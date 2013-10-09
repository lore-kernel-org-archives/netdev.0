From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement pattern
Date: Tue, 08 Oct 2013 20:55:03 -0700
Message-ID: <5254D397.9030307@zytor.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
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
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
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

On 10/02/2013 03:29 AM, Alexander Gordeev wrote:
> 
> As result, device drivers will cease to use the overcomplicated
> repeated fallbacks technique and resort to a straightforward
> pattern - determine the number of MSI/MSI-X interrupts required
> before calling pci_enable_msi_block() and pci_enable_msix()
> interfaces:
> 
> 
> 	rc = pci_msix_table_size(adapter->pdev);
> 	if (rc < 0)
> 		return rc;
> 
> 	nvec = min(nvec, rc);
> 	if (nvec < FOO_DRIVER_MINIMUM_NVEC) {
> 		return -ENOSPC;
> 
> 	for (i = 0; i < nvec; i++)
> 		adapter->msix_entries[i].entry = i;
> 
> 	rc = pci_enable_msix(adapter->pdev,
> 			     adapter->msix_entries, nvec);
> 	return rc;
> 

Why not add a minimum number to pci_enable_msix(), i.e.:

pci_enable_msix(pdev, msix_entries, nvec, minvec)

... which means "nvec" is the number of interrupts *requested*, and
"minvec" is the minimum acceptable number (otherwise fail).

	-hpa
