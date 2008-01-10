From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH] drivers/net/niu: Support for Marvell PHY
Date: Thu, 10 Jan 2008 10:33:01 +0100
Message-ID: <1199957581.5290.21.camel@mlindner-lin.skd.de>
Reply-To: mlindner@marvell.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:37363 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752098AbYAJJdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 04:33:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes necessary changes in the Neptune driver to support 
the new Marvell PHY. It also adds support for the LED blinking
on Neptune cards with Marvell PHY. All registers are using defines
in the niu.h header file as is already done for the BCM8704 registers.


diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/niu.c linux-2.6-changed/drivers/net/niu.c
--- linux-2.6/drivers/net/niu.c	2007-12-10 14:14:04.000000000 +0100
+++ linux-2.6-changed/drivers/net/niu.c	2008-01-09 14:32:59.000000000 +0100
@@ -801,22 +801,86 @@ static int bcm8704_init_user_dev3(struct
 	return 0;
 }
 
-static int xcvr_init_10g(struct niu *np)
+void mrvl88x2011_act_led(struct niu *np, int val)
+{
+	int	err;
+	err  = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+		MRVL88X2011_LED_8_TO_11_CTL);
+	err &= ~MRVL88X2011_LED(MRVL88X2011_LED_ACT,MRVL88X2011_LED_CTL_MASK);
+	err |=  MRVL88X2011_LED(MRVL88X2011_LED_ACT,val);
+
+	(void) mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+		MRVL88X2011_LED_8_TO_11_CTL, err);
+}
+
+void mrvl88x2011_led_blink_rate(struct niu *np, int rate)
+{
+	int	err;
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+		MRVL88X2011_LED_BLINK_CTL);
+	if (err >= 0) {
+		err &= ~MRVL88X2011_LED_BLKRATE_MASK;
+		err |= (rate << 4);
+
+		(void) mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV2_ADDR,
+			MRVL88X2011_LED_BLINK_CTL, err);
+	}
+}
+
+static int xcvr_init_10g_mrvl88x2011(struct niu *np)
+{
+	int	err;
+
+	/* Set LED functions */
+	mrvl88x2011_led_blink_rate(np, MRVL88X2011_LED_BLKRATE_134MS);
+	mrvl88x2011_act_led(np, MRVL88X2011_LED_CTL_OFF);	/* led activity */
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+		MRVL88X2011_GENERAL_CTL);
+	if (err < 0) {
+		return(err);
+	}
+
+	err |= MRVL88X2011_ENA_XFPREFCLK;
+
+	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+		MRVL88X2011_GENERAL_CTL, err);
+	if (err < 0) {
+		return(err);
+	}
+
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+		MRVL88X2011_PMA_PMD_CTL_1);
+	if (err < 0) {
+		return(err);
+	}
+
+	if (np->link_config.loopback_mode == LOOPBACK_MAC) {
+		err |= MRVL88X2011_LOOPBACK;
+	}
+	else {
+		err &= ~MRVL88X2011_LOOPBACK;
+	}
+
+	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+		MRVL88X2011_PMA_PMD_CTL_1, err);
+	if (err < 0) {
+		return(err);
+	}
+
+	/* Enable PMD  */
+	err = mdio_write(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+		MRVL88X2011_10G_PMD_TX_DIS, MRVL88X2011_ENA_PMDTX);
+	
+	return (err);
+}
+
+static int xcvr_init_10g_bcm8704(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
 	u16 analog_stat0, tx_alarm_status;
 	int err;
-	u64 val;
-
-	val = nr64_mac(XMAC_CONFIG);
-	val &= ~XMAC_CONFIG_LED_POLARITY;
-	val |= XMAC_CONFIG_FORCE_LED_ON;
-	nw64_mac(XMAC_CONFIG, val);
-
-	/* XXX shared resource, lock parent XXX */
-	val = nr64(MIF_CONFIG);
-	val |= MIF_CONFIG_INDIRECT_MODE;
-	nw64(MIF_CONFIG, val);
 
 	err = bcm8704_reset(np);
 	if (err)
@@ -896,6 +960,39 @@ static int xcvr_init_10g(struct niu *np)
 	return 0;
 }
 
