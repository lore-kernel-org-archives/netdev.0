From: Joe Perches <joe@perches.com>
Subject: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Tue, 26 Apr 2011 11:12:10 -0700
Message-ID: <1303841530.24299.37.camel@Joe-Laptop>
References: <1303771370-32579-1-git-send-email-mcarlson@broadcom.com>
	 <1303776118.24299.1.camel@Joe-Laptop>
	 <20110426001738.GB802@mcarlson.broadcom.com>
	 <1303776574.24299.3.camel@Joe-Laptop>
	 <20110426013512.GA2031@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4997 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757864Ab1DZSMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 14:12:13 -0400
In-Reply-To: <20110426013512.GA2031@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a bitmap instead of separate u32 flags allows a consistent, simpler
and more extensible mechanism to determine capabilities.

Convert bitmasks to enum.
Add tg3_flag, tg3_flag_clear and tg3_flag_set.
Convert the flag & bitmask tests.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tg3.c | 1299 ++++++++++++++++++++++++++---------------------------
 drivers/net/tg3.h |  168 ++++----
 2 files changed, 728 insertions(+), 739 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b20538a..fa57e3d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -62,6 +62,30 @@
 
 #include "tg3.h"
 
+/* Functions & macros to verify TG3_FLAGS types */
+
+static inline int _tg3_flag(enum TG3_FLAGS flag, unsigned long *bits)
+{
+	return test_bit(flag, bits);
+}
+
+static inline void _tg3_flag_set(enum TG3_FLAGS flag, unsigned long *bits)
+{
+	set_bit(flag, bits);
+}
+
+static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
+{
+	clear_bit(flag, bits);
+}
+
+#define tg3_flag(tp, flag)				\
+	_tg3_flag(TG3_FLAG_##flag, (tp)->tg3_flags)
+#define tg3_flag_set(tp, flag)				\
+	_tg3_flag_set(TG3_FLAG_##flag, (tp)->tg3_flags)
+#define tg3_flag_clear(tp, flag)			\
+	_tg3_flag_clear(TG3_FLAG_##flag, (tp)->tg3_flags)
+
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
 #define TG3_MIN_NUM			118
@@ -85,23 +109,24 @@
 /* length of time before we decide the hardware is borked,
  * and dev->tx_timeout() should be called to fix the problem
  */
+
 #define TG3_TX_TIMEOUT			(5 * HZ)
 
 /* hardware minimum and maximum for a single frame's data payload */
 #define TG3_MIN_MTU			60
 #define TG3_MAX_MTU(tp)	\
-	((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ? 9000 : 1500)
+	(tg3_flag(tp, JUMBO_CAPABLE) ? 9000 : 1500)
 
 /* These numbers seem to be hard coded in the NIC firmware somehow.
  * You can't change the ring sizes, but you can change where you place
  * them in the NIC onboard memory.
  */
 #define TG3_RX_STD_RING_SIZE(tp) \
-	((tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP) ? \
+	(tg3_flag(tp, LRG_PROD_RING_CAP) ? \
 	 TG3_RX_STD_MAX_SIZE_5717 : TG3_RX_STD_MAX_SIZE_5700)
 #define TG3_DEF_RX_RING_PENDING		200
 #define TG3_RX_JMB_RING_SIZE(tp) \
-	((tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP) ? \
+	(tg3_flag(tp, LRG_PROD_RING_CAP) ? \
 	 TG3_RX_JMB_MAX_SIZE_5717 : TG3_RX_JMB_MAX_SIZE_5700)
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
 #define TG3_RSS_INDIR_TBL_SIZE		128
@@ -468,8 +493,7 @@ static u32 tg3_read_indirect_mbox(struct tg3 *tp, u32 off)
  */
 static void _tw32_flush(struct tg3 *tp, u32 off, u32 val, u32 usec_wait)
 {
-	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) ||
-	    (tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND))
+	if (tg3_flag(tp, PCIX_TARGET_HWBUG) || tg3_flag(tp, ICH_WORKAROUND))
 		/* Non-posted methods */
 		tp->write32(tp, off, val);
 	else {
@@ -489,8 +513,7 @@ static void _tw32_flush(struct tg3 *tp, u32 off, u32 val, u32 usec_wait)
 static inline void tw32_mailbox_flush(struct tg3 *tp, u32 off, u32 val)
 {
 	tp->write32_mbox(tp, off, val);
-	if (!(tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND))
+	if (!tg3_flag(tp, MBOX_WRITE_REORDER) && !tg3_flag(tp, ICH_WORKAROUND))
 		tp->read32_mbox(tp, off);
 }
 
@@ -498,9 +521,9 @@ static void tg3_write32_tx_mbox(struct tg3 *tp, u32 off, u32 val)
 {
 	void __iomem *mbox = tp->regs + off;
 	writel(val, mbox);
-	if (tp->tg3_flags & TG3_FLAG_TXD_MBOX_HWBUG)
+	if (tg3_flag(tp, TXD_MBOX_HWBUG))
 		writel(val, mbox);
-	if (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)
+	if (tg3_flag(tp, MBOX_WRITE_REORDER))
 		readl(mbox);
 }
 
@@ -534,7 +557,7 @@ static void tg3_write_mem(struct tg3 *tp, u32 off, u32 val)
 		return;
 
 	spin_lock_irqsave(&tp->indirect_lock, flags);
-	if (tp->tg3_flags & TG3_FLAG_SRAM_USE_CONFIG) {
+	if (tg3_flag(tp, SRAM_USE_CONFIG)) {
 		pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
 		pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_DATA, val);
 
@@ -561,7 +584,7 @@ static void tg3_read_mem(struct tg3 *tp, u32 off, u32 *val)
 	}
 
 	spin_lock_irqsave(&tp->indirect_lock, flags);
-	if (tp->tg3_flags & TG3_FLAG_SRAM_USE_CONFIG) {
+	if (tg3_flag(tp, SRAM_USE_CONFIG)) {
 		pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
 		pci_read_config_dword(tp->pdev, TG3PCI_MEM_WIN_DATA, val);
 
@@ -598,7 +621,7 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 	int ret = 0;
 	u32 status, req, gnt;
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+	if (!tg3_flag(tp, ENABLE_APE))
 		return 0;
 
 	switch (locknum) {
@@ -644,7 +667,7 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 {
 	u32 gnt;
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+	if (!tg3_flag(tp, ENABLE_APE))
 		return;
 
 	switch (locknum) {
@@ -688,14 +711,14 @@ static void tg3_enable_ints(struct tg3 *tp)
 		struct tg3_napi *tnapi = &tp->napi[i];
 
 		tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
-		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
+		if (tg3_flag(tp, 1SHOT_MSI))
 			tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
 
 		tp->coal_now |= tnapi->coal_now;
 	}
 
 	/* Force an initial interrupt */
-	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
+	if (!tg3_flag(tp, TAGGED_STATUS) &&
 	    (tp->napi[0].hw_status->status & SD_STATUS_UPDATED))
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
 	else
@@ -711,9 +734,7 @@ static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 	unsigned int work_exists = 0;
 
 	/* check for phy events */
-	if (!(tp->tg3_flags &
-	      (TG3_FLAG_USE_LINKCHG_REG |
-	       TG3_FLAG_POLL_SERDES))) {
+	if (!(tg3_flag(tp, USE_LINKCHG_REG) || tg3_flag(tp, POLL_SERDES))) {
 		if (sblk->status & SD_STATUS_LINK_CHG)
 			work_exists = 1;
 	}
@@ -741,8 +762,7 @@ static void tg3_int_reenable(struct tg3_napi *tnapi)
 	 * The last_tag we write above tells the chip which piece of
 	 * work we've completed.
 	 */
-	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
-	    tg3_has_work(tnapi))
+	if (!tg3_flag(tp, TAGGED_STATUS) && tg3_has_work(tnapi))
 		tw32(HOSTCC_MODE, tp->coalesce_mode |
 		     HOSTCC_MODE_ENABLE | tnapi->coal_now);
 }
@@ -752,8 +772,7 @@ static void tg3_switch_clocks(struct tg3 *tp)
 	u32 clock_ctrl;
 	u32 orig_clock_ctrl;
 
-	if ((tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	if (tg3_flag(tp, CPMU_PRESENT) || tg3_flag(tp, 5780_CLASS))
 		return;
 
 	clock_ctrl = tr32(TG3PCI_CLOCK_CTRL);
@@ -764,7 +783,7 @@ static void tg3_switch_clocks(struct tg3 *tp)
 		       0x1f);
 	tp->pci_clock_ctrl = clock_ctrl;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tg3_flag(tp, 5705_PLUS)) {
 		if (orig_clock_ctrl & CLOCK_CTRL_625_CORE) {
 			tw32_wait_f(TG3PCI_CLOCK_CTRL,
 				    clock_ctrl | CLOCK_CTRL_625_CORE, 40);
@@ -1081,7 +1100,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		return;
 	}
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE))
+	if (!tg3_flag(tp, RGMII_INBAND_DISABLE))
 		val |= MAC_PHYCFG2_EMODE_MASK_MASK |
 		       MAC_PHYCFG2_FMODE_MASK_MASK |
 		       MAC_PHYCFG2_GMODE_MASK_MASK |
@@ -1094,10 +1113,10 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 	val = tr32(MAC_PHYCFG1);
 	val &= ~(MAC_PHYCFG1_RXCLK_TO_MASK | MAC_PHYCFG1_TXCLK_TO_MASK |
 		 MAC_PHYCFG1_RGMII_EXT_RX_DEC | MAC_PHYCFG1_RGMII_SND_STAT_EN);
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)) {
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+	if (!tg3_flag(tp, RGMII_INBAND_DISABLE)) {
+		if (tg3_flag(tp, RGMII_EXT_IBND_RX_EN))
 			val |= MAC_PHYCFG1_RGMII_EXT_RX_DEC;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+		if (tg3_flag(tp, RGMII_EXT_IBND_TX_EN))
 			val |= MAC_PHYCFG1_RGMII_SND_STAT_EN;
 	}
 	val |= MAC_PHYCFG1_RXCLK_TIMEOUT | MAC_PHYCFG1_TXCLK_TIMEOUT |
@@ -1112,13 +1131,13 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 		 MAC_RGMII_MODE_TX_ENABLE |
 		 MAC_RGMII_MODE_TX_LOWPWR |
 		 MAC_RGMII_MODE_TX_RESET);
-	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)) {
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+	if (!tg3_flag(tp, RGMII_INBAND_DISABLE)) {
+		if (tg3_flag(tp, RGMII_EXT_IBND_RX_EN))
 			val |= MAC_RGMII_MODE_RX_INT_B |
 			       MAC_RGMII_MODE_RX_QUALITY |
 			       MAC_RGMII_MODE_RX_ACTIVITY |
 			       MAC_RGMII_MODE_RX_ENG_DET;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+		if (tg3_flag(tp, RGMII_EXT_IBND_TX_EN))
 			val |= MAC_RGMII_MODE_TX_ENABLE |
 			       MAC_RGMII_MODE_TX_LOWPWR |
 			       MAC_RGMII_MODE_TX_RESET;
@@ -1132,7 +1151,7 @@ static void tg3_mdio_start(struct tg3 *tp)
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
 
-	if ((tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) &&
+	if (tg3_flag(tp, MDIOBUS_INITED) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tg3_mdio_config_5785(tp);
 }
@@ -1143,7 +1162,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	u32 reg;
 	struct phy_device *phydev;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	if (tg3_flag(tp, 5717_PLUS)) {
 		u32 is_serdes;
 
 		tp->phy_addr = PCI_FUNC(tp->pdev->devfn) + 1;
@@ -1160,8 +1179,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 
 	tg3_mdio_start(tp);
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) ||
-	    (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED))
+	if (!tg3_flag(tp, USE_PHYLIB) || tg3_flag(tp, MDIOBUS_INITED))
 		return 0;
 
 	tp->mdio_bus = mdiobus_alloc();
@@ -1217,11 +1235,11 @@ static int tg3_mdio_init(struct tg3 *tp)
 				     PHY_BRCM_RX_REFCLK_UNUSED |
 				     PHY_BRCM_DIS_TXCRXC_NOENRGY |
 				     PHY_BRCM_AUTO_PWRDWN_ENABLE;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_INBAND_DISABLE)
+		if (tg3_flag(tp, RGMII_INBAND_DISABLE))
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+		if (tg3_flag(tp, RGMII_EXT_IBND_RX_EN))
 			phydev->dev_flags |= PHY_BRCM_EXT_IBND_RX_ENABLE;
-		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+		if (tg3_flag(tp, RGMII_EXT_IBND_TX_EN))
 			phydev->dev_flags |= PHY_BRCM_EXT_IBND_TX_ENABLE;
 		/* fallthru */
 	case PHY_ID_RTL8211C:
@@ -1235,7 +1253,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 		break;
 	}
 
-	tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
+	tg3_flag_set(tp, MDIOBUS_INITED);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tg3_mdio_config_5785(tp);
@@ -1245,8 +1263,8 @@ static int tg3_mdio_init(struct tg3 *tp)
 
 static void tg3_mdio_fini(struct tg3 *tp)
 {
-	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
-		tp->tg3_flags3 &= ~TG3_FLG3_MDIOBUS_INITED;
+	if (tg3_flag(tp, MDIOBUS_INITED)) {
+		tg3_flag_clear(tp, MDIOBUS_INITED);
 		mdiobus_unregister(tp->mdio_bus);
 		mdiobus_free(tp->mdio_bus);
 	}
@@ -1299,8 +1317,7 @@ static void tg3_ump_link_report(struct tg3 *tp)
 	u32 reg;
 	u32 val;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
-	    !(tp->tg3_flags  & TG3_FLAG_ENABLE_ASF))
+	if (!tg3_flag(tp, 5780_CLASS) || !tg3_flag(tp, ENABLE_ASF))
 		return;
 
 	tg3_wait_for_event_ack(tp);
@@ -1430,13 +1447,12 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 	u32 old_rx_mode = tp->rx_mode;
 	u32 old_tx_mode = tp->tx_mode;
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+	if (tg3_flag(tp, USE_PHYLIB))
 		autoneg = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]->autoneg;
 	else
 		autoneg = tp->link_config.autoneg;
 
-	if (autoneg == AUTONEG_ENABLE &&
-	    (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)) {
+	if (autoneg == AUTONEG_ENABLE && tg3_flag(tp, PAUSE_AUTONEG)) {
 		if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES)
 			flowctrl = tg3_resolve_flowctrl_1000X(lcladv, rmtadv);
 		else
@@ -1657,8 +1673,8 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 reg;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	    ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+	if (!tg3_flag(tp, 5705_PLUS) ||
+	    (tg3_flag(tp, 5717_PLUS) &&
 	     (tp->phy_flags & TG3_PHYFLG_MII_SERDES)))
 		return;
 
@@ -1692,7 +1708,7 @@ static void tg3_phy_toggle_automdix(struct tg3 *tp, int enable)
 {
 	u32 phy;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+	if (!tg3_flag(tp, 5705_PLUS) ||
 	    (tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
 		return;
 
@@ -2065,7 +2081,7 @@ static int tg3_phy_reset(struct tg3 *tp)
 		}
 	}
 
-	if ((tp->tg3_flags3 & TG3_FLG3_5717_PLUS) &&
+	if (tg3_flag(tp, 5717_PLUS) &&
 	    (tp->phy_flags & TG3_PHYFLG_MII_SERDES))
 		return 0;
 
@@ -2115,7 +2131,7 @@ out:
 	if ((tp->phy_id & TG3_PHY_ID_MASK) == TG3_PHY_ID_BCM5401) {
 		/* Cannot do read-modify-write on 5401 */
 		tg3_phy_auxctl_write(tp, MII_TG3_AUXCTL_SHDWSEL_AUXCTL, 0x4c20);
-	} else if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+	} else if (tg3_flag(tp, JUMBO_CAPABLE)) {
 		/* Set bit 14 with read-modify-write to preserve other bits */
 		err = tg3_phy_auxctl_read(tp,
 					  MII_TG3_AUXCTL_SHDWSEL_AUXCTL, &val);
@@ -2127,7 +2143,7 @@ out:
 	/* Set phy register 0x10 bit 0 to high fifo elasticity to support
 	 * jumbo frames transmission.
 	 */
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+	if (tg3_flag(tp, JUMBO_CAPABLE)) {
 		if (!tg3_readphy(tp, MII_TG3_EXT_CTRL, &val))
 			tg3_writephy(tp, MII_TG3_EXT_CTRL,
 				     val | MII_TG3_EXT_CTRL_FIFO_ELASTIC);
@@ -2148,7 +2164,7 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 	bool need_vaux = false;
 
 	/* The GPIOs do something completely different on 57765. */
-	if ((tp->tg3_flags2 & TG3_FLG2_IS_NIC) == 0 ||
+	if (!tg3_flag(tp, IS_NIC) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		return;
@@ -2166,17 +2182,16 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 		if (dev_peer) {
 			struct tg3 *tp_peer = netdev_priv(dev_peer);
 
-			if (tp_peer->tg3_flags & TG3_FLAG_INIT_COMPLETE)
+			if (tg3_flag(tp_peer, INIT_COMPLETE))
 				return;
 
-			if ((tp_peer->tg3_flags & TG3_FLAG_WOL_ENABLE) ||
-			    (tp_peer->tg3_flags & TG3_FLAG_ENABLE_ASF))
+			if (tg3_flag(tp_peer, WOL_ENABLE) ||
+			    tg3_flag(tp_peer, ENABLE_ASF))
 				need_vaux = true;
 		}
 	}
 
-	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) ||
-	    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+	if (tg3_flag(tp, WOL_ENABLE) || tg3_flag(tp, ENABLE_ASF))
 		need_vaux = true;
 
 	if (need_vaux) {
@@ -2359,7 +2374,7 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 /* tp->lock is held. */
 static int tg3_nvram_lock(struct tg3 *tp)
 {
-	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
+	if (tg3_flag(tp, NVRAM)) {
 		int i;
 
 		if (tp->nvram_lock_cnt == 0) {
@@ -2382,7 +2397,7 @@ static int tg3_nvram_lock(struct tg3 *tp)
 /* tp->lock is held. */
 static void tg3_nvram_unlock(struct tg3 *tp)
 {
-	if (tp->tg3_flags & TG3_FLAG_NVRAM) {
+	if (tg3_flag(tp, NVRAM)) {
 		if (tp->nvram_lock_cnt > 0)
 			tp->nvram_lock_cnt--;
 		if (tp->nvram_lock_cnt == 0)
@@ -2393,8 +2408,7 @@ static void tg3_nvram_unlock(struct tg3 *tp)
 /* tp->lock is held. */
 static void tg3_enable_nvram_access(struct tg3 *tp)
 {
-	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_PROTECTED_NVRAM)) {
+	if (tg3_flag(tp, 5750_PLUS) && !tg3_flag(tp, PROTECTED_NVRAM)) {
 		u32 nvaccess = tr32(NVRAM_ACCESS);
 
 		tw32(NVRAM_ACCESS, nvaccess | ACCESS_ENABLE);
@@ -2404,8 +2418,7 @@ static void tg3_enable_nvram_access(struct tg3 *tp)
 /* tp->lock is held. */
 static void tg3_disable_nvram_access(struct tg3 *tp)
 {
-	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_PROTECTED_NVRAM)) {
+	if (tg3_flag(tp, 5750_PLUS) && !tg3_flag(tp, PROTECTED_NVRAM)) {
 		u32 nvaccess = tr32(NVRAM_ACCESS);
 
 		tw32(NVRAM_ACCESS, nvaccess & ~ACCESS_ENABLE);
@@ -2475,10 +2488,10 @@ static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 
 static u32 tg3_nvram_phys_addr(struct tg3 *tp, u32 addr)
 {
-	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
-	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
-	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
-	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
+	if (tg3_flag(tp, NVRAM) &&
+	    tg3_flag(tp, NVRAM_BUFFERED) &&
+	    tg3_flag(tp, FLASH) &&
+	    !tg3_flag(tp, NO_NVRAM_ADDR_TRANS) &&
 	    (tp->nvram_jedecnum == JEDEC_ATMEL))
 
 		addr = ((addr / tp->nvram_pagesize) <<
@@ -2490,10 +2503,10 @@ static u32 tg3_nvram_phys_addr(struct tg3 *tp, u32 addr)
 
 static u32 tg3_nvram_logical_addr(struct tg3 *tp, u32 addr)
 {
-	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
-	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
-	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
-	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
+	if (tg3_flag(tp, NVRAM) &&
+	    tg3_flag(tp, NVRAM_BUFFERED) &&
+	    tg3_flag(tp, FLASH) &&
+	    !tg3_flag(tp, NO_NVRAM_ADDR_TRANS) &&
 	    (tp->nvram_jedecnum == JEDEC_ATMEL))
 
 		addr = ((addr >> ATMEL_AT45DB0X1B_PAGE_POS) *
@@ -2513,7 +2526,7 @@ static int tg3_nvram_read(struct tg3 *tp, u32 offset, u32 *val)
 {
 	int ret;
 
-	if (!(tp->tg3_flags & TG3_FLAG_NVRAM))
+	if (!tg3_flag(tp, NVRAM))
 		return tg3_nvram_read_using_eeprom(tp, offset, val);
 
 	offset = tg3_nvram_phys_addr(tp, offset);
@@ -2605,7 +2618,7 @@ static int tg3_power_up(struct tg3 *tp)
 	pci_set_power_state(tp->pdev, PCI_D0);
 
 	/* Switch out of Vaux if it is a NIC */
-	if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
+	if (tg3_flag(tp, IS_NIC))
 		tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl, 100);
 
 	return 0;
@@ -2619,7 +2632,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 	tg3_enable_register_access(tp);
 
 	/* Restore the CLKREQ setting. */
-	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
+	if (tg3_flag(tp, CLKREQ_BUG)) {
 		u16 lnkctl;
 
 		pci_read_config_word(tp->pdev,
@@ -2636,9 +2649,9 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
 
 	device_should_wake = device_may_wakeup(&tp->pdev->dev) &&
-			     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+			     tg3_flag(tp, WOL_ENABLE);
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		do_low_power = false;
 		if ((tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) &&
 		    !(tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
@@ -2659,9 +2672,8 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 				      ADVERTISED_Autoneg |
 				      ADVERTISED_10baseT_Half;
 
-			if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-			    device_should_wake) {
-				if (tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB)
+			if (tg3_flag(tp, ENABLE_ASF) || device_should_wake) {
+				if (tg3_flag(tp, WOL_SPEED_100MB))
 					advertising |=
 						ADVERTISED_100baseT_Half |
 						ADVERTISED_100baseT_Full |
@@ -2706,7 +2718,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 		val = tr32(GRC_VCPU_EXT_CTRL);
 		tw32(GRC_VCPU_EXT_CTRL, val | GRC_VCPU_EXT_CTRL_DISABLE_WOL);
-	} else if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
+	} else if (!tg3_flag(tp, ENABLE_ASF)) {
 		int i;
 		u32 val;
 
@@ -2717,7 +2729,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			msleep(1);
 		}
 	}
-	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
+	if (tg3_flag(tp, WOL_CAP))
 		tg3_write_mem(tp, NIC_SRAM_WOL_MBOX, WOL_SIGNATURE |
 						     WOL_DRV_STATE_SHUTDOWN |
 						     WOL_DRV_WOL |
@@ -2745,8 +2757,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			mac_mode |= tp->mac_mode & MAC_MODE_LINK_POLARITY;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
 			    ASIC_REV_5700) {
-				u32 speed = (tp->tg3_flags &
-					     TG3_FLAG_WOL_SPEED_100MB) ?
+				u32 speed = tg3_flag(tp, WOL_SPEED_100MB) ?
 					     SPEED_100 : SPEED_10;
 				if (tg3_5700_link_polarity(tp, speed))
 					mac_mode |= MAC_MODE_LINK_POLARITY;
@@ -2757,17 +2768,15 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 			mac_mode = MAC_MODE_PORT_MODE_TBI;
 		}
 
-		if (!(tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
+		if (!tg3_flag(tp, 5750_PLUS))
 			tw32(MAC_LED_CTRL, tp->led_ctrl);
 
 		mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
-		if (((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-		    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) &&
-		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-		     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)))
+		if ((tg3_flag(tp, 5705_PLUS) && !tg3_flag(tp, 5780_CLASS)) &&
+		    (tg3_flag(tp, ENABLE_ASF) || tg3_flag(tp, ENABLE_APE)))
 			mac_mode |= MAC_MODE_KEEP_FRAME_IN_WOL;
 
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		if (tg3_flag(tp, ENABLE_APE))
 			mac_mode |= MAC_MODE_APE_TX_EN |
 				    MAC_MODE_APE_RX_EN |
 				    MAC_MODE_TDE_ENABLE;
@@ -2779,7 +2788,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 		udelay(10);
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB) &&
+	if (!tg3_flag(tp, WOL_SPEED_100MB) &&
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)) {
 		u32 base_val;
@@ -2790,12 +2799,11 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 		tw32_wait_f(TG3PCI_CLOCK_CTRL, base_val | CLOCK_CTRL_ALTCLK |
 			    CLOCK_CTRL_PWRDOWN_PLL133, 40);
-	} else if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
-		   (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
+	} else if (tg3_flag(tp, 5780_CLASS) ||
+		   tg3_flag(tp, CPMU_PRESENT) ||
 		   (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)) {
 		/* do nothing */
-	} else if (!((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-		     (tp->tg3_flags & TG3_FLAG_ENABLE_ASF))) {
+	} else if (!(tg3_flag(tp, 5750_PLUS) && tg3_flag(tp, ENABLE_ASF))) {
 		u32 newbits1, newbits2;
 
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
@@ -2804,7 +2812,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 				    CLOCK_CTRL_TXCLK_DISABLE |
 				    CLOCK_CTRL_ALTCLK);
 			newbits2 = newbits1 | CLOCK_CTRL_44MHZ_CORE;
-		} else if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+		} else if (tg3_flag(tp, 5705_PLUS)) {
 			newbits1 = CLOCK_CTRL_625_CORE;
 			newbits2 = newbits1 | CLOCK_CTRL_ALTCLK;
 		} else {
@@ -2818,7 +2826,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 		tw32_wait_f(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl | newbits2,
 			    40);
 
-		if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+		if (!tg3_flag(tp, 5705_PLUS)) {
 			u32 newbits3;
 
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
@@ -2835,8 +2843,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 		}
 	}
 
-	if (!(device_should_wake) &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+	if (!(device_should_wake) && !tg3_flag(tp, ENABLE_ASF))
 		tg3_power_down_phy(tp, do_low_power);
 
 	tg3_frob_aux_power(tp);
@@ -2848,7 +2855,7 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 		val &= ~((1 << 16) | (1 << 4) | (1 << 2) | (1 << 1) | 1);
 		tw32(0x7d00, val);
-		if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
+		if (!tg3_flag(tp, ENABLE_ASF)) {
 			int err;
 
 			err = tg3_nvram_lock(tp);
@@ -2867,7 +2874,7 @@ static void tg3_power_down(struct tg3 *tp)
 {
 	tg3_power_down_prepare(tp);
 
-	pci_wake_from_d3(tp->pdev, tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+	pci_wake_from_d3(tp->pdev, tg3_flag(tp, WOL_ENABLE));
 	pci_set_power_state(tp->pdev, PCI_D3hot);
 }
 
@@ -2931,7 +2938,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 
 		new_adv = (ADVERTISE_10HALF | ADVERTISE_10FULL |
 			   ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-		if (tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB)
+		if (tg3_flag(tp, WOL_SPEED_100MB))
 			new_adv |= (ADVERTISE_100HALF | ADVERTISE_100FULL);
 
 		tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3163,7 +3170,7 @@ static int tg3_adv_1000T_flowctrl_ok(struct tg3 *tp, u32 *lcladv, u32 *rmtadv)
 		if (curadv != reqadv)
 			return 0;
 
-		if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)
+		if (tg3_flag(tp, PAUSE_AUTONEG))
 			tg3_readphy(tp, MII_LPA, rmtadv);
 	} else {
 		/* Reprogram the advertisement register, even if it
@@ -3226,7 +3233,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	if ((tp->phy_id & TG3_PHY_ID_MASK) == TG3_PHY_ID_BCM5401) {
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (tg3_readphy(tp, MII_BMSR, &bmsr) ||
-		    !(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE))
+		    !tg3_flag(tp, INIT_COMPLETE))
 			bmsr = 0;
 
 		if (!(bmsr & BMSR_LSTATUS)) {
@@ -3410,7 +3417,7 @@ relink:
 
 	tg3_phy_eee_adjust(tp, current_link_up);
 
-	if (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) {
+	if (tg3_flag(tp, USE_LINKCHG_REG)) {
 		/* Polled via timer. */
 		tw32_f(MAC_EVENT, 0);
 	} else {
@@ -3421,8 +3428,7 @@ relink:
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 &&
 	    current_link_up == 1 &&
 	    tp->link_config.active_speed == SPEED_1000 &&
-	    ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) ||
-	     (tp->tg3_flags & TG3_FLAG_PCI_HIGH_SPEED))) {
+	    (tg3_flag(tp, PCIX_MODE) || tg3_flag(tp, PCI_HIGH_SPEED))) {
 		udelay(120);
 		tw32_f(MAC_STATUS,
 		     (MAC_STATUS_SYNC_CHANGED |
@@ -3434,7 +3440,7 @@ relink:
 	}
 
 	/* Prevent send BD corruption. */
-	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
+	if (tg3_flag(tp, CLKREQ_BUG)) {
 		u16 oldlnkctl, newlnkctl;
 
 		pci_read_config_word(tp->pdev,
@@ -3829,7 +3835,7 @@ static void tg3_init_bcm8002(struct tg3 *tp)
 	int i;
 
 	/* Reset when initting first time or we have a link. */
-	if ((tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) &&
+	if (tg3_flag(tp, INIT_COMPLETE) &&
 	    !(mac_status & MAC_STATUS_PCS_SYNCED))
 		return;
 
@@ -4090,9 +4096,9 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	orig_active_speed = tp->link_config.active_speed;
 	orig_active_duplex = tp->link_config.active_duplex;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_HW_AUTONEG) &&
+	if (!tg3_flag(tp, HW_AUTONEG) &&
 	    netif_carrier_ok(tp->dev) &&
-	    (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE)) {
+	    tg3_flag(tp, INIT_COMPLETE)) {
 		mac_status = tr32(MAC_STATUS);
 		mac_status &= (MAC_STATUS_PCS_SYNCED |
 			       MAC_STATUS_SIGNAL_DET |
@@ -4123,7 +4129,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	current_link_up = 0;
 	mac_status = tr32(MAC_STATUS);
 
-	if (tp->tg3_flags2 & TG3_FLG2_HW_AUTONEG)
+	if (tg3_flag(tp, HW_AUTONEG))
 		current_link_up = tg3_setup_fiber_hw_autoneg(tp, mac_status);
 	else
 		current_link_up = tg3_setup_fiber_by_hand(tp, mac_status);
@@ -4322,7 +4328,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
-			} else if (!(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+			} else if (!tg3_flag(tp, 5780_CLASS)) {
 				/* Link is up via parallel detect */
 			} else {
 				current_link_up = 0;
@@ -4460,7 +4466,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		tw32(MAC_TX_LENGTHS, val |
 		     (32 << TX_LENGTHS_SLOT_TIME_SHIFT));
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		if (netif_carrier_ok(tp->dev)) {
 			tw32(HOSTCC_STAT_COAL_TICKS,
 			     tp->coal.stats_block_coalesce_usecs);
@@ -4469,7 +4475,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		}
 	}
 
-	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND) {
+	if (tg3_flag(tp, ASPM_WORKAROUND)) {
 		val = tr32(PCIE_PWR_MGMT_THRESH);
 		if (!netif_carrier_ok(tp->dev))
 			val = (val & ~PCIE_PWR_MGMT_L1_THRESH_MSK) |
@@ -4518,7 +4524,7 @@ static void tg3_dump_legacy_regs(struct tg3 *tp, u32 *regs)
 	tg3_rd32_loop(tp, regs, MBFREE_MODE, 0x08);
 	tg3_rd32_loop(tp, regs, HOSTCC_MODE, 0x100);
 
-	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX)
+	if (tg3_flag(tp, SUPPORT_MSIX))
 		tg3_rd32_loop(tp, regs, HOSTCC_RXCOL_TICKS_VEC1, 0x180);
 
 	tg3_rd32_loop(tp, regs, MEMARB_MODE, 0x10);
@@ -4530,7 +4536,7 @@ static void tg3_dump_legacy_regs(struct tg3 *tp, u32 *regs)
 	tg3_rd32_loop(tp, regs, RX_CPU_PGMCTR, 0x04);
 	tg3_rd32_loop(tp, regs, RX_CPU_HWBKPT, 0x04);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		tg3_rd32_loop(tp, regs, TX_CPU_MODE, 0x04);
 		tg3_rd32_loop(tp, regs, TX_CPU_STATE, 0x04);
 		tg3_rd32_loop(tp, regs, TX_CPU_PGMCTR, 0x04);
@@ -4542,7 +4548,7 @@ static void tg3_dump_legacy_regs(struct tg3 *tp, u32 *regs)
 	tg3_rd32_loop(tp, regs, DMAC_MODE, 0x04);
 	tg3_rd32_loop(tp, regs, GRC_MODE, 0x4c);
 
-	if (tp->tg3_flags & TG3_FLAG_NVRAM)
+	if (tg3_flag(tp, NVRAM))
 		tg3_rd32_loop(tp, regs, NVRAM_CMD, 0x24);
 }
 
@@ -4557,7 +4563,7 @@ static void tg3_dump_state(struct tg3 *tp)
 		return;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	if (tg3_flag(tp, PCI_EXPRESS)) {
 		/* Read up to but not including private PCI registers */
 		for (i = 0; i < TG3_PCIE_TLDLPL_PORT; i += sizeof(u32))
 			regs[i / sizeof(u32)] = tr32(i);
@@ -4612,7 +4618,7 @@ static void tg3_dump_state(struct tg3 *tp)
  */
 static void tg3_tx_recover(struct tg3 *tp)
 {
-	BUG_ON((tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER) ||
+	BUG_ON(tg3_flag(tp, MBOX_WRITE_REORDER) ||
 	       tp->write32_tx_mbox == tg3_write_indirect_mbox);
 
 	netdev_warn(tp->dev,
@@ -4622,7 +4628,7 @@ static void tg3_tx_recover(struct tg3 *tp)
 		    "and include system chipset information.\n");
 
 	spin_lock(&tp->lock);
-	tp->tg3_flags |= TG3_FLAG_TX_RECOVERY_PENDING;
+	tg3_flag_set(tp, TX_RECOVERY_PENDING);
 	spin_unlock(&tp->lock);
 }
 
@@ -4646,7 +4652,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	struct netdev_queue *txq;
 	int index = tnapi - tp->napi;
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+	if (tg3_flag(tp, ENABLE_TSS))
 		index--;
 
 	txq = netdev_get_tx_queue(tp->dev, index);
@@ -5014,7 +5020,7 @@ next_pkt_nopost:
 	tw32_rx_mbox(tnapi->consmbox, sw_idx);
 
 	/* Refill RX ring(s). */
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)) {
+	if (!tg3_flag(tp, ENABLE_RSS)) {
 		if (work_mask & RXD_OPAQUE_RING_STD) {
 			tpr->rx_std_prod_idx = std_prod_idx &
 					       tp->rx_std_ring_mask;
@@ -5047,16 +5053,14 @@ next_pkt_nopost:
 static void tg3_poll_link(struct tg3 *tp)
 {
 	/* handle link change and other phy events */
-	if (!(tp->tg3_flags &
-	      (TG3_FLAG_USE_LINKCHG_REG |
-	       TG3_FLAG_POLL_SERDES))) {
+	if (!(tg3_flag(tp, USE_LINKCHG_REG) || tg3_flag(tp, POLL_SERDES))) {
 		struct tg3_hw_status *sblk = tp->napi[0].hw_status;
 
 		if (sblk->status & SD_STATUS_LINK_CHG) {
 			sblk->status = SD_STATUS_UPDATED |
 				       (sblk->status & ~SD_STATUS_LINK_CHG);
 			spin_lock(&tp->lock);
-			if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+			if (tg3_flag(tp, USE_PHYLIB)) {
 				tw32_f(MAC_STATUS,
 				     (MAC_STATUS_SYNC_CHANGED |
 				      MAC_STATUS_CFG_CHANGED |
@@ -5203,7 +5207,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	/* run TX completion thread */
 	if (tnapi->hw_status->idx[0].tx_consumer != tnapi->tx_cons) {
 		tg3_tx(tnapi);
-		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
+		if (unlikely(tg3_flag(tp, TX_RECOVERY_PENDING)))
 			return work_done;
 	}
 
@@ -5214,7 +5218,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	if (*(tnapi->rx_rcb_prod_idx) != tnapi->rx_rcb_ptr)
 		work_done += tg3_rx(tnapi, budget - work_done);
 
-	if ((tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) && tnapi == &tp->napi[1]) {
+	if (tg3_flag(tp, ENABLE_RSS) && tnapi == &tp->napi[1]) {
 		struct tg3_rx_prodring_set *dpr = &tp->napi[0].prodring;
 		int i, err = 0;
 		u32 std_prod_idx = dpr->rx_std_prod_idx;
@@ -5253,7 +5257,7 @@ static int tg3_poll_msix(struct napi_struct *napi, int budget)
 	while (1) {
 		work_done = tg3_poll_work(tnapi, work_done, budget);
 
-		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
+		if (unlikely(tg3_flag(tp, TX_RECOVERY_PENDING)))
 			goto tx_recovery;
 
 		if (unlikely(work_done >= budget))
@@ -5292,7 +5296,7 @@ static void tg3_process_error(struct tg3 *tp)
 	u32 val;
 	bool real_error = false;
 
-	if (tp->tg3_flags & TG3_FLAG_ERROR_PROCESSED)
+	if (tg3_flag(tp, ERROR_PROCESSED))
 		return;
 
 	/* Check Flow Attention register */
@@ -5317,7 +5321,7 @@ static void tg3_process_error(struct tg3 *tp)
 
 	tg3_dump_state(tp);
 
-	tp->tg3_flags |= TG3_FLAG_ERROR_PROCESSED;
+	tg3_flag_set(tp, ERROR_PROCESSED);
 	schedule_work(&tp->reset_task);
 }
 
@@ -5336,13 +5340,13 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 
 		work_done = tg3_poll_work(tnapi, work_done, budget);
 
-		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
+		if (unlikely(tg3_flag(tp, TX_RECOVERY_PENDING)))
 			goto tx_recovery;
 
 		if (unlikely(work_done >= budget))
 			break;
 
-		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
+		if (tg3_flag(tp, TAGGED_STATUS)) {
 			/* tp->last_tag is used in tg3_int_reenable() below
 			 * to tell the hw how much work has been processed,
 			 * so we must read it before checking for more work.
@@ -5509,7 +5513,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	 * interrupt is ours and will flush the status block.
 	 */
 	if (unlikely(!(sblk->status & SD_STATUS_UPDATED))) {
-		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
+		if (tg3_flag(tp, CHIP_RESETTING) ||
 		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 			handled = 0;
 			goto out;
@@ -5558,7 +5562,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * interrupt is ours and will flush the status block.
 	 */
 	if (unlikely(sblk->status_tag == tnapi->last_irq_tag)) {
-		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
+		if (tg3_flag(tp, CHIP_RESETTING) ||
 		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 			handled = 0;
 			goto out;
@@ -5671,14 +5675,14 @@ static void tg3_reset_task(struct work_struct *work)
 
 	tg3_full_lock(tp, 1);
 
-	restart_timer = tp->tg3_flags2 & TG3_FLG2_RESTART_TIMER;
-	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
+	restart_timer = tg3_flag(tp, RESTART_TIMER);
+	tg3_flag_clear(tp, RESTART_TIMER);
 
-	if (tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING) {
+	if (tg3_flag(tp, TX_RECOVERY_PENDING)) {
 		tp->write32_tx_mbox = tg3_write32_tx_mbox;
 		tp->write32_rx_mbox = tg3_write_flush_reg32;
-		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
-		tp->tg3_flags &= ~TG3_FLAG_TX_RECOVERY_PENDING;
+		tg3_flag_set(tp, MBOX_WRITE_REORDER);
+		tg3_flag_clear(tp, TX_RECOVERY_PENDING);
 	}
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
@@ -5723,7 +5727,7 @@ static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 					  int len)
 {
 #if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
-	if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG)
+	if (tg3_flag(tp, 40BIT_DMA_BUG))
 		return ((u64) mapping + len) > DMA_BIT_MASK(40);
 	return 0;
 #else
@@ -5770,8 +5774,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
 		 */
-		} else if ((tp->tg3_flags3 & TG3_FLG3_4G_DMA_BNDRY_BUG) &&
-			    tg3_4g_overflow_test(new_addr, new_skb->len)) {
+		} else if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
+			   tg3_4g_overflow_test(new_addr, new_skb->len)) {
 			pci_unmap_single(tp->pdev, new_addr, new_skb->len,
 					 PCI_DMA_TODEVICE);
 			ret = -1;
@@ -5838,7 +5842,7 @@ static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
 }
 
 /* hard_start_xmit for devices that don't have any bugs and
- * support TG3_FLG2_HW_TSO_2 and TG3_FLG2_HW_TSO_3 only.
+ * support TG3_FLAG_HW_TSO_2 and TG3_FLAG_HW_TSO_3 only.
  */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 				  struct net_device *dev)
@@ -5852,7 +5856,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+	if (tg3_flag(tp, ENABLE_TSS))
 		tnapi++;
 
 	/* We are running in BH disabled context with netif_tx_lock
@@ -5897,7 +5901,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			hdrlen = ip_tcp_len + tcp_opt_len;
 		}
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
+		if (tg3_flag(tp, HW_TSO_3)) {
 			mss |= (hdrlen & 0xc) << 12;
 			if (hdrlen & 0x10)
 				base_flags |= 0x00000010;
@@ -5930,7 +5934,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	tnapi->tx_buffers[entry].skb = skb;
 	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
 
-	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
+	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
 		base_flags |= TXD_FLAG_JMB_PKT;
 
@@ -6053,7 +6057,7 @@ tg3_tso_bug_end:
 }
 
 /* hard_start_xmit for devices that have the 4G bug and/or 40-bit bug and
- * support TG3_FLG2_HW_TSO_1 or firmware TSO only.
+ * support TG3_FLAG_HW_TSO_1 or firmware TSO only.
  */
 static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 					  struct net_device *dev)
@@ -6068,7 +6072,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+	if (tg3_flag(tp, ENABLE_TSS))
 		tnapi++;
 
 	/* We are running in BH disabled context with netif_tx_lock
@@ -6119,13 +6123,15 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		}
 
 		if (unlikely((ETH_HLEN + hdr_len) > 80) &&
-			     (tp->tg3_flags2 & TG3_FLG2_TSO_BUG))
+		    tg3_flag(tp, TSO_BUG))
 			return tg3_tso_bug(tp, skb);
 
 		base_flags |= (TXD_FLAG_CPU_PRE_DMA |
 			       TXD_FLAG_CPU_POST_DMA);
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
+		if (tg3_flag(tp, HW_TSO_1) ||
+		    tg3_flag(tp, HW_TSO_2) ||
+		    tg3_flag(tp, HW_TSO_3)) {
 			tcp_hdr(skb)->check = 0;
 			base_flags &= ~TXD_FLAG_TCPUDP_CSUM;
 		} else
@@ -6134,14 +6140,14 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 								 IPPROTO_TCP,
 								 0);
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
+		if (tg3_flag(tp, HW_TSO_3)) {
 			mss |= (hdr_len & 0xc) << 12;
 			if (hdr_len & 0x10)
 				base_flags |= 0x00000010;
 			base_flags |= (hdr_len & 0x3e0) << 5;
-		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+		} else if (tg3_flag(tp, HW_TSO_2))
 			mss |= hdr_len << 9;
-		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
+		else if (tg3_flag(tp, HW_TSO_1) ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
 			if (tcp_opt_len || iph->ihl > 5) {
 				int tsflags;
@@ -6163,7 +6169,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		base_flags |= (TXD_FLAG_VLAN |
 			       (vlan_tx_tag_get(skb) << 16));
 
-	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
+	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&
 	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
 		base_flags |= TXD_FLAG_JMB_PKT;
 
@@ -6180,18 +6186,18 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 
 	would_hit_hwbug = 0;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_SHORT_DMA_BUG) && len <= 8)
+	if (tg3_flag(tp, SHORT_DMA_BUG) && len <= 8)
 		would_hit_hwbug = 1;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_4G_DMA_BNDRY_BUG) &&
+	if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
 	    tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_40BIT_DMA_LIMIT_BUG) &&
+	if (tg3_flag(tp, 40BIT_DMA_LIMIT_BUG) &&
 	    tg3_40bit_overflow_test(tp, mapping, len))
 		would_hit_hwbug = 1;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5701_DMA_BUG)
+	if (tg3_flag(tp, 5701_DMA_BUG))
 		would_hit_hwbug = 1;
 
 	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
@@ -6217,19 +6223,21 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			if (pci_dma_mapping_error(tp->pdev, mapping))
 				goto dma_error;
 
-			if ((tp->tg3_flags3 & TG3_FLG3_SHORT_DMA_BUG) &&
+			if (tg3_flag(tp, SHORT_DMA_BUG) &&
 			    len <= 8)
 				would_hit_hwbug = 1;
 
-			if ((tp->tg3_flags3 & TG3_FLG3_4G_DMA_BNDRY_BUG) &&
+			if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
 			    tg3_4g_overflow_test(mapping, len))
 				would_hit_hwbug = 1;
 
-			if ((tp->tg3_flags3 & TG3_FLG3_40BIT_DMA_LIMIT_BUG) &&
+			if (tg3_flag(tp, 40BIT_DMA_LIMIT_BUG) &&
 			    tg3_40bit_overflow_test(tp, mapping, len))
 				would_hit_hwbug = 1;
 
-			if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+			if (tg3_flag(tp, HW_TSO_1) ||
+			    tg3_flag(tp, HW_TSO_2) ||
+			    tg3_flag(tp, HW_TSO_3))
 				tg3_set_txd(tnapi, entry, mapping, len,
 					    base_flags, (i == last)|(mss << 1));
 			else
@@ -6305,7 +6313,7 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (dev->mtu > ETH_DATA_LEN && (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	if (dev->mtu > ETH_DATA_LEN && tg3_flag(tp, 5780_CLASS))
 		features &= ~NETIF_F_ALL_TSO;
 
 	return features;
@@ -6317,18 +6325,18 @@ static inline void tg3_set_mtu(struct net_device *dev, struct tg3 *tp,
 	dev->mtu = new_mtu;
 
 	if (new_mtu > ETH_DATA_LEN) {
-		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
+		if (tg3_flag(tp, 5780_CLASS)) {
 			netdev_update_features(dev);
-			tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
+			tg3_flag_clear(tp, TSO_CAPABLE);
 		} else {
-			tp->tg3_flags |= TG3_FLAG_JUMBO_RING_ENABLE;
+			tg3_flag_set(tp, JUMBO_RING_ENABLE);
 		}
 	} else {
-		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
-			tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+		if (tg3_flag(tp, 5780_CLASS)) {
+			tg3_flag_set(tp, TSO_CAPABLE);
 			netdev_update_features(dev);
 		}
-		tp->tg3_flags &= ~TG3_FLAG_JUMBO_RING_ENABLE;
+		tg3_flag_clear(tp, JUMBO_RING_ENABLE);
 	}
 }
 
@@ -6382,7 +6390,7 @@ static void tg3_rx_prodring_free(struct tg3 *tp,
 			tg3_rx_skb_free(tp, &tpr->rx_std_buffers[i],
 					tp->rx_pkt_map_sz);
 
-		if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+		if (tg3_flag(tp, JUMBO_CAPABLE)) {
 			for (i = tpr->rx_jmb_cons_idx;
 			     i != tpr->rx_jmb_prod_idx;
 			     i = (i + 1) & tp->rx_jmb_ring_mask) {
@@ -6398,8 +6406,7 @@ static void tg3_rx_prodring_free(struct tg3 *tp,
 		tg3_rx_skb_free(tp, &tpr->rx_std_buffers[i],
 				tp->rx_pkt_map_sz);
 
-	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+	if (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS)) {
 		for (i = 0; i <= tp->rx_jmb_ring_mask; i++)
 			tg3_rx_skb_free(tp, &tpr->rx_jmb_buffers[i],
 					TG3_RX_JMB_MAP_SZ);
@@ -6436,7 +6443,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 	memset(tpr->rx_std, 0, TG3_RX_STD_RING_BYTES(tp));
 
 	rx_pkt_dma_sz = TG3_RX_STD_DMA_SZ;
-	if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) &&
+	if (tg3_flag(tp, 5780_CLASS) &&
 	    tp->dev->mtu > ETH_DATA_LEN)
 		rx_pkt_dma_sz = TG3_RX_JMB_DMA_SZ;
 	tp->rx_pkt_map_sz = TG3_RX_DMA_TO_MAP_SZ(rx_pkt_dma_sz);
@@ -6469,13 +6476,12 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 		}
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	if (!tg3_flag(tp, JUMBO_CAPABLE) || tg3_flag(tp, 5780_CLASS))
 		goto done;
 
 	memset(tpr->rx_jmb, 0, TG3_RX_JMB_RING_BYTES(tp));
 
-	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE))
+	if (!tg3_flag(tp, JUMBO_RING_ENABLE))
 		goto done;
 
 	for (i = 0; i <= tp->rx_jmb_ring_mask; i++) {
@@ -6544,8 +6550,7 @@ static int tg3_rx_prodring_init(struct tg3 *tp,
 	if (!tpr->rx_std)
 		goto err_out;
 
-	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+	if (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS)) {
 		tpr->rx_jmb_buffers = kzalloc(TG3_RX_JMB_BUFF_RING_SIZE(tp),
 					      GFP_KERNEL);
 		if (!tpr->rx_jmb_buffers)
@@ -6743,8 +6748,8 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		/* If multivector TSS is enabled, vector 0 does not handle
 		 * tx interrupts.  Don't allocate any resources for it.
 		 */
-		if ((!i && !(tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)) ||
-		    (i && (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS))) {
+		if ((!i && !tg3_flag(tp, ENABLE_TSS)) ||
+		    (i && tg3_flag(tp, ENABLE_TSS))) {
 			tnapi->tx_buffers = kzalloc(sizeof(struct ring_info) *
 						    TG3_TX_RING_SIZE,
 						    GFP_KERNEL);
@@ -6784,7 +6789,7 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		 * If multivector RSS is enabled, vector 0 does not handle
 		 * rx or tx interrupts.  Don't allocate any resources for it.
 		 */
-		if (!i && (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS))
+		if (!i && tg3_flag(tp, ENABLE_RSS))
 			continue;
 
 		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
@@ -6814,7 +6819,7 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int
 	unsigned int i;
 	u32 val;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tg3_flag(tp, 5705_PLUS)) {
 		switch (ofs) {
 		case RCVLSC_MODE:
 		case DMAC_MODE:
@@ -6924,7 +6929,7 @@ static void tg3_ape_send_event(struct tg3 *tp, u32 event)
 	u32 apedata;
 
 	/* NCSI does not support APE events */
-	if (tp->tg3_flags3 & TG3_FLG3_APE_HAS_NCSI)
+	if (tg3_flag(tp, APE_HAS_NCSI))
 		return;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
@@ -6963,7 +6968,7 @@ static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
 	u32 event;
 	u32 apedata;
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+	if (!tg3_flag(tp, ENABLE_APE))
 		return;
 
 	switch (kind) {
@@ -6992,7 +6997,7 @@ static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
 		tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG, 0x0);
 
 		if (device_may_wakeup(&tp->pdev->dev) &&
-		    (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
+		    tg3_flag(tp, WOL_ENABLE)) {
 			tg3_ape_write32(tp, TG3_APE_HOST_WOL_SPEED,
 					    TG3_APE_HOST_WOL_SPEED_AUTO);
 			apedata = TG3_APE_HOST_DRVR_STATE_WOL;
@@ -7021,7 +7026,7 @@ static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 	tg3_write_mem(tp, NIC_SRAM_FIRMWARE_MBOX,
 		      NIC_SRAM_FIRMWARE_MBOX_MAGIC1);
 
-	if (tp->tg3_flags2 & TG3_FLG2_ASF_NEW_HANDSHAKE) {
+	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
 		switch (kind) {
 		case RESET_KIND_INIT:
 			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
@@ -7051,7 +7056,7 @@ static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 /* tp->lock is held. */
 static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_ASF_NEW_HANDSHAKE) {
+	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
 		switch (kind) {
 		case RESET_KIND_INIT:
 			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
@@ -7075,7 +7080,7 @@ static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
 /* tp->lock is held. */
 static void tg3_write_sig_legacy(struct tg3 *tp, int kind)
 {
-	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+	if (tg3_flag(tp, ENABLE_ASF)) {
 		switch (kind) {
 		case RESET_KIND_INIT:
 			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
@@ -7126,9 +7131,8 @@ static int tg3_poll_fw(struct tg3 *tp)
 	 * of the above loop as an error, but do report the lack of
 	 * running firmware once.
 	 */
-	if (i >= 100000 &&
-	    !(tp->tg3_flags2 & TG3_FLG2_NO_FWARE_REPORTED)) {
-		tp->tg3_flags2 |= TG3_FLG2_NO_FWARE_REPORTED;
+	if (i >= 100000 && !tg3_flag(tp, NO_FWARE_REPORTED)) {
+		tg3_flag_set(tp, NO_FWARE_REPORTED);
 
 		netdev_info(tp->dev, "No firmware running\n");
 	}
@@ -7161,10 +7165,10 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	/* Set MAX PCI retry to zero. */
 	val = (PCISTATE_ROM_ENABLE | PCISTATE_ROM_RETRY_ENABLE);
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE))
+	    tg3_flag(tp, PCIX_MODE))
 		val |= PCISTATE_RETRY_SAME_DMA;
 	/* Allow reads and writes to the APE register and memory space. */
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+	if (tg3_flag(tp, ENABLE_APE))
 		val |= PCISTATE_ALLOW_APE_CTLSPC_WR |
 		       PCISTATE_ALLOW_APE_SHMEM_WR |
 		       PCISTATE_ALLOW_APE_PSPACE_WR;
@@ -7173,7 +7177,7 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
-		if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
+		if (tg3_flag(tp, PCI_EXPRESS))
 			pcie_set_readrq(tp->pdev, tp->pcie_readrq);
 		else {
 			pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
@@ -7184,7 +7188,7 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	}
 
 	/* Make sure PCI-X relaxed ordering bit is clear. */
-	if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
+	if (tg3_flag(tp, PCIX_MODE)) {
 		u16 pcix_cmd;
 
 		pci_read_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
@@ -7194,12 +7198,12 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 				      pcix_cmd);
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
+	if (tg3_flag(tp, 5780_CLASS)) {
 
 		/* Chip reset on 5780 will reset MSI enable bit,
 		 * so need to restore it.
 		 */
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
+		if (tg3_flag(tp, USING_MSI)) {
 			u16 ctrl;
 
 			pci_read_config_word(tp->pdev,
@@ -7239,7 +7243,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	tg3_save_pci_state(tp);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5755_PLUS))
+	    tg3_flag(tp, 5755_PLUS))
 		tw32(GRC_FASTBOOT_PC, 0);
 
 	/*
@@ -7258,7 +7262,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 * at this time, but the irq handler may still be called due to irq
 	 * sharing or irqpoll.
 	 */
-	tp->tg3_flags |= TG3_FLAG_CHIP_RESETTING;
+	tg3_flag_set(tp, CHIP_RESETTING);
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		if (tnapi->hw_status) {
@@ -7281,10 +7285,10 @@ static int tg3_chip_reset(struct tg3 *tp)
 	/* do the reset */
 	val = GRC_MISC_CFG_CORECLK_RESET;
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	if (tg3_flag(tp, PCI_EXPRESS)) {
 		/* Force PCIe 1.0a mode */
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-		    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
+		    !tg3_flag(tp, 57765_PLUS) &&
 		    tr32(TG3_PCIE_PHY_TSTCTL) ==
 		    (TG3_PCIE_PHY_TSTCTL_PCIE10 | TG3_PCIE_PHY_TSTCTL_PSCRAM))
 			tw32(TG3_PCIE_PHY_TSTCTL, TG3_PCIE_PHY_TSTCTL_PSCRAM);
@@ -7302,8 +7306,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	}
 
 	/* Manage gphy power for all CPMU absent PCIe devices. */
-	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-	    !(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
+	if (tg3_flag(tp, 5705_PLUS) && !tg3_flag(tp, CPMU_PRESENT))
 		val |= GRC_MISC_CFG_KEEP_GPHY_POWER;
 
 	tw32(GRC_MISC_CFG, val);
@@ -7336,7 +7339,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	udelay(120);
 
-	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) && tp->pcie_cap) {
+	if (tg3_flag(tp, PCI_EXPRESS) && tp->pcie_cap) {
 		u16 val16;
 
 		if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
@@ -7362,7 +7365,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 		 * Older PCIe devices only support the 128 byte
 		 * MPS setting.  Enforce the restriction.
 		 */
-		if (!(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
+		if (!tg3_flag(tp, CPMU_PRESENT))
 			val16 &= ~PCI_EXP_DEVCTL_PAYLOAD;
 		pci_write_config_word(tp->pdev,
 				      tp->pcie_cap + PCI_EXP_DEVCTL,
@@ -7381,11 +7384,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_restore_pci_state(tp);
 
-	tp->tg3_flags &= ~(TG3_FLAG_CHIP_RESETTING |
-			   TG3_FLAG_ERROR_PROCESSED);
+	tg3_flag_clear(tp, CHIP_RESETTING);
+	tg3_flag_clear(tp, ERROR_PROCESSED);
 
 	val = 0;
-	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
+	if (tg3_flag(tp, 5780_CLASS))
 		val = tr32(MEMARB_MODE);
 	tw32(MEMARB_MODE, val | MEMARB_MODE_ENABLE);
 
@@ -7410,7 +7413,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+	if (tg3_flag(tp, ENABLE_APE))
 		tp->mac_mode = MAC_MODE_APE_TX_EN |
 			       MAC_MODE_APE_RX_EN |
 			       MAC_MODE_TDE_ENABLE;
@@ -7435,10 +7438,10 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_mdio_start(tp);
 
-	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+	if (tg3_flag(tp, PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-	    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
+	    !tg3_flag(tp, 57765_PLUS)) {
 		val = tr32(0x7c00);
 
 		tw32(0x7c00, val | (1 << 25));
@@ -7450,18 +7453,18 @@ static int tg3_chip_reset(struct tg3 *tp)
 	}
 
 	/* Reprobe ASF enable state.  */
-	tp->tg3_flags &= ~TG3_FLAG_ENABLE_ASF;
-	tp->tg3_flags2 &= ~TG3_FLG2_ASF_NEW_HANDSHAKE;
+	tg3_flag_clear(tp, ENABLE_ASF);
+	tg3_flag_clear(tp, ASF_NEW_HANDSHAKE);
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
 	if (val == NIC_SRAM_DATA_SIG_MAGIC) {
 		u32 nic_cfg;
 
 		tg3_read_mem(tp, NIC_SRAM_DATA_CFG, &nic_cfg);
 		if (nic_cfg & NIC_SRAM_DATA_CFG_ASF_ENABLE) {
-			tp->tg3_flags |= TG3_FLAG_ENABLE_ASF;
+			tg3_flag_set(tp, ENABLE_ASF);
 			tp->last_event_jiffies = jiffies;
-			if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
-				tp->tg3_flags2 |= TG3_FLG2_ASF_NEW_HANDSHAKE;
+			if (tg3_flag(tp, 5750_PLUS))
+				tg3_flag_set(tp, ASF_NEW_HANDSHAKE);
 		}
 	}
 
@@ -7471,8 +7474,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 /* tp->lock is held. */
 static void tg3_stop_fw(struct tg3 *tp)
 {
-	if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
-	   !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
+	if (tg3_flag(tp, ENABLE_ASF) && !tg3_flag(tp, ENABLE_APE)) {
 		/* Wait for RX cpu to ACK the previous event. */
 		tg3_wait_for_event_ack(tp);
 
@@ -7518,8 +7520,7 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 {
 	int i;
 
-	BUG_ON(offset == TX_CPU_BASE &&
-	    (tp->tg3_flags2 & TG3_FLG2_5705_PLUS));
+	BUG_ON(offset == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS));
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		u32 val = tr32(GRC_VCPU_EXT_CTRL);
@@ -7554,7 +7555,7 @@ static int tg3_halt_cpu(struct tg3 *tp, u32 offset)
 	}
 
 	/* Clear firmware's nvram arbitration. */
-	if (tp->tg3_flags & TG3_FLAG_NVRAM)
+	if (tg3_flag(tp, NVRAM))
 		tw32(NVRAM_SWARB, SWARB_REQ_CLR0);
 	return 0;
 }
@@ -7572,15 +7573,14 @@ static int tg3_load_firmware_cpu(struct tg3 *tp, u32 cpu_base, u32 cpu_scratch_b
 	int err, lock_err, i;
 	void (*write_op)(struct tg3 *, u32, u32);
 
-	if (cpu_base == TX_CPU_BASE &&
-	    (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (cpu_base == TX_CPU_BASE && tg3_flag(tp, 5705_PLUS)) {
 		netdev_err(tp->dev,
 			   "%s: Trying to load TX cpu firmware which is 5705\n",
 			   __func__);
 		return -EINVAL;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+	if (tg3_flag(tp, 5705_PLUS))
 		write_op = tg3_write_mem;
 	else
 		write_op = tg3_write_indirect_reg32;
@@ -7674,7 +7674,9 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 	unsigned long cpu_base, cpu_scratch_base, cpu_scratch_size;
 	int err, i;
 
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+	if (tg3_flag(tp, HW_TSO_1) ||
+	    tg3_flag(tp, HW_TSO_2) ||
+	    tg3_flag(tp, HW_TSO_3))
 		return 0;
 
 	fw_data = (void *)tp->fw->data;
@@ -7743,7 +7745,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 	if (!netif_running(dev))
 		return 0;
 
-	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+	if (tg3_flag(tp, ENABLE_ASF)) {
 		u32 addr0_high, addr0_low, addr1_high, addr1_low;
 
 		addr0_high = tr32(MAC_ADDR_0_HIGH);
@@ -7778,7 +7780,7 @@ static void tg3_set_bdinfo(struct tg3 *tp, u32 bdinfo_addr,
 		      (bdinfo_addr + TG3_BDINFO_MAXLEN_FLAGS),
 		       maxlen_flags);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		tg3_write_mem(tp,
 			      (bdinfo_addr + TG3_BDINFO_NIC_ADDR),
 			      nic_addr);
@@ -7789,7 +7791,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 {
 	int i;
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)) {
+	if (!tg3_flag(tp, ENABLE_TSS)) {
 		tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
 		tw32(HOSTCC_TXMAX_FRAMES, ec->tx_max_coalesced_frames);
 		tw32(HOSTCC_TXCOAL_MAXF_INT, ec->tx_max_coalesced_frames_irq);
@@ -7799,7 +7801,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
 	}
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)) {
+	if (!tg3_flag(tp, ENABLE_RSS)) {
 		tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
 		tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
 		tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
@@ -7809,7 +7811,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_RXCOAL_MAXF_INT, 0);
 	}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		u32 val = ec->stats_block_coalesce_usecs;
 
 		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
@@ -7831,7 +7833,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		reg = HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18;
 		tw32(reg, ec->rx_max_coalesced_frames_irq);
 
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS) {
+		if (tg3_flag(tp, ENABLE_TSS)) {
 			reg = HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18;
 			tw32(reg, ec->tx_coalesce_usecs);
 			reg = HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18;
@@ -7846,7 +7848,7 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_RXMAX_FRAMES_VEC1 + i * 0x18, 0);
 		tw32(HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
 
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS) {
+		if (tg3_flag(tp, ENABLE_TSS)) {
 			tw32(HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18, 0);
 			tw32(HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18, 0);
 			tw32(HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
@@ -7862,9 +7864,9 @@ static void tg3_rings_reset(struct tg3 *tp)
 	struct tg3_napi *tnapi = &tp->napi[0];
 
 	/* Disable all transmit rings but the first. */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
-	else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	else if (tg3_flag(tp, 5717_PLUS))
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
@@ -7878,9 +7880,9 @@ static void tg3_rings_reset(struct tg3 *tp)
 
 
 	/* Disable all receive return rings but the first. */
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	if (tg3_flag(tp, 5717_PLUS))
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 17;
-	else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	else if (!tg3_flag(tp, 5705_PLUS))
 		limit = NIC_SRAM_RCV_RET_RCB + TG3_BDINFO_SIZE * 16;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
@@ -7897,16 +7899,16 @@ static void tg3_rings_reset(struct tg3 *tp)
 	tw32_mailbox_f(tp->napi[0].int_mbox, 1);
 
 	/* Zero mailbox registers. */
-	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX) {
+	if (tg3_flag(tp, SUPPORT_MSIX)) {
 		for (i = 1; i < tp->irq_max; i++) {
 			tp->napi[i].tx_prod = 0;
 			tp->napi[i].tx_cons = 0;
-			if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+			if (tg3_flag(tp, ENABLE_TSS))
 				tw32_mailbox(tp->napi[i].prodmbox, 0);
 			tw32_rx_mbox(tp->napi[i].consmbox, 0);
 			tw32_mailbox_f(tp->napi[i].int_mbox, 1);
 		}
-		if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS))
+		if (!tg3_flag(tp, ENABLE_TSS))
 			tw32_mailbox(tp->napi[0].prodmbox, 0);
 	} else {
 		tp->napi[0].tx_prod = 0;
@@ -7916,7 +7918,7 @@ static void tg3_rings_reset(struct tg3 *tp)
 	}
 
 	/* Make sure the NIC-based send BD rings are disabled. */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		u32 mbox = MAILBOX_SNDNIC_PROD_IDX_0 + TG3_64BIT_REG_LOW;
 		for (i = 0; i < 16; i++)
 			tw32_tx_mbox(mbox + i * 8, 0);
@@ -7980,8 +7982,8 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 {
 	u32 val, bdcache_maxcnt, host_rep_thresh, nic_rep_thresh;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5750_PLUS) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+	if (!tg3_flag(tp, 5750_PLUS) ||
+	    tg3_flag(tp, 5780_CLASS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 		bdcache_maxcnt = TG3_SRAM_RX_STD_BDCACHE_SIZE_5700;
@@ -7997,14 +7999,13 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 	val = min(nic_rep_thresh, host_rep_thresh);
 	tw32(RCVBDI_STD_THRESH, val);
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
+	if (tg3_flag(tp, 57765_PLUS))
 		tw32(STD_REPLENISH_LWM, bdcache_maxcnt);
 
-	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ||
-		(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	if (!tg3_flag(tp, JUMBO_CAPABLE) || tg3_flag(tp, 5780_CLASS))
 		return;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5700;
 	else
 		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5717;
@@ -8014,7 +8015,7 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 	val = min(bdcache_maxcnt / 2, host_rep_thresh);
 	tw32(RCVBDI_JUMBO_THRESH, val);
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
+	if (tg3_flag(tp, 57765_PLUS))
 		tw32(JMB_REPLENISH_LWM, bdcache_maxcnt);
 }
 
@@ -8031,7 +8032,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tg3_write_sig_pre_reset(tp, RESET_KIND_INIT);
 
-	if (tp->tg3_flags & TG3_FLAG_INIT_COMPLETE)
+	if (tg3_flag(tp, INIT_COMPLETE))
 		tg3_abort_hw(tp, 1);
 
 	/* Enable MAC control of LPI */
@@ -8051,7 +8052,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717)
 			val |= TG3_CPMU_EEEMD_SND_IDX_DET_EN;
 
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		if (tg3_flag(tp, ENABLE_APE))
 			val |= TG3_CPMU_EEEMD_APE_TX_DET_EN;
 
 		tw32_f(TG3_CPMU_EEE_MODE, val);
@@ -8110,7 +8111,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_PCIE_LNKCTL, val | TG3_PCIE_LNKCTL_L1_PLL_PD_DIS);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_L1PLLPD_EN) {
+	if (tg3_flag(tp, L1PLLPD_EN)) {
 		u32 grc_mode = tr32(GRC_MODE);
 
 		/* Access the lower 1K of PL PCIE block registers. */
@@ -8151,20 +8152,20 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	 * other revision.  But do not set this on PCI Express
 	 * chips and don't even touch the clocks if the CPMU is present.
 	 */
-	if (!(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT)) {
-		if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
+	if (!tg3_flag(tp, CPMU_PRESENT)) {
+		if (!tg3_flag(tp, PCI_EXPRESS))
 			tp->pci_clock_ctrl |= CLOCK_CTRL_DELAY_PCI_GRANT;
 		tw32_f(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
 	}
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE)) {
+	    tg3_flag(tp, PCIX_MODE)) {
 		val = tr32(TG3PCI_PCISTATE);
 		val |= PCISTATE_RETRY_SAME_DMA;
 		tw32(TG3PCI_PCISTATE, val);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+	if (tg3_flag(tp, ENABLE_APE)) {
 		/* Allow reads and writes to the
 		 * APE register and memory space.
 		 */
@@ -8191,7 +8192,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
+	if (tg3_flag(tp, 57765_PLUS)) {
 		val = tr32(TG3PCI_DMA_RW_CTRL) &
 		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0)
@@ -8233,7 +8234,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(GRC_MISC_CFG, val);
 
 	/* Initialize MBUF/DESC pool. */
-	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
+	if (tg3_flag(tp, 5750_PLUS)) {
 		/* Do nothing.  */
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5705) {
 		tw32(BUFMGR_MB_POOL_ADDR, NIC_SRAM_MBUF_POOL_BASE);
@@ -8243,7 +8244,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			tw32(BUFMGR_MB_POOL_SIZE, NIC_SRAM_MBUF_POOL_SIZE96);
 		tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
 		tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
-	} else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
+	} else if (tg3_flag(tp, TSO_CAPABLE)) {
 		int fw_len;
 
 		fw_len = tp->fw_len;
@@ -8318,12 +8319,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	     ((u64) tpr->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tpr->rx_std_mapping & 0xffffffff));
-	if (!(tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
+	if (!tg3_flag(tp, 5717_PLUS))
 		tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 		     NIC_SRAM_RX_BUFFER_DESC);
 
 	/* Disable the mini ring */
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		tw32(RCVDBDI_MINI_BD + TG3_BDINFO_MAXLEN_FLAGS,
 		     BDINFO_FLAGS_DISABLED);
 
@@ -8331,10 +8332,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	 * blocks on those devices that have them.
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))) {
+	    (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS))) {
 
-		if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) {
+		if (tg3_flag(tp, JUMBO_RING_ENABLE)) {
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_HIGH,
 			     ((u64) tpr->rx_jmb_mapping >> 32));
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
@@ -8343,7 +8343,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			      BDINFO_FLAGS_MAXLEN_SHIFT;
 			tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_MAXLEN_FLAGS,
 			     val | BDINFO_FLAGS_USE_EXT_RECV);
-			if (!(tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) ||
+			if (!tg3_flag(tp, USE_JUMBO_BDFLAG) ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 				tw32(RCVDBDI_JUMBO_BD + TG3_BDINFO_NIC_ADDR,
 				     NIC_SRAM_RX_JUMBO_BUFFER_DESC);
@@ -8352,7 +8352,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			     BDINFO_FLAGS_DISABLED);
 		}
 
-		if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
+		if (tg3_flag(tp, 57765_PLUS)) {
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 				val = TG3_RX_STD_MAX_SIZE_5700;
 			else
@@ -8369,8 +8369,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tpr->rx_std_prod_idx = tp->rx_pending;
 	tw32_rx_mbox(TG3_RX_STD_PROD_IDX_REG, tpr->rx_std_prod_idx);
 
-	tpr->rx_jmb_prod_idx = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
-			  tp->rx_jumbo_pending : 0;
+	tpr->rx_jmb_prod_idx =
+		tg3_flag(tp, JUMBO_RING_ENABLE) ? tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(TG3_RX_JMB_PROD_IDX_REG, tpr->rx_jmb_prod_idx);
 
 	tg3_rings_reset(tp);
@@ -8421,22 +8421,24 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
-		if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE &&
+		if (tg3_flag(tp, TSO_CAPABLE) &&
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
 			rdmac_mode |= RDMAC_MODE_FIFO_SIZE_128;
 		} else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
-			   !(tp->tg3_flags2 & TG3_FLG2_IS_5788)) {
+			   !tg3_flag(tp, IS_5788)) {
 			rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 		}
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)
+	if (tg3_flag(tp, PCI_EXPRESS))
 		rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
 
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+	if (tg3_flag(tp, HW_TSO_1) ||
+	    tg3_flag(tp, HW_TSO_2) ||
+	    tg3_flag(tp, HW_TSO_3))
 		rdmac_mode |= RDMAC_MODE_IPV4_LSO_EN;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+	if (tg3_flag(tp, HW_TSO_3) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		rdmac_mode |= RDMAC_MODE_IPV6_LSO_EN;
@@ -8448,7 +8450,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
+	    tg3_flag(tp, 57765_PLUS)) {
 		val = tr32(TG3_RDMA_RSRVCTRL_REG);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
@@ -8472,12 +8474,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	/* Receive/send statistics. */
-	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
+	if (tg3_flag(tp, 5750_PLUS)) {
 		val = tr32(RCVLPC_STATS_ENABLE);
 		val &= ~RCVLPC_STATSENAB_DACK_FIX;
 		tw32(RCVLPC_STATS_ENABLE, val);
 	} else if ((rdmac_mode & RDMAC_MODE_FIFO_SIZE_128) &&
-		   (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+		   tg3_flag(tp, TSO_CAPABLE)) {
 		val = tr32(RCVLPC_STATS_ENABLE);
 		val &= ~RCVLPC_STATSENAB_LNGBRST_RFIX;
 		tw32(RCVLPC_STATS_ENABLE, val);
@@ -8500,7 +8502,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	__tg3_set_coalesce(tp, &tp->coal);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		/* Status/statistics block address.  See tg3_timer,
 		 * the tg3_periodic_fetch_stats call there, and
 		 * tg3_get_stats to see how this works for 5705/5750 chips.
@@ -8526,7 +8528,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tw32(RCVCC_MODE, RCVCC_MODE_ENABLE | RCVCC_MODE_ATTN_ENABLE);
 	tw32(RCVLPC_MODE, RCVLPC_MODE_ENABLE);
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		tw32(RCVLSC_MODE, RCVLSC_MODE_ENABLE | RCVLSC_MODE_ATTN_ENABLE);
 
 	if (tp->phy_flags & TG3_PHYFLG_MII_SERDES) {
@@ -8536,13 +8538,13 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		udelay(10);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+	if (tg3_flag(tp, ENABLE_APE))
 		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	else
 		tp->mac_mode = 0;
 	tp->mac_mode |= MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
 		MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE | MAC_MODE_FHDE_ENABLE;
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	if (!tg3_flag(tp, 5705_PLUS) &&
 	    !(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700)
 		tp->mac_mode |= MAC_MODE_LINK_POLARITY;
@@ -8550,12 +8552,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(40);
 
 	/* tp->grc_local_ctrl is partially set up during tg3_get_invariants().
-	 * If TG3_FLG2_IS_NIC is zero, we should read the
+	 * If TG3_FLAG_IS_NIC is zero, we should read the
 	 * register to preserve the GPIO settings for LOMs. The GPIOs,
 	 * whether used as inputs or outputs, are set by boot code after
 	 * reset.
 	 */
-	if (!(tp->tg3_flags2 & TG3_FLG2_IS_NIC)) {
+	if (!tg3_flag(tp, IS_NIC)) {
 		u32 gpio_mask;
 
 		gpio_mask = GRC_LCLCTRL_GPIO_OE0 | GRC_LCLCTRL_GPIO_OE1 |
@@ -8573,21 +8575,20 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tp->grc_local_ctrl |= tr32(GRC_LOCAL_CTRL) & gpio_mask;
 
 		/* GPIO1 must be driven high for eeprom write protect */
-		if (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT)
+		if (tg3_flag(tp, EEPROM_WRITE_PROT))
 			tp->grc_local_ctrl |= (GRC_LCLCTRL_GPIO_OE1 |
 					       GRC_LCLCTRL_GPIO_OUTPUT1);
 	}
 	tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	udelay(100);
 
-	if ((tp->tg3_flags2 & TG3_FLG2_USING_MSIX) &&
-		tp->irq_cnt > 1) {
+	if (tg3_flag(tp, USING_MSIX) && tp->irq_cnt > 1) {
 		val = tr32(MSGINT_MODE);
 		val |= MSGINT_MODE_MULTIVEC_EN | MSGINT_MODE_ENABLE;
 		tw32(MSGINT_MODE, val);
 	}
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
 		udelay(40);
 	}
@@ -8600,18 +8601,18 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
-		if ((tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
+		if (tg3_flag(tp, TSO_CAPABLE) &&
 		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
 		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
 			/* nothing */
 		} else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
-			   !(tp->tg3_flags2 & TG3_FLG2_IS_5788)) {
+			   !tg3_flag(tp, IS_5788)) {
 			val |= WDMAC_MODE_RX_ACCEL;
 		}
 	}
 
 	/* Enable host coalescing bug fix */
-	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+	if (tg3_flag(tp, 5755_PLUS))
 		val |= WDMAC_MODE_STATUS_TAG_FIX;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
@@ -8620,7 +8621,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(WDMAC_MODE, val);
 	udelay(40);
 
-	if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
+	if (tg3_flag(tp, PCIX_MODE)) {
 		u16 pcix_cmd;
 
 		pci_read_config_word(tp->pdev, tp->pcix_cap + PCI_X_CMD,
@@ -8640,7 +8641,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(40);
 
 	tw32(RCVDCC_MODE, RCVDCC_MODE_ENABLE | RCVDCC_MODE_ATTN_ENABLE);
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		tw32(MBFREE_MODE, MBFREE_MODE_ENABLE);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
@@ -8652,14 +8653,16 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(SNDBDC_MODE, SNDBDC_MODE_ENABLE | SNDBDC_MODE_ATTN_ENABLE);
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
 	val = RCVDBDI_MODE_ENABLE | RCVDBDI_MODE_INV_RING_SZ;
-	if (tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP)
+	if (tg3_flag(tp, LRG_PROD_RING_CAP))
 		val |= RCVDBDI_MODE_LRG_RING_SZ;
 	tw32(RCVDBDI_MODE, val);
 	tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE);
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+	if (tg3_flag(tp, HW_TSO_1) ||
+	    tg3_flag(tp, HW_TSO_2) ||
+	    tg3_flag(tp, HW_TSO_3))
 		tw32(SNDDATAI_MODE, SNDDATAI_MODE_ENABLE | 0x8);
 	val = SNDBDI_MODE_ENABLE | SNDBDI_MODE_ATTN_ENABLE;
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+	if (tg3_flag(tp, ENABLE_TSS))
 		val |= SNDBDI_MODE_MULTI_TXQ_EN;
 	tw32(SNDBDI_MODE, val);
 	tw32(SNDBDS_MODE, SNDBDS_MODE_ENABLE | SNDBDS_MODE_ATTN_ENABLE);
@@ -8670,7 +8673,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 			return err;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
+	if (tg3_flag(tp, TSO_CAPABLE)) {
 		err = tg3_load_tso_firmware(tp);
 		if (err)
 			return err;
@@ -8678,7 +8681,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tp->tx_mode = TX_MODE_ENABLE;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+	if (tg3_flag(tp, 5755_PLUS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tx_mode |= TX_MODE_MBUF_LOCKUP_FIX;
 
@@ -8691,7 +8694,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32_f(MAC_TX_MODE, tp->tx_mode);
 	udelay(100);
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) {
+	if (tg3_flag(tp, ENABLE_RSS)) {
 		u32 reg = MAC_RSS_INDIR_TBL_0;
 		u8 *ent = (u8 *)&val;
 
@@ -8720,10 +8723,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	tp->rx_mode = RX_MODE_ENABLE;
-	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+	if (tg3_flag(tp, 5755_PLUS))
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)
+	if (tg3_flag(tp, ENABLE_RSS))
 		tp->rx_mode |= RX_MODE_RSS_ENABLE |
 			       RX_MODE_RSS_ITBL_HASH_BITS_7 |
 			       RX_MODE_RSS_IPV6_HASH_EN |
@@ -8770,7 +8773,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 &&
 	    (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)) {
 		/* Use hardware link auto-negotiation */
-		tp->tg3_flags2 |= TG3_FLG2_HW_AUTONEG;
+		tg3_flag_set(tp, HW_AUTONEG);
 	}
 
 	if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
@@ -8784,7 +8787,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 	}
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+	if (!tg3_flag(tp, USE_PHYLIB)) {
 		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
 			tp->phy_flags &= ~TG3_PHYFLG_IS_LOW_POWER;
 			tp->link_config.speed = tp->link_config.orig_speed;
@@ -8817,12 +8820,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(MAC_RCV_RULE_1,  0x86000004 & RCV_RULE_DISABLE_MASK);
 	tw32(MAC_RCV_VALUE_1, 0xffffffff & RCV_RULE_DISABLE_MASK);
 
-	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	if (tg3_flag(tp, 5705_PLUS) && !tg3_flag(tp, 5780_CLASS))
 		limit = 8;
 	else
 		limit = 16;
-	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF)
+	if (tg3_flag(tp, ENABLE_ASF))
 		limit -= 4;
 	switch (limit) {
 	case 16:
@@ -8860,7 +8862,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		break;
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+	if (tg3_flag(tp, ENABLE_APE))
 		/* Write our heartbeat update interval to APE. */
 		tg3_ape_write32(tp, TG3_APE_HOST_HEARTBEAT_INT_MS,
 				APE_HOST_HEARTBEAT_INT_DISABLE);
@@ -8951,7 +8953,7 @@ static void tg3_timer(unsigned long __opaque)
 
 	spin_lock(&tp->lock);
 
-	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+	if (!tg3_flag(tp, TAGGED_STATUS)) {
 		/* All of this garbage is because when using non-tagged
 		 * IRQ status the mailbox/status_block protocol the chip
 		 * uses with the cpu is race prone.
@@ -8965,7 +8967,7 @@ static void tg3_timer(unsigned long __opaque)
 		}
 
 		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
-			tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
+			tg3_flag_set(tp, RESTART_TIMER);
 			spin_unlock(&tp->lock);
 			schedule_work(&tp->reset_task);
 			return;
@@ -8974,7 +8976,7 @@ static void tg3_timer(unsigned long __opaque)
 
 	/* This part only runs once per second. */
 	if (!--tp->timer_counter) {
-		if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+		if (tg3_flag(tp, 5705_PLUS))
 			tg3_periodic_fetch_stats(tp);
 
 		if (tp->setlpicnt && !--tp->setlpicnt) {
@@ -8983,7 +8985,7 @@ static void tg3_timer(unsigned long __opaque)
 			     val | TG3_CPMU_EEEMD_LPI_ENABLE);
 		}
 
-		if (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) {
+		if (tg3_flag(tp, USE_LINKCHG_REG)) {
 			u32 mac_stat;
 			int phy_event;
 
@@ -8998,7 +9000,7 @@ static void tg3_timer(unsigned long __opaque)
 
 			if (phy_event)
 				tg3_setup_phy(tp, 0);
-		} else if (tp->tg3_flags & TG3_FLAG_POLL_SERDES) {
+		} else if (tg3_flag(tp, POLL_SERDES)) {
 			u32 mac_stat = tr32(MAC_STATUS);
 			int need_setup = 0;
 
@@ -9023,7 +9025,7 @@ static void tg3_timer(unsigned long __opaque)
 				tg3_setup_phy(tp, 0);
 			}
 		} else if ((tp->phy_flags & TG3_PHYFLG_MII_SERDES) &&
-			   (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+			   tg3_flag(tp, 5780_CLASS)) {
 			tg3_serdes_parallel_detect(tp);
 		}
 
@@ -9048,8 +9050,7 @@ static void tg3_timer(unsigned long __opaque)
 	 * resets.
 	 */
 	if (!--tp->asf_counter) {
-		if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
-		    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
+		if (tg3_flag(tp, ENABLE_ASF) && !tg3_flag(tp, ENABLE_APE)) {
 			tg3_wait_for_event_ack(tp);
 
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX,
@@ -9085,14 +9086,14 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		name[IFNAMSIZ-1] = 0;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
+	if (tg3_flag(tp, USING_MSI) || tg3_flag(tp, USING_MSIX)) {
 		fn = tg3_msi;
-		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
+		if (tg3_flag(tp, 1SHOT_MSI))
 			fn = tg3_msi_1shot;
 		flags = 0;
 	} else {
 		fn = tg3_interrupt;
-		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+		if (tg3_flag(tp, TAGGED_STATUS))
 			fn = tg3_interrupt_tagged;
 		flags = IRQF_SHARED;
 	}
@@ -9118,8 +9119,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	 * Turn off MSI one shot mode.  Otherwise this test has no
 	 * observable way to know whether the interrupt was delivered.
 	 */
-	if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
-	    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
+	if (tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
 		val = tr32(MSGINT_MODE) | MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
 	}
@@ -9161,8 +9161,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	if (intr_ok) {
 		/* Reenable MSI one shot mode. */
-		if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
-		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
+		if (tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
 			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
 			tw32(MSGINT_MODE, val);
 		}
@@ -9180,7 +9179,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	int err;
 	u16 pci_cmd;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSI))
+	if (!tg3_flag(tp, USING_MSI))
 		return 0;
 
 	/* Turn off SERR reporting in case MSI terminates with Master
@@ -9210,7 +9209,7 @@ static int tg3_test_msi(struct tg3 *tp)
 
 	pci_disable_msi(tp->pdev);
 
-	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
+	tg3_flag_clear(tp, USING_MSI);
 	tp->napi[0].irq_vec = tp->pdev->irq;
 
 	err = tg3_request_irq(tp, 0);
@@ -9307,11 +9306,11 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	}
 
 	if (tp->irq_cnt > 1) {
-		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
+		tg3_flag_set(tp, ENABLE_RSS);
 
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
-			tp->tg3_flags3 |= TG3_FLG3_ENABLE_TSS;
+			tg3_flag_set(tp, ENABLE_TSS);
 			netif_set_real_num_tx_queues(tp->dev, tp->irq_cnt - 1);
 		}
 	}
@@ -9321,8 +9320,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 
 static void tg3_ints_init(struct tg3 *tp)
 {
-	if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSI_OR_MSIX) &&
-	    !(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+	if ((tg3_flag(tp, SUPPORT_MSI) || tg3_flag(tp, SUPPORT_MSIX)) &&
+	    !tg3_flag(tp, TAGGED_STATUS)) {
 		/* All MSI supporting chips should support tagged
 		 * status.  Assert that this is the case.
 		 */
@@ -9331,21 +9330,19 @@ static void tg3_ints_init(struct tg3 *tp)
 		goto defcfg;
 	}
 
-	if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX) && tg3_enable_msix(tp))
-		tp->tg3_flags2 |= TG3_FLG2_USING_MSIX;
-	else if ((tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) &&
-		 pci_enable_msi(tp->pdev) == 0)
-		tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
+	if (tg3_flag(tp, SUPPORT_MSIX) && tg3_enable_msix(tp))
+		tg3_flag_set(tp, USING_MSIX);
+	else if (tg3_flag(tp, SUPPORT_MSI) && pci_enable_msi(tp->pdev) == 0)
+		tg3_flag_set(tp, USING_MSI);
 
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI_OR_MSIX) {
+	if (tg3_flag(tp, USING_MSI) || tg3_flag(tp, USING_MSIX)) {
 		u32 msi_mode = tr32(MSGINT_MODE);
-		if ((tp->tg3_flags2 & TG3_FLG2_USING_MSIX) &&
-		    tp->irq_cnt > 1)
+		if (tg3_flag(tp, USING_MSIX) && tp->irq_cnt > 1)
 			msi_mode |= MSGINT_MODE_MULTIVEC_EN;
 		tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
 	}
 defcfg:
-	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
+	if (!tg3_flag(tp, USING_MSIX)) {
 		tp->irq_cnt = 1;
 		tp->napi[0].irq_vec = tp->pdev->irq;
 		netif_set_real_num_tx_queues(tp->dev, 1);
@@ -9355,12 +9352,14 @@ defcfg:
 
 static void tg3_ints_fini(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSIX)
+	if (tg3_flag(tp, USING_MSIX))
 		pci_disable_msix(tp->pdev);
-	else if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
+	else if (tg3_flag(tp, USING_MSI))
 		pci_disable_msi(tp->pdev);
-	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI_OR_MSIX;
-	tp->tg3_flags3 &= ~(TG3_FLG3_ENABLE_RSS | TG3_FLG3_ENABLE_TSS);
+	tg3_flag_clear(tp, USING_MSI);
+	tg3_flag_clear(tp, USING_MSIX);
+	tg3_flag_clear(tp, ENABLE_RSS);
+	tg3_flag_clear(tp, ENABLE_TSS);
 }
 
 static int tg3_open(struct net_device *dev)
@@ -9375,10 +9374,10 @@ static int tg3_open(struct net_device *dev)
 				return err;
 		} else if (err) {
 			netdev_warn(tp->dev, "TSO capability disabled\n");
-			tp->tg3_flags2 &= ~TG3_FLG2_TSO_CAPABLE;
-		} else if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+			tg3_flag_clear(tp, TSO_CAPABLE);
+		} else if (!tg3_flag(tp, TSO_CAPABLE)) {
 			netdev_notice(tp->dev, "TSO capability restored\n");
-			tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+			tg3_flag_set(tp, TSO_CAPABLE);
 		}
 	}
 
@@ -9391,7 +9390,7 @@ static int tg3_open(struct net_device *dev)
 	tg3_full_lock(tp, 0);
 
 	tg3_disable_ints(tp);
-	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_clear(tp, INIT_COMPLETE);
 
 	tg3_full_unlock(tp);
 
@@ -9432,7 +9431,7 @@ static int tg3_open(struct net_device *dev)
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		tg3_free_rings(tp);
 	} else {
-		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+		if (tg3_flag(tp, TAGGED_STATUS))
 			tp->timer_offset = HZ;
 		else
 			tp->timer_offset = HZ / 10;
@@ -9454,7 +9453,7 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		goto err_out3;
 
-	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
+	if (tg3_flag(tp, USING_MSI)) {
 		err = tg3_test_msi(tp);
 
 		if (err) {
@@ -9466,8 +9465,7 @@ static int tg3_open(struct net_device *dev)
 			goto err_out2;
 		}
 
-		if (!(tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
-		    (tp->tg3_flags2 & TG3_FLG2_USING_MSI)) {
+		if (!tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
 			u32 val = tr32(PCIE_TRANSACTION_CFG);
 
 			tw32(PCIE_TRANSACTION_CFG,
@@ -9480,7 +9478,7 @@ static int tg3_open(struct net_device *dev)
 	tg3_full_lock(tp, 0);
 
 	add_timer(&tp->timer);
-	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_set(tp, INIT_COMPLETE);
 	tg3_enable_ints(tp);
 
 	tg3_full_unlock(tp);
@@ -9529,7 +9527,7 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 	tg3_free_rings(tp);
-	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_clear(tp, INIT_COMPLETE);
 
 	tg3_full_unlock(tp);
 
@@ -9786,7 +9784,7 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
 	 * flag clear.
 	 */
-	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+	if (!tg3_flag(tp, ENABLE_ASF))
 		rx_mode |= RX_MODE_KEEP_VLAN_TAG;
 #endif
 
@@ -9879,7 +9877,7 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	u32 i, offset, len, b_offset, b_count;
 	__be32 val;
 
-	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM)
+	if (tg3_flag(tp, NO_NVRAM))
 		return -EINVAL;
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
@@ -9947,7 +9945,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
 		return -EAGAIN;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
+	if (tg3_flag(tp, NO_NVRAM) ||
 	    eeprom->magic != TG3_EEPROM_MAGIC)
 		return -EINVAL;
 
@@ -9999,7 +9997,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
@@ -10045,7 +10043,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
@@ -10145,14 +10143,12 @@ static void tg3_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
-	    device_can_wakeup(&tp->pdev->dev))
+	if (tg3_flag(tp, WOL_CAP) && device_can_wakeup(&tp->pdev->dev))
 		wol->supported = WAKE_MAGIC;
 	else
 		wol->supported = 0;
 	wol->wolopts = 0;
-	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) &&
-	    device_can_wakeup(&tp->pdev->dev))
+	if (tg3_flag(tp, WOL_ENABLE) && device_can_wakeup(&tp->pdev->dev))
 		wol->wolopts = WAKE_MAGIC;
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
 }
@@ -10165,16 +10161,16 @@ static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 	if ((wol->wolopts & WAKE_MAGIC) &&
-	    !((tp->tg3_flags & TG3_FLAG_WOL_CAP) && device_can_wakeup(dp)))
+	    !(tg3_flag(tp, WOL_CAP) && device_can_wakeup(dp)))
 		return -EINVAL;
 
 	device_set_wakeup_enable(dp, wol->wolopts & WAKE_MAGIC);
 
 	spin_lock_bh(&tp->lock);
 	if (device_may_wakeup(dp))
-		tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+		tg3_flag_set(tp, WOL_ENABLE);
 	else
-		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
+		tg3_flag_clear(tp, WOL_ENABLE);
 	spin_unlock_bh(&tp->lock);
 
 	return 0;
@@ -10203,7 +10199,7 @@ static int tg3_nway_reset(struct net_device *dev)
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
 		return -EINVAL;
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
 		r = phy_start_aneg(tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR]);
@@ -10232,7 +10228,7 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 
 	ering->rx_max_pending = tp->rx_std_ring_mask;
 	ering->rx_mini_max_pending = 0;
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE)
+	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		ering->rx_jumbo_max_pending = tp->rx_jmb_ring_mask;
 	else
 		ering->rx_jumbo_max_pending = 0;
@@ -10241,7 +10237,7 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 
 	ering->rx_pending = tp->rx_pending;
 	ering->rx_mini_pending = 0;
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE)
+	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		ering->rx_jumbo_pending = tp->rx_jumbo_pending;
 	else
 		ering->rx_jumbo_pending = 0;
@@ -10258,7 +10254,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
 	    (ering->tx_pending <= MAX_SKB_FRAGS) ||
-	    ((tp->tg3_flags2 & TG3_FLG2_TSO_BUG) &&
+	    (tg3_flag(tp, TSO_BUG) &&
 	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
 		return -EINVAL;
 
@@ -10272,7 +10268,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 
 	tp->rx_pending = ering->rx_pending;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_MAX_RXPEND_64) &&
+	if (tg3_flag(tp, MAX_RXPEND_64) &&
 	    tp->rx_pending > 63)
 		tp->rx_pending = 63;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
@@ -10299,7 +10295,7 @@ static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	epause->autoneg = (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) != 0;
+	epause->autoneg = !!tg3_flag(tp, PAUSE_AUTONEG);
 
 	if (tp->link_config.active_flowctrl & FLOW_CTRL_RX)
 		epause->rx_pause = 1;
@@ -10317,7 +10313,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 	struct tg3 *tp = netdev_priv(dev);
 	int err = 0;
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		u32 newadv;
 		struct phy_device *phydev;
 
@@ -10345,9 +10341,9 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 			newadv = 0;
 
 		if (epause->autoneg)
-			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+			tg3_flag_set(tp, PAUSE_AUTONEG);
 		else
-			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
+			tg3_flag_clear(tp, PAUSE_AUTONEG);
 
 		if (tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) {
 			u32 oldadv = phydev->advertising &
@@ -10389,9 +10385,9 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 		tg3_full_lock(tp, irq_sync);
 
 		if (epause->autoneg)
-			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+			tg3_flag_set(tp, PAUSE_AUTONEG);
 		else
-			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
+			tg3_flag_clear(tp, PAUSE_AUTONEG);
 		if (epause->rx_pause)
 			tp->link_config.flowctrl |= FLOW_CTRL_RX;
 		else
@@ -10490,8 +10486,7 @@ static __be32 * tg3_vpd_readblock(struct tg3 *tp)
 	u32 offset = 0, len = 0;
 	u32 magic, val;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
-	    tg3_nvram_read(tp, 0, &magic))
+	if (tg3_flag(tp, NO_NVRAM) || tg3_nvram_read(tp, 0, &magic))
 		return NULL;
 
 	if (magic == TG3_EEPROM_MAGIC) {
@@ -10571,7 +10566,7 @@ static int tg3_test_nvram(struct tg3 *tp)
 	__be32 *buf;
 	int i, j, k, err = 0, size;
 
-	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM)
+	if (tg3_flag(tp, NO_NVRAM))
 		return 0;
 
 	if (tg3_nvram_read(tp, 0, &magic) != 0)
@@ -10913,9 +10908,9 @@ static int tg3_test_registers(struct tg3 *tp)
 	};
 
 	is_5705 = is_5750 = 0;
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tg3_flag(tp, 5705_PLUS)) {
 		is_5705 = 1;
-		if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
+		if (tg3_flag(tp, 5750_PLUS))
 			is_5750 = 1;
 	}
 
@@ -10926,7 +10921,7 @@ static int tg3_test_registers(struct tg3 *tp)
 		if (!is_5705 && (reg_tbl[i].flags & TG3_FL_5705))
 			continue;
 
-		if ((tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
+		if (tg3_flag(tp, IS_5788) &&
 		    (reg_tbl[i].flags & TG3_FL_NOT_5788))
 			continue;
 
@@ -11049,15 +11044,15 @@ static int tg3_test_memory(struct tg3 *tp)
 	int err = 0;
 	int i;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
+	if (tg3_flag(tp, 5717_PLUS))
 		mem_tbl = mem_tbl_5717;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		mem_tbl = mem_tbl_57765;
-	else if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+	else if (tg3_flag(tp, 5755_PLUS))
 		mem_tbl = mem_tbl_5755;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		mem_tbl = mem_tbl_5906;
-	else if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+	else if (tg3_flag(tp, 5705_PLUS))
 		mem_tbl = mem_tbl_5705;
 	else
 		mem_tbl = mem_tbl_570x;
@@ -11113,9 +11108,9 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 	tnapi = &tp->napi[0];
 	rnapi = &tp->napi[0];
 	if (tp->irq_cnt > 1) {
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)
+		if (tg3_flag(tp, ENABLE_RSS))
 			rnapi = &tp->napi[1];
-		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+		if (tg3_flag(tp, ENABLE_TSS))
 			tnapi = &tp->napi[1];
 	}
 	coal_now = tnapi->coal_now | rnapi->coal_now;
@@ -11127,13 +11122,13 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 		 * all newer ASIC revisions.
 		 */
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
-		    (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT))
+		    tg3_flag(tp, CPMU_PRESENT))
 			return 0;
 
 		mac_mode = tp->mac_mode &
 			   ~(MAC_MODE_PORT_MODE_MASK | MAC_MODE_HALF_DUPLEX);
 		mac_mode |= MAC_MODE_PORT_INT_LPBACK;
-		if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		if (!tg3_flag(tp, 5705_PLUS))
 			mac_mode |= MAC_MODE_LINK_POLARITY;
 		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
@@ -11222,7 +11217,9 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 		base_flags = (TXD_FLAG_CPU_PRE_DMA |
 			      TXD_FLAG_CPU_POST_DMA);
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
+		if (tg3_flag(tp, HW_TSO_1) ||
+		    tg3_flag(tp, HW_TSO_2) ||
+		    tg3_flag(tp, HW_TSO_3)) {
 			struct tcphdr *th;
 			val = ETH_HLEN + TG3_TSO_IP_HDR_LEN;
 			th = (struct tcphdr *)&tx_data[val];
@@ -11230,14 +11227,14 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 		} else
 			base_flags |= TXD_FLAG_TCPUDP_CSUM;
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
+		if (tg3_flag(tp, HW_TSO_3)) {
 			mss |= (hdr_len & 0xc) << 12;
 			if (hdr_len & 0x10)
 				base_flags |= 0x00000010;
 			base_flags |= (hdr_len & 0x3e0) << 5;
-		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+		} else if (tg3_flag(tp, HW_TSO_2))
 			mss |= hdr_len << 9;
-		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
+		else if (tg3_flag(tp, HW_TSO_1) ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
 			mss |= (TG3_TSO_TCP_OPT_LEN << 9);
 		} else {
@@ -11381,7 +11378,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 		goto done;
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) {
+	if (tg3_flag(tp, ENABLE_RSS)) {
 		int i;
 
 		/* Reroute all rx packets to the 1st queue */
@@ -11394,7 +11391,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, false);
 
-	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+	if (tg3_flag(tp, CPMU_PRESENT)) {
 		int i;
 		u32 status;
 
@@ -11423,11 +11420,11 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
 		err |= TG3_STD_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
-	if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
+	if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
 	    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
 		err |= TG3_JMB_LOOPBACK_FAILED << TG3_MAC_LOOPBACK_SHIFT;
 
-	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+	if (tg3_flag(tp, CPMU_PRESENT)) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */
@@ -11435,15 +11432,15 @@ static int tg3_test_loopback(struct tg3 *tp)
 	}
 
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
+	    !tg3_flag(tp, USE_PHYLIB)) {
 		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
 			err |= TG3_STD_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
-		if ((tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
+		if (tg3_flag(tp, TSO_CAPABLE) &&
 		    tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_TSO_LOOPBACK))
 			err |= TG3_TSO_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
-		if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
+		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
 		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
 			err |= TG3_JMB_LOOPBACK_FAILED <<
 			       TG3_PHY_LOOPBACK_SHIFT;
@@ -11491,7 +11488,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		tg3_halt(tp, RESET_KIND_SUSPEND, 1);
 		err = tg3_nvram_lock(tp);
 		tg3_halt_cpu(tp, RX_CPU_BASE);
-		if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		if (!tg3_flag(tp, 5705_PLUS))
 			tg3_halt_cpu(tp, TX_CPU_BASE);
 		if (!err)
 			tg3_nvram_unlock(tp);
@@ -11521,7 +11518,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
-			tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+			tg3_flag_set(tp, INIT_COMPLETE);
 			err2 = tg3_restart_hw(tp, 1);
 			if (!err2)
 				tg3_netif_start(tp);
@@ -11543,7 +11540,7 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+	if (tg3_flag(tp, USE_PHYLIB)) {
 		struct phy_device *phydev;
 		if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED))
 			return -EAGAIN;
@@ -11608,7 +11605,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	u32 max_rxcoal_tick_int = 0, max_txcoal_tick_int = 0;
 	u32 max_stat_coal_ticks = 0, min_stat_coal_ticks = 0;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+	if (!tg3_flag(tp, 5705_PLUS)) {
 		max_rxcoal_tick_int = MAX_RXCOAL_TICK_INT;
 		max_txcoal_tick_int = MAX_TXCOAL_TICK_INT;
 		max_stat_coal_ticks = MAX_STAT_COAL_TICKS;
@@ -11722,8 +11719,7 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 {
 	u32 val;
 
-	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
-	    tg3_nvram_read(tp, 0, &val) != 0)
+	if (tg3_flag(tp, NO_NVRAM) || tg3_nvram_read(tp, 0, &val) != 0)
 		return;
 
 	/* Selfboot format */
@@ -11758,19 +11754,19 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 
 	nvcfg1 = tr32(NVRAM_CFG1);
 	if (nvcfg1 & NVRAM_CFG1_FLASHIF_ENAB) {
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, FLASH);
 	} else {
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
 		tw32(NVRAM_CFG1, nvcfg1);
 	}
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+	    tg3_flag(tp, 5780_CLASS)) {
 		switch (nvcfg1 & NVRAM_CFG1_VENDOR_MASK) {
 		case FLASH_VENDOR_ATMEL_FLASH_BUFFERED:
 			tp->nvram_jedecnum = JEDEC_ATMEL;
 			tp->nvram_pagesize = ATMEL_AT45DB0X1B_PAGE_SIZE;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			tg3_flag_set(tp, NVRAM_BUFFERED);
 			break;
 		case FLASH_VENDOR_ATMEL_FLASH_UNBUFFERED:
 			tp->nvram_jedecnum = JEDEC_ATMEL;
@@ -11779,12 +11775,12 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 		case FLASH_VENDOR_ATMEL_EEPROM:
 			tp->nvram_jedecnum = JEDEC_ATMEL;
 			tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			tg3_flag_set(tp, NVRAM_BUFFERED);
 			break;
 		case FLASH_VENDOR_ST:
 			tp->nvram_jedecnum = JEDEC_ST;
 			tp->nvram_pagesize = ST_M45PEX0_PAGE_SIZE;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			tg3_flag_set(tp, NVRAM_BUFFERED);
 			break;
 		case FLASH_VENDOR_SAIFUN:
 			tp->nvram_jedecnum = JEDEC_SAIFUN;
@@ -11799,7 +11795,7 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 	} else {
 		tp->nvram_jedecnum = JEDEC_ATMEL;
 		tp->nvram_pagesize = ATMEL_AT45DB0X1B_PAGE_SIZE;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 	}
 }
 
@@ -11838,29 +11834,29 @@ static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 
 	/* NVRAM protection for TPM */
 	if (nvcfg1 & (1 << 27))
-		tp->tg3_flags3 |= TG3_FLG3_PROTECTED_NVRAM;
+		tg3_flag_set(tp, PROTECTED_NVRAM);
 
 	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 	case FLASH_5752VENDOR_ATMEL_EEPROM_64KHZ:
 	case FLASH_5752VENDOR_ATMEL_EEPROM_376KHZ:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 		break;
 	case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		break;
 	case FLASH_5752VENDOR_ST_M45PE10:
 	case FLASH_5752VENDOR_ST_M45PE20:
 	case FLASH_5752VENDOR_ST_M45PE40:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		break;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_FLASH) {
+	if (tg3_flag(tp, FLASH)) {
 		tg3_nvram_get_pagesize(tp, nvcfg1);
 	} else {
 		/* For eeprom, set pagesize to maximum eeprom size */
@@ -11879,7 +11875,7 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 
 	/* NVRAM protection for TPM */
 	if (nvcfg1 & (1 << 27)) {
-		tp->tg3_flags3 |= TG3_FLG3_PROTECTED_NVRAM;
+		tg3_flag_set(tp, PROTECTED_NVRAM);
 		protect = 1;
 	}
 
@@ -11890,8 +11886,8 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 	case FLASH_5755VENDOR_ATMEL_FLASH_3:
 	case FLASH_5755VENDOR_ATMEL_FLASH_5:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		tp->nvram_pagesize = 264;
 		if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1 ||
 		    nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_5)
@@ -11908,8 +11904,8 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 	case FLASH_5752VENDOR_ST_M45PE20:
 	case FLASH_5752VENDOR_ST_M45PE40:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		tp->nvram_pagesize = 256;
 		if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE10)
 			tp->nvram_size = (protect ?
@@ -11939,7 +11935,7 @@ static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
 	case FLASH_5787VENDOR_MICRO_EEPROM_64KHZ:
 	case FLASH_5787VENDOR_MICRO_EEPROM_376KHZ:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
@@ -11950,16 +11946,16 @@ static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
 	case FLASH_5755VENDOR_ATMEL_FLASH_2:
 	case FLASH_5755VENDOR_ATMEL_FLASH_3:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		tp->nvram_pagesize = 264;
 		break;
 	case FLASH_5752VENDOR_ST_M45PE10:
 	case FLASH_5752VENDOR_ST_M45PE20:
 	case FLASH_5752VENDOR_ST_M45PE40:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		tp->nvram_pagesize = 256;
 		break;
 	}
@@ -11973,7 +11969,7 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 
 	/* NVRAM protection for TPM */
 	if (nvcfg1 & (1 << 27)) {
-		tp->tg3_flags3 |= TG3_FLG3_PROTECTED_NVRAM;
+		tg3_flag_set(tp, PROTECTED_NVRAM);
 		protect = 1;
 	}
 
@@ -11988,9 +11984,9 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 	case FLASH_5761VENDOR_ATMEL_MDB081D:
 	case FLASH_5761VENDOR_ATMEL_MDB161D:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
+		tg3_flag_set(tp, NO_NVRAM_ADDR_TRANS);
 		tp->nvram_pagesize = 256;
 		break;
 	case FLASH_5761VENDOR_ST_A_M45PE20:
@@ -12002,8 +11998,8 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 	case FLASH_5761VENDOR_ST_M_M45PE80:
 	case FLASH_5761VENDOR_ST_M_M45PE16:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 		tp->nvram_pagesize = 256;
 		break;
 	}
@@ -12043,7 +12039,7 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 static void __devinit tg3_get_5906_nvram_info(struct tg3 *tp)
 {
 	tp->nvram_jedecnum = JEDEC_ATMEL;
-	tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+	tg3_flag_set(tp, NVRAM_BUFFERED);
 	tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 }
 
@@ -12057,7 +12053,7 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 	case FLASH_5787VENDOR_ATMEL_EEPROM_376KHZ:
 	case FLASH_5787VENDOR_MICRO_EEPROM_376KHZ:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
@@ -12071,8 +12067,8 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 	case FLASH_57780VENDOR_ATMEL_AT45DB041D:
 	case FLASH_57780VENDOR_ATMEL_AT45DB041B:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
@@ -12094,8 +12090,8 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 	case FLASH_5752VENDOR_ST_M45PE20:
 	case FLASH_5752VENDOR_ST_M45PE40:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5752VENDOR_ST_M45PE10:
@@ -12110,13 +12106,13 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 		}
 		break;
 	default:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
+		tg3_flag_set(tp, NO_NVRAM);
 		return;
 	}
 
 	tg3_nvram_get_pagesize(tp, nvcfg1);
 	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tg3_flag_set(tp, NO_NVRAM_ADDR_TRANS);
 }
 
 
@@ -12130,7 +12126,7 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 	case FLASH_5717VENDOR_ATMEL_EEPROM:
 	case FLASH_5717VENDOR_MICRO_EEPROM:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
@@ -12144,8 +12140,8 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 	case FLASH_5717VENDOR_ATMEL_ADB021D:
 	case FLASH_5717VENDOR_ATMEL_45USPT:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5717VENDOR_ATMEL_MDB021D:
@@ -12171,8 +12167,8 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 	case FLASH_5717VENDOR_ST_25USPT:
 	case FLASH_5717VENDOR_ST_45USPT:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5717VENDOR_ST_M_M25PE20:
@@ -12189,13 +12185,13 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 		}
 		break;
 	default:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
+		tg3_flag_set(tp, NO_NVRAM);
 		return;
 	}
 
 	tg3_nvram_get_pagesize(tp, nvcfg1);
 	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tg3_flag_set(tp, NO_NVRAM_ADDR_TRANS);
 }
 
 static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
@@ -12209,7 +12205,7 @@ static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
 	case FLASH_5720_EEPROM_HD:
 	case FLASH_5720_EEPROM_LD:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
 
 		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
 		tw32(NVRAM_CFG1, nvcfg1);
@@ -12231,8 +12227,8 @@ static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
 	case FLASH_5720VENDOR_A_ATMEL_DB081D:
 	case FLASH_5720VENDOR_ATMEL_45USPT:
 		tp->nvram_jedecnum = JEDEC_ATMEL;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvmpinstrp) {
 		case FLASH_5720VENDOR_M_ATMEL_DB021D:
@@ -12273,8 +12269,8 @@ static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
 	case FLASH_5720VENDOR_ST_25USPT:
 	case FLASH_5720VENDOR_ST_45USPT:
 		tp->nvram_jedecnum = JEDEC_ST;
-		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+		tg3_flag_set(tp, NVRAM_BUFFERED);
+		tg3_flag_set(tp, FLASH);
 
 		switch (nvmpinstrp) {
 		case FLASH_5720VENDOR_M_ST_M25PE20:
@@ -12301,13 +12297,13 @@ static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
 		}
 		break;
 	default:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
+		tg3_flag_set(tp, NO_NVRAM);
 		return;
 	}
 
 	tg3_nvram_get_pagesize(tp, nvcfg1);
 	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tg3_flag_set(tp, NO_NVRAM_ADDR_TRANS);
 }
 
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
@@ -12327,7 +12323,7 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701) {
-		tp->tg3_flags |= TG3_FLAG_NVRAM;
+		tg3_flag_set(tp, NVRAM);
 
 		if (tg3_nvram_lock(tp)) {
 			netdev_warn(tp->dev,
@@ -12369,7 +12365,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		tg3_nvram_unlock(tp);
 
 	} else {
-		tp->tg3_flags &= ~(TG3_FLAG_NVRAM | TG3_FLAG_NVRAM_BUFFERED);
+		tg3_flag_clear(tp, NVRAM);
+		tg3_flag_clear(tp, NVRAM_BUFFERED);
 
 		tg3_get_eeprom_size(tp);
 	}
@@ -12552,7 +12549,7 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 			nvram_cmd |= NVRAM_CMD_LAST;
 
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
-		    !(tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
+		    !tg3_flag(tp, 5755_PLUS) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
 		    (nvram_cmd & NVRAM_CMD_FIRST)) {
 
@@ -12562,7 +12559,7 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 
 				break;
 		}
-		if (!(tp->tg3_flags2 & TG3_FLG2_FLASH)) {
+		if (!tg3_flag(tp, FLASH)) {
 			/* We always do complete word writes to eeprom. */
 			nvram_cmd |= (NVRAM_CMD_FIRST | NVRAM_CMD_LAST);
 		}
@@ -12578,13 +12575,13 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 {
 	int ret;
 
-	if (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) {
+	if (tg3_flag(tp, EEPROM_WRITE_PROT)) {
 		tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl &
 		       ~GRC_LCLCTRL_GPIO_OUTPUT1);
 		udelay(40);
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_NVRAM)) {
+	if (!tg3_flag(tp, NVRAM)) {
 		ret = tg3_nvram_write_block_using_eeprom(tp, offset, len, buf);
 	} else {
 		u32 grc_mode;
@@ -12594,16 +12591,13 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 			return ret;
 
 		tg3_enable_nvram_access(tp);
-		if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-		    !(tp->tg3_flags3 & TG3_FLG3_PROTECTED_NVRAM))
+		if (tg3_flag(tp, 5750_PLUS) && !tg3_flag(tp, PROTECTED_NVRAM))
 			tw32(NVRAM_WRITE1, 0x406);
 
 		grc_mode = tr32(GRC_MODE);
 		tw32(GRC_MODE, grc_mode | GRC_MODE_NVRAM_WR_ENABLE);
 
-		if ((tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) ||
-			!(tp->tg3_flags2 & TG3_FLG2_FLASH)) {
-
+		if (tg3_flag(tp, NVRAM_BUFFERED) || !tg3_flag(tp, FLASH)) {
 			ret = tg3_nvram_write_block_buffered(tp, offset, len,
 				buf);
 		} else {
@@ -12618,7 +12612,7 @@ static int tg3_nvram_write_block(struct tg3 *tp, u32 offset, u32 len, u8 *buf)
 		tg3_nvram_unlock(tp);
 	}
 
-	if (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT) {
+	if (tg3_flag(tp, EEPROM_WRITE_PROT)) {
 		tw32_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl);
 		udelay(40);
 	}
@@ -12740,19 +12734,20 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	tp->led_ctrl = LED_CTRL_MODE_PHY_1;
 
 	/* Assume an onboard device and WOL capable by default.  */
-	tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT | TG3_FLAG_WOL_CAP;
+	tg3_flag_set(tp, EEPROM_WRITE_PROT);
+	tg3_flag_set(tp, WOL_CAP);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		if (!(tr32(PCIE_TRANSACTION_CFG) & PCIE_TRANS_CFG_LOM)) {
-			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
-			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
+			tg3_flag_clear(tp, EEPROM_WRITE_PROT);
+			tg3_flag_set(tp, IS_NIC);
 		}
 		val = tr32(VCPU_CFGSHDW);
 		if (val & VCPU_CFGSHDW_ASPM_DBNC)
-			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
+			tg3_flag_set(tp, ASPM_WORKAROUND);
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
 		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
-			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+			tg3_flag_set(tp, WOL_ENABLE);
 		goto done;
 	}
 
@@ -12793,13 +12788,13 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 
 		tp->phy_id = eeprom_phy_id;
 		if (eeprom_phy_serdes) {
-			if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+			if (!tg3_flag(tp, 5705_PLUS))
 				tp->phy_flags |= TG3_PHYFLG_PHY_SERDES;
 			else
 				tp->phy_flags |= TG3_PHYFLG_MII_SERDES;
 		}
 
-		if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
+		if (tg3_flag(tp, 5750_PLUS))
 			led_cfg = cfg2 & (NIC_SRAM_DATA_CFG_LED_MODE_MASK |
 				    SHASTA_EXT_LED_MODE_MASK);
 		else
@@ -12859,34 +12854,34 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			tp->led_ctrl = LED_CTRL_MODE_PHY_1;
 
 		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP) {
-			tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
+			tg3_flag_set(tp, EEPROM_WRITE_PROT);
 			if ((tp->pdev->subsystem_vendor ==
 			     PCI_VENDOR_ID_ARIMA) &&
 			    (tp->pdev->subsystem_device == 0x205a ||
 			     tp->pdev->subsystem_device == 0x2063))
-				tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
+				tg3_flag_clear(tp, EEPROM_WRITE_PROT);
 		} else {
-			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
-			tp->tg3_flags2 |= TG3_FLG2_IS_NIC;
+			tg3_flag_clear(tp, EEPROM_WRITE_PROT);
+			tg3_flag_set(tp, IS_NIC);
 		}
 
 		if (nic_cfg & NIC_SRAM_DATA_CFG_ASF_ENABLE) {
-			tp->tg3_flags |= TG3_FLAG_ENABLE_ASF;
-			if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
-				tp->tg3_flags2 |= TG3_FLG2_ASF_NEW_HANDSHAKE;
+			tg3_flag_set(tp, ENABLE_ASF);
+			if (tg3_flag(tp, 5750_PLUS))
+				tg3_flag_set(tp, ASF_NEW_HANDSHAKE);
 		}
 
 		if ((nic_cfg & NIC_SRAM_DATA_CFG_APE_ENABLE) &&
-			(tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
-			tp->tg3_flags3 |= TG3_FLG3_ENABLE_APE;
+		    tg3_flag(tp, 5750_PLUS))
+			tg3_flag_set(tp, ENABLE_APE);
 
 		if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES &&
 		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
-			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
+			tg3_flag_clear(tp, WOL_CAP);
 
-		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
+		if (tg3_flag(tp, WOL_CAP) &&
 		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE))
-			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+			tg3_flag_set(tp, WOL_ENABLE);
 
 		if (cfg2 & (1 << 17))
 			tp->phy_flags |= TG3_PHYFLG_CAPACITIVE_COUPLING;
@@ -12896,33 +12891,33 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg2 & (1 << 18))
 			tp->phy_flags |= TG3_PHYFLG_SERDES_PREEMPHASIS;
 
-		if (((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) ||
-		    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
-		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX))) &&
+		if ((tg3_flag(tp, 57765_PLUS) ||
+		     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX)) &&
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
 			tp->phy_flags |= TG3_PHYFLG_ENABLE_APD;
 
-		if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+		if (tg3_flag(tp, PCI_EXPRESS) &&
 		    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
-		    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
+		    !tg3_flag(tp, 57765_PLUS)) {
 			u32 cfg3;
 
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &cfg3);
 			if (cfg3 & NIC_SRAM_ASPM_DEBOUNCE)
-				tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
+				tg3_flag_set(tp, ASPM_WORKAROUND);
 		}
 
 		if (cfg4 & NIC_SRAM_RGMII_INBAND_DISABLE)
-			tp->tg3_flags3 |= TG3_FLG3_RGMII_INBAND_DISABLE;
+			tg3_flag_set(tp, RGMII_INBAND_DISABLE);
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_RX_EN)
-			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_RX_EN;
+			tg3_flag_set(tp, RGMII_EXT_IBND_RX_EN);
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_TX_EN)
-			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_TX_EN;
+			tg3_flag_set(tp, RGMII_EXT_IBND_TX_EN);
 	}
 done:
-	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
+	if (tg3_flag(tp, WOL_CAP))
 		device_set_wakeup_enable(&tp->pdev->dev,
-					 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+					 tg3_flag(tp, WOL_ENABLE));
 	else
 		device_set_wakeup_capable(&tp->pdev->dev, false);
 }
@@ -13012,18 +13007,17 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	int err;
 
 	/* flow control autonegotiation is default behavior */
-	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+	tg3_flag_set(tp, PAUSE_AUTONEG);
 	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
 
-	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
+	if (tg3_flag(tp, USE_PHYLIB))
 		return tg3_phy_init(tp);
 
 	/* Reading the PHY ID register can conflict with ASF
 	 * firmware access to the PHY hardware.
 	 */
 	err = 0;
-	if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-	    (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
+	if (tg3_flag(tp, ENABLE_ASF) || tg3_flag(tp, ENABLE_APE)) {
 		hw_phy_id = hw_phy_id_masked = TG3_PHY_ID_INVALID;
 	} else {
 		/* Now read the physical PHY_ID from the chip and verify
@@ -13079,8 +13073,8 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	tg3_phy_init_link_config(tp);
 
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
+	    !tg3_flag(tp, ENABLE_APE) &&
+	    !tg3_flag(tp, ENABLE_ASF)) {
 		u32 bmsr, adv_reg, tg3_ctrl, mask;
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -13399,7 +13393,7 @@ static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
 	if (offset == TG3_NVM_DIR_END)
 		return;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!tg3_flag(tp, 5705_PLUS))
 		start = 0x08000000;
 	else if (tg3_nvram_read(tp, offset - 4, &start))
 		return;
@@ -13439,8 +13433,7 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 	u32 apedata;
 	char *fwtype;
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) ||
-	    !(tp->tg3_flags  & TG3_FLAG_ENABLE_ASF))
+	if (!tg3_flag(tp, ENABLE_APE) || !tg3_flag(tp, ENABLE_ASF))
 		return;
 
 	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
@@ -13454,7 +13447,7 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 	apedata = tg3_ape_read32(tp, TG3_APE_FW_VERSION);
 
 	if (tg3_ape_read32(tp, TG3_APE_FW_FEATURES) & TG3_APE_FW_FEATURE_NCSI) {
-		tp->tg3_flags3 |= TG3_FLG3_APE_HAS_NCSI;
+		tg3_flag_set(tp, APE_HAS_NCSI);
 		fwtype = "NCSI";
 	} else {
 		fwtype = "DASH";
@@ -13478,7 +13471,7 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	if (tp->fw_ver[0] != 0)
 		vpd_vers = true;
 
-	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) {
+	if (tg3_flag(tp, NO_NVRAM)) {
 		strcat(tp->fw_ver, "sb");
 		return;
 	}
@@ -13495,8 +13488,7 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	else
 		return;
 
-	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) || vpd_vers)
+	if (!tg3_flag(tp, ENABLE_ASF) || tg3_flag(tp, ENABLE_APE) || vpd_vers)
 		goto done;
 
 	tg3_read_mgmtfw_ver(tp);
@@ -13509,10 +13501,9 @@ static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
 
 static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 {
-	if (tp->tg3_flags3 & TG3_FLG3_LRG_PROD_RING_CAP)
+	if (tg3_flag(tp, LRG_PROD_RING_CAP))
 		return TG3_RX_RET_MAX_SIZE_5717;
-	else if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
-		 !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
+	else if (tg3_flag(tp, JUMBO_CAPABLE) && !tg3_flag(tp, 5780_CLASS))
 		return TG3_RX_RET_MAX_SIZE_5700;
 	else
 		return TG3_RX_RET_MAX_SIZE_5705;
@@ -13638,8 +13629,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			if (bridge->subordinate &&
 			    (bridge->subordinate->number ==
 			     tp->pdev->bus->number)) {
-
-				tp->tg3_flags2 |= TG3_FLG2_ICH_WORKAROUND;
+				tg3_flag_set(tp, ICH_WORKAROUND);
 				pci_dev_put(bridge);
 				break;
 			}
@@ -13671,7 +13661,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			     tp->pdev->bus->number) &&
 			    (bridge->subordinate->subordinate >=
 			     tp->pdev->bus->number)) {
-				tp->tg3_flags3 |= TG3_FLG3_5701_DMA_BUG;
+				tg3_flag_set(tp, 5701_DMA_BUG);
 				pci_dev_put(bridge);
 				break;
 			}
@@ -13686,8 +13676,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714) {
-		tp->tg3_flags2 |= TG3_FLG2_5780_CLASS;
-		tp->tg3_flags |= TG3_FLAG_40BIT_DMA_BUG;
+		tg3_flag_set(tp, 5780_CLASS);
+		tg3_flag_set(tp, 40BIT_DMA_BUG);
 		tp->msi_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_MSI);
 	} else {
 		struct pci_dev *bridge = NULL;
@@ -13701,7 +13691,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			     tp->pdev->bus->number) &&
 			    (bridge->subordinate->subordinate >=
 			     tp->pdev->bus->number)) {
-				tp->tg3_flags |= TG3_FLAG_40BIT_DMA_BUG;
+				tg3_flag_set(tp, 40BIT_DMA_BUG);
 				pci_dev_put(bridge);
 				break;
 			}
@@ -13723,11 +13713,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
-		tp->tg3_flags3 |= TG3_FLG3_5717_PLUS;
+		tg3_flag_set(tp, 5717_PLUS);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
-		tp->tg3_flags3 |= TG3_FLG3_57765_PLUS;
+	    tg3_flag(tp, 5717_PLUS))
+		tg3_flag_set(tp, 57765_PLUS);
 
 	/* Intentionally exclude ASIC_REV_5906 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
@@ -13736,19 +13726,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS))
-		tp->tg3_flags3 |= TG3_FLG3_5755_PLUS;
+	    tg3_flag(tp, 57765_PLUS))
+		tg3_flag_set(tp, 5755_PLUS);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
-	    (tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
-		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
+	    tg3_flag(tp, 5755_PLUS) ||
+	    tg3_flag(tp, 5780_CLASS))
+		tg3_flag_set(tp, 5750_PLUS);
 
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
-		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
+	    tg3_flag(tp, 5750_PLUS))
+		tg3_flag_set(tp, 5705_PLUS);
 
 	/* 5700 B0 chips do not support checksumming correctly due
 	 * to hardware bugs.
@@ -13756,7 +13746,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->pci_chip_rev_id != CHIPREV_ID_5700_B0) {
 		u32 features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 
-		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+		if (tg3_flag(tp, 5755_PLUS))
 			features |= NETIF_F_IPV6_CSUM;
 		tp->dev->features |= features;
 		tp->dev->hw_features |= features;
@@ -13766,20 +13756,21 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* Determine TSO capabilities */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 		; /* Do nothing. HW bug. */
-	else if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
-		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_3;
-	else if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+	else if (tg3_flag(tp, 57765_PLUS))
+		tg3_flag_set(tp, HW_TSO_3);
+	else if (tg3_flag(tp, 5755_PLUS) ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
-	else if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
-		tp->tg3_flags2 |= TG3_FLG2_HW_TSO_1 | TG3_FLG2_TSO_BUG;
+		tg3_flag_set(tp, HW_TSO_2);
+	else if (tg3_flag(tp, 5750_PLUS)) {
+		tg3_flag_set(tp, HW_TSO_1);
+		tg3_flag_set(tp, TSO_BUG);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 &&
 		    tp->pci_chip_rev_id >= CHIPREV_ID_5750_C2)
-			tp->tg3_flags2 &= ~TG3_FLG2_TSO_BUG;
+			tg3_flag_clear(tp, TSO_BUG);
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 		   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
 		   tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
-		tp->tg3_flags2 |= TG3_FLG2_TSO_BUG;
+			tg3_flag_set(tp, TSO_BUG);
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)
 			tp->fw_needed = FIRMWARE_TG3TSO5;
 		else
@@ -13788,22 +13779,22 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	tp->irq_max = 1;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
-		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
+	if (tg3_flag(tp, 5750_PLUS)) {
+		tg3_flag_set(tp, SUPPORT_MSI);
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
 		    GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_BX ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 &&
 		     tp->pci_chip_rev_id <= CHIPREV_ID_5714_A2 &&
 		     tp->pdev_peer == tp->pdev))
-			tp->tg3_flags &= ~TG3_FLAG_SUPPORT_MSI;
+			tg3_flag_clear(tp, SUPPORT_MSI);
 
-		if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
+		if (tg3_flag(tp, 5755_PLUS) ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
+			tg3_flag_set(tp, 1SHOT_MSI);
 		}
 
-		if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
-			tp->tg3_flags |= TG3_FLAG_SUPPORT_MSIX;
+		if (tg3_flag(tp, 57765_PLUS)) {
+			tg3_flag_set(tp, SUPPORT_MSIX);
 			tp->irq_max = TG3_IRQ_MAX_VECS;
 		}
 	}
@@ -13811,23 +13802,23 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-		tp->tg3_flags3 |= TG3_FLG3_SHORT_DMA_BUG;
-	else if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS)) {
-		tp->tg3_flags3 |= TG3_FLG3_4G_DMA_BNDRY_BUG;
-		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
+		tg3_flag_set(tp, SHORT_DMA_BUG);
+	else if (!tg3_flag(tp, 5755_PLUS)) {
+		tg3_flag_set(tp, 4G_DMA_BNDRY_BUG);
+		tg3_flag_set(tp, 40BIT_DMA_LIMIT_BUG);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS)
-		tp->tg3_flags3 |= TG3_FLG3_LRG_PROD_RING_CAP;
+	if (tg3_flag(tp, 5717_PLUS))
+		tg3_flag_set(tp, LRG_PROD_RING_CAP);
 
-	if ((tp->tg3_flags3 & TG3_FLG3_57765_PLUS) &&
+	if (tg3_flag(tp, 57765_PLUS) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
-		tp->tg3_flags3 |= TG3_FLG3_USE_JUMBO_BDFLAG;
+		tg3_flag_set(tp, USE_JUMBO_BDFLAG);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
-	    (tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG))
-		tp->tg3_flags |= TG3_FLAG_JUMBO_CAPABLE;
+	if (!tg3_flag(tp, 5705_PLUS) ||
+	    tg3_flag(tp, 5780_CLASS) ||
+	    tg3_flag(tp, USE_JUMBO_BDFLAG))
+		tg3_flag_set(tp, JUMBO_CAPABLE);
 
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
 			      &pci_state_reg);
@@ -13836,7 +13827,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->pcie_cap != 0) {
 		u16 lnkctl;
 
-		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
+		tg3_flag_set(tp, PCI_EXPRESS);
 
 		tp->pcie_readrq = 4096;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
@@ -13850,19 +13841,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				     &lnkctl);
 		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
+				tg3_flag_clear(tp, HW_TSO_2);
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A0 ||
 			    tp->pci_chip_rev_id == CHIPREV_ID_57780_A1)
-				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
+				tg3_flag_set(tp, CLKREQ_BUG);
 		} else if (tp->pci_chip_rev_id == CHIPREV_ID_5717_A0) {
-			tp->tg3_flags3 |= TG3_FLG3_L1PLLPD_EN;
+			tg3_flag_set(tp, L1PLLPD_EN);
 		}
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
-		tp->tg3_flags2 |= TG3_FLG2_PCI_EXPRESS;
-	} else if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
-		   (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+		tg3_flag_set(tp, PCI_EXPRESS);
+	} else if (!tg3_flag(tp, 5705_PLUS) ||
+		   tg3_flag(tp, 5780_CLASS)) {
 		tp->pcix_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_PCIX);
 		if (!tp->pcix_cap) {
 			dev_err(&tp->pdev->dev,
@@ -13871,7 +13862,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 
 		if (!(pci_state_reg & PCISTATE_CONV_PCI_MODE))
-			tp->tg3_flags |= TG3_FLAG_PCIX_MODE;
+			tg3_flag_set(tp, PCIX_MODE);
 	}
 
 	/* If we have an AMD 762 or VIA K8T800 chipset, write
@@ -13881,8 +13872,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 * posted to the chip in order.
 	 */
 	if (pci_dev_present(tg3_write_reorder_chipsets) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
-		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;
+	    !tg3_flag(tp, PCI_EXPRESS))
+		tg3_flag_set(tp, MBOX_WRITE_REORDER);
 
 	pci_read_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
 			     &tp->pci_cacheline_sz);
@@ -13899,17 +13890,17 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		/* 5700 BX chips need to have their TX producer index
 		 * mailboxes written twice to workaround a bug.
 		 */
-		tp->tg3_flags |= TG3_FLAG_TXD_MBOX_HWBUG;
+		tg3_flag_set(tp, TXD_MBOX_HWBUG);
 
 		/* If we are in PCI-X mode, enable register write workaround.
 		 *
 		 * The workaround is to use indirect register accesses
 		 * for all chip writes not to mailbox registers.
 		 */
-		if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
+		if (tg3_flag(tp, PCIX_MODE)) {
 			u32 pm_reg;
 
-			tp->tg3_flags |= TG3_FLAG_PCIX_TARGET_HWBUG;
+			tg3_flag_set(tp, PCIX_TARGET_HWBUG);
 
 			/* The chip can have it's power management PCI config
 			 * space registers clobbered due to this bug.
@@ -13932,9 +13923,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	if ((pci_state_reg & PCISTATE_BUS_SPEED_HIGH) != 0)
-		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
+		tg3_flag_set(tp, PCI_HIGH_SPEED);
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
-		tp->tg3_flags |= TG3_FLAG_PCI_32BIT;
+		tg3_flag_set(tp, PCI_32BIT);
 
 	/* Chip-specific fixup from Broadcom driver */
 	if ((tp->pci_chip_rev_id == CHIPREV_ID_5704_A0) &&
@@ -13952,10 +13943,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	tp->write32_rx_mbox = tg3_write32;
 
 	/* Various workaround register access methods */
-	if (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG)
+	if (tg3_flag(tp, PCIX_TARGET_HWBUG))
 		tp->write32 = tg3_write_indirect_reg32;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
-		 ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+		 (tg3_flag(tp, PCI_EXPRESS) &&
 		  tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
 		/*
 		 * Back to back register writes can cause problems on these
@@ -13967,14 +13958,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->write32 = tg3_write_flush_reg32;
 	}
 
-	if ((tp->tg3_flags & TG3_FLAG_TXD_MBOX_HWBUG) ||
-	    (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)) {
+	if (tg3_flag(tp, TXD_MBOX_HWBUG) || tg3_flag(tp, MBOX_WRITE_REORDER)) {
 		tp->write32_tx_mbox = tg3_write32_tx_mbox;
-		if (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)
+		if (tg3_flag(tp, MBOX_WRITE_REORDER))
 			tp->write32_rx_mbox = tg3_write_flush_reg32;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND) {
+	if (tg3_flag(tp, ICH_WORKAROUND)) {
 		tp->read32 = tg3_read_indirect_reg32;
 		tp->write32 = tg3_write_indirect_reg32;
 		tp->read32_mbox = tg3_read_indirect_mbox;
@@ -13997,13 +13987,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	if (tp->write32 == tg3_write_indirect_reg32 ||
-	    ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
+	    (tg3_flag(tp, PCIX_MODE) &&
 	     (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	      GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)))
-		tp->tg3_flags |= TG3_FLAG_SRAM_USE_CONFIG;
+		tg3_flag_set(tp, SRAM_USE_CONFIG);
 
 	/* Get eeprom hw config before calling tg3_set_power_state().
-	 * In particular, the TG3_FLG2_IS_NIC flag must be
+	 * In particular, the TG3_FLAG_IS_NIC flag must be
 	 * determined before calling tg3_set_power_state() so that
 	 * we know whether or not to switch out of Vaux power.
 	 * When the flag is set, it means that GPIO1 is used for eeprom
@@ -14012,7 +14002,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tg3_get_eeprom_hw_cfg(tp);
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+	if (tg3_flag(tp, ENABLE_APE)) {
 		/* Allow reads and writes to the
 		 * APE register and memory space.
 		 */
@@ -14027,8 +14017,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
-	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS))
-		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
+	    tg3_flag(tp, 57765_PLUS))
+		tg3_flag_set(tp, CPMU_PRESENT);
 
 	/* Set up tp->grc_local_ctrl before calling tg3_power_up().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
@@ -14036,7 +14026,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tp->grc_local_ctrl = GRC_LCLCTRL_INT_ON_ATTN | GRC_LCLCTRL_AUTO_SEEPROM;
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700) ||
-	    (tp->tg3_flags & TG3_FLAG_EEPROM_WRITE_PROT))
+	    tg3_flag(tp, EEPROM_WRITE_PROT))
 		tp->grc_local_ctrl |= (GRC_LCLCTRL_GPIO_OE1 |
 				       GRC_LCLCTRL_GPIO_OUTPUT1);
 	/* Unused GPIO3 must be driven as output on 5752 because there
@@ -14054,7 +14044,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_5761S) {
 		/* Turn off the debug UART. */
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
-		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
+		if (tg3_flag(tp, IS_NIC))
 			/* Keep VMain power. */
 			tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_OE0 |
 					      GRC_LCLCTRL_GPIO_OUTPUT0;
@@ -14070,18 +14060,17 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* Derive initial jumbo mode from MTU assigned in
 	 * ether_setup() via the alloc_etherdev() call
 	 */
-	if (tp->dev->mtu > ETH_DATA_LEN &&
-	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
-		tp->tg3_flags |= TG3_FLAG_JUMBO_RING_ENABLE;
+	if (tp->dev->mtu > ETH_DATA_LEN && !tg3_flag(tp, 5780_CLASS))
+		tg3_flag_set(tp, JUMBO_RING_ENABLE);
 
 	/* Determine WakeOnLan speed to use. */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B2) {
-		tp->tg3_flags &= ~(TG3_FLAG_WOL_SPEED_100MB);
+		tg3_flag_clear(tp, WOL_SPEED_100MB);
 	} else {
-		tp->tg3_flags |= TG3_FLAG_WOL_SPEED_100MB;
+		tg3_flag_set(tp, WOL_SPEED_100MB);
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
@@ -14102,11 +14091,11 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0)
 		tp->phy_flags |= TG3_PHYFLG_5704_A0_BUG;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	if (tg3_flag(tp, 5705_PLUS) &&
 	    !(tp->phy_flags & TG3_PHYFLG_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780 &&
-	    !(tp->tg3_flags3 & TG3_FLG3_57765_PLUS)) {
+	    !tg3_flag(tp, 57765_PLUS)) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
@@ -14127,7 +14116,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			tp->phy_otp = TG3_OTP_DEFAULT;
 	}
 
-	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT)
+	if (tg3_flag(tp, CPMU_PRESENT))
 		tp->mi_mode = MAC_MI_MODE_500KHZ_CONST;
 	else
 		tp->mi_mode = MAC_MI_MODE_BASE;
@@ -14147,7 +14136,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
-		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
+		tg3_flag_set(tp, USE_PHYLIB);
 
 	err = tg3_mdio_init(tp);
 	if (err)
@@ -14174,7 +14163,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
 			      &pci_state_reg);
 	if ((pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) == 0) {
+	    !tg3_flag(tp, PCIX_TARGET_HWBUG)) {
 		u32 chiprevid = GET_CHIP_REV_ID(tp->misc_host_ctrl);
 
 		if (chiprevid == CHIPREV_ID_5701_A0 ||
@@ -14193,7 +14182,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			writel(0x00000000, sram_base + 4);
 			writel(0xffffffff, sram_base + 4);
 			if (readl(sram_base) != 0x00000000)
-				tp->tg3_flags |= TG3_FLAG_PCIX_TARGET_HWBUG;
+				tg3_flag_set(tp, PCIX_TARGET_HWBUG);
 		}
 	}
 
@@ -14206,12 +14195,12 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	    (grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788 ||
 	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
-		tp->tg3_flags2 |= TG3_FLG2_IS_5788;
+		tg3_flag_set(tp, IS_5788);
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
+	if (!tg3_flag(tp, IS_5788) &&
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700))
-		tp->tg3_flags |= TG3_FLAG_TAGGED_STATUS;
-	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
+		tg3_flag_set(tp, TAGGED_STATUS);
+	if (tg3_flag(tp, TAGGED_STATUS)) {
 		tp->coalesce_mode |= (HOSTCC_MODE_CLRTICK_RXBD |
 				      HOSTCC_MODE_CLRTICK_TXBD);
 
@@ -14221,7 +14210,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	/* Preserve the APE MAC_MODE bits */
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+	if (tg3_flag(tp, ENABLE_APE))
 		tp->mac_mode = MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
 	else
 		tp->mac_mode = TG3_DEF_MAC_MODE;
@@ -14268,9 +14257,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 * status register in those cases.
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700)
-		tp->tg3_flags |= TG3_FLAG_USE_LINKCHG_REG;
+		tg3_flag_set(tp, USE_LINKCHG_REG);
 	else
-		tp->tg3_flags &= ~TG3_FLAG_USE_LINKCHG_REG;
+		tg3_flag_clear(tp, USE_LINKCHG_REG);
 
 	/* The led_ctrl is set during tg3_phy_probe, here we might
 	 * have to force the link status polling mechanism based
@@ -14280,19 +14269,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    !(tp->phy_flags & TG3_PHYFLG_PHY_SERDES)) {
 		tp->phy_flags |= TG3_PHYFLG_USE_MI_INTERRUPT;
-		tp->tg3_flags |= TG3_FLAG_USE_LINKCHG_REG;
+		tg3_flag_set(tp, USE_LINKCHG_REG);
 	}
 
 	/* For all SERDES we poll the MAC status register. */
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES)
-		tp->tg3_flags |= TG3_FLAG_POLL_SERDES;
+		tg3_flag_set(tp, POLL_SERDES);
 	else
-		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
+		tg3_flag_clear(tp, POLL_SERDES);
 
 	tp->rx_offset = NET_IP_ALIGN;
 	tp->rx_copy_thresh = TG3_RX_COPY_THRESHOLD;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0) {
+	    tg3_flag(tp, PCIX_MODE)) {
 		tp->rx_offset = 0;
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 		tp->rx_copy_thresh = ~(u16)0;
@@ -14313,7 +14302,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 		tp->rx_std_max_post = 8;
 
-	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND)
+	if (tg3_flag(tp, ASPM_WORKAROUND))
 		tp->pwrmgmt_thresh = tr32(PCIE_PWR_MGMT_THRESH) &
 				     PCIE_PWR_MGMT_L1_THRESH_MSK;
 
@@ -14361,14 +14350,14 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 
 	mac_offset = 0x7c;
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
-	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
+	    tg3_flag(tp, 5780_CLASS)) {
 		if (tr32(TG3PCI_DUAL_MAC_CTRL) & DUAL_MAC_CTRL_ID)
 			mac_offset = 0xcc;
 		if (tg3_nvram_lock(tp))
 			tw32_f(NVRAM_CMD, NVRAM_CMD_RESET);
 		else
 			tg3_nvram_unlock(tp);
-	} else if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
+	} else if (tg3_flag(tp, 5717_PLUS)) {
 		if (PCI_FUNC(tp->pdev->devfn) & 1)
 			mac_offset = 0xcc;
 		if (PCI_FUNC(tp->pdev->devfn) > 1)
@@ -14393,7 +14382,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 	}
 	if (!addr_ok) {
 		/* Next, try NVRAM. */
-		if (!(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) &&
+		if (!tg3_flag(tp, NO_NVRAM) &&
 		    !tg3_nvram_read_be32(tp, mac_offset + 0, &hi) &&
 		    !tg3_nvram_read_be32(tp, mac_offset + 4, &lo)) {
 			memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
@@ -14444,7 +14433,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
-	    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
+	    !tg3_flag(tp, PCI_EXPRESS))
 		goto out;
 
 #if defined(CONFIG_PPC64) || defined(CONFIG_IA64) || defined(CONFIG_PARISC)
@@ -14457,7 +14446,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 #endif
 #endif
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
+	if (tg3_flag(tp, 57765_PLUS)) {
 		val = goal ? 0 : DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
 		goto out;
 	}
@@ -14476,8 +14465,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 	 * other than 5700 and 5701 which do not implement the
 	 * boundary bits.
 	 */
-	if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
-	    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
+	if (tg3_flag(tp, PCIX_MODE) && !tg3_flag(tp, PCI_EXPRESS)) {
 		switch (cacheline_size) {
 		case 16:
 		case 32:
@@ -14502,7 +14490,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 				DMA_RWCTRL_WRITE_BNDRY_384_PCIX);
 			break;
 		}
-	} else if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	} else if (tg3_flag(tp, PCI_EXPRESS)) {
 		switch (cacheline_size) {
 		case 16:
 		case 32:
@@ -14674,13 +14662,13 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 
 	tp->dma_rwctrl = tg3_calc_dma_bndry(tp, tp->dma_rwctrl);
 
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS)
+	if (tg3_flag(tp, 57765_PLUS))
 		goto out;
 
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	if (tg3_flag(tp, PCI_EXPRESS)) {
 		/* DMA read watermark not used on PCIE */
 		tp->dma_rwctrl |= 0x00180000;
-	} else if (!(tp->tg3_flags & TG3_FLAG_PCIX_MODE)) {
+	} else if (!tg3_flag(tp, PCIX_MODE)) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750)
 			tp->dma_rwctrl |= 0x003f0000;
@@ -14696,7 +14684,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 			 * do the less restrictive ONE_DMA workaround for
 			 * better performance.
 			 */
-			if ((tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG) &&
+			if (tg3_flag(tp, 40BIT_DMA_BUG) &&
 			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
 				tp->dma_rwctrl |= 0x8000;
 			else if (ccval == 0x6 || ccval == 0x7)
@@ -14848,7 +14836,7 @@ out_nofree:
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (tp->tg3_flags3 & TG3_FLG3_57765_PLUS) {
+	if (tg3_flag(tp, 57765_PLUS)) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
@@ -14862,7 +14850,7 @@ static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 			DEFAULT_MB_MACRX_LOW_WATER_JUMBO_57765;
 		tp->bufmgr_config.mbuf_high_water_jumbo =
 			DEFAULT_MB_HIGH_WATER_JUMBO_57765;
-	} else if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	} else if (tg3_flag(tp, 5705_PLUS)) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
@@ -14935,10 +14923,10 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 
 static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+	if (tg3_flag(tp, PCI_EXPRESS)) {
 		strcpy(str, "PCI Express");
 		return str;
-	} else if (tp->tg3_flags & TG3_FLAG_PCIX_MODE) {
+	} else if (tg3_flag(tp, PCIX_MODE)) {
 		u32 clock_ctrl = tr32(TG3PCI_CLOCK_CTRL) & 0x1f;
 
 		strcpy(str, "PCIX:");
@@ -14957,12 +14945,12 @@ static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
 			strcat(str, "100MHz");
 	} else {
 		strcpy(str, "PCI:");
-		if (tp->tg3_flags & TG3_FLAG_PCI_HIGH_SPEED)
+		if (tg3_flag(tp, PCI_HIGH_SPEED))
 			strcat(str, "66MHz");
 		else
 			strcat(str, "33MHz");
 	}
-	if (tp->tg3_flags & TG3_FLAG_PCI_32BIT)
+	if (tg3_flag(tp, PCI_32BIT))
 		strcat(str, ":32-bit");
 	else
 		strcat(str, ":64-bit");
@@ -15021,7 +15009,7 @@ static void __devinit tg3_init_coal(struct tg3 *tp)
 		ec->tx_coalesce_usecs_irq = DEFAULT_TXCOAL_TICK_INT_CLRTCKS;
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if (tg3_flag(tp, 5705_PLUS)) {
 		ec->rx_coalesce_usecs_irq = 0;
 		ec->tx_coalesce_usecs_irq = 0;
 		ec->stats_block_coalesce_usecs = 0;
@@ -15166,8 +15154,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
-	    !(tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
+	if (tg3_flag(tp, 5755_PLUS) && !tg3_flag(tp, 5717_PLUS))
 		dev->netdev_ops = &tg3_netdev_ops;
 	else
 		dev->netdev_ops = &tg3_netdev_ops_dma_bug;
@@ -15179,9 +15166,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * On 64-bit systems without IOMMU, use 64-bit dma_mask and
 	 * do DMA address check in tg3_start_xmit().
 	 */
-	if (tp->tg3_flags2 & TG3_FLG2_IS_5788)
+	if (tg3_flag(tp, IS_5788))
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(32);
-	else if (tp->tg3_flags & TG3_FLAG_40BIT_DMA_BUG) {
+	else if (tg3_flag(tp, 40BIT_DMA_BUG)) {
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 #ifdef CONFIG_HIGHMEM
 		dma_mask = DMA_BIT_MASK(64);
@@ -15215,11 +15202,14 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tg3_init_bufmgr_config(tp);
 
 	/* Selectively allow TSO based on operating conditions */
-	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
-	    (tp->fw_needed && !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)))
-		tp->tg3_flags2 |= TG3_FLG2_TSO_CAPABLE;
+	if ((tg3_flag(tp, HW_TSO_1) ||
+	     tg3_flag(tp, HW_TSO_2) ||
+	     tg3_flag(tp, HW_TSO_3)) ||
+	    (tp->fw_needed && !tg3_flag(tp, ENABLE_ASF)))
+		tg3_flag_set(tp, TSO_CAPABLE);
 	else {
-		tp->tg3_flags2 &= ~(TG3_FLG2_TSO_CAPABLE | TG3_FLG2_TSO_BUG);
+		tg3_flag_clear(tp, TSO_CAPABLE);
+		tg3_flag_clear(tp, TSO_BUG);
 		tp->fw_needed = NULL;
 	}
 
@@ -15230,18 +15220,19 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
 	 */
-	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) &&
+	if ((tg3_flag(tp, HW_TSO_1) ||
+	     tg3_flag(tp, HW_TSO_2) ||
+	     tg3_flag(tp, HW_TSO_3)) &&
 	    (dev->features & NETIF_F_IP_CSUM))
 		hw_features |= NETIF_F_TSO;
-	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
-	    (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3)) {
+	if (tg3_flag(tp, HW_TSO_2) || tg3_flag(tp, HW_TSO_3)) {
 		if (dev->features & NETIF_F_IPV6_CSUM)
 			hw_features |= NETIF_F_TSO6;
-		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+		if (tg3_flag(tp, HW_TSO_3) ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
-			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 			hw_features |= NETIF_F_TSO_ECN;
 	}
@@ -15251,9 +15242,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	dev->vlan_features |= hw_features;
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
-	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
+	    !tg3_flag(tp, TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {
-		tp->tg3_flags2 |= TG3_FLG2_MAX_RXPEND_64;
+		tg3_flag_set(tp, MAX_RXPEND_64);
 		tp->rx_pending = 63;
 	}
 
@@ -15264,7 +15255,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+	if (tg3_flag(tp, ENABLE_APE)) {
 		tp->aperegs = pci_ioremap_bar(pdev, BAR_2);
 		if (!tp->aperegs) {
 			dev_err(&pdev->dev,
@@ -15275,7 +15266,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 		tg3_ape_lock_init(tp);
 
-		if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF)
+		if (tg3_flag(tp, ENABLE_ASF))
 			tg3_read_dash_ver(tp);
 	}
 
@@ -15319,7 +15310,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		else
 			tnapi->coal_now = HOSTCC_MODE_NOW;
 
-		if (!(tp->tg3_flags & TG3_FLAG_SUPPORT_MSIX))
+		if (!tg3_flag(tp, SUPPORT_MSIX))
 			break;
 
 		/*
@@ -15381,10 +15372,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	netdev_info(dev, "RXcsums[%d] LinkChgREG[%d] MIirq[%d] ASF[%d] TSOcap[%d]\n",
 		    (dev->features & NETIF_F_RXCSUM) != 0,
-		    (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) != 0,
+		    tg3_flag(tp, USE_LINKCHG_REG) != 0,
 		    (tp->phy_flags & TG3_PHYFLG_USE_MI_INTERRUPT) != 0,
-		    (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0,
-		    (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) != 0);
+		    tg3_flag(tp, ENABLE_ASF) != 0,
+		    tg3_flag(tp, TSO_CAPABLE) != 0);
 	netdev_info(dev, "dma_rwctrl[%08x] dma_mask[%d-bit]\n",
 		    tp->dma_rwctrl,
 		    pdev->dma_mask == DMA_BIT_MASK(32) ? 32 :
@@ -15430,7 +15421,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 
 		cancel_work_sync(&tp->reset_task);
 
-		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
+		if (!tg3_flag(tp, USE_PHYLIB)) {
 			tg3_phy_fini(tp);
 			tg3_mdio_fini(tp);
 		}
@@ -15476,7 +15467,7 @@ static int tg3_suspend(struct device *device)
 
 	tg3_full_lock(tp, 0);
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_clear(tp, INIT_COMPLETE);
 	tg3_full_unlock(tp);
 
 	err = tg3_power_down_prepare(tp);
@@ -15485,7 +15476,7 @@ static int tg3_suspend(struct device *device)
 
 		tg3_full_lock(tp, 0);
 
-		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+		tg3_flag_set(tp, INIT_COMPLETE);
 		err2 = tg3_restart_hw(tp, 1);
 		if (err2)
 			goto out;
@@ -15520,7 +15511,7 @@ static int tg3_resume(struct device *device)
 
 	tg3_full_lock(tp, 0);
 
-	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp, 1);
 	if (err)
 		goto out;
@@ -15575,12 +15566,12 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 	tg3_netif_stop(tp);
 
 	del_timer_sync(&tp->timer);
-	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
+	tg3_flag_clear(tp, RESTART_TIMER);
 
 	/* Want to make sure that the reset task doesn't run */
 	cancel_work_sync(&tp->reset_task);
-	tp->tg3_flags  &= ~TG3_FLAG_TX_RECOVERY_PENDING;
-	tp->tg3_flags2 &= ~TG3_FLG2_RESTART_TIMER;
+	tg3_flag_clear(tp, TX_RECOVERY_PENDING);
+	tg3_flag_clear(tp, RESTART_TIMER);
 
 	netif_device_detach(netdev);
 
@@ -15665,7 +15656,7 @@ static void tg3_io_resume(struct pci_dev *pdev)
 		goto done;
 
 	tg3_full_lock(tp, 0);
-	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
+	tg3_flag_set(tp, INIT_COMPLETE);
 	err = tg3_restart_hw(tp, 1);
 	tg3_full_unlock(tp);
 	if (err) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 6f37d2a..ce010cd3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2816,6 +2816,86 @@ struct tg3_napi {
 	unsigned int			irq_vec;
 };
 
+enum TG3_FLAGS {
+	TG3_FLAG_TAGGED_STATUS = 0,
+	TG3_FLAG_TXD_MBOX_HWBUG,
+	TG3_FLAG_USE_LINKCHG_REG,
+	TG3_FLAG_ERROR_PROCESSED,
+	TG3_FLAG_ENABLE_ASF,
+	TG3_FLAG_ASPM_WORKAROUND,
+	TG3_FLAG_POLL_SERDES,
+	TG3_FLAG_MBOX_WRITE_REORDER,
+	TG3_FLAG_PCIX_TARGET_HWBUG,
+	TG3_FLAG_WOL_SPEED_100MB,
+	TG3_FLAG_WOL_ENABLE,
+	TG3_FLAG_EEPROM_WRITE_PROT,
+	TG3_FLAG_NVRAM,
+	TG3_FLAG_NVRAM_BUFFERED,
+	TG3_FLAG_SUPPORT_MSI,
+	TG3_FLAG_SUPPORT_MSIX,
+	TG3_FLAG_PCIX_MODE,
+	TG3_FLAG_PCI_HIGH_SPEED,
+	TG3_FLAG_PCI_32BIT,
+	TG3_FLAG_SRAM_USE_CONFIG,
+	TG3_FLAG_TX_RECOVERY_PENDING,
+	TG3_FLAG_WOL_CAP,
+	TG3_FLAG_JUMBO_RING_ENABLE,
+	TG3_FLAG_PAUSE_AUTONEG,
+	TG3_FLAG_CPMU_PRESENT,
+	TG3_FLAG_40BIT_DMA_BUG,
+	TG3_FLAG_BROKEN_CHECKSUMS,
+	TG3_FLAG_JUMBO_CAPABLE,
+	TG3_FLAG_CHIP_RESETTING,
+	TG3_FLAG_INIT_COMPLETE,
+	TG3_FLAG_RESTART_TIMER,
+	TG3_FLAG_TSO_BUG,
+	TG3_FLAG_IS_5788,
+	TG3_FLAG_MAX_RXPEND_64,
+	TG3_FLAG_TSO_CAPABLE,
+	TG3_FLAG_PCI_EXPRESS,
+	TG3_FLAG_ASF_NEW_HANDSHAKE,
+	TG3_FLAG_HW_AUTONEG,
+	TG3_FLAG_IS_NIC,
+	TG3_FLAG_FLASH,
+	TG3_FLAG_HW_TSO_1,
+	TG3_FLAG_5705_PLUS,
+	TG3_FLAG_5750_PLUS,
+	TG3_FLAG_HW_TSO_3,
+	TG3_FLAG_USING_MSI,
+	TG3_FLAG_USING_MSIX,
+	TG3_FLAG_ICH_WORKAROUND,
+	TG3_FLAG_5780_CLASS,
+	TG3_FLAG_HW_TSO_2,
+	TG3_FLAG_1SHOT_MSI,
+	TG3_FLAG_NO_FWARE_REPORTED,
+	TG3_FLAG_NO_NVRAM_ADDR_TRANS,
+	TG3_FLAG_ENABLE_APE,
+	TG3_FLAG_PROTECTED_NVRAM,
+	TG3_FLAG_5701_DMA_BUG,
+	TG3_FLAG_USE_PHYLIB,
+	TG3_FLAG_MDIOBUS_INITED,
+	TG3_FLAG_LRG_PROD_RING_CAP,
+	TG3_FLAG_RGMII_INBAND_DISABLE,
+	TG3_FLAG_RGMII_EXT_IBND_RX_EN,
+	TG3_FLAG_RGMII_EXT_IBND_TX_EN,
+	TG3_FLAG_CLKREQ_BUG,
+	TG3_FLAG_5755_PLUS,
+	TG3_FLAG_NO_NVRAM,
+	TG3_FLAG_ENABLE_RSS,
+	TG3_FLAG_ENABLE_TSS,
+	TG3_FLAG_4G_DMA_BNDRY_BUG,
+	TG3_FLAG_40BIT_DMA_LIMIT_BUG,
+	TG3_FLAG_SHORT_DMA_BUG,
+	TG3_FLAG_USE_JUMBO_BDFLAG,
+	TG3_FLAG_L1PLLPD_EN,
+	TG3_FLAG_57765_PLUS,
+	TG3_FLAG_APE_HAS_NCSI,
+	TG3_FLAG_5717_PLUS,
+
+	/* Add new flags before this comment and TG3_FLAG_NUMBER_OF_FLAGS */
+	TG3_FLAG_NUMBER_OF_FLAGS,	/* Last entry in enum TG3_FLAGS */
+};
+
 struct tg3 {
 	/* begin "general, frequently-used members" cacheline section */
 
@@ -2839,7 +2919,7 @@ struct tg3 {
 	/* SMP locking strategy:
 	 *
 	 * lock: Held during reset, PHY access, timer, and when
-	 *       updating tg3_flags and tg3_flags2.
+	 *       updating tg3_flags.
 	 *
 	 * netif_tx_lock: Held during tg3_start_xmit. tg3_tx holds
 	 *                netif_tx_lock when it needs to call
@@ -2896,95 +2976,13 @@ struct tg3 {
 	struct tg3_ethtool_stats	estats;
 	struct tg3_ethtool_stats	estats_prev;
 
+	DECLARE_BITMAP(tg3_flags, TG3_FLAG_NUMBER_OF_FLAGS);
+
 	union {
 	unsigned long			phy_crc_errors;
 	unsigned long			last_event_jiffies;
 	};
 
-	u32				tg3_flags;
-#define TG3_FLAG_TAGGED_STATUS		0x00000001
-#define TG3_FLAG_TXD_MBOX_HWBUG		0x00000002
-#define TG3_FLAG_USE_LINKCHG_REG	0x00000008
-#define TG3_FLAG_ERROR_PROCESSED	0x00000010
-#define TG3_FLAG_ENABLE_ASF		0x00000020
-#define TG3_FLAG_ASPM_WORKAROUND	0x00000040
-#define TG3_FLAG_POLL_SERDES		0x00000080
-#define TG3_FLAG_MBOX_WRITE_REORDER	0x00000100
-#define TG3_FLAG_PCIX_TARGET_HWBUG	0x00000200
-#define TG3_FLAG_WOL_SPEED_100MB	0x00000400
-#define TG3_FLAG_WOL_ENABLE		0x00000800
-#define TG3_FLAG_EEPROM_WRITE_PROT	0x00001000
-#define TG3_FLAG_NVRAM			0x00002000
-#define TG3_FLAG_NVRAM_BUFFERED		0x00004000
-#define TG3_FLAG_SUPPORT_MSI		0x00008000
-#define TG3_FLAG_SUPPORT_MSIX		0x00010000
-#define TG3_FLAG_SUPPORT_MSI_OR_MSIX	(TG3_FLAG_SUPPORT_MSI | \
-					 TG3_FLAG_SUPPORT_MSIX)
-#define TG3_FLAG_PCIX_MODE		0x00020000
-#define TG3_FLAG_PCI_HIGH_SPEED		0x00040000
-#define TG3_FLAG_PCI_32BIT		0x00080000
-#define TG3_FLAG_SRAM_USE_CONFIG	0x00100000
-#define TG3_FLAG_TX_RECOVERY_PENDING	0x00200000
-#define TG3_FLAG_WOL_CAP		0x00400000
-#define TG3_FLAG_JUMBO_RING_ENABLE	0x00800000
-#define TG3_FLAG_PAUSE_AUTONEG		0x02000000
-#define TG3_FLAG_CPMU_PRESENT		0x04000000
-#define TG3_FLAG_40BIT_DMA_BUG		0x08000000
-#define TG3_FLAG_JUMBO_CAPABLE		0x20000000
-#define TG3_FLAG_CHIP_RESETTING		0x40000000
-#define TG3_FLAG_INIT_COMPLETE		0x80000000
-	u32				tg3_flags2;
-#define TG3_FLG2_RESTART_TIMER		0x00000001
-#define TG3_FLG2_TSO_BUG		0x00000002
-#define TG3_FLG2_IS_5788		0x00000008
-#define TG3_FLG2_MAX_RXPEND_64		0x00000010
-#define TG3_FLG2_TSO_CAPABLE		0x00000020
-#define TG3_FLG2_PCI_EXPRESS		0x00000200
-#define TG3_FLG2_ASF_NEW_HANDSHAKE	0x00000400
-#define TG3_FLG2_HW_AUTONEG		0x00000800
-#define TG3_FLG2_IS_NIC			0x00001000
-#define TG3_FLG2_FLASH			0x00008000
-#define TG3_FLG2_HW_TSO_1		0x00010000
-#define TG3_FLG2_5705_PLUS		0x00040000
-#define TG3_FLG2_5750_PLUS		0x00080000
-#define TG3_FLG2_HW_TSO_3		0x00100000
-#define TG3_FLG2_USING_MSI		0x00200000
-#define TG3_FLG2_USING_MSIX		0x00400000
-#define TG3_FLG2_USING_MSI_OR_MSIX	(TG3_FLG2_USING_MSI | \
-					TG3_FLG2_USING_MSIX)
-#define TG3_FLG2_ICH_WORKAROUND		0x02000000
-#define TG3_FLG2_5780_CLASS		0x04000000
-#define TG3_FLG2_HW_TSO_2		0x08000000
-#define TG3_FLG2_HW_TSO			(TG3_FLG2_HW_TSO_1 | \
-					 TG3_FLG2_HW_TSO_2 | \
-					 TG3_FLG2_HW_TSO_3)
-#define TG3_FLG2_1SHOT_MSI		0x10000000
-#define TG3_FLG2_NO_FWARE_REPORTED	0x40000000
-	u32				tg3_flags3;
-#define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
-#define TG3_FLG3_ENABLE_APE		0x00000002
-#define TG3_FLG3_PROTECTED_NVRAM	0x00000004
-#define TG3_FLG3_5701_DMA_BUG		0x00000008
-#define TG3_FLG3_USE_PHYLIB		0x00000010
-#define TG3_FLG3_MDIOBUS_INITED		0x00000020
-#define TG3_FLG3_LRG_PROD_RING_CAP	0x00000080
-#define TG3_FLG3_RGMII_INBAND_DISABLE	0x00000100
-#define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
-#define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
-#define TG3_FLG3_CLKREQ_BUG		0x00000800
-#define TG3_FLG3_5755_PLUS		0x00002000
-#define TG3_FLG3_NO_NVRAM		0x00004000
-#define TG3_FLG3_ENABLE_RSS		0x00020000
-#define TG3_FLG3_ENABLE_TSS		0x00040000
-#define TG3_FLG3_4G_DMA_BNDRY_BUG	0x00080000
-#define TG3_FLG3_40BIT_DMA_LIMIT_BUG	0x00100000
-#define TG3_FLG3_SHORT_DMA_BUG		0x00200000
-#define TG3_FLG3_USE_JUMBO_BDFLAG	0x00400000
-#define TG3_FLG3_L1PLLPD_EN		0x00800000
-#define TG3_FLG3_57765_PLUS		0x01000000
-#define TG3_FLG3_APE_HAS_NCSI		0x02000000
-#define TG3_FLG3_5717_PLUS		0x04000000
-
 	struct timer_list		timer;
 	u16				timer_counter;
 	u16				timer_multiplier;
-- 
1.7.5.rc3.dirty



