From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 03/11] tg3: Use new VLAN code
Date: Tue, 25 Jan 2011 17:58:49 -0800
Message-ID: <1296007137-23146-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1809 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab1AZB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch pivots the tg3 driver to the new VLAN infrastructure.
All references to vlgrp have been removed.  The driver still attempts to
disable VLAN tag stripping if CONFIG_VLAN_8021Q or
CONFIG_VLAN_8021Q_MODULE is not defined.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   95 +++++-----------------------------------------------
 drivers/net/tg3.h |    3 --
 2 files changed, 10 insertions(+), 88 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8756f31..07da2b5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -60,12 +60,6 @@
 #define BAR_0	0
 #define BAR_2	2
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define TG3_VLAN_TAG_USED 1
-#else
-#define TG3_VLAN_TAG_USED 0
-#endif
-
 #include "tg3.h"
 
 #define DRV_MODULE_NAME		"tg3"
@@ -134,9 +128,6 @@
 				 TG3_TX_RING_SIZE)
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
 
-#define TG3_RX_DMA_ALIGN		16
-#define TG3_RX_HEADROOM			ALIGN(VLAN_HLEN, TG3_RX_DMA_ALIGN)
-
 #define TG3_DMA_BYTE_ENAB		64
 
 #define TG3_RX_STD_DMA_SZ		1536
@@ -4722,8 +4713,6 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u32 opaque_key, desc_idx, *post_ptr;
-		bool hw_vlan __maybe_unused = false;
-		u16 vtag __maybe_unused = 0;
 
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
@@ -4782,12 +4771,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			tg3_recycle_rx(tnapi, tpr, opaque_key,
 				       desc_idx, *post_ptr);
 
-			copy_skb = netdev_alloc_skb(tp->dev, len + VLAN_HLEN +
+			copy_skb = netdev_alloc_skb(tp->dev, len +
 						    TG3_RAW_IP_ALIGN);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN + VLAN_HLEN);
+			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
@@ -4814,30 +4803,11 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		}
 
 		if (desc->type_flags & RXD_FLAG_VLAN &&
-		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG)) {
-			vtag = desc->err_vlan & RXD_VLAN_MASK;
-#if TG3_VLAN_TAG_USED
-			if (tp->vlgrp)
-				hw_vlan = true;
-			else
-#endif
-			{
-				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
-						    __skb_push(skb, VLAN_HLEN);
-
-				memmove(ve, skb->data + VLAN_HLEN,
-					ETH_ALEN * 2);
-				ve->h_vlan_proto = htons(ETH_P_8021Q);
-				ve->h_vlan_TCI = htons(vtag);
-			}
-		}
+		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG))
+			__vlan_hwaccel_put_tag(skb,
+					       desc->err_vlan & RXD_VLAN_MASK);
 
-#if TG3_VLAN_TAG_USED
-		if (hw_vlan)
-			vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
-		else
-#endif
-			napi_gro_receive(&tnapi->napi, skb);
+		napi_gro_receive(&tnapi->napi, skb);
 
 		received++;
 		budget--;
@@ -5740,11 +5710,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
 	}
 
-#if TG3_VLAN_TAG_USED
 	if (vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
-#endif
 
 	len = skb_headlen(skb);
 
@@ -5986,11 +5954,10 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			}
 		}
 	}
-#if TG3_VLAN_TAG_USED
+
 	if (vlan_tx_tag_present(skb))
 		base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
-#endif
 
 	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
@@ -9537,17 +9504,10 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	rx_mode = tp->rx_mode & ~(RX_MODE_PROMISC |
 				  RX_MODE_KEEP_VLAN_TAG);
 
+#if !defined(CONFIG_VLAN_8021Q) && !defined(CONFIG_VLAN_8021Q_MODULE)
 	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
 	 * flag clear.
 	 */
-#if TG3_VLAN_TAG_USED
-	if (!tp->vlgrp &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
-		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
-#else
-	/* By definition, VLAN is disabled always in this
-	 * case.
-	 */
 	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
 		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
 #endif
@@ -11235,31 +11195,6 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-#if TG3_VLAN_TAG_USED
-static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct tg3 *tp = netdev_priv(dev);
-
-	if (!netif_running(dev)) {
-		tp->vlgrp = grp;
-		return;
-	}
-
-	tg3_netif_stop(tp);
-
-	tg3_full_lock(tp, 0);
-
-	tp->vlgrp = grp;
-
-	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
-	__tg3_set_rx_mode(dev);
-
-	tg3_netif_start(tp);
-
-	tg3_full_unlock(tp);
-}
-#endif
-
 static int tg3_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -13071,9 +13006,7 @@ static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
 
 static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
 {
-#if TG3_VLAN_TAG_USED
 	dev->vlan_features |= flags;
-#endif
 }
 
 static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
@@ -13835,11 +13768,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
-	tp->rx_offset = NET_IP_ALIGN + TG3_RX_HEADROOM;
+	tp->rx_offset = NET_IP_ALIGN;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
-		tp->rx_offset -= NET_IP_ALIGN;
+		tp->rx_offset = 0;
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		tp->rx_copy_thresh = ~(u16)0;
 #endif
@@ -14603,9 +14536,6 @@ static const struct net_device_ops tg3_netdev_ops = {
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
-#if TG3_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= tg3_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -14622,9 +14552,6 @@ static const struct net_device_ops tg3_netdev_ops_dma_bug = {
 	.ndo_do_ioctl		= tg3_ioctl,
 	.ndo_tx_timeout		= tg3_tx_timeout,
 	.ndo_change_mtu		= tg3_change_mtu,
-#if TG3_VLAN_TAG_USED
-	.ndo_vlan_rx_register	= tg3_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tg3_poll_controller,
 #endif
@@ -14674,9 +14601,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 
 	tp = netdev_priv(dev);
 	tp->pdev = pdev;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 52ae644..fc8ecdd 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2813,9 +2813,6 @@ struct tg3 {
 	u32				rx_std_max_post;
 	u32				rx_offset;
 	u32				rx_pkt_map_sz;
-#if TG3_VLAN_TAG_USED
-	struct vlan_group		*vlgrp;
-#endif
 
 
 	/* begin "everything else" cacheline(s) section */
-- 
1.7.2.2


