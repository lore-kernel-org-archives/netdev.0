From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH v2] ipv4 : igmp : optimize timer modify logic in igmp_mod_timer()
Date: Thu, 24 Nov 2011 00:38:42 +0800
Message-ID: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jun Zhao <mypopydev@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44585 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677Ab1KWQlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 11:41:00 -0500
Received: by ywt32 with SMTP id 32so1561475ywt.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 08:40:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When timer is pending and expires less-than-or-equal-to new delay,
we need not used del_timer()/add_timer().

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv4/igmp.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7472ef..5f2aedf 100644
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
+	if (timer_pending(&im->timer)) {
+		if (time_before_eq(im->timer.expires, (jiffies + max_delay))) {
 			spin_unlock_bh(&im->lock);
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
