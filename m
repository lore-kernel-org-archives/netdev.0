From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 06/12] net: dsa: b53: Move Broadcom header setup to b53
Date: Tue, 19 Sep 2017 10:46:48 -0700
Message-ID: <20170919174654.2122-7-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34242 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdISRrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id i131so319973wma.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:18 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code to enable Broadcom tags/headers is largely switch independent,
and in preparation for enabling it for multiple devices with b53, move
the code we have in bcm_sf2.c to b53_common.c

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 47 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  1 +
 drivers/net/dsa/b53/b53_regs.h   |  7 ++++++
 drivers/net/dsa/bcm_sf2.c        | 43 ++----------------------------------
 drivers/net/dsa/bcm_sf2_regs.h   |  8 -------
 5 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 3297af6aab8a..aa2187c71ea5 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -538,6 +538,53 @@ static void b53_disable_port(struct dsa_switch *ds, int port,
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
 
+void b53_brcm_hdr_setup(struct dsa_switch *ds, int port)
+{
+	struct b53_device *dev = ds->priv;
+	u8 hdr_ctl, val;
+	u16 reg;
+
+	/* Resolve which bit controls the Broadcom tag */
+	switch (port) {
+	case 8:
+		val = BRCM_HDR_P8_EN;
+		break;
+	case 7:
+		val = BRCM_HDR_P7_EN;
+		break;
+	case 5:
+		val = BRCM_HDR_P5_EN;
+		break;
+	default:
+		val = 0;
+		break;
+	}
+
+	/* Enable Broadcom tags for IMP port */
+	b53_read8(dev, B53_MGMT_PAGE, B53_BRCM_HDR, &hdr_ctl);
+	hdr_ctl |= val;
+	b53_write8(dev, B53_MGMT_PAGE, B53_BRCM_HDR, hdr_ctl);
+
+	/* Registers below are only accessible on newer devices */
+	if (!is58xx(dev))
+		return;
+
+	/* Enable reception Broadcom tag for CPU TX (switch RX) to
+	 * allow us to tag outgoing frames
+	 */
+	b53_read16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_RX_DIS, &reg);
+	reg &= ~BIT(port);
+	b53_write16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_RX_DIS, reg);
+
+	/* Enable transmission of Broadcom tags from the switch (CPU RX) to
+	 * allow delivering frames to the per-port net_devices
+	 */
+	b53_read16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_TX_DIS, &reg);
+	reg &= ~BIT(port);
+	b53_write16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_TX_DIS, reg);
+}
+EXPORT_SYMBOL(b53_brcm_hdr_setup);
+
 static void b53_enable_cpu_port(struct b53_device *dev, int port)
 {
 	u8 port_ctrl;
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 5bebe97900e8..77102f685da0 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -309,5 +309,6 @@ int b53_mirror_add(struct dsa_switch *ds, int port,
 		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
 void b53_mirror_del(struct dsa_switch *ds, int port,
 		    struct dsa_mall_mirror_tc_entry *mirror);
+void b53_brcm_hdr_setup(struct dsa_switch *ds, int port);
 
 #endif
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index e5c86d44667a..5e8b8e31fee8 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -210,6 +210,7 @@
 #define B53_BRCM_HDR			0x03
 #define   BRCM_HDR_P8_EN		BIT(0) /* Enable tagging on port 8 */
 #define   BRCM_HDR_P5_EN		BIT(1) /* Enable tagging on port 5 */
+#define   BRCM_HDR_P7_EN		BIT(2) /* Enable tagging on port 7 */
 
 /* Mirror capture control register (16 bit) */
 #define B53_MIR_CAP_CTL			0x10
@@ -249,6 +250,12 @@
 /* Revision ID register (8 bit) */
 #define B53_REV_ID			0x40
 
+/* Broadcom header RX control (16 bit) */
+#define B53_BRCM_HDR_RX_DIS		0x60
+
+/* Broadcom header TX control (16 bit)	*/
+#define B53_BRCM_HDR_TX_DIS		0x62
+
 /*************************************************************************
  * ARL Access Page Registers
  *************************************************************************/
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8acbd17bc1fd..49cb51223f70 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -60,45 +60,6 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 	}
 }
 
-static void bcm_sf2_brcm_hdr_setup(struct bcm_sf2_priv *priv, int port)
-{
-	u32 reg, val;
-
-	/* Resolve which bit controls the Broadcom tag */
-	switch (port) {
-	case 8:
-		val = BRCM_HDR_EN_P8;
-		break;
-	case 7:
-		val = BRCM_HDR_EN_P7;
-		break;
-	case 5:
-		val = BRCM_HDR_EN_P5;
-		break;
-	default:
-		val = 0;
-		break;
-	}
-
-	/* Enable Broadcom tags for IMP port */
-	reg = core_readl(priv, CORE_BRCM_HDR_CTRL);
-	reg |= val;
-	core_writel(priv, reg, CORE_BRCM_HDR_CTRL);
-
-	/* Enable reception Broadcom tag for CPU TX (switch RX) to
-	 * allow us to tag outgoing frames
-	 */
-	reg = core_readl(priv, CORE_BRCM_HDR_RX_DIS);
-	reg &= ~(1 << port);
-	core_writel(priv, reg, CORE_BRCM_HDR_RX_DIS);
-
-	/* Enable transmission of Broadcom tags from the switch (CPU RX) to
-	 * allow delivering frames to the per-port net_devices
-	 */
-	reg = core_readl(priv, CORE_BRCM_HDR_TX_DIS);
-	reg &= ~(1 << port);
-	core_writel(priv, reg, CORE_BRCM_HDR_TX_DIS);
-}
 
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
@@ -138,7 +99,7 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 		reg |= i << (PRT_TO_QID_SHIFT * i);
 	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
 
-	bcm_sf2_brcm_hdr_setup(priv, port);
+	b53_brcm_hdr_setup(ds, port);
 
 	/* Force link status for IMP port */
 	reg = core_readl(priv, offset);
@@ -247,7 +208,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 
 	/* Enable Broadcom tags for that port if requested */
 	if (priv->brcm_tag_mask & BIT(port))
-		bcm_sf2_brcm_hdr_setup(priv, port);
+		b53_brcm_hdr_setup(ds, port);
 
 	/* Configure Traffic Class to QoS mapping, allow each priority to map
 	 * to a different queue number
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 49695fcc2ea8..788361ad68a0 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -205,16 +205,8 @@ enum bcm_sf2_reg_offs {
 
 #define CORE_IMP0_PRT_ID		0x0804
 
-#define CORE_BRCM_HDR_CTRL		0x0080c
-#define  BRCM_HDR_EN_P8			(1 << 0)
-#define  BRCM_HDR_EN_P5			(1 << 1)
-#define  BRCM_HDR_EN_P7			(1 << 2)
-
 #define CORE_RST_MIB_CNT_EN		0x0950
 
-#define CORE_BRCM_HDR_RX_DIS		0x0980
-#define CORE_BRCM_HDR_TX_DIS		0x0988
-
 #define CORE_ARLA_VTBL_RWCTRL		0x1600
 #define  ARLA_VTBL_CMD_WRITE		0
 #define  ARLA_VTBL_CMD_READ		1
-- 
2.9.3
