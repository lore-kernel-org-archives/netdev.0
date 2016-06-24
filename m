From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Decrement phy_fixed_addr during unregister
Date: Fri, 24 Jun 2016 15:44:11 -0700
Message-ID: <1466808251-19588-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, linux@armlinux.org.uk,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33569 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFXWoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:44:18 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so10036706pac.0
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:44:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have a system which uses fixed PHY devices and calls
fixed_phy_register() then fixed_phy_unregister() we can exhaust the
number of fixed PHYs available after a while, since we keep incrementing
the variable phy_fixed_addr, but we never decrement it.

This patch fixes that by decrementing phy_fixed_addr during
fixed_phy_del(), and in order to do that, we need to move the
phy_fixed_addr integer and its spinlock above that function.

Fixes: a75951217472 ("net: phy: extend fixed driver with fixed_phy_register()")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed_phy.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 2d2e4339f0df..050bc5657b9d 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -286,6 +286,9 @@ err_regs:
 }
 EXPORT_SYMBOL_GPL(fixed_phy_add);
 
+static int phy_fixed_addr;
+static DEFINE_SPINLOCK(phy_fixed_addr_lock);
+
 static void fixed_phy_del(int phy_addr)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
@@ -297,14 +300,14 @@ static void fixed_phy_del(int phy_addr)
 			if (gpio_is_valid(fp->link_gpio))
 				gpio_free(fp->link_gpio);
 			kfree(fp);
+			spin_lock(&phy_fixed_addr_lock);
+			phy_fixed_addr--;
+			spin_unlock(&phy_fixed_addr_lock);
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
-- 
2.7.4
