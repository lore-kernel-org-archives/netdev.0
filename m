From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] cfg80211: Fix memory leak
Date: Mon,  4 Feb 2013 15:33:44 -0600
Message-ID: <1360013624-4973-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:55447 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3BDVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 16:34:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>

When a driver requests a specific regulatory domain after cfg80211 already
has one, a struct ieee80211_regdomain is leaked.

Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Tested-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Johannes,

I added a From: for you as the content of this patch is yours.

Larry
---

 net/wireless/reg.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index de02d63..558f524 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2189,10 +2189,14 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 		 * However if a driver requested this specific regulatory
 		 * domain we keep it for its private use
 		 */
-		if (lr->initiator == NL80211_REGDOM_SET_BY_DRIVER)
+		if (lr->initiator == NL80211_REGDOM_SET_BY_DRIVER) {
+			const struct ieee80211_regdomain *tmp =
+						get_wiphy_regdom(request_wiphy);
 			rcu_assign_pointer(request_wiphy->regd, rd);
-		else
+			rcu_free_regdom(tmp);
+		} else {
 			kfree(rd);
+		}
 
 		rd = NULL;
 
-- 
1.8.1
