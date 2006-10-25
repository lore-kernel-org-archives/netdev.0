From: Hong Liu <hong.liu@intel.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Wed, 25 Oct 2006 16:28:10 +0800
Message-ID: <1161764889.8668.13.camel@devlinux-hong>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>  <1161681021.2840.23.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33891 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1423114AbWJYIfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 04:35:07 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161681021.2840.23.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 17:10, Johannes Berg wrote:
> On Tue, 2006-10-24 at 16:38 +0800, Hong Liu wrote:
> 
> > The first time when we set the TKIP key, we can set the phase1 key if
> > the driver requires.
> 
> Right.
> 
> > The problem is when IV16 wraps, who will generate the new phase1 key?
> 
> Ok, I was confused for a moment, but yes, when the 16-bit part of the IV
> wraps then the upper part changes and hence you need to regenerate the
> phase1 key.
> 
> > If the stack need to do this, then we will need to call set_key in the
> > packet TX path which I think may not be appropriate.
> 
> Well, I checked again and found that bcm34xx requires the IV (48) to be
> maintained by software, iow with each packet you tell the hardware what
> the IV16 should be. Hence you know when it has wrapped and thus (before
> submitting the DMA for the packet) you can regenerate the phase1 key in
> software and upload it to the hardware key memory.
> 
> This is getting quite complicated. How about having the stack maintain
> the IV *only*, and adding helper functions for
>  * generating the phase 1 key
>  * generating the phase 2 key based on the phase 1 key
> that the drivers can use as required?
> 
> ipw3945 would call both key generation functions as required, and
> bcm43xx would just call the phase 1 function when a key is uploaded and
> when the iv16 wraps, not using the phase 2 function at all.
> 
> johannes
> 
> 

I'd prefer to let the stack tell the driver when there is new phase1 key
generated.
Rebase the patch on David Kimdon's bitfield removing patches.


Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 812f2d1..2570072 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -159,6 +159,7 @@ #define IEEE80211_TXCTL_CLEAR_DST_MASK	(
 #define IEEE80211_TXCTL_REQUEUE		(1<<7)
 #define IEEE80211_TXCTL_FIRST_FRAGMENT	(1<<8) /* this is a first fragment of
 						* the frame */
+#define IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY (1<<9)
 	u16 flags;			       /* tx control flags defined
 						* above */
 	u16 rts_cts_duration;	/* duration field for RTS/CTS frame */
@@ -169,6 +170,8 @@ #define IEEE80211_TXCTL_FIRST_FRAGMENT	(
 				 * hw->set_key() */
 	u8 icv_len;		/* length of the ICV/MIC field in octets */
 	u8 iv_len;		/* length of the IV field in octets */
+	u8 tkip_keylen;
+	u8 tkip_key[16];/* generated RC4/phase1 key for hw TKIP */
 	u8 queue;		/* hardware queue to use for this frame;
 				 * 0 = highest, hw->queues-1 = lowest */
 	u8 sw_retry_attempt;	/* number of times hw has tried to
@@ -487,6 +490,15 @@ #define IEEE80211_HW_MONITOR_DURING_OPER
 	 * i.e. more than one skb per frame */
 #define IEEE80211_HW_FRAGLIST (1<<11)
 
