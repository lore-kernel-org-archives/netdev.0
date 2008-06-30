From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-06-30
Date: Mon, 30 Jun 2008 16:11:47 -0400
Message-ID: <20080630201147.GB878@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another quick round of some (relatively minor) fixes hoping
to see 2.6.26.  Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d420895efb259a78dda50f95289571faa6e10e41:
  YOSHIFUJI Hideaki (1):
        ipv6 route: Convert rt6_device_match() to use RT6_LOOKUP_F_xxx flags.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Emmanuel Grumbach (1):
      mac80211: don't accept WEP keys other than WEP40 and WEP104

Pavel Roskin (2):
      hostap: don't report useless WDS frames by default
      hostap: fix sparse warnings

 drivers/net/wireless/hostap/hostap_80211_rx.c |    8 ++++----
 drivers/net/wireless/hostap/hostap_ap.c       |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c       |    8 ++++----
 drivers/net/wireless/hostap/hostap_hw.c       |   10 +++++-----
 drivers/net/wireless/hostap/hostap_main.c     |    5 ++---
 include/net/mac80211.h                        |    9 +++++++++
 net/mac80211/wext.c                           |    7 +++++++
 7 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 4fd7380..020f450 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -64,7 +64,7 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 	int hdrlen, phdrlen, head_need, tail_need;
 	u16 fc;
 	int prism_header, ret;
-	struct ieee80211_hdr_4addr *hdr;
+	struct ieee80211_hdr_4addr *fhdr;
 
 	iface = netdev_priv(dev);
 	local = iface->local;
@@ -83,8 +83,8 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 		phdrlen = 0;
 	}
 
