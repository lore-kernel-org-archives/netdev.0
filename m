From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/7] au1000-eth: implement set/get_msglevel
Date: Wed, 7 Apr 2010 10:09:09 +0200
Message-ID: <201004071009.10042.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:4845 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143Ab0DGIKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:16 -0400
Received: by ey-out-2122.google.com with SMTP id d26so91648eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

{set,get}_msglevel is required to use netif_{err,dbg} macros.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 49f56b4..0c59d4c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -75,6 +75,10 @@ static int au1000_debug = 5;
 static int au1000_debug = 3;
 #endif
 
+#define AU1000_DEF_MSG_ENABLE	(NETIF_MSG_DRV	| \
+				NETIF_MSG_PROBE	| \
+				NETIF_MSG_LINK)
+
 #define DRV_NAME	"au1000_eth"
 #define DRV_VERSION	"1.6"
 #define DRV_AUTHOR	"Pete Popov <ppopov@embeddedalley.com>"
@@ -583,11 +587,25 @@ au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	info->regdump_len = 0;
 }
 
+static void au1000_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	aup->msg_enable = value;
+}
+
+static u32 au1000_get_msglevel(struct net_device *dev)
+{
+	struct au1000_private *aup = netdev_priv(dev);
+	return aup->msg_enable;
+}
+
 static const struct ethtool_ops au1000_ethtool_ops = {
 	.get_settings = au1000_get_settings,
 	.set_settings = au1000_set_settings,
 	.get_drvinfo = au1000_get_drvinfo,
 	.get_link = ethtool_op_get_link,
+	.get_msglevel = au1000_get_msglevel,
+	.set_msglevel = au1000_set_msglevel,
 };
 
 
@@ -1050,6 +1068,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	aup = netdev_priv(dev);
 
 	spin_lock_init(&aup->lock);
+	aup->msg_enable = (au1000_debug < 4 ? AU1000_DEF_MSG_ENABLE : au1000_debug);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 344c600..d06ec00 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -125,4 +125,6 @@ struct au1000_private {
 	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
 
 	spinlock_t lock;       /* Serialise access to device */
+
+	u32 msg_enable;
 };
