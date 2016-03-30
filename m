From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 1/4] net: w5100: move mmiowb into register access callbacks
Date: Thu, 31 Mar 2016 01:38:37 +0900
Message-ID: <1459355920-14623-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36377 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047AbcC3Qjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 12:39:47 -0400
Received: by mail-pa0-f65.google.com with SMTP id 1so7177778pal.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 09:39:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of sprinkle mmiowb over the driver code, move it into primary
register write callbacks. (w5100_write, w5100_write16, w5100_writebuf)

This is a preparation for supporting SPI interface which doesn't use
MMIO for accessing w5100 registers.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/wiznet/w5100.c | 44 +++++++++++++------------------------
 1 file changed, 15 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 8b282d0..f4b7200 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -122,10 +122,17 @@ static inline u8 w5100_read_direct(struct w5100_priv *priv, u16 addr)
 	return ioread8(priv->base + (addr << CONFIG_WIZNET_BUS_SHIFT));
 }
 
+static inline void __w5100_write_direct(struct w5100_priv *priv, u16 addr,
+					u8 data)
+{
+	iowrite8(data, priv->base + (addr << CONFIG_WIZNET_BUS_SHIFT));
+}
+
 static inline void w5100_write_direct(struct w5100_priv *priv,
 				      u16 addr, u8 data)
 {
-	iowrite8(data, priv->base + (addr << CONFIG_WIZNET_BUS_SHIFT));
+	__w5100_write_direct(priv, addr, data);
+	mmiowb();
 }
 
 static u16 w5100_read16_direct(struct w5100_priv *priv, u16 addr)
@@ -138,8 +145,9 @@ static u16 w5100_read16_direct(struct w5100_priv *priv, u16 addr)
 
 static void w5100_write16_direct(struct w5100_priv *priv, u16 addr, u16 data)
 {
-	w5100_write_direct(priv, addr, data >> 8);
-	w5100_write_direct(priv, addr + 1, data);
+	__w5100_write_direct(priv, addr, data >> 8);
+	__w5100_write_direct(priv, addr + 1, data);
+	mmiowb();
 }
 
 static void w5100_readbuf_direct(struct w5100_priv *priv,
@@ -164,8 +172,9 @@ static void w5100_writebuf_direct(struct w5100_priv *priv,
 	for (i = 0; i < len; i++, addr++) {
 		if (unlikely(addr > W5100_TX_MEM_END))
 			addr = W5100_TX_MEM_START;
-		w5100_write_direct(priv, addr, *buf++);
+		__w5100_write_direct(priv, addr, *buf++);
 	}
+	mmiowb();
 }
 
 /*
@@ -186,7 +195,6 @@ static u8 w5100_read_indirect(struct w5100_priv *priv, u16 addr)
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
 	data = w5100_read_direct(priv, W5100_IDM_DR);
 	spin_unlock_irqrestore(&priv->reg_lock, flags);
 
@@ -199,9 +207,7 @@ static void w5100_write_indirect(struct w5100_priv *priv, u16 addr, u8 data)
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
 	w5100_write_direct(priv, W5100_IDM_DR, data);
-	mmiowb();
 	spin_unlock_irqrestore(&priv->reg_lock, flags);
 }
 
@@ -212,7 +218,6 @@ static u16 w5100_read16_indirect(struct w5100_priv *priv, u16 addr)
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
 	data  = w5100_read_direct(priv, W5100_IDM_DR) << 8;
 	data |= w5100_read_direct(priv, W5100_IDM_DR);
 	spin_unlock_irqrestore(&priv->reg_lock, flags);
@@ -226,10 +231,8 @@ static void w5100_write16_indirect(struct w5100_priv *priv, u16 addr, u16 data)
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
-	w5100_write_direct(priv, W5100_IDM_DR, data >> 8);
+	__w5100_write_direct(priv, W5100_IDM_DR, data >> 8);
 	w5100_write_direct(priv, W5100_IDM_DR, data);
-	mmiowb();
 	spin_unlock_irqrestore(&priv->reg_lock, flags);
 }
 
@@ -242,13 +245,11 @@ static void w5100_readbuf_indirect(struct w5100_priv *priv,
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
 
 	for (i = 0; i < len; i++, addr++) {
 		if (unlikely(addr > W5100_RX_MEM_END)) {
 			addr = W5100_RX_MEM_START;
 			w5100_write16_direct(priv, W5100_IDM_AR, addr);
-			mmiowb();
 		}
 		*buf++ = w5100_read_direct(priv, W5100_IDM_DR);
 	}
@@ -265,15 +266,13 @@ static void w5100_writebuf_indirect(struct w5100_priv *priv,
 
 	spin_lock_irqsave(&priv->reg_lock, flags);
 	w5100_write16_direct(priv, W5100_IDM_AR, addr);
-	mmiowb();
 
 	for (i = 0; i < len; i++, addr++) {
 		if (unlikely(addr > W5100_TX_MEM_END)) {
 			addr = W5100_TX_MEM_START;
 			w5100_write16_direct(priv, W5100_IDM_AR, addr);
-			mmiowb();
 		}
-		w5100_write_direct(priv, W5100_IDM_DR, *buf++);
+		__w5100_write_direct(priv, W5100_IDM_DR, *buf++);
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->reg_lock, flags);
@@ -309,7 +308,6 @@ static int w5100_command(struct w5100_priv *priv, u16 cmd)
 	unsigned long timeout = jiffies + msecs_to_jiffies(100);
 
 	w5100_write(priv, W5100_S0_CR, cmd);
-	mmiowb();
 
 	while (w5100_read(priv, W5100_S0_CR) != 0) {
 		if (time_after(jiffies, timeout))
@@ -327,18 +325,15 @@ static void w5100_write_macaddr(struct w5100_priv *priv)
 
 	for (i = 0; i < ETH_ALEN; i++)
 		w5100_write(priv, W5100_SHAR + i, ndev->dev_addr[i]);
-	mmiowb();
 }
 
 static void w5100_hw_reset(struct w5100_priv *priv)
 {
 	w5100_write_direct(priv, W5100_MR, MR_RST);
-	mmiowb();
 	mdelay(5);
 	w5100_write_direct(priv, W5100_MR, priv->indirect ?
 				  MR_PB | MR_AI | MR_IND :
 				  MR_PB);
-	mmiowb();
 	w5100_write(priv, W5100_IMR, 0);
 	w5100_write_macaddr(priv);
 
@@ -347,23 +342,19 @@ static void w5100_hw_reset(struct w5100_priv *priv)
 	 */
 	w5100_write(priv, W5100_RMSR, 0x03);
 	w5100_write(priv, W5100_TMSR, 0x03);
-	mmiowb();
 }
 
 static void w5100_hw_start(struct w5100_priv *priv)
 {
 	w5100_write(priv, W5100_S0_MR, priv->promisc ?
 			  S0_MR_MACRAW : S0_MR_MACRAW_MF);
-	mmiowb();
 	w5100_command(priv, S0_CR_OPEN);
 	w5100_write(priv, W5100_IMR, IR_S0);
-	mmiowb();
 }
 
 static void w5100_hw_close(struct w5100_priv *priv)
 {
 	w5100_write(priv, W5100_IMR, 0);
-	mmiowb();
 	w5100_command(priv, S0_CR_CLOSE);
 }
 
