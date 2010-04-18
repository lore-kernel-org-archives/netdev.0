From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH] ks8842: Add platform data for setting mac address
Date: Mon, 19 Apr 2010 00:12:21 +0200
Message-ID: <1271628741.18194.7.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h22.telenor.se ([195.54.99.197]:60825 "EHLO
	smtprelay-h22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab0DRWnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 18:43:24 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h22.telenor.se (Postfix) with ESMTP id 42236D039
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 00:12:23 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds platform data to the ks8842 driver.

Via the platform data a MAC address, to be used by the controller,
can be passed.

To ensure this MAC address is used, the MAC address is written
after each hardware reset.

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 5c45cb5..423dd8d 100644
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
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/ks8842.h>
=20
 #define DRV_NAME "ks8842"
=20
@@ -302,6 +303,20 @@ static void ks8842_read_mac_addr(struct ks8842_ada=
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
@@ -520,6 +535,8 @@ static int ks8842_open(struct net_device *netdev)
 	/* reset the HW */
 	ks8842_reset_hw(adapter);
=20
+	ks8842_write_mac_addr(adapter, netdev->dev_addr);
+
 	ks8842_update_link_status(netdev, adapter);
=20
 	err =3D request_irq(adapter->irq, ks8842_irq, IRQF_SHARED, DRV_NAME,
@@ -567,10 +584,8 @@ static netdev_tx_t ks8842_xmit_frame(struct sk_buf=
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
@@ -579,13 +594,7 @@ static int ks8842_set_mac(struct net_device *netde=
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
@@ -604,6 +613,8 @@ static void ks8842_tx_timeout(struct net_device *ne=
tdev)
=20
 	ks8842_reset_hw(adapter);
=20
+	ks8842_write_mac_addr(adapter, netdev->dev_addr);
+
 	ks8842_update_link_status(netdev, adapter);
 }
=20
@@ -626,7 +637,9 @@ static int __devinit ks8842_probe(struct platform_d=
evice *pdev)
 	struct resource *iomem;
 	struct net_device *netdev;
 	struct ks8842_adapter *adapter;
+	struct ks8842_platform_data *pdata =3D pdev->dev.platform_data;
 	u16 id;
+	unsigned i;
=20
 	iomem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!request_mem_region(iomem->start, resource_size(iomem), DRV_NAME)=
)
@@ -657,7 +670,25 @@ static int __devinit ks8842_probe(struct platform_=
device *pdev)
 	netdev->netdev_ops =3D &ks8842_netdev_ops;
 	netdev->ethtool_ops =3D &ks8842_ethtool_ops;
=20
-	ks8842_read_mac_addr(adapter, netdev->dev_addr);
+	/* Check if a mac address was given */
+	i =3D netdev->addr_len;
+	if (pdata) {
+		for (i =3D 0; i < netdev->addr_len; i++)
+			if (pdata->macaddr[i] !=3D 0)
+				break;
+
+		if (i < netdev->addr_len)
+			/* an address was passed, use it */
+			memcpy(netdev->dev_addr, pdata->macaddr,
+				netdev->addr_len);
+	}
+
+	if (i =3D=3D netdev->addr_len) {
+		ks8842_read_mac_addr(adapter, netdev->dev_addr);
+
+		if (!is_valid_ether_addr(netdev->dev_addr))
+			random_ether_addr(netdev->dev_addr);
+	}
=20
 	id =3D ks8842_read16(adapter, 32, REG_SW_ID_AND_ENABLE);
=20
diff --git a/include/linux/ks8842.h b/include/linux/ks8842.h
new file mode 100644
index 0000000..da0341b
--- /dev/null
+++ b/include/linux/ks8842.h
@@ -0,0 +1,34 @@
+/*
+ * ks8842.h KS8842 platform data struct definition
+ * Copyright (c) 2010 Intel Corporation
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _LINUX_KS8842_H
+#define _LINUX_KS8842_H
+
+#include <linux/if_ether.h>
+
+/**
+ * struct ks8842_platform_data - Platform data of the KS8842 network d=
river
+ * @macaddr:	The MAC address of the device, set to all 0:s to use the =
on in
+ *		the chip.
+ *
+ */
+struct ks8842_platform_data {
+	u8 macaddr[ETH_ALEN];
+};
+
+#endif