+static int xcvr_init_10g(struct niu *np)
+{
+	int err;
+	u64 val;
+	int phy_id;
+
+	val = nr64_mac(XMAC_CONFIG);
+	val &= ~XMAC_CONFIG_LED_POLARITY;
+	val |= XMAC_CONFIG_FORCE_LED_ON;
+	nw64_mac(XMAC_CONFIG, val);
+
+	/* XXX shared resource, lock parent XXX */
+	val = nr64(MIF_CONFIG);
+	val |= MIF_CONFIG_INDIRECT_MODE;
+	nw64(MIF_CONFIG, val);
+
+	phy_id = phy_decode(np->parent->port_phy, np->port);
+	phy_id = np->parent->phy_probe_info.phy_id[phy_id][np->port];
+
+	/* handle different phy types */
+	switch((phy_id & NIU_PHY_ID_MASK)) {
+	case NIU_PHY_ID_MRVL88X2011:
+		err = xcvr_init_10g_mrvl88x2011(np);
+		break;
+
+	default: /* bcom 8704 */
+		err = xcvr_init_10g_bcm8704(np);
+		break;
+	}
+
+	return 0;
+}
+
 static int mii_reset(struct niu *np)
 {
 	int limit, err;
@@ -1082,18 +1179,71 @@ static int niu_link_status_common(struct
 	return 0;
 }
 
-static int link_status_10g(struct niu *np, int *link_up_p)
+static int link_status_10g_mrvl(struct niu *np, int *link_up_p)
 {
-	unsigned long flags;
-	int err, link_up;
+	int 	err;
+	int	link_up = 0;
+	int	pma_status;
+	int	pcs_status;
 
-	link_up = 0;
 
-	spin_lock_irqsave(&np->lock, flags);
+	err = mdio_read(np, np->phy_addr, 
+		MRVL88X2011_USER_DEV1_ADDR, MRVL88X2011_10G_PMD_STATUS_2);
+	if (err < 0) {
+		goto out;
+	}
 
-	err = -EINVAL;
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
+	/* Check PMA/PMD Register: 1.0001.2 == 1 */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV1_ADDR,
+		MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0) {
 		goto out;
+	}
+
+	pma_status = ((err & MRVL88X2011_LNK_STATUS_OK) ? 1:0);
+
+        /* Check PMC Register : 3.0001.2 == 1: read twice */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+		MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0) {
+		goto out;
+	}
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV3_ADDR,
+		MRVL88X2011_PMA_PMD_STATUS_1);
+	if (err < 0) {
+		goto out;
+	}
+	pcs_status = ((err & MRVL88X2011_LNK_STATUS_OK) ? 1:0);
+
+        /* Check XGXS Register : 4.0018.[0-3,12] */
+	err = mdio_read(np, np->phy_addr, MRVL88X2011_USER_DEV4_ADDR,
+		MRVL88X2011_10G_XGXS_LANE_STAT);
+	if (err < 0) {
+		goto out;
+	}
+
+	if (err == (
+		PHYXS_XGXS_LANE_STAT_ALINGED | PHYXS_XGXS_LANE_STAT_LANE3 |
+		PHYXS_XGXS_LANE_STAT_LANE2 | PHYXS_XGXS_LANE_STAT_LANE1 |
+		PHYXS_XGXS_LANE_STAT_LANE0 | PHYXS_XGXS_LANE_STAT_MAGIC | 0x800)) {
+
+		link_up = (pma_status && pcs_status) ? 1 : 0;
+	}
+
+	np->link_config.active_speed = SPEED_10000;
+	np->link_config.active_duplex = DUPLEX_FULL;
+	err = 0;
+out:
+	mrvl88x2011_act_led(np, link_up ? MRVL88X2011_LED_CTL_PCS_ACT:MRVL88X2011_LED_CTL_OFF);
+
+	*link_up_p = link_up;
+	return err;
+}
+
+static int link_status_10g_bcom(struct niu *np, int *link_up_p)
+{
+	int err;
+	int link_up = 0;
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PMA_PMD_DEV_ADDR,
 			BCM8704_PMD_RCV_SIGDET);
@@ -1134,12 +1284,42 @@ static int link_status_10g(struct niu *n
 	err = 0;
 
 out:
-	spin_unlock_irqrestore(&np->lock, flags);
-
 	*link_up_p = link_up;
 	return err;
 }
 
