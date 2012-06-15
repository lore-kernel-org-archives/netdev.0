From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 07/20] hostap: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:47 -0700
Message-ID: <64828fcc3f9037a726e8781f20f295a28164df65.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.
Neaten debug logging macros.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/hostap/hostap_80211_rx.c |  125 ++++----
 drivers/net/wireless/hostap/hostap_80211_tx.c |   78 ++---
 drivers/net/wireless/hostap/hostap_ap.c       |   77 ++---
 drivers/net/wireless/hostap/hostap_cs.c       |   53 ++--
 drivers/net/wireless/hostap/hostap_download.c |  143 ++++-----
 drivers/net/wireless/hostap/hostap_hw.c       |  438 +++++++++++--------------
 drivers/net/wireless/hostap/hostap_info.c     |   36 +-
 drivers/net/wireless/hostap/hostap_ioctl.c    |  175 +++++------
 drivers/net/wireless/hostap/hostap_main.c     |  142 ++++-----
 drivers/net/wireless/hostap/hostap_pci.c      |   26 +-
 drivers/net/wireless/hostap/hostap_plx.c      |   69 ++---
 drivers/net/wireless/hostap/hostap_proc.c     |   18 +-
 drivers/net/wireless/hostap/hostap_wlan.h     |   16 +-
 13 files changed, 629 insertions(+), 767 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index df7050a..da1149c 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/etherdevice.h>
 #include <linux/slab.h>
 #include <linux/export.h>
@@ -25,35 +27,34 @@ void hostap_dump_rx_80211(const char *name, struct sk_buff *skb,
 
 	hdr = (struct ieee80211_hdr *) skb->data;
 
-	printk(KERN_DEBUG "%s: RX signal=%d noise=%d rate=%d len=%d "
-	       "jiffies=%ld\n",
-	       name, rx_stats->signal, rx_stats->noise, rx_stats->rate,
-	       skb->len, jiffies);
+	pr_debug("%s: RX signal=%d noise=%d rate=%d len=%d jiffies=%ld\n",
+		 name, rx_stats->signal, rx_stats->noise, rx_stats->rate,
+		 skb->len, jiffies);
 
 	if (skb->len < 2)
 		return;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	printk(KERN_DEBUG "   FC=0x%04x (type=%d:%d)%s%s",
-	       fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
-	       (fc & IEEE80211_FCTL_STYPE) >> 4,
-	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
-	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
+	pr_debug("   FC=0x%04x (type=%d:%d)%s%s",
+		 fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
+		 (fc & IEEE80211_FCTL_STYPE) >> 4,
+		 fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
+		 fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
 
 	if (skb->len < IEEE80211_DATA_HDR3_LEN) {
-		printk("\n");
+		pr_cont("\n");
 		return;
 	}
 
-	printk(" dur=0x%04x seq=0x%04x\n", le16_to_cpu(hdr->duration_id),
-	       le16_to_cpu(hdr->seq_ctrl));
+	pr_cont(" dur=0x%04x seq=0x%04x\n",
+		le16_to_cpu(hdr->duration_id), le16_to_cpu(hdr->seq_ctrl));
 
-	printk(KERN_DEBUG "   A1=%pM", hdr->addr1);
-	printk(" A2=%pM", hdr->addr2);
-	printk(" A3=%pM", hdr->addr3);
+	pr_debug("   A1=%pM", hdr->addr1);
+	pr_cont(" A2=%pM", hdr->addr2);
+	pr_cont(" A3=%pM", hdr->addr3);
 	if (skb->len >= 30)
-		printk(" A4=%pM", hdr->addr4);
-	printk("\n");
+		pr_cont(" A4=%pM", hdr->addr4);
+	pr_cont("\n");
 }
 
 
@@ -92,8 +93,8 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 	fc = le16_to_cpu(fhdr->frame_control);
 
 	if (type == PRISM2_RX_MGMT && (fc & IEEE80211_FCTL_VERS)) {
-		printk(KERN_DEBUG "%s: dropped management frame with header "
-		       "version %d\n", dev->name, fc & IEEE80211_FCTL_VERS);
+		pr_debug("%s: dropped management frame with header version %d\n",
+			 dev->name, fc & IEEE80211_FCTL_VERS);
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
@@ -115,8 +116,8 @@ int prism2_rx_80211(struct net_device *dev, struct sk_buff *skb,
 		if (pskb_expand_head(skb, head_need > 0 ? head_need : 0,
 				     tail_need > 0 ? tail_need : 0,
 				     GFP_ATOMIC)) {
-			printk(KERN_DEBUG "%s: prism2_rx_80211 failed to "
-			       "reallocate skb buffer\n", dev->name);
+			pr_debug("%s: prism2_rx_80211 failed to reallocate skb buffer\n",
+				 dev->name);
 			dev_kfree_skb_any(skb);
 			return 0;
 		}
@@ -229,9 +230,9 @@ prism2_frag_cache_find(local_info_t *local, unsigned int seq,
 		entry = &local->frag_cache[i];
 		if (entry->skb != NULL &&
 		    time_after(jiffies, entry->first_frag_time + 2 * HZ)) {
-			printk(KERN_DEBUG "%s: expiring fragment cache entry "
-			       "seq=%u last_frag=%u\n",
-			       local->dev->name, entry->seq, entry->last_frag);
+			pr_debug("%s: expiring fragment cache entry seq=%u last_frag=%u\n",
+				 local->dev->name, entry->seq,
+				 entry->last_frag);
 			dev_kfree_skb(entry->skb);
 			entry->skb = NULL;
 		}
@@ -313,9 +314,8 @@ static int prism2_frag_cache_invalidate(local_info_t *local,
 	entry = prism2_frag_cache_find(local, seq, -1, hdr->addr2, hdr->addr1);
 
 	if (entry == NULL) {
-		printk(KERN_DEBUG "%s: could not invalidate fragment cache "
-		       "entry (seq=%u)\n",
-		       local->dev->name, seq);
+		pr_debug("%s: could not invalidate fragment cache entry (seq=%u)\n",
+			 local->dev->name, seq);
 		return -1;
 	}
 
@@ -500,9 +500,8 @@ hostap_rx_frame_mgmt(local_info_t *local, struct sk_buff *skb,
 	if (local->iw_mode == IW_MODE_MASTER) {
 		if (type != IEEE80211_FTYPE_MGMT &&
 		    type != IEEE80211_FTYPE_CTL) {
-			printk(KERN_DEBUG "%s: unknown management frame "
-			       "(type=0x%02x, stype=0x%02x) dropped\n",
-			       skb->dev->name, type >> 2, stype >> 4);
+			pr_debug("%s: unknown management frame (type=0x%02x, stype=0x%02x) dropped\n",
+				 skb->dev->name, type >> 2, stype >> 4);
 			return -1;
 		}
 
@@ -521,9 +520,8 @@ hostap_rx_frame_mgmt(local_info_t *local, struct sk_buff *skb,
 		 */
 		return -1;
 	} else {
-		printk(KERN_DEBUG "%s: hostap_rx_frame_mgmt: dropped unhandled"
-		       " management frame in non-Host AP mode (type=%d:%d)\n",
-		       skb->dev->name, type >> 2, stype >> 4);
+		pr_debug("%s: hostap_rx_frame_mgmt: dropped unhandled management frame in non-Host AP mode (type=%d:%d)\n",
+			 skb->dev->name, type >> 2, stype >> 4);
 		return -1;
 	}
 }
@@ -662,9 +660,8 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 	if (local->tkip_countermeasures &&
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "received packet from %pM\n",
-			       local->dev->name, hdr->addr2);
+			pr_debug("%s: TKIP countermeasures: dropped received packet from %pM\n",
+				 local->dev->name, hdr->addr2);
 		}
 		return -1;
 	}
@@ -673,8 +670,8 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 	res = crypt->ops->decrypt_mpdu(skb, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: decryption failed (SA=%pM) res=%d\n",
-		       local->dev->name, hdr->addr2, res);
+		pr_debug("%s: decryption failed (SA=%pM) res=%d\n",
+			 local->dev->name, hdr->addr2, res);
 		local->comm_tallies.rx_discards_wep_undecryptable++;
 		return -1;
 	}
@@ -701,9 +698,8 @@ hostap_rx_frame_decrypt_msdu(local_info_t *local, struct sk_buff *skb,
 	res = crypt->ops->decrypt_msdu(skb, keyidx, hdrlen, crypt->priv);
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
-		       " (SA=%pM keyidx=%d)\n",
-		       local->dev->name, hdr->addr2, keyidx);
+		pr_debug("%s: MSDU decryption/MIC verification failed (SA=%pM keyidx=%d)\n",
+			 local->dev->name, hdr->addr2, keyidx);
 		return -1;
 	}
 
@@ -808,9 +804,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			 * frames from other than current BSS, so just drop the
 			 * frames silently instead of filling system log with
 			 * these reports. */
-			printk(KERN_DEBUG "%s: WEP decryption failed (not set)"
-			       " (SA=%pM)\n",
-			       local->dev->name, hdr->addr2);
+			pr_debug("%s: WEP decryption failed (not set) (SA=%pM)\n",
+				 local->dev->name, hdr->addr2);
 #endif
 			local->comm_tallies.rx_discards_wep_undecryptable++;
 			goto rx_dropped;
@@ -823,8 +818,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		    fc & IEEE80211_FCTL_PROTECTED && local->host_decrypt &&
 		    (keyidx = hostap_rx_frame_decrypt(local, skb, crypt)) < 0)
 		{
-			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
-			       "from %pM\n", dev->name, hdr->addr2);
+			pr_debug("%s: failed to decrypt mgmt::auth from %pM\n",
+				 dev->name, hdr->addr2);
 			/* TODO: could inform hostapd about this so that it
 			 * could send auth failure report */
 			goto rx_dropped;
@@ -901,9 +896,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	    stype != IEEE80211_STYPE_DATA_CFPOLL &&
 	    stype != IEEE80211_STYPE_DATA_CFACKPOLL) {
 		if (stype != IEEE80211_STYPE_NULLFUNC)
-			printk(KERN_DEBUG "%s: RX: dropped data frame "
-			       "with no data (type=0x%02x, subtype=0x%02x)\n",
-			       dev->name, type >> 2, stype >> 4);
+			pr_debug("%s: RX: dropped data frame with no data (type=0x%02x, subtype=0x%02x)\n",
+				 dev->name, type >> 2, stype >> 4);
 		goto rx_dropped;
 	}
 
@@ -922,10 +916,10 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 		struct sk_buff *frag_skb =
 			prism2_frag_cache_get(local, hdr);
 		if (!frag_skb) {
-			printk(KERN_DEBUG "%s: Rx cannot get skb from "
-			       "fragment cache (morefrag=%d seq=%u frag=%u)\n",
-			       dev->name, (fc & IEEE80211_FCTL_MOREFRAGS) != 0,
-			       (sc & IEEE80211_SCTL_SEQ) >> 4, frag);
+			pr_debug("%s: Rx cannot get skb from fragment cache (morefrag=%d seq=%u frag=%u)\n",
+				 dev->name,
+				 (fc & IEEE80211_FCTL_MOREFRAGS) != 0,
+				 (sc & IEEE80211_SCTL_SEQ) >> 4, frag);
 			goto rx_dropped;
 		}
 
@@ -934,9 +928,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			flen -= hdrlen;
 
 		if (frag_skb->tail + flen > frag_skb->end) {
-			printk(KERN_WARNING "%s: host decrypted and "
-			       "reassembled frame did not fit skb\n",
-			       dev->name);
+			pr_warn("%s: host decrypted and reassembled frame did not fit skb\n",
+				dev->name);
 			prism2_frag_cache_invalidate(local, hdr);
 			goto rx_dropped;
 		}
@@ -986,9 +979,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			PDEBUG(DEBUG_EXTRA2, "%s: RX: IEEE 802.1X - passing "
 			       "unencrypted EAPOL frame\n", local->dev->name);
 		} else {
-			printk(KERN_DEBUG "%s: encryption configured, but RX "
-			       "frame not encrypted (SA=%pM)\n",
-			       local->dev->name, hdr->addr2);
+			pr_debug("%s: encryption configured, but RX frame not encrypted (SA=%pM)\n",
+				 local->dev->name, hdr->addr2);
 			goto rx_dropped;
 		}
 	}
@@ -996,9 +988,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	if (local->drop_unencrypted && !(fc & IEEE80211_FCTL_PROTECTED) &&
 	    !hostap_is_eapol_frame(local, skb)) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: dropped unencrypted RX data "
-			       "frame from %pM (drop_unencrypted=1)\n",
-			       dev->name, hdr->addr2);
+			pr_debug("%s: dropped unencrypted RX data frame from %pM (drop_unencrypted=1)\n",
+				 dev->name, hdr->addr2);
 		}
 		goto rx_dropped;
 	}
@@ -1024,10 +1015,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 				goto rx_exit;
 			}
 		} else if (!frame_authorized) {
-			printk(KERN_DEBUG "%s: dropped frame from "
-			       "unauthorized port (IEEE 802.1X): "
-			       "ethertype=0x%04x\n",
-			       dev->name, ethertype);
+			pr_debug("%s: dropped frame from unauthorized port (IEEE 802.1X): ethertype=0x%04x\n",
+				 dev->name, ethertype);
 			goto rx_dropped;
 		}
 	}
@@ -1074,8 +1063,8 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 			local->ap->bridged_multicast++;
 			skb2 = skb_clone(skb, GFP_ATOMIC);
 			if (skb2 == NULL)
-				printk(KERN_DEBUG "%s: skb_clone failed for "
-				       "multicast frame\n", dev->name);
+				pr_debug("%s: skb_clone failed for multicast frame\n",
+					 dev->name);
 		} else if (hostap_is_sta_authorized(local->ap, dst)) {
 			/* send frame directly to the associated STA using
 			 * wireless media and not passing to higher layers */
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 344a981..141a9bd 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/export.h>
 
@@ -23,33 +25,32 @@ void hostap_dump_tx_80211(const char *name, struct sk_buff *skb)
 
 	hdr = (struct ieee80211_hdr *) skb->data;
 
-	printk(KERN_DEBUG "%s: TX len=%d jiffies=%ld\n",
-	       name, skb->len, jiffies);
+	pr_debug("%s: TX len=%d jiffies=%ld\n", name, skb->len, jiffies);
 
 	if (skb->len < 2)
 		return;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	printk(KERN_DEBUG "   FC=0x%04x (type=%d:%d)%s%s",
-	       fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
-	       (fc & IEEE80211_FCTL_STYPE) >> 4,
-	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
-	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
+	pr_debug("   FC=0x%04x (type=%d:%d)%s%s",
+		 fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
+		 (fc & IEEE80211_FCTL_STYPE) >> 4,
+		 fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
+		 fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
 
 	if (skb->len < IEEE80211_DATA_HDR3_LEN) {
-		printk("\n");
+		pr_cont("\n");
 		return;
 	}
 
-	printk(" dur=0x%04x seq=0x%04x\n", le16_to_cpu(hdr->duration_id),
-	       le16_to_cpu(hdr->seq_ctrl));
+	pr_cont(" dur=0x%04x seq=0x%04x\n",
+	       le16_to_cpu(hdr->duration_id), le16_to_cpu(hdr->seq_ctrl));
 
-	printk(KERN_DEBUG "   A1=%pM", hdr->addr1);
-	printk(" A2=%pM", hdr->addr2);
-	printk(" A3=%pM", hdr->addr3);
+	pr_debug("   A1=%pM", hdr->addr1);
+	pr_cont(" A2=%pM", hdr->addr2);
+	pr_cont(" A3=%pM", hdr->addr3);
 	if (skb->len >= 30)
-		printk(" A4=%pM", hdr->addr4);
-	printk("\n");
+		pr_cont(" A4=%pM", hdr->addr4);
+	pr_cont("\n");
 }
 
 
@@ -76,8 +77,8 @@ netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
 	local = iface->local;
 
 	if (skb->len < ETH_HLEN) {
-		printk(KERN_DEBUG "%s: hostap_data_start_xmit: short skb "
-		       "(len=%d)\n", dev->name, skb->len);
+		pr_debug("%s: hostap_data_start_xmit: short skb (len=%d)\n",
+			 dev->name, skb->len);
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -90,15 +91,15 @@ netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
 			to_assoc_ap = 1;
 			use_wds = WDS_NO;
 		} else if (dev == local->apdev) {
-			printk(KERN_DEBUG "%s: prism2_tx: trying to use "
-			       "AP device with Ethernet net dev\n", dev->name);
+			pr_debug("%s: prism2_tx: trying to use AP device with Ethernet net dev\n",
+				 dev->name);
 			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
 	} else {
 		if (local->iw_mode == IW_MODE_REPEAT) {
-			printk(KERN_DEBUG "%s: prism2_tx: trying to use "
-			       "non-WDS link in Repeater mode\n", dev->name);
+			pr_debug("%s: prism2_tx: trying to use non-WDS link in Repeater mode\n",
+				 dev->name);
 			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		} else if (local->iw_mode == IW_MODE_INFRA &&
@@ -278,8 +279,8 @@ netdev_tx_t hostap_mgmt_start_xmit(struct sk_buff *skb,
 	local = iface->local;
 
 	if (skb->len < 10) {
-		printk(KERN_DEBUG "%s: hostap_mgmt_start_xmit: short skb "
-		       "(len=%d)\n", dev->name, skb->len);
+		pr_debug("%s: hostap_mgmt_start_xmit: short skb (len=%d)\n",
+			 dev->name, skb->len);
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -331,9 +332,8 @@ static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
 		hdr = (struct ieee80211_hdr *) skb->data;
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "TX packet to %pM\n",
-			       local->dev->name, hdr->addr1);
+			pr_debug("%s: TKIP countermeasures: dropped TX packet to %pM\n",
+				 local->dev->name, hdr->addr1);
 		}
 		kfree_skb(skb);
 		return NULL;
@@ -399,9 +399,8 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 
 	meta = (struct hostap_skb_tx_data *) skb->cb;
 	if (meta->magic != HOSTAP_SKB_TX_DATA_MAGIC) {
-		printk(KERN_DEBUG "%s: invalid skb->cb magic (0x%08x, "
-		       "expected 0x%08x)\n",
-		       dev->name, meta->magic, HOSTAP_SKB_TX_DATA_MAGIC);
+		pr_debug("%s: invalid skb->cb magic (0x%08x, expected 0x%08x)\n",
+			 dev->name, meta->magic, HOSTAP_SKB_TX_DATA_MAGIC);
 		ret = NETDEV_TX_OK;
 		iface->stats.tx_dropped++;
 		goto fail;
@@ -418,8 +417,8 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 	}
 
 	if (skb->len < 24) {
-		printk(KERN_DEBUG "%s: hostap_master_start_xmit: short skb "
-		       "(len=%d)\n", dev->name, skb->len);
+		pr_debug("%s: hostap_master_start_xmit: short skb (len=%d)\n",
+			 dev->name, skb->len);
 		ret = NETDEV_TX_OK;
 		iface->stats.tx_dropped++;
 		goto fail;
@@ -442,9 +441,8 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 		    ieee80211_is_data(hdr->frame_control) &&
 		    meta->ethertype != ETH_P_PAE &&
 		    !(meta->flags & HOSTAP_TX_FLAGS_WDS)) {
-			printk(KERN_DEBUG "%s: dropped frame to unauthorized "
-			       "port (IEEE 802.1X): ethertype=0x%04x\n",
-			       dev->name, meta->ethertype);
+			pr_debug("%s: dropped frame to unauthorized port (IEEE 802.1X): ethertype=0x%04x\n",
+				 dev->name, meta->ethertype);
 			hostap_dump_tx_80211(dev->name, skb);
 
 			ret = NETDEV_TX_OK; /* drop packet */
@@ -503,8 +501,8 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 		   ieee80211_is_data(hdr->frame_control) &&
 		   meta->ethertype != ETH_P_PAE) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: dropped unencrypted TX data "
-			       "frame (drop_unencrypted=1)\n", dev->name);
+			pr_debug("%s: dropped unencrypted TX data frame (drop_unencrypted=1)\n",
+				 dev->name);
 		}
 		iface->stats.tx_dropped++;
 		ret = NETDEV_TX_OK;
@@ -514,16 +512,14 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 	if (tx.crypt) {
 		skb = hostap_tx_encrypt(skb, tx.crypt);
 		if (skb == NULL) {
-			printk(KERN_DEBUG "%s: TX - encryption failed\n",
-			       dev->name);
+			pr_debug("%s: TX - encryption failed\n", dev->name);
 			ret = NETDEV_TX_OK;
 			goto fail;
 		}
 		meta = (struct hostap_skb_tx_data *) skb->cb;
 		if (meta->magic != HOSTAP_SKB_TX_DATA_MAGIC) {
-			printk(KERN_DEBUG "%s: invalid skb->cb magic (0x%08x, "
-			       "expected 0x%08x) after hostap_tx_encrypt\n",
-			       dev->name, meta->magic,
+			pr_debug("%s: invalid skb->cb magic (0x%08x, expected 0x%08x) after hostap_tx_encrypt\n",
+				 dev->name, meta->magic,
 			       HOSTAP_SKB_TX_DATA_MAGIC);
 			ret = NETDEV_TX_OK;
 			iface->stats.tx_dropped++;
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index e1f4102..82b2724 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -16,6 +16,8 @@
  *   (8802.11: 5.5)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/proc_fs.h>
 #include <linux/delay.h>
 #include <linux/random.h>
@@ -550,7 +552,7 @@ static int prism2_ap_proc_read(char *page, char **start, off_t off,
 		p += sprintf(p, "\n");
 
 		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "hostap: ap proc did not fit\n");
+			pr_debug("ap proc did not fit\n");
 			break;
 		}
 	}
@@ -581,9 +583,8 @@ void hostap_check_sta_fw_version(struct ap_data *ap, int sta_fw_ver)
 		ap->nullfunc_ack = 0;
 
 	if (sta_fw_ver == PRISM2_FW_VER(1,4,2)) {
-		printk(KERN_WARNING "%s: Warning: secondary station firmware "
-		       "version 1.4.2 does not seem to work in Host AP mode\n",
-		       ap->local->dev->name);
+		pr_warn("%s: Warning: secondary station firmware version 1.4.2 does not seem to work in Host AP mode\n",
+			ap->local->dev->name);
 	}
 }
 
@@ -635,8 +636,8 @@ static void hostap_ap_tx_cb_auth(struct sk_buff *skb, int ok, void *data)
 	hdr = (struct ieee80211_hdr *) skb->data;
 	if (!ieee80211_is_auth(hdr->frame_control) ||
 	    skb->len < IEEE80211_MGMT_HDR_LEN + 6) {
-		printk(KERN_DEBUG "%s: hostap_ap_tx_cb_auth received invalid "
-		       "frame\n", dev->name);
+		pr_debug("%s: hostap_ap_tx_cb_auth received invalid frame\n",
+			 dev->name);
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -704,8 +705,8 @@ static void hostap_ap_tx_cb_assoc(struct sk_buff *skb, int ok, void *data)
 	if ((!ieee80211_is_assoc_resp(hdr->frame_control) &&
 	     !ieee80211_is_reassoc_resp(hdr->frame_control)) ||
 	    skb->len < IEEE80211_MGMT_HDR_LEN + 4) {
-		printk(KERN_DEBUG "%s: hostap_ap_tx_cb_assoc received invalid "
-		       "frame\n", dev->name);
+		pr_debug("%s: hostap_ap_tx_cb_assoc received invalid frame\n",
+			 dev->name);
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -782,7 +783,7 @@ void hostap_init_data(local_info_t *local)
 	struct ap_data *ap = local->ap;
 
 	if (ap == NULL) {
-		printk(KERN_WARNING "hostap_init_data: ap == NULL\n");
+		pr_warn("%s: ap == NULL\n", __func__);
 		return;
 	}
 	memset(ap, 0, sizeof(struct ap_data));
@@ -803,8 +804,8 @@ void hostap_init_data(local_info_t *local)
 	ap->tx_callback_idx =
 		hostap_tx_callback_register(local, hostap_ap_tx_cb, ap);
 	if (ap->tx_callback_idx == 0)
-		printk(KERN_WARNING "%s: failed to register TX callback for "
-		       "AP\n", local->dev->name);
+		pr_warn("%s: failed to register TX callback for AP\n",
+			local->dev->name);
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 	INIT_WORK(&local->ap->wds_oper_queue, handle_wds_oper_queue);
 
@@ -816,8 +817,8 @@ void hostap_init_data(local_info_t *local)
 		hostap_tx_callback_register(local, hostap_ap_tx_cb_poll, ap);
 	if (ap->tx_callback_auth == 0 || ap->tx_callback_assoc == 0 ||
 		ap->tx_callback_poll == 0)
-		printk(KERN_WARNING "%s: failed to register TX callback for "
-		       "AP\n", local->dev->name);
+		pr_warn("%s: failed to register TX callback for AP\n",
+			local->dev->name);
 
 	spin_lock_init(&ap->mac_restrictions.lock);
 	INIT_LIST_HEAD(&ap->mac_restrictions.mac_list);
@@ -855,8 +856,8 @@ void hostap_free_data(struct ap_data *ap)
 	struct sta_info *n, *sta;
 
 	if (ap == NULL || !ap->initialized) {
-		printk(KERN_DEBUG "hostap_free_data: ap has not yet been "
-		       "initialized - skip resource freeing\n");
+		pr_debug("%s: ap has not yet been initialized - skip resource freeing\n",
+			__func__);
 		return;
 	}
 
@@ -1123,7 +1124,7 @@ static struct sta_info * ap_add_sta(struct ap_data *ap, u8 *addr)
 			ap->add_sta_proc_entries = entry;
 			schedule_work(&ap->add_sta_proc_queue);
 		} else
-			printk(KERN_DEBUG "Failed to add STA proc data\n");
+			pr_debug("Failed to add STA proc data\n");
 	}
 
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
@@ -1222,8 +1223,7 @@ static void ap_crypt_init(struct ap_data *ap)
 	}
 
 	if (ap->crypt == NULL) {
-		printk(KERN_WARNING "AP could not initialize WEP: load module "
-		       "lib80211_crypt_wep.ko\n");
+		pr_warn("AP could not initialize WEP: load module lib80211_crypt_wep.ko\n");
 	}
 }
 
