From: John Linn <john.linn@xilinx.com>
Subject: [PATCH 2/2] net: ll_temac: fix checksum offload logic
Date: Wed, 26 May 2010 11:29:19 -0600
Message-ID: <0690e798-1e5e-4416-90dc-04a9df16600f@SG2EHSMHS005.ehs.local>
References: <1274894959-27473-1-git-send-email-john.linn@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john.williams@petalogix.com, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>,
	Brian Hill <brian.hill@xilinx.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe001.messaging.microsoft.com ([207.46.51.75]:48724 "EHLO
	SG2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755152Ab0EZRoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 13:44:46 -0400
In-Reply-To: <1274894959-27473-1-git-send-email-john.linn@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current checksum offload code does not work and this corrects
that functionality. It also updates the interrupt coallescing
initialization so than there are fewer interrupts and performance
is increased.

Signed-off-by: Brian Hill <brian.hill@xilinx.com>
Signed-off-by: John Linn <john.linn@xilinx.com>
---
 drivers/net/ll_temac.h      |    5 +++
 drivers/net/ll_temac_main.c |   82 ++++++++++++++++++++++++++++++------------
 2 files changed, 63 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
index c033584..2e0c9cc 100644
--- a/drivers/net/ll_temac.h
+++ b/drivers/net/ll_temac.h
@@ -295,6 +295,10 @@ This option defaults to enabled (set) */
 
 #define MULTICAST_CAM_TABLE_NUM 4
 
+/* TEMAC Synthesis features */
+#define TEMAC_FEATURE_RX_CSUM  (1 << 0)
+#define TEMAC_FEATURE_TX_CSUM  (1 << 1)
+
 /* TX/RX CURDESC_PTR points to first descriptor */
 /* TX/RX TAILDESC_PTR points to last descriptor in linked list */
 
@@ -353,6 +357,7 @@ struct temac_local {
 	struct mutex indirect_mutex;
 	u32 options;			/* Current options word */
 	int last_link;
+	unsigned temac_features;
 
 	/* Buffer descriptors */
 	struct cdmac_bd *tx_bd_v;
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 0615737..52dcc84 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -245,7 +245,7 @@ static int temac_dma_bd_init(struct net_device *ndev)
 					  CHNL_CTRL_IRQ_COAL_EN);
 	/* 0x10220483 */
 	/* 0x00100483 */
-	lp->dma_out(lp, RX_CHNL_CTRL, 0xff010000 |
+	lp->dma_out(lp, RX_CHNL_CTRL, 0xff070000 |
 					  CHNL_CTRL_IRQ_EN |
 					  CHNL_CTRL_IRQ_DLY_EN |
 					  CHNL_CTRL_IRQ_COAL_EN |
@@ -574,6 +574,10 @@ static void temac_start_xmit_done(struct net_device *ndev)
 		if (cur_p->app4)
 			dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
 		cur_p->app0 = 0;
+		cur_p->app1 = 0;
+		cur_p->app2 = 0;
+		cur_p->app3 = 0;
+		cur_p->app4 = 0;
 
 		ndev->stats.tx_packets++;
 		ndev->stats.tx_bytes += cur_p->len;
@@ -589,6 +593,29 @@ static void temac_start_xmit_done(struct net_device *ndev)
 	netif_wake_queue(ndev);
 }
 
+static inline int temac_check_tx_bd_space(struct temac_local *lp, int num_frag)
+{
+	struct cdmac_bd *cur_p;
+	int tail;
+
+	tail = lp->tx_bd_tail;
+	cur_p = &lp->tx_bd_v[tail];
+
+	do {
+		if (cur_p->app0)
+			return NETDEV_TX_BUSY;
+
+		tail++;
+		if (tail >= TX_BD_NUM)
+			tail = 0;
+
+		cur_p = &lp->tx_bd_v[tail];
+		num_frag--;
+	} while (num_frag >= 0);
+
+	return 0;
+}
+
 static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct temac_local *lp = netdev_priv(ndev);
@@ -603,7 +630,7 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	start_p = lp->tx_bd_p + sizeof(*lp->tx_bd_v) * lp->tx_bd_tail;
 	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 
-	if (cur_p->app0 & STS_CTRL_APP0_CMPLT) {
+	if (temac_check_tx_bd_space(lp, num_frag)) {
 		if (!netif_queue_stopped(ndev)) {
 			netif_stop_queue(ndev);
 			return NETDEV_TX_BUSY;
@@ -613,29 +640,14 @@ static int temac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	cur_p->app0 = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		const struct iphdr *ip = ip_hdr(skb);
-		int length = 0, start = 0, insert = 0;
-
-		switch (ip->protocol) {
-		case IPPROTO_TCP:
-			start = sizeof(struct iphdr) + ETH_HLEN;
-			insert = sizeof(struct iphdr) + ETH_HLEN + 16;
-			length = ip->tot_len - sizeof(struct iphdr);
-			break;
-		case IPPROTO_UDP:
-			start = sizeof(struct iphdr) + ETH_HLEN;
-			insert = sizeof(struct iphdr) + ETH_HLEN + 6;
-			length = ip->tot_len - sizeof(struct iphdr);
-			break;
-		default:
-			break;
-		}
-		cur_p->app1 = ((start << 16) | insert);
-		cur_p->app2 = csum_tcpudp_magic(ip->saddr, ip->daddr,
-						length, ip->protocol, 0);
-		skb->data[insert] = 0;
-		skb->data[insert + 1] = 0;
+		unsigned int csum_start_off = skb_transport_offset(skb);
+		unsigned int csum_index_off = csum_start_off + skb->csum_offset;
+
+		cur_p->app0 |= 1; /* TX Checksum Enabled */
+		cur_p->app1 = (csum_start_off << 16) | csum_index_off;
+		cur_p->app2 = 0;  /* initial checksum seed */
 	}
+
 	cur_p->app0 |= STS_CTRL_APP0_SOP;
 	cur_p->len = skb_headlen(skb);
 	cur_p->phys = dma_map_single(ndev->dev.parent, skb->data, skb->len,
@@ -699,6 +711,15 @@ static void ll_temac_recv(struct net_device *ndev)
 		skb->protocol = eth_type_trans(skb, ndev);
 		skb->ip_summed = CHECKSUM_NONE;
 
+		/* if we're doing rx csum offload, set it up */
+		if (((lp->temac_features & TEMAC_FEATURE_RX_CSUM) != 0) &&
+			(skb->protocol == __constant_htons(ETH_P_IP)) &&
+			(skb->len > 64)) {
+
+			skb->csum = cur_p->app3 & 0xFFFF;
+			skb->ip_summed = CHECKSUM_COMPLETE;
+		}
+
 		netif_rx(skb);
 
 		ndev->stats.rx_packets++;
@@ -883,6 +904,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	struct temac_local *lp;
 	struct net_device *ndev;
 	const void *addr;
+	__be32 *p;
 	int size, rc = 0;
 
 	/* Init network device structure */
@@ -926,6 +948,18 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 		goto nodev;
 	}
 
+	/* Setup checksum offload, but default to off if not specified */
+	lp->temac_features = 0;
+	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
+	if (p && be32_to_cpu(*p)) {
+		lp->temac_features |= TEMAC_FEATURE_TX_CSUM;
+		/* Can checksum TCP/UDP over IPv4. */
+		ndev->features |= NETIF_F_IP_CSUM;
+	}
+	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
+	if (p && be32_to_cpu(*p))
+		lp->temac_features |= TEMAC_FEATURE_RX_CSUM;
+
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(op->dev.of_node, "llink-connected", 0);
 	if (!np) {
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


