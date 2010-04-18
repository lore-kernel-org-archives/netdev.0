From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH] ks8842: Add module param for setting mac address
Date: Sun, 18 Apr 2010 19:25:57 +0200
Message-ID: <1271611557.24099.11.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:38395 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab0DRR0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 13:26:01 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 21297D421
	for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 19:25:58 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a module parameter for setting the MAC address.

To ensure this MAC address is used, the MAC address is written
after each hardware reset.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 5c45cb5..a013662 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -1,5 +1,5 @@
 /*
- * ks8842_main.c timberdale KS8842 ethernet driver
+ * ks8842.c timberdale KS8842 ethernet driver
  * Copyright (c) 2009 Intel Corporation
  *
  * This program is free software; you can redistribute it and/or modif=
y
@@ -119,6 +119,8 @@ struct ks8842_adapter {
 	struct platform_device *pdev;
 };
=20
+static u8 __devinitdata macaddr[ETH_ALEN];
+
 static inline void ks8842_select_bank(struct ks8842_adapter *adapter, =
u16 bank)
 {
 	iowrite16(bank, adapter->hw_addr + REG_SELECT_BANK);
@@ -302,6 +304,20 @@ static void ks8842_read_mac_addr(struct ks8842_ada=
pter *adapter, u8 *dest)
 	ks8842_write16(adapter, 39, mac, REG_MACAR3);
 }
=20
+static void ks8842_write_mac_addr(struct ks8842_adapter *adapter, u8 *=
mac)
+{
+	unsigned long flags;
+	unsigned i;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		ks8842_write8(adapter, 2, mac[ETH_ALEN - i - 1], REG_MARL + i);
+		ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
+			REG_MACAR1 + i);
+	}
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
 static inline u16 ks8842_tx_fifo_space(struct ks8842_adapter *adapter)
 {
 	return ks8842_read16(adapter, 16, REG_TXMIR) & 0x1fff;
@@ -520,6 +536,8 @@ static int ks8842_open(struct net_device *netdev)
 	/* reset the HW */
 	ks8842_reset_hw(adapter);
=20
+	ks8842_write_mac_addr(adapter, netdev->dev_addr);
+
 	ks8842_update_link_status(netdev, adapter);
=20
 	err =3D request_irq(adapter->irq, ks8842_irq, IRQF_SHARED, DRV_NAME,
@@ -567,10 +585,8 @@ static netdev_tx_t ks8842_xmit_frame(struct sk_buf=
f *skb,
 static int ks8842_set_mac(struct net_device *netdev, void *p)
 {
 	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
-	unsigned long flags;
 	struct sockaddr *addr =3D p;
 	char *mac =3D (u8 *)addr->sa_data;
-	int i;
=20
 	dev_dbg(&adapter->pdev->dev, "%s: entry\n", __func__);
=20
@@ -579,13 +595,7 @@ static int ks8842_set_mac(struct net_device *netde=
v, void *p)
=20
 	memcpy(netdev->dev_addr, mac, netdev->addr_len);
=20
-	spin_lock_irqsave(&adapter->lock, flags);
-	for (i =3D 0; i < ETH_ALEN; i++) {
-		ks8842_write8(adapter, 2, mac[ETH_ALEN - i - 1], REG_MARL + i);
-		ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
-			REG_MACAR1 + i);
-	}
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	ks8842_write_mac_addr(adapter, mac);
 	return 0;
 }
=20
@@ -604,6 +614,8 @@ static void ks8842_tx_timeout(struct net_device *ne=
tdev)
=20
 	ks8842_reset_hw(adapter);
=20
+	ks8842_write_mac_addr(adapter, netdev->dev_addr);
+
 	ks8842_update_link_status(netdev, adapter);
 }
=20
@@ -627,6 +639,7 @@ static int __devinit ks8842_probe(struct platform_d=
evice *pdev)
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
 	u16 id;
+	unsigned i;
=20
 	iomem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!request_mem_region(iomem->start, resource_size(iomem), DRV_NAME)=
)
@@ -657,7 +670,20 @@ static int __devinit ks8842_probe(struct platform_=
device *pdev)
 	netdev->netdev_ops =3D &ks8842_netdev_ops;
 	netdev->ethtool_ops =3D &ks8842_ethtool_ops;
=20
-	ks8842_read_mac_addr(adapter, netdev->dev_addr);
+	/* Check if a mac address was given */
+	for (i =3D 0; i < netdev->addr_len; i++)
+		if (macaddr[i] !=3D 0)
+			break;
+
+	if (i < netdev->addr_len)
+		/* an address was passed, use it */
+		memcpy(netdev->dev_addr, macaddr, netdev->addr_len);
+	else {
+		ks8842_read_mac_addr(adapter, netdev->dev_addr);
+
+		if (!is_valid_ether_addr(netdev->dev_addr))
+			random_ether_addr(netdev->dev_addr);
+	}
=20
 	id =3D ks8842_read16(adapter, 32, REG_SW_ID_AND_ENABLE);
=20
@@ -723,6 +749,10 @@ static void __exit ks8842_exit(void)
 module_init(ks8842_init);
 module_exit(ks8842_exit);
=20
+/* accept MAC address of the form macaddr=3D0x08,0x00,0x20,0x30,0x40,0=
x50 */
+module_param_array(macaddr, byte, NULL, 0);
+MODULE_PARM_DESC(macaddr, "KS8842 MAC address to set");
+
 MODULE_DESCRIPTION("Timberdale KS8842 ethernet driver");
 MODULE_AUTHOR("Mocean Laboratories <info@mocean-labs.com>");
 MODULE_LICENSE("GPL v2");

