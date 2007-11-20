From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 20 Nov 2007 17:10:25 -0500
Message-ID: <20071120221025.GH16090@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some more fixes for 2.6.24.  There is a whitespace fix for an
error message, a fix to limit log pollution with ieee80211, and a couple
of fixes form Johannes related to handling multicast addresses in
mac80211.

Let me know if there are problems!

Thanks,

John
---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit d9f8bcbf67a0ee67c8cb0734f003dfe916bb5248:
  Linus Torvalds (1):
        Linux 2.6.24-rc3

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Bruno Randolf (1):
      mac80211: add missing space in error message

Guillaume Chazarain (1):
      ieee80211: Stop net_ratelimit/IEEE80211_DEBUG_DROP log pollution

Johannes Berg (2):
      mac80211: fix ieee80211_set_multicast_list
      mac80211: fix allmulti/promisc behaviour

 include/net/ieee80211.h              |    8 ++++++++
 net/ieee80211/ieee80211_crypt_ccmp.c |    2 +-
 net/ieee80211/ieee80211_crypt_tkip.c |    4 ++--
 net/mac80211/ieee80211.c             |   27 +++++++++++++++++++++++++--
 net/mac80211/ieee80211_sta.c         |    2 +-
 5 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 164d132..d8ae484 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -115,8 +115,16 @@ extern u32 ieee80211_debug_level;
 do { if (ieee80211_debug_level & (level)) \
   printk(KERN_DEBUG "ieee80211: %c %s " fmt, \
          in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+static inline bool ieee80211_ratelimit_debug(u32 level)
+{
+	return (ieee80211_debug_level & level) && net_ratelimit();
+}
 #else
 #define IEEE80211_DEBUG(level, fmt, args...) do {} while (0)
+static inline bool ieee80211_ratelimit_debug(u32 level)
+{
+	return false;
+}
 #endif				/* CONFIG_IEEE80211_DEBUG */
 
 /* escape_essid() is intended to be used in debug (and possibly error)
diff --git a/net/ieee80211/ieee80211_crypt_ccmp.c b/net/ieee80211/ieee80211_crypt_ccmp.c
index c6d760d..208bf35 100644
--- a/net/ieee80211/ieee80211_crypt_ccmp.c
+++ b/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -338,7 +338,7 @@ static int ieee80211_ccmp_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos += 8;
 
 	if (ccmp_replay_check(pn, key->rx_pn)) {
-		if (net_ratelimit()) {
+		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
 			IEEE80211_DEBUG_DROP("CCMP: replay detected: STA=%s "
 				 "previous PN %02x%02x%02x%02x%02x%02x "
 				 "received PN %02x%02x%02x%02x%02x%02x\n",
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 58b2261..8e14694 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -464,7 +464,7 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 	pos += 8;
 
 	if (tkip_replay_check(iv32, iv16, tkey->rx_iv32, tkey->rx_iv16)) {
-		if (net_ratelimit()) {
+		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
 			IEEE80211_DEBUG_DROP("TKIP: replay detected: STA=%s"
 			       " previous TSC %08x%04x received TSC "
 			       "%08x%04x\n", print_mac(mac, hdr->addr2),
@@ -504,7 +504,7 @@ static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 			 * it needs to be recalculated for the next packet. */
 			tkey->rx_phase1_done = 0;
 		}
-		if (net_ratelimit()) {
+		if (ieee80211_ratelimit_debug(IEEE80211_DL_DROP)) {
 			IEEE80211_DEBUG_DROP("TKIP: ICV error detected: STA="
 			       "%s\n", print_mac(mac, hdr->addr2));
 		}
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index e0ee65a..59350b8 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -267,6 +267,17 @@ static int ieee80211_open(struct net_device *dev)
 		tasklet_enable(&local->tasklet);
 	}
 
+	/*
+	 * set_multicast_list will be invoked by the networking core
+	 * which will check whether any increments here were done in
+	 * error and sync them down to the hardware as filter flags.
+	 */
+	if (sdata->flags & IEEE80211_SDATA_ALLMULTI)
+		atomic_inc(&local->iff_allmultis);
+
+	if (sdata->flags & IEEE80211_SDATA_PROMISC)
+		atomic_inc(&local->iff_promiscs);
+
 	local->open_count++;
 
 	netif_start_queue(dev);
@@ -284,6 +295,18 @@ static int ieee80211_stop(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
+	/*
+	 * Don't count this interface for promisc/allmulti while it
+	 * is down. dev_mc_unsync() will invoke set_multicast_list
+	 * on the master interface which will sync these down to the
+	 * hardware as filter flags.
+	 */
+	if (sdata->flags & IEEE80211_SDATA_ALLMULTI)
+		atomic_dec(&local->iff_allmultis);
+
+	if (sdata->flags & IEEE80211_SDATA_PROMISC)
+		atomic_dec(&local->iff_promiscs);
+
 	dev_mc_unsync(local->mdev, dev);
 
 	/* down all dependent devices, that is VLANs */
@@ -366,8 +389,8 @@ static void ieee80211_set_multicast_list(struct net_device *dev)
 
 	allmulti = !!(dev->flags & IFF_ALLMULTI);
 	promisc = !!(dev->flags & IFF_PROMISC);
-	sdata_allmulti = sdata->flags & IEEE80211_SDATA_ALLMULTI;
-	sdata_promisc = sdata->flags & IEEE80211_SDATA_PROMISC;
+	sdata_allmulti = !!(sdata->flags & IEEE80211_SDATA_ALLMULTI);
+	sdata_promisc = !!(sdata->flags & IEEE80211_SDATA_PROMISC);
 
 	if (allmulti != sdata_allmulti) {
 		if (dev->flags & IFF_ALLMULTI)
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 015b3f8..16afd24 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2647,7 +2647,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 	local->sta_scanning = 0;
 
 	if (ieee80211_hw_config(local))
-		printk(KERN_DEBUG "%s: failed to restore operational"
+		printk(KERN_DEBUG "%s: failed to restore operational "
 		       "channel after scan\n", dev->name);
 
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
