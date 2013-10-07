From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 07/77] PCI/MSI: Re-design MSI/MSI-X interrupts
 enablement pattern
Date: Mon, 7 Oct 2013 14:17:49 -0400
Message-ID: <20131007181749.GB27396@htj.dyndns.org>
References: <cover.1380703262.git.agordeev@redhat.com>
 <d8c36203ada6efbfa9f7ce92c2f713ee3b6d6b8d.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	linux-pci@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
	linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMware, Inc." <pv-dr
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d8c36203ada6efbfa9f7ce92c2f713ee3b6d6b8d.1380703262.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Oct 02, 2013 at 12:48:23PM +0200, Alexander Gordeev wrote:
> +static int foo_driver_enable_msi(struct foo_adapter *adapter, int nvec)
> +{
> +	rc = pci_get_msi_cap(adapter->pdev);
> +	if (rc < 0)
> +		return rc;
> +
> +	nvec = min(nvec, rc);
> +	if (nvec < FOO_DRIVER_MINIMUM_NVEC) {
> +		return -ENOSPC;
> +
> +	rc = pci_enable_msi_block(adapter->pdev, nvec);
> +	return rc;
> +}

If there are many which duplicate the above pattern, it'd probably be
worthwhile to provide a helper?  It's usually a good idea to reduce
the amount of boilerplate code in drivers.

>  static int foo_driver_enable_msix(struct foo_adapter *adapter, int nvec)
>  {
> +	rc = pci_msix_table_size(adapter->pdev);
> +	if (rc < 0)
> +		return rc;
> +
> +	nvec = min(nvec, rc);
> +	if (nvec < FOO_DRIVER_MINIMUM_NVEC) {
> +		return -ENOSPC;
> +
> +	for (i = 0; i < nvec; i++)
> +		adapter->msix_entries[i].entry = i;
> +
> +	rc = pci_enable_msix(adapter->pdev, adapter->msix_entries, nvec);
> +	return rc;
>  }

Ditto.

> @@ -975,7 +951,7 @@ int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
>  	if (nr_entries < 0)
>  		return nr_entries;
>  	if (nvec > nr_entries)
> -		return nr_entries;
> +		return -EINVAL;
>  
>  	/* Check for any invalid entries */
>  	for (i = 0; i < nvec; i++) {

If we do things this way, it breaks all drivers using this interface
until they're converted, right?  Also, it probably isn't the best idea
to flip the behavior like this as this can go completely unnoticed (no
compiler warning or anything, the same function just behaves
differently).  Maybe it'd be a better idea to introduce a simpler
interface that most can be converted to?

Thanks.

-- 
tejun
