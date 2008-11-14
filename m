From: Santwona.Behera@Sun.COM
Subject: PATCH[1/1] NIU: Add Sun CP3260 ATCA blade support
Date: Fri, 14 Nov 2008 09:21:56 -0800
Message-ID: <491DB3B4.5010805@Sun.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_hSu9Ynimf8sRsUvBVvNY9w)"
Cc: Santwona Behera <Santwona.Behera@Sun.COM>,
	Matheos Worku <Matheos.Worku@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:49307 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbYKNRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 12:22:11 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id mAEHMAaE010219
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 09:22:10 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0KAC004011NEO500@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 14 Nov 2008 09:22:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_hSu9Ynimf8sRsUvBVvNY9w)
Content-type: text/plain; format=flowed; charset=ISO-8859-1
Content-transfer-encoding: 7BIT

This patch adds support for the Sun CP3260 ATCA blade which is
a N2 based ATCA blade with 2 NIU ports. The NIU ports do not
have on-board PHY.

--Boundary_(ID_hSu9Ynimf8sRsUvBVvNY9w)
Content-type: text/x-patch; name=niu-add-Sun-CP3260-support.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=niu-add-Sun-CP3260-support.patch

Signed-off-by: Santwona Behera <santwona.behera@sun.com>
---
 drivers/net/niu.c |  288 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/niu.h |   13 +++
 2 files changed, 295 insertions(+), 6 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index d8463b1..e8fa427 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -406,7 +406,7 @@ static int esr2_set_rx_cfg(struct niu *np, unsigned long channel, u32 val)
 }
 
 /* Mode is always 10G fiber.  */
-static int serdes_init_niu(struct niu *np)
+static int serdes_init_niu_10g_fiber(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
 	u32 tx_cfg, rx_cfg;
@@ -443,6 +443,225 @@ static int serdes_init_niu(struct niu *np)
 	return 0;
 }
 
