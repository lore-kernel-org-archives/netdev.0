From: Mark Lord <kernel@start.ca>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement pattern
Date: Thu, 10 Oct 2013 19:17:18 -0400
Message-ID: <5257357E.8080506@start.ca>
References: <cover.1380703262.git.agordeev@redhat.com> <5254D397.9030307@zytor.com> <1381292648.645.259.camel@pasglop> <20131010101704.GC11874@dhcp-26-207.brq.redhat.com> <5256D5AB.4050105@zytor.com> <20131010180704.GA15719@dhcp-26-207.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
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
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
        linux-dr
To: Alexander Gordeev <agordeev@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20131010180704.GA15719@dhcp-26-207.brq.redhat.com>
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

Just to help us all understand "the loop" issue..

Here's an example of driver code which uses the existing MSI-X interfaces,
for a device which can work with either 16, 8, 4, 2, or 1 MSI-X interrupt.
This is from a new driver I'm working on right now:


static int xx_alloc_msix_irqs (struct xx_dev *dev, int nvec)
{
        xx_disable_all_irqs(dev);
        do {
                if (nvec < 2)
                        xx_prep_for_1_msix_vector(dev);
                else if (nvec < 4)
                        xx_prep_for_2_msix_vectors(dev);
                else if (nvec < 8)
                        xx_prep_for_4_msix_vectors(dev);
                else if (nvec < 16)
                        xx_prep_for_8_msix_vectors(dev);
                else
                        xx_prep_for_16_msix_vectors(dev);
                nvec = pci_enable_msix(dev->pdev, dev->irqs, dev->num_vectors);
        } while (nvec > 0);

        if (nvec) {
                kerr(dev->name, "pci_enable_msix() failed, err=%d", nvec);
                dev->num_vectors = 0;
                return nvec;
        }
        return 0;       /* success */
}
