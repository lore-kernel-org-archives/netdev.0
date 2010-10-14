From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC PATCH 3/7] bnx2: Update bnx2 to use new vlan
 accleration.
Date: Thu, 14 Oct 2010 15:56:00 -0700
Message-ID: <1287096960.14523.31.camel@nseg_linux_HP1.broadcom.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
 <1287000177-7126-4-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jesse Gross" <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2549 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506Ab0JNW6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 18:58:47 -0400
In-Reply-To: <1287000177-7126-4-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2010-10-13 at 13:02 -0700, Jesse Gross wrote:
> Make the bnx2 driver use the new vlan accleration model.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |   75 +++------------------------------------------------
>  drivers/net/bnx2.h |    4 ---
>  2 files changed, 5 insertions(+), 74 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index ae894bc..2d306f4 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -37,9 +37,6 @@
>  #include <linux/ethtool.h>
>  #include <linux/mii.h>
>  #include <linux/if_vlan.h>
> -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> -#define BCM_VLAN 1
> -#endif
>  #include <net/ip.h>
>  #include <net/tcp.h>
>  #include <net/checksum.h>
> @@ -3087,8 +3084,6 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  		struct sw_bd *rx_buf, *next_rx_buf;
>  		struct sk_buff *skb;
>  		dma_addr_t dma_addr;
> -		u16 vtag = 0;
> -		int hw_vlan __maybe_unused = 0;
>  
>  		sw_ring_cons = RX_RING_IDX(sw_cons);
>  		sw_ring_prod = RX_RING_IDX(sw_prod);
> @@ -3168,23 +3163,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  			goto next_rx;
>  
>  		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
> -		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) {
> -			vtag = rx_hdr->l2_fhdr_vlan_tag;
> -#ifdef BCM_VLAN
> -			if (bp->vlgrp)
> -				hw_vlan = 1;
> -			else
> -#endif
> -			{
> -				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
> -					__skb_push(skb, 4);
> -
> -				memmove(ve, skb->data + 4, ETH_ALEN * 2);
> -				ve->h_vlan_proto = htons(ETH_P_8021Q);
> -				ve->h_vlan_TCI = htons(vtag);
> -				len += 4;
> -			}
> -		}
> +		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG))

This check for the rx_mode bit is no longer necessary if we always
configure the chip to strip out the vlan tag.


> +			__vlan_hwaccel_put_tag(skb, rx_hdr->l2_fhdr_vlan_tag);
>  
>  		skb->protocol = eth_type_trans(skb, bp->dev);
>  
> @@ -3211,14 +3191,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  			skb->rxhash = rx_hdr->l2_fhdr_hash;
>  
>  		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
> -
> -#ifdef BCM_VLAN
> -		if (hw_vlan)
> -			vlan_gro_receive(&bnapi->napi, bp->vlgrp, vtag, skb);
> -		else
> -#endif
> -			napi_gro_receive(&bnapi->napi, skb);
> -
> +		napi_gro_receive(&bnapi->napi, skb);
>  		rx_pkt++;
>  
>  next_rx:
> @@ -3533,13 +3506,6 @@ bnx2_set_rx_mode(struct net_device *dev)
>  	rx_mode = bp->rx_mode & ~(BNX2_EMAC_RX_MODE_PROMISCUOUS |
>  				  BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG);
>  	sort_mode = 1 | BNX2_RPM_SORT_USER0_BC_EN;
> -#ifdef BCM_VLAN
> -	if (!bp->vlgrp && (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
> -		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
> -#else
> -	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
> -		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
> -#endif
>  	if (dev->flags & IFF_PROMISC) {
>  		/* Promiscuous mode. */
>  		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
> @@ -6365,29 +6331,6 @@ bnx2_tx_timeout(struct net_device *dev)
>  	schedule_work(&bp->reset_task);
>  }
>  
> -#ifdef BCM_VLAN
> -/* Called with rtnl_lock */
> -static void
> -bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
> -{
> -	struct bnx2 *bp = netdev_priv(dev);
> -
> -	if (netif_running(dev))
> -		bnx2_netif_stop(bp, false);
> -
> -	bp->vlgrp = vlgrp;
> -
> -	if (!netif_running(dev))
> -		return;
> -
> -	bnx2_set_rx_mode(dev);
> -	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
> -		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
> -
> -	bnx2_netif_start(bp, false);
> -}
> -#endif
> -
>  /* Called with netif_tx_lock.
>   * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
>   * netif_wake_queue().
> @@ -6428,12 +6371,11 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
>  	}
>  
> -#ifdef BCM_VLAN
> -	if (bp->vlgrp && vlan_tx_tag_present(skb)) {
> +	if (vlan_tx_tag_present(skb)) {
>  		vlan_tag_flags |=
>  			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
>  	}
> -#endif
> +
>  	if ((mss = skb_shinfo(skb)->gso_size)) {
>  		u32 tcp_opt_len;
>  		struct iphdr *iph;
> @@ -8318,9 +8260,6 @@ static const struct net_device_ops bnx2_netdev_ops = {
>  	.ndo_set_mac_address	= bnx2_change_mac_addr,
>  	.ndo_change_mtu		= bnx2_change_mtu,
>  	.ndo_tx_timeout		= bnx2_tx_timeout,
> -#ifdef BCM_VLAN
> -	.ndo_vlan_rx_register	= bnx2_vlan_rx_register,
> -#endif
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	= poll_bnx2,
>  #endif
> @@ -8328,9 +8267,7 @@ static const struct net_device_ops bnx2_netdev_ops = {
>  
>  static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
>  {
> -#ifdef BCM_VLAN
>  	dev->vlan_features |= flags;
> -#endif
>  }
>  
>  static int __devinit
> @@ -8379,9 +8316,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		dev->features |= NETIF_F_IPV6_CSUM;
>  		vlan_features_add(dev, NETIF_F_IPV6_CSUM);
>  	}
> -#ifdef BCM_VLAN
>  	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> -#endif
>  	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
>  	vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
>  	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
> diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> index efdfbc2..4f44db6 100644
> --- a/drivers/net/bnx2.h
> +++ b/drivers/net/bnx2.h
> @@ -6742,10 +6742,6 @@ struct bnx2 {
>  
>  	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
>  
> -#ifdef BCM_VLAN
> -	struct			vlan_group *vlgrp;
> -#endif
> -
>  	u32			rx_buf_use_size;	/* useable size */
>  	u32			rx_buf_size;		/* with alignment */
>  	u32			rx_copy_thresh;


