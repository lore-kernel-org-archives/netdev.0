From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/11][TG3]: WoL fixes.
Date: Fri, 04 May 2007 17:52:44 -0700
Message-ID: <1178326364.4859.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3289 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767923AbXEEAF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: WoL fixes.

Change TG3_FLAG_SERDES_WOL_CAP to TG3_FLAG_WOL_CAP to make it easier
to manage WoL.  This flag is now used consistently during ethtool WoL
setup and power setting changes.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6bd17d9..bc49f8b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1300,9 +1300,11 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			msleep(1);
 		}
 	}
-	tg3_write_mem(tp, NIC_SRAM_WOL_MBOX, WOL_SIGNATURE |
-					     WOL_DRV_STATE_SHUTDOWN |
-					     WOL_DRV_WOL | WOL_SET_MAGIC_PKT);
+	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
+		tg3_write_mem(tp, NIC_SRAM_WOL_MBOX, WOL_SIGNATURE |
+						     WOL_DRV_STATE_SHUTDOWN |
+						     WOL_DRV_WOL |
+						     WOL_SET_MAGIC_PKT);
 
 	pci_read_config_word(tp->pdev, pm + PCI_PM_PMC, &power_caps);
 
@@ -8034,7 +8036,10 @@ static void tg3_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	wol->supported = WAKE_MAGIC;
+	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
+		wol->supported = WAKE_MAGIC;
+	else
+		wol->supported = 0;
 	wol->wolopts = 0;
 	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
 		wol->wolopts = WAKE_MAGIC;
@@ -8048,8 +8053,7 @@ static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 	if ((wol->wolopts & WAKE_MAGIC) &&
-	    tp->tg3_flags2 & TG3_FLG2_ANY_SERDES &&
-	    !(tp->tg3_flags & TG3_FLAG_SERDES_WOL_CAP))
+	    !(tp->tg3_flags & TG3_FLAG_WOL_CAP))
 		return -EINVAL;
 
 	spin_lock_bh(&tp->lock);
@@ -10001,8 +10005,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	tp->phy_id = PHY_ID_INVALID;
 	tp->led_ctrl = LED_CTRL_MODE_PHY_1;
 
-	/* Assume an onboard device by default.  */
-	tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
+	/* Assume an onboard device and WOL capable by default.  */
+	tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT | TG3_FLAG_WOL_CAP;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 		if (!(tr32(PCIE_TRANSACTION_CFG) & PCIE_TRANS_CFG_LOM)) {
@@ -10125,8 +10129,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
 				tp->tg3_flags2 |= TG3_FLG2_ASF_NEW_HANDSHAKE;
 		}
-		if (nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL)
-			tp->tg3_flags |= TG3_FLAG_SERDES_WOL_CAP;
+		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES &&
+		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
+			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
 
 		if (cfg2 & (1 << 17))
 			tp->tg3_flags2 |= TG3_FLG2_CAPACITIVE_COUPLING;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d515ed2..f76e310 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2215,7 +2215,7 @@ struct tg3 {
 #define TG3_FLAG_PCI_32BIT		0x00080000
 #define TG3_FLAG_SRAM_USE_CONFIG	0x00100000
 #define TG3_FLAG_TX_RECOVERY_PENDING	0x00200000
-#define TG3_FLAG_SERDES_WOL_CAP		0x00400000
+#define TG3_FLAG_WOL_CAP		0x00400000
 #define TG3_FLAG_JUMBO_RING_ENABLE	0x00800000
 #define TG3_FLAG_10_100_ONLY		0x01000000
 #define TG3_FLAG_PAUSE_AUTONEG		0x02000000



