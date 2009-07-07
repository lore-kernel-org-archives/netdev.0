From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: Add support for skb recycling
Date: Tue, 7 Jul 2009 22:38:42 +0400
Message-ID: <20090707183842.GA8425@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:44013 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752125AbZGGSin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 14:38:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can reclaim transmitted skbs to use in the receive path, so-called
skb recycling support.

Also reorder ucc_geth_poll() steps, so that we'll clean tx ring firstly,
thus maybe reclaim some skbs for rx.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   40 ++++++++++++++++++++++++++++------------
 drivers/net/ucc_geth.h |    2 ++
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 40c6eba..beaa329 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -209,9 +209,10 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 {
 	struct sk_buff *skb = NULL;
 
-	skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
-				  UCC_GETH_RX_DATA_BUF_ALIGNMENT);
-
+	skb = __skb_dequeue(&ugeth->rx_recycle);
+	if (!skb)
+		skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
+				    UCC_GETH_RX_DATA_BUF_ALIGNMENT);
 	if (skb == NULL)
 		return NULL;
 
@@ -1986,6 +1987,8 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		iounmap(ugeth->ug_regs);
 		ugeth->ug_regs = NULL;
 	}
+
+	skb_queue_purge(&ugeth->rx_recycle);
 }
 
 static void ucc_geth_set_multi(struct net_device *dev)
@@ -2202,6 +2205,8 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 
+	skb_queue_head_init(&ugeth->rx_recycle);
+
 	return 0;
 }
 
@@ -3208,8 +3213,10 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 			if (netif_msg_rx_err(ugeth))
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
 					   __func__, __LINE__, (u32) skb);
-			if (skb)
-				dev_kfree_skb_any(skb);
+			if (skb) {
+				skb->data = skb->head + NET_SKB_PAD;
+				__skb_queue_head(&ugeth->rx_recycle, skb);
+			}
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
 			dev->stats.rx_dropped++;
@@ -3267,6 +3274,8 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 	/* Normal processing. */
 	while ((bd_status & T_R) == 0) {
+		struct sk_buff *skb;
+
 		/* BD contains already transmitted buffer.   */
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
@@ -3276,9 +3285,16 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		dev->stats.tx_packets++;
 
-		/* Free the sk buffer associated with this TxBD */
-		dev_kfree_skb(ugeth->
-				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
+		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
+
+		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
+			     skb_recycle_check(skb,
+				    ugeth->ug_info->uf_info.max_rx_buf_length +
+				    UCC_GETH_RX_DATA_BUF_ALIGNMENT))
+			__skb_queue_head(&ugeth->rx_recycle, skb);
+		else
+			dev_kfree_skb(skb);
+
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
 		    (ugeth->skb_dirtytx[txQ] +
@@ -3307,16 +3323,16 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 
 	ug_info = ugeth->ug_info;
 
-	howmany = 0;
-	for (i = 0; i < ug_info->numQueuesRx; i++)
-		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
-
 	/* Tx event processing */
 	spin_lock(&ugeth->lock);
 	for (i = 0; i < ug_info->numQueuesTx; i++)
 		ucc_geth_tx(ugeth->ndev, i);
 	spin_unlock(&ugeth->lock);
 
+	howmany = 0;
+	for (i = 0; i < ug_info->numQueuesRx; i++)
+		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
+
 	if (howmany < budget) {
 		napi_complete(napi);
 		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS | UCCE_TX_EVENTS);
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 195ab26..cfb31af 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1212,6 +1212,8 @@ struct ucc_geth_private {
 	/* index of the first skb which hasn't been transmitted yet. */
 	u16 skb_dirtytx[NUM_TX_QUEUES];
 
+	struct sk_buff_head rx_recycle;
+
 	struct ugeth_mii_info *mii_info;
 	struct phy_device *phydev;
 	phy_interface_t phy_interface;
-- 
1.6.3.3