@@ -447,7 +438,6 @@ static int w5100_start_tx(struct sk_buff *skb, struct net_device *ndev)
 	offset = w5100_read16(priv, W5100_S0_TX_WR);
 	w5100_writebuf(priv, offset, skb->data, skb->len);
 	w5100_write16(priv, W5100_S0_TX_WR, offset + skb->len);
-	mmiowb();
 	ndev->stats.tx_bytes += skb->len;
 	ndev->stats.tx_packets++;
 	dev_kfree_skb(skb);
@@ -488,7 +478,6 @@ static int w5100_napi_poll(struct napi_struct *napi, int budget)
 		skb_put(skb, rx_len);
 		w5100_readbuf(priv, offset + 2, skb->data, rx_len);
 		w5100_write16(priv, W5100_S0_RX_RD, offset + 2 + rx_len);
-		mmiowb();
 		w5100_command(priv, S0_CR_RECV);
 		skb->protocol = eth_type_trans(skb, ndev);
 
@@ -500,7 +489,6 @@ static int w5100_napi_poll(struct napi_struct *napi, int budget)
 	if (rx_count < budget) {
 		napi_complete(napi);
 		w5100_write(priv, W5100_IMR, IR_S0);
-		mmiowb();
 	}
 
 	return rx_count;
@@ -515,7 +503,6 @@ static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
 	if (!ir)
 		return IRQ_NONE;
 	w5100_write(priv, W5100_S0_IR, ir);
-	mmiowb();
 
 	if (ir & S0_IR_SENDOK) {
 		netif_dbg(priv, tx_done, ndev, "tx done\n");
@@ -525,7 +512,6 @@ static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
 	if (ir & S0_IR_RECV) {
 		if (napi_schedule_prep(&priv->napi)) {
 			w5100_write(priv, W5100_IMR, 0);
-			mmiowb();
 			__napi_schedule(&priv->napi);
 		}
 	}
-- 
2.5.0
