From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [NIU] Add support for Neptune FEM/NEM cards for
 C10 server blades
Date: Thu, 24 Apr 2008 21:10:09 -0700 (PDT)
Message-ID: <20080424.211009.161855006.davem@davemloft.net>
References: <200804231812.m3NICPCL047978@sr1-umpk-33.sfbay.sun.com>
	<20080423.183022.52374157.davem@davemloft.net>
	<4810E383.9040506@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbYDYEKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 00:10:11 -0400
In-Reply-To: <4810E383.9040506@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 24 Apr 2008 12:46:11 -0700

> New patch attached.

Thanks a lot.

I made minor coding style fixups and also bumped the driver
version and release date when I checked this in.  Here is
the exact patch I committed below.

Thanks again!

niu: Add support for Neptune FEM/NEM cards for C10 server blades

[ Minor coding style and whitespace corrections, also bump
  driver version and release date. -DaveM ]

Signed-off-by: Matheos Worku <matheos.worku@sun.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index c7c173c..4009c4c 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -33,8 +33,8 @@
 
 #define DRV_MODULE_NAME		"niu"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.7"
-#define DRV_MODULE_RELDATE	"February 18, 2008"
+#define DRV_MODULE_VERSION	"0.8"
+#define DRV_MODULE_RELDATE	"April 24, 2008"
 
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
@@ -673,11 +673,16 @@ static int serdes_init_10g(struct niu *np)
 	}
 
 	if ((sig & mask) != val) {
+		if (np->flags & NIU_FLAGS_HOTPLUG_PHY) {
+			np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
+			return 0;
+		}
 		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
 			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
 		return -ENODEV;
 	}
-
+	if (np->flags & NIU_FLAGS_HOTPLUG_PHY)
+		np->flags |= NIU_FLAGS_HOTPLUG_PHY_PRESENT;
 	return 0;
 }
 
@@ -998,6 +1003,28 @@ static int bcm8704_user_dev3_readback(struct niu *np, int reg)
 	return 0;
 }
 
+static int bcm8706_init_user_dev3(struct niu *np)
+{
+	int err;
+
+
+	err = mdio_read(np, np->phy_addr, BCM8704_USER_DEV3_ADDR,
+			BCM8704_USER_OPT_DIGITAL_CTRL);
+	if (err < 0)
+		return err;
+	err &= ~USER_ODIG_CTRL_GPIOS;
+	err |= (0x3 << USER_ODIG_CTRL_GPIOS_SHIFT);
+	err |=  USER_ODIG_CTRL_RESV2;
+	err = mdio_write(np, np->phy_addr, BCM8704_USER_DEV3_ADDR,
+			 BCM8704_USER_OPT_DIGITAL_CTRL, err);
+	if (err)
+		return err;
+
+	mdelay(1000);
+
+	return 0;
+}
+
 static int bcm8704_init_user_dev3(struct niu *np)
 {
 	int err;
@@ -1127,33 +1154,11 @@ static int xcvr_init_10g_mrvl88x2011(struct niu *np)
 			  MRVL88X2011_10G_PMD_TX_DIS, MRVL88X2011_ENA_PMDTX);
 }
 
-static int xcvr_init_10g_bcm8704(struct niu *np)
+
+static int xcvr_diag_bcm870x(struct niu *np)
 {
-	struct niu_link_config *lp = &np->link_config;
 	u16 analog_stat0, tx_alarm_status;
-	int err;
-
-	err = bcm8704_reset(np);
-	if (err)
-		return err;
-
-	err = bcm8704_init_user_dev3(np);
-	if (err)
-		return err;
-
-	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
-			MII_BMCR);
-	if (err < 0)
-		return err;
-	err &= ~BMCR_LOOPBACK;
-
-	if (lp->loopback_mode == LOOPBACK_MAC)
-		err |= BMCR_LOOPBACK;
-
-	err = mdio_write(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
-			 MII_BMCR, err);
-	if (err)
-		return err;
+	int err = 0;
 
 #if 1
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
@@ -1211,6 +1216,89 @@ static int xcvr_init_10g_bcm8704(struct niu *np)
 	return 0;
 }
 
