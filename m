From: Tim Harvey <tharvey@gateworks.com>
Subject: [PATCH] net: sky2: allow mac to come from dt
Date: Tue,  4 Mar 2014 22:22:15 -0800
Message-ID: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:59982 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbaCEGW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 01:22:28 -0500
Received: by mail-pd0-f182.google.com with SMTP id g10so627794pdj.13
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 22:22:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver reads the mac address from the device registers which would
need to have been programmed by the bootloader.  This patch adds
the ability to pull the mac from devicetree via the pci device dt node.

Signed-off-by: Tim Harvey <tharvey@gateworks.com>
Cc: netdev@vger.kernel.org
Cc: devicetree@vger.kernel.org
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <robh+dt@kernel.org>
---
 drivers/net/ethernet/marvell/sky2.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 55a37ae..bff493a 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -44,6 +44,8 @@
 #include <linux/prefetch.h>
 #include <linux/debugfs.h>
 #include <linux/mii.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
 
 #include <asm/irq.h>
 
@@ -4748,6 +4750,7 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
+	unsigned char *iap, tmpaddr[ETH_ALEN];
 
 	if (!dev)
 		return NULL;
@@ -4805,8 +4808,27 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 
 	dev->features |= dev->hw_features;
 
+	/* try to get mac address in the following order:
+	 * 1) from device tree data
+	 * 2) from internal registers set by bootloader
+	 */
+	iap = NULL;
+	if (IS_ENABLED(CONFIG_OF)) {
+		struct device_node *np = hw->pdev->dev.of_node;
+		if (np)
+			iap = (unsigned char *) of_get_mac_address(np);
+	}
+
+	/* 2) mac registers set by bootloader
+	 */
+	if (!iap || !is_valid_ether_addr(iap)) {
+		memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
+			ETH_ALEN);
+		iap = &tmpaddr[0];
+	}
+
 	/* read the mac address */
-	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
+	ether_addr_copy(dev->dev_addr, iap);
 
 	return dev;
 }
-- 
1.8.3.2
