From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Thu, 10 Dec 2009 11:45:30 +1100
Message-ID: <20091210004530.GG4163@verge.net.au>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091208221435.28373.76070.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49079 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759145AbZLJApY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:45:24 -0500
Content-Disposition: inline
In-Reply-To: <20091208221435.28373.76070.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 02:14:36PM -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Adds SR-IOV features supported by the 82599 controller to the main driver
> module.  If the CONFIG_PCI_IOV kernel option is selected then the SR-IOV
> features are enabled.  Use the max_vfs module option to allocate up to 63
> virtual functions per physical port.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |  270 ++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 259 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 35ea8c9..0bde380 100644

[snip]

> @@ -5767,6 +5954,52 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>  		goto err_sw_init;
>  	}
>  
> +#ifdef CONFIG_PCI_IOV
> +	if (hw->mac.type == ixgbe_mac_82599EB) {
> +		/* The 82599 supports up to 64 VFs per physical function
> +		 * but this implementation limits allocation to 63 so that
> +		 * basic networking resources are still available to the
> +		 * physical function
> +		 */
> +		adapter->num_vfs = (max_vfs > 63) ? 63 : max_vfs;
> +		if (adapter->num_vfs) {
> +			adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
> +			err = pci_enable_sriov(pdev, adapter->num_vfs);
> +			if (err) {
> +				DPRINTK(PROBE, ERR,
> +					"Failed to enable PCI sriov: %d\n",
> +					err);
> +				adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
> +				adapter->num_vfs = 0;
> +			}
> +		}
> +		/* If call to enable VFs succeeded then allocate memory
> +		 * for per VF control structures.
> +		 */
> +		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
> +			adapter->vfinfo =
> +				kcalloc(adapter->num_vfs,
> +					sizeof(struct vf_data_storage),
> +					GFP_KERNEL);
> +			if (!adapter->vfinfo) {
> +				/* Oh oh */
> +				DPRINTK(PROBE, ERR,
> +					"Unable to allocate memory for VF "
> +					"Data Storage - SRIOV disabled\n");
> +				adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
> +				adapter->num_vfs = 0;

A call to pci_disable_sriov(pdev) is needed here?

> +			} else {
> +				/* Now that we're sure SR-IOV is enabled
> +				 * set up the mailbox parameters
> +				 */
> +				ixgbe_init_mbx_params_pf(hw);
> +				memcpy(&hw->mbx.ops, ii->mbx_ops,
> +				       sizeof(hw->mbx.ops));
> +			}
> +		}
> +	}
> +
> +#endif /* CONFIG_PCI_IOV */
>  	netdev->features = NETIF_F_SG |
>  	                   NETIF_F_IP_CSUM |
>  	                   NETIF_F_HW_VLAN_TX |

I wonder if it would be easier on the eyes to break the hunk above out into
a ixgbe_probe_vf() function. Something like (compile tested only, I don't
have an 82599):

static void ixgbe_probe_vf(struct ixgbe_adapter *adapter,
                           const struct ixgbe_info *ii)
{
#ifdef CONFIG_PCI_IOV
	struct ixgbe_hw *hw = &adapter->hw;
        int err;

	if (hw->mac.type != ixgbe_mac_82599EB || !max_vfs)
		return;

	/* The 82599 supports up to 64 VFs per physical function
	 * but this implementation limits allocation to 63 so that
	 * basic networking resources are still available to the
	 * physical function
	 */
	adapter->num_vfs = (max_vfs > 63) ? 63 : max_vfs;
	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
	err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
	if (err) {
		DPRINTK(PROBE, ERR, "Failed to enable PCI sriov: %d\n", err);
		goto err_novf;
	}

	adapter->vfinfo = kcalloc(adapter->num_vfs,
				  sizeof(struct vf_data_storage), GFP_KERNEL);
	if (!adapter->vfinfo) {
		/* Oh oh */
		DPRINTK(PROBE, ERR, "Unable to allocate memory for VF "
			"Data Storage - SRIOV disabled\n");
		goto err_sriov;
	}

	/* Now that we're sure SR-IOV is enabled
	 * set up the mailbox parameters
	 */
	ixgbe_init_mbx_params_pf(hw);
	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));

	return;
err_sriov:
        pci_disable_sriov(adapter->pdev);
err_novf:
	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
	adapter->num_vfs = 0;
	return;
#endif /* CONFIG_PCI_IOV */
	;
}