+static int xcvr_10g_set_lb_bcm870x(struct niu *np)
+{
+	struct niu_link_config *lp = &np->link_config;
+	int err;
+
+	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
+			MII_BMCR);
+	if (err < 0)
+		return err;
+
+	err &= ~BMCR_LOOPBACK;
+
+	if (lp->loopback_mode == LOOPBACK_MAC)
+		err |= BMCR_LOOPBACK;
+
+	err = mdio_write(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
+			 MII_BMCR, err);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static int xcvr_init_10g_bcm8706(struct niu *np)
+{
+	int err = 0;
+	u64 val;
+
+	if ((np->flags & NIU_FLAGS_HOTPLUG_PHY) &&
+	    (np->flags & NIU_FLAGS_HOTPLUG_PHY_PRESENT) == 0)
+			return err;
+
+	val = nr64_mac(XMAC_CONFIG);
+	val &= ~XMAC_CONFIG_LED_POLARITY;
+	val |= XMAC_CONFIG_FORCE_LED_ON;
+	nw64_mac(XMAC_CONFIG, val);
+
+	val = nr64(MIF_CONFIG);
+	val |= MIF_CONFIG_INDIRECT_MODE;
+	nw64(MIF_CONFIG, val);
+
+	err = bcm8704_reset(np);
+	if (err)
+		return err;
+
+	err = xcvr_10g_set_lb_bcm870x(np);
+	if (err)
+		return err;
+
+	err = bcm8706_init_user_dev3(np);
+	if (err)
+		return err;
+
+	err = xcvr_diag_bcm870x(np);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static int xcvr_init_10g_bcm8704(struct niu *np)
+{
+	int err;
+
+	err = bcm8704_reset(np);
+	if (err)
+		return err;
+
+	err = bcm8704_init_user_dev3(np);
+	if (err)
+		return err;
+
+	err = xcvr_10g_set_lb_bcm870x(np);
+	if (err)
+		return err;
+
+	err =  xcvr_diag_bcm870x(np);
+	if (err)
+		return err;
+
+	return 0;
+}
+
 static int xcvr_init_10g(struct niu *np)
 {
 	int phy_id, err;
@@ -1548,6 +1636,59 @@ out:
 	return err;
 }
 
+static int link_status_10g_bcm8706(struct niu *np, int *link_up_p)
+{
+	int err, link_up;
+	link_up = 0;
+
+	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
+			BCM8704_PMD_RCV_SIGDET);
+	if (err < 0)
+		goto out;
+	if (!(err & PMD_RCV_SIGDET_GLOBAL)) {
+		err = 0;
+		goto out;
+	}
+
+	err = mdio_read(np, np->phy_addr, BCM8704_PCS_DEV_ADDR,
+			BCM8704_PCS_10G_R_STATUS);
+	if (err < 0)
+		goto out;
+
+	if (!(err & PCS_10G_R_STATUS_BLK_LOCK)) {
+		err = 0;
+		goto out;
+	}
+
+	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
+			BCM8704_PHYXS_XGXS_LANE_STAT);
+	if (err < 0)
+		goto out;
+	if (err != (PHYXS_XGXS_LANE_STAT_ALINGED |
+		    PHYXS_XGXS_LANE_STAT_MAGIC |
+		    PHYXS_XGXS_LANE_STAT_PATTEST |
+		    PHYXS_XGXS_LANE_STAT_LANE3 |
+		    PHYXS_XGXS_LANE_STAT_LANE2 |
+		    PHYXS_XGXS_LANE_STAT_LANE1 |
+		    PHYXS_XGXS_LANE_STAT_LANE0)) {
+		err = 0;
+		np->link_config.active_speed = SPEED_INVALID;
+		np->link_config.active_duplex = DUPLEX_INVALID;
+		goto out;
+	}
+
+	link_up = 1;
+	np->link_config.active_speed = SPEED_10000;
+	np->link_config.active_duplex = DUPLEX_FULL;
+	err = 0;
+
+out:
+	*link_up_p = link_up;
+	if (np->flags & NIU_FLAGS_HOTPLUG_PHY)
+		err = 0;
+	return err;
+}
+
 static int link_status_10g_bcom(struct niu *np, int *link_up_p)
 {
 	int err, link_up;
@@ -1627,6 +1768,82 @@ static int link_status_10g(struct niu *np, int *link_up_p)
 	return err;
 }
 
