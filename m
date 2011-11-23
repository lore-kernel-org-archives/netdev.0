From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH] ipv4 : igmp : optimize timer modify logic in igmp_mod_timer()
Date: Wed, 23 Nov 2011 23:26:44 +0800
Message-ID: <1322062004-9742-1-git-send-email-mypopydev@gmail.com>
Cc: netdev@vger.kernel.org, Jun Zhao <mypopydev@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36442 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756431Ab1KWP2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 10:28:02 -0500
Received: by ywt32 with SMTP id 32so1476017ywt.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 07:28:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When timer is pending and expires less-than-or-equal-to new delay,
we need not used del_timer()/add_timer().

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv4/igmp.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..50d06c5 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -215,14 +215,14 @@ static void igmp_mod_timer(struct ip_mc_list *im, int max_delay)
 {
 	spin_lock_bh(&im->lock);
 	im->unsolicit_count = 0;
-	if (del_timer(&im->timer)) {
-		if ((long)(im->timer.expires-jiffies) < max_delay) {
-			add_timer(&im->timer);
-			im->tm_running = 1;
-			spin_unlock_bh(&im->lock);
+	if (timer_pending(&im->timer)) {
+		if (time_before_eq(im->timer.expires, (jiffies + max_delay))) {
+			spin_lock_bh(&im->lock);
 			return;
+		} else {
+			del_timer(&im->timer);
+			atomic_dec(&im->refcnt);
 		}
-		atomic_dec(&im->refcnt);
 	}
 	igmp_start_timer(im, max_delay);
 	spin_unlock_bh(&im->lock);
-- 
1.7.2.5
