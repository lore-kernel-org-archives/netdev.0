From: mathieu.poirier@linaro.org
Subject: [PATCH] net: allow shifted access in smsc911x V2
Date: Wed, 13 Apr 2011 12:50:21 -0600
Message-ID: <1302720621-7339-1-git-send-email-mathieu.poirier@linaro.org>
Cc: lee.jones@linaro.org, patches@linaro.org, rubini@gnudd.com,
	linus.walleij@linaro.org
To: netdev@vger.kernel.org, mathieu.poirier@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44017 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756655Ab1DMSud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:50:33 -0400
Received: by gxk21 with SMTP id 21so368763gxk.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 11:50:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu J. Poirier <mathieu.poirier@linaro.org>

This is a revised patch that permits a shifted access to the
LAN9221 registers.  More specifically:

 It adds a shift parameter in the platform_data.
 It introduces an ops in smsc911x_data.
 A choice of access function to use at run-time.
 Four new shifted access function.

Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
---
 drivers/net/smsc911x.c   |  156 +++++++++++++++++++++++++++++++++++++++++++--
 include/linux/smsc911x.h |    1 +
 2 files changed, 150 insertions(+), 7 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index d70bde9..2d65fa4 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -69,6 +69,17 @@ static int debug = 3;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+struct smsc911x_data;
+
+struct smsc911x_ops {
+	u32 (*reg_read)(struct smsc911x_data *pdata, u32 reg);
+	void (*reg_write)(struct smsc911x_data *pdata, u32 reg, u32 val);
+	void (*rx_readfifo)(struct smsc911x_data *pdata,
+				unsigned int *buf, unsigned int wordcount);
+	void (*tx_writefifo)(struct smsc911x_data *pdata,
+				unsigned int *buf, unsigned int wordcount);
+};
+
 struct smsc911x_data {
 	void __iomem *ioaddr;
 
@@ -116,8 +127,14 @@ struct smsc911x_data {
 	unsigned int clear_bits_mask;
 	unsigned int hashhi;
 	unsigned int hashlo;
+
+	/* register access functions */
+	const struct smsc911x_ops *ops;
 };
 
+/* Easy access to information */
+#define __smsc_shift(pdata, reg) ((reg) << ((pdata)->config.shift))
+
 static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT)
@@ -131,13 +148,29 @@ static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 	return 0;
 }
 
+static inline u32
+__smsc911x_reg_read_shift(struct smsc911x_data *pdata, u32 reg)
+{
+	if (pdata->config.flags & SMSC911X_USE_32BIT)
+		return readl(pdata->ioaddr + __smsc_shift(pdata, reg));
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT)
+		return (readw(pdata->ioaddr +
+				__smsc_shift(pdata, reg)) & 0xFFFF) |
+			((readw(pdata->ioaddr +
+			__smsc_shift(pdata, reg + 2)) & 0xFFFF) << 16);
+
+	BUG();
+	return 0;
+}
+
 static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
 	u32 data;
 	unsigned long flags;
 
 	spin_lock_irqsave(&pdata->dev_lock, flags);
-	data = __smsc911x_reg_read(pdata, reg);
+	data = pdata->ops->reg_read(pdata, reg);
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 
 	return data;
@@ -160,13 +193,32 @@ static inline void __smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
 	BUG();
 }
 
+static inline void
+__smsc911x_reg_write_shift(struct smsc911x_data *pdata, u32 reg, u32 val)
+{
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		writel(val, pdata->ioaddr + __smsc_shift(pdata, reg));
+		return;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		writew(val & 0xFFFF,
+			pdata->ioaddr + __smsc_shift(pdata, reg));
+		writew((val >> 16) & 0xFFFF,
+			pdata->ioaddr + __smsc_shift(pdata, reg + 2));
+		return;
+	}
+
+	BUG();
+}
+
 static inline void smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
 				      u32 val)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&pdata->dev_lock, flags);
-	__smsc911x_reg_write(pdata, reg, val);
+	pdata->ops->reg_write(pdata, reg, val);
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
@@ -202,6 +254,40 @@ out:
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
+/* Writes a packet to the TX_DATA_FIFO - shifted version */
+static inline void
+smsc911x_tx_writefifo_shift(struct smsc911x_data *pdata, unsigned int *buf,
+		      unsigned int wordcount)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+
+	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
+		while (wordcount--)
+			__smsc911x_reg_write_shift(pdata, TX_DATA_FIFO,
+					     swab32(*buf++));
+		goto out;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		writesl(pdata->ioaddr + __smsc_shift(pdata,
+						TX_DATA_FIFO), buf, wordcount);
+		goto out;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		while (wordcount--)
+			__smsc911x_reg_write_shift(pdata,
+						 TX_DATA_FIFO, *buf++);
+		goto out;
+	}
+
+	BUG();
+out:
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+}
+
 /* Reads a packet out of the RX_DATA_FIFO */
 static inline void
 smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