@@ -1795,7 +1795,7 @@ static void ap_handle_data_nullfunc(local_info_t *local,
 	 * not send this..
 	 * send control::ACK for the data::nullfunc */
 
-	printk(KERN_DEBUG "Sending control::ACK for data::nullfunc\n");
+	pr_debug("Sending control::ACK for data::nullfunc\n");
 	prism2_send_mgmt(dev, IEEE80211_FTYPE_CTL | IEEE80211_STYPE_ACK,
 			 NULL, 0, hdr->addr2, 0);
 }
@@ -1995,8 +1995,7 @@ static void handle_beacon(local_info_t *local, struct sk_buff *skb,
 	len = skb->len - IEEE80211_MGMT_HDR_LEN;
 
 	if (len < 8 + 2 + 2) {
-		printk(KERN_DEBUG "handle_beacon - too short payload "
-		       "(len=%d)\n", len);
+		pr_debug("handle_beacon - too short payload (len=%d)\n", len);
 		return;
 	}
 
@@ -2089,8 +2088,7 @@ static void handle_beacon(local_info_t *local, struct sk_buff *skb,
 		new_sta = 1;
 		sta = ap_add_sta(local->ap, hdr->addr2);
 		if (sta == NULL) {
-			printk(KERN_INFO "prism2: kmalloc failed for AP "
-			       "data structure\n");
+			pr_info("prism2: kmalloc failed for AP data structure\n");
 			return;
 		}
 		hostap_event_new_sta(local->dev, sta);
@@ -2296,8 +2294,8 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 
 	skb = dev_alloc_skb(16);
 	if (skb == NULL) {
-		printk(KERN_DEBUG "%s: schedule_packet_send: skb alloc "
-		       "failed\n", local->dev->name);
+		pr_debug("%s: %s: skb alloc failed\n",
+			 local->dev->name, __func__);
 		return;
 	}
 
@@ -2625,8 +2623,7 @@ int prism2_hostapd(struct ap_data *ap, struct prism2_hostapd_param *param)
 	case PRISM2_HOSTAPD_STA_CLEAR_STATS:
 		return prism2_hostapd_sta_clear_stats(ap, param);
 	default:
-		printk(KERN_WARNING "prism2_hostapd: unknown cmd=%d\n",
-		       param->cmd);
+		pr_warn("%s: unknown cmd=%d\n", __func__, param->cmd);
 		return -EOPNOTSUPP;
 	}
 }
@@ -2719,8 +2716,8 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 		 * ports of the bridge. Since this is a valid scenario, do not
 		 * print out any errors here. */
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "AP: drop packet to non-associated "
-			       "STA %pM\n", hdr->addr1);
+			pr_debug("drop packet to non-associated STA %pM\n",
+				 hdr->addr1);
 		}
 #endif
 		local->ap->tx_drop_nonassoc++;
@@ -2957,11 +2954,9 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 						PRISM2_RX_NON_ASSOC);
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 			} else {
-				printk(KERN_DEBUG "%s: dropped received packet"
-				       " from non-associated STA %pM"
-				       " (type=0x%02x, subtype=0x%02x)\n",
-				       dev->name, hdr->addr2,
-				       type >> 2, stype >> 4);
+				pr_debug("%s: dropped received packet from non-associated STA %pM (type=0x%02x, subtype=0x%02x)\n",
+					 dev->name, hdr->addr2,
+					 type >> 2, stype >> 4);
 				hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 			}
@@ -2973,8 +2968,7 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 			/* FromDS frame - not for us; probably
 			 * broadcast/multicast in another BSS - drop */
 			if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0) {
-				printk(KERN_DEBUG "Odd.. FromDS packet "
-				       "received with own BSSID\n");
+				pr_debug("Odd.. FromDS packet received with own BSSID\n");
 				hostap_dump_rx_80211(dev->name, skb, rx_stats);
 			}
 			ret = AP_RX_DROP;
@@ -2993,9 +2987,8 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 			 * after being unavailable for some time. Speed up
 			 * re-association by informing the station about it not
 			 * being associated. */
-			printk(KERN_DEBUG "%s: rejected received nullfunc frame"
-			       " without ToDS from not associated STA %pM\n",
-			       dev->name, hdr->addr2);
+			pr_debug("%s: rejected received nullfunc frame without ToDS from not associated STA %pM\n",
+				 dev->name, hdr->addr2);
 			hostap_rx(dev, skb, rx_stats);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 		}
@@ -3011,10 +3004,8 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 		 * broadcast frame from an IBSS network. Drop it silently.
 		 * If BSSID is own, report the dropping of this frame. */
 		if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
-			printk(KERN_DEBUG "%s: dropped received packet from %pM"
-			       " with no ToDS flag "
-			       "(type=0x%02x, subtype=0x%02x)\n", dev->name,
-			       hdr->addr2, type >> 2, stype >> 4);
+			pr_debug("%s: dropped received packet from %pM with no ToDS flag (type=0x%02x, subtype=0x%02x)\n",
+				 dev->name, hdr->addr2, type >> 2, stype >> 4);
 			hostap_dump_rx_80211(dev->name, skb, rx_stats);
 		}
 		ret = AP_RX_DROP;
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 89e9d3a..83e76ce 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -1,5 +1,7 @@
 #define PRISM2_PCCARD
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/if.h>
@@ -228,16 +230,16 @@ static void sandisk_set_iobase(local_info_t *local)
 	res = pcmcia_write_config_byte(hw_priv->link, 0x10,
 				hw_priv->link->resource[0]->start & 0x00ff);
 	if (res != 0) {
-		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 0 -"
-		       " res=%d\n", res);
+		pr_debug("Prism3 SanDisk - failed to set I/O base 0 - res=%d\n",
+			 res);
 	}
 	udelay(10);
 
 	res = pcmcia_write_config_byte(hw_priv->link, 0x12,
 				(hw_priv->link->resource[0]->start >> 8) & 0x00ff);
 	if (res != 0) {
-		printk(KERN_DEBUG "Prism3 SanDisk - failed to set I/O base 1 -"
-		       " res=%d\n", res);
+		pr_debug("Prism3 SanDisk - failed to set I/O base 1 - res=%d\n",
+			 res);
 	}
 }
 
@@ -282,15 +284,15 @@ static int sandisk_enable_wireless(struct net_device *dev)
 		goto done;
 	}
 
-	printk(KERN_DEBUG "%s: Multi-function SanDisk ConnectPlus detected"
-	       " - using vendor-specific initialization\n", dev->name);
+	pr_debug("%s: Multi-function SanDisk ConnectPlus detected - using vendor-specific initialization\n",
+		 dev->name);
 	hw_priv->sandisk_connectplus = 1;
 
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
 				COR_SOFT_RESET);
 	if (res != 0) {
-		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
-		       dev->name, res);
+		pr_debug("%s: SanDisk - COR sreset failed (%d)\n",
+			 dev->name, res);
 		goto done;
 	}
 	mdelay(5);
@@ -303,8 +305,8 @@ static int sandisk_enable_wireless(struct net_device *dev)
 				(COR_LEVEL_REQ | 0x8 | COR_ADDR_DECODE |
 					COR_FUNC_ENA));
 	if (res != 0) {
-		printk(KERN_DEBUG "%s: SanDisk - COR sreset failed (%d)\n",
-		       dev->name, res);
+		pr_debug("%s: SanDisk - COR sreset failed (%d)\n",
+			 dev->name, res);
 		goto done;
 	}
 	mdelay(5);
@@ -332,18 +334,15 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 
 	res = pcmcia_read_config_byte(hw_priv->link, CISREG_COR, &val);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 1 (%d)\n",
-		       res);
+		pr_debug("%s: failed 1 (%d)\n", __func__, res);
 		return;
 	}
-	printk(KERN_DEBUG "prism2_pccard_cor_sreset: original COR %02x\n",
-		val);
+	pr_debug("%s: original COR %02x\n", __func__, val);
 
 	val |= COR_SOFT_RESET;
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR, val);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 2 (%d)\n",
-		       res);
+		pr_debug("%s: failed 2 (%d)\n", __func__, res);
 		return;
 	}
 
@@ -354,8 +353,7 @@ static void prism2_pccard_cor_sreset(local_info_t *local)
 		val |= COR_IREQ_ENA;
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR, val);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_cor_sreset failed 3 (%d)\n",
-		       res);
+		pr_debug("%s: failed 3 (%d)\n", __func__, res);
 		return;
 	}
 
@@ -382,18 +380,15 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 
 	res = pcmcia_read_config_byte(hw_priv->link, CISREG_COR, &old_cor);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 1 "
-		       "(%d)\n", res);
+		pr_debug("%s: failed 1 (%d)\n", __func__, res);
 		return;
 	}
-	printk(KERN_DEBUG "prism2_pccard_genesis_sreset: original COR %02x\n",
-		old_cor);
+	pr_debug("%s: original COR %02x\n", __func__, old_cor);
 
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
 				old_cor | COR_SOFT_RESET);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 2 "
-		       "(%d)\n", res);
+		pr_debug("%s: failed 2 (%d)\n", __func__, res);
 		return;
 	}
 
@@ -402,8 +397,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	/* Setup Genesis mode */
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_CCSR, hcr);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 3 "
-		       "(%d)\n", res);
+		pr_debug("%s: failed 3 (%d)\n", __func__, res);
 		return;
 	}
 	mdelay(10);
@@ -411,8 +405,7 @@ static void prism2_pccard_genesis_reset(local_info_t *local, int hcr)
 	res = pcmcia_write_config_byte(hw_priv->link, CISREG_COR,
 				old_cor & ~COR_SOFT_RESET);
 	if (res != 0) {
-		printk(KERN_DEBUG "prism2_pccard_genesis_sreset failed 4 "
-		       "(%d)\n", res);
+		pr_debug("%s: failed 4 (%d)\n", __func__, res);
 		return;
 	}
 