+	/* calculate Michael MIC for an MSDU when doing hwcrypto */
+#define IEEE80211_HW_TKIP_INCLUDE_MMIC (1<<12)
+	/* Do TKIP phase1 key mixing in stack to support cards only do
+	 * phase2 key mixing when doing hwcrypto */
+#define IEEE80211_HW_TKIP_REQ_PHASE1_KEY (1<<13)
+	/* Do TKIP phase1 and phase2 key mixing in stack and send the generated
+	 * per-packet RC4 key with each TX frame when doing hwcrypto */
+#define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
+
 	u32 flags;			/* hardware flags defined above */
 
         /* This is the time in us to change channels
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index 7e3665a..fd02449 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -190,17 +190,16 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
 	return pos;
 }
 
-
-/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
- * beginning of the buffer containing payload. This payload must include
- * headroom of eight octets for IV and Ext. IV and taildroom of four octets
- * for ICV. @payload_len is the length of payload (_not_ including extra
- * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
-				 u8 *pos, size_t payload_len, u8 *ta)
+void ieee80211_tkip_gen_phase1key(struct ieee80211_key *key, u8 *ta,
+				  u16 *phase1key)
 {
-	u8 rc4key[16];
+	tkip_mixing_phase1(ta, &key->key[ALG_TKIP_TEMP_ENCR_KEY],
+			   key->u.tkip.iv32, phase1key);
+}
 
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key, u8 *ta,
+			       u8 *rc4key)
+{
 	/* Calculate per-packet key */
 	if (key->u.tkip.iv16 == 0 || !key->u.tkip.tx_initialized) {
 		/* IV16 wrapped around - perform TKIP phase 1 */
@@ -211,7 +210,19 @@ void ieee80211_tkip_encrypt_data(struct 
 
 	tkip_mixing_phase2(key->u.tkip.p1k, &key->key[ALG_TKIP_TEMP_ENCR_KEY],
 			   key->u.tkip.iv16, rc4key);
+}
+
+/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
+ * beginning of the buffer containing payload. This payload must include
+ * headroom of eight octets for IV and Ext. IV and taildroom of four octets
+ * for ICV. @payload_len is the length of payload (_not_ including extra
+ * headroom and tailroom). @ta is the transmitter addresses. */
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				 u8 *pos, size_t payload_len, u8 *ta)
+{
+	u8 rc4key[16];
 
+	ieee80211_tkip_gen_rc4key(key, ta, rc4key);
 	pos = ieee80211_tkip_add_iv(pos, key, rc4key[0], rc4key[1], rc4key[2]);
 	ieee80211_wep_encrypt_data(tfm, rc4key, 16, pos, payload_len);
 }
diff --git a/net/d80211/tkip.h b/net/d80211/tkip.h
index e36b85c..9b22717 100644
--- a/net/d80211/tkip.h
+++ b/net/d80211/tkip.h
@@ -15,6 +15,10 @@ #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
 			   u8 iv0, u8 iv1, u8 iv2);
+void ieee80211_tkip_gen_phase1key(struct ieee80211_key *key, u8 *ta,
+				  u16 *phase1key);
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key, u8 *ta,
+			       u8 *rc4key);
 void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta);
 enum {
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index e6ea53e..bb325bf 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -105,7 +105,9 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt &&
 	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
-	    !tx->fragmented && !wpa_test) {
+	    !tx->fragmented &&
+	    !(tx->local->hw->flags & IEEE80211_HW_TKIP_INCLUDE_MMIC) &&
+	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
 		return TXRX_CONTINUE;
@@ -332,14 +334,34 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	    && !tx->wpa_test
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 		) {
-		/* hwaccel - with preallocated room for IV */
+		u32 flags = tx->local->hw->flags;
+		hdr = (struct ieee80211_hdr *)skb->data;
 
+		/* hwaccel - with preallocated room for IV */
 		ieee80211_tkip_add_iv(pos, key,
 				      (u8) (key->u.tkip.iv16 >> 8),
 				      (u8) (((key->u.tkip.iv16 >> 8) | 0x20) &
 					    0x7f),
 				      (u8) key->u.tkip.iv16);
 
+		if (flags & IEEE80211_HW_TKIP_REQ_PHASE1_KEY) {
+			if (key->u.tkip.iv16 == 0 ||
+			    !key->u.tkip.tx_initialized) {
+				ieee80211_tkip_gen_phase1key(key, hdr->addr2,
+					    (u16 *)tx->u.tx.control->tkip_key);
+				key->u.tkip.tx_initialized = 1;
+				tx->u.tx.control->flags |=
+					    IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
+				tx->u.tx.control->tkip_keylen = 10;
+			} else
+				tx->u.tx.control->flags &=
+					    ~IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
+		} else if (flags & IEEE80211_HW_TKIP_REQ_PHASE2_KEY) {
+			ieee80211_tkip_gen_rc4key(key, hdr->addr2,
+						  tx->u.tx.control->tkip_key);
+			tx->u.tx.control->tkip_keylen = 16;
+		}
+
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		return 0;
 	}
