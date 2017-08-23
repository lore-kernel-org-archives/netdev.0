From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v3] net: stmmac: Delete dead code for MDIO registration
Date: Wed, 23 Aug 2017 10:50:58 +0200
Message-ID: <20170823085058.23333-1-romain.perier@collabora.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is no longer used, the logging function was changed by commit
fbca164776e4 ("net: stmmac: Use the right logging functi"). It was
previously showing information about the type if the IRQ, if it's polled,
ignored or a normal interrupt. As we don't want information loss, I have
moved this code to phy_attached_print().

Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")
Signed-off-by: Romain Perier <romain.perier@collabora.com>
---

Hello,

This is the continuity of "[PATCH v2 0/2] net: stmmac: phy logging fixes",
see https://lkml.org/lkml/2017/8/21/288

Changes in v3:
- Removed patch 2/2: "net: phy: Don't use drv when it is NULL in phy_attached_print",
  fixed upstream by fcd03e362b1c
  ("net: phy: Deal with unbound PHY driver in phy_attached_print()")
- Moved this code to phy_attached_print(), so we have more informations
  about the IRQ (poll, ignore or normal irq) and no information are loss.
- Re-worded commit message

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 16 ----------------
 drivers/net/phy/phy_device.c                      | 21 ++++++++++++++++++---
 2 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 72ec711fcba2..f5f37bfa1d58 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -248,9 +248,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 	found = 0;
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
-		int act = 0;
-		char irq_num[4];
-		char *irq_str;
 
 		if (!phydev)
 			continue;
@@ -273,19 +270,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 		if (priv->plat->phy_addr == -1)
 			priv->plat->phy_addr = addr;
 
-		act = (priv->plat->phy_addr == addr);
-		switch (phydev->irq) {
-		case PHY_POLL:
-			irq_str = "POLL";
-			break;
-		case PHY_IGNORE_INTERRUPT:
-			irq_str = "IGNORE";
-			break;
-		default:
-			sprintf(irq_num, "%d", phydev->irq);
-			irq_str = irq_num;
-			break;
-		}
 		phy_attached_info(phydev);
 		found = 1;
 	}
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 810f6fd2f639..a3ba51808b1a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -874,21 +874,36 @@ void phy_attached_info(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_attached_info);
 
-#define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)"
+#define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%s)"
 void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
 {
 	const char *drv_name = phydev->drv ? phydev->drv->name : "unbound";
+	char *irq_str;
+	char irq_num[4];
+
+	switch(phydev->irq) {
+	case PHY_POLL:
+		irq_str = "POLL";
+		break;
+	case PHY_IGNORE_INTERRUPT:
+		irq_str = "IGNORE";
+		break;
+	default:
+		snprintf(irq_num, sizeof(irq_str), "%d", phydev->irq);
+		irq_str = irq_num;
+		break;
+	}
 
 	if (!fmt) {
 		dev_info(&phydev->mdio.dev, ATTACHED_FMT "\n",
 			 drv_name, phydev_name(phydev),
-			 phydev->irq);
+			 irq_str);
 	} else {
 		va_list ap;
 
 		dev_info(&phydev->mdio.dev, ATTACHED_FMT,
 			 drv_name, phydev_name(phydev),
-			 phydev->irq);
+			 irq_str);
 
 		va_start(ap, fmt);
 		vprintk(fmt, ap);
-- 
2.11.0
