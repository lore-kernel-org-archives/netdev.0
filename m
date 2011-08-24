From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 2/2] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 24 Aug 2011 14:16:32 +0300
Message-ID: <201108241416.32584.vladz@broadcom.com>
References: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
 <20110823161539.24707.9577.stgit@dhcp-29-224.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4577 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855Ab1HXLQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 07:16:56 -0400
In-Reply-To: <20110823161539.24707.9577.stgit@dhcp-29-224.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 August 2011 19:15:39 Michal Schmidt wrote:
> Allow disabling of HW RX VLAN stripping with ethtool.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Vladislav Zolotarov <vladz@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Dmitry Kravkov <dmitry@broadcom.com>
> ---
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   18 ++++++++++++++----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 +++++-----
>  3 files changed, 20 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h index f127768..dd43634
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -1178,6 +1178,7 @@ struct bnx2x {
>  #define NO_MCP_FLAG			(1 << 9)
> 
>  #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
> +#define RX_VLAN_STRIP_FLAG		(1 << 10)
>  #define MF_FUNC_DIS			(1 << 11)
>  #define OWN_CNIC_IRQ			(1 << 12)
>  #define NO_ISCSI_OOO_FLAG		(1 << 13)
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c index 93bff08..340bff9
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -385,6 +385,10 @@ static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp,
> u16 parsing_flags, else /* IPv4 */
>  		hdrs_len += sizeof(struct iphdr);
> 
> +	/* VLAN header present and not stripped by HW */
> +	if ((parsing_flags & PARSING_FLAGS_VLAN) &&
> +	    !(bp->flags & RX_VLAN_STRIP_FLAG))
> +		hdrs_len += VLAN_HLEN;
> 
>  	/* Check if there was a TCP timestamp, if there is it's will
>  	 * always be 12 bytes length: nop nop kind length echo val.
> @@ -412,7 +416,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct
> bnx2x_fastpath *fp, frag_size = le16_to_cpu(cqe->pkt_len) - len_on_bd;
>  	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
> 
> -	/* This is needed in order to enable forwarding support */
> +	/* Doing LRO, let TCP know the receive MSS */
>  	if (frag_size)
>  		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
>  					tpa_info->parsing_flags, len_on_bd);
> @@ -514,7 +518,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct
> bnx2x_fastpath *fp, skb->ip_summed = CHECKSUM_UNNECESSARY;
> 
>  		if (!bnx2x_fill_frag_skb(bp, fp, queue, skb, cqe, cqe_idx)) {
> -			if (tpa_info->parsing_flags & PARSING_FLAGS_VLAN)
> +			if ((tpa_info->parsing_flags & PARSING_FLAGS_VLAN) &&
> +			    (bp->flags & RX_VLAN_STRIP_FLAG))
>  				__vlan_hwaccel_put_tag(skb, tpa_info-
>vlan_tag);
>  			napi_gro_receive(&fp->napi, skb);
>  		} else {
> @@ -757,8 +762,8 @@ reuse_rx:
> 
>  		skb_record_rx_queue(skb, fp->index);
> 
> -		if (le16_to_cpu(cqe_fp->pars_flags.flags) &
> -		    PARSING_FLAGS_VLAN)
> +		if ((le16_to_cpu(cqe_fp->pars_flags.flags) &
> +		    PARSING_FLAGS_VLAN) && (bp->flags & RX_VLAN_STRIP_FLAG))
>  			__vlan_hwaccel_put_tag(skb,
>  					       le16_to_cpu(cqe_fp->vlan_tag));
>  		napi_gro_receive(&fp->napi, skb);
> @@ -3431,6 +3436,11 @@ int bnx2x_set_features(struct net_device *dev, u32
> features) else
>  		flags &= ~TPA_ENABLE_FLAG;
> 
> +	if (features & NETIF_F_HW_VLAN_RX)
> +		flags |= RX_VLAN_STRIP_FLAG;
> +	else
> +		flags &= ~RX_VLAN_STRIP_FLAG;
> +
>  	if (features & NETIF_F_LOOPBACK) {
>  		if (bp->link_params.loopback_mode != LOOPBACK_BMAC) {
>  			bp->link_params.loopback_mode = LOOPBACK_BMAC;
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index 85dd294..e444e7d
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2722,9 +2722,8 @@ static inline unsigned long bnx2x_get_q_flags(struct
> bnx2x *bp, __set_bit(BNX2X_Q_FLG_MCAST, &flags);
>  	}
> 
> -	/* Always set HW VLAN stripping */
> -	__set_bit(BNX2X_Q_FLG_VLAN, &flags);
> -
> +	if (bp->flags & RX_VLAN_STRIP_FLAG)
> +		__set_bit(BNX2X_Q_FLG_VLAN, &flags);
> 
>  	return flags | bnx2x_get_common_flags(bp, fp, true);
>  }
> @@ -10286,12 +10285,13 @@ static int __devinit bnx2x_init_dev(struct
> pci_dev *pdev,
> 
>  	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_LRO |
> -		NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
> +		NETIF_F_RXCSUM | NETIF_F_RXHASH |
> +		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> 
>  	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM 
|
>  		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | 
NETIF_F_HIGHDMA;
> 
> -	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
> +	dev->features |= dev->hw_features;
>  	if (bp->flags & USING_DAC_FLAG)
>  		dev->features |= NETIF_F_HIGHDMA;

NACK as u set the RX_VLAN_STRIP_FLAG in bp->flags before u reset the function, 
thus there is a real posibility that u would handle the pending packets 
(during unload) under the new stripping policy while it's not yet configured 
in the HW. 

thanks,
vlad
