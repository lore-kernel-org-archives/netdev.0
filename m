From: Eugene Konev <ejka@imfi.kspu.ru>
Subject: [PATCH 3/3] cpmac: update to new fixed phy driver interface
Date: Wed, 24 Oct 2007 10:42:03 +0800
Message-ID: <1193193723-12691-4-git-send-email-ejka@imfi.kspu.ru>
References: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru>
 <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
 <1193193723-12691-3-git-send-email-ejka@imfi.kspu.ru>
Cc: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org,
	Eugene Konev <ejka@imfi.kspu.ru>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 117.19.65.80.ip.morning.ru ([80.65.19.117]:54701 "EHLO
	mail.imfi.kspu.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753323AbXJXDBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:01:12 -0400
In-Reply-To: <1193193723-12691-3-git-send-email-ejka@imfi.kspu.ru>
Message-Id: <6a2c62ba4fb9c80b4a4a957168183fbe35775740.1193191283.git.ejka@imfi.kspu.ru>
In-Reply-To: <5070e5ddd7ae0681b14e712980d830225a2103aa.1193191283.git.ejka@imfi.kspu.ru>
References: <5070e5ddd7ae0681b14e712980d830225a2103aa.1193191283.git.ejka@imfi.kspu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use fixed_mdio_get_phydev for obtaining fixed phy instances and adopt to
changed fixed phy device naming.

Signed-off-by: Eugene Konev <ejka@imfi.kspu.ru>
---
 drivers/net/cpmac.c |   64 ++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 46 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 486c82b..6fd95a2 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -34,6 +34,7 @@
 #include <linux/skbuff.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <asm/gpio.h>
@@ -847,6 +848,15 @@ static void cpmac_adjust_link(struct net_device *dev)
 	spin_unlock(&priv->lock);
 }
 
+static int cpmac_link_update(struct net_device *dev,
+			     struct fixed_phy_status *status)
+{
+	status->link = 1;
+	status->speed = 100;
+	status->duplex = 1;
+	return 0;
+}
+
 static int cpmac_open(struct net_device *dev)
 {
 	int i, size, res;
@@ -855,15 +865,6 @@ static int cpmac_open(struct net_device *dev)
 	struct cpmac_desc *desc;
 	struct sk_buff *skb;
 
-	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link,
-				0, PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(priv->phy)) {
-		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: Could not attach to PHY\n",
-			       dev->name);
-		return PTR_ERR(priv->phy);
-	}
-
 	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
 	if (!request_mem_region(mem->start, mem->end - mem->start, dev->name)) {
 		if (netif_msg_drv(priv))
@@ -950,8 +951,6 @@ fail_remap:
 	release_mem_region(mem->start, mem->end - mem->start);
 
 fail_reserve:
-	phy_disconnect(priv->phy);
-
 	return res;
 }
 
@@ -966,8 +965,6 @@ static int cpmac_stop(struct net_device *dev)
 	cancel_work_sync(&priv->reset_work);
 	napi_disable(&priv->napi);
 	phy_stop(priv->phy);
-	phy_disconnect(priv->phy);
-	priv->phy = NULL;
 
 	cpmac_hw_stop(dev);
 
@@ -1001,11 +998,12 @@ static int external_switch;
 
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
-	int rc, phy_id;
+	int rc, phy_id, i;
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
+	struct fixed_info *fixed_phy;
 	DECLARE_MAC_BUF(mac);
 
 	pdata = pdev->dev.platform_data;
@@ -1064,11 +1062,41 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->ring_size = 64;
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
+
 	if (phy_id == 31) {
-		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT,
-			 cpmac_mii.id, phy_id);
-	} else
-		snprintf(priv->phy_name, BUS_ID_SIZE, "fixed@%d:%d", 100, 1);
+		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, cpmac_mii.id,
+			 phy_id);
+	} else {
+		/* Let's try to get a free fixed phy... */
+		for (i = 0; i < MAX_PHY_AMNT; i++) {
+			fixed_phy = fixed_mdio_get_phydev(i);
+			if (!fixed_phy)
+				continue;
+			if (!fixed_phy->phydev->attached_dev) {
+				strncpy(priv->phy_name,
+					fixed_phy->phydev->dev.bus_id,
+					BUS_ID_SIZE);
+				fixed_mdio_set_link_update(fixed_phy->phydev,
+							   &cpmac_link_update);
+				goto phy_found;
+			}
+		}
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: Could not find fixed PHY\n",
+			       dev->name);
+		rc = -ENODEV;
+		goto fail;
+	}
+
+phy_found:
+	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(priv->phy)) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: Could not attach to PHY\n",
+			       dev->name);
+		return PTR_ERR(priv->phy);
+	}
 
 	if ((rc = register_netdev(dev))) {
 		printk(KERN_ERR "cpmac: error %i registering device %s\n", rc,
-- 
1.5.3.4