@@ -234,6 +320,40 @@ out:
 	spin_unlock_irqrestore(&pdata->dev_lock, flags);
 }
 
+/* Reads a packet out of the RX_DATA_FIFO - shifted version */
+static inline void
+smsc911x_rx_readfifo_shift(struct smsc911x_data *pdata, unsigned int *buf,
+		     unsigned int wordcount)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->dev_lock, flags);
+
+	if (pdata->config.flags & SMSC911X_SWAP_FIFO) {
+		while (wordcount--)
+			*buf++ = swab32(__smsc911x_reg_read_shift(pdata,
+							    RX_DATA_FIFO));
+		goto out;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_32BIT) {
+		readsl(pdata->ioaddr + __smsc_shift(pdata,
+						RX_DATA_FIFO), buf, wordcount);
+		goto out;
+	}
+
+	if (pdata->config.flags & SMSC911X_USE_16BIT) {
+		while (wordcount--)
+			*buf++ = __smsc911x_reg_read_shift(pdata,
+								RX_DATA_FIFO);
+		goto out;
+	}
+
+	BUG();
+out:
+	spin_unlock_irqrestore(&pdata->dev_lock, flags);
+}
+
 /* waits for MAC not busy, with timeout.  Only called by smsc911x_mac_read
  * and smsc911x_mac_write, so assumes mac_lock is held */
 static int smsc911x_mac_complete(struct smsc911x_data *pdata)
@@ -499,7 +619,7 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 		wrsz += (u32)((ulong)pdata->loopback_tx_pkt & 0x3);
 		wrsz >>= 2;
 
-		smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+		pdata->ops->tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
 
 		/* Wait till transmit is done */
 		i = 60;
@@ -543,7 +663,7 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 		rdsz += (u32)((ulong)pdata->loopback_rx_pkt & 0x3);
 		rdsz >>= 2;
 
-		smsc911x_rx_readfifo(pdata, (unsigned int *)bufp, rdsz);
+		pdata->ops->rx_readfifo(pdata, (unsigned int *)bufp, rdsz);
 
 		if (pktlength != (MIN_PACKET_SIZE + 4)) {
 			SMSC_WARNING(HW, "Unexpected packet size "
@@ -1046,8 +1166,8 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 		/* Align IP on 16B boundary */
 		skb_reserve(skb, NET_IP_ALIGN);
 		skb_put(skb, pktlength - 4);
-		smsc911x_rx_readfifo(pdata, (unsigned int *)skb->head,
-				     pktwords);
+		pdata->ops->rx_readfifo(pdata,
+				 (unsigned int *)skb->head, pktwords);
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_checksum_none_assert(skb);
 		netif_receive_skb(skb);
@@ -1350,7 +1470,7 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	wrsz += (u32)((ulong)skb->data & 0x3);
 	wrsz >>= 2;
 
-	smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+	pdata->ops->tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
 	freespace -= (skb->len + 32);
 	dev_kfree_skb(skb);
 
@@ -1951,6 +2071,22 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+/* standard register acces */
+static const struct smsc911x_ops standard_smsc911x_ops = {
+	.reg_read = __smsc911x_reg_read,
+	.reg_write = __smsc911x_reg_write,
+	.rx_readfifo = smsc911x_rx_readfifo,
+	.tx_writefifo = smsc911x_tx_writefifo,
+};
+
+/* shifted register access */
+static const struct smsc911x_ops shifted_smsc911x_ops = {
+	.reg_read = __smsc911x_reg_read_shift,
+	.reg_write = __smsc911x_reg_write_shift,
+	.rx_readfifo = smsc911x_rx_readfifo_shift,
+	.tx_writefifo = smsc911x_tx_writefifo_shift,
+};
+
 static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
@@ -2023,6 +2159,12 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev_2;
 	}
 
+	/* assume standard, non-shifted, access to HW registers */
+	pdata->ops = &standard_smsc911x_ops;
+	/* apply the right access if shifting is needed */
+	if (config->shift)
+		pdata->ops = &shifted_smsc911x_ops;
+
 	retval = smsc911x_init(dev);
 	if (retval < 0)
 		goto out_unmap_io_3;
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 7144e8a..4dde70e 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -29,6 +29,7 @@ struct smsc911x_platform_config {
 	unsigned int irq_polarity;
 	unsigned int irq_type;
 	unsigned int flags;
+	unsigned int shift;
 	phy_interface_t phy_interface;
 	unsigned char mac[6];
 };
-- 
1.7.1

