From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH] phy: remove irq param to fix crash in fixed_phy_add()
Date: Mon, 16 May 2016 13:15:56 +0200
Message-ID: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org,
	devicetree@vger.kernel.org, Rabin Vincent <rabinv@axis.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

Since e7f4dc3536a ("mdio: Move allocation of interrupts into core"),
platforms which call fixed_phy_add() before fixed_mdio_bus_init() is
called (for example, because the platform code and the fixed_phy driver
use the same initcall level) crash in fixed_phy_add() since the
->mii_bus is not allocated.

Also since e7f4dc3536a, these interrupts are initalized to polling by
default.  All callers of both fixed_phy_register() and fixed_phy_add()
pass PHY_POLL for the irq argument, so we can fix these crashes by
simply removing the irq parameter, since the default is correct for all
users.

Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
Signed-off-by: Rabin Vincent <rabinv@axis.com>
---
 arch/m68k/coldfire/m5272.c                   |  2 +-
 arch/mips/ar7/platform.c                     |  5 ++---
 arch/mips/bcm47xx/setup.c                    |  2 +-
 drivers/net/ethernet/broadcom/bgmac.c        |  2 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c |  2 +-
 drivers/net/phy/fixed_phy.c                  | 10 +++-------
 drivers/of/of_mdio.c                         |  6 +++---
 include/linux/phy_fixed.h                    | 16 ++++++----------
 8 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/arch/m68k/coldfire/m5272.c b/arch/m68k/coldfire/m5272.c
