From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 1/8] net/wan/fsl_ucc_hdlc: cleanup debug traces
Date: Wed, 17 May 2017 17:24:32 +0200
Message-ID: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47186 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdEQPbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the tracing seems to be remaining traces for basic driver
development. They can be removed now, as they cause noisy printouts.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 33 ---------------------------------
 1 file changed, 33 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 6742ae605660..0ae10a58ffca 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -36,7 +36,6 @@
 #define DRV_NAME "ucc_hdlc"
 
 #define TDM_PPPOHT_SLIC_MAXIN
-#define BROKEN_FRAME_INFO
 
 static struct ucc_tdm_info utdm_primary_info = {
 	.uf_info = {
@@ -314,8 +313,6 @@ static netdev_tx_t ucc_hdlc_tx(struct sk_buff *skb, struct net_device *dev)
 	struct qe_bd __iomem *bd;
 	u16 bd_status;
 	unsigned long flags;
-	u8 *send_buf;
-	int i;
 	u16 *proto_head;
 
 	switch (dev->type) {
@@ -352,16 +349,6 @@ static netdev_tx_t ucc_hdlc_tx(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
-
-	pr_info("Tx data skb->len:%d ", skb->len);
-	send_buf = (u8 *)skb->data;
-	pr_info("\nTransmitted data:\n");
-	for (i = 0; i < 16; i++) {
-		if (i == skb->len)
-			pr_info("++++");
-		else
-		pr_info("%02x\n", send_buf[i]);
-	}
 	spin_lock_irqsave(&priv->lock, flags);
 
 	/* Start from the next BD that should be filled */
@@ -423,7 +410,6 @@ static int hdlc_tx_done(struct ucc_hdlc_private *priv)
 		skb = priv->tx_skbuff[priv->skb_dirtytx];
 		if (!skb)
 			break;
-		pr_info("TxBD: %x\n", bd_status);
 		dev->stats.tx_packets++;
 		memset(priv->tx_buffer +
 		       (be32_to_cpu(bd->buf) - priv->dma_tx_addr),
@@ -460,8 +446,6 @@ static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 	u16 bd_status;
 	u16 length, howmany = 0;
 	u8 *bdbuffer;
-	int i;
-	static int entry;
 
 	bd = priv->currx_bd;
 	bd_status = ioread16be(&bd->status);
@@ -471,9 +455,6 @@ static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 		if (bd_status & R_OV_S)
 			dev->stats.rx_over_errors++;
 		if (bd_status & R_CR_S) {
-#ifdef BROKEN_FRAME_INFO
-			pr_info("Broken Frame with RxBD: %x\n", bd_status);
-#endif
 			dev->stats.rx_crc_errors++;
 			dev->stats.rx_dropped++;
 			goto recycle;
@@ -482,17 +463,6 @@ static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 			(priv->currx_bdnum * MAX_RX_BUF_LENGTH);
 		length = ioread16be(&bd->length);
 
-		pr_info("Received data length:%d", length);
-		pr_info("while entry times:%d", entry++);
-
-		pr_info("\nReceived data:\n");
-		for (i = 0; (i < 16); i++) {
-			if (i == length)
-				pr_info("++++");
-			else
-			pr_info("%02x\n", bdbuffer[i]);
-		}
-
 		switch (dev->type) {
 		case ARPHRD_RAWHDLC:
 			bdbuffer += HDLC_HEAD_LEN;
@@ -531,7 +501,6 @@ static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 		howmany++;
 		if (hdlc->proto)
 			skb->protocol = hdlc_type_trans(skb, dev);
-		pr_info("skb->protocol:%x\n", skb->protocol);
 		netif_receive_skb(skb);
 
 recycle:
@@ -597,7 +566,6 @@ static irqreturn_t ucc_hdlc_irq_handler(int irq, void *dev_id)
 	uccm = ioread32be(uccf->p_uccm);
 	ucce &= uccm;
 	iowrite32be(ucce, uccf->p_ucce);
-	pr_info("irq ucce:%x\n", ucce);
 	if (!ucce)
 		return IRQ_NONE;
 
@@ -855,7 +823,6 @@ static int uhdlc_suspend(struct device *dev)
 	/* save power */
 	ucc_fast_disable(priv->uccf, COMM_DIR_RX | COMM_DIR_TX);
 
-	dev_dbg(dev, "ucc hdlc suspend\n");
 	return 0;
 }
 
-- 
2.12.0.rc1
