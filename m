From: Brice Goglin <brice@myri.com>
Subject: [PATCH 4/5] myri10ge: add IPv6 TSO support
Date: Sat, 13 Oct 2007 12:34:01 +0200
Message-ID: <47109F19.4040102@myri.com>
References: <47109E8A.8080205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1820 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753599AbXJMKgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 06:36:05 -0400
In-Reply-To: <47109E8A.8080205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for IPv6 TSO to the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   87 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 79 insertions(+), 8 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-10-13 11:59:18.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-10-13 12:03:46.000000000 +0200
@@ -214,6 +214,8 @@
 	unsigned long serial_number;
 	int vendor_specific_offset;
 	int fw_multicast_support;
+	unsigned long features;
+	u32 max_tso6;
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;
@@ -311,6 +313,7 @@
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
 static void myri10ge_set_multicast_list(struct net_device *dev);
+static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev);
 
 static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
@@ -612,6 +615,7 @@
 	__be32 buf[16];
 	u32 dma_low, dma_high, size;
 	int status, i;
+	struct myri10ge_cmd cmd;
 
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
@@ -688,6 +692,14 @@
 	dev_info(&mgp->pdev->dev, "handoff confirmed\n");
 	myri10ge_dummy_rdma(mgp, 1);
 
+	/* probe for IPv6 TSO support */
+	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+				   &cmd, 0);
+	if (status == 0) {
+		mgp->max_tso6 = cmd.data0;
+		mgp->features |= NETIF_F_TSO6;
+	}
 	return 0;
 }
 
@@ -1384,6 +1396,18 @@
 	return 0;
 }
 
+static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	unsigned long flags = mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
+
+	if (tso_enabled)
+		netdev->features |= flags;
+	else
+		netdev->features &= ~flags;
+	return 0;
+}
+
 static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -1508,7 +1532,7 @@
 	.set_rx_csum = myri10ge_set_rx_csum,
 	.set_tx_csum = ethtool_op_set_tx_hw_csum,
 	.set_sg = ethtool_op_set_sg,
-	.set_tso = ethtool_op_set_tso,
+	.set_tso = myri10ge_set_tso,
 	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
 	.get_sset_count = myri10ge_get_sset_count,
@@ -2166,7 +2190,8 @@
 		pseudo_hdr_offset = cksum_offset + skb->csum_offset;
 		/* If the headers are excessively large, then we must
 		 * fall back to a software checksum */
-		if (unlikely(cksum_offset > 255 || pseudo_hdr_offset > 127)) {
+		if (unlikely(!mss && (cksum_offset > 255 ||
+				      pseudo_hdr_offset > 127))) {
 			if (skb_checksum_help(skb))
 				goto drop;
 			cksum_offset = 0;
@@ -2186,9 +2211,18 @@
 		/* negative cum_len signifies to the
 		 * send loop that we are still in the
 		 * header portion of the TSO packet.
-		 * TSO header must be at most 134 bytes long */
+		 * TSO header can be at most 1KB long */
 		cum_len = -(skb_transport_offset(skb) + tcp_hdrlen(skb));
 
+		/* for IPv6 TSO, the checksum offset stores the
+		 * TCP header length, to save the firmware from
+		 * the need to parse the headers */
+		if (skb_is_gso_v6(skb)) {
+			cksum_offset = tcp_hdrlen(skb);
+			/* Can only handle headers <= max_tso6 long */
+			if (unlikely(-cum_len > mgp->max_tso6))
+				return myri10ge_sw_tso(skb, dev);
+		}
 		/* for TSO, pseudo_hdr_offset holds mss.
 		 * The firmware figures out where to put
 		 * the checksum by parsing the header. */
@@ -2303,10 +2337,12 @@
 			req++;
 			count++;
 			rdma_count++;
-			if (unlikely(cksum_offset > seglen))
-				cksum_offset -= seglen;
-			else
-				cksum_offset = 0;
+			if (cksum_offset != 0 && !(mss && skb_is_gso_v6(skb))) {
+				if (unlikely(cksum_offset > seglen))
+					cksum_offset -= seglen;
+				else
+					cksum_offset = 0;
+			}
 		}
 		if (frag_idx == frag_cnt)
 			break;
@@ -2389,6 +2425,41 @@
 
 }
 
+static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *segs, *curr;
+	struct myri10ge_priv *mgp = dev->priv;
+	int status;
+
+	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO6);
+	if (unlikely(IS_ERR(segs)))
+		goto drop;
+
+	while (segs) {
+		curr = segs;
+		segs = segs->next;
+		curr->next = NULL;
+		status = myri10ge_xmit(curr, dev);
+		if (status != 0) {
+			dev_kfree_skb_any(curr);
+			if (segs != NULL) {
+				curr = segs;
+				segs = segs->next;
+				curr->next = NULL;
+				dev_kfree_skb_any(segs);
+			}
+			goto drop;
+		}
+	}
+	dev_kfree_skb_any(skb);
+	return 0;
+
+drop:
+	dev_kfree_skb_any(skb);
+	mgp->stats.tx_dropped += 1;
+	return 0;
+}
+
 static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
@@ -3076,7 +3147,7 @@
 	netdev->change_mtu = myri10ge_change_mtu;
 	netdev->set_multicast_list = myri10ge_set_multicast_list;
 	netdev->set_mac_address = myri10ge_set_mac_address;
-	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	netdev->features = mgp->features;
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
 


