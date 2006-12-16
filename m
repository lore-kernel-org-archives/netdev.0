From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4][TG3]: Power down/up 5906 PHY correctly.
Date: Fri, 15 Dec 2006 22:48:54 -0800
Message-ID: <1166251734.30429.11.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1700 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030612AbWLPF7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 00:59:32 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Power down/up 5906 PHY correctly.

The 5906 PHY requires a special register bit to power down and up the
PHY.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6804489..6ee399c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -959,6 +959,13 @@ static int tg3_phy_reset(struct tg3 *tp)
 	u32 phy_status;
 	int err;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 val;
+
+		val = tr32(GRC_MISC_CFG);
+		tw32_f(GRC_MISC_CFG, val & ~GRC_MISC_CFG_EPHY_IDDQ);
+		udelay(40);
+	}
 	err  = tg3_readphy(tp, MII_BMSR, &phy_status);
 	err |= tg3_readphy(tp, MII_BMSR, &phy_status);
 	if (err != 0)
@@ -1170,7 +1177,15 @@ static void tg3_power_down_phy(struct tg
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 		return;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 val;
+
+		tg3_bmcr_reset(tp);
+		val = tr32(GRC_MISC_CFG);
+		tw32_f(GRC_MISC_CFG, val | GRC_MISC_CFG_EPHY_IDDQ);
+		udelay(40);
+		return;
+	} else {
 		tg3_writephy(tp, MII_TG3_EXT_CTRL,
 			     MII_TG3_EXT_CTRL_FORCE_LED_OFF);
 		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x01b2);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dfaf4ed..cf78a7e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1350,6 +1350,7 @@
 #define  GRC_MISC_CFG_BOARD_ID_5788	0x00010000
 #define  GRC_MISC_CFG_BOARD_ID_5788M	0x00018000
 #define  GRC_MISC_CFG_BOARD_ID_AC91002A1 0x00018000
+#define  GRC_MISC_CFG_EPHY_IDDQ		0x00200000
 #define  GRC_MISC_CFG_KEEP_GPHY_POWER	0x04000000
 #define GRC_LOCAL_CTRL			0x00006808
 #define  GRC_LCLCTRL_INT_ACTIVE		0x00000001


