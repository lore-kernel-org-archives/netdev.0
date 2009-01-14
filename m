From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 09/34]bnx2x: VLAN tagged packets without VLAN offload
Date: Wed, 14 Jan 2009 18:43:09 +0200
Message-ID: <1231951389.11301.130.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2653 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763092AbZANQn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong handling of tagged packet if VLAN offload is disabled caused packets to
get corrupted

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   12 +++++++-----
 drivers/net/bnx2x_main.c |   42 +++++++++++++++++++++++++++++++++---------
 2 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index b9bc285..a6c9d23 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -20,6 +20,11 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define BCM_VLAN			1
+#endif
+
+
 /* error/debug prints */
 
 #define DRV_MODULE_NAME		"bnx2x"
@@ -78,11 +83,6 @@
 #endif
 
 
-#ifdef NETIF_F_HW_VLAN_TX
-#define BCM_VLAN			1
-#endif
-
-
 #define U64_LO(x)			(u32)(((u64)(x)) & 0xffffffff)
 #define U64_HI(x)			(u32)(((u64)(x)) >> 32)
 #define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
@@ -800,6 +800,8 @@ struct bnx2x {
 #define TPA_ENABLE_FLAG			0x80
 #define NO_MCP_FLAG			0x100
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
+#define HW_VLAN_TX_FLAG			0x400
+#define HW_VLAN_RX_FLAG			0x800
 
 	int			func;
 #define BP_PORT(bp)			(bp->func % PORT_MAX)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4735f57..4993707 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -38,9 +38,7 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#ifdef NETIF_F_HW_VLAN_TX
-	#include <linux/if_vlan.h>
-#endif
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
@@ -1299,6 +1297,13 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	if (likely(new_skb)) {
 		/* fix ip xsum and give it to the stack */
 		/* (no need to map the new skb) */
+#ifdef BCM_VLAN
+		int is_vlan_cqe =
+			(le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+			 PARSING_FLAGS_VLAN);
+		int is_not_hwaccel_vlan_cqe =
+			(is_vlan_cqe && (!(bp->flags & HW_VLAN_RX_FLAG)));
+#endif
 
 		prefetch(skb);
 		prefetch(((char *)(skb)) + 128);
@@ -1323,6 +1328,12 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			struct iphdr *iph;
 
 			iph = (struct iphdr *)skb->data;
+#ifdef BCM_VLAN
+			/* If there is no Rx VLAN offloading -
+			   take VLAN tag into an account */
+			if (unlikely(is_not_hwaccel_vlan_cqe))
+				iph = (struct iphdr *)((u8 *)iph + VLAN_HLEN);
+#endif
 			iph->check = 0;
 			iph->check = ip_fast_csum((u8 *)iph, iph->ihl);
 		}
@@ -1330,9 +1341,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		if (!bnx2x_fill_frag_skb(bp, fp, skb,
 					 &cqe->fast_path_cqe, cqe_idx)) {
 #ifdef BCM_VLAN
-			if ((bp->vlgrp != NULL) &&
-			    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
-			     PARSING_FLAGS_VLAN))
+			if ((bp->vlgrp != NULL) && is_vlan_cqe &&
+			    (!is_not_hwaccel_vlan_cqe))
 				vlan_hwaccel_receive_skb(skb, bp->vlgrp,
 						le16_to_cpu(cqe->fast_path_cqe.
 							    vlan_tag));
@@ -1576,7 +1586,7 @@ reuse_rx:
 		}
 
 #ifdef BCM_VLAN
-		if ((bp->vlgrp != NULL) &&
+		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
 		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
 		     PARSING_FLAGS_VLAN))
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
@@ -4554,7 +4564,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	tstorm_client.config_flags =
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
 #ifdef BCM_VLAN
-	if (bp->rx_mode && bp->vlgrp) {
+	if (bp->rx_mode && bp->vlgrp && (bp->flags & HW_VLAN_RX_FLAG)) {
 		tstorm_client.config_flags |=
 				TSTORM_ETH_CLIENT_CONFIG_VLAN_REMOVAL_ENABLE;
 		DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
@@ -9587,11 +9597,14 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
 	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_bd);
 
-	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb)) {
+#ifdef BCM_VLAN
+	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
+	    (bp->flags & HW_VLAN_TX_FLAG)) {
 		tx_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 		tx_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
 		vlan_off += 4;
 	} else
+#endif
 		tx_bd->vlan = cpu_to_le16(pkt_prod);
 
 	if (xmit_type) {
@@ -10037,6 +10050,16 @@ static void bnx2x_vlan_rx_register(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	bp->vlgrp = vlgrp;
+
+	/* Set flags according to the required capabilities */
+	bp->flags &= ~(HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
+
+	if (dev->features & NETIF_F_HW_VLAN_TX)
+		bp->flags |= HW_VLAN_TX_FLAG;
+
+	if (dev->features & NETIF_F_HW_VLAN_RX)
+		bp->flags |= HW_VLAN_RX_FLAG;
+
 	if (netif_running(dev))
 		bnx2x_set_client_config(bp);
 }
@@ -10193,6 +10216,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		dev->features |= NETIF_F_HIGHDMA;
 #ifdef BCM_VLAN
 	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+	bp->flags |= (HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
 #endif
 	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->features |= NETIF_F_TSO6;
-- 
1.5.4.3




