From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/9] tg3: Move phy accessor functions higher
Date: Wed, 20 Apr 2011 10:57:39 -0700
Message-ID: <1303322263-18991-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1903 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365Ab1DTRs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phy accessor functions should live closer to where the base phy read /
write routines are.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  136 ++++++++++++++++++++++++++--------------------------
 1 files changed, 68 insertions(+), 68 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e134e48..ea41d76 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -881,6 +881,74 @@ static int tg3_writephy(struct tg3 *tp, int reg, u32 val)
 	return ret;
 }
 
+static int tg3_phy_cl45_write(struct tg3 *tp, u32 devad, u32 addr, u32 val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
+			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, val);
+
+done:
+	return err;
+}
+
+static int tg3_phy_cl45_read(struct tg3 *tp, u32 devad, u32 addr, u32 *val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
+	if (err)
+		goto done;
+
+	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
+			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
+	if (err)
+		goto done;
+
+	err = tg3_readphy(tp, MII_TG3_MMD_ADDRESS, val);
+
+done:
+	return err;
+}
+
+static int tg3_phydsp_read(struct tg3 *tp, u32 reg, u32 *val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
+	if (!err)
+		err = tg3_readphy(tp, MII_TG3_DSP_RW_PORT, val);
+
+	return err;
+}
+
+static int tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
+{
+	int err;
+
+	err = tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
+	if (!err)
+		err = tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
+
+	return err;
+}
+
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
 	u32 phy_control;
@@ -1154,52 +1222,6 @@ static void tg3_mdio_fini(struct tg3 *tp)
 	}
 }
 
-static int tg3_phy_cl45_write(struct tg3 *tp, u32 devad, u32 addr, u32 val)
-{
-	int err;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
-	if (err)
-		goto done;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
-	if (err)
-		goto done;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
-			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
-	if (err)
-		goto done;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, val);
-
-done:
-	return err;
-}
-
-static int tg3_phy_cl45_read(struct tg3 *tp, u32 devad, u32 addr, u32 *val)
-{
-	int err;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_CTRL, devad);
-	if (err)
-		goto done;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_ADDRESS, addr);
-	if (err)
-		goto done;
-
-	err = tg3_writephy(tp, MII_TG3_MMD_CTRL,
-			   MII_TG3_MMD_CTRL_DATA_NOINC | devad);
-	if (err)
-		goto done;
-
-	err = tg3_readphy(tp, MII_TG3_MMD_ADDRESS, val);
-
-done:
-	return err;
-}
-
 /* tp->lock is held. */
 static inline void tg3_generate_fw_event(struct tg3 *tp)
 {
@@ -1576,28 +1598,6 @@ static void tg3_phy_fini(struct tg3 *tp)
 	}
 }
 
-static int tg3_phydsp_read(struct tg3 *tp, u32 reg, u32 *val)
-{
-	int err;
-
-	err = tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
-	if (!err)
-		err = tg3_readphy(tp, MII_TG3_DSP_RW_PORT, val);
-
-	return err;
-}
-
-static int tg3_phydsp_write(struct tg3 *tp, u32 reg, u32 val)
-{
-	int err;
-
-	err = tg3_writephy(tp, MII_TG3_DSP_ADDRESS, reg);
-	if (!err)
-		err = tg3_writephy(tp, MII_TG3_DSP_RW_PORT, val);
-
-	return err;
-}
-
 static void tg3_phy_fet_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 phytest;
-- 
1.7.3.4