+static int link_status_10g(struct niu *np, int *link_up_p)
+{
+	unsigned long flags;
+	int err;
+
+	err = -EINVAL;
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	if (np->link_config.loopback_mode == LOOPBACK_DISABLED) {
+		int phy_id;
+
+		phy_id = phy_decode(np->parent->port_phy, np->port);
+		phy_id = np->parent->phy_probe_info.phy_id[phy_id][np->port];
+
+		/* handle different phy types */
+		switch((phy_id & NIU_PHY_ID_MASK)) {
+		case NIU_PHY_ID_MRVL88X2011:
+			err = link_status_10g_mrvl(np, link_up_p);
+			break;
+
+		default: /* bcom 8704 */
+			err = link_status_10g_bcom(np, link_up_p);
+			break;
+		}
+	}
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return(err);
+}
+
 static int link_status_1g(struct niu *np, int *link_up_p)
 {
 	u16 current_speed, bmsr;
@@ -6281,8 +6461,10 @@ static int __devinit phy_record(struct n
 
 	if (dev_id_1 < 0 || dev_id_2 < 0)
 		return 0;
+
 	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
-		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704)
+		if (((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM8704) &&
+			((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_MRVL88X2011))
 			return 0;
 	} else {
 		if ((id & NIU_PHY_ID_MASK) != NIU_PHY_ID_BCM5464R)
diff -uprN -X linux-2.6/Documentation/dontdiff linux-2.6/drivers/net/niu.h linux-2.6-changed/drivers/net/niu.h
--- linux-2.6/drivers/net/niu.h	2007-12-10 14:14:04.000000000 +0100
+++ linux-2.6-changed/drivers/net/niu.h	2008-01-09 14:22:23.000000000 +0100
@@ -2538,6 +2538,39 @@ struct fcram_hash_ipv6 {
 #define NIU_PHY_ID_MASK			0xfffff0f0
 #define NIU_PHY_ID_BCM8704		0x00206030
 #define NIU_PHY_ID_BCM5464R		0x002060b0
+#define NIU_PHY_ID_MRVL88X2011		0x01410020
+
+/* MRVL88X2011 register addresses */
+#define MRVL88X2011_USER_DEV1_ADDR	1
+#define MRVL88X2011_USER_DEV2_ADDR	2
+#define MRVL88X2011_USER_DEV3_ADDR	3
+#define MRVL88X2011_USER_DEV4_ADDR	4
+#define MRVL88X2011_PMA_PMD_CTL_1	0x0000
+#define MRVL88X2011_PMA_PMD_STATUS_1	0x0001
+#define MRVL88X2011_10G_PMD_STATUS_2	0x0008
+#define MRVL88X2011_10G_PMD_TX_DIS	0x0009
+#define MRVL88X2011_10G_XGXS_LANE_STAT	0x0018
+#define MRVL88X2011_GENERAL_CTL		0x8300
+#define MRVL88X2011_LED_BLINK_CTL	0x8303
+#define MRVL88X2011_LED_8_TO_11_CTL	0x8306
+
+/* MRVL88X2011 register control */
+#define MRVL88X2011_ENA_XFPREFCLK	0x0001
+#define MRVL88X2011_ENA_PMDTX		0x0000
+#define MRVL88X2011_LOOPBACK            0x1
+#define MRVL88X2011_LED_ACT             0x1
+#define MRVL88X2011_LNK_STATUS_OK       0x4
+#define MRVL88X2011_LED_BLKRATE_MASK	0x70
+#define MRVL88X2011_LED_BLKRATE_034MS	0x0
+#define MRVL88X2011_LED_BLKRATE_067MS	0x1
+#define MRVL88X2011_LED_BLKRATE_134MS	0x2
+#define MRVL88X2011_LED_BLKRATE_269MS	0x3
+#define MRVL88X2011_LED_BLKRATE_538MS	0x4
+#define MRVL88X2011_LED_CTL_OFF		0x0
+#define MRVL88X2011_LED_CTL_PCS_ACT	0x5
+#define MRVL88X2011_LED_CTL_MASK	0x7
+#define MRVL88X2011_LED(n,v)            ((v)<<((n)*4))
+#define MRVL88X2011_LED_STAT(n,v)       ((v)>>((n)*4))
 
 #define BCM8704_PMA_PMD_DEV_ADDR	1
 #define BCM8704_PCS_DEV_ADDR		2

