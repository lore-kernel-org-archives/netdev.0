From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC 5/5] net/ucc_geth: use generic recycling infrastructure
Date: Wed,  5 May 2010 16:47:50 +0200
Message-ID: <1273070870-7821-6-git-send-email-sebastian@breakpoint.cc>
References: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51300 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933811Ab0EEOsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 10:48:00 -0400
In-Reply-To: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ucc_geth.c |   24 +++++++-----------------
 drivers/net/ucc_geth.h |    2 --
 2 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 081f76b..d5af4f1 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -210,10 +210,7 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 {
 	struct sk_buff *skb = NULL;
 
-	skb = __skb_dequeue(&ugeth->rx_recycle);
-	if (!skb)
-		skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT);
+	skb = net_recycle_get(ugeth->ndev);
 	if (skb == NULL)
 		return NULL;
 
@@ -1992,8 +1989,6 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		iounmap(ugeth->ug_regs);
 		ugeth->ug_regs = NULL;
 	}
-
-	skb_queue_purge(&ugeth->rx_recycle);
 }
 
 static void ucc_geth_set_multi(struct net_device *dev)
@@ -2069,6 +2064,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	ugeth->phydev = NULL;
 
 	ucc_geth_memclean(ugeth);
+	net_recycle_cleanup(ugeth->ndev);
 }
 
 static int ucc_struct_init(struct ucc_geth_private *ugeth)
@@ -2205,9 +2201,6 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 			ugeth_err("%s: Failed to ioremap regs.", __func__);
 		return -ENOMEM;
 	}
-
-	skb_queue_head_init(&ugeth->rx_recycle);
-
 	return 0;
 }
 
@@ -3217,7 +3210,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 					   __func__, __LINE__, (u32) skb);
 			if (skb) {
 				skb->data = skb->head + NET_SKB_PAD;
-				__skb_queue_head(&ugeth->rx_recycle, skb);
+				net_recycle_add(dev, skb);
 			}
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
@@ -3288,13 +3281,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		dev->stats.tx_packets++;
 
-		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
-			     skb_recycle_check(skb,
-				    ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT))
-			__skb_queue_head(&ugeth->rx_recycle, skb);
-		else
-			dev_kfree_skb(skb);
+		net_recycle_add(dev, skb);
 
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
@@ -3915,6 +3902,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, 64);
 	dev->mtu = 1500;
 
+	net_recycle_init(dev, RX_BD_RING_LEN, ug_info->uf_info.max_rx_buf_length
+			+ UCC_GETH_RX_DATA_BUF_ALIGNMENT);
+
 	ugeth->msg_enable = netif_msg_init(debug.msg_enable, UGETH_MSG_DEFAULT);
 	ugeth->phy_interface = phy_interface;
 	ugeth->max_speed = max_speed;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index ef1fbeb..55708c5 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1213,8 +1213,6 @@ struct ucc_geth_private {
 	/* index of the first skb which hasn't been transmitted yet. */
 	u16 skb_dirtytx[NUM_TX_QUEUES];
 
-	struct sk_buff_head rx_recycle;
-
 	struct ugeth_mii_info *mii_info;
 	struct phy_device *phydev;
 	phy_interface_t phy_interface;
-- 
1.6.6.1

