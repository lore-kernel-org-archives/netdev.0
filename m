From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 8/9] phy: fixed_phy: Add gpio to determine link up/down.
Date: Sun, 23 Aug 2015 11:46:59 +0200
Message-ID: <1440323220-20438-9-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38065 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbbHWJyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:54:38 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An SFP module may have a link up/down status pin which can be
connection to a GPIO line of the host. Add support for reading such an
GPIO in the fixed_phy driver.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 .../devicetree/bindings/net/fixed-link.txt         | 14 +++++++++++-
 Documentation/networking/stmmac.txt                |  2 +-
 arch/m68k/coldfire/m5272.c                         |  2 +-
 arch/mips/ar7/platform.c                           |  5 +++--
 arch/mips/bcm47xx/setup.c                          |  2 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  2 +-
 drivers/net/phy/fixed_phy.c                        | 26 +++++++++++++++++++---
 drivers/of/of_mdio.c                               | 13 ++++++++---
 include/linux/phy_fixed.h                          |  8 +++++--
 9 files changed, 59 insertions(+), 15 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
index 82bf7e0f47b6..ec5d889fe3d8 100644
--- a/Documentation/devicetree/bindings/net/fixed-link.txt
+++ b/Documentation/devicetree/bindings/net/fixed-link.txt
@@ -17,6 +17,8 @@ properties:
   enabled.
 * 'asym-pause' (boolean, optional), to indicate that asym_pause should
   be enabled.
+* 'link-gpios' ('gpio-list', optional), to indicate if a gpio can be read
+  to determine if the link is up.
 
 Old, deprecated 'fixed-link' binding:
 
@@ -30,7 +32,7 @@ Old, deprecated 'fixed-link' binding:
   - e: asymmetric pause configuration: 0 for no asymmetric pause, 1 for
     asymmetric pause
 
-Example:
+Examples:
 
 ethernet@0 {
 	...
@@ -40,3 +42,13 @@ ethernet@0 {
 	};
 	...
 };
+
+ethernet@1 {
+	...
+	fixed-link {
+	      speed = <1000>;
+	      pause;
+	      link-gpios = <&gpio0 12 GPIO_ACTIVE_HIGH>;
+	};
+	...
+};
diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 2903b1cf4d70..d64a14714236 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -254,7 +254,7 @@ static struct fixed_phy_status stmmac0_fixed_phy_status = {
 
 During the board's device_init we can configure the first
 MAC for fixed_link by calling:
-  fixed_phy_add(PHY_POLL, 1, &stmmac0_fixed_phy_status));)
+  fixed_phy_add(PHY_POLL, 1, &stmmac0_fixed_phy_status, -1);
 and the second one, with a real PHY device attached to the bus,
 by using the stmmac_mdio_bus_data structure (to provide the id, the
 reset procedure etc).
