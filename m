From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/15] tg3: Refine power management and WOL code
Date: Mon, 3 Nov 2008 02:13:10 -0800
Message-ID: <1225751625.6187@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2836 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756711AbYKCWdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 12dac0756d357325b107fe6ec24921ec38661839 introduced the new PCI
PM API to the tg3 driver.  The patch was understandably conservative, so
this patch elaborates on that work.

The patch starts by creating a single point in tg3_set_power_state()
to decide whether or not to enable WOL.  The rest of the code in
tg3_set_power_state() was then pivoted to use the result of this
decision.

The patch then makes sure the device is allowed to wakeup before
reporting whether or not WOL is currently enabled.  The final hunks of
the patch consolidate where the WOL capability and WOL enabled flags
are set to a single location.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   40 +++++++++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index aebc645..e64721b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2052,6 +2052,7 @@ static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
 static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 {
 	u32 misc_host_ctrl;
+	bool device_should_wake;
 
 	/* Make sure register accesses (indirect or otherwise)
 	 * will function correctly.
@@ -2085,6 +2086,10 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
 
+	device_should_wake = pci_pme_capable(tp->pdev, state) &&
+			     device_may_wakeup(&tp->pdev->dev) &&
+			     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 		if ((tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) &&
 		    !tp->link_config.phy_is_low_power) {
@@ -2106,7 +2111,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 				      ADVERTISED_10baseT_Half;
 
 			if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-			    (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
+			    device_should_wake) {
 				if (tp->tg3_flags & TG3_FLAG_WOL_SPEED_100MB)
 					advertising |=
 						ADVERTISED_100baseT_Half |
@@ -2160,7 +2165,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 						     WOL_DRV_WOL |
 						     WOL_SET_MAGIC_PKT);
 
-	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE) {
+	if (device_should_wake) {
 		u32 mac_mode;
 
 		if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
@@ -2192,15 +2197,12 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		if (!(tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 			tw32(MAC_LED_CTRL, tp->led_ctrl);
 
-		if (pci_pme_capable(tp->pdev, state) &&
-		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)) {
-			mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
-			if (((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
-			    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) &&
-			    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-			     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)))
-				mac_mode |= MAC_MODE_KEEP_FRAME_IN_WOL;
-		}
+		mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
+		if (((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+		    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) &&
+		    ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+		     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)))
+			mac_mode |= MAC_MODE_KEEP_FRAME_IN_WOL;
 
 		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
 			mac_mode |= tp->mac_mode &
@@ -2272,7 +2274,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		}
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_WOL_ENABLE) &&
+	if (!(device_should_wake) &&
 	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
 		tg3_power_down_phy(tp);
@@ -2298,7 +2300,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 
 	tg3_write_sig_post_reset(tp, RESET_KIND_SHUTDOWN);
 
-	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
+	if (device_should_wake)
 		pci_enable_wake(tp->pdev, state, true);
 
 	/* Finally, set the new power state. */
@@ -9082,7 +9084,8 @@ static void tg3_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	else
 		wol->supported = 0;
 	wol->wolopts = 0;
-	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
+	if ((tp->tg3_flags & TG3_FLAG_WOL_ENABLE) &&
+	    device_can_wakeup(&tp->pdev->dev))
 		wol->wolopts = WAKE_MAGIC;
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
 }
@@ -11315,7 +11318,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    (val & VCPU_CFGSHDW_WOL_MAGPKT) &&
 		    device_may_wakeup(&tp->pdev->dev))
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
-		return;
+		goto done;
 	}
 
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
@@ -11447,8 +11450,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
 
 		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
-		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE) &&
-		    device_may_wakeup(&tp->pdev->dev))
+		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE))
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 
 		if (cfg2 & (1 << 17))
@@ -11474,6 +11476,10 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_TX_EN)
 			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_TX_EN;
 	}
+done:
+	device_init_wakeup(&tp->pdev->dev, tp->tg3_flags & TG3_FLAG_WOL_CAP);
+	device_set_wakeup_enable(&tp->pdev->dev,
+				 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
 }
 
 static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
-- 
1.5.6.4



