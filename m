From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Add external loopback support to
 selftest
Date: Fri, 19 Aug 2011 16:58:23 -0700
Message-ID: <1313798304-26171-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2636 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab1HSXu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds external loopback support to tg3's ethtool selftest.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   97 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/tg3.h |    3 +
 2 files changed, 90 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6827b4f..eb3b5ce 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -396,6 +396,7 @@ static const struct {
 	{ "memory test       (offline)" },
 	{ "mac loopback test (offline)" },
 	{ "phy loopback test (offline)" },
+	{ "ext loopback test (offline)" },
 	{ "interrupt test    (offline)" },
 };
 
@@ -1680,6 +1681,36 @@ static void tg3_phy_fini(struct tg3 *tp)
 	}
 }
 
+static int tg3_phy_set_extloopbk(struct tg3 *tp)
+{
+	int err;
+	u32 val;
+
+	if (tp->phy_flags & TG3_PHYFLG_IS_FET)
+		return 0;
+
+	if ((tp->phy_id & TG3_PHY_ID_MASK) == TG3_PHY_ID_BCM5401) {
+		/* Cannot do read-modify-write on 5401 */
+		err = tg3_phy_auxctl_write(tp,
+					   MII_TG3_AUXCTL_SHDWSEL_AUXCTL,
+					   MII_TG3_AUXCTL_ACTL_EXTLOOPBK |
+					   0x4c20);
+		goto done;
+	}
+
+	err = tg3_phy_auxctl_read(tp,
+				  MII_TG3_AUXCTL_SHDWSEL_AUXCTL, &val);
+	if (err)
+		return err;
+
+	val |= MII_TG3_AUXCTL_ACTL_EXTLOOPBK;
+	err = tg3_phy_auxctl_write(tp,
+				   MII_TG3_AUXCTL_SHDWSEL_AUXCTL, val);
+
+done:
+	return err;
+}
+
 static void tg3_phy_fet_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 phytest;
@@ -6371,14 +6402,17 @@ static void tg3_mac_loopback(struct tg3 *tp, bool enable)
 	udelay(40);
 }
 
-static void tg3_phy_lpbk_set(struct tg3 *tp, u32 speed)
+static int tg3_phy_lpbk_set(struct tg3 *tp, u32 speed, bool extlpbk)
 {
-	u32 val, bmcr, mac_mode;
+	u32 val, bmcr, mac_mode, ptest = 0;
 
 	tg3_phy_toggle_apd(tp, false);
 	tg3_phy_toggle_automdix(tp, 0);
 
-	bmcr = BMCR_LOOPBACK | BMCR_FULLDPLX;
+	if (extlpbk && tg3_phy_set_extloopbk(tp))
+		return -EIO;
+
+	bmcr = BMCR_FULLDPLX;
 	switch (speed) {
 	case SPEED_10:
 		break;
@@ -6396,6 +6430,20 @@ static void tg3_phy_lpbk_set(struct tg3 *tp, u32 speed)
 		}
 	}
 
+	if (extlpbk) {
+		if (!(tp->phy_flags & TG3_PHYFLG_IS_FET)) {
+			tg3_readphy(tp, MII_CTRL1000, &val);
+			val |= CTL1000_AS_MASTER |
+			       CTL1000_ENABLE_MASTER;
+			tg3_writephy(tp, MII_CTRL1000, val);
+		} else {
+			ptest = MII_TG3_FET_PTEST_TRIM_SEL |
+				MII_TG3_FET_PTEST_TRIM_2;
+			tg3_writephy(tp, MII_TG3_FET_PTEST, ptest);
+		}
+	} else
+		bmcr |= BMCR_LOOPBACK;
+
 	tg3_writephy(tp, MII_BMCR, bmcr);
 
 	/* The write needs to be flushed for the FETs */
@@ -6406,7 +6454,7 @@ static void tg3_phy_lpbk_set(struct tg3 *tp, u32 speed)
 
 	if ((tp->phy_flags & TG3_PHYFLG_IS_FET) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
-		tg3_writephy(tp, MII_TG3_FET_PTEST,
+		tg3_writephy(tp, MII_TG3_FET_PTEST, ptest |
 			     MII_TG3_FET_PTEST_FRC_TX_LINK |
 			     MII_TG3_FET_PTEST_FRC_TX_LOCK);
 
@@ -6443,6 +6491,8 @@ static void tg3_phy_lpbk_set(struct tg3 *tp, u32 speed)
 
 	tw32(MAC_MODE, mac_mode);
 	udelay(40);
+
+	return 0;
 }
 
 static void tg3_set_loopback(struct net_device *dev, u32 features)
@@ -11542,7 +11592,7 @@ out:
 	 TG3_JMB_LOOPBACK_FAILED | \
 	 TG3_TSO_LOOPBACK_FAILED)
 
