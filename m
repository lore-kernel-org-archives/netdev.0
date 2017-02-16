From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: bgmac: store MAC address directly in netdev->dev_addr
Date: Thu, 16 Feb 2017 15:11:19 +0100
Message-ID: <20170216141119.18505-1-tklauser@distanz.ch>
Cc: rafal@milecki.pl, f.fainelli@gmail.com, jon.mason@broadcom.com,
        arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:48172 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754959AbdBPOLY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 09:11:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 34a5102c3235 ("net: bgmac: allocate struct bgmac just once
& don't copy it") the mac_addr member of struct bgmac is no longer
necessary to pass the MAC address to bgmac_enet_probe(). Instead it can
directly be stored in netdev->dev_addr.

Also use eth_hw_addr_random() instead of eth_random_addr() in case a
random MAC is nedded. This will make sure netdev->addr_assign_type will
be properly set.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c     | 2 +-
 drivers/net/ethernet/broadcom/bgmac-platform.c | 2 +-
 drivers/net/ethernet/broadcom/bgmac.c          | 9 ++++-----
 drivers/net/ethernet/broadcom/bgmac.h          | 1 -
 4 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 5ef60d4f12b4..d59cfcc4c4d5 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -144,7 +144,7 @@ static int bgmac_probe(struct bcma_device *core)
 		goto err;
 	}
 
-	ether_addr_copy(bgmac->mac_addr, mac);
+	ether_addr_copy(bgmac->net_dev->dev_addr, mac);
 
 	/* On BCM4706 we need common core to access PHY */
 	if (core->id.id == BCMA_CORE_4706_MAC_GBIT &&
diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 805e6ed6c390..7b1af950f312 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -169,7 +169,7 @@ static int bgmac_probe(struct platform_device *pdev)
 
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
-		ether_addr_copy(bgmac->mac_addr, mac_addr);
+		ether_addr_copy(bgmac->net_dev->dev_addr, mac_addr);
 	else
 		dev_warn(&pdev->dev, "MAC address not present in device tree\n");
 
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 20fe2520da42..415046750bb4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1477,14 +1477,13 @@ int bgmac_enet_probe(struct bgmac *bgmac)
 	net_dev->irq = bgmac->irq;
 	SET_NETDEV_DEV(net_dev, bgmac->dev);
 
-	if (!is_valid_ether_addr(bgmac->mac_addr)) {
+	if (!is_valid_ether_addr(net_dev->dev_addr)) {
 		dev_err(bgmac->dev, "Invalid MAC addr: %pM\n",
-			bgmac->mac_addr);
-		eth_random_addr(bgmac->mac_addr);
+			net_dev->dev_addr);
+		eth_hw_addr_random(net_dev);
 		dev_warn(bgmac->dev, "Using random MAC: %pM\n",
-			 bgmac->mac_addr);
+			 net_dev->dev_addr);
 	}
-	ether_addr_copy(net_dev->dev_addr, bgmac->mac_addr);
 
 	/* This (reset &) enable is not preset in specs or reference driver but
 	 * Broadcom does it in arch PCI code when enabling fake PCI device.
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index ab2db76e4fb8..248727dc62f2 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -474,7 +474,6 @@ struct bgmac {
 
 	struct device *dev;
 	struct device *dma_dev;
-	unsigned char mac_addr[ETH_ALEN];
 	u32 feature_flags;
 
 	struct net_device *net_dev;
-- 
2.11.0
