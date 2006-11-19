From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 8/13] d80211: introduce IEEE80211_HW_FRAG flag
Date: Sun, 19 Nov 2006 20:29:48 +0100
Message-ID: <1163964588.15473.55.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63157 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933062AbWKSTb5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:31:57 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This introduces the promised IEEE80211_HW_FRAG used to determine whether the
hardware can do fragmentation or not.

It actually makes sense to split this capability flag out from the function
pointer, maybe some hardware wants to be notified about the fragmentation
threshold even though it doesn't do fragmentation itself.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 20:13:59.349275208 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 20:14:00.039275208 +0100
@@ -505,6 +505,9 @@ struct ieee80211_hw {
 	 * per-packet RC4 key with each TX frame when doing hwcrypto */
 #define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
 
+	/* do hardware fragmentation */
+#define IEEE80211_HW_FRAG (1<<15)
+
 	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
@@ -658,8 +661,6 @@ struct ieee80211_ops {
 	int (*set_rts_threshold)(struct ieee80211_hw *hw, u32 value);
 
 	/* Configuration of fragmentation threshold (if device needs it) */
-	/* FIXME: if this is set, then d80211 will never do fragmentation!
-	 * hence, this really needs to be a flag in _hw!! */
 	int (*set_frag_threshold)(struct ieee80211_hw *hw, u32 value);
 
 	/* Configuration of retry limits (if device needs it) */
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:13:59.359275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:14:00.039275208 +0100
@@ -1079,7 +1079,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + FCS_LEN > local->fragmentation_threshold &&
-		(!local->ops->set_frag_threshold);
+		(!(local->wiphy.flags & IEEE80211_HW_FRAG));
 	if (!tx->sta)
 		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	else if (tx->sta->clear_dst_mask) {


