From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Thu, 20 Dec 2007 10:52:27 -0500
Message-ID: <20071220155227.GE3139@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A few more stragglers for 2.6.24...let me know if there are any
problems!

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit 82d29bf6dc7317aeb0a3a13c2348ca8591965875:
  Linus Torvalds (1):
        Linux 2.6.24-rc5

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Johannes Berg (2):
      mac80211: round station cleanup timer
      mac80211: warn when receiving frames with unaligned data

 net/mac80211/rx.c       |   13 +++++++++++++
 net/mac80211/sta_info.c |    7 +++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 00f908d..a7263fc 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1443,6 +1443,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_sub_if_data *prev = NULL;
 	struct sk_buff *skb_new;
 	u8 *bssid;
+	int hdrlen;
 
 	/*
 	 * key references and virtual interfaces are protected using RCU
@@ -1472,6 +1473,18 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	rx.fc = le16_to_cpu(hdr->frame_control);
 	type = rx.fc & IEEE80211_FCTL_FTYPE;
 
+	/*
+	 * Drivers are required to align the payload data to a four-byte
+	 * boundary, so the last two bits of the address where it starts
+	 * may not be set. The header is required to be directly before
+	 * the payload data, padding like atheros hardware adds which is
+	 * inbetween the 802.11 header and the payload is not supported,
+	 * the driver is required to move the 802.11 header further back
+	 * in that case.
+	 */
+	hdrlen = ieee80211_get_hdrlen(rx.fc);
+	WARN_ON_ONCE(((unsigned long)(skb->data + hdrlen)) & 3);
+
 	if (type == IEEE80211_FTYPE_DATA || type == IEEE80211_FTYPE_MGMT)
 		local->dot11ReceivedFragmentCount++;
 
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index e849155..cfd8ee9 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -14,6 +14,7 @@
 #include <linux/slab.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
+#include <linux/timer.h>
 
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
@@ -306,7 +307,8 @@ static void sta_info_cleanup(unsigned long data)
 	}
 	read_unlock_bh(&local->sta_lock);
 
-	local->sta_cleanup.expires = jiffies + STA_INFO_CLEANUP_INTERVAL;
+	local->sta_cleanup.expires =
+		round_jiffies(jiffies + STA_INFO_CLEANUP_INTERVAL);
 	add_timer(&local->sta_cleanup);
 }
 
@@ -345,7 +347,8 @@ void sta_info_init(struct ieee80211_local *local)
 	INIT_LIST_HEAD(&local->sta_list);
 
 	init_timer(&local->sta_cleanup);
-	local->sta_cleanup.expires = jiffies + STA_INFO_CLEANUP_INTERVAL;
+	local->sta_cleanup.expires =
+		round_jiffies(jiffies + STA_INFO_CLEANUP_INTERVAL);
 	local->sta_cleanup.data = (unsigned long) local;
 	local->sta_cleanup.function = sta_info_cleanup;
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