+static int serdes_init_niu_1g_serdes(struct niu *np)
+{
+	struct niu_link_config *lp = &np->link_config;
+	u32 tx_cfg, rx_cfg;
+	u16 pll_cfg, pll_sts;
+	unsigned long i;
+	int err;
+	u64 sig, mask, val;
+	int max_retry = 100;
+
+	tx_cfg = (PLL_TX_CFG_ENTX | PLL_TX_CFG_SWING_1375MV |
+		  PLL_TX_CFG_RATE_HALF);
+	rx_cfg = (PLL_RX_CFG_ENRX | PLL_RX_CFG_TERM_0P8VDDT |
+		  PLL_RX_CFG_ALIGN_ENA | PLL_RX_CFG_LOS_LTHRESH |
+		  PLL_RX_CFG_RATE_HALF);
+
+	if (np->port == 0)
+		rx_cfg |= PLL_RX_CFG_EQ_LP_ADAPTIVE;
+
+	if (lp->loopback_mode == LOOPBACK_PHY) {
+		u16 test_cfg = PLL_TEST_CFG_LOOPBACK_CML_DIS;
+
+		mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			   ESR2_TI_PLL_TEST_CFG_L, test_cfg);
+
+		tx_cfg |= PLL_TX_CFG_ENTEST;
+		rx_cfg |= PLL_RX_CFG_ENTEST;
+	}
+
+	/* Initialize PLL for 1G */
+	pll_cfg = (PLL_CFG_ENPLL | PLL_CFG_MPY_8X);
+
+	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			 ESR2_TI_PLL_CFG_L, pll_cfg);
+	if (err) {
+		dev_err(np->device, PFX "NIU Port %d "
+			"serdes_init_niu_1g_serdes: "
+			"mdio write to ESR2_TI_PLL_CFG_L failed", np->port);
+		return err;
+	}
+
+	pll_sts = PLL_CFG_ENPLL;
+
+	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			 ESR2_TI_PLL_STS_L, pll_sts);
+	if (err) {
+		dev_err(np->device, PFX "NIU Port %d "
+			"serdes_init_niu_1g_serdes: "
+			"mdio write to ESR2_TI_PLL_STS_L failed", np->port);
+		return err;
+	}
+
+	udelay(200);
+
+	/* Initialize all 4 lanes of the SERDES.  */
+	for (i = 0; i < 4; i++) {
+		err = esr2_set_tx_cfg(np, i, tx_cfg);
+		if (err)
+			return err;
+	}
+
+	for (i = 0; i < 4; i++) {
+		err = esr2_set_rx_cfg(np, i, rx_cfg);
+		if (err)
+			return err;
+	}
+
+	switch (np->port) {
+	case 0:
+		val = (ESR_INT_SRDY0_P0 | ESR_INT_DET0_P0);
+		mask = val;
+		break;
+
+	case 1:
+		val = (ESR_INT_SRDY0_P1 | ESR_INT_DET0_P1);
+		mask = val;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	while (max_retry--) {
+		sig = nr64(ESR_INT_SIGNALS);
+		if ((sig & mask) == val)
+			break;
+
+		mdelay(500);
+	}
+
+	if ((sig & mask) != val) {
+		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
+			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static int serdes_init_niu_10g_serdes(struct niu *np)
+{
+	struct niu_link_config *lp = &np->link_config;
+	u32 tx_cfg, rx_cfg;
+	u32 pll_cfg, pll_sts;
+	unsigned long i;
+	int err;
+	u64 sig, mask, val;
+	int max_retry = 100;
+
+	tx_cfg = (PLL_TX_CFG_ENTX | PLL_TX_CFG_SWING_1375MV);
+	rx_cfg = (PLL_RX_CFG_ENRX | PLL_RX_CFG_TERM_0P8VDDT |
+		  PLL_RX_CFG_ALIGN_ENA | PLL_RX_CFG_LOS_LTHRESH |
+		  PLL_RX_CFG_EQ_LP_ADAPTIVE);
+
+	if (lp->loopback_mode == LOOPBACK_PHY) {
+		u16 test_cfg = PLL_TEST_CFG_LOOPBACK_CML_DIS;
+
+		mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			   ESR2_TI_PLL_TEST_CFG_L, test_cfg);
+
+		tx_cfg |= PLL_TX_CFG_ENTEST;
+		rx_cfg |= PLL_RX_CFG_ENTEST;
+	}
+
+	/* Initialize PLL for 10G */
+	pll_cfg = (PLL_CFG_ENPLL | PLL_CFG_MPY_10X);
+
+	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			 ESR2_TI_PLL_CFG_L, pll_cfg & 0xffff);
+	if (err) {
+		dev_err(np->device, PFX "NIU Port %d "
+			"serdes_init_niu_10g_serdes: "
+			"mdio write to ESR2_TI_PLL_CFG_L failed", np->port);
+		return err;
+	}
+
+	pll_sts = PLL_CFG_ENPLL;
+
+	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
+			 ESR2_TI_PLL_STS_L, pll_sts & 0xffff);
+	if (err) {
+		dev_err(np->device, PFX "NIU Port %d "
+			"serdes_init_niu_10g_serdes: "
+			"mdio write to ESR2_TI_PLL_STS_L failed", np->port);
+		return err;
+	}
+
+	udelay(200);
+
+	/* Initialize all 4 lanes of the SERDES.  */
+	for (i = 0; i < 4; i++) {
+		err = esr2_set_tx_cfg(np, i, tx_cfg);
+		if (err)
+			return err;
+	}
+
+	for (i = 0; i < 4; i++) {
+		err = esr2_set_rx_cfg(np, i, rx_cfg);
+		if (err)
+			return err;
+	}
+
+	/* check if serdes is ready */
+
+	switch (np->port) {
+	case 0:
+		mask = ESR_INT_SIGNALS_P0_BITS;
+		val = (ESR_INT_SRDY0_P0 |
+		       ESR_INT_DET0_P0 |
+		       ESR_INT_XSRDY_P0 |
+		       ESR_INT_XDP_P0_CH3 |
+		       ESR_INT_XDP_P0_CH2 |
+		       ESR_INT_XDP_P0_CH1 |
+		       ESR_INT_XDP_P0_CH0);
+		break;
+
+	case 1:
+		mask = ESR_INT_SIGNALS_P1_BITS;
+		val = (ESR_INT_SRDY0_P1 |
+		       ESR_INT_DET0_P1 |
+		       ESR_INT_XSRDY_P1 |
+		       ESR_INT_XDP_P1_CH3 |
+		       ESR_INT_XDP_P1_CH2 |
+		       ESR_INT_XDP_P1_CH1 |
+		       ESR_INT_XDP_P1_CH0);
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	while (max_retry--) {
+		sig = nr64(ESR_INT_SIGNALS);
+		if ((sig & mask) == val)
+			break;
+
+		mdelay(500);
+	}
+
+	if ((sig & mask) != val) {
+
+		pr_info(PFX "NIU Port %u signal bits [%08x] are not "
+			"[%08x] for 10G...trying 1G\n",
+			np->port, (int) (sig & mask), (int) val);
+
+		/* 10G failed, try initializing at 1G */
+		err = serdes_init_niu_1g_serdes(np);
+		if (!err) {
+			np->flags &= ~NIU_FLAGS_10G;
+			np->mac_xcvr = MAC_XCVR_PCS;
+		}  else {
+			dev_err(np->device, PFX "Port %u 10G/1G SERDES "
+				"Link Failed \n", np->port);
+			return -ENODEV;
+		}
+	}
+	return 0;
+}
+
 static int esr_read_rxtx_ctrl(struct niu *np, unsigned long chan, u32 *val)
 {
 	int err;
@@ -1954,13 +2173,23 @@ static const struct niu_phy_ops phy_ops_10g_serdes = {
 	.link_status		= link_status_10g_serdes,
 };
 
+static const struct niu_phy_ops phy_ops_10g_serdes_niu = {
+	.serdes_init		= serdes_init_niu_10g_serdes,
+	.link_status		= link_status_10g_serdes,
+};
+
+static const struct niu_phy_ops phy_ops_1g_serdes_niu = {
+	.serdes_init		= serdes_init_niu_1g_serdes,
+	.link_status		= link_status_1g_serdes,
+};
+
 static const struct niu_phy_ops phy_ops_1g_rgmii = {
 	.xcvr_init		= xcvr_init_1g_rgmii,
 	.link_status		= link_status_1g_rgmii,
 };
 
 static const struct niu_phy_ops phy_ops_10g_fiber_niu = {
-	.serdes_init		= serdes_init_niu,
+	.serdes_init		= serdes_init_niu_10g_fiber,
 	.xcvr_init		= xcvr_init_10g,
 	.link_status		= link_status_10g,
 };
@@ -1998,11 +2227,21 @@ struct niu_phy_template {
 	u32				phy_addr_base;
 };
 
-static const struct niu_phy_template phy_template_niu = {
+static const struct niu_phy_template phy_template_niu_10g_fiber = {
 	.ops		= &phy_ops_10g_fiber_niu,
 	.phy_addr_base	= 16,
 };
 
+static const struct niu_phy_template phy_template_niu_10g_serdes = {
+	.ops		= &phy_ops_10g_serdes_niu,
+	.phy_addr_base	= 0,
+};
+
+static const struct niu_phy_template phy_template_niu_1g_serdes = {
+	.ops		= &phy_ops_1g_serdes_niu,
+	.phy_addr_base	= 0,
+};
+
 static const struct niu_phy_template phy_template_10g_fiber = {
 	.ops		= &phy_ops_10g_fiber,
 	.phy_addr_base	= 8,
@@ -2182,8 +2421,25 @@ static int niu_determine_phy_disposition(struct niu *np)
 	u32 phy_addr_off = 0;
 
 	if (plat_type == PLAT_TYPE_NIU) {
-		tp = &phy_template_niu;
-		phy_addr_off += np->port;
+		switch (np->flags &
+			(NIU_FLAGS_10G |
+			 NIU_FLAGS_FIBER |
+			 NIU_FLAGS_XCVR_SERDES)) {
+		case NIU_FLAGS_10G | NIU_FLAGS_XCVR_SERDES:
+			/* 10G Serdes */
+			tp = &phy_template_niu_10g_serdes;
+		      break;
+		case NIU_FLAGS_XCVR_SERDES:
+			/* 1G Serdes */
+			tp = &phy_template_niu_1g_serdes;
+		      break;
+		case NIU_FLAGS_10G | NIU_FLAGS_FIBER:
+			/* 10G Fiber */
+		default:
+			tp = &phy_template_niu_10g_fiber;
+			phy_addr_off += np->port;
+			break;
+		}
 	} else {
 		switch (np->flags &
 			(NIU_FLAGS_10G |
@@ -7213,6 +7469,12 @@ static int __devinit niu_phy_type_prop_decode(struct niu *np,
 		np->flags |= NIU_FLAGS_10G;
 		np->flags &= ~NIU_FLAGS_FIBER;
 		np->mac_xcvr = MAC_XCVR_XPCS;
+	} else if (!strcmp(phy_prop, "xgsd") || !strcmp(phy_prop, "gsd")) {
+		/* 10G Serdes or 1G Serdes, default to 10G */
+		np->flags |= NIU_FLAGS_10G;
+		np->flags &= ~NIU_FLAGS_FIBER;
+		np->flags |= NIU_FLAGS_XCVR_SERDES;
+		np->mac_xcvr = MAC_XCVR_XPCS;
 	} else {
 		return -EINVAL;
 	}
@@ -7741,6 +8003,8 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 	u32 val;
 	int err;
 
+	num_10g = num_1g = 0;
+
 	if (!strcmp(np->vpd.model, NIU_ALONSO_MDL_STR) ||
 	    !strcmp(np->vpd.model, NIU_KIMI_MDL_STR)) {
 		num_10g = 0;
@@ -7757,6 +8021,16 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 		parent->num_ports = 2;
 		val = (phy_encode(PORT_TYPE_10G, 0) |
 		       phy_encode(PORT_TYPE_10G, 1));
+	} else if ((np->flags & NIU_FLAGS_XCVR_SERDES) &&
+		   (parent->plat_type == PLAT_TYPE_NIU)) {
+		/* this is the Monza case */
+		if (np->flags & NIU_FLAGS_10G) {
+			val = (phy_encode(PORT_TYPE_10G, 0) |
+			       phy_encode(PORT_TYPE_10G, 1));
+		} else {
+			val = (phy_encode(PORT_TYPE_1G, 0) |
+			       phy_encode(PORT_TYPE_1G, 1));
+		}
 	} else {
 		err = fill_phy_probe_info(np, parent, info);
 		if (err)
@@ -8656,7 +8930,9 @@ static void __devinit niu_device_announce(struct niu *np)
 				dev->name,
 				(np->flags & NIU_FLAGS_XMAC ? "XMAC" : "BMAC"),
 				(np->flags & NIU_FLAGS_10G ? "10G" : "1G"),
-				(np->flags & NIU_FLAGS_FIBER ? "FIBER" : "COPPER"),
+				(np->flags & NIU_FLAGS_FIBER ? "FIBER" :
+				 (np->flags & NIU_FLAGS_XCVR_SERDES ? "SERDES" :
+				  "COPPER")),
 				(np->mac_xcvr == MAC_XCVR_MII ? "MII" :
 				 (np->mac_xcvr == MAC_XCVR_PCS ? "PCS" : "XPCS")),
 				np->vpd.phy_type);
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index c6fa883..180ca8a 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -1048,6 +1048,13 @@
 #define  PLL_CFG_LD_SHIFT		8
 #define  PLL_CFG_MPY			0x0000001e
 #define  PLL_CFG_MPY_SHIFT		1
+#define  PLL_CFG_MPY_4X		0x0
+#define  PLL_CFG_MPY_5X		0x00000002
+#define  PLL_CFG_MPY_6X		0x00000004
+#define  PLL_CFG_MPY_8X		0x00000008
+#define  PLL_CFG_MPY_10X		0x0000000a
+#define  PLL_CFG_MPY_12X		0x0000000c
+#define  PLL_CFG_MPY_12P5X		0x0000000e
 #define  PLL_CFG_ENPLL			0x00000001
 
 #define ESR2_TI_PLL_STS_L		(ESR2_BASE + 0x002)
@@ -1093,6 +1100,9 @@
 #define  PLL_TX_CFG_INVPAIR		0x00000080
 #define  PLL_TX_CFG_RATE		0x00000060
 #define  PLL_TX_CFG_RATE_SHIFT		5
+#define  PLL_TX_CFG_RATE_FULL		0x0
+#define  PLL_TX_CFG_RATE_HALF		0x20
+#define  PLL_TX_CFG_RATE_QUAD		0x40
 #define  PLL_TX_CFG_BUSWIDTH		0x0000001c
 #define  PLL_TX_CFG_BUSWIDTH_SHIFT	2
 #define  PLL_TX_CFG_ENTEST		0x00000002
@@ -1132,6 +1142,9 @@
 #define  PLL_RX_CFG_INVPAIR		0x00000080
 #define  PLL_RX_CFG_RATE		0x00000060
 #define  PLL_RX_CFG_RATE_SHIFT		5
+#define  PLL_RX_CFG_RATE_FULL		0x0
+#define  PLL_RX_CFG_RATE_HALF		0x20
+#define  PLL_RX_CFG_RATE_QUAD		0x40
 #define  PLL_RX_CFG_BUSWIDTH		0x0000001c
 #define  PLL_RX_CFG_BUSWIDTH_SHIFT	2
 #define  PLL_RX_CFG_ENTEST		0x00000002
-- 
1.6.0.4


--Boundary_(ID_hSu9Ynimf8sRsUvBVvNY9w)--