index c525e4c..217e2e0 100644
--- a/arch/m68k/coldfire/m5272.c
+++ b/arch/m68k/coldfire/m5272.c
@@ -126,7 +126,7 @@ static struct fixed_phy_status nettel_fixed_phy_status __initdata = {
 static int __init init_BSP(void)
 {
 	m5272_uarts_init();
-	fixed_phy_add(PHY_POLL, 0, &nettel_fixed_phy_status, -1);
+	fixed_phy_add(0, &nettel_fixed_phy_status, -1);
 	return 0;
 }
 
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index 58fca9a..0a024b0 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -678,8 +678,7 @@ static int __init ar7_register_devices(void)
 	}
 
 	if (ar7_has_high_cpmac()) {
-		res = fixed_phy_add(PHY_POLL, cpmac_high.id,
-				    &fixed_phy_status, -1);
+		res = fixed_phy_add(cpmac_high.id, &fixed_phy_status, -1);
 		if (!res) {
 			cpmac_get_mac(1, cpmac_high_data.dev_addr);
 
@@ -692,7 +691,7 @@ static int __init ar7_register_devices(void)
 	} else
 		cpmac_low_data.phy_mask = 0xffffffff;
 
-	res = fixed_phy_add(PHY_POLL, cpmac_low.id, &fixed_phy_status, -1);
+	res = fixed_phy_add(cpmac_low.id, &fixed_phy_status, -1);
 	if (!res) {
 		cpmac_get_mac(0, cpmac_low_data.dev_addr);
 		res = platform_device_register(&cpmac_low);
diff --git a/arch/mips/bcm47xx/setup.c b/arch/mips/bcm47xx/setup.c
index c807e32..ca3fbd1 100644
--- a/arch/mips/bcm47xx/setup.c
+++ b/arch/mips/bcm47xx/setup.c
@@ -243,7 +243,7 @@ static int __init bcm47xx_register_bus_complete(void)
 	bcm47xx_leds_register();
 	bcm47xx_workarounds();
 
-	fixed_phy_add(PHY_POLL, 0, &bcm47xx_fixed_phy_status, -1);
+	fixed_phy_add(0, &bcm47xx_fixed_phy_status, -1);
 	return 0;
 }
 device_initcall(bcm47xx_register_bus_complete);
diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 38db2e4..0c8f467 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1460,7 +1460,7 @@ static int bgmac_fixed_phy_register(struct bgmac *bgmac)
 	struct phy_device *phy_dev;
 	int err;
 
-	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
+	phy_dev = fixed_phy_register(&fphy_status, -1, NULL);
 	if (!phy_dev || IS_ERR(phy_dev)) {
 		bgmac_err(bgmac, "Failed to register fixed PHY device\n");
 		return -ENODEV;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 457c3bc..f181fd1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -595,7 +595,7 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 			.asym_pause = 0,
 		};
 
-		phydev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
+		phydev = fixed_phy_register(&fphy_status, -1, NULL);
 		if (!phydev || IS_ERR(phydev)) {
 			dev_err(kdev, "failed to register fixed PHY device\n");
 			return -ENODEV;
diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index fc07a88..295e6bd 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -241,8 +241,7 @@ int fixed_phy_update_state(struct phy_device *phydev,
 }
 EXPORT_SYMBOL(fixed_phy_update_state);
 
-int fixed_phy_add(unsigned int irq, int phy_addr,
-		  struct fixed_phy_status *status,
+int fixed_phy_add(int phy_addr, struct fixed_phy_status *status,
 		  int link_gpio)
 {
 	int ret;
@@ -255,8 +254,6 @@ int fixed_phy_add(unsigned int irq, int phy_addr,
 
 	memset(fp->regs, 0xFF,  sizeof(fp->regs[0]) * MII_REGS_NUM);
 
-	fmb->mii_bus->irq[phy_addr] = irq;
-
 	fp->addr = phy_addr;
 	fp->status = *status;
 	fp->link_gpio = link_gpio;
@@ -304,8 +301,7 @@ static void fixed_phy_del(int phy_addr)
 static int phy_fixed_addr;
 static DEFINE_SPINLOCK(phy_fixed_addr_lock);
 
-struct phy_device *fixed_phy_register(unsigned int irq,
-				      struct fixed_phy_status *status,
+struct phy_device *fixed_phy_register(struct fixed_phy_status *status,
 				      int link_gpio,
 				      struct device_node *np)
 {
@@ -323,7 +319,7 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 	phy_addr = phy_fixed_addr++;
 	spin_unlock(&phy_fixed_addr_lock);
 
-	ret = fixed_phy_add(irq, phy_addr, status, link_gpio);
+	ret = fixed_phy_add(phy_addr, status, link_gpio);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 8453f08..bc4ef2ce 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -411,7 +411,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 	if (err == 0) {
 		if (strcmp(managed, "in-band-status") == 0) {
 			/* status is zeroed, namely its .link member */
-			phy = fixed_phy_register(PHY_POLL, &status, -1, np);
+			phy = fixed_phy_register(&status, -1, np);
 			return PTR_ERR_OR_ZERO(phy);
 		}
 	}
@@ -433,7 +433,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 		if (link_gpio == -EPROBE_DEFER)
 			return -EPROBE_DEFER;
 
-		phy = fixed_phy_register(PHY_POLL, &status, link_gpio, np);
+		phy = fixed_phy_register(&status, link_gpio, np);
 		return PTR_ERR_OR_ZERO(phy);
 	}
 
@@ -445,7 +445,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 		status.speed = be32_to_cpu(fixed_link_prop[2]);
 		status.pause = be32_to_cpu(fixed_link_prop[3]);
 		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
-		phy = fixed_phy_register(PHY_POLL, &status, -1, np);
+		phy = fixed_phy_register(&status, -1, np);
 		return PTR_ERR_OR_ZERO(phy);
 	}
 
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index 1d41ec4..43aca21 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -12,11 +12,9 @@ struct fixed_phy_status {
 struct device_node;
 
 #if IS_ENABLED(CONFIG_FIXED_PHY)
-extern int fixed_phy_add(unsigned int irq, int phy_id,
-			 struct fixed_phy_status *status,
+extern int fixed_phy_add(int phy_id, struct fixed_phy_status *status,
 			 int link_gpio);
-extern struct phy_device *fixed_phy_register(unsigned int irq,
-					     struct fixed_phy_status *status,
+extern struct phy_device *fixed_phy_register(struct fixed_phy_status *status,
 					     int link_gpio,
 					     struct device_node *np);
 extern void fixed_phy_unregister(struct phy_device *phydev);
@@ -27,16 +25,14 @@ extern int fixed_phy_update_state(struct phy_device *phydev,
 			   const struct fixed_phy_status *status,
 			   const struct fixed_phy_status *changed);
 #else
-static inline int fixed_phy_add(unsigned int irq, int phy_id,
-				struct fixed_phy_status *status,
+static inline int fixed_phy_add(int phy_id, struct fixed_phy_status *status,
 				int link_gpio)
 {
 	return -ENODEV;
 }
-static inline struct phy_device *fixed_phy_register(unsigned int irq,
-						struct fixed_phy_status *status,
-						int gpio_link,
-						struct device_node *np)
+static inline struct phy_device *
+fixed_phy_register(struct fixed_phy_status *status, int gpio_link,
+		   struct device_node *np)
 {
 	return ERR_PTR(-ENODEV);
 }
-- 
2.1.4
