From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 4.1] cfg80211: wext: clear sinfo struct before calling driver
Date: Tue,  9 Jun 2015 21:35:44 +0200
Message-ID: <1433878544-10749-1-git-send-email-johannes@sipsolutions.net>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>,
	Alexander Kaltsas <alexkaltsas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Until recently, mac80211 overwrote all the statistics it could
provide when getting called, but it now relies on the struct
having been zeroed by the caller. This was always the case in
nl80211, but wext used a static struct which could even cause
values from one device leak to another.

Using a static struct is OK (as even documented in a comment)
since the whole usage of this function and its return value is
always locked under RTNL. Not clearing the struct for calling
the driver has always been wrong though, since drivers were
free to only fill values they could report, so calling this
for one device and then for another would always have leaked
values from one to the other.

Fix this by initializing the structure in question before the
driver method call.

This fixes https://bugzilla.kernel.org/show_bug.cgi?id=99691

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
Reported-by: Alexander Kaltsas <alexkaltsas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
Dave, would you mind applying this patch directly? It seems a
bit pointless to send a pull request for a single patch again.
---
 net/wireless/wext-compat.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index fff1bef6ed6d..fd682832a0e3 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -1333,6 +1333,8 @@ static struct iw_statistics *cfg80211_wireless_stats(struct net_device *dev)
 	memcpy(bssid, wdev->current_bss->pub.bssid, ETH_ALEN);
 	wdev_unlock(wdev);
 
+	memset(&sinfo, 0, sizeof(sinfo));
+
 	if (rdev_get_station(rdev, dev, bssid, &sinfo))
 		return NULL;
 
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
