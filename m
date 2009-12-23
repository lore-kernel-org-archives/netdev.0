From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch] fix error paths in cfg80211_wext_siwscan()
Date: Wed, 23 Dec 2009 15:29:37 +0200
Message-ID: <20091223132937.GG17923@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The new code calls kfree(creq) and on the wreq->essid_len > IEEE80211_MAX_SSID_LEN
case it also unlocks the rdev lock.

This was found with a static checker and compile tested only.  :/

Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

--- orig/net/wireless/scan.c	2009-12-23 08:38:15.000000000 +0200
+++ devel/net/wireless/scan.c	2009-12-23 08:50:15.000000000 +0200
@@ -685,7 +685,7 @@ int cfg80211_wext_siwscan(struct net_dev
 	/* No channels found? */
 	if (!i) {
 		err = -EINVAL;
-		goto out;
+		goto out1;
 	}
 
 	/* Set real number of channels specified in creq->channels[] */
@@ -694,8 +694,10 @@ int cfg80211_wext_siwscan(struct net_dev
 	/* translate "Scan for SSID" request */
 	if (wreq) {
 		if (wrqu->data.flags & IW_SCAN_THIS_ESSID) {
-			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN)
-				return -EINVAL;
+			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN) {
+				err = -EINVAL;
+				goto out1;
+			}
 			memcpy(creq->ssids[0].ssid, wreq->essid, wreq->essid_len);
 			creq->ssids[0].ssid_len = wreq->essid_len;
 		}
@@ -705,6 +707,7 @@ int cfg80211_wext_siwscan(struct net_dev
 
 	rdev->scan_req = creq;
 	err = rdev->ops->scan(wiphy, dev, creq);
+out1:
 	if (err) {
 		rdev->scan_req = NULL;
 		kfree(creq);
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