diff --git a/arch/m68k/coldfire/m5272.c b/arch/m68k/coldfire/m5272.c
index b15219ed22bf..c525e4c08f84 100644
--- a/arch/m68k/coldfire/m5272.c
+++ b/arch/m68k/coldfire/m5272.c
@@ -126,7 +126,7 @@ static struct fixed_phy_status nettel_fixed_phy_status __initdata = {
 static int __init init_BSP(void)
 {
 	m5272_uarts_init();
-	fixed_phy_add(PHY_POLL, 0, &nettel_fixed_phy_status);
+	fixed_phy_add(PHY_POLL, 0, &nettel_fixed_phy_status, -1);
 	return 0;
 }
 
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index be9ff1673ded..298b97715d5f 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -679,7 +679,8 @@ static int __init ar7_register_devices(void)
 	}
 
 	if (ar7_has_high_cpmac()) {
-		res = fixed_phy_add(PHY_POLL, cpmac_high.id, &fixed_phy_status);
+		res = fixed_phy_add(PHY_POLL, cpmac_high.id,
+				    &fixed_phy_status, -1);
 		if (!res) {
 			cpmac_get_mac(1, cpmac_high_data.dev_addr);
 
@@ -692,7 +693,7 @@ static int __init ar7_register_devices(void)
 	} else
 		cpmac_low_data.phy_mask = 0xffffffff;
 
-	res = fixed_phy_add(PHY_POLL, cpmac_low.id, &fixed_phy_status);
+	res = fixed_phy_add(PHY_POLL, cpmac_low.id, &fixed_phy_status, -1);
 	if (!res) {
 		cpmac_get_mac(0, cpmac_low_data.dev_addr);
 		res = platform_device_register(&cpmac_low);
diff --git a/arch/mips/bcm47xx/setup.c b/arch/mips/bcm47xx/setup.c
index 98c075f81795..17503a05938e 100644
--- a/arch/mips/bcm47xx/setup.c
+++ b/arch/mips/bcm47xx/setup.c
@@ -263,7 +263,7 @@ static int __init bcm47xx_register_bus_complete(void)
 	bcm47xx_leds_register();
 	bcm47xx_workarounds();
 
-	fixed_phy_add(PHY_POLL, 0, &bcm47xx_fixed_phy_status);
+	fixed_phy_add(PHY_POLL, 0, &bcm47xx_fixed_phy_status, -1);
 	return 0;
 }
 device_initcall(bcm47xx_register_bus_complete);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index b3679ad1c1c7..c8affad76f36 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -585,7 +585,7 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 			.asym_pause = 0,
 		};
 
