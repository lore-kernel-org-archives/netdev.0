From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] bna: fix vlan tag stripping and implement its
 toggling
Date: Fri, 28 Feb 2014 10:42:03 +0100
Message-ID: <20140228094203.GA22153@breakpoint.cc>
References: <1393578674-12658-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, rmody@brocade.com,
	jiri@resnulli.us
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42540 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbaB1JmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 04:42:07 -0500
Content-Disposition: inline
In-Reply-To: <1393578674-12658-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> wrote:
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
> index cf64f3d..bc09056 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad.c
> @@ -707,7 +707,8 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
>  		else
>  			skb_checksum_none_assert(skb);
>  
> -		if (flags & BNA_CQ_EF_VLAN)
> +		if ((flags & BNA_CQ_EF_VLAN) &&
> +		    (bnad->netdev->features & NETIF_F_HW_VLAN_CTAG_RX))
>  			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(cmpl->vlan_tag));
>  
>  		if (BNAD_RXBUF_IS_SK_BUFF(unmap_q->type))
> @@ -3245,11 +3246,6 @@ bnad_set_rx_mode(struct net_device *netdev)
>  			BNA_RXMODE_ALLMULTI;
>  	bna_rx_mode_set(bnad->rx_info[0].rx, new_mode, mode_mask, NULL);
>  
> -	if (bnad->cfg_flags & BNAD_CF_PROMISC)
> -		bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
> -	else
> -		bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
> -
>  	spin_unlock_irqrestore(&bnad->bna_lock, flags);
>  }
>  
> @@ -3374,6 +3370,27 @@ bnad_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
>  	return 0;
>  }
>  
> +int bnad_set_features(struct net_device *dev, netdev_features_t features)
> +{

Nit: static?
