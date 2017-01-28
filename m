From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 1/3] net: bgmac: allocate struct bgmac just once & don't copy it
Date: Sat, 28 Jan 2017 22:08:30 +0100
Message-ID: <20170128210832.26174-2-zajec5@gmail.com>
References: <20170128210832.26174-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36329 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751912AbdA1VJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 16:09:12 -0500
Received: by mail-lf0-f66.google.com with SMTP id h65so28435076lfi.3
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 13:09:11 -0800 (PST)
In-Reply-To: <20170128210832.26174-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

So far were were allocating struct bgmac in 3 places: platform code,
bcma code and shared bgmac_enet_probe function. The reason for this was
bgmac_enet_probe:
1) Requiring early-filled struct bgmac
2) Calling alloc_etherdev on its own in order to use netdev_priv later

This solution got few drawbacks:
1) Was duplicating allocating code
2) Required copying early-filled struct
3) Resulted in platform/bcma code having access only to unused struct

Solve this situation by simply extracting some probe code into the new
bgmac_alloc function.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V2: Add bgmac_alloc function instead of hacking alloc_etherdev and netdev_priv

Important: this patch depends on:
[PATCH net-next] net: add devm version of alloc_etherdev_mqs function
and is the first user of devm_alloc_etherdev.
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c     |  4 +---
 drivers/net/ethernet/broadcom/bgmac-platform.c |  2 +-
 drivers/net/ethernet/broadcom/bgmac.c          | 24 ++++++++++++++++--------
 drivers/net/ethernet/broadcom/bgmac.h          |  3 ++-
 4 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 4a4ffc0c4c65..9281abda4026 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -117,12 +117,11 @@ static int bgmac_probe(struct bcma_device *core)
 	u8 *mac;
 	int err;
 
-	bgmac = kzalloc(sizeof(*bgmac), GFP_KERNEL);
+	bgmac = bgmac_alloc(&core->dev);
 	if (!bgmac)
 		return -ENOMEM;
 
 	bgmac->bcma.core = core;
-	bgmac->dev = &core->dev;
 	bgmac->dma_dev = core->dma_dev;
 	bgmac->irq = core->irq;
 
@@ -307,7 +306,6 @@ static int bgmac_probe(struct bcma_device *core)
 err1:
 	bcma_mdio_mii_unregister(bgmac->mii_bus);
 err:
-	kfree(bgmac);
 	bcma_set_drvdata(core, NULL);
 
 	return err;
diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 6f736c19872f..805e6ed6c390 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -151,7 +151,7 @@ static int bgmac_probe(struct platform_device *pdev)
 	struct resource *regs;
 	const u8 *mac_addr;
 
-	bgmac = devm_kzalloc(&pdev->dev, sizeof(*bgmac), GFP_KERNEL);
+	bgmac = bgmac_alloc(&pdev->dev);
 	if (!bgmac)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 0e066dc6b8cc..632d4d7b5a5b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1446,22 +1446,31 @@ int bgmac_phy_connect_direct(struct bgmac *bgmac)
 }
 EXPORT_SYMBOL_GPL(bgmac_phy_connect_direct);
 
-int bgmac_enet_probe(struct bgmac *info)
+struct bgmac *bgmac_alloc(struct device *dev)
 {
 	struct net_device *net_dev;
 	struct bgmac *bgmac;
-	int err;
 
 	/* Allocation and references */
-	net_dev = alloc_etherdev(sizeof(*bgmac));
+	net_dev = devm_alloc_etherdev(dev, sizeof(*bgmac));
 	if (!net_dev)
-		return -ENOMEM;
+		return NULL;
 
 	net_dev->netdev_ops = &bgmac_netdev_ops;
 	net_dev->ethtool_ops = &bgmac_ethtool_ops;
+
 	bgmac = netdev_priv(net_dev);
-	memcpy(bgmac, info, sizeof(*bgmac));
+	bgmac->dev = dev;
 	bgmac->net_dev = net_dev;
+
+	return bgmac;
+}
+
+int bgmac_enet_probe(struct bgmac *bgmac)
+{
+	struct net_device *net_dev = bgmac->net_dev;
+	int err;
+
 	net_dev->irq = bgmac->irq;
 	SET_NETDEV_DEV(net_dev, bgmac->dev);
 
@@ -1488,7 +1497,7 @@ int bgmac_enet_probe(struct bgmac *info)
 	err = bgmac_dma_alloc(bgmac);
 	if (err) {
 		dev_err(bgmac->dev, "Unable to alloc memory for DMA\n");
-		goto err_netdev_free;
+		goto err_out;
 	}
 
 	bgmac->int_mask = BGMAC_IS_ERRMASK | BGMAC_IS_RX | BGMAC_IS_TX_MASK;
@@ -1521,8 +1530,7 @@ int bgmac_enet_probe(struct bgmac *info)
 	phy_disconnect(net_dev->phydev);
 err_dma_free:
 	bgmac_dma_free(bgmac);
-err_netdev_free:
-	free_netdev(net_dev);
+err_out:
 
 	return err;
 }
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 71f493f2451f..dfebaded3b52 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -517,7 +517,8 @@ struct bgmac {
 	int (*phy_connect)(struct bgmac *bgmac);
 };
 
-int bgmac_enet_probe(struct bgmac *info);
+struct bgmac *bgmac_alloc(struct device *dev);
+int bgmac_enet_probe(struct bgmac *bgmac);
 void bgmac_enet_remove(struct bgmac *bgmac);
 void bgmac_adjust_link(struct net_device *net_dev);
 int bgmac_phy_connect_direct(struct bgmac *bgmac);
-- 
2.11.0
