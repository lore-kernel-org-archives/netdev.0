From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Mon, 6 Aug 2007 16:13:21 -0400
Message-ID: <20070806201321.GI6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some fixes intended for 2.6.23.  Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem/

Thanks!

John
---

The following changes since commit d4ac2477fad0f2680e84ec12e387ce67682c5c13:
  Linus Torvalds (1):
        Linux 2.6.23-rc2

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Daniel Drake (2):
      mac80211: missing dev_put in ieee80211_master_start_xmit
      mac80211: don't allow scanning in monitor mode

Zhu Yi (2):
      mac80211: use do { } while (0) for multi-line macros
      mac80211: Fix sparse error for sta_last_seq_ctrl_read

 net/mac80211/debugfs_netdev.c  |    8 +++++---
 net/mac80211/debugfs_sta.c     |    2 +-
 net/mac80211/ieee80211.c       |    1 +
 net/mac80211/ieee80211_ioctl.c |   19 +++++++++++++------
 4 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 799a920..095be91 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -271,9 +271,11 @@ static void add_files(struct ieee80211_sub_if_data *sdata)
 	}
 }
 
-#define DEBUGFS_DEL(name, type)\
-	debugfs_remove(sdata->debugfs.type.name);\
-	sdata->debugfs.type.name = NULL;
+#define DEBUGFS_DEL(name, type)					\
+	do {							\
+		debugfs_remove(sdata->debugfs.type.name);	\
+		sdata->debugfs.type.name = NULL;		\
+	} while (0)
 
 static void del_sta_files(struct ieee80211_sub_if_data *sdata)
 {
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index d41e696..da34ea7 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -157,7 +157,7 @@ static ssize_t sta_last_seq_ctrl_read(struct file *file, char __user *userbuf,
 	struct sta_info *sta = file->private_data;
 	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
 		p += scnprintf(p, sizeof(buf)+buf-p, "%x ",
-			       sta->last_seq_ctrl[i]);
+			       le16_to_cpu(sta->last_seq_ctrl[i]));
 	p += scnprintf(p, sizeof(buf)+buf-p, "\n");
 	return simple_read_from_buffer(userbuf, count, ppos, buf, p - buf);
 }
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index c944b17..8ec5ed1 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -1650,6 +1650,7 @@ static int ieee80211_master_start_xmit(struct sk_buff *skb,
 	if (skb_headroom(skb) < headroom) {
 		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
+			dev_put(odev);
 			return 0;
 		}
 	}
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index d0e1ab5..e7904db 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -697,17 +697,24 @@ static int ieee80211_ioctl_siwscan(struct net_device *dev,
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
-	if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-		if (sdata->type == IEEE80211_IF_TYPE_STA ||
-		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
 			ssid = sdata->u.sta.ssid;
 			ssid_len = sdata->u.sta.ssid_len;
-		} else if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		}
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
 			ssid = sdata->u.ap.ssid;
 			ssid_len = sdata->u.ap.ssid_len;
-		} else
-			return -EINVAL;
+		}
+		break;
+	default:
+		return -EOPNOTSUPP;
 	}
+
 	return ieee80211_sta_req_scan(dev, ssid, ssid_len);
 }
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