+static int niu_10g_phy_present(struct niu *np)
+{
+	u64 sig, mask, val;
+
+	sig = nr64(ESR_INT_SIGNALS);
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
+		return 0;
+	}
+
+	if ((sig & mask) != val)
+		return 0;
+	return 1;
+}
+
+static int link_status_10g_hotplug(struct niu *np, int *link_up_p)
+{
+	unsigned long flags;
+	int err = 0;
+	int phy_present;
+	int phy_present_prev;
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	if (np->link_config.loopback_mode == LOOPBACK_DISABLED) {
+		phy_present_prev = (np->flags & NIU_FLAGS_HOTPLUG_PHY_PRESENT) ?
+			1 : 0;
+		phy_present = niu_10g_phy_present(np);
+		if (phy_present != phy_present_prev) {
+			/* state change */
+			if (phy_present) {
+				np->flags |= NIU_FLAGS_HOTPLUG_PHY_PRESENT;
+				if (np->phy_ops->xcvr_init)
+					err = np->phy_ops->xcvr_init(np);
+				if (err) {
+					/* debounce */
+					np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
+				}
+			} else {
+				np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
+				*link_up_p = 0;
+				niuwarn(LINK, "%s: Hotplug PHY Removed\n",
+					np->dev->name);
+			}
+		}
+		if (np->flags & NIU_FLAGS_HOTPLUG_PHY_PRESENT)
+			err = link_status_10g_bcm8706(np, link_up_p);
+	}
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return err;
+}
+
 static int link_status_1g(struct niu *np, int *link_up_p)
 {
 	struct niu_link_config *lp = &np->link_config;
@@ -1761,6 +1978,12 @@ static const struct niu_phy_ops phy_ops_10g_fiber = {
 	.link_status		= link_status_10g,
 };
 
+static const struct niu_phy_ops phy_ops_10g_fiber_hotplug = {
+	.serdes_init		= serdes_init_10g,
+	.xcvr_init		= xcvr_init_10g_bcm8706,
+	.link_status		= link_status_10g_hotplug,
+};
+
 static const struct niu_phy_ops phy_ops_10g_copper = {
 	.serdes_init		= serdes_init_10g,
 	.link_status		= link_status_10g, /* XXX */
@@ -1792,6 +2015,11 @@ static const struct niu_phy_template phy_template_10g_fiber = {
 	.phy_addr_base	= 8,
 };
 
+static const struct niu_phy_template phy_template_10g_fiber_hotplug = {
+	.ops		= &phy_ops_10g_fiber_hotplug,
+	.phy_addr_base	= 8,
+};
+
 static const struct niu_phy_template phy_template_10g_copper = {
 	.ops		= &phy_ops_10g_copper,
 	.phy_addr_base	= 10,
@@ -1996,6 +2224,13 @@ static int niu_determine_phy_disposition(struct niu *np)
 			    plat_type == PLAT_TYPE_VF_P1)
 				phy_addr_off = 8;
 			phy_addr_off += np->port;
+			if (np->flags & NIU_FLAGS_HOTPLUG_PHY) {
+				tp = &phy_template_10g_fiber_hotplug;
+				if (np->port == 0)
+					phy_addr_off = 8;
+				if (np->port == 1)
+					phy_addr_off = 12;
+			}
 			break;
 
 		case NIU_FLAGS_10G | NIU_FLAGS_XCVR_SERDES:
@@ -6830,6 +7065,9 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 		}
 		if (np->flags & NIU_FLAGS_10G)
 			 np->mac_xcvr = MAC_XCVR_XPCS;
+	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+		np->flags |= (NIU_FLAGS_10G | NIU_FLAGS_FIBER |
+			      NIU_FLAGS_HOTPLUG_PHY);
 	} else if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
 		dev_err(np->device, PFX "Illegal phy string [%s].\n",
 			np->vpd.phy_type);
@@ -7052,7 +7290,8 @@ static int __devinit phy_record(struct niu_parent *parent,
 		return 0;
 	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
 		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
-		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011))
+		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011) &&
+		    ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8706))
 			return 0;
 	} else {
 		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM5464R)
@@ -7299,7 +7538,6 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 	u32 val;
 	int err;
 
-
 	if (!strcmp(np->vpd.model, "SUNW,CP3220") ||
 	    !strcmp(np->vpd.model, "SUNW,CP3260")) {
 		num_10g = 0;
@@ -7310,6 +7548,12 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 		       phy_encode(PORT_TYPE_1G, 1) |
 		       phy_encode(PORT_TYPE_1G, 2) |
 		       phy_encode(PORT_TYPE_1G, 3));
+	} else if (niu_board_model_match(np, NIU_FOXXY_BM_STR)) {
+		num_10g = 2;
+		num_1g = 0;
+		parent->num_ports = 2;
+		val = (phy_encode(PORT_TYPE_10G, 0) |
+		       phy_encode(PORT_TYPE_10G, 1));
 	} else {
 		err = fill_phy_probe_info(np, parent, info);
 		if (err)
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 35e9afb..97ffbe1 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2537,6 +2537,7 @@ struct fcram_hash_ipv6 {
 
 #define NIU_PHY_ID_MASK			0xfffff0f0
 #define NIU_PHY_ID_BCM8704		0x00206030
+#define NIU_PHY_ID_BCM8706		0x00206035
 #define NIU_PHY_ID_BCM5464R		0x002060b0
 #define NIU_PHY_ID_MRVL88X2011		0x01410020
 
@@ -3208,6 +3209,8 @@ struct niu {
 	struct niu_parent		*parent;
 
 	u32				flags;
+#define NIU_FLAGS_HOTPLUG_PHY_PRESENT	0x02000000 /* Removebale PHY detected*/
+#define NIU_FLAGS_HOTPLUG_PHY		0x01000000 /* Removebale PHY */
 #define NIU_FLAGS_VPD_VALID		0x00800000 /* VPD has valid version */
 #define NIU_FLAGS_MSIX			0x00400000 /* MSI-X in use */
 #define NIU_FLAGS_MCAST			0x00200000 /* multicast filter enabled */
