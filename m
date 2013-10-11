From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Fri, 11 Oct 2013 10:41:09 +0200
Message-ID: <20131011084108.GA25702@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <5254D397.9030307@zytor.com>
 <1381292648.645.259.camel@pasglop>
 <20131010101704.GC11874@dhcp-26-207.brq.redhat.com>
 <5256D5AB.4050105@zytor.com>
 <20131010180704.GA15719@dhcp-26-207.brq.redhat.com>
 <5257357E.8080506@start.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-dev
To: Mark Lord <kernel@start.ca>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <5257357E.8080506@start.ca>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 07:17:18PM -0400, Mark Lord wrote:
> Just to help us all understand "the loop" issue..
> 
> Here's an example of driver code which uses the existing MSI-X interfaces,
> for a device which can work with either 16, 8, 4, 2, or 1 MSI-X interrupt.
> This is from a new driver I'm working on right now:
> 
> 
> static int xx_alloc_msix_irqs (struct xx_dev *dev, int nvec)
> {
>         xx_disable_all_irqs(dev);
>         do {
>                 if (nvec < 2)
>                         xx_prep_for_1_msix_vector(dev);
>                 else if (nvec < 4)
>                         xx_prep_for_2_msix_vectors(dev);
>                 else if (nvec < 8)
>                         xx_prep_for_4_msix_vectors(dev);
>                 else if (nvec < 16)
>                         xx_prep_for_8_msix_vectors(dev);
>                 else
>                         xx_prep_for_16_msix_vectors(dev);
>                 nvec = pci_enable_msix(dev->pdev, dev->irqs, dev->num_vectors);
>         } while (nvec > 0);
> 
>         if (nvec) {
>                 kerr(dev->name, "pci_enable_msix() failed, err=%d", nvec);
>                 dev->num_vectors = 0;
>                 return nvec;
>         }
>         return 0;       /* success */
> }

Yeah, that is a very good example.

I would move all xx_prep_for_<pow2>_msix_vector() functions to a single
helper i.e. xx_prep_msix_vectors(dev, ndev).

Considering also (a) we do not want to waste unused platform resources
associated with MSI-Xs and pull more quota than needed and (b) fixing
couple of bugs, this function could look like this:

static int xx_alloc_msix_irqs(struct xx_dev *dev, int nvec_in)
{
	int nvec = roundup_pow_of_two(nvec_in);	/* assume 0 > nvec_in <= 16 */
	int rc;

	xx_disable_all_irqs(dev);

retry:
       	xx_prep_for_msix_vectors(dev, nvec);

	rc = pci_enable_msix(dev->pdev, dev->irqs, nvec);	/* (b) */
	if (rc > 0) {
		nvec = rounddown_pow_of_two(nvec);		/* (a) */
		goto retry;
	}

	if (rc) {
		kerr(dev->name, "pci_enable_msix() failed, err=%d", rc);
		dev->num_vectors = 0;
		return rc;
	}

	dev->num_vectors = nvec;				/* (b) */
	return 0;       /* success */
}

Now, this is a loop-free alternative:

static int xx_alloc_msix_irqs(struct xx_dev *dev, int nvec)
{
	nvec = roundup_pow_of_two(nvec);	/* assume 0 > nvec <= 16 */

	xx_disable_all_irqs(dev);

	pci_lock_msi(dev->pdev);

	rc = pci_get_msix_limit(dev->pdev, nvec);
	if (rc < 0)
		goto err;

	nvec = min(nvec, rc);		/* if limit is more than requested */
	nvec = rounddown_pow_of_two(nvec);	/* (a) */

	xx_prep_for_msix_vectors(dev, nvec);

	rc = pci_enable_msix(dev->pdev, dev->irqs, nvec);	/* (b)	*/
	if (rc < 0)
		goto err;

	pci_unlock_msi(dev->pdev);

	dev->num_vectors = nvec;		/* (b) */
	return 0;

err:
	pci_unlock_msi(dev->pdev);

        kerr(dev->name, "pci_enable_msix() failed, err=%d", rc);
        dev->num_vectors = 0;
        return rc;
}

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
