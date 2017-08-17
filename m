From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH] PCI: Allow PCI express root ports to find themselves
Date: Thu, 17 Aug 2017 11:58:47 -0500
Message-ID: <20170817165847.GJ28977@bhelgaas-glaptop.roam.corp.google.com>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
 <20170817110614.11454-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Michael Ellerman <mpe@ellerman.id.au>, mark.rutland@arm.com,
        gabriele.paoloni@huawei.com, asit.k.mallick@intel.com,
        catalin.marinas@arm.com, will.deacon@arm.com, linuxarm@huawei.com,
        alexander.duyck@gmail.com, ashok.raj@intel.com,
        eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
        linux-pci@vger.kernel.org, ganeshgr@chelsio.com, Bob.Shaw@amd.com,
        leedom@chelsio.com, patrick.j.cramer@intel.com, werner@chelsio.com,
        linux-arm-kernel@lists.infradead.org, amira@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David.Laight@aculab.com, Suravee.Suthikulpanit@amd.com,
        robin.murphy@arm.com, l.stach@pengutronix.de
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170817110614.11454-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2017 at 01:06:14PM +0200, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> If the pci_find_pcie_root_port() function is called on a root port
> itself, return the root port rather than NULL.
> 
> This effectively reverts commit 0e405232871d6 ("PCI: fix oops when
> try to find Root Port for a PCI device") which added an extra check
> that would now be redundant.
> 
> Fixes: a99b646afa8a ("PCI: Disable PCIe Relaxed Ordering if unsupported")
> Fixes: c56d4450eb68 ("PCI: Turn off Request Attributes to avoid Chelsio T5 Completion erratum")
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

I *think* this should work for everybody, but I can't test it personally.

> ---
> This applies on top of and was tested on next-20170817.
> 
> Michael, it'd be great if you could test this one again to clarify
> whether or not the fix that's already in Linus' tree is still needed, or
> whether it's indeed obsoleted by this patch.
> 
>  drivers/pci/pci.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index b05c587e335a..dd56c1c05614 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -514,7 +514,7 @@ EXPORT_SYMBOL(pci_find_resource);
>   */
>  struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>  {
> -	struct pci_dev *bridge, *highest_pcie_bridge = NULL;
> +	struct pci_dev *bridge, *highest_pcie_bridge = dev;
>  
>  	bridge = pci_upstream_bridge(dev);
>  	while (bridge && pci_is_pcie(bridge)) {
> @@ -522,11 +522,10 @@ struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>  		bridge = pci_upstream_bridge(bridge);
>  	}
>  
> -	if (highest_pcie_bridge &&
> -	    pci_pcie_type(highest_pcie_bridge) == PCI_EXP_TYPE_ROOT_PORT)
> -		return highest_pcie_bridge;
> +	if (pci_pcie_type(highest_pcie_bridge) != PCI_EXP_TYPE_ROOT_PORT)
> +		return NULL;
>  
> -	return NULL;
> +	return highest_pcie_bridge;
>  }
>  EXPORT_SYMBOL(pci_find_pcie_root_port);
>  
> -- 
> 2.13.3
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
