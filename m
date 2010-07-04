From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH] ks8842: Replace usage of dev_dbg with netdev_dbg
Date: Mon, 05 Jul 2010 01:26:39 +0200
Message-ID: <1278285999.2594.4.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:47805 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab0GDXvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 19:51:35 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id 4F1CBCDF9
	for <netdev@vger.kernel.org>; Mon,  5 Jul 2010 01:26:40 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces all usage of dev_dbg with netdev_dbg.

A side effect is that the pointer to the platform device in the adapter
struct can be removed.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index f852ab3..d47bba9 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -119,7 +119,6 @@ struct ks8842_adapter {
 	int		irq;
 	struct tasklet_struct	tasklet;
 	spinlock_t	lock; /* spinlock to be interrupt safe */
-	struct platform_device *pdev;
 };
=20
 static inline void ks8842_select_bank(struct ks8842_adapter *adapter, =
u16 bank)
@@ -331,8 +330,7 @@ static int ks8842_tx_frame(struct sk_buff *skb, str=
uct net_device *netdev)
 	u32 *ptr =3D (u32 *)skb->data;
 	u32 ctrl;
=20
-	dev_dbg(&adapter->pdev->dev,
-		"%s: len %u head %p data %p tail %p end %p\n",
+	netdev_dbg(netdev, "%s: len %u head %p data %p tail %p end %p\n",
 		__func__, skb->len, skb->head, skb->data,
 		skb_tail_pointer(skb), skb_end_pointer(skb));
=20
@@ -369,15 +367,13 @@ static void ks8842_rx_frame(struct net_device *ne=
tdev,
=20
 	status &=3D 0xffff;
=20
-	dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
-		__func__, status);
+	netdev_dbg(netdev, "%s - rx_data: status: %x\n", __func__, status);
=20
 	/* check the status */
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
 		struct sk_buff *skb =3D netdev_alloc_skb_ip_align(netdev, len);
=20
-		dev_dbg(&adapter->pdev->dev, "%s, got package, len: %d\n",
-			__func__, len);
+		netdev_dbg(netdev, "%s, got package, len: %d\n", __func__, len);
 		if (skb) {
 			u32 *data;
=20
@@ -400,7 +396,7 @@ static void ks8842_rx_frame(struct net_device *netd=
ev,
 		} else
 			netdev->stats.rx_dropped++;
 	} else {
-		dev_dbg(&adapter->pdev->dev, "RX error, status: %x\n", status);
+		netdev_dbg(netdev, "RX error, status: %x\n", status);
 		netdev->stats.rx_errors++;
 		if (status & RXSR_TOO_LONG)
 			netdev->stats.rx_length_errors++;
@@ -423,8 +419,7 @@ static void ks8842_rx_frame(struct net_device *netd=
ev,
 void ks8842_handle_rx(struct net_device *netdev, struct ks8842_adapter=
 *adapter)
 {
 	u16 rx_data =3D ks8842_read16(adapter, 16, REG_RXMIR) & 0x1fff;
-	dev_dbg(&adapter->pdev->dev, "%s Entry - rx_data: %d\n",
-		__func__, rx_data);
+	netdev_dbg(netdev, "%s Entry - rx_data: %d\n", __func__, rx_data);
 	while (rx_data) {
 		ks8842_rx_frame(netdev, adapter);
 		rx_data =3D ks8842_read16(adapter, 16, REG_RXMIR) & 0x1fff;
@@ -434,7 +429,7 @@ void ks8842_handle_rx(struct net_device *netdev, st=
ruct ks8842_adapter *adapter)
 void ks8842_handle_tx(struct net_device *netdev, struct ks8842_adapter=
 *adapter)
 {
 	u16 sr =3D ks8842_read16(adapter, 16, REG_TXSR);
-	dev_dbg(&adapter->pdev->dev, "%s - entry, sr: %x\n", __func__, sr);
+	netdev_dbg(netdev, "%s - entry, sr: %x\n", __func__, sr);
 	netdev->stats.tx_packets++;
 	if (netif_queue_stopped(netdev))
 		netif_wake_queue(netdev);
@@ -443,7 +438,7 @@ void ks8842_handle_tx(struct net_device *netdev, st=
ruct ks8842_adapter *adapter)
 void ks8842_handle_rx_overrun(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
-	dev_dbg(&adapter->pdev->dev, "%s: entry\n", __func__);
+	netdev_dbg(netdev, "%s: entry\n", __func__);
 	netdev->stats.rx_errors++;
 	netdev->stats.rx_fifo_errors++;
 }
@@ -462,7 +457,7 @@ void ks8842_tasklet(unsigned long arg)
 	spin_unlock_irqrestore(&adapter->lock, flags);
=20
 	isr =3D ks8842_read16(adapter, 18, REG_ISR);
-	dev_dbg(&adapter->pdev->dev, "%s - ISR: 0x%x\n", __func__, isr);
+	netdev_dbg(netdev, "%s - ISR: 0x%x\n", __func__, isr);
=20
 	/* Ack */
 	ks8842_write16(adapter, 18, isr, REG_ISR);
@@ -501,13 +496,14 @@ void ks8842_tasklet(unsigned long arg)
=20
 static irqreturn_t ks8842_irq(int irq, void *devid)
 {
-	struct ks8842_adapter *adapter =3D devid;
+	struct net_device *netdev =3D devid;
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
 	u16 isr;
 	u16 entry_bank =3D ioread16(adapter->hw_addr + REG_SELECT_BANK);
 	irqreturn_t ret =3D IRQ_NONE;
=20
 	isr =3D ks8842_read16(adapter, 18, REG_ISR);
-	dev_dbg(&adapter->pdev->dev, "%s - ISR: 0x%x\n", __func__, isr);
+	netdev_dbg(netdev, "%s - ISR: 0x%x\n", __func__, isr);
=20
 	if (isr) {
 		/* disable IRQ */
@@ -532,7 +528,7 @@ static int ks8842_open(struct net_device *netdev)
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
 	int err;
=20
-	dev_dbg(&adapter->pdev->dev, "%s - entry\n", __func__);
+	netdev_dbg(netdev, "%s - entry\n", __func__);
=20
 	/* reset the HW */
 	ks8842_reset_hw(adapter);
@@ -542,7 +538,7 @@ static int ks8842_open(struct net_device *netdev)
 	ks8842_update_link_status(netdev, adapter);
=20
 	err =3D request_irq(adapter->irq, ks8842_irq, IRQF_SHARED, DRV_NAME,
-		adapter);
+		netdev);
 	if (err) {
 		pr_err("Failed to request IRQ: %d: %d\n", adapter->irq, err);
 		return err;
@@ -555,10 +551,10 @@ static int ks8842_close(struct net_device *netdev=
)
 {
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
=20
-	dev_dbg(&adapter->pdev->dev, "%s - entry\n", __func__);
+	netdev_dbg(netdev, "%s - entry\n", __func__);
=20
 	/* free the irq */
-	free_irq(adapter->irq, adapter);
+	free_irq(adapter->irq, netdev);
=20
 	/* disable the switch */
 	ks8842_write16(adapter, 32, 0x0, REG_SW_ID_AND_ENABLE);
@@ -572,7 +568,7 @@ static netdev_tx_t ks8842_xmit_frame(struct sk_buff=
 *skb,
 	int ret;
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
=20
-	dev_dbg(&adapter->pdev->dev, "%s: entry\n", __func__);
+	netdev_dbg(netdev, "%s: entry\n", __func__);
=20
 	ret =3D ks8842_tx_frame(skb, netdev);
=20
@@ -588,7 +584,7 @@ static int ks8842_set_mac(struct net_device *netdev=
, void *p)
 	struct sockaddr *addr =3D p;
 	char *mac =3D (u8 *)addr->sa_data;
=20
-	dev_dbg(&adapter->pdev->dev, "%s: entry\n", __func__);
+	netdev_dbg(netdev, "%s: entry\n", __func__);
=20
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -604,7 +600,7 @@ static void ks8842_tx_timeout(struct net_device *ne=
tdev)
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
 	unsigned long flags;
=20
-	dev_dbg(&adapter->pdev->dev, "%s: entry\n", __func__);
+	netdev_dbg(netdev, "%s: entry\n", __func__);
=20
 	spin_lock_irqsave(&adapter->lock, flags);
 	/* disable interrupts */
@@ -663,8 +659,6 @@ static int __devinit ks8842_probe(struct platform_d=
evice *pdev)
 		goto err_get_irq;
 	}
=20
-	adapter->pdev =3D pdev;
-
 	tasklet_init(&adapter->tasklet, ks8842_tasklet, (unsigned long)netdev=
);
 	spin_lock_init(&adapter->lock);
=20

