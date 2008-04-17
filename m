From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
Date: Thu, 17 Apr 2008 14:25:18 -0700
Message-ID: <4807C03E.7060705@intel.com>
References: <20080411135851.GD8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, kaber@trash.net, jeff@garzik.org,
	netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943AbYDQV0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 17:26:51 -0400
In-Reply-To: <20080411135851.GD8137@tp64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> If the netdev goes into mode promiscuous, receive all of the packets on
> the wire without HW filtering, those packets will be processed as type
> PACKET_OTHERHOST.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>


this is a repost afaics with the same idea as previous.

I however can't make sense out of what the consensus was in the discussion that
previously took place.

My techical objection against this patch is that it removes flexibility from the
admin to display only the particular vlan traffic. With this patch there is no
longer a way to sniff just one vlan and forget about the other traffic.

My logistical objection against this patch is that it adjusts only one/two drivers
to do something, but I don't see anything consistently in all the drivers at all
that suggest that this is the right thing to do at all. Either a mandate or
something suggesting that all drivers that do vlan filtering *should* do something
 specific in promiscuous mode.

Either it should be clear that all drivers should do the same thing (and you
should then adjust all the drivers and not just the one or two that you use, and
preferably in the stack if possible) or we leave this as is for all the drivers.

I think we should prevent wild growth like e.g. module parameters like
`vlan_tag_strip` in s2io (NO_STRIP_IN_PROMISC)... !

so I don't think this is a good idea.

Auke


> ---
>  drivers/net/e1000/e1000_main.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 0991648..61965c2 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -2495,7 +2495,7 @@ e1000_set_rx_mode(struct net_device *netdev)
>  	struct e1000_hw *hw = &adapter->hw;
>  	struct dev_addr_list *uc_ptr;
>  	struct dev_addr_list *mc_ptr;
> -	uint32_t rctl;
> +	uint32_t rctl, ctrl;
>  	uint32_t hash_value;
>  	int i, rar_entries = E1000_RAR_ENTRIES;
>  	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
> @@ -2512,13 +2512,19 @@ e1000_set_rx_mode(struct net_device *netdev)
>  	/* Check for Promiscuous and All Multicast modes */
>  
>  	rctl = E1000_READ_REG(hw, RCTL);
> +	ctrl = E1000_READ_REG(hw, CTRL);
>  
>  	if (netdev->flags & IFF_PROMISC) {
>  		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
> -	} else if (netdev->flags & IFF_ALLMULTI) {
> -		rctl |= E1000_RCTL_MPE;
> +		rctl &= ~E1000_RCTL_VFE;
>  	} else {
> -		rctl &= ~E1000_RCTL_MPE;
> +		if (ctrl & E1000_CTRL_VME &&
> +		    adapter->hw.mac_type != e1000_ich8lan)
> +			rctl |= E1000_RCTL_VFE;
> +		if (netdev->flags & IFF_ALLMULTI)
> +			rctl |= E1000_RCTL_MPE;
> +		else
> +			rctl &= ~E1000_RCTL_MPE;
>  	}
>  
>  	uc_ptr = NULL;
> @@ -5013,7 +5019,10 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
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

