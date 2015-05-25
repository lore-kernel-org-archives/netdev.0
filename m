From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net 2/3] net: dp83640: reinforce locking rules.
Date: Mon, 25 May 2015 11:55:44 +0200
Message-ID: <e7890424afd2dce4a4b04cfbad9bc6c600cae4fb.1432547381.git.richardcochran@gmail.com>
References: <cover.1432547381.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Christian Riesch <christian.riesch@omicron.at>,
	Stefan Sorensen <stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35769 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbbEYJzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:55:52 -0400
Received: by wgme6 with SMTP id e6so410968wgm.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:55:51 -0700 (PDT)
In-Reply-To: <cover.1432547381.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers of the ext_write function are supposed to hold a mutex that
protects the state of the dialed page, but one caller was missing the
lock from the very start, and over time the code has been changed
without following the rule.  This patch cleans up the call sites in
violation of the rule.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 7a068d9..e570036 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -496,7 +496,9 @@ static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
 			else
 				evnt |= EVNT_RISE;
 		}
+		mutex_lock(&clock->extreg_lock);
 		ext_write(0, phydev, PAGE5, PTP_EVNT, evnt);
+		mutex_unlock(&clock->extreg_lock);
 		return 0;
 
 	case PTP_CLK_REQ_PEROUT:
@@ -532,6 +534,8 @@ static u8 status_frame_src[6] = { 0x08, 0x00, 0x17, 0x0B, 0x6B, 0x0F };
 
 static void enable_status_frames(struct phy_device *phydev, bool on)
 {
+	struct dp83640_private *dp83640 = phydev->priv;
+	struct dp83640_clock *clock = dp83640->clock;
 	u16 cfg0 = 0, ver;
 
 	if (on)
@@ -539,9 +543,13 @@ static void enable_status_frames(struct phy_device *phydev, bool on)
 
 	ver = (PSF_PTPVER & VERSIONPTP_MASK) << VERSIONPTP_SHIFT;
 
+	mutex_lock(&clock->extreg_lock);
+
 	ext_write(0, phydev, PAGE5, PSF_CFG0, cfg0);
 	ext_write(0, phydev, PAGE6, PSF_CFG1, ver);
 
+	mutex_unlock(&clock->extreg_lock);
+
 	if (!phydev->attached_dev) {
 		pr_warn("expected to find an attached netdevice\n");
 		return;
@@ -1173,11 +1181,18 @@ static int dp83640_config_init(struct phy_device *phydev)
 
 	if (clock->chosen && !list_empty(&clock->phylist))
 		recalibrate(clock);
-	else
+	else {
+		mutex_lock(&clock->extreg_lock);
 		enable_broadcast(phydev, clock->page, 1);
+		mutex_unlock(&clock->extreg_lock);
+	}
 
 	enable_status_frames(phydev, true);
+
+	mutex_lock(&clock->extreg_lock);
 	ext_write(0, phydev, PAGE4, PTP_CTL, PTP_ENABLE);
+	mutex_unlock(&clock->extreg_lock);
+
 	return 0;
 }
 
-- 
2.1.4
