From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [net-next] net: qcom/emac: rename emac_phy to emac_sgmii and move it
Date: Fri, 20 Jan 2017 17:21:03 -0600
Message-ID: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46176 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752556AbdATXVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 18:21:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC has an internal PHY that is often called the "SGMII".  This
SGMII is also connected to an external PHY, which is managed by phylib.
These dual PHYs often cause confusion.  In this case, the data structure
for managing the SGMII was mis-named and located in the wrong header file.

Structure emac_phy is renamed to emac_sgmii to clearly indicate it applies
to the internal PHY only.  It also also moved from emac_phy.h (which
supports the external PHY) to emac_sgmii.h (where it belongs).

To keep the changes minimal, only the structure name is changed, not
the names of any variables of that type.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-phy.c           |  2 --
 drivers/net/ethernet/qualcomm/emac/emac-phy.h           | 13 -------------
 drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c |  2 +-
 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c |  2 +-
 drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c |  2 +-
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c         |  8 ++++----
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h         | 13 +++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.c               |  2 +-
 drivers/net/ethernet/qualcomm/emac/emac.h               |  3 ++-
 9 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
index 2851b4c..1d7852f 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -22,8 +22,6 @@
 #include <linux/acpi.h>
 #include "emac.h"
 #include "emac-mac.h"
-#include "emac-phy.h"
-#include "emac-sgmii.h"
 
 /* EMAC base register offsets */
 #define EMAC_MDIO_CTRL                                        0x001414
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.h b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
index 49f3701..c0c301c 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
@@ -13,19 +13,6 @@
 #ifndef _EMAC_PHY_H_
 #define _EMAC_PHY_H_
 
-typedef int (*emac_sgmii_initialize)(struct emac_adapter *adpt);
-
-/** emac_phy - internal emac phy
- * @base base address
- * @digital per-lane digital block
- * @initialize initialization function
- */
-struct emac_phy {
-	void __iomem		*base;
-	void __iomem		*digital;
-	emac_sgmii_initialize	initialize;
-};
-
 struct emac_adapter;
 
 int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
index af690e1..10de8d0 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
@@ -214,7 +214,7 @@ static void emac_reg_write_all(void __iomem *base,
 
 int emac_sgmii_init_fsm9900(struct emac_adapter *adpt)
 {
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	unsigned int i;
 
 	emac_reg_write_all(phy->base, physical_coding_sublayer_programming,
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
index 5b84194..f62c215 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2400.c
@@ -174,7 +174,7 @@ static void emac_reg_write_all(void __iomem *base,
 
 int emac_sgmii_init_qdf2400(struct emac_adapter *adpt)
 {
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	void __iomem *phy_regs = phy->base;
 	void __iomem *laned = phy->digital;
 	unsigned int i;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c
index 6170200..b9c0df7 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-qdf2432.c
@@ -167,7 +167,7 @@ static void emac_reg_write_all(void __iomem *base,
 
 int emac_sgmii_init_qdf2432(struct emac_adapter *adpt)
 {
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	void __iomem *phy_regs = phy->base;
 	void __iomem *laned = phy->digital;
 	unsigned int i;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index bf722a9..0149b52 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -50,7 +50,7 @@
 static int emac_sgmii_link_init(struct emac_adapter *adpt)
 {
 	struct phy_device *phydev = adpt->phydev;
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	u32 val;
 
 	val = readl(phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
@@ -89,7 +89,7 @@ static int emac_sgmii_link_init(struct emac_adapter *adpt)
 
 static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
 {
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	u32 status;
 
 	writel_relaxed(irq_bits, phy->base + EMAC_SGMII_PHY_INTERRUPT_CLEAR);
@@ -123,7 +123,7 @@ static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
 
 static void emac_sgmii_reset_prepare(struct emac_adapter *adpt)
 {
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	u32 val;
 
 	/* Reset PHY */
@@ -217,7 +217,7 @@ static int emac_sgmii_acpi_match(struct device *dev, void *data)
 int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 {
 	struct platform_device *sgmii_pdev = NULL;
-	struct emac_phy *phy = &adpt->phy;
+	struct emac_sgmii *phy = &adpt->phy;
 	struct resource *res;
 	int ret;
 
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
index 80ed3dc..4a8f6b1 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
@@ -16,6 +16,19 @@
 struct emac_adapter;
 struct platform_device;
 
+typedef int (*emac_sgmii_initialize)(struct emac_adapter *adpt);
+
+/** emac_sgmii - internal emac phy
+ * @base base address
+ * @digital per-lane digital block
+ * @initialize initialization function
+ */
+struct emac_sgmii {
+	void __iomem		*base;
+	void __iomem		*digital;
+	emac_sgmii_initialize	initialize;
+};
+
 int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt);
 void emac_sgmii_reset(struct emac_adapter *adpt);
 
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 0aac0de..b74ec7f 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -602,7 +602,7 @@ static int emac_probe(struct platform_device *pdev)
 {
 	struct net_device *netdev;
 	struct emac_adapter *adpt;
-	struct emac_phy *phy;
+	struct emac_sgmii *phy;
 	u16 devid, revid;
 	u32 reg;
 	int ret;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
index 4b8483c..1368440 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -19,6 +19,7 @@
 #include <linux/platform_device.h>
 #include "emac-mac.h"
 #include "emac-phy.h"
+#include "emac-sgmii.h"
 
 /* EMAC base register offsets */
 #define EMAC_DMA_MAS_CTRL                                     0x001400
@@ -291,7 +292,7 @@ struct emac_adapter {
 	void __iomem			*base;
 	void __iomem			*csr;
 
-	struct emac_phy			phy;
+	struct emac_sgmii		phy;
 	struct emac_stats		stats;
 
 	struct emac_irq			irq;
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