-static int tg3_test_loopback(struct tg3 *tp, u64 *data)
+static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
 {
 	int err = -EIO;
 	u32 eee_cap;
@@ -11553,6 +11603,8 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data)
 	if (!netif_running(tp->dev)) {
 		data[0] = TG3_LOOPBACK_FAILED;
 		data[1] = TG3_LOOPBACK_FAILED;
+		if (do_extlpbk)
+			data[2] = TG3_LOOPBACK_FAILED;
 		goto done;
 	}
 
@@ -11560,6 +11612,8 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data)
 	if (err) {
 		data[0] = TG3_LOOPBACK_FAILED;
 		data[1] = TG3_LOOPBACK_FAILED;
+		if (do_extlpbk)
+			data[2] = TG3_LOOPBACK_FAILED;
 		goto done;
 	}
 
@@ -11595,7 +11649,7 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data)
 	    !tg3_flag(tp, USE_PHYLIB)) {
 		int i;
 
-		tg3_phy_lpbk_set(tp, 0);
+		tg3_phy_lpbk_set(tp, 0, false);
 
 		/* Wait for link */
 		for (i = 0; i < 100; i++) {
@@ -11613,12 +11667,31 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data)
 		    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
 			data[1] |= TG3_JMB_LOOPBACK_FAILED;
 
+		if (do_extlpbk) {
+			tg3_phy_lpbk_set(tp, 0, true);
+
+			/* All link indications report up, but the hardware
+			 * isn't really ready for about 20 msec.  Double it
+			 * to be sure.
+			 */
+			mdelay(40);
+
+			if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
+				data[2] |= TG3_STD_LOOPBACK_FAILED;
+			if (tg3_flag(tp, TSO_CAPABLE) &&
+			    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
+				data[2] |= TG3_TSO_LOOPBACK_FAILED;
+			if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
+			    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+				data[2] |= TG3_JMB_LOOPBACK_FAILED;
+		}
+
 		/* Re-enable gphy autopowerdown. */
 		if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 			tg3_phy_toggle_apd(tp, true);
 	}
 
-	err = (data[0] | data[1]) ? -EIO : 0;
+	err = (data[0] | data[1] | data[2]) ? -EIO : 0;
 
 done:
 	tp->phy_flags |= eee_cap;
@@ -11630,6 +11703,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 			  u64 *data)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	bool doextlpbk = etest->flags & ETH_TEST_FL_EXTERNAL_LB;
 
 	if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) &&
 	    tg3_power_up(tp)) {
@@ -11644,7 +11718,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 		etest->flags |= ETH_TEST_FL_FAILED;
 		data[0] = 1;
 	}
-	if (tg3_test_link(tp) != 0) {
+	if (!doextlpbk && tg3_test_link(tp)) {
 		etest->flags |= ETH_TEST_FL_FAILED;
 		data[1] = 1;
 	}
@@ -11680,14 +11754,17 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 			data[3] = 1;
 		}
 
-		if (tg3_test_loopback(tp, &data[4]))
+		if (doextlpbk)
+			etest->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
+
+		if (tg3_test_loopback(tp, &data[4], doextlpbk))
 			etest->flags |= ETH_TEST_FL_FAILED;
 
 		tg3_full_unlock(tp);
 
 		if (tg3_test_interrupt(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
-			data[6] = 1;
+			data[7] = 1;
 		}
 
 		tg3_full_lock(tp, 0);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 2ea456d..d2976f3 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2197,6 +2197,7 @@
 #define MII_TG3_AUXCTL_ACTL_TX_6DB	0x0400
 #define MII_TG3_AUXCTL_ACTL_SMDSP_ENA	0x0800
 #define MII_TG3_AUXCTL_ACTL_EXTPKTLEN	0x4000
+#define MII_TG3_AUXCTL_ACTL_EXTLOOPBK	0x8000
 
 #define MII_TG3_AUXCTL_SHDWSEL_PWRCTL	0x0002
 #define MII_TG3_AUXCTL_PCTL_WOL_EN	0x0008
@@ -2262,6 +2263,8 @@
 
 /* Fast Ethernet Tranceiver definitions */
 #define MII_TG3_FET_PTEST		0x17
+#define  MII_TG3_FET_PTEST_TRIM_SEL	0x0010
+#define  MII_TG3_FET_PTEST_TRIM_2	0x0002
 #define  MII_TG3_FET_PTEST_FRC_TX_LINK	0x1000
 #define  MII_TG3_FET_PTEST_FRC_TX_LOCK	0x0800
 
-- 
1.7.3.4


