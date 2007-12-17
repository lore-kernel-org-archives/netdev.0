From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Mon, 17 Dec 2007 15:54:54 -0500
Message-ID: <20071217205454.GG3121@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A few more small fixes for 2.6.24.  Let me know if there are any
problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit 82d29bf6dc7317aeb0a3a13c2348ca8591965875:
  Linus Torvalds (1):
        Linux 2.6.24-rc5

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Cyrill Gorcunov (1):
      NET: mac80211: fix inappropriate memory freeing

Johannes Berg (1):
      mac80211: fix header ops

Michael Wu (1):
      mac80211: Drop out of associated state if link is lost

 net/mac80211/ieee80211.c      |    1 -
 net/mac80211/ieee80211_rate.c |    2 +-
 net/mac80211/ieee80211_sta.c  |    8 ++------
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 505af1f..6378850 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -427,7 +427,6 @@ static const struct header_ops ieee80211_header_ops = {
 void ieee80211_if_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->header_ops = &ieee80211_header_ops;
 	dev->hard_start_xmit = ieee80211_subif_start_xmit;
 	dev->wireless_handlers = &ieee80211_iw_handler_def;
 	dev->set_multicast_list = ieee80211_set_multicast_list;
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 7254bd6..9f26a10 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -59,11 +59,11 @@ void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
 	list_for_each_entry(alg, &rate_ctrl_algs, list) {
 		if (alg->ops == ops) {
 			list_del(&alg->list);
+			kfree(alg);
 			break;
 		}
 	}
 	mutex_unlock(&rate_ctrl_mutex);
-	kfree(alg);
 }
 EXPORT_SYMBOL(ieee80211_rate_control_unregister);
 
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 16afd24..bee8080 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -808,12 +808,8 @@ static void ieee80211_associated(struct net_device *dev,
 		sta_info_put(sta);
 	}
 	if (disassoc) {
-		union iwreq_data wrqu;
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
-		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
-		wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
-		mod_timer(&ifsta->timer, jiffies +
-				      IEEE80211_MONITORING_INTERVAL + 30 * HZ);
+		ifsta->state = IEEE80211_DISABLED;
+		ieee80211_set_associated(dev, ifsta, 0);
 	} else {
 		mod_timer(&ifsta->timer, jiffies +
 				      IEEE80211_MONITORING_INTERVAL);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
