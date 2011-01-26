From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/11] tg3: Disable EEE during loopback tests
Date: Tue, 25 Jan 2011 17:58:54 -0800
Message-ID: <1296007137-23146-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1852 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab1AZB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 20:59:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEE interferes with the hardware's ability to loop a packet back to the
host.  This patch disables the feature for the duration of the test.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0f00270..997f0d2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11013,14 +11013,19 @@ out:
 static int tg3_test_loopback(struct tg3 *tp)
 {
 	int err = 0;
-	u32 cpmuctrl = 0;
+	u32 eee_cap, cpmuctrl = 0;
 
 	if (!netif_running(tp->dev))
 		return TG3_LOOPBACK_FAILED;
 
+	eee_cap = tp->phy_flags & TG3_PHYFLG_EEE_CAP;
+	tp->phy_flags &= ~TG3_PHYFLG_EEE_CAP;
+
 	err = tg3_reset_hw(tp, 1);
-	if (err)
-		return TG3_LOOPBACK_FAILED;
+	if (err) {
+		err = TG3_LOOPBACK_FAILED;
+		goto done;
+	}
 
 	/* Turn off gphy autopowerdown. */
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
@@ -11040,8 +11045,10 @@ static int tg3_test_loopback(struct tg3 *tp)
 			udelay(10);
 		}
 
-		if (status != CPMU_MUTEX_GNT_DRIVER)
-			return TG3_LOOPBACK_FAILED;
+		if (status != CPMU_MUTEX_GNT_DRIVER) {
+			err = TG3_LOOPBACK_FAILED;
+			goto done;
+		}
 
 		/* Turn off link-based power management. */
 		cpmuctrl = tr32(TG3_CPMU_CTRL);
@@ -11070,6 +11077,9 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, true);
 
+done:
+	tp->phy_flags |= eee_cap;
+
 	return err;
 }
 
-- 
1.7.2.2


