From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: phy: Manage fixed PHY address space using IDA
Date: Fri, 24 Jun 2016 16:25:24 -0700
Message-ID: <1466810724-6615-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, linux@armlinux.org.uk,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34183 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbcFXXZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 19:25:36 -0400
Received: by mail-pf0-f193.google.com with SMTP id 66so10388206pfy.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 16:25:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have a system which uses fixed PHY devices and calls
fixed_phy_register() then fixed_phy_unregister() we can exhaust the
number of fixed PHYs available after a while, since we keep incrementing
the variable phy_fixed_addr, but we never decrement it.

This patch fixes that by converting the fixed PHY allocation to using
IDA, which takes care of the allocation/dealloaction of the PHY
addresses for us.

Fixes: a75951217472 ("net: phy: extend fixed driver with fixed_phy_register()")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed_phy.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 2d2e4339f0df..9ec7f7353434 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/gpio.h>
+#include <linux/idr.h>
 
 #define MII_REGS_NUM 29
 
@@ -286,6 +287,8 @@ err_regs:
 }
 EXPORT_SYMBOL_GPL(fixed_phy_add);
 
+static DEFINE_IDA(phy_fixed_ida);
+
 static void fixed_phy_del(int phy_addr)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
@@ -297,14 +300,12 @@ static void fixed_phy_del(int phy_addr)
 			if (gpio_is_valid(fp->link_gpio))
 				gpio_free(fp->link_gpio);
 			kfree(fp);
+			ida_simple_remove(&phy_fixed_ida, phy_addr);
 			return;
 		}
 	}
 }
 
-static int phy_fixed_addr;
-static DEFINE_SPINLOCK(phy_fixed_addr_lock);
-
 struct phy_device *fixed_phy_register(unsigned int irq,
 				      struct fixed_phy_status *status,
 				      int link_gpio,
@@ -319,17 +320,15 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 		return ERR_PTR(-EPROBE_DEFER);
 
 	/* Get the next available PHY address, up to PHY_MAX_ADDR */
-	spin_lock(&phy_fixed_addr_lock);
-	if (phy_fixed_addr == PHY_MAX_ADDR) {
-		spin_unlock(&phy_fixed_addr_lock);
-		return ERR_PTR(-ENOSPC);
-	}
-	phy_addr = phy_fixed_addr++;
-	spin_unlock(&phy_fixed_addr_lock);
+	phy_addr = ida_simple_get(&phy_fixed_ida, 0, PHY_MAX_ADDR, GFP_KERNEL);
+	if (phy_addr < 0)
+		return ERR_PTR(phy_addr);
 
 	ret = fixed_phy_add(irq, phy_addr, status, link_gpio);
-	if (ret < 0)
+	if (ret < 0) {
+		ida_simple_remove(&phy_fixed_ida, phy_addr);
 		return ERR_PTR(ret);
+	}
 
 	phy = get_phy_device(fmb->mii_bus, phy_addr, false);
 	if (IS_ERR(phy)) {
@@ -434,6 +433,7 @@ static void __exit fixed_mdio_bus_exit(void)
 		list_del(&fp->node);
 		kfree(fp);
 	}
+	ida_destroy(&phy_fixed_ida);
 }
 module_exit(fixed_mdio_bus_exit);
 
-- 
2.7.4
