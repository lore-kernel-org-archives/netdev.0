From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH v3 1/2] ks8842: Do the TX timeout work in workqueue context.
Date: Fri, 09 Jul 2010 08:28:14 +0200
Message-ID: <1278656894.6953.14.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:53083 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab0GIGtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:49:01 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id C8F21E8FB1
	for <netdev@vger.kernel.org>; Fri,  9 Jul 2010 08:28:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently all code that needs to be run at TX timeout is done in the
calling context, where bottom halves are disabled. Some of the code
blocks, so it needs to be done in a different context. This patch
adds in a work struct which is scheduled at TX timeout. Then the
timeout code is executed within work queue context.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index d47bba9..5191af2 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -119,6 +119,8 @@ struct ks8842_adapter {
 	int		irq;
 	struct tasklet_struct	tasklet;
 	spinlock_t	lock; /* spinlock to be interrupt safe */
+	struct work_struct timeout_work;
+	struct net_device *netdev;
 };
=20
 static inline void ks8842_select_bank(struct ks8842_adapter *adapter, =
u16 bank)
@@ -553,6 +555,8 @@ static int ks8842_close(struct net_device *netdev)
=20
 	netdev_dbg(netdev, "%s - entry\n", __func__);
=20
+	cancel_work_sync(&adapter->timeout_work);
+
 	/* free the irq */
 	free_irq(adapter->irq, netdev);
=20
@@ -595,9 +599,11 @@ static int ks8842_set_mac(struct net_device *netde=
v, void *p)
 	return 0;
 }
=20
-static void ks8842_tx_timeout(struct net_device *netdev)
+static void ks8842_tx_timeout_work(struct work_struct *work)
 {
-	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+	struct ks8842_adapter *adapter =3D
+		container_of(work, struct ks8842_adapter, timeout_work);
+	struct net_device *netdev =3D adapter->netdev;
 	unsigned long flags;
=20
 	netdev_dbg(netdev, "%s: entry\n", __func__);
@@ -606,6 +612,9 @@ static void ks8842_tx_timeout(struct net_device *ne=
tdev)
 	/* disable interrupts */
 	ks8842_write16(adapter, 18, 0, REG_IER);
 	ks8842_write16(adapter, 18, 0xFFFF, REG_ISR);
+
+	netif_stop_queue(netdev);
+
 	spin_unlock_irqrestore(&adapter->lock, flags);
=20
 	ks8842_reset_hw(adapter);
@@ -615,6 +624,15 @@ static void ks8842_tx_timeout(struct net_device *n=
etdev)
 	ks8842_update_link_status(netdev, adapter);
 }
=20
+static void ks8842_tx_timeout(struct net_device *netdev)
+{
+	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
+
+	netdev_dbg(netdev, "%s: entry\n", __func__);
+
+	schedule_work(&adapter->timeout_work);
+}
+
 static const struct net_device_ops ks8842_netdev_ops =3D {
 	.ndo_open		=3D ks8842_open,
 	.ndo_stop		=3D ks8842_close,
@@ -649,6 +667,8 @@ static int __devinit ks8842_probe(struct platform_d=
evice *pdev)
 	SET_NETDEV_DEV(netdev, &pdev->dev);
=20
 	adapter =3D netdev_priv(netdev);
+	adapter->netdev =3D netdev;
+	INIT_WORK(&adapter->timeout_work, ks8842_tx_timeout_work);
 	adapter->hw_addr =3D ioremap(iomem->start, resource_size(iomem));
 	if (!adapter->hw_addr)
 		goto err_ioremap;