-		phydev = fixed_phy_register(PHY_POLL, &fphy_status, NULL);
+		phydev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
 		if (!phydev || IS_ERR(phydev)) {
 			dev_err(kdev, "failed to register fixed PHY device\n");
 			return -ENODEV;
diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 7244336dee7a..14ab80899e77 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -22,6 +22,7 @@
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/of.h>
+#include <linux/gpio.h>
 
 #define MII_REGS_NUM 29
 
@@ -38,6 +39,7 @@ struct fixed_phy {
 	struct fixed_phy_status status;
 	int (*link_update)(struct net_device *, struct fixed_phy_status *);
 	struct list_head node;
+	int link_gpio;
 };
 
 static struct platform_device *pdev;
@@ -52,6 +54,9 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 	u16 lpagb = 0;
 	u16 lpa = 0;
 
+	if (gpio_is_valid(fp->link_gpio))
+		fp->status.link = !!gpio_get_value_cansleep(fp->link_gpio);
+
 	if (!fp->status.link)
 		goto done;
 	bmsr |= BMSR_LSTATUS | BMSR_ANEGCOMPLETE;
@@ -215,7 +220,8 @@ int fixed_phy_update_state(struct phy_device *phydev,
 EXPORT_SYMBOL(fixed_phy_update_state);
 
 int fixed_phy_add(unsigned int irq, int phy_addr,
-		  struct fixed_phy_status *status)
+		  struct fixed_phy_status *status,
+		  int link_gpio)
 {
 	int ret;
 	struct fixed_mdio_bus *fmb = &platform_fmb;
@@ -231,15 +237,26 @@ int fixed_phy_add(unsigned int irq, int phy_addr,
 
 	fp->addr = phy_addr;
 	fp->status = *status;
+	fp->link_gpio = link_gpio;
+
+	if (gpio_is_valid(fp->link_gpio)) {
+		ret = gpio_request_one(fp->link_gpio, GPIOF_DIR_IN,
+				       "fixed-link-gpio-link");
+		if (ret)
+			goto err_regs;
+	}
 
 	ret = fixed_phy_update_regs(fp);
 	if (ret)
-		goto err_regs;
+		goto err_gpio;
 
 	list_add_tail(&fp->node, &fmb->phys);
 
 	return 0;
 
+err_gpio:
+	if (gpio_is_valid(fp->link_gpio))
+		gpio_free(fp->link_gpio);
 err_regs:
 	kfree(fp);
 	return ret;
@@ -254,6 +271,8 @@ void fixed_phy_del(int phy_addr)
 	list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
 		if (fp->addr == phy_addr) {
 			list_del(&fp->node);
+			if (gpio_is_valid(fp->link_gpio))
+				gpio_free(fp->link_gpio);
 			kfree(fp);
 			return;
 		}
@@ -266,6 +285,7 @@ static DEFINE_SPINLOCK(phy_fixed_addr_lock);
 
 struct phy_device *fixed_phy_register(unsigned int irq,
 				      struct fixed_phy_status *status,
+				      int link_gpio,
 				      struct device_node *np)
 {
 	struct fixed_mdio_bus *fmb = &platform_fmb;
@@ -282,7 +302,7 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 	phy_addr = phy_fixed_addr++;
 	spin_unlock(&phy_fixed_addr_lock);
 
-	ret = fixed_phy_add(PHY_POLL, phy_addr, status);
+	ret = fixed_phy_add(PHY_POLL, phy_addr, status, link_gpio);
 	if (ret < 0)
 		return ERR_PTR(ret);
 
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 7c8c23cc6896..1350fa25cdb0 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -16,6 +16,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/of.h>
+#include <linux/of_gpio.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
 #include <linux/module.h>
@@ -294,6 +295,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 	struct fixed_phy_status status = {};
 	struct device_node *fixed_link_node;
 	const __be32 *fixed_link_prop;
+	int link_gpio;
 	int len, err;
 	struct phy_device *phy;
 	const char *managed;
@@ -302,7 +304,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 	if (err == 0) {
 		if (strcmp(managed, "in-band-status") == 0) {
 			/* status is zeroed, namely its .link member */
-			phy = fixed_phy_register(PHY_POLL, &status, np);
+			phy = fixed_phy_register(PHY_POLL, &status, -1, np);
 			return IS_ERR(phy) ? PTR_ERR(phy) : 0;
 		}
 	}
@@ -318,8 +320,13 @@ int of_phy_register_fixed_link(struct device_node *np)
 		status.pause = of_property_read_bool(fixed_link_node, "pause");
 		status.asym_pause = of_property_read_bool(fixed_link_node,
 							  "asym-pause");
+		link_gpio = of_get_named_gpio_flags(fixed_link_node,
+						    "link-gpios", 0, NULL);
 		of_node_put(fixed_link_node);
-		phy = fixed_phy_register(PHY_POLL, &status, np);
+		if (link_gpio == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+
+		phy = fixed_phy_register(PHY_POLL, &status, link_gpio, np);
 		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
 	}
 
@@ -331,7 +338,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 		status.speed = be32_to_cpu(fixed_link_prop[2]);
 		status.pause = be32_to_cpu(fixed_link_prop[3]);
 		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
-		phy = fixed_phy_register(PHY_POLL, &status, np);
+		phy = fixed_phy_register(PHY_POLL, &status, -1, np);
 		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
 	}
 
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index fe5732d53eda..2400d2ea4f34 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -13,9 +13,11 @@ struct device_node;
 
 #if IS_ENABLED(CONFIG_FIXED_PHY)
 extern int fixed_phy_add(unsigned int irq, int phy_id,
-			 struct fixed_phy_status *status);
+			 struct fixed_phy_status *status,
+			 int link_gpio);
 extern struct phy_device *fixed_phy_register(unsigned int irq,
 					     struct fixed_phy_status *status,
+					     int link_gpio,
 					     struct device_node *np);
 extern void fixed_phy_del(int phy_addr);
 extern int fixed_phy_set_link_update(struct phy_device *phydev,
@@ -26,12 +28,14 @@ extern int fixed_phy_update_state(struct phy_device *phydev,
 			   const struct fixed_phy_status *changed);
 #else
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
-				struct fixed_phy_status *status)
+				struct fixed_phy_status *status,
+				int link_gpio)
 {
 	return -ENODEV;
 }
 static inline struct phy_device *fixed_phy_register(unsigned int irq,
 						struct fixed_phy_status *status,
+						int gpio_link,
 						struct device_node *np)
 {
 	return ERR_PTR(-ENODEV);
-- 
2.5.0