-	hdr = (struct ieee80211_hdr_4addr *) skb->data;
-	fc = le16_to_cpu(hdr->frame_ctl);
+	fhdr = (struct ieee80211_hdr_4addr *) skb->data;
+	fc = le16_to_cpu(fhdr->frame_ctl);
 
 	if (type == PRISM2_RX_MGMT && (fc & IEEE80211_FCTL_VERS)) {
 		printk(KERN_DEBUG "%s: dropped management frame with header "
@@ -551,7 +551,7 @@ hostap_rx_frame_wds(local_info_t *local, struct ieee80211_hdr_4addr *hdr,
 	     hdr->addr1[2] != 0xff || hdr->addr1[3] != 0xff ||
 	     hdr->addr1[4] != 0xff || hdr->addr1[5] != 0xff)) {
 		/* RA (or BSSID) is not ours - drop */
-		PDEBUG(DEBUG_EXTRA, "%s: received WDS frame with "
+		PDEBUG(DEBUG_EXTRA2, "%s: received WDS frame with "
 		       "not own or broadcast %s=%s\n",
 		       local->dev->name,
 		       fc & IEEE80211_FCTL_FROMDS ? "RA" : "BSSID",
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 0acd958..ab981af 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -1930,7 +1930,7 @@ static void handle_pspoll(local_info_t *local,
 		PDEBUG(DEBUG_PS, "   PSPOLL and AID[15:14] not set\n");
 		return;
 	}
-	aid &= ~BIT(15) & ~BIT(14);
+	aid &= ~(BIT(15) | BIT(14));
 	if (aid == 0 || aid > MAX_AID_TABLE_SIZE) {
 		PDEBUG(DEBUG_PS, "   invalid aid=%d\n", aid);
 		return;
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index ed4317a..80039a0 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -533,10 +533,10 @@ static void prism2_detach(struct pcmcia_device *link)
 do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)
 
 #define CFG_CHECK2(fn, retf) \
-do { int ret = (retf); \
-if (ret != 0) { \
-	PDEBUG(DEBUG_EXTRA, "CardServices(" #fn ") returned %d\n", ret); \
-	cs_error(link, fn, ret); \
+do { int _ret = (retf); \
+if (_ret != 0) { \
+	PDEBUG(DEBUG_EXTRA, "CardServices(" #fn ") returned %d\n", _ret); \
+	cs_error(link, fn, _ret); \
 	goto next_entry; \
 } \
 } while (0)
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index cdf90c4..936f52e 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -2835,7 +2835,7 @@ static void hostap_passive_scan(unsigned long data)
 {
 	local_info_t *local = (local_info_t *) data;
 	struct net_device *dev = local->dev;
-	u16 channel;
+	u16 chan;
 
 	if (local->passive_scan_interval <= 0)
 		return;
@@ -2872,11 +2872,11 @@ static void hostap_passive_scan(unsigned long data)
 
 		printk(KERN_DEBUG "%s: passive scan channel %d\n",
 		       dev->name, local->passive_scan_channel);
-		channel = local->passive_scan_channel;
+		chan = local->passive_scan_channel;
 		local->passive_scan_state = PASSIVE_SCAN_WAIT;
 		local->passive_scan_timer.expires = jiffies + HZ / 10;
 	} else {
-		channel = local->channel;
+		chan = local->channel;
 		local->passive_scan_state = PASSIVE_SCAN_LISTEN;
 		local->passive_scan_timer.expires = jiffies +
 			local->passive_scan_interval * HZ;
@@ -2884,9 +2884,9 @@ static void hostap_passive_scan(unsigned long data)
 
 	if (hfa384x_cmd_callback(dev, HFA384X_CMDCODE_TEST |
 				 (HFA384X_TEST_CHANGE_CHANNEL << 8),
-				 channel, NULL, 0))
+				 chan, NULL, 0))
 		printk(KERN_ERR "%s: passive scan channel set %d "
-		       "failed\n", dev->name, channel);
+		       "failed\n", dev->name, chan);
 
 	add_timer(&local->passive_scan_timer);
 }
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index f7aec93..a38e85f 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -594,7 +594,8 @@ void hostap_dump_tx_header(const char *name, const struct hfa384x_tx_frame *tx)
 }
 
 
-int hostap_80211_header_parse(const struct sk_buff *skb, unsigned char *haddr)
+static int hostap_80211_header_parse(const struct sk_buff *skb,
+				     unsigned char *haddr)
 {
 	struct hostap_interface *iface = netdev_priv(skb->dev);
 	local_info_t *local = iface->local;
@@ -857,7 +858,6 @@ const struct header_ops hostap_80211_ops = {
 	.rebuild	= eth_rebuild_header,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
-
 	.parse		= hostap_80211_header_parse,
 };
 EXPORT_SYMBOL(hostap_80211_ops);
@@ -1150,7 +1150,6 @@ EXPORT_SYMBOL(hostap_set_roaming);
 EXPORT_SYMBOL(hostap_set_auth_algs);
 EXPORT_SYMBOL(hostap_dump_rx_header);
 EXPORT_SYMBOL(hostap_dump_tx_header);
-EXPORT_SYMBOL(hostap_80211_header_parse);
 EXPORT_SYMBOL(hostap_80211_get_hdrlen);
 EXPORT_SYMBOL(hostap_get_stats);
 EXPORT_SYMBOL(hostap_setup_dev);
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index dae3f9e..bcd1623 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -595,6 +595,15 @@ enum ieee80211_key_alg {
 	ALG_CCMP,
 };
 
+/**
+ * enum ieee80211_key_len - key length
+ * @WEP40: WEP 5 byte long key
+ * @WEP104: WEP 13 byte long key
+ */
+enum ieee80211_key_len {
+	LEN_WEP40 = 5,
+	LEN_WEP104 = 13,
+};
 
 /**
  * enum ieee80211_key_flags - key flags
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 6106cb7..e840421 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -95,6 +95,13 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 			}
 		}
 
+		if (alg == ALG_WEP &&
+			key_len != LEN_WEP40 && key_len != LEN_WEP104) {
+			ieee80211_key_free(key);
+			err = -EINVAL;
+			goto out_unlock;
+		}
+
 		ieee80211_key_link(key, sdata, sta);
 
 		if (set_tx_key || (!sta && !sdata->default_key && key))
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
