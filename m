From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 09/14] bnx2: Update bnx2 to use new vlan accleration.
Date: Wed, 20 Oct 2010 16:56:09 -0700
Message-ID: <1287618974-4714-10-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55512 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101Ab0JTX4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:34 -0400
Received: by mail-qw0-f46.google.com with SMTP id 26so2908363qwa.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:34 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the bnx2 driver use the new vlan accleration model.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   97 +++++++++++++++-------------------------------------
 drivers/net/bnx2.h |    4 --
 2 files changed, 28 insertions(+), 73 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 363ca8b..bf3c830 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -37,9 +37,6 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/if_vlan.h>
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define BCM_VLAN 1
-#endif
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
@@ -3087,8 +3084,6 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		struct sw_bd *rx_buf, *next_rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
-		u16 vtag = 0;
-		int hw_vlan __maybe_unused = 0;
 
 		sw_ring_cons = RX_RING_IDX(sw_cons);
 		sw_ring_prod = RX_RING_IDX(sw_prod);
@@ -3168,23 +3163,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			goto next_rx;
 
 		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
-		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) {
-			vtag = rx_hdr->l2_fhdr_vlan_tag;
-#ifdef BCM_VLAN
-			if (bp->vlgrp)
-				hw_vlan = 1;
-			else
-#endif
-			{
-				struct vlan_ethhdr *ve = (struct vlan_ethhdr *)
-					__skb_push(skb, 4);
-
-				memmove(ve, skb->data + 4, ETH_ALEN * 2);
-				ve->h_vlan_proto = htons(ETH_P_8021Q);
-				ve->h_vlan_TCI = htons(vtag);
-				len += 4;
-			}
-		}
+		    !(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG))
+			__vlan_hwaccel_put_tag(skb, rx_hdr->l2_fhdr_vlan_tag);
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
@@ -3211,14 +3191,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			skb->rxhash = rx_hdr->l2_fhdr_hash;
 
 		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
-
-#ifdef BCM_VLAN
-		if (hw_vlan)
-			vlan_gro_receive(&bnapi->napi, bp->vlgrp, vtag, skb);
-		else
-#endif
-			napi_gro_receive(&bnapi->napi, skb);
-
+		napi_gro_receive(&bnapi->napi, skb);
 		rx_pkt++;
 
 next_rx:
@@ -3533,13 +3506,9 @@ bnx2_set_rx_mode(struct net_device *dev)
 	rx_mode = bp->rx_mode & ~(BNX2_EMAC_RX_MODE_PROMISCUOUS |
 				  BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG);
 	sort_mode = 1 | BNX2_RPM_SORT_USER0_BC_EN;
-#ifdef BCM_VLAN
-	if (!bp->vlgrp && (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
+	if (!(dev->features & NETIF_F_HW_VLAN_RX) &&
+	     (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
-#else
-	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
-		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
-#endif
 	if (dev->flags & IFF_PROMISC) {
 		/* Promiscuous mode. */
 		rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
@@ -6365,29 +6334,6 @@ bnx2_tx_timeout(struct net_device *dev)
 	schedule_work(&bp->reset_task);
 }
 
-#ifdef BCM_VLAN
-/* Called with rtnl_lock */
-static void
-bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
-{
-	struct bnx2 *bp = netdev_priv(dev);
-
-	if (netif_running(dev))
-		bnx2_netif_stop(bp, false);
-
-	bp->vlgrp = vlgrp;
-
-	if (!netif_running(dev))
-		return;
-
-	bnx2_set_rx_mode(dev);
-	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
-		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
-
-	bnx2_netif_start(bp, false);
-}
-#endif
-
 /* Called with netif_tx_lock.
  * bnx2_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue().
@@ -6428,12 +6374,11 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag_flags |= TX_BD_FLAGS_TCP_UDP_CKSUM;
 	}
 
-#ifdef BCM_VLAN
 	if (vlan_tx_tag_present(skb)) {
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
-#endif
+
 	if ((mss = skb_shinfo(skb)->gso_size)) {
 		u32 tcp_opt_len;
 		struct iphdr *iph;
@@ -7578,7 +7523,28 @@ bnx2_set_tx_csum(struct net_device *dev, u32 data)
 static int
 bnx2_set_flags(struct net_device *dev, u32 data)
 {
-	return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
+	struct bnx2 *bp = netdev_priv(dev);
+	int rc;
+
+	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN) &&
+	    !(data & ETH_FLAG_RXVLAN))
+		return -EOPNOTSUPP;
+
+	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH | ETH_FLAG_RXVLAN |
+				  ETH_FLAG_TXVLAN);
+	if (rc)
+		return rc;
+
+	if ((!!(data & ETH_FLAG_RXVLAN) !=
+	    !!(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) &&
+	    netif_running(dev)) {
+		bnx2_netif_stop(bp, false);
+		bnx2_set_rx_mode(dev);
+		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
+		bnx2_netif_start(bp, false);
+	}
+
+	return 0;
 }
 
 static const struct ethtool_ops bnx2_ethtool_ops = {
@@ -8318,9 +8284,6 @@ static const struct net_device_ops bnx2_netdev_ops = {
 	.ndo_set_mac_address	= bnx2_change_mac_addr,
 	.ndo_change_mtu		= bnx2_change_mtu,
 	.ndo_tx_timeout		= bnx2_tx_timeout,
-#ifdef BCM_VLAN
-	.ndo_vlan_rx_register	= bnx2_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= poll_bnx2,
 #endif
@@ -8328,9 +8291,7 @@ static const struct net_device_ops bnx2_netdev_ops = {
 
 static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
 {
-#ifdef BCM_VLAN
 	dev->vlan_features |= flags;
-#endif
 }
 
 static int __devinit
@@ -8379,9 +8340,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->features |= NETIF_F_IPV6_CSUM;
 		vlan_features_add(dev, NETIF_F_IPV6_CSUM);
 	}
-#ifdef BCM_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
 	vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index efdfbc2..4f44db6 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6742,10 +6742,6 @@ struct bnx2 {
 
 	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
-#ifdef BCM_VLAN
-	struct			vlan_group *vlgrp;
-#endif
-
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_buf_size;		/* with alignment */
 	u32			rx_copy_thresh;
-- 
1.7.1

