From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH] drivers/net/niu: Support for Marvell PHY
Date: Tue, 18 Dec 2007 17:03:58 +0100
Message-ID: <1197993838.26679.64.camel@mlindner-lin.skd.de>
Reply-To: mlindner@marvell.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:43039 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753433AbXLRQ2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 11:28:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes necessary changes in the Neptune driver to support 
the new Marvell PHY. It also adds support for the LED blinking
on Neptune cards with Marvell PHY.


diff -uprN -X linux-2.6/Documentation/dontdiff
linux-2.6/drivers/net/niu.c linux-2.6-changed/drivers/net/niu.c
--- linux-2.6/drivers/net/niu.c	2007-12-10 14:14:04.000000000 +0100
+++ linux-2.6-changed/drivers/net/niu.c	2007-12-18 16:47:50.000000000
+0100
@@ -801,22 +801,65 @@ static int bcm8704_init_user_dev3(struct
 	return 0;
 }
 
-static int xcvr_init_10g(struct niu *np)
+void mrvl88x2011_act_led(struct niu *np, int val)
 {
-	struct niu_link_config *lp = &np->link_config;
-	u16 analog_stat0, tx_alarm_status;
 	int err;
-	u64 val;
 
-	val = nr64_mac(XMAC_CONFIG);
-	val &= ~XMAC_CONFIG_LED_POLARITY;
-	val |= XMAC_CONFIG_FORCE_LED_ON;
-	nw64_mac(XMAC_CONFIG, val);
+#define MRVL88X2011_LED_ACT             1
+#define MRVL88X2011_LED(n,v)            ((v)<<((n)*4))
+#define MRVL88X2011_LED_STAT(n,v)       ((v)>>((n)*4))
 
-	/* XXX shared resource, lock parent XXX */
-	val = nr64(MIF_CONFIG);
-	val |= MIF_CONFIG_INDIRECT_MODE;
-	nw64(MIF_CONFIG, val);
+	err  = mdio_read(np, np->phy_addr, 2, 0x8306);
+	err &= ~MRVL88X2011_LED(MRVL88X2011_LED_ACT,0x7);
+	err |=  MRVL88X2011_LED(MRVL88X2011_LED_ACT,val);
+
+	(void) mdio_write(np, np->phy_addr, 2, 0x8306, err);
+}
+
+void mrvl88x2011_led_blink_rate(struct niu *np, int rate)
+{
+	int err;
+
+	err = mdio_read(np, np->phy_addr, 2, 0x8303);
+	if (err >= 0) {
+		err &= ~0x70;
+		err |= (rate << 4);
+
+		(void) mdio_write(np, np->phy_addr, 2, 0x8303, err);
+	}
+}
+
+static int xcvr_init_10g_mrvl88x2011(struct niu *np)
+{
+	int err;
+
+	/* Set LED functions */
+	mrvl88x2011_led_blink_rate(np, 2);
+	mrvl88x2011_act_led(np, 0);	/* led activity */
+
+	err = mdio_read(np, np->phy_addr, 3, 0x8300);
+	if (err < 0) {
+		return(err);
+	}
+
+	err |= 0x0001;
+
+	err = mdio_write(np, np->phy_addr, 3, 0x8300, err);
+	if (err < 0) {
+		return(err);
+	}
+
+	/* Enable PMD */
+	err = mdio_write(np, np->phy_addr, 1, 0x0009, 0);
+	
+	return (err);
+}
+
+static int xcvr_init_10g_bcm8704(struct niu *np)
+{
+	struct niu_link_config *lp = &np->link_config;
+	u16 analog_stat0, tx_alarm_status;
+	int err;
 
 	err = bcm8704_reset(np);
 	if (err)
@@ -896,6 +939,39 @@ static int xcvr_init_10g(struct niu *np)
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
@@ -1082,18 +1158,69 @@ static int niu_link_status_common(struct
 	return 0;
 }
 
-static int link_status_10g(struct niu *np, int *link_up_p)
+static int link_status_10g_mrvl(struct niu *np, int *link_up_p)
 {
-	unsigned long flags;
-	int err, link_up;
+	int err;
+	int link_up = 0;
+	int pma_status;
+	int pcs_status;
 
-	link_up = 0;
 
-	spin_lock_irqsave(&np->lock, flags);
+	err = mdio_read(np, np->phy_addr, 1, 0x0008);
+	if (err < 0) {
+		goto out;
+	}
 
-	err = -EINVAL;
-	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
+	/* Check PMA/PMD Register: 1.0001.2 == 1
+         */
+	err = mdio_read(np, np->phy_addr, 1, 0x0001);
+	if (err < 0) {
+		goto out;
+	}
+
+	pma_status = ((err & 0x0004) ? 1:0);
+
+        /* Check PMC Register : 3.0001.2 == 1: read twice
+         */
+	err = mdio_read(np, np->phy_addr, 3, 0x0001);
+	if (err < 0) {
 		goto out;
+	}
+	err = mdio_read(np, np->phy_addr, 3, 0x0001);
+	if (err < 0) {
+		goto out;
+	}
+	pcs_status = ((err & 0x0004) ? 1 : 0);
+
+        /* Check XGXS Register : 4.0018.[0-3,12]
+         */
+	err = mdio_read(np, np->phy_addr, 4, 0x0018);
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
+	mrvl88x2011_act_led(np, link_up ? 5:0);
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
@@ -1134,12 +1261,42 @@ static int link_status_10g(struct niu *n
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
@@ -6281,8 +6438,10 @@ static int __devinit phy_record(struct n
 
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
diff -uprN -X linux-2.6/Documentation/dontdiff
linux-2.6/drivers/net/niu.h linux-2.6-changed/drivers/net/niu.h
--- linux-2.6/drivers/net/niu.h	2007-12-10 14:14:04.000000000 +0100
+++ linux-2.6-changed/drivers/net/niu.h	2007-12-18 15:01:02.000000000
+0100
@@ -2538,6 +2538,7 @@ struct fcram_hash_ipv6 {
 #define NIU_PHY_ID_MASK			0xfffff0f0
 #define NIU_PHY_ID_BCM8704		0x00206030
 #define NIU_PHY_ID_BCM5464R		0x002060b0
+#define NIU_PHY_ID_MRVL88X2011		0x01410020
 
 #define BCM8704_PMA_PMD_DEV_ADDR	1
 #define BCM8704_PCS_DEV_ADDR		2

