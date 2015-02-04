From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] cw1200: use msecs_to_jiffies for conversion
Date: Wed,  4 Feb 2015 02:39:49 -0500
Message-ID: <1423035589-3647-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Solomon Peachy <pizza@shaftnet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:35390 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932318AbbBDHoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 02:44:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is only an API consolidation to make things more readable.
Instances of  HZ / CONST  are replaced by appropriate msecs_to_jiffies().

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Converting milliseconds to jiffies by "val * HZ / 1000" or passing
HZ / 10 is technically OK but appropriate msecs_to_jiffies(val), respectively
msecs_to_jiffies(100) is the cleaner solution and handles all corner cases 
correctly. This is a minor API cleanup only.

Patch was only compile tested for x86_64_defconfig + CONFIG_CW1200=m

Patch is against 3.19.0-rc7 (localversion-next = -next-20150203)

 drivers/net/wireless/cw1200/scan.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/cw1200/scan.c b/drivers/net/wireless/cw1200/scan.c
index f2e276f..bff81b8 100644
--- a/drivers/net/wireless/cw1200/scan.c
+++ b/drivers/net/wireless/cw1200/scan.c
@@ -39,9 +39,9 @@ static int cw1200_scan_start(struct cw1200_common *priv, struct wsm_scan *scan)
 	cancel_delayed_work_sync(&priv->clear_recent_scan_work);
 	atomic_set(&priv->scan.in_progress, 1);
 	atomic_set(&priv->recent_scan, 1);
-	cw1200_pm_stay_awake(&priv->pm_state, tmo * HZ / 1000);
+	cw1200_pm_stay_awake(&priv->pm_state, msecs_to_jiffies(tmo));
 	queue_delayed_work(priv->workqueue, &priv->scan.timeout,
-			   tmo * HZ / 1000);
+			   msecs_to_jiffies(tmo));
 	ret = wsm_scan(priv, scan);
 	if (ret) {
 		atomic_set(&priv->scan.in_progress, 0);
@@ -386,8 +386,8 @@ void cw1200_probe_work(struct work_struct *work)
 	if (down_trylock(&priv->scan.lock)) {
 		/* Scan is already in progress. Requeue self. */
 		schedule();
-		queue_delayed_work(priv->workqueue,
-				   &priv->scan.probe_work, HZ / 10);
+		queue_delayed_work(priv->workqueue, &priv->scan.probe_work,
+				   msecs_to_jiffies(100));
 		mutex_unlock(&priv->conf_mutex);
 		return;
 	}
-- 
1.7.10.4
