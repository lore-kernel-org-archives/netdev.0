From: Tim Harvey <tharvey@gateworks.com>
Subject: [PATCH v2] sky2: allow mac to come from dt
Date: Wed,  5 Mar 2014 14:45:12 -0800
Message-ID: <1394059512-1691-1-git-send-email-tharvey@gateworks.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:35099 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbaCEWpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 17:45:21 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so1689969pbb.31
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 14:45:20 -0800 (PST)
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

Changes since v1:
 - simplified based on feedback
 - fixed formatting
---
 drivers/net/ethernet/marvell/sky2.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 55a37ae..471473e 100644
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
@@ -4805,8 +4808,17 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 
 	dev->features |= dev->hw_features;
 
-	/* read the mac address */
-	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8, ETH_ALEN);
+	/* try to get mac address in the following order:
+	 * 1) from device tree data
+	 * 2) from internal registers set by bootloader
+	 */
+	iap = of_get_mac_address(hw->pdev->dev.of_node);
+	if (!iap) {
+		memcpy_fromio(&tmpaddr, hw->regs + B2_MAC_1 + port * 8,
+			      ETH_ALEN);
+		iap = tmpaddr;
+	}
+	ether_addr_copy(dev->dev_addr, iap);
 
 	return dev;
 }
-- 
1.8.3.2
