From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous
 mode
Date: Mon, 12 Nov 2007 09:12:40 -0800
Message-ID: <47388988.1000506@intel.com>
References: <47365200.0f10240a.0686.2173@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>, netdev@vger.kernel.org,
	'Dave Johnson' <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25084 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbXKLRNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 12:13:11 -0500
In-Reply-To: <47365200.0f10240a.0686.2173@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote:
> IMHO even though netdevice is in the promiscuous mode, we should receive all of ingress packets.
> This disable the vlan filtering feature when a vlan hw accel configured e1000 device goes into promiscuous mode.
> This make packets visible to sniffers though it's not vlan id of itself.
> Any check, comments will be appreciated.

Actually I think this patch removes a choice from the user.

Before this patch, the user can sniff all traffic by disabling vlans, or a
specific vlan only by leaving vlans on when going into promisc mode.

After this patch, the user has no choice but to sniff all vlans at all times.

I don't think that that is such a good improvement.

Auke


> Thanks.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  drivers/net/e1000/e1000_main.c |   26 ++++++++++++++++++++------
>  1 files changed, 20 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c index 72deff0..cdd5c84 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -2424,7 +2424,7 @@ e1000_set_multi(struct net_device *netdev)
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  	struct e1000_hw *hw = &adapter->hw;
>  	struct dev_mc_list *mc_ptr;
> -	uint32_t rctl;
> +	uint32_t rctl, ctrl;
>  	uint32_t hash_value;
>  	int i, rar_entries = E1000_RAR_ENTRIES;
>  	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
> @@ -2441,14 +2441,25 @@ e1000_set_multi(struct net_device *netdev)
>  	/* Check for Promiscuous and All Multicast modes */
>  
>  	rctl = E1000_READ_REG(hw, RCTL);
> +	ctrl = E1000_READ_REG(&adapter->hw, CTRL);
>  
>  	if (netdev->flags & IFF_PROMISC) {
>  		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
> -	} else if (netdev->flags & IFF_ALLMULTI) {
> -		rctl |= E1000_RCTL_MPE;
> -		rctl &= ~E1000_RCTL_UPE;
> +		if (adapter->hw.mac_type != e1000_ich8lan) {
> +			if (ctrl & E1000_CTRL_VME)
> +				rctl &= ~E1000_RCTL_VFE;
> +		}
>  	} else {
> -		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
> +		if (adapter->hw.mac_type != e1000_ich8lan) {
> +			if (ctrl & E1000_CTRL_VME)
> +				rctl |= E1000_RCTL_VFE;
> +		}
> +		if (netdev->flags & IFF_ALLMULTI) {
> +			rctl |= E1000_RCTL_MPE;
> +			rctl &= ~E1000_RCTL_UPE;
> +		} else {
> +			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
> +		}
>  	}
>  
>  	E1000_WRITE_REG(hw, RCTL, rctl);
> @@ -4952,7 +4963,10 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
>  		if (adapter->hw.mac_type != e1000_ich8lan) {
>  			/* enable VLAN receive filtering */
>  			rctl = E1000_READ_REG(&adapter->hw, RCTL);
> -			rctl |= E1000_RCTL_VFE;
> +			if (netdev->flags & IFF_PROMISC)
> +				rctl &= ~E1000_RCTL_VFE;
> +			else
> +				rctl |= E1000_RCTL_VFE;
>  			rctl &= ~E1000_RCTL_CFIEN;
>  			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
>  			e1000_update_mng_vlan(adapter);
> ---
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