@@ -499,9 +492,7 @@ static int prism2_config(struct pcmcia_device *link)
 	ret = pcmcia_loop_config(link, prism2_config_check, NULL);
 	if (ret) {
 		if (!ignore_cis_vcc)
-			printk(KERN_ERR "GetNextTuple(): No matching "
-			       "CIS configuration.  Maybe you need the "
-			       "ignore_cis_vcc=1 parameter.\n");
+			pr_err("GetNextTuple(): No matching CIS configuration.  Maybe you need the ignore_cis_vcc=1 parameter.\n");
 		goto failed;
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/hostap/hostap_download.c
index e73bf73..8090bc3 100644
--- a/drivers/net/wireless/hostap/hostap_download.c
+++ b/drivers/net/wireless/hostap/hostap_download.c
@@ -228,7 +228,7 @@ static u8 * prism2_read_pda(struct net_device *dev)
 	prism2_enable_aux_port(dev, 0);
 
 	if (!found) {
-		printk(KERN_DEBUG "%s: valid PDA not found\n", dev->name);
+		pr_debug("%s: valid PDA not found\n", dev->name);
 		kfree(buf);
 		buf = NULL;
 	}
@@ -245,8 +245,8 @@ static int prism2_download_volatile(local_info_t *local,
 	u16 param0, param1;
 
 	if (local->hw_downloading) {
-		printk(KERN_WARNING "%s: Already downloading - aborting new "
-		       "request\n", dev->name);
+		pr_warn("%s: Already downloading - aborting new request\n",
+			dev->name);
 		return -1;
 	}
 
@@ -257,16 +257,15 @@ static int prism2_download_volatile(local_info_t *local,
 		prism2_hw_shutdown(dev, 0);
 
 		if (prism2_hw_init(dev, 0)) {
-			printk(KERN_WARNING "%s: Could not initialize card for"
-			       " download\n", dev->name);
+			pr_warn("%s: Could not initialize card for download\n",
+				dev->name);
 			ret = -1;
 			goto out;
 		}
 	}
 
 	if (prism2_enable_aux_port(dev, 1)) {
-		printk(KERN_WARNING "%s: Could not enable AUX port\n",
-		       dev->name);
+		pr_warn("%s: Could not enable AUX port\n", dev->name);
 		ret = -1;
 		goto out;
 	}
@@ -279,8 +278,7 @@ static int prism2_download_volatile(local_info_t *local,
 	if (hfa384x_cmd_wait(dev, HFA384X_CMDCODE_DOWNLOAD |
 			     (HFA384X_PROGMODE_ENABLE_VOLATILE << 8),
 			     param0)) {
-		printk(KERN_WARNING "%s: Download command execution failed\n",
-		       dev->name);
+		pr_warn("%s: Download command execution failed\n", dev->name);
 		ret = -1;
 		goto out;
 	}
@@ -290,8 +288,8 @@ static int prism2_download_volatile(local_info_t *local,
 		       dev->name, param->data[i].len, param->data[i].addr);
 		if (hfa384x_to_aux(dev, param->data[i].addr,
 				   param->data[i].len, param->data[i].data)) {
-			printk(KERN_WARNING "%s: RAM download at 0x%08x "
-			       "(len=%d) failed\n", dev->name,
+			pr_warn("%s: RAM download at 0x%08x (len=%d) failed\n",
+				dev->name,
 			       param->data[i].addr, param->data[i].len);
 			ret = -1;
 			goto out;
@@ -302,8 +300,7 @@ static int prism2_download_volatile(local_info_t *local,
 	HFA384X_OUTW(0, HFA384X_PARAM2_OFF);
 	if (hfa384x_cmd_no_wait(dev, HFA384X_CMDCODE_DOWNLOAD |
 				(HFA384X_PROGMODE_DISABLE << 8), param0)) {
-		printk(KERN_WARNING "%s: Download command execution failed\n",
-		       dev->name);
+		pr_warn("%s: Download command execution failed\n", dev->name);
 		ret = -1;
 		goto out;
 	}
@@ -314,16 +311,15 @@ static int prism2_download_volatile(local_info_t *local,
 	HFA384X_OUTW(HFA384X_EV_CMD, HFA384X_EVACK_OFF);
 
 	if (prism2_enable_aux_port(dev, 0)) {
-		printk(KERN_DEBUG "%s: Disabling AUX port failed\n",
-		       dev->name);
+		pr_debug("%s: Disabling AUX port failed\n", dev->name);
 		/* continue anyway.. restart should have taken care of this */
 	}
 
 	mdelay(5);
 	local->hw_downloading = 0;
 	if (prism2_hw_config(dev, 2)) {
-		printk(KERN_WARNING "%s: Card configuration after RAM "
-		       "download failed\n", dev->name);
+		pr_warn("%s: Card configuration after RAM download failed\n",
+			dev->name);
 		ret = -1;
 		goto out;
 	}
@@ -340,8 +336,7 @@ static int prism2_enable_genesis(local_info_t *local, int hcr)
 	u8 initseq[4] = { 0x00, 0xe1, 0xa1, 0xff };
 	u8 readbuf[4];
 
-	printk(KERN_DEBUG "%s: test Genesis mode with HCR 0x%02x\n",
-	       dev->name, hcr);
+	pr_debug("%s: test Genesis mode with HCR 0x%02x\n", dev->name, hcr);
 	local->func->cor_sreset(local);
 	hfa384x_to_aux(dev, 0x7e0038, sizeof(initseq), initseq);
 	local->func->genesis_reset(local, hcr);
@@ -352,14 +347,12 @@ static int prism2_enable_genesis(local_info_t *local, int hcr)
 	hfa384x_from_aux(dev, 0x7e0038, sizeof(readbuf), readbuf);
 
 	if (memcmp(initseq, readbuf, sizeof(initseq)) == 0) {
-		printk(KERN_DEBUG "Readback test succeeded, HCR 0x%02x\n",
-		       hcr);
+		pr_debug("Readback test succeeded, HCR 0x%02x\n", hcr);
 		return 0;
 	} else {
-		printk(KERN_DEBUG "Readback test failed, HCR 0x%02x "
-		       "write %02x %02x %02x %02x read %02x %02x %02x %02x\n",
-		       hcr, initseq[0], initseq[1], initseq[2], initseq[3],
-		       readbuf[0], readbuf[1], readbuf[2], readbuf[3]);
+		pr_debug("Readback test failed, HCR 0x%02x write %02x %02x %02x %02x read %02x %02x %02x %02x\n",
+			 hcr, initseq[0], initseq[1], initseq[2], initseq[3],
+			 readbuf[0], readbuf[1], readbuf[2], readbuf[3]);
 		return 1;
 	}
 }
@@ -392,22 +385,21 @@ static int prism2_download_genesis(local_info_t *local,
 	int ret = 0;
 
 	if (local->hw_downloading) {
-		printk(KERN_WARNING "%s: Already downloading - aborting new "
-		       "request\n", dev->name);
+		pr_warn("%s: Already downloading - aborting new request\n",
+			dev->name);
 		return -EBUSY;
 	}
 
 	if (!local->func->genesis_reset || !local->func->cor_sreset) {
-		printk(KERN_INFO "%s: Genesis mode downloading not supported "
-		       "with this hwmodel\n", dev->name);
+		pr_info("%s: Genesis mode downloading not supported with this hwmodel\n",
+			dev->name);
 		return -EOPNOTSUPP;
 	}
 
 	local->hw_downloading = 1;
 
 	if (prism2_enable_aux_port(dev, 1)) {
-		printk(KERN_DEBUG "%s: failed to enable AUX port\n",
-		       dev->name);
+		pr_debug("%s: failed to enable AUX port\n", dev->name);
 		ret = -EIO;
 		goto out;
 	}
@@ -423,17 +415,16 @@ static int prism2_download_genesis(local_info_t *local,
 			PDEBUG(DEBUG_EXTRA2, "%s: Genesis mode OK using x16 "
 			       "SRAM\n", dev->name);
 		} else {
-			printk(KERN_DEBUG "%s: Could not initiate genesis "
-			       "mode\n", dev->name);
+			pr_debug("%s: Could not initiate genesis mode\n",
+				 dev->name);
 			ret = -EIO;
 			goto out;
 		}
 	} else {
 		if (prism2_enable_genesis(local, local->sram_type == 8 ?
 					  0x1f : 0x0f)) {
-			printk(KERN_DEBUG "%s: Failed to set Genesis "
-			       "mode (sram_type=%d)\n", dev->name,
-			       local->sram_type);
+			pr_debug("%s: Failed to set Genesis mode (sram_type=%d)\n",
+				 dev->name, local->sram_type);
 			ret = -EIO;
 			goto out;
 		}
@@ -445,9 +436,9 @@ static int prism2_download_genesis(local_info_t *local,
 		       dev->name, param->data[i].len, param->data[i].addr);
 		if (hfa384x_to_aux(dev, param->data[i].addr,
 				   param->data[i].len, param->data[i].data)) {
-			printk(KERN_WARNING "%s: RAM download at 0x%08x "
-			       "(len=%d) failed\n", dev->name,
-			       param->data[i].addr, param->data[i].len);
+			pr_warn("%s: RAM download at 0x%08x (len=%d) failed\n",
+				dev->name,
+				param->data[i].addr, param->data[i].len);
 			ret = -EIO;
 			goto out;
 		}
@@ -456,8 +447,7 @@ static int prism2_download_genesis(local_info_t *local,
 	PDEBUG(DEBUG_EXTRA2, "Disable genesis mode\n");
 	local->func->genesis_reset(local, ram16 ? 0x07 : 0x17);
 	if (prism2_enable_aux_port(dev, 0)) {
-		printk(KERN_DEBUG "%s: Failed to disable AUX port\n",
-		       dev->name);
+		pr_debug("%s: Failed to disable AUX port\n", dev->name);
 	}
 
 	mdelay(5);
@@ -470,16 +460,16 @@ static int prism2_download_genesis(local_info_t *local,
 	 */
 	hfa384x_disable_interrupts(dev);
 	if (prism2_hw_init(dev, 1)) {
-		printk(KERN_DEBUG "%s: Initialization after genesis mode "
-		       "download failed\n", dev->name);
+		pr_debug("%s: Initialization after genesis mode download failed\n",
+			 dev->name);
 		ret = -EIO;
 		goto out;
 	}
 
 	PDEBUG(DEBUG_EXTRA2, "Card initialized - running PRI only\n");
 	if (prism2_hw_init2(dev, 1)) {
-		printk(KERN_DEBUG "%s: Initialization(2) after genesis mode "
-		       "download failed\n", dev->name);
+		pr_debug("%s: Initialization(2) after genesis mode download failed\n",
+			 dev->name);
 		ret = -EIO;
 		goto out;
 	}
@@ -513,14 +503,14 @@ static inline int prism2_download_block(struct net_device *dev,
 	if (hfa384x_cmd_wait(dev, HFA384X_CMDCODE_DOWNLOAD |
 			     (HFA384X_PROGMODE_ENABLE_NON_VOLATILE << 8),
 			     param0)) {
-		printk(KERN_WARNING "%s: Flash download command execution "
-		       "failed\n", dev->name);
+		pr_warn("%s: Flash download command execution failed\n",
+			dev->name);
 		return -1;
 	}
 
 	if (hfa384x_to_aux(dev, bufaddr, block_len, data)) {
-		printk(KERN_WARNING "%s: flash download at 0x%08x "
-		       "(len=%d) failed\n", dev->name, addr, block_len);
+		pr_warn("%s: flash download at 0x%08x (len=%d) failed\n",
+			dev->name, addr, block_len);
 		return -1;
 	}
 
@@ -529,8 +519,8 @@ static inline int prism2_download_block(struct net_device *dev,
 	if (hfa384x_cmd_wait(dev, HFA384X_CMDCODE_DOWNLOAD |
 			     (HFA384X_PROGMODE_PROGRAM_NON_VOLATILE << 8),
 			     0)) {
-		printk(KERN_WARNING "%s: Flash write command execution "
-		       "failed\n", dev->name);
+		pr_warn("%s: Flash write command execution failed\n",
+			dev->name);
 		return -1;
 	}
 
@@ -551,8 +541,8 @@ static int prism2_download_nonvolatile(local_info_t *local,
 	u32 bufaddr;
 
 	if (local->hw_downloading) {
-		printk(KERN_WARNING "%s: Already downloading - aborting new "
-		       "request\n", dev->name);
+		pr_warn("%s: Already downloading - aborting new request\n",
+			dev->name);
 		return -1;
 	}
 
@@ -560,15 +550,14 @@ static int prism2_download_nonvolatile(local_info_t *local,
 				   &dlbuffer, 6, 0);
 
 	if (ret < 0) {
-		printk(KERN_WARNING "%s: Could not read download buffer "
-		       "parameters\n", dev->name);
+		pr_warn("%s: Could not read download buffer parameters\n",
+			dev->name);
 		goto out;
 	}
 
-	printk(KERN_DEBUG "Download buffer: %d bytes at 0x%04x:0x%04x\n",
-	       le16_to_cpu(dlbuffer.len),
-	       le16_to_cpu(dlbuffer.page),
-	       le16_to_cpu(dlbuffer.offset));
+	pr_debug("Download buffer: %d bytes at 0x%04x:0x%04x\n",
+		 le16_to_cpu(dlbuffer.len), le16_to_cpu(dlbuffer.page),
+		 le16_to_cpu(dlbuffer.offset));
 
 	bufaddr = (le16_to_cpu(dlbuffer.page) << 7) + le16_to_cpu(dlbuffer.offset);
 
@@ -578,8 +567,8 @@ static int prism2_download_nonvolatile(local_info_t *local,
 		prism2_hw_shutdown(dev, 0);
 
 		if (prism2_hw_init(dev, 0)) {
-			printk(KERN_WARNING "%s: Could not initialize card for"
-			       " download\n", dev->name);
+			pr_warn("%s: Could not initialize card for download\n",
+				dev->name);
 			ret = -1;
 			goto out;
 		}
@@ -588,13 +577,12 @@ static int prism2_download_nonvolatile(local_info_t *local,
 	hfa384x_disable_interrupts(dev);
 
 	if (prism2_enable_aux_port(dev, 1)) {
-		printk(KERN_WARNING "%s: Could not enable AUX port\n",
-		       dev->name);
+		pr_warn("%s: Could not enable AUX port\n", dev->name);
 		ret = -1;
 		goto out;
 	}
 
-	printk(KERN_DEBUG "%s: starting flash download\n", dev->name);
+	pr_debug("%s: starting flash download\n", dev->name);
 	for (i = 0; i < dl->num_areas; i++) {
 		int rest_len = dl->data[i].len;
 		int data_off = 0;
@@ -621,15 +609,13 @@ static int prism2_download_nonvolatile(local_info_t *local,
 	HFA384X_OUTW(0, HFA384X_PARAM2_OFF);
 	if (hfa384x_cmd_wait(dev, HFA384X_CMDCODE_DOWNLOAD |
 				(HFA384X_PROGMODE_DISABLE << 8), 0)) {
-		printk(KERN_WARNING "%s: Download command execution failed\n",
-		       dev->name);
+		pr_warn("%s: Download command execution failed\n", dev->name);
 		ret = -1;
 		goto out;
 	}
 
 	if (prism2_enable_aux_port(dev, 0)) {
-		printk(KERN_DEBUG "%s: Disabling AUX port failed\n",
-		       dev->name);
+		pr_debug("%s: Disabling AUX port failed\n", dev->name);
 		/* continue anyway.. restart should have taken care of this */
 	}
 
@@ -638,12 +624,12 @@ static int prism2_download_nonvolatile(local_info_t *local,
 	local->func->hw_reset(dev);
 	local->hw_downloading = 0;
 	if (prism2_hw_config(dev, 2)) {
-		printk(KERN_WARNING "%s: Card configuration after flash "
-		       "download failed\n", dev->name);
+		pr_warn("%s: Card configuration after flash download failed\n",
+			dev->name);
 		ret = -1;
 	} else {
-		printk(KERN_INFO "%s: Card initialized successfully after "
-		       "flash download\n", dev->name);
+		pr_info("%s: Card initialized successfully after flash download\n",
+			dev->name);
 	}
 
  out:
@@ -674,9 +660,8 @@ static int prism2_download(local_info_t *local,
 	u32 total_len = 0;
 	struct prism2_download_data *dl = NULL;
 
-	printk(KERN_DEBUG "prism2_download: dl_cmd=%d start_addr=0x%08x "
-	       "num_areas=%d\n",
-	       param->dl_cmd, param->start_addr, param->num_areas);
+	pr_debug("%s: dl_cmd=%d start_addr=0x%08x num_areas=%d\n",
+		 __func__, param->dl_cmd, param->start_addr, param->num_areas);
 
 	if (param->num_areas > 100) {
 		ret = -EINVAL;
@@ -734,14 +719,14 @@ static int prism2_download(local_info_t *local,
 #ifdef PRISM2_NON_VOLATILE_DOWNLOAD
 		ret = prism2_download_nonvolatile(local, dl);
 #else /* PRISM2_NON_VOLATILE_DOWNLOAD */
-		printk(KERN_INFO "%s: non-volatile downloading not enabled\n",
-		       local->dev->name);
+		pr_info("%s: non-volatile downloading not enabled\n",
+			local->dev->name);
 		ret = -EOPNOTSUPP;
 #endif /* PRISM2_NON_VOLATILE_DOWNLOAD */
 		break;
 	default:
-		printk(KERN_DEBUG "%s: unsupported download command %d\n",
-		       local->dev->name, param->dl_cmd);
+		pr_debug("%s: unsupported download command %d\n",
+			 local->dev->name, param->dl_cmd);
 		ret = -EINVAL;
 		break;
 	}
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 50f87b6..04e412d 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -29,8 +29,6 @@
  *   (spin_lock_bh) to prevent concurrent use.
  */
 
-
-
 #include <asm/delay.h>
 #include <asm/uaccess.h>
 
@@ -229,17 +227,16 @@ static void prism2_clear_cmd_queue(local_info_t *local)
 	list_for_each_safe(ptr, n, &local->cmd_queue) {
 		entry = list_entry(ptr, struct hostap_cmd_queue, list);
 		atomic_inc(&entry->usecnt);
-		printk(KERN_DEBUG "%s: removed pending cmd_queue entry "
-		       "(type=%d, cmd=0x%04x, param0=0x%04x)\n",
-		       local->dev->name, entry->type, entry->cmd,
-		       entry->param0);
+		pr_debug("%s: removed pending cmd_queue entry (type=%d, cmd=0x%04x, param0=0x%04x)\n",
+			 local->dev->name, entry->type, entry->cmd,
+			 entry->param0);
 		__hostap_cmd_queue_free(local, entry, 1);
 	}
 	if (local->cmd_queue_len) {
 		/* This should not happen; print debug message and clear
 		 * queue length. */
-		printk(KERN_DEBUG "%s: cmd_queue_len (%d) not zero after "
-		       "flush\n", local->dev->name, local->cmd_queue_len);
+		pr_debug("%s: cmd_queue_len (%d) not zero after flush\n",
+			 local->dev->name, local->cmd_queue_len);
 		local->cmd_queue_len = 0;
 	}
 	spin_unlock_irqrestore(&local->cmdlock, flags);
@@ -267,8 +264,8 @@ static int hfa384x_cmd_issue(struct net_device *dev,
 		return -ENODEV;
 
 	if (entry->issued) {
-		printk(KERN_DEBUG "%s: driver bug - re-issuing command @%p\n",
-		       dev->name, entry);
+		pr_debug("%s: driver bug - re-issuing command @%p\n",
+			 dev->name, entry);
 	}
 
 	/* wait until busy bit is clear; this should always be clear since the
@@ -281,16 +278,15 @@ static int hfa384x_cmd_issue(struct net_device *dev,
 #ifndef final_version
 	if (tries != HFA384X_CMD_BUSY_TIMEOUT) {
 		prism2_io_debug_error(dev, 1);
-		printk(KERN_DEBUG "%s: hfa384x_cmd_issue: cmd reg was busy "
-		       "for %d usec\n", dev->name,
-		       HFA384X_CMD_BUSY_TIMEOUT - tries);
+		pr_debug("%s: %s: cmd reg was busy for %d usec\n",
+			 dev->name, __func__, HFA384X_CMD_BUSY_TIMEOUT - tries);
 	}
 #endif
 	if (tries == 0) {
 		reg = HFA384X_INW(HFA384X_CMD_OFF);
 		prism2_io_debug_error(dev, 2);
-		printk(KERN_DEBUG "%s: hfa384x_cmd_issue - timeout - "
-		       "reg=0x%04x\n", dev->name, reg);
+		pr_debug("%s: %s: timeout - reg=0x%04x\n",
+			 dev->name, __func__, reg);
 		return -ETIMEDOUT;
 	}
 
@@ -332,14 +328,13 @@ static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 	local = iface->local;
 
 	if (in_interrupt()) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd called from interrupt "
-		       "context\n", dev->name);
+		pr_debug("%s: %s called from interrupt context\n",
+			 dev->name, __func__);
 		return -1;
 	}
 
 	if (local->cmd_queue_len >= HOSTAP_CMD_QUEUE_MAX_LEN) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd: cmd_queue full\n",
-		       dev->name);
+		pr_debug("%s: %s: cmd_queue full\n", dev->name, __func__);
 		return -1;
 	}
 
@@ -426,34 +421,32 @@ static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 
 	spin_lock_irqsave(&local->cmdlock, flags);
 	if (!list_empty(&entry->list)) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd: entry still in list? "
-		       "(entry=%p, type=%d, res=%d)\n", dev->name, entry,
-		       entry->type, res);
+		pr_debug("%s: %s: entry still in list? (entry=%p, type=%d, res=%d)\n",
+			 dev->name, __func__, entry, entry->type, res);
 		list_del_init(&entry->list);
 		local->cmd_queue_len--;
 	}
 	spin_unlock_irqrestore(&local->cmdlock, flags);
 
 	if (err) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd: interrupted; err=%d\n",
-		       dev->name, err);
+		pr_debug("%s: %s: interrupted; err=%d\n",
+			 dev->name, __func__, err);
 		res = err;
 		goto done;
 	}
 
 	if (entry->type != CMD_COMPLETED) {
 		u16 reg = HFA384X_INW(HFA384X_EVSTAT_OFF);
-		printk(KERN_DEBUG "%s: hfa384x_cmd: command was not "
-		       "completed (res=%d, entry=%p, type=%d, cmd=0x%04x, "
-		       "param0=0x%04x, EVSTAT=%04x INTEN=%04x)\n", dev->name,
-		       res, entry, entry->type, entry->cmd, entry->param0, reg,
-		       HFA384X_INW(HFA384X_INTEN_OFF));
+		pr_debug("%s: %s: command was not completed (res=%d, entry=%p, type=%d, cmd=0x%04x, param0=0x%04x, EVSTAT=%04x INTEN=%04x)\n",
+			 dev->name, __func__,
+			 res, entry, entry->type, entry->cmd, entry->param0,
+			 reg, HFA384X_INW(HFA384X_INTEN_OFF));
 		if (reg & HFA384X_EV_CMD) {
 			/* Command completion event is pending, but the
 			 * interrupt was not delivered - probably an issue
 			 * with pcmcia-cs configuration. */
-			printk(KERN_WARNING "%s: interrupt delivery does not "
-			       "seem to work\n", dev->name);
+			pr_warn("%s: interrupt delivery does not seem to work\n",
+				dev->name);
 		}
 		prism2_io_debug_error(dev, 3);
 		res = -ETIMEDOUT;
@@ -464,9 +457,8 @@ static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 		*resp0 = entry->resp0;
 #ifndef final_version
 	if (entry->res) {
-		printk(KERN_DEBUG "%s: CMD=0x%04x => res=0x%02x, "
-		       "resp0=0x%04x\n",
-		       dev->name, cmd, entry->res, entry->resp0);
+		pr_debug("%s: CMD=0x%04x => res=0x%02x, resp0=0x%04x\n",
+			 dev->name, cmd, entry->res, entry->resp0);
 	}
 #endif /* final_version */
 
@@ -507,8 +499,7 @@ static int hfa384x_cmd_callback(struct net_device *dev, u16 cmd, u16 param0,
 	local = iface->local;
 
 	if (local->cmd_queue_len >= HOSTAP_CMD_QUEUE_MAX_LEN + 2) {
-		printk(KERN_DEBUG "%s: hfa384x_cmd: cmd_queue full\n",
-		       dev->name);
+		pr_debug("%s: %s: cmd_queue full\n", dev->name, __func__);
 		return -1;
 	}
 
@@ -567,8 +558,8 @@ static int __hfa384x_cmd_no_wait(struct net_device *dev, u16 cmd, u16 param0,
 	if (tries == 0) {
 		reg = HFA384X_INW(HFA384X_CMD_OFF);
 		prism2_io_debug_error(dev, io_debug_num);
-		printk(KERN_DEBUG "%s: __hfa384x_cmd_no_wait(%d) - timeout - "
-		       "reg=0x%04x\n", dev->name, io_debug_num, reg);
+		pr_debug("%s: %s(%d) - timeout - reg=0x%04x\n",
+			 dev->name, __func__, io_debug_num, reg);
 		return -ETIMEDOUT;
 	}
 
@@ -609,8 +600,8 @@ static int hfa384x_cmd_wait(struct net_device *dev, u16 cmd, u16 param0)
         if (tries == 0) {
                 reg = HFA384X_INW(HFA384X_EVSTAT_OFF);
 		prism2_io_debug_error(dev, 5);
-                printk(KERN_DEBUG "%s: hfa384x_cmd_wait - timeout2 - "
-		       "reg=0x%04x\n", dev->name, reg);
+		pr_debug("%s: %s: timeout2 - reg=0x%04x\n",
+			 dev->name, __func__, reg);
                 return -ETIMEDOUT;
         }
 
@@ -619,8 +610,7 @@ static int hfa384x_cmd_wait(struct net_device *dev, u16 cmd, u16 param0)
                 BIT(8))) >> 8;
 #ifndef final_version
 	if (res) {
-		printk(KERN_DEBUG "%s: CMD=0x%04x => res=0x%02x\n",
-		       dev->name, cmd, res);
+		pr_debug("%s: CMD=0x%04x => res=0x%02x\n", dev->name, cmd, res);
 	}
 #endif
 
@@ -671,8 +661,8 @@ static void prism2_cmd_ev(struct net_device *dev)
 		local->cmd_queue_len--;
 
 		if (!entry->issued) {
-			printk(KERN_DEBUG "%s: Command completion event, but "
-			       "cmd not issued\n", dev->name);
+			pr_debug("%s: Command completion event, but cmd not issued\n",
+				 dev->name);
 			__hostap_cmd_queue_free(local, entry, 1);
 			entry = NULL;
 		}
@@ -681,8 +671,8 @@ static void prism2_cmd_ev(struct net_device *dev)
 
 	if (!entry) {
 		HFA384X_OUTW(HFA384X_EV_CMD, HFA384X_EVACK_OFF);
-		printk(KERN_DEBUG "%s: Command completion event, but no "
-		       "pending commands\n", dev->name);
+		pr_debug("%s: Command completion event, but no pending commands\n",
+			 dev->name);
 		return;
 	}
 
@@ -701,8 +691,8 @@ static void prism2_cmd_ev(struct net_device *dev)
 			entry->callback(dev, entry->context, entry->resp0,
 					entry->res);
 	} else {
-		printk(KERN_DEBUG "%s: Invalid command completion type %d\n",
-		       dev->name, entry->type);
+		pr_debug("%s: Invalid command completion type %d\n",
+			 dev->name, entry->type);
 	}
 	hostap_cmd_queue_free(local, entry, 1);
 
@@ -767,8 +757,7 @@ static int hfa384x_setup_bap(struct net_device *dev, u16 bap, u16 id,
 
 	if (hfa384x_wait_offset(dev, o_off)) {
 		prism2_io_debug_error(dev, 7);
-		printk(KERN_DEBUG "%s: hfa384x_setup_bap - timeout before\n",
-		       dev->name);
+		pr_debug("%s: %s: timeout before\n", dev->name, __func__);
 		ret = -ETIMEDOUT;
 		goto out;
 	}
@@ -778,17 +767,16 @@ static int hfa384x_setup_bap(struct net_device *dev, u16 bap, u16 id,
 
 	if (hfa384x_wait_offset(dev, o_off)) {
 		prism2_io_debug_error(dev, 8);
-		printk(KERN_DEBUG "%s: hfa384x_setup_bap - timeout after\n",
-		       dev->name);
+		pr_debug("%s: %s: timeout after\n", dev->name, __func__);
 		ret = -ETIMEDOUT;
 		goto out;
 	}
 #ifndef final_version
 	if (HFA384X_INW(o_off) & HFA384X_OFFSET_ERR) {
 		prism2_io_debug_error(dev, 9);
-		printk(KERN_DEBUG "%s: hfa384x_setup_bap - offset error "
-		       "(%d,0x04%x,%d); reg=0x%04x\n",
-		       dev->name, bap, id, offset, HFA384X_INW(o_off));
+		pr_debug("%s: %s: offset error (%d,0x04%x,%d); reg=0x%04x\n",
+			 dev->name, __func__, bap, id, offset,
+			 HFA384X_INW(o_off));
 		ret = -EINVAL;
 	}
 #endif
@@ -810,8 +798,8 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 	local = iface->local;
 
 	if (local->no_pri) {
-		printk(KERN_DEBUG "%s: cannot get RID %04x (len=%d) - no PRI "
-		       "f/w\n", dev->name, rid, len);
+		pr_debug("%s: cannot get RID %04x (len=%d) - no PRI f/w\n",
+			 dev->name, rid, len);
 		return -ENOTTY; /* Well.. not really correct, but return
 				 * something unique enough.. */
 	}
@@ -826,9 +814,8 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 
 	res = hfa384x_cmd(dev, HFA384X_CMDCODE_ACCESS, rid, NULL, NULL);
 	if (res) {
-		printk(KERN_DEBUG "%s: hfa384x_get_rid: CMDCODE_ACCESS failed "
-		       "(res=%d, rid=%04x, len=%d)\n",
-		       dev->name, res, rid, len);
+		pr_debug("%s: %s: CMDCODE_ACCESS failed (res=%d, rid=%04x, len=%d)\n",
+			 dev->name, __func__, res, rid, len);
 		mutex_unlock(&local->rid_bap_mtx);
 		return res;
 	}
@@ -846,9 +833,8 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 
 	rlen = (le16_to_cpu(rec.len) - 1) * 2;
 	if (!res && exact_len && rlen != len) {
-		printk(KERN_DEBUG "%s: hfa384x_get_rid - RID len mismatch: "
-		       "rid=0x%04x, len=%d (expected %d)\n",
-		       dev->name, rid, rlen, len);
+		pr_debug("%s: %s: RID len mismatch: rid=0x%04x, len=%d (expected %d)\n",
+			 dev->name, __func__, rid, rlen, len);
 		res = -ENODATA;
 	}
 
@@ -860,9 +846,8 @@ static int hfa384x_get_rid(struct net_device *dev, u16 rid, void *buf, int len,
 
 	if (res) {
 		if (res != -ENODATA)
-			printk(KERN_DEBUG "%s: hfa384x_get_rid (rid=%04x, "
-			       "len=%d) - failed - res=%d\n", dev->name, rid,
-			       len, res);
+			pr_debug("%s: %s: (rid=%04x, len=%d) - failed - res=%d\n",
+				 dev->name, __func__, rid, len, res);
 		if (res == -ETIMEDOUT)
 			prism2_hw_reset(dev);
 		return res;
@@ -883,8 +868,8 @@ static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 	local = iface->local;
 
 	if (local->no_pri) {
-		printk(KERN_DEBUG "%s: cannot set RID %04x (len=%d) - no PRI "
-		       "f/w\n", dev->name, rid, len);
+		pr_debug("%s: cannot set RID %04x (len=%d) - no PRI f/w\n",
+			 dev->name, rid, len);
 		return -ENOTTY; /* Well.. not really correct, but return
 				 * something unique enough.. */
 	}
@@ -910,8 +895,8 @@ static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 	spin_unlock_bh(&local->baplock);
 
 	if (res) {
-		printk(KERN_DEBUG "%s: hfa384x_set_rid (rid=%04x, len=%d) - "
-		       "failed - res=%d\n", dev->name, rid, len, res);
+		pr_debug("%s: %s: (rid=%04x, len=%d) - failed - res=%d\n",
+			 dev->name, __func__, rid, len, res);
 		mutex_unlock(&local->rid_bap_mtx);
 		return res;
 	}
@@ -920,9 +905,8 @@ static int hfa384x_set_rid(struct net_device *dev, u16 rid, void *buf, int len)
 	mutex_unlock(&local->rid_bap_mtx);
 
 	if (res) {
-		printk(KERN_DEBUG "%s: hfa384x_set_rid: CMDCODE_ACCESS_WRITE "
-		       "failed (res=%d, rid=%04x, len=%d)\n",
-		       dev->name, res, rid, len);
+		pr_debug("%s: %s: CMDCODE_ACCESS_WRITE failed (res=%d, rid=%04x, len=%d)\n",
+			 dev->name, __func__, res, rid, len);
 
 		if (res == -ETIMEDOUT)
 			prism2_hw_reset(dev);
@@ -976,8 +960,7 @@ static u16 hfa384x_allocate_fid(struct net_device *dev, int len)
 	 * below would be handled like CmdCompl event (sleep here, wake up from
 	 * interrupt handler */
 	if (hfa384x_cmd_wait(dev, HFA384X_CMDCODE_ALLOC, len)) {
-		printk(KERN_DEBUG "%s: cannot allocate fid, len=%d\n",
-		       dev->name, len);
+		pr_debug("%s: cannot allocate fid, len=%d\n", dev->name, len);
 		return 0xffff;
 	}
 
@@ -1012,14 +995,13 @@ static int prism2_reset_port(struct net_device *dev)
 	res = hfa384x_cmd(dev, HFA384X_CMDCODE_DISABLE, 0,
 			  NULL, NULL);
 	if (res)
-		printk(KERN_DEBUG "%s: reset port failed to disable port\n",
-		       dev->name);
+		pr_debug("%s: reset port failed to disable port\n", dev->name);
 	else {
 		res = hfa384x_cmd(dev, HFA384X_CMDCODE_ENABLE, 0,
 				  NULL, NULL);
 		if (res)
-			printk(KERN_DEBUG "%s: reset port failed to enable "
-			       "port\n", dev->name);
+			pr_debug("%s: reset port failed to enable port\n",
+				 dev->name);
 	}
 
 	/* It looks like at least some STA firmware versions reset
@@ -1028,9 +1010,8 @@ static int prism2_reset_port(struct net_device *dev)
 	if (local->fragm_threshold != 2346 &&
 	    hostap_set_word(dev, HFA384X_RID_FRAGMENTATIONTHRESHOLD,
 			    local->fragm_threshold)) {
-		printk(KERN_DEBUG "%s: failed to restore fragmentation "
-		       "threshold (%d) after Port0 enable\n",
-		       dev->name, local->fragm_threshold);
+		pr_debug("%s: failed to restore fragmentation threshold (%d) after Port0 enable\n",
+			 dev->name, local->fragm_threshold);
 	}
 
 	/* Some firmwares lose antenna selection settings on reset */
@@ -1055,13 +1036,14 @@ static int prism2_get_version_info(struct net_device *dev, u16 rid,
 		return -1;
 	}
 	if (hfa384x_get_rid(dev, rid, &comp, sizeof(comp), 1) < 0) {
-		printk(KERN_DEBUG "Could not get RID for component %s\n", txt);
+		pr_debug("Could not get RID for component %s\n", txt);
 		return -1;
 	}
 
-	printk(KERN_INFO "%s: %s: id=0x%02x v%d.%d.%d\n", dev->name, txt,
-	       __le16_to_cpu(comp.id), __le16_to_cpu(comp.major),
-	       __le16_to_cpu(comp.minor), __le16_to_cpu(comp.variant));
+	pr_info("%s: %s: id=0x%02x v%d.%d.%d\n",
+		dev->name, txt,
+		__le16_to_cpu(comp.id), __le16_to_cpu(comp.major),
+		__le16_to_cpu(comp.minor), __le16_to_cpu(comp.variant));
 	return 0;
 }
 
@@ -1116,8 +1098,8 @@ static int prism2_setup_rids(struct net_device *dev)
 
 	if (local->channel < 1 || local->channel > 14 ||
 	    !(local->channel_mask & (1 << (local->channel - 1)))) {
-		printk(KERN_WARNING "%s: Channel setting out of range "
-		       "(%d)!\n", dev->name, local->channel);
+		pr_warn("%s: Channel setting out of range (%d)!\n",
+			dev->name, local->channel);
 		ret = -EBUSY;
 		goto fail;
 	}
@@ -1152,8 +1134,8 @@ static int prism2_setup_rids(struct net_device *dev)
 	ret = hostap_set_word(dev, HFA384X_RID_PROMISCUOUSMODE,
 			      local->is_promisc);
 	if (ret)
-		printk(KERN_INFO "%s: Setting promiscuous mode (%d) failed\n",
-		       dev->name, local->is_promisc);
+		pr_info("%s: Setting promiscuous mode (%d) failed\n",
+			dev->name, local->is_promisc);
 
 	if (!local->fw_ap) {
 		ret = hostap_set_string(dev, HFA384X_RID_CNFDESIREDSSID,
@@ -1212,21 +1194,19 @@ static int prism2_setup_rids(struct net_device *dev)
 					 local->name);
 
 	if (hostap_set_encryption(local)) {
-		printk(KERN_INFO "%s: could not configure encryption\n",
-		       dev->name);
+		pr_info("%s: could not configure encryption\n", dev->name);
 	}
 
 	(void) hostap_set_antsel(local);
 
 	if (hostap_set_roaming(local)) {
-		printk(KERN_INFO "%s: could not set host roaming\n",
-		       dev->name);
+		pr_info("%s: could not set host roaming\n", dev->name);
 	}
 
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,6,3) &&
 	    hostap_set_word(dev, HFA384X_RID_CNFENHSECURITY, local->enh_sec))
-		printk(KERN_INFO "%s: cnfEnhSecurity setting to 0x%x failed\n",
-		       dev->name, local->enh_sec);
+		pr_info("%s: cnfEnhSecurity setting to 0x%x failed\n",
+			dev->name, local->enh_sec);
 
 	/* 32-bit tallies were added in STA f/w 0.8.0, but they were apparently
 	 * not working correctly (last seven counters report bogus values).
@@ -1236,8 +1216,8 @@ static int prism2_setup_rids(struct net_device *dev)
 	 * versions, too? */
 	if (local->sta_fw_ver >= PRISM2_FW_VER(0,8,2)) {
 		if (hostap_set_word(dev, HFA384X_RID_CNFTHIRTY2TALLY, 1)) {
-			printk(KERN_INFO "%s: cnfThirty2Tally setting "
-			       "failed\n", dev->name);
+			pr_info("%s: cnfThirty2Tally setting failed\n",
+				dev->name);
 			local->tallies32 = 0;
 		} else
 			local->tallies32 = 1;
@@ -1248,21 +1228,21 @@ static int prism2_setup_rids(struct net_device *dev)
 
 	if (hostap_set_word(dev, HFA384X_RID_FRAGMENTATIONTHRESHOLD,
 			    local->fragm_threshold)) {
-		printk(KERN_INFO "%s: setting FragmentationThreshold to %d "
-		       "failed\n", dev->name, local->fragm_threshold);
+		pr_info("%s: setting FragmentationThreshold to %d failed\n",
+			dev->name, local->fragm_threshold);
 	}
 
 	if (hostap_set_word(dev, HFA384X_RID_RTSTHRESHOLD,
 			    local->rts_threshold)) {
-		printk(KERN_INFO "%s: setting RTSThreshold to %d failed\n",
-		       dev->name, local->rts_threshold);
+		pr_info("%s: setting RTSThreshold to %d failed\n",
+			dev->name, local->rts_threshold);
 	}
 
 	if (local->manual_retry_count >= 0 &&
 	    hostap_set_word(dev, HFA384X_RID_CNFALTRETRYCOUNT,
 			    local->manual_retry_count)) {
-		printk(KERN_INFO "%s: setting cnfAltRetryCount to %d failed\n",
-		       dev->name, local->manual_retry_count);
+		pr_info("%s: setting cnfAltRetryCount to %d failed\n",
+			dev->name, local->manual_retry_count);
 	}
 
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,3,1) &&
@@ -1272,15 +1252,13 @@ static int prism2_setup_rids(struct net_device *dev)
 
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,7,0) && local->wpa &&
 	    hostap_set_word(dev, HFA384X_RID_SSNHANDLINGMODE, 1)) {
-		printk(KERN_INFO "%s: setting ssnHandlingMode to 1 failed\n",
-		       dev->name);
+		pr_info("%s: setting ssnHandlingMode to 1 failed\n", dev->name);
 	}
 
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,7,0) && local->generic_elem &&
 	    hfa384x_set_rid(dev, HFA384X_RID_GENERICELEMENT,
 			    local->generic_elem, local->generic_elem_len)) {
-		printk(KERN_INFO "%s: setting genericElement failed\n",
-		       dev->name);
+		pr_info("%s: setting genericElement failed\n", dev->name);
 	}
 
  fail:
@@ -1306,16 +1284,15 @@ static int prism2_hw_init(struct net_device *dev, int initial)
 	/* initialize HFA 384x */
 	ret = hfa384x_cmd_no_wait(dev, HFA384X_CMDCODE_INIT, 0);
 	if (ret) {
-		printk(KERN_INFO "%s: first command failed - assuming card "
-		       "does not have primary firmware\n", dev_info);
+		pr_info("first command failed - assuming card does not have primary firmware\n");
 	}
 
 	if (first && (HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_CMD)) {
 		/* EvStat has Cmd bit set in some cases, so retry once if no
 		 * wait was needed */
 		HFA384X_OUTW(HFA384X_EV_CMD, HFA384X_EVACK_OFF);
-		printk(KERN_DEBUG "%s: init command completed too quickly - "
-		       "retrying\n", dev->name);
+		pr_debug("%s: init command completed too quickly - retrying\n",
+			 dev->name);
 		first = 0;
 		goto init;
 	}
@@ -1326,9 +1303,7 @@ static int prism2_hw_init(struct net_device *dev, int initial)
 	       time_before(jiffies, delay))
 		yield();
 	if (!(HFA384X_INW(HFA384X_EVSTAT_OFF) & HFA384X_EV_CMD)) {
-		printk(KERN_DEBUG "%s: assuming no Primary image in "
-		       "flash - card initialization not completed\n",
-		       dev_info);
+		pr_debug("assuming no Primary image in flash - card initialization not completed\n");
 		local->no_pri = 1;
 #ifdef PRISM2_DOWNLOAD_SUPPORT
 			if (local->sram_type == -1)
@@ -1337,8 +1312,8 @@ static int prism2_hw_init(struct net_device *dev, int initial)
 		return 1;
 	}
 	local->no_pri = 0;
-	printk(KERN_DEBUG "prism2_hw_init: initialized in %lu ms\n",
-	       (jiffies - start) * 1000 / HZ);
+	pr_debug("%s: initialized in %lu ms\n",
+		 __func__, (jiffies - start) * 1000 / HZ);
 	HFA384X_OUTW(HFA384X_EV_CMD, HFA384X_EVACK_OFF);
 	return 0;
 }
@@ -1382,8 +1357,8 @@ static int prism2_hw_init2(struct net_device *dev, int initial)
 		}
 
 		if (prism2_get_version_info(dev, HFA384X_RID_STAID, "STA")) {
-			printk(KERN_DEBUG "%s: Failed to read STA f/w version "
-			       "- only Primary f/w present\n", dev->name);
+			pr_debug("%s: Failed to read STA f/w version - only Primary f/w present\n",
+				 dev->name);
 			local->pri_only = 1;
 			return 0;
 		}
@@ -1402,8 +1377,8 @@ static int prism2_hw_init2(struct net_device *dev, int initial)
 		if (local->txfid[i] == 0xffff && local->txfid_len > 1600) {
 			local->txfid[i] = hfa384x_allocate_fid(dev, 1600);
 			if (local->txfid[i] != 0xffff) {
-				printk(KERN_DEBUG "%s: Using shorter TX FID "
-				       "(1600 bytes)\n", dev->name);
+				pr_debug("%s: Using shorter TX FID (1600 bytes)\n",
+					 dev->name);
 				local->txfid_len = 1600;
 			}
 		}
@@ -1437,7 +1412,7 @@ static int prism2_hw_init2(struct net_device *dev, int initial)
 
  failed:
 	if (!local->no_pri)
-		printk(KERN_WARNING "%s: Initialization failed\n", dev_info);
+		pr_warn("Initialization failed\n");
 	return 1;
 }
 
@@ -1530,14 +1505,14 @@ static void prism2_hw_shutdown(struct net_device *dev, int no_disable)
 	local->dev_enabled = 0;
 
 	if (local->func->card_present && !local->func->card_present(local)) {
-		printk(KERN_DEBUG "%s: card already removed or not configured "
-		       "during shutdown\n", dev->name);
+		pr_debug("%s: card already removed or not configured during shutdown\n",
+			 dev->name);
 		return;
 	}
 
 	if ((no_disable & HOSTAP_HW_NO_DISABLE) == 0 &&
 	    hfa384x_cmd(dev, HFA384X_CMDCODE_DISABLE, 0, NULL, NULL))
-		printk(KERN_WARNING "%s: Shutdown failed\n", dev_info);
+		pr_warn("Shutdown failed\n");
 
 	hfa384x_disable_interrupts(dev);
 
@@ -1567,8 +1542,8 @@ static void prism2_hw_reset(struct net_device *dev)
 	local = iface->local;
 
 	if (in_interrupt()) {
-		printk(KERN_DEBUG "%s: driver bug - prism2_hw_reset() called "
-		       "in interrupt context\n", dev->name);
+		pr_debug("%s: driver bug - prism2_hw_reset() called in interrupt context\n",
+			 dev->name);
 		return;
 	}
 
@@ -1576,19 +1551,18 @@ static void prism2_hw_reset(struct net_device *dev)
 		return;
 
 	if (local->hw_resetting) {
-		printk(KERN_WARNING "%s: %s: already resetting card - "
-		       "ignoring reset request\n", dev_info, dev->name);
+		pr_warn("%s: already resetting card - ignoring reset request\n",
+			dev->name);
 		return;
 	}
 
 	local->hw_reset_tries++;
 	if (local->hw_reset_tries > 10) {
-		printk(KERN_WARNING "%s: too many reset tries, skipping\n",
-		       dev->name);
+		pr_warn("%s: too many reset tries, skipping\n", dev->name);
 		return;
 	}
 
-	printk(KERN_WARNING "%s: %s: resetting card\n", dev_info, dev->name);
+	pr_warn("%s: resetting card\n", dev->name);
 	hfa384x_disable_interrupts(dev);
 	local->hw_resetting = 1;
 	if (local->func->cor_sreset) {
@@ -1608,19 +1582,17 @@ static void prism2_hw_reset(struct net_device *dev)
 
 #ifdef PRISM2_DOWNLOAD_SUPPORT
 	if (local->dl_pri) {
-		printk(KERN_DEBUG "%s: persistent download of primary "
-		       "firmware\n", dev->name);
+		pr_debug("%s: persistent download of primary firmware\n",
+			 dev->name);
 		if (prism2_download_genesis(local, local->dl_pri) < 0)
-			printk(KERN_WARNING "%s: download (PRI) failed\n",
-			       dev->name);
+			pr_warn("%s: download (PRI) failed\n", dev->name);
 	}
 
 	if (local->dl_sec) {
-		printk(KERN_DEBUG "%s: persistent download of secondary "
-		       "firmware\n", dev->name);
+		pr_debug("%s: persistent download of secondary firmware\n",
+			 dev->name);
 		if (prism2_download_volatile(local, local->dl_sec) < 0)
-			printk(KERN_WARNING "%s: download (SEC) failed\n",
-			       dev->name);
+			pr_warn("%s: download (SEC) failed\n", dev->name);
 	}
 #endif /* PRISM2_DOWNLOAD_SUPPORT */
 
@@ -1640,7 +1612,7 @@ static void handle_reset_queue(struct work_struct *work)
 {
 	local_info_t *local = container_of(work, local_info_t, reset_queue);
 
-	printk(KERN_DEBUG "%s: scheduled card reset\n", local->dev->name);
+	pr_debug("%s: scheduled card reset\n", local->dev->name);
 	prism2_hw_reset(local->dev);
 
 	if (netif_queue_stopped(local->dev)) {
@@ -1696,20 +1668,19 @@ static void prism2_transmit_cb(struct net_device *dev, long context,
 	local = iface->local;
 
 	if (res) {
-		printk(KERN_DEBUG "%s: prism2_transmit_cb - res=0x%02x\n",
-		       dev->name, res);
+		pr_debug("%s: %s: res=0x%02x\n", dev->name, __func__, res);
 		return;
 	}
 
 	if (idx < 0 || idx >= PRISM2_TXFID_COUNT) {
-		printk(KERN_DEBUG "%s: prism2_transmit_cb called with invalid "
-		       "idx=%d\n", dev->name, idx);
+		pr_debug("%s: %s: called with invalid idx=%d\n",
+			 dev->name, __func__, idx);
 		return;
 	}
 
 	if (!test_and_clear_bit(HOSTAP_BITS_TRANSMIT, &local->bits)) {
-		printk(KERN_DEBUG "%s: driver bug: prism2_transmit_cb called "
-		       "with no pending transmit\n", dev->name);
+		pr_debug("%s: driver bug: %s: called with no pending transmit\n",
+			 dev->name, __func__);
 	}
 
 	if (netif_queue_stopped(dev)) {
@@ -1767,8 +1738,8 @@ static int prism2_transmit(struct net_device *dev, int idx)
 	 * is really the case */
 
 	if (test_and_set_bit(HOSTAP_BITS_TRANSMIT, &local->bits)) {
-		printk(KERN_DEBUG "%s: driver bug - prism2_transmit() called "
-		       "when previous TX was pending\n", dev->name);
+		pr_debug("%s: driver bug - %s() called when previous TX was pending\n",
+			 dev->name, __func__);
 		return -1;
 	}
 
@@ -1783,8 +1754,8 @@ static int prism2_transmit(struct net_device *dev, int idx)
 		prism2_transmit_cb, (long) idx);
 
 	if (res) {
-		printk(KERN_DEBUG "%s: prism2_transmit: CMDCODE_TRANSMIT "
-		       "failed (res=%d)\n", dev->name, res);
+		pr_debug("%s: %s: CMDCODE_TRANSMIT failed (res=%d)\n",
+			 dev->name, __func__, res);
 		dev->stats.tx_dropped++;
 		netif_wake_queue(dev);
 		return -1;
@@ -1821,8 +1792,8 @@ static int prism2_tx_80211(struct sk_buff *skb, struct net_device *dev)
 	if ((local->func->card_present && !local->func->card_present(local)) ||
 	    !local->hw_ready || local->hw_downloading || local->pri_only) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: prism2_tx_80211: hw not ready -"
-			       " skipping\n", dev->name);
+			pr_debug("%s: %s: hw not ready - skipping\n",
+				 dev->name, __func__);
 		}
 		goto fail;
 	}
@@ -1874,8 +1845,7 @@ static int prism2_tx_80211(struct sk_buff *skb, struct net_device *dev)
 	if (!res)
 		res = prism2_transmit(dev, idx);
 	if (res) {
-		printk(KERN_DEBUG "%s: prism2_tx_80211 - to BAP0 failed\n",
-		       dev->name);
+		pr_debug("%s: %s: to BAP0 failed\n", dev->name, __func__);
 		local->intransmitfid[idx] = PRISM2_TXFID_EMPTY;
 		schedule_work(&local->reset_queue);
 		goto fail;
@@ -1910,16 +1880,15 @@ static u16 prism2_read_fid_reg(struct net_device *dev, u16 reg)
 		if (val == val2 && val == val3)
 			return val;
 
-		printk(KERN_DEBUG "%s: detected fid change (try=%d, reg=%04x):"
-		       " %04x %04x %04x\n",
-		       dev->name, i, reg, val, val2, val3);
+		pr_debug("%s: detected fid change (try=%d, reg=%04x): %04x %04x %04x\n",
+			 dev->name, i, reg, val, val2, val3);
 		if ((val == val2 || val == val3) && val != 0)
 			return val;
 		if (val2 == val3 && val2 != 0)
 			return val2;
 	}
-	printk(KERN_WARNING "%s: Uhhuh.. could not read good fid from reg "
-	       "%04x (%04x %04x %04x)\n", dev->name, reg, val, val2, val3);
+	pr_warn("%s: Uhhuh.. could not read good fid from reg %04x (%04x %04x %04x)\n",
+		dev->name, reg, val, val2, val3);
 	return val;
 #else /* EXTRA_FID_READ_TESTS */
 	return HFA384X_INW(reg);
@@ -1942,8 +1911,7 @@ static void prism2_rx(local_info_t *local)
 #ifndef final_version
 	if (rxfid == 0) {
 		rxfid = HFA384X_INW(HFA384X_RXFID_OFF);
-		printk(KERN_DEBUG "prism2_rx: rxfid=0 (next 0x%04x)\n",
-		       rxfid);
+		pr_debug("%s: rxfid=0 (next 0x%04x)\n", __func__, rxfid);
 		if (rxfid == 0) {
 			schedule_work(&local->reset_queue);
 			goto rx_dropped;
@@ -1959,8 +1927,7 @@ static void prism2_rx(local_info_t *local)
 
 	if (res) {
 		spin_unlock(&local->baplock);
-		printk(KERN_DEBUG "%s: copy from BAP0 failed %d\n", dev->name,
-		       res);
+		pr_debug("%s: copy from BAP0 failed %d\n", dev->name, res);
 		if (res == -ETIMEDOUT) {
 			schedule_work(&local->reset_queue);
 		}
@@ -1985,8 +1952,8 @@ static void prism2_rx(local_info_t *local)
 			len = 0;
 		} else {
 			spin_unlock(&local->baplock);
-			printk(KERN_DEBUG "%s: Received frame with invalid "
-			       "length 0x%04x\n", dev->name, len);
+			pr_debug("%s: Received frame with invalid length 0x%04x\n",
+				 dev->name, len);
 			hostap_dump_rx_header(dev->name, &rxdesc);
 			goto rx_dropped;
 		}
@@ -1995,8 +1962,7 @@ static void prism2_rx(local_info_t *local)
 	skb = dev_alloc_skb(len + hdr_len);
 	if (!skb) {
 		spin_unlock(&local->baplock);
-		printk(KERN_DEBUG "%s: RX failed to allocate skb\n",
-		       dev->name);
+		pr_debug("%s: RX failed to allocate skb\n", dev->name);
 		goto rx_dropped;
 	}
 	skb->dev = dev;
@@ -2006,8 +1972,7 @@ static void prism2_rx(local_info_t *local)
 		res = hfa384x_from_bap(dev, BAP0, skb_put(skb, len), len);
 	spin_unlock(&local->baplock);
 	if (res) {
-		printk(KERN_DEBUG "%s: RX failed to read "
-		       "frame data\n", dev->name);
+		pr_debug("%s: RX failed to read frame data\n", dev->name);
 		goto rx_dropped;
 	}
 
@@ -2062,8 +2027,8 @@ static void hostap_rx_skb(local_info_t *local, struct sk_buff *skb)
 		goto drop;
 
 	if (skb->len > PRISM2_DATA_MAXLEN) {
-		printk(KERN_DEBUG "%s: RX: len(%d) > MAX(%d)\n",
-		       dev->name, skb->len, PRISM2_DATA_MAXLEN);
+		pr_debug("%s: RX: len(%d) > MAX(%d)\n",
+			 dev->name, skb->len, PRISM2_DATA_MAXLEN);
 		goto drop;
 	}
 
@@ -2148,13 +2113,12 @@ static void prism2_alloc_ev(struct net_device *dev)
 			idx = 0;
 	} while (idx != local->next_alloc);
 
-	printk(KERN_WARNING "%s: could not find matching txfid (0x%04x, new "
-	       "read 0x%04x) for alloc event\n", dev->name, fid,
-	       HFA384X_INW(HFA384X_ALLOCFID_OFF));
-	printk(KERN_DEBUG "TXFIDs:");
+	pr_warn("%s: could not find matching txfid (0x%04x, new read 0x%04x) for alloc event\n",
+		dev->name, fid, HFA384X_INW(HFA384X_ALLOCFID_OFF));
+	pr_debug("TXFIDs:");
 	for (idx = 0; idx < PRISM2_TXFID_COUNT; idx++)
-		printk(" %04x[%04x]", local->txfid[idx],
-		       local->intransmitfid[idx]);
+		printk(" %04x[%04x]",
+		       local->txfid[idx], local->intransmitfid[idx]);
 	printk("\n");
 	spin_unlock(&local->txfidlock);
 
@@ -2176,8 +2140,7 @@ static void hostap_tx_callback(local_info_t *local,
 
 	/* Make sure that frame was from us. */
 	if (memcmp(txdesc->addr2, local->dev->dev_addr, ETH_ALEN)) {
-		printk(KERN_DEBUG "%s: TX callback - foreign frame\n",
-		       local->dev->name);
+		pr_debug("%s: TX callback - foreign frame\n", local->dev->name);
 		return;
 	}
 
@@ -2190,8 +2153,8 @@ static void hostap_tx_callback(local_info_t *local,
 	spin_unlock(&local->lock);
 
 	if (cb == NULL) {
-		printk(KERN_DEBUG "%s: could not find TX callback (idx %d)\n",
-		       local->dev->name, sw_support);
+		pr_debug("%s: could not find TX callback (idx %d)\n",
+			 local->dev->name, sw_support);
 		return;
 	}
 
@@ -2199,8 +2162,8 @@ static void hostap_tx_callback(local_info_t *local,
 	len = le16_to_cpu(txdesc->data_len);
 	skb = dev_alloc_skb(hdrlen + len);
 	if (skb == NULL) {
-		printk(KERN_DEBUG "%s: hostap_tx_callback failed to allocate "
-		       "skb\n", local->dev->name);
+		pr_debug("%s: %s: failed to allocate skb\n",
+			 local->dev->name, __func__);
 		return;
 	}
 
@@ -2426,8 +2389,7 @@ static void prism2_info(local_info_t *local)
 		res = hfa384x_from_bap(dev, BAP0, &info, sizeof(info));
 	if (res) {
 		spin_unlock(&local->baplock);
-		printk(KERN_DEBUG "Could not get info frame (fid=0x%04x)\n",
-		       fid);
+		pr_debug("Could not get info frame (fid=0x%04x)\n", fid);
 		if (res == -ETIMEDOUT) {
 			schedule_work(&local->reset_queue);
 		}
@@ -2441,17 +2403,17 @@ static void prism2_info(local_info_t *local)
 		 * though busy bit is not set in offset register;
 		 * in addition, length must be at least 1 due to type field */
 		spin_unlock(&local->baplock);
-		printk(KERN_DEBUG "%s: Received info frame with invalid "
-		       "length 0x%04x (type 0x%04x)\n", dev->name,
-		       le16_to_cpu(info.len), le16_to_cpu(info.type));
+		pr_debug("%s: Received info frame with invalid length 0x%04x (type 0x%04x)\n",
+			 dev->name,
+			 le16_to_cpu(info.len), le16_to_cpu(info.type));
 		goto out;
 	}
 
 	skb = dev_alloc_skb(sizeof(info) + left);
 	if (skb == NULL) {
 		spin_unlock(&local->baplock);
-		printk(KERN_DEBUG "%s: Could not allocate skb for info "
-		       "frame\n", dev->name);
+		pr_debug("%s: Could not allocate skb for info frame\n",
+			 dev->name);
 		goto out;
 	}
 
@@ -2459,9 +2421,9 @@ static void prism2_info(local_info_t *local)
 	if (left > 0 && hfa384x_from_bap(dev, BAP0, skb_put(skb, left), left))
 	{
 		spin_unlock(&local->baplock);
-		printk(KERN_WARNING "%s: Info frame read failed (fid=0x%04x, "
-		       "len=0x%04x, type=0x%04x\n", dev->name, fid,
-		       le16_to_cpu(info.len), le16_to_cpu(info.type));
+		pr_warn("%s: Info frame read failed (fid=0x%04x, len=0x%04x, type=0x%04x\n",
+			dev->name, fid,
+			le16_to_cpu(info.len), le16_to_cpu(info.type));
 		dev_kfree_skb(skb);
 		goto out;
 	}
@@ -2549,15 +2511,14 @@ static void prism2_ev_tick(struct net_device *dev)
 		evstat = HFA384X_INW(HFA384X_EVSTAT_OFF);
 		inten = HFA384X_INW(HFA384X_INTEN_OFF);
 		if (!prev_stuck) {
-			printk(KERN_INFO "%s: SW TICK stuck? "
-			       "bits=0x%lx EvStat=%04x IntEn=%04x\n",
-			       dev->name, local->bits, evstat, inten);
+			pr_info("%s: SW TICK stuck? bits=0x%lx EvStat=%04x IntEn=%04x\n",
+				dev->name, local->bits, evstat, inten);
 		}
 		local->sw_tick_stuck++;
 		if ((evstat & HFA384X_BAP0_EVENTS) &&
 		    (inten & HFA384X_BAP0_EVENTS)) {
-			printk(KERN_INFO "%s: trying to recover from IRQ "
-			       "hang\n", dev->name);
+			pr_info("%s: trying to recover from IRQ hang\n",
+				dev->name);
 			hfa384x_events_no_bap0(dev);
 		}
 		prev_stuck = 1;
@@ -2591,10 +2552,10 @@ static void prism2_check_magic(local_info_t *local)
 			       HFA384X_MAGIC);
 			last_magic_err = jiffies;
 		} else if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: interrupt - SWSUPPORT0=%04x "
-			       "MAGIC=%04x\n", dev->name,
-			       HFA384X_INW(HFA384X_SWSUPPORT0_OFF),
-			       HFA384X_MAGIC);
+			pr_debug("%s: interrupt - SWSUPPORT0=%04x MAGIC=%04x\n",
+				 dev->name,
+				 HFA384X_INW(HFA384X_SWSUPPORT0_OFF),
+				 HFA384X_MAGIC);
 		}
 		if (HFA384X_INW(HFA384X_SWSUPPORT0_OFF) != 0xffff)
 			schedule_work(&local->reset_queue);
@@ -2621,8 +2582,8 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 	spin_lock(&local->irq_init_lock);
 	if (!dev->base_addr) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: Interrupt, but dev not configured\n",
-			       dev->name);
+			pr_debug("%s: Interrupt, but dev not configured\n",
+				 dev->name);
 		}
 		spin_unlock(&local->irq_init_lock);
 		return IRQ_HANDLED;
@@ -2633,8 +2594,7 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 
 	if (local->func->card_present && !local->func->card_present(local)) {
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: Interrupt, but dev not OK\n",
-			       dev->name);
+			pr_debug("%s: Interrupt, but dev not OK\n", dev->name);
 		}
 		return IRQ_HANDLED;
 	}
@@ -2647,8 +2607,7 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 			if (local->shutdown)
 				return IRQ_HANDLED;
 			HFA384X_OUTW(0xffff, HFA384X_EVACK_OFF);
-			printk(KERN_DEBUG "%s: prism2_interrupt: ev=0xffff\n",
-			       dev->name);
+			pr_debug("%s: %s: ev=0xffff\n", dev->name, __func__);
 			return IRQ_HANDLED;
 		}
 
@@ -2673,16 +2632,14 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 				return IRQ_HANDLED;
 			if (local->dev_enabled && (ev & ~HFA384X_EV_TICK) &&
 			    net_ratelimit()) {
-				printk(KERN_DEBUG "%s: prism2_interrupt: hw "
-				       "not ready; skipping events 0x%04x "
-				       "(IntEn=0x%04x)%s%s%s\n",
-				       dev->name, ev,
-				       HFA384X_INW(HFA384X_INTEN_OFF),
-				       !local->hw_ready ? " (!hw_ready)" : "",
-				       local->hw_resetting ?
-				       " (hw_resetting)" : "",
-				       !local->dev_enabled ?
-				       " (!dev_enabled)" : "");
+				pr_debug("%s: %s: hw not ready; skipping events 0x%04x (IntEn=0x%04x)%s%s%s\n",
+					 dev->name, __func__, ev,
+					 HFA384X_INW(HFA384X_INTEN_OFF),
+					 !local->hw_ready ? " (!hw_ready)" : "",
+					 local->hw_resetting
+					 ? " (hw_resetting)" : "",
+					 !local->dev_enabled
+					 ? " (!dev_enabled)" : "");
 			}
 			HFA384X_OUTW(ev, HFA384X_EVACK_OFF);
 			return IRQ_HANDLED;
@@ -2765,9 +2722,8 @@ static void prism2_check_sta_fw_version(local_info_t *local)
 
 	if (local->iw_mode == IW_MODE_MASTER && !local->host_encrypt &&
 	    !local->fw_encrypt_ok) {
-		printk(KERN_DEBUG "%s: defaulting to host-based encryption as "
-		       "a workaround for firmware bug in Host AP mode WEP\n",
-		       local->dev->name);
+		pr_debug("%s: defaulting to host-based encryption as a workaround for firmware bug in Host AP mode WEP\n",
+			 local->dev->name);
 		local->host_encrypt = 1;
 	}
 
@@ -2781,9 +2737,8 @@ static void prism2_check_sta_fw_version(local_info_t *local)
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,5,0))
 		local->wds_type |= HOSTAP_WDS_STANDARD_FRAME;
 	else {
-		printk(KERN_DEBUG "%s: defaulting to bogus WDS frame as a "
-		       "workaround for firmware bug in Host AP mode WDS\n",
-		       local->dev->name);
+		pr_debug("%s: defaulting to bogus WDS frame as a workaround for firmware bug in Host AP mode WDS\n",
+			 local->dev->name);
 	}
 
 	hostap_check_sta_fw_version(local->ap, local->sta_fw_ver);
@@ -2807,8 +2762,8 @@ static void hostap_passive_scan(unsigned long data)
 		 * passive scanning when a host-generated frame is being
 		 * transmitted */
 		if (test_bit(HOSTAP_BITS_TRANSMIT, &local->bits)) {
-			printk(KERN_DEBUG "%s: passive scan detected pending "
-			       "TX - delaying\n", dev->name);
+			pr_debug("%s: passive scan detected pending TX - delaying\n",
+				 dev->name);
 			local->passive_scan_timer.expires = jiffies + HZ / 10;
 			add_timer(&local->passive_scan_timer);
 			return;
@@ -2824,13 +2779,13 @@ static void hostap_passive_scan(unsigned long data)
 			 max_tries > 0);
 
 		if (max_tries == 0) {
-			printk(KERN_INFO "%s: no allowed passive scan channels"
-			       " found\n", dev->name);
+			pr_info("%s: no allowed passive scan channels found\n",
+				dev->name);
 			return;
 		}
 
-		printk(KERN_DEBUG "%s: passive scan channel %d\n",
-		       dev->name, local->passive_scan_channel);
+		pr_debug("%s: passive scan channel %d\n",
+			 dev->name, local->passive_scan_channel);
 		chan = local->passive_scan_channel;
 		local->passive_scan_state = PASSIVE_SCAN_WAIT;
 		local->passive_scan_timer.expires = jiffies + HZ / 10;
@@ -2844,8 +2799,8 @@ static void hostap_passive_scan(unsigned long data)
 	if (hfa384x_cmd_callback(dev, HFA384X_CMDCODE_TEST |
 				 (HFA384X_TEST_CHANGE_CHANNEL << 8),
 				 chan, NULL, 0))
-		printk(KERN_ERR "%s: passive scan channel set %d "
-		       "failed\n", dev->name, chan);
+		pr_err("%s: passive scan channel set %d failed\n",
+		       dev->name, chan);
 
 	add_timer(&local->passive_scan_timer);
 }
@@ -3029,9 +2984,8 @@ static void handle_set_tim_queue(struct work_struct *work)
 		if (entry->set)
 			val |= 0x8000;
 		if (hostap_set_word(local->dev, HFA384X_RID_CNFTIMCTRL, val)) {
-			printk(KERN_DEBUG "%s: set_tim failed (aid=%d "
-			       "set=%d)\n",
-			       local->dev->name, entry->aid, entry->set);
+			pr_debug("%s: set_tim failed (aid=%d set=%d)\n",
+				 local->dev->name, entry->aid, entry->set);
 		}
 
 		kfree(entry);
@@ -3089,8 +3043,7 @@ prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
 
 	len = strlen(dev_template);
 	if (len >= IFNAMSIZ || strstr(dev_template, "%d") == NULL) {
-		printk(KERN_WARNING "hostap: Invalid dev_template='%s'\n",
-		       dev_template);
+		pr_warn("Invalid dev_template='%s'\n", dev_template);
 		return NULL;
 	}
 
@@ -3160,8 +3113,8 @@ prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
 	    i == IW_MODE_MONITOR) {
 		local->iw_mode = i;
 	} else {
-		printk(KERN_WARNING "prism2: Unknown iw_mode %d; using "
-		       "IW_MODE_MASTER\n", i);
+		pr_warn("prism2: Unknown iw_mode %d; using IW_MODE_MASTER\n",
+			i);
 		local->iw_mode = IW_MODE_MASTER;
 	}
 	local->channel = GET_INT_PARM(channel, card_idx);
@@ -3241,11 +3194,10 @@ while (0)
 	prism2_set_lockdep_class(dev);
 	rtnl_unlock();
 	if (ret < 0) {
-		printk(KERN_WARNING "%s: register netdevice failed!\n",
-		       dev_info);
+		pr_warn("register netdevice failed!\n");
 		goto fail;
 	}
-	printk(KERN_INFO "%s: Registered netdevice %s\n", dev_info, dev->name);
+	pr_info("Registered netdevice %s\n", dev->name);
 
 	hostap_init_data(local);
 	return dev;
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index 47932b2..afdd08d 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -1,5 +1,7 @@
 /* Host AP driver Info Frame processing (part of hostap.o module) */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/if_arp.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -15,8 +17,8 @@ static void prism2_info_commtallies16(local_info_t *local, unsigned char *buf,
 	struct hfa384x_comm_tallies *tallies;
 
 	if (left < sizeof(struct hfa384x_comm_tallies)) {
-		printk(KERN_DEBUG "%s: too short (len=%d) commtallies "
-		       "info frame\n", local->dev->name, left);
+		pr_debug("%s: too short (len=%d) commtallies info frame\n",
+			 local->dev->name, left);
 		return;
 	}
 
@@ -55,8 +57,8 @@ static void prism2_info_commtallies32(local_info_t *local, unsigned char *buf,
 	struct hfa384x_comm_tallies32 *tallies;
 
 	if (left < sizeof(struct hfa384x_comm_tallies32)) {
-		printk(KERN_DEBUG "%s: too short (len=%d) commtallies32 "
-		       "info frame\n", local->dev->name, left);
+		pr_debug("%s: too short (len=%d) commtallies32 info frame\n",
+			 local->dev->name, left);
 		return;
 	}
 
@@ -135,8 +137,8 @@ static void prism2_info_linkstatus(local_info_t *local, unsigned char *buf,
 	local->last_join_time = 0;
 
 	if (left != 2) {
-		printk(KERN_DEBUG "%s: invalid linkstatus info frame "
-		       "length %d\n", local->dev->name, left);
+		pr_debug("%s: invalid linkstatus info frame length %d\n",
+			 local->dev->name, left);
 		return;
 	}
 
@@ -225,7 +227,7 @@ static void prism2_host_roaming(local_info_t *local)
 	       dev->name, req.bssid, le16_to_cpu(req.channel));
 	if (local->func->set_rid(dev, HFA384X_RID_JOINREQUEST, &req,
 				 sizeof(req))) {
-		printk(KERN_DEBUG "%s: JoinRequest failed\n", dev->name);
+		pr_debug("%s: JoinRequest failed\n", dev->name);
 	}
 	local->last_join_time = jiffies;
 }
@@ -258,8 +260,8 @@ static void prism2_info_scanresults(local_info_t *local, unsigned char *buf,
 	struct hfa384x_hostscan_result *results, *prev;
 
 	if (left < 4) {
-		printk(KERN_DEBUG "%s: invalid scanresult info frame "
-		       "length %d\n", local->dev->name, left);
+		pr_debug("%s: invalid scanresult info frame length %d\n",
+			 local->dev->name, left);
 		return;
 	}
 
@@ -311,16 +313,16 @@ static void prism2_info_hostscanresults(local_info_t *local,
 	wake_up_interruptible(&local->hostscan_wq);
 
 	if (left < 4) {
-		printk(KERN_DEBUG "%s: invalid hostscanresult info frame "
-		       "length %d\n", local->dev->name, left);
+		pr_debug("%s: invalid hostscanresult info frame length %d\n",
+			 local->dev->name, left);
 		return;
 	}
 
 	pos = (__le16 *) buf;
 	copy_len = result_size = le16_to_cpu(*pos);
 	if (result_size == 0) {
-		printk(KERN_DEBUG "%s: invalid result_size (0) in "
-		       "hostscanresults\n", local->dev->name);
+		pr_debug("%s: invalid result_size (0) in hostscanresults\n",
+			 local->dev->name);
 		return;
 	}
 	if (copy_len > sizeof(struct hfa384x_hostscan_result))
@@ -344,8 +346,8 @@ static void prism2_info_hostscanresults(local_info_t *local,
 	}
 
 	if (left) {
-		printk(KERN_DEBUG "%s: short HostScan result entry (%d/%d)\n",
-		       local->dev->name, left, result_size);
+		pr_debug("%s: short HostScan result entry (%d/%d)\n",
+			 local->dev->name, left, result_size);
 	}
 
 	spin_lock_irqsave(&local->lock, flags);
@@ -423,8 +425,8 @@ static void handle_info_queue_linkstatus(local_info_t *local)
 
 	if (local->func->get_rid(local->dev, HFA384X_RID_CURRENTBSSID,
 				 local->bssid, ETH_ALEN, 1) < 0) {
-		printk(KERN_DEBUG "%s: could not read CURRENTBSSID after "
-		       "LinkStatus event\n", local->dev->name);
+		pr_debug("%s: could not read CURRENTBSSID after LinkStatus event\n",
+			 local->dev->name);
 	} else {
 		PDEBUG(DEBUG_EXTRA, "%s: LinkStatus: BSSID=%pM\n",
 		       local->dev->name,
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 18054d9..c638047 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1,5 +1,7 @@
 /* ioctl() (mostly Linux Wireless Extensions) routines for Host AP driver */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/sched.h>
@@ -173,9 +175,8 @@ static int prism2_ioctl_siwencode(struct net_device *dev,
 			kfree(new_crypt);
 			new_crypt = NULL;
 
-			printk(KERN_WARNING "%s: could not initialize WEP: "
-			       "load module hostap_crypt_wep.o\n",
-			       dev->name);
+			pr_warn("%s: could not initialize WEP: load module hostap_crypt_wep.o\n",
+				dev->name);
 			return -EOPNOTSUPP;
 		}
 		*crypt = new_crypt;
@@ -204,7 +205,7 @@ static int prism2_ioctl_siwencode(struct net_device *dev,
 	local->open_wep = erq->flags & IW_ENCODE_OPEN;
 
 	if (hostap_set_encryption(local)) {
-		printk(KERN_DEBUG "%s: set_encryption failed\n", dev->name);
+		pr_debug("%s: set_encryption failed\n", dev->name);
 		return -EINVAL;
 	}
 
@@ -214,7 +215,7 @@ static int prism2_ioctl_siwencode(struct net_device *dev,
 	 * after WEP configuration. However, keys are apparently changed at
 	 * least in Managed mode. */
 	if (local->iw_mode != IW_MODE_INFRA && local->func->reset_port(dev)) {
-		printk(KERN_DEBUG "%s: reset_port failed\n", dev->name);
+		pr_debug("%s: reset_port failed\n", dev->name);
 		return -EINVAL;
 	}
 
@@ -295,17 +296,15 @@ static int hostap_set_rate(struct net_device *dev)
 
 	basic_rates = local->basic_rates & local->tx_rate_control;
 	if (!basic_rates || basic_rates != local->basic_rates) {
-		printk(KERN_INFO "%s: updating basic rate set automatically "
-		       "to match with the new supported rate set\n",
-		       dev->name);
+		pr_info("%s: updating basic rate set automatically to match with the new supported rate set\n",
+			dev->name);
 		if (!basic_rates)
 			basic_rates = local->tx_rate_control;
 
 		local->basic_rates = basic_rates;
 		if (hostap_set_word(dev, HFA384X_RID_CNFBASICRATES,
 				    basic_rates))
-			printk(KERN_WARNING "%s: failed to set "
-			       "cnfBasicRates\n", dev->name);
+			pr_warn("%s: failed to set cnfBasicRates\n", dev->name);
 	}
 
 	ret = (hostap_set_word(dev, HFA384X_RID_TXRATECONTROL,
@@ -315,9 +314,8 @@ static int hostap_set_rate(struct net_device *dev)
 	       local->func->reset_port(dev));
 
 	if (ret) {
-		printk(KERN_WARNING "%s: TXRateControl/cnfSupportedRates "
-		       "setting to 0x%x failed\n",
-		       dev->name, local->tx_rate_control);
+		pr_warn("%s: TXRateControl/cnfSupportedRates setting to 0x%x failed\n",
+			dev->name, local->tx_rate_control);
 	}
 
 	/* Update TX rate configuration for all STAs based on new operational
@@ -505,8 +503,7 @@ static int prism2_ioctl_giwaplist(struct net_device *dev,
 	local = iface->local;
 
 	if (local->iw_mode != IW_MODE_MASTER) {
-		printk(KERN_DEBUG "SIOCGIWAPLIST is currently only supported "
-		       "in Host AP mode\n");
+		pr_debug("SIOCGIWAPLIST is currently only supported in Host AP mode\n");
 		data->length = 0;
 		return -EOPNOTSUPP;
 	}
@@ -663,13 +660,13 @@ static int hostap_join_ap(struct net_device *dev)
 
 	if (local->func->set_rid(dev, HFA384X_RID_JOINREQUEST, &req,
 				 sizeof(req))) {
-		printk(KERN_DEBUG "%s: JoinRequest %pM failed\n",
-		       dev->name, local->preferred_ap);
+		pr_debug("%s: JoinRequest %pM failed\n",
+			 dev->name, local->preferred_ap);
 		return -1;
 	}
 
-	printk(KERN_DEBUG "%s: Trying to join BSSID %pM\n",
-	       dev->name, local->preferred_ap);
+	pr_debug("%s: Trying to join BSSID %pM\n",
+		 dev->name, local->preferred_ap);
 
 	return 0;
 }
@@ -698,18 +695,16 @@ static int prism2_ioctl_siwap(struct net_device *dev,
 		scan_req.txrate = cpu_to_le16(HFA384X_RATES_1MBPS);
 		if (local->func->set_rid(dev, HFA384X_RID_SCANREQUEST,
 					 &scan_req, sizeof(scan_req))) {
-			printk(KERN_DEBUG "%s: ScanResults request failed - "
-			       "preferred AP delayed to next unsolicited "
-			       "scan\n", dev->name);
+			pr_debug("%s: ScanResults request failed - preferred AP delayed to next unsolicited scan\n",
+				 dev->name);
 		}
 	} else if (local->host_roaming == 2 &&
 		   local->iw_mode == IW_MODE_INFRA) {
 		if (hostap_join_ap(dev))
 			return -EINVAL;
 	} else {
-		printk(KERN_DEBUG "%s: Preferred AP (SIOCSIWAP) is used only "
-		       "in Managed mode when host_roaming is enabled\n",
-		       dev->name);
+		pr_debug("%s: Preferred AP (SIOCSIWAP) is used only in Managed mode when host_roaming is enabled\n",
+			 dev->name);
 	}
 
 	return 0;
@@ -900,8 +895,8 @@ static int prism2_ioctl_siwessid(struct net_device *dev,
 	if (local->iw_mode == IW_MODE_MASTER && ssid[0] == '\0') {
 		/* Setting SSID to empty string seems to kill the card in
 		 * Host AP mode */
-		printk(KERN_DEBUG "%s: Host AP mode does not support "
-		       "'Any' essid\n", dev->name);
+		pr_debug("%s: Host AP mode does not support 'Any' essid\n",
+			 dev->name);
 		return -EINVAL;
 	}
 
@@ -1078,13 +1073,12 @@ static int hostap_monitor_mode_enable(local_info_t *local)
 {
 	struct net_device *dev = local->dev;
 
-	printk(KERN_DEBUG "Enabling monitor mode\n");
+	pr_debug("Enabling monitor mode\n");
 	hostap_monitor_set_type(local);
 
 	if (hostap_set_word(dev, HFA384X_RID_CNFPORTTYPE,
 			    HFA384X_PORTTYPE_PSEUDO_IBSS)) {
-		printk(KERN_DEBUG "Port type setting for monitor mode "
-		       "failed\n");
+		pr_debug("Port type setting for monitor mode failed\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -1094,7 +1088,7 @@ static int hostap_monitor_mode_enable(local_info_t *local)
 	if (hostap_set_word(dev, HFA384X_RID_CNFWEPFLAGS,
 			    HFA384X_WEPFLAGS_HOSTENCRYPT |
 			    HFA384X_WEPFLAGS_HOSTDECRYPT)) {
-		printk(KERN_DEBUG "WEP flags setting failed\n");
+		pr_debug("WEP flags setting failed\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -1102,7 +1096,7 @@ static int hostap_monitor_mode_enable(local_info_t *local)
 	    local->func->cmd(dev, HFA384X_CMDCODE_TEST |
 			     (HFA384X_TEST_MONITOR << 8),
 			     0, NULL, NULL)) {
-		printk(KERN_DEBUG "Setting monitor mode failed\n");
+		pr_debug("Setting monitor mode failed\n");
 		return -EOPNOTSUPP;
 	}
 
@@ -1117,7 +1111,7 @@ static int hostap_monitor_mode_disable(local_info_t *local)
 	if (dev == NULL)
 		return -1;
 
-	printk(KERN_DEBUG "%s: Disabling monitor mode\n", dev->name);
+	pr_debug("%s: Disabling monitor mode\n", dev->name);
 	dev->type = ARPHRD_ETHER;
 
 	if (local->func->cmd(dev, HFA384X_CMDCODE_TEST |
@@ -1153,8 +1147,8 @@ static int prism2_ioctl_siwmode(struct net_device *dev,
 		return 0;
 
 	if (*mode == IW_MODE_MASTER && local->essid[0] == '\0') {
-		printk(KERN_WARNING "%s: empty SSID not allowed in Master "
-		       "mode\n", dev->name);
+		pr_warn("%s: empty SSID not allowed in Master mode\n",
+			dev->name);
 		return -EINVAL;
 	}
 
@@ -1170,17 +1164,16 @@ static int prism2_ioctl_siwmode(struct net_device *dev,
 		double_reset = 1;
 	}
 
-	printk(KERN_DEBUG "prism2: %s: operating mode changed "
-	       "%d -> %d\n", dev->name, local->iw_mode, *mode);
+	pr_debug("prism2: %s: operating mode changed %d -> %d\n",
+		 dev->name, local->iw_mode, *mode);
 	local->iw_mode = *mode;
 
 	if (local->iw_mode == IW_MODE_MONITOR)
 		hostap_monitor_mode_enable(local);
 	else if (local->iw_mode == IW_MODE_MASTER && !local->host_encrypt &&
 		 !local->fw_encrypt_ok) {
-		printk(KERN_DEBUG "%s: defaulting to host-based encryption as "
-		       "a workaround for firmware bug in Host AP mode WEP\n",
-		       dev->name);
+		pr_debug("%s: defaulting to host-based encryption as a workaround for firmware bug in Host AP mode WEP\n",
+			 dev->name);
 		local->host_encrypt = 1;
 	}
 
@@ -1370,9 +1363,8 @@ static int prism2_ioctl_siwretry(struct net_device *dev,
 		} else {
 			if (hostap_set_word(dev, HFA384X_RID_CNFALTRETRYCOUNT,
 					    rrq->value)) {
-				printk(KERN_DEBUG "%s: Alternate retry count "
-				       "setting to %d failed\n",
-				       dev->name, rrq->value);
+				pr_debug("%s: Alternate retry count setting to %d failed\n",
+					 dev->name, rrq->value);
 				return -EOPNOTSUPP;
 			}
 
@@ -1522,8 +1514,8 @@ static int prism2_ioctl_siwtxpow(struct net_device *dev,
 			ret = local->func->cmd(dev, HFA384X_CMDCODE_WRITEMIF,
 					       HFA386X_CR_A_D_TEST_MODES2,
 					       &val, NULL);
-			printk(KERN_DEBUG "%s: Turning radio off: %s\n",
-			       dev->name, ret ? "failed" : "OK");
+			pr_debug("%s: Turning radio off: %s\n",
+				 dev->name, ret ? "failed" : "OK");
 			local->txpower_type = PRISM2_TXPOWER_OFF;
 		}
 		return (ret ? -EOPNOTSUPP : 0);
@@ -1533,14 +1525,14 @@ static int prism2_ioctl_siwtxpow(struct net_device *dev,
 		val = 0; /* disable all standby and sleep modes */
 		ret = local->func->cmd(dev, HFA384X_CMDCODE_WRITEMIF,
 				       HFA386X_CR_A_D_TEST_MODES2, &val, NULL);
-		printk(KERN_DEBUG "%s: Turning radio on: %s\n",
-		       dev->name, ret ? "failed" : "OK");
+		pr_debug("%s: Turning radio on: %s\n",
+			 dev->name, ret ? "failed" : "OK");
 		local->txpower_type = PRISM2_TXPOWER_UNKNOWN;
 	}
 
 #ifdef RAW_TXPOWER_SETTING
 	if (!rrq->fixed && local->txpower_type != PRISM2_TXPOWER_AUTO) {
-		printk(KERN_DEBUG "Setting ALC on\n");
+		pr_debug("Setting ALC on\n");
 		val = HFA384X_TEST_CFG_BIT_ALC;
 		local->func->cmd(dev, HFA384X_CMDCODE_TEST |
 				 (HFA384X_TEST_CFG_BITS << 8), 1, &val, NULL);
@@ -1549,7 +1541,7 @@ static int prism2_ioctl_siwtxpow(struct net_device *dev,
 	}
 
 	if (local->txpower_type != PRISM2_TXPOWER_FIXED) {
-		printk(KERN_DEBUG "Setting ALC off\n");
+		pr_debug("Setting ALC off\n");
 		val = HFA384X_TEST_CFG_BIT_ALC;
 		local->func->cmd(dev, HFA384X_CMDCODE_TEST |
 				 (HFA384X_TEST_CFG_BITS << 8), 0, &val, NULL);
@@ -1562,7 +1554,7 @@ static int prism2_ioctl_siwtxpow(struct net_device *dev,
 		tmp = "mW";
 	else
 		tmp = "UNKNOWN";
-	printk(KERN_DEBUG "Setting TX power to %d %s\n", rrq->value, tmp);
+	pr_debug("Setting TX power to %d %s\n", rrq->value, tmp);
 
 	if (rrq->flags != IW_TXPOW_DBM) {
 		printk("SIOCSIWTXPOW with mW is not supported; use dBm\n");
@@ -1652,7 +1644,7 @@ static int prism2_request_hostscan(struct net_device *dev,
 
 	if (local->func->set_rid(dev, HFA384X_RID_HOSTSCAN, &scan_req,
 				 sizeof(scan_req))) {
-		printk(KERN_DEBUG "%s: HOSTSCAN failed\n", dev->name);
+		pr_debug("%s: HOSTSCAN failed\n", dev->name);
 		return -EINVAL;
 	}
 	return 0;
@@ -1689,7 +1681,7 @@ static int prism2_request_scan(struct net_device *dev)
 
 	if (local->func->set_rid(dev, HFA384X_RID_SCANREQUEST, &scan_req,
 				 sizeof(scan_req))) {
-		printk(KERN_DEBUG "SCANREQUEST failed\n");
+		pr_debug("SCANREQUEST failed\n");
 		ret = -EINVAL;
 	}
 
@@ -2087,14 +2079,13 @@ static int prism2_ioctl_giwscan(struct net_device *dev,
 		/* Translate to WE format */
 		res = prism2_ap_translate_scan(dev, info, extra);
 		if (res >= 0) {
-			printk(KERN_DEBUG "Scan result translation succeeded "
-			       "(length=%d)\n", res);
+			pr_debug("Scan result translation succeeded (length=%d)\n",
+				 res);
 			data->length = res;
 			return 0;
 		} else {
-			printk(KERN_DEBUG
-			       "Scan result translation failed (res=%d)\n",
-			       res);
+			pr_debug("Scan result translation failed (res=%d)\n",
+				 res);
 			data->length = 0;
 			return res;
 		}
@@ -2349,8 +2340,8 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 			break;
 		}
 
-		printk(KERN_DEBUG "prism2: %s: pseudo IBSS change %d -> %d\n",
-		       dev->name, local->pseudo_adhoc, value);
+		pr_debug("prism2: %s: pseudo IBSS change %d -> %d\n",
+			 dev->name, local->pseudo_adhoc, value);
 		local->pseudo_adhoc = value;
 		if (local->iw_mode != IW_MODE_ADHOC)
 			break;
@@ -2367,8 +2358,8 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 #endif /* PRISM2_NO_STATION_MODES */
 
 	case PRISM2_PARAM_ALC:
-		printk(KERN_DEBUG "%s: %s ALC\n", dev->name,
-		       value == 0 ? "Disabling" : "Enabling");
+		pr_debug("%s: %s ALC\n",
+			 dev->name, value == 0 ? "Disabling" : "Enabling");
 		val = HFA384X_TEST_CFG_BIT_ALC;
 		local->func->cmd(dev, HFA384X_CMDCODE_TEST |
 				 (HFA384X_TEST_CFG_BITS << 8),
@@ -2533,13 +2524,12 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 			if (hostap_set_word(dev, HFA384X_RID_CNFPORTTYPE,
 					    HFA384X_PORTTYPE_BSS) ||
 			    local->func->reset_port(dev))
-				printk(KERN_DEBUG "Leaving Host AP mode "
-				       "for HostScan failed\n");
+				pr_debug("Leaving Host AP mode for HostScan failed\n");
 		}
 
 		if (local->func->set_rid(dev, HFA384X_RID_HOSTSCAN, &scan_req,
 					 sizeof(scan_req))) {
-			printk(KERN_DEBUG "HOSTSCAN failed\n");
+			pr_debug("HOSTSCAN failed\n");
 			ret = -EINVAL;
 		}
 		if (local->iw_mode == IW_MODE_MASTER) {
@@ -2556,8 +2546,7 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 			if (hostap_set_word(dev, HFA384X_RID_CNFPORTTYPE,
 					    HFA384X_PORTTYPE_HOSTAP) ||
 			    local->func->reset_port(dev))
-				printk(KERN_DEBUG "Returning to Host AP mode "
-				       "after HostScan failed\n");
+				pr_debug("Returning to Host AP mode after HostScan failed\n");
 		}
 		break;
 	}
@@ -2582,8 +2571,8 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 		if (hostap_set_word(dev, HFA384X_RID_CNFENHSECURITY,
 				    local->enh_sec) ||
 		    local->func->reset_port(dev)) {
-			printk(KERN_INFO "%s: cnfEnhSecurity requires STA f/w "
-			       "1.6.3 or newer\n", dev->name);
+			pr_info("%s: cnfEnhSecurity requires STA f/w 1.6.3 or newer\n",
+				dev->name);
 			ret = -EOPNOTSUPP;
 		}
 		break;
@@ -2596,9 +2585,8 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 
 	case PRISM2_PARAM_BASIC_RATES:
 		if ((value & local->tx_rate_control) != value || value == 0) {
-			printk(KERN_INFO "%s: invalid basic rate set - basic "
-			       "rates must be in supported rate set\n",
-			       dev->name);
+			pr_info("%s: invalid basic rate set - basic rates must be in supported rate set\n",
+				dev->name);
 			ret = -EINVAL;
 			break;
 		}
@@ -2652,8 +2640,8 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 		break;
 
 	default:
-		printk(KERN_DEBUG "%s: prism2_param: unknown param %d\n",
-		       dev->name, param);
+		pr_debug("%s: prism2_param: unknown param %d\n",
+			 dev->name, param);
 		ret = -EOPNOTSUPP;
 		break;
 	}
@@ -2839,8 +2827,8 @@ static int prism2_ioctl_priv_get_prism2_param(struct net_device *dev,
 		break;
 
 	default:
-		printk(KERN_DEBUG "%s: get_prism2_param: unknown param %d\n",
-		       dev->name, *param);
+		pr_debug("%s: get_prism2_param: unknown param %d\n",
+			 dev->name, *param);
 		ret = -EOPNOTSUPP;
 		break;
 	}
@@ -2900,9 +2888,8 @@ static int prism2_ioctl_priv_monitor(struct net_device *dev, int *i)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
-	printk(KERN_DEBUG "%s: process %d (%s) used deprecated iwpriv monitor "
-	       "- update software to use iwconfig mode monitor\n",
-	       dev->name, task_pid_nr(current), current->comm);
+	pr_debug("%s: process %d (%s) used deprecated iwpriv monitor - update software to use iwconfig mode monitor\n",
+		 dev->name, task_pid_nr(current), current->comm);
 
 	/* Backward compatibility code - this can be removed at some point */
 
@@ -2944,7 +2931,7 @@ static int prism2_ioctl_priv_reset(struct net_device *dev, int *i)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
-	printk(KERN_DEBUG "%s: manual reset request(%d)\n", dev->name, *i);
+	pr_debug("%s: manual reset request(%d)\n", dev->name, *i);
 	switch (*i) {
 	case 0:
 		/* Disable and enable card */
@@ -2976,7 +2963,7 @@ static int prism2_ioctl_priv_reset(struct net_device *dev, int *i)
 		break;
 
 	default:
-		printk(KERN_DEBUG "Unknown reset request %d\n", *i);
+		pr_debug("Unknown reset request %d\n", *i);
 		return -EOPNOTSUPP;
 	}
 
@@ -2989,7 +2976,7 @@ static int prism2_ioctl_priv_set_rid_word(struct net_device *dev, int *i)
 	int rid = *i;
 	int value = *(i + 1);
 
-	printk(KERN_DEBUG "%s: Set RID[0x%X] = %d\n", dev->name, rid, value);
+	pr_debug("%s: Set RID[0x%X] = %d\n", dev->name, rid, value);
 
 	if (hostap_set_word(dev, rid, value))
 		return -EINVAL;
@@ -3264,8 +3251,8 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 		module = "lib80211_crypt_ccmp";
 		break;
 	default:
-		printk(KERN_DEBUG "%s: unsupported algorithm %d\n",
-		       local->dev->name, ext->alg);
+		pr_debug("%s: unsupported algorithm %d\n",
+			 local->dev->name, ext->alg);
 		ret = -EOPNOTSUPP;
 		goto done;
 	}
@@ -3276,8 +3263,8 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 		ops = lib80211_get_crypto_ops(alg);
 	}
 	if (ops == NULL) {
-		printk(KERN_DEBUG "%s: unknown crypto alg '%s'\n",
-		       local->dev->name, alg);
+		pr_debug("%s: unknown crypto alg '%s'\n",
+			 local->dev->name, alg);
 		ret = -EOPNOTSUPP;
 		goto done;
 	}
@@ -3324,8 +3311,7 @@ static int prism2_ioctl_siwencodeext(struct net_device *dev,
 	    && (*crypt)->ops->set_key &&
 	    (*crypt)->ops->set_key(ext->key, ext->key_len, ext->rx_seq,
 				   (*crypt)->priv) < 0) {
-		printk(KERN_DEBUG "%s: key setting failed\n",
-		       local->dev->name);
+		pr_debug("%s: key setting failed\n", local->dev->name);
 		ret = -EINVAL;
 		goto done;
 	}
@@ -3497,8 +3483,8 @@ static int prism2_ioctl_set_encryption(local_info_t *local,
 		ops = lib80211_get_crypto_ops(param->u.crypt.alg);
 	}
 	if (ops == NULL) {
-		printk(KERN_DEBUG "%s: unknown crypto alg '%s'\n",
-		       local->dev->name, param->u.crypt.alg);
+		pr_debug("%s: unknown crypto alg '%s'\n",
+			 local->dev->name, param->u.crypt.alg);
 		param->u.crypt.err = HOSTAP_CRYPT_ERR_UNKNOWN_ALG;
 		ret = -EINVAL;
 		goto done;
@@ -3537,8 +3523,7 @@ static int prism2_ioctl_set_encryption(local_info_t *local,
 	    (*crypt)->ops->set_key(param->u.crypt.key,
 				   param->u.crypt.key_len, param->u.crypt.seq,
 				   (*crypt)->priv) < 0) {
-		printk(KERN_DEBUG "%s: key setting failed\n",
-		       local->dev->name);
+		pr_debug("%s: key setting failed\n", local->dev->name);
 		param->u.crypt.err = HOSTAP_CRYPT_ERR_KEY_SET_FAILED;
 		ret = -EINVAL;
 		goto done;
@@ -3548,8 +3533,8 @@ static int prism2_ioctl_set_encryption(local_info_t *local,
 		if (!sta_ptr)
 			local->crypt_info.tx_keyidx = param->u.crypt.idx;
 		else if (param->u.crypt.idx) {
-			printk(KERN_DEBUG "%s: TX key idx setting failed\n",
-			       local->dev->name);
+			pr_debug("%s: TX key idx setting failed\n",
+				 local->dev->name);
 			param->u.crypt.err =
 				HOSTAP_CRYPT_ERR_TX_KEY_SET_FAILED;
 			ret = -EINVAL;
@@ -3677,8 +3662,8 @@ static int prism2_ioctl_set_assoc_ap_addr(local_info_t *local,
 					  struct prism2_hostapd_param *param,
 					  int param_len)
 {
-	printk(KERN_DEBUG "%ssta: associated as client with AP %pM\n",
-	       local->dev->name, param->sta_addr);
+	pr_debug("%ssta: associated as client with AP %pM\n",
+		 local->dev->name, param->sta_addr);
 	memcpy(local->assoc_ap_addr, param->sta_addr, ETH_ALEN);
 	return 0;
 }
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 627bc12..643c003 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -12,6 +12,8 @@
  * more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -86,14 +88,12 @@ struct net_device * hostap_add_interface(struct local_info *local,
 		rtnl_unlock();
 
 	if (ret < 0) {
-		printk(KERN_WARNING "%s: failed to add new netdevice!\n",
-		       dev->name);
+		pr_warn("%s: failed to add new netdevice!\n", dev->name);
 		free_netdev(dev);
 		return NULL;
 	}
 
-	printk(KERN_DEBUG "%s: registered netdevice %s\n",
-	       mdev->name, dev->name);
+	pr_debug("%s: registered netdevice %s\n", mdev->name, dev->name);
 
 	return dev;
 }
@@ -165,8 +165,8 @@ int prism2_wds_add(local_info_t *local, u8 *remote_addr,
 		/* take pre-allocated entry into use */
 		memcpy(empty->u.wds.remote_addr, remote_addr, ETH_ALEN);
 		read_unlock_bh(&local->iface_lock);
-		printk(KERN_DEBUG "%s: using pre-allocated WDS netdevice %s\n",
-		       local->dev->name, empty->dev->name);
+		pr_debug("%s: using pre-allocated WDS netdevice %s\n",
+			 local->dev->name, empty->dev->name);
 		return 0;
 	}
 	read_unlock_bh(&local->iface_lock);
@@ -182,8 +182,7 @@ int prism2_wds_add(local_info_t *local, u8 *remote_addr,
 
 	/* verify that there is room for wds# postfix in the interface name */
 	if (strlen(local->dev->name) >= IFNAMSIZ - 5) {
-		printk(KERN_DEBUG "'%s' too long base device name\n",
-		       local->dev->name);
+		pr_debug("'%s' too long base device name\n", local->dev->name);
 		return -EINVAL;
 	}
 
@@ -347,7 +346,7 @@ int hostap_set_encryption(local_info_t *local)
 
 	if (local->func->get_rid(local->dev, HFA384X_RID_CNFWEPFLAGS, &val, 2,
 				 1) < 0) {
-		printk(KERN_DEBUG "Could not read current WEP flags.\n");
+		pr_debug("Could not read current WEP flags\n");
 		goto fail;
 	}
 	le16_to_cpus(&val);
@@ -377,8 +376,7 @@ int hostap_set_encryption(local_info_t *local)
 
 	if (val != old_val &&
 	    hostap_set_word(local->dev, HFA384X_RID_CNFWEPFLAGS, val)) {
-		printk(KERN_DEBUG "Could not write new WEP flags (0x%x)\n",
-		       val);
+		pr_debug("Could not write new WEP flags (0x%x)\n", val);
 		goto fail;
 	}
 
@@ -403,20 +401,20 @@ int hostap_set_encryption(local_info_t *local)
 		if (local->func->set_rid(local->dev,
 					 HFA384X_RID_CNFDEFAULTKEY0 + i,
 					 keybuf, keylen)) {
-			printk(KERN_DEBUG "Could not set key %d (len=%d)\n",
-			       i, keylen);
+			pr_debug("Could not set key %d (len=%d)\n",
+				 i, keylen);
 			goto fail;
 		}
 	}
 	if (hostap_set_word(local->dev, HFA384X_RID_CNFWEPDEFAULTKEYID, idx)) {
-		printk(KERN_DEBUG "Could not set default keyid %d\n", idx);
+		pr_debug("Could not set default keyid %d\n", idx);
 		goto fail;
 	}
 
 	return 0;
 
  fail:
-	printk(KERN_DEBUG "%s: encryption setup failed\n", local->dev->name);
+	pr_debug("%s: encryption setup failed\n", local->dev->name);
 	return -1;
 }
 
@@ -444,8 +442,8 @@ int hostap_set_antsel(local_info_t *local)
 
 		if (local->func->cmd(local->dev, HFA384X_CMDCODE_WRITEMIF,
 				     HFA386X_CR_TX_CONFIGURE, &val, NULL)) {
-			printk(KERN_INFO "%s: setting TX AntSel failed\n",
-			       local->dev->name);
+			pr_info("%s: setting TX AntSel failed\n",
+				local->dev->name);
 			ret = -1;
 		}
 	}
@@ -468,8 +466,8 @@ int hostap_set_antsel(local_info_t *local)
 
 		if (local->func->cmd(local->dev, HFA384X_CMDCODE_WRITEMIF,
 				     HFA386X_CR_RX_CONFIGURE, &val, NULL)) {
-			printk(KERN_INFO "%s: setting RX AntSel failed\n",
-			       local->dev->name);
+			pr_info("%s: setting RX AntSel failed\n",
+				local->dev->name);
 			ret = -1;
 		}
 	}
@@ -512,8 +510,8 @@ int hostap_set_auth_algs(local_info_t *local)
 		val = PRISM2_AUTH_OPEN;
 
 	if (hostap_set_word(local->dev, HFA384X_RID_CNFAUTHENTICATION, val)) {
-		printk(KERN_INFO "%s: cnfAuthentication setting to 0x%x "
-		       "failed\n", local->dev->name, local->auth_algs);
+		pr_info("%s: cnfAuthentication setting to 0x%x failed\n",
+			local->dev->name, local->auth_algs);
 		return -EINVAL;
 	}
 
@@ -527,28 +525,24 @@ void hostap_dump_rx_header(const char *name, const struct hfa384x_rx_frame *rx)
 
 	status = __le16_to_cpu(rx->status);
 
-	printk(KERN_DEBUG "%s: RX status=0x%04x (port=%d, type=%d, "
-	       "fcserr=%d) silence=%d signal=%d rate=%d rxflow=%d; "
-	       "jiffies=%ld\n",
-	       name, status, (status >> 8) & 0x07, status >> 13, status & 1,
-	       rx->silence, rx->signal, rx->rate, rx->rxflow, jiffies);
+	pr_debug("%s: RX status=0x%04x (port=%d, type=%d, fcserr=%d) silence=%d signal=%d rate=%d rxflow=%d; jiffies=%ld\n",
+		 name, status, (status >> 8) & 0x07, status >> 13, status & 1,
+		 rx->silence, rx->signal, rx->rate, rx->rxflow, jiffies);
 
 	fc = __le16_to_cpu(rx->frame_control);
-	printk(KERN_DEBUG "   FC=0x%04x (type=%d:%d) dur=0x%04x seq=0x%04x "
-	       "data_len=%d%s%s\n",
-	       fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
-	       (fc & IEEE80211_FCTL_STYPE) >> 4,
-	       __le16_to_cpu(rx->duration_id), __le16_to_cpu(rx->seq_ctrl),
-	       __le16_to_cpu(rx->data_len),
-	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
-	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
-
-	printk(KERN_DEBUG "   A1=%pM A2=%pM A3=%pM A4=%pM\n",
-	       rx->addr1, rx->addr2, rx->addr3, rx->addr4);
-
-	printk(KERN_DEBUG "   dst=%pM src=%pM len=%d\n",
-	       rx->dst_addr, rx->src_addr,
-	       __be16_to_cpu(rx->len));
+	pr_debug("   FC=0x%04x (type=%d:%d) dur=0x%04x seq=0x%04x data_len=%d%s%s\n",
+		 fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
+		 (fc & IEEE80211_FCTL_STYPE) >> 4,
+		 __le16_to_cpu(rx->duration_id), __le16_to_cpu(rx->seq_ctrl),
+		 __le16_to_cpu(rx->data_len),
+		 fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
+		 fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
+
+	pr_debug("   A1=%pM A2=%pM A3=%pM A4=%pM\n",
+		 rx->addr1, rx->addr2, rx->addr3, rx->addr4);
+
+	pr_debug("   dst=%pM src=%pM len=%d\n",
+		 rx->dst_addr, rx->src_addr, __be16_to_cpu(rx->len));
 }
 
 
@@ -556,27 +550,24 @@ void hostap_dump_tx_header(const char *name, const struct hfa384x_tx_frame *tx)
 {
 	u16 fc;
 
-	printk(KERN_DEBUG "%s: TX status=0x%04x retry_count=%d tx_rate=%d "
-	       "tx_control=0x%04x; jiffies=%ld\n",
-	       name, __le16_to_cpu(tx->status), tx->retry_count, tx->tx_rate,
-	       __le16_to_cpu(tx->tx_control), jiffies);
+	pr_debug("%s: TX status=0x%04x retry_count=%d tx_rate=%d tx_control=0x%04x; jiffies=%ld\n",
+		 name, __le16_to_cpu(tx->status), tx->retry_count, tx->tx_rate,
+		 __le16_to_cpu(tx->tx_control), jiffies);
 
 	fc = __le16_to_cpu(tx->frame_control);
-	printk(KERN_DEBUG "   FC=0x%04x (type=%d:%d) dur=0x%04x seq=0x%04x "
-	       "data_len=%d%s%s\n",
-	       fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
-	       (fc & IEEE80211_FCTL_STYPE) >> 4,
-	       __le16_to_cpu(tx->duration_id), __le16_to_cpu(tx->seq_ctrl),
-	       __le16_to_cpu(tx->data_len),
-	       fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
-	       fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
-
-	printk(KERN_DEBUG "   A1=%pM A2=%pM A3=%pM A4=%pM\n",
-	       tx->addr1, tx->addr2, tx->addr3, tx->addr4);
-
-	printk(KERN_DEBUG "   dst=%pM src=%pM len=%d\n",
-	       tx->dst_addr, tx->src_addr,
-	       __be16_to_cpu(tx->len));
+	pr_debug("   FC=0x%04x (type=%d:%d) dur=0x%04x seq=0x%04x data_len=%d%s%s\n",
+		 fc, (fc & IEEE80211_FCTL_FTYPE) >> 2,
+		 (fc & IEEE80211_FCTL_STYPE) >> 4,
+		 __le16_to_cpu(tx->duration_id), __le16_to_cpu(tx->seq_ctrl),
+		 __le16_to_cpu(tx->data_len),
+		 fc & IEEE80211_FCTL_TODS ? " [ToDS]" : "",
+		 fc & IEEE80211_FCTL_FROMDS ? " [FromDS]" : "");
+
+	pr_debug("   A1=%pM A2=%pM A3=%pM A4=%pM\n",
+		 tx->addr1, tx->addr2, tx->addr3, tx->addr4);
+
+	pr_debug("   dst=%pM src=%pM len=%d\n",
+		 tx->dst_addr, tx->src_addr, __be16_to_cpu(tx->len));
 }
 
 
@@ -665,8 +656,8 @@ static int prism2_open(struct net_device *dev)
 	local = iface->local;
 
 	if (local->no_pri) {
-		printk(KERN_DEBUG "%s: could not set interface UP - no PRI "
-		       "f/w\n", dev->name);
+		pr_debug("%s: could not set interface UP - no PRI f/w\n",
+			 dev->name);
 		return 1;
 	}
 
@@ -679,8 +670,7 @@ static int prism2_open(struct net_device *dev)
 	local->num_dev_open++;
 
 	if (!local->dev_enabled && local->func->hw_enable(dev, 1)) {
-		printk(KERN_WARNING "%s: could not enable MAC port\n",
-		       dev->name);
+		pr_warn("%s: could not enable MAC port\n", dev->name);
 		prism2_close(dev);
 		return 1;
 	}
@@ -738,8 +728,8 @@ void hostap_set_multicast_list_queue(struct work_struct *work)
 
 	if (hostap_set_word(dev, HFA384X_RID_PROMISCUOUSMODE,
 			    local->is_promisc)) {
-		printk(KERN_INFO "%s: %sabling promiscuous mode failed\n",
-		       dev->name, local->is_promisc ? "en" : "dis");
+		pr_info("%s: %sabling promiscuous mode failed\n",
+			dev->name, local->is_promisc ? "en" : "dis");
 	}
 }
 
@@ -786,14 +776,13 @@ static void prism2_tx_timeout(struct net_device *dev)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
-	printk(KERN_WARNING "%s Tx timed out! Resetting card\n", dev->name);
+	pr_warn("%s Tx timed out! Resetting card\n", dev->name);
 	netif_stop_queue(local->dev);
 
 	local->func->read_regs(dev, &regs);
-	printk(KERN_DEBUG "%s: CMD=%04x EVSTAT=%04x "
-	       "OFFSET0=%04x OFFSET1=%04x SWSUPPORT0=%04x\n",
-	       dev->name, regs.cmd, regs.evstat, regs.offset0, regs.offset1,
-	       regs.swsupport0);
+	pr_debug("%s: CMD=%04x EVSTAT=%04x OFFSET0=%04x OFFSET1=%04x SWSUPPORT0=%04x\n",
+		 dev->name, regs.cmd, regs.evstat, regs.offset0, regs.offset1,
+		 regs.swsupport0);
 
 	local->func->schedule_reset(local);
 }
@@ -895,7 +884,7 @@ static int hostap_enable_hostapd(local_info_t *local, int rtnl_locked)
 	if (local->apdev)
 		return -EEXIST;
 
-	printk(KERN_DEBUG "%s: enabling hostapd mode\n", dev->name);
+	pr_debug("%s: enabling hostapd mode\n", dev->name);
 
 	local->apdev = hostap_add_interface(local, HOSTAP_INTERFACE_AP,
 					    rtnl_locked, local->ddev->name,
@@ -911,7 +900,7 @@ static int hostap_disable_hostapd(local_info_t *local, int rtnl_locked)
 {
 	struct net_device *dev = local->dev;
 
-	printk(KERN_DEBUG "%s: disabling hostapd mode\n", dev->name);
+	pr_debug("%s: disabling hostapd mode\n", dev->name);
 
 	hostap_remove_interface(local->apdev, rtnl_locked, 1);
 	local->apdev = NULL;
@@ -927,7 +916,7 @@ static int hostap_enable_hostapd_sta(local_info_t *local, int rtnl_locked)
 	if (local->stadev)
 		return -EEXIST;
 
-	printk(KERN_DEBUG "%s: enabling hostapd STA mode\n", dev->name);
+	pr_debug("%s: enabling hostapd STA mode\n", dev->name);
 
 	local->stadev = hostap_add_interface(local, HOSTAP_INTERFACE_STA,
 					     rtnl_locked, local->ddev->name,
@@ -943,7 +932,7 @@ static int hostap_disable_hostapd_sta(local_info_t *local, int rtnl_locked)
 {
 	struct net_device *dev = local->dev;
 
-	printk(KERN_DEBUG "%s: disabling hostapd mode\n", dev->name);
+	pr_debug("%s: disabling hostapd mode\n", dev->name);
 
 	hostap_remove_interface(local->stadev, rtnl_locked, 1);
 	local->stadev = NULL;
@@ -1103,8 +1092,7 @@ static int __init hostap_init(void)
 	if (init_net.proc_net != NULL) {
 		hostap_proc = proc_mkdir("hostap", init_net.proc_net);
 		if (!hostap_proc)
-			printk(KERN_WARNING "Failed to mkdir "
-			       "/proc/net/hostap\n");
+			pr_warn("Failed to mkdir /proc/net/hostap\n");
 	} else
 		hostap_proc = NULL;
 
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 05ca340..e5bd77e 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -4,6 +4,8 @@
  * driver patches from Reyk Floeter <reyk@vantronix.net> and
  * Andy Warner <andyw@pobox.com> */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/if.h>
@@ -20,10 +22,6 @@
 
 #include "hostap_wlan.h"
 
-
-static char *dev_info = "hostap_pci";
-
-
 MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Support for Intersil Prism2.5-based 802.11 wireless LAN "
 		   "PCI cards.");
@@ -226,7 +224,7 @@ static void prism2_pci_cor_sreset(local_info_t *local)
 	u16 reg;
 
 	reg = HFA384X_INB(HFA384X_PCICOR_OFF);
-	printk(KERN_DEBUG "%s: Original COR value: 0x%0x\n", dev->name, reg);
+	pr_debug("%s: Original COR value: 0x%0x\n", dev->name, reg);
 
 	/* linux-wlan-ng uses extremely long hold and settle times for
 	 * COR sreset. A comment in the driver code mentions that the long
@@ -260,7 +258,7 @@ static void prism2_pci_cor_sreset(local_info_t *local)
 #endif /* PRISM2_PCI_USE_LONG_DELAYS */
 
 	if (HFA384X_INW(HFA384X_CMD_OFF) & HFA384X_CMD_BUSY) {
-		printk(KERN_DEBUG "%s: COR sreset timeout\n", dev->name);
+		pr_debug("%s: COR sreset timeout\n", dev->name);
 	}
 }
 
@@ -309,13 +307,13 @@ static int prism2_pci_probe(struct pci_dev *pdev,
 	phymem = pci_resource_start(pdev, 0);
 
 	if (!request_mem_region(phymem, pci_resource_len(pdev, 0), "Prism2")) {
-		printk(KERN_ERR "prism2: Cannot reserve PCI memory region\n");
+		pr_err("prism2: Cannot reserve PCI memory region\n");
 		goto err_out_disable;
 	}
 
 	mem = pci_ioremap_bar(pdev, 0);
 	if (mem == NULL) {
-		printk(KERN_ERR "prism2: Cannot remap PCI memory region\n") ;
+		pr_err("prism2: Cannot remap PCI memory region\n") ;
 		goto fail;
 	}
 
@@ -338,19 +336,18 @@ static int prism2_pci_probe(struct pci_dev *pdev,
 
 	if (request_irq(dev->irq, prism2_interrupt, IRQF_SHARED, dev->name,
 			dev)) {
-		printk(KERN_WARNING "%s: request_irq failed\n", dev->name);
+		pr_warn("%s: request_irq failed\n", dev->name);
 		goto fail;
 	} else
 		irq_registered = 1;
 
 	if (!local->pri_only && prism2_hw_config(dev, 1)) {
-		printk(KERN_DEBUG "%s: hardware initialization failed\n",
-		       dev_info);
+		pr_debug("hardware initialization failed\n");
 		goto fail;
 	}
 
-	printk(KERN_INFO "%s: Intersil Prism2.5 PCI: "
-	       "mem=0x%lx, irq=%d\n", dev->name, phymem, dev->irq);
+	pr_info("%s: Intersil Prism2.5 PCI: mem=0x%lx, irq=%d\n",
+		dev->name, phymem, dev->irq);
 
 	return hostap_hw_ready(dev);
 
@@ -428,8 +425,7 @@ static int prism2_pci_resume(struct pci_dev *pdev)
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
-		       dev->name);
+		pr_err("%s: pci_enable_device failed on resume\n", dev->name);
 		return err;
 	}
 	pci_restore_state(pdev);
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index c3d067e..4cf0cfa 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -6,6 +6,7 @@
  * - linux-wlan-ng driver, Copyright (C) AbsoluteValue Systems, Inc.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/init.h>
@@ -23,10 +24,6 @@
 
 #include "hostap_wlan.h"
 
-
-static char *dev_info = "hostap_plx";
-
-
 MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Support for Intersil Prism2-based 802.11 wireless LAN "
 		   "cards (PLX).");
@@ -269,8 +266,7 @@ static void prism2_plx_cor_sreset(local_info_t *local)
 	unsigned char corsave;
 	struct hostap_plx_priv *hw_priv = local->hw_priv;
 
-	printk(KERN_DEBUG "%s: Doing reset via direct COR access.\n",
-	       dev_info);
+	pr_debug("Doing reset via direct COR access\n");
 
 	/* Set sreset bit of COR and clear it after hold time */
 
@@ -352,8 +348,8 @@ static int prism2_plx_check_cis(void __iomem *attr_mem, int attr_len,
 	/* read CIS; it is in even offsets in the beginning of attr_mem */
 	for (i = 0; i < CIS_MAX_LEN; i++)
 		cis[i] = readb(attr_mem + 2 * i);
-	printk(KERN_DEBUG "%s: CIS: %02x %02x %02x %02x %02x %02x ...\n",
-	       dev_info, cis[0], cis[1], cis[2], cis[3], cis[4], cis[5]);
+	pr_debug("CIS: %02x %02x %02x %02x %02x %02x ...\n",
+		 cis[0], cis[1], cis[2], cis[3], cis[4], cis[5]);
 
 	/* set reasonable defaults for Prism2 cards just in case CIS parsing
 	 * fails */
@@ -378,12 +374,10 @@ static int prism2_plx_check_cis(void __iomem *attr_mem, int attr_len,
 			*cor_offset = 0;
 			for (i = 0; i <= rasz; i++)
 				*cor_offset += cis[pos + 4 + i] << (8 * i);
-			printk(KERN_DEBUG "%s: cor_index=0x%x "
-			       "cor_offset=0x%x\n", dev_info,
-			       *cor_index, *cor_offset);
+			pr_debug("cor_index=0x%x cor_offset=0x%x\n",
+				 *cor_index, *cor_offset);
 			if (*cor_offset > attr_len) {
-				printk(KERN_ERR "%s: COR offset not within "
-				       "attr_mem\n", dev_info);
+				pr_err("COR offset not within attr_mem\n");
 				kfree(cis);
 				return -1;
 			}
@@ -394,8 +388,7 @@ static int prism2_plx_check_cis(void __iomem *attr_mem, int attr_len,
 				goto cis_error;
 			manfid1 = cis[pos + 2] + (cis[pos + 3] << 8);
 			manfid2 = cis[pos + 4] + (cis[pos + 5] << 8);
-			printk(KERN_DEBUG "%s: manfid=0x%04x, 0x%04x\n",
-			       dev_info, manfid1, manfid2);
+			pr_debug("manfid=0x%04x, 0x%04x\n", manfid1, manfid2);
 			break;
 		}
 
@@ -411,18 +404,17 @@ static int prism2_plx_check_cis(void __iomem *attr_mem, int attr_len,
 			return 0;
 		}
 
-	printk(KERN_INFO "%s: unknown manfid 0x%04x, 0x%04x - assuming this is"
-	       " not supported card\n", dev_info, manfid1, manfid2);
+	pr_info("unknown manfid 0x%04x, 0x%04x - assuming this is not supported card\n",
+		manfid1, manfid2);
 	goto fail;
 
  cis_error:
-	printk(KERN_WARNING "%s: invalid CIS data\n", dev_info);
+	pr_warn("invalid CIS data\n");
 
  fail:
 	kfree(cis);
 	if (ignore_cis) {
-		printk(KERN_INFO "%s: ignore_cis parameter set - ignoring "
-		       "errors during CIS verification\n", dev_info);
+		pr_info("ignore_cis parameter set - ignoring errors during CIS verification\n");
 		return 0;
 	}
 	return -1;
@@ -463,9 +455,8 @@ static int prism2_plx_probe(struct pci_dev *pdev,
 		/* TMD7160 */
 		attr_mem = NULL; /* no access to PC Card attribute memory */
 
-		printk(KERN_INFO "TMD7160 PCI/PCMCIA adapter: io=0x%x, "
-		       "irq=%d, pccard_io=0x%x\n",
-		       plx_ioaddr, pdev->irq, pccard_ioaddr);
+		pr_info("TMD7160 PCI/PCMCIA adapter: io=0x%x, irq=%d, pccard_io=0x%x\n",
+			plx_ioaddr, pdev->irq, pccard_ioaddr);
 
 		cor_offset = plx_ioaddr;
 		cor_index = 0x04;
@@ -474,8 +465,7 @@ static int prism2_plx_probe(struct pci_dev *pdev,
 		mdelay(1);
 		reg = inb(plx_ioaddr);
 		if (reg != (cor_index | COR_LEVLREQ | COR_ENABLE_FUNC)) {
-			printk(KERN_ERR "%s: Error setting COR (expected="
-			       "0x%02x, was=0x%02x)\n", dev_info,
+			pr_err("Error setting COR (expected=0x%02x, was=0x%02x)\n",
 			       cor_index | COR_LEVLREQ | COR_ENABLE_FUNC, reg);
 			goto fail;
 		}
@@ -489,24 +479,20 @@ static int prism2_plx_probe(struct pci_dev *pdev,
 
 		attr_mem = ioremap(pccard_attr_mem, pccard_attr_len);
 		if (attr_mem == NULL) {
-			printk(KERN_ERR "%s: cannot remap attr_mem\n",
-			       dev_info);
+			pr_err("cannot remap attr_mem\n");
 			goto fail;
 		}
 
-		printk(KERN_INFO "PLX9052 PCI/PCMCIA adapter: "
-		       "mem=0x%lx, plx_io=0x%x, irq=%d, pccard_io=0x%x\n",
-		       pccard_attr_mem, plx_ioaddr, pdev->irq, pccard_ioaddr);
+		pr_info("PLX9052 PCI/PCMCIA adapter: mem=0x%lx, plx_io=0x%x, irq=%d, pccard_io=0x%x\n",
+			pccard_attr_mem, plx_ioaddr, pdev->irq, pccard_ioaddr);
 
 		if (prism2_plx_check_cis(attr_mem, pccard_attr_len,
 					 &cor_offset, &cor_index)) {
-			printk(KERN_INFO "Unknown PC Card CIS - not a "
-			       "Prism2/2.5 card?\n");
+			pr_info("Unknown PC Card CIS - not a Prism2/2.5 card?\n");
 			goto fail;
 		}
 
-		printk(KERN_DEBUG "Prism2/2.5 PC Card detected in PLX9052 "
-		       "adapter\n");
+		pr_debug("Prism2/2.5 PC Card detected in PLX9052 adapter\n");
 
 		/* Write COR to enable PC Card */
 		writeb(cor_index | COR_LEVLREQ | COR_ENABLE_FUNC,
@@ -514,22 +500,20 @@ static int prism2_plx_probe(struct pci_dev *pdev,
 
 		/* Enable PCI interrupts if they are not already enabled */
 		reg = inl(plx_ioaddr + PLX_INTCSR);
-		printk(KERN_DEBUG "PLX_INTCSR=0x%x\n", reg);
+		pr_debug("PLX_INTCSR=0x%x\n", reg);
 		if (!(reg & PLX_INTCSR_PCI_INTEN)) {
 			outl(reg | PLX_INTCSR_PCI_INTEN,
 			     plx_ioaddr + PLX_INTCSR);
 			if (!(inl(plx_ioaddr + PLX_INTCSR) &
 			      PLX_INTCSR_PCI_INTEN)) {
-				printk(KERN_WARNING "%s: Could not enable "
-				       "Local Interrupts\n", dev_info);
+				pr_warn("Could not enable Local Interrupts\n");
 				goto fail;
 			}
 		}
 
 		reg = inl(plx_ioaddr + PLX_CNTRL);
-		printk(KERN_DEBUG "PLX_CNTRL=0x%x (Serial EEPROM "
-		       "present=%d)\n",
-		       reg, (reg & PLX_CNTRL_SERIAL_EEPROM_PRESENT) != 0);
+		pr_debug("PLX_CNTRL=0x%x (Serial EEPROM present=%d)\n",
+			 reg, (reg & PLX_CNTRL_SERIAL_EEPROM_PRESENT) != 0);
 		/* should set PLX_PCIIPR to 0x01 (INTA#) if Serial EEPROM is
 		 * not present; but are there really such cards in use(?) */
 	}
@@ -552,14 +536,13 @@ static int prism2_plx_probe(struct pci_dev *pdev,
 
 	if (request_irq(dev->irq, prism2_interrupt, IRQF_SHARED, dev->name,
 			dev)) {
-		printk(KERN_WARNING "%s: request_irq failed\n", dev->name);
+		pr_warn("%s: request_irq failed\n", dev->name);
 		goto fail;
 	} else
 		irq_registered = 1;
 
 	if (prism2_hw_config(dev, 1)) {
-		printk(KERN_DEBUG "%s: hardware initialization failed\n",
-		       dev_info);
+		pr_debug("hardware initialization failed\n");
 		goto fail;
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/hostap/hostap_proc.c
index 75ef8f0..eb4bab5 100644
--- a/drivers/net/wireless/hostap/hostap_proc.c
+++ b/drivers/net/wireless/hostap/hostap_proc.c
@@ -1,5 +1,7 @@
 /* /proc routines for Host AP driver */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/proc_fs.h>
 #include <linux/export.h>
@@ -123,8 +125,8 @@ static int prism2_wds_proc_read(char *page, char **start, off_t off,
 			     iface->dev->name,
 			     iface->u.wds.remote_addr);
 		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "%s: wds proc did not fit\n",
-			       local->dev->name);
+			pr_debug("%s: wds proc did not fit\n",
+				 local->dev->name);
 			break;
 		}
 	}
@@ -178,8 +180,8 @@ static int prism2_bss_list_proc_read(char *page, char **start, off_t off,
 		}
 		p += sprintf(p, "\n");
 		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "%s: BSS proc did not fit\n",
-			       local->dev->name);
+			pr_debug("%s: BSS proc did not fit\n",
+				 local->dev->name);
 			break;
 		}
 	}
@@ -391,15 +393,15 @@ void hostap_init_proc(local_info_t *local)
 	local->proc = NULL;
 
 	if (hostap_proc == NULL) {
-		printk(KERN_WARNING "%s: hostap proc directory not created\n",
-		       local->dev->name);
+		pr_warn("%s: hostap proc directory not created\n",
+			local->dev->name);
 		return;
 	}
 
 	local->proc = proc_mkdir(local->ddev->name, hostap_proc);
 	if (local->proc == NULL) {
-		printk(KERN_INFO "/proc/net/hostap/%s creation failed\n",
-		       local->ddev->name);
+		pr_info("/proc/net/hostap/%s creation failed\n",
+			local->ddev->name);
 		return;
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 7bb0b4b..738adc7 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -946,15 +946,17 @@ struct hostap_skb_tx_data {
 #define DEBUG_EXTRA2 BIT(6)
 #define DEBUG_PS2 BIT(7)
 #define DEBUG_MASK (DEBUG_PS | DEBUG_AP | DEBUG_HW | DEBUG_EXTRA)
-#define PDEBUG(n, args...) \
-do { if ((n) & DEBUG_MASK) printk(KERN_DEBUG args); } while (0)
-#define PDEBUG2(n, args...) \
-do { if ((n) & DEBUG_MASK) printk(args); } while (0)
+#define PDEBUG(n, fmt, ...)						\
+	do { if ((n) & DEBUG_MASK) pr_debug(fmt, ##__VA_ARGS__); } while (0)
+#define PDEBUG2(n, fmt, ...)						\
+	do { if ((n) & DEBUG_MASK) printk(fmt, ##__VA_ARGS__); } while (0)
 
 #else /* PRISM2_NO_DEBUG */
 
-#define PDEBUG(n, args...)
-#define PDEBUG2(n, args...)
+#define PDEBUG(n, fmt, ...)
+	do { if (0) pr_debug(fmt, ##__VA_ARGS__); } while (0)
+#define PDEBUG2(n, fmt, ...)
+	do { if (0) printk(fmt, ##__VA_ARGS__); } while (0)
 
 #endif /* PRISM2_NO_DEBUG */
 
@@ -1006,7 +1008,7 @@ static inline void prism2_io_debug_error(struct net_device *dev, int err)
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_ERROR, 0, err);
 	if (local->io_debug_enabled == 1) {
 		local->io_debug_enabled = 0;
-		printk(KERN_DEBUG "%s: I/O debug stopped\n", dev->name);
+		pr_debug("%s: I/O debug stopped\n", dev->name);
 	}
 	spin_unlock_irqrestore(&local->lock, flags);
 }
-- 
1.7.8.111.gad25c.dirty
