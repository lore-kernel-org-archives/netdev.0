From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/8 net-next-2.6] cxgb3: AEL2020 phy support update
Date: Tue, 07 Jul 2009 22:48:43 -0700
Message-ID: <20090708054843.11344.70846.stgit@speedy5>
References: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8709 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215AbZGHFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:48:45 -0400
In-Reply-To: <20090708054832.11344.82449.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

We don't always see the link status update interrupt
when we come out of reset and the peer is up.
Check and report the link status right before enabling interrupts.
Also fix LED settings, to get a consistent link status.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    8 +++
 drivers/net/cxgb3/ael1002.c |  102 ++++++++++++++++++++++++++++++++-----------
 2 files changed, 83 insertions(+), 27 deletions(-)


diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 1694fad..bfa312d 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -276,6 +276,14 @@ static inline struct port_info *adap2pinfo(struct adapter *adap, int idx)
 	return netdev_priv(adap->port[idx]);
 }
 
+static inline int phy2portid(struct cphy *phy)
+{
+	struct adapter *adap = phy->adapter;
+	struct port_info *port0 = adap2pinfo(adap, 0);
+
+	return &port0->phy == phy ? 0 : 1;
+}
+
 #define OFFLOAD_DEVMAP_BIT 15
 
 #define tdev2adap(d) container_of(d, struct adapter, tdev)
diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 9fe008e..99e3e0f 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -1649,9 +1649,39 @@ static int ael2020_get_module_type(struct cphy *phy, int delay_ms)
  */
 static int ael2020_intr_enable(struct cphy *phy)
 {
-	int err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
-				0x2 << (AEL2020_GPIO_MODDET*4));
-	return err ? err : t3_phy_lasi_intr_enable(phy);
+	struct reg_val regs[] = {
+		/* output Module's Loss Of Signal (LOS) to LED */
+		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CFG+AEL2020_GPIO_LSTAT,
+			0xffff, 0x4 },
+		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
+			0xffff, 0x8 << (AEL2020_GPIO_LSTAT*4) },
+
+		 /* enable module detect status change interrupts */
+		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
+			0xffff, 0x2 << (AEL2020_GPIO_MODDET*4) },
+
+		/* end */
+		{ 0, 0, 0, 0 }
+	};
+	int err, link_ok = 0;
+
+	/* set up "link status" LED and enable module change interrupts */
+	err = set_phy_regs(phy, regs);
+	if (err)
+		return err;
+
+	err = get_link_status_r(phy, &link_ok, NULL, NULL, NULL);
+	if (err)
+		return err;
+	if (link_ok)
+		t3_link_changed(phy->adapter,
+				phy2portid(phy));
+
+	err = t3_phy_lasi_intr_enable(phy);
+	if (err)
+		return err;
+
+	return 0;
 }
 
 /*
@@ -1659,9 +1689,26 @@ static int ael2020_intr_enable(struct cphy *phy)
  */
 static int ael2020_intr_disable(struct cphy *phy)
 {
-	int err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
-				0x1 << (AEL2020_GPIO_MODDET*4));
-	return err ? err : t3_phy_lasi_intr_disable(phy);
+	struct reg_val regs[] = {
+		/* reset "link status" LED to "off" */
+		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
+			0xffff, 0xb << (AEL2020_GPIO_LSTAT*4) },
+
+		/* disable module detect status change interrupts */
+		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
+			0xffff, 0x1 << (AEL2020_GPIO_MODDET*4) },
+
+		/* end */
+		{ 0, 0, 0, 0 }
+	};
+	int err;
+
+	/* turn off "link status" LED and disable module change interrupts */
+	err = set_phy_regs(phy, regs);
+	if (err)
+		return err;
+
+	return t3_phy_lasi_intr_disable(phy);
 }
 
 /*
@@ -1679,31 +1726,26 @@ static int ael2020_intr_clear(struct cphy *phy)
 	return err ? err : t3_phy_lasi_intr_clear(phy);
 }
 
+static struct reg_val ael2020_reset_regs[] = {
+	/* Erratum #2: CDRLOL asserted, causing PMA link down status */
+	{ MDIO_MMD_PMAPMD, 0xc003, 0xffff, 0x3101 },
+
+	/* force XAUI to send LF when RX_LOS is asserted */
+	{ MDIO_MMD_PMAPMD, 0xcd40, 0xffff, 0x0001 },
+
+	/* allow writes to transceiver module EEPROM on i2c bus */
+	{ MDIO_MMD_PMAPMD, 0xff02, 0xffff, 0x0023 },
+	{ MDIO_MMD_PMAPMD, 0xff03, 0xffff, 0x0000 },
+	{ MDIO_MMD_PMAPMD, 0xff04, 0xffff, 0x0000 },
+
+	/* end */
+	{ 0, 0, 0, 0 }
+};
 /*
  * Reset the PHY and put it into a canonical operating state.
  */
 static int ael2020_reset(struct cphy *phy, int wait)
 {
-	static struct reg_val regs0[] = {
-		/* Erratum #2: CDRLOL asserted, causing PMA link down status */
-		{ MDIO_MMD_PMAPMD, 0xc003, 0xffff, 0x3101 },
-
-		/* force XAUI to send LF when RX_LOS is asserted */
-		{ MDIO_MMD_PMAPMD, 0xcd40, 0xffff, 0x0001 },
-
-		/* RX_LOS pin is active high */
-		{ MDIO_MMD_PMAPMD, AEL_OPT_SETTINGS,
-			0x0020, 0x0020 },
-
-		/* output Module's Loss Of Signal (LOS) to LED */
-		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CFG+AEL2020_GPIO_LSTAT,
-			0xffff, 0x0004 },
-		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
-			0xffff, 0x8 << (AEL2020_GPIO_LSTAT*4) },
-
-		/* end */
-		{ 0, 0, 0, 0 }
-	};
 	int err;
 	unsigned int lasi_ctrl;
 
@@ -1720,7 +1762,7 @@ static int ael2020_reset(struct cphy *phy, int wait)
 
 	/* basic initialization for all module types */
 	phy->priv = edc_none;
-	err = set_phy_regs(phy, regs0);
+	err = set_phy_regs(phy, ael2020_reset_regs);
 	if (err)
 		return err;
 
@@ -1798,10 +1840,16 @@ static struct cphy_ops ael2020_ops = {
 int t3_ael2020_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 			const struct mdio_ops *mdio_ops)
 {
+	int err;
+
 	cphy_init(phy, adapter, phy_addr, &ael2020_ops, mdio_ops,
 		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_FIBRE |
 		  SUPPORTED_IRQ, "10GBASE-R");
 	msleep(125);
+
+	err = set_phy_regs(phy, ael2020_reset_regs);
+	if (err)
+		return err;
 	return 0;
 }
 

