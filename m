From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 2/2] d80211: Add software sequence support
Date: Sat, 3 Feb 2007 12:45:26 +0100
Message-ID: <200702031245.27035.IvDoorn@gmail.com>
References: <200701312016.52221.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:30069 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423086AbXBCLpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 06:45:47 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1541902nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 03:45:45 -0800 (PST)
In-Reply-To: <200701312016.52221.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 January 2007 20:16, Ivo van Doorn wrote:
> Most hardware can keep track of sequence numbers themselves,
> unfortunately *most* doesn't cover all devices. ;)
> This patch will keep track of the sequence number if the flag
> IEEE80211_HW_SOFTWARE_SEQUENCE has been set.
> 
> Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

Previous version had a small bug in it.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 dscape/include/net/d80211.h dscape_seq/include/net/d80211.h
--- dscape/include/net/d80211.h	2007-01-31 19:38:14.000000000 +0100
+++ dscape_seq/include/net/d80211.h	2007-01-31 19:55:55.000000000 +0100
@@ -534,6 +534,9 @@
 	/* Does the device need the stack to create a RTS frame */
 #define IEEE80211_HW_SOFTWARE_RTS (1<<15)
 
+	/* Does the HOST need to insert the frame sequence counter */
+#define IEEE80211_HW_SOFTWARE_SEQUENCE (1<<16)
+
 	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
diff -rNU3 dscape/net/d80211/ieee80211.c dscape_seq/net/d80211/ieee80211.c
--- dscape/net/d80211/ieee80211.c	2007-01-31 19:41:18.000000000 +0100
+++ dscape_seq/net/d80211/ieee80211.c	2007-02-03 12:42:25.000000000 +0100
@@ -441,6 +441,7 @@
 	size_t hdrlen, per_fragm, num_fragm, payload_len, left;
 	struct sk_buff **frags, *first, *frag;
 	int i;
+	u16 seq;
         u8 *pos;
 	int frag_threshold = tx->local->fragmentation_threshold;
 
@@ -458,6 +459,7 @@
 	if (!frags)
 		goto fail;
 
+	seq = le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ;
 	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREFRAGS);
 	pos = first->data + hdrlen + per_fragm;
 	left = payload_len - per_fragm;
@@ -486,7 +488,7 @@
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
 			fhdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREFRAGS);
-		fhdr->seq_ctrl = cpu_to_le16(i + 1);
+		fhdr->seq_ctrl = cpu_to_le16(seq + ((i + 1) & IEEE80211_SCTL_FRAG));
 		copylen = left > per_fragm ? per_fragm : left;
 		memcpy(skb_put(frag, copylen), pos, copylen);
 
@@ -933,6 +935,17 @@
 	return TXRX_CONTINUE;
 }
 
+static ieee80211_txrx_result
+ieee80211_tx_h_sequence(struct ieee80211_txrx_data *tx)
+{
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)tx->skb->data;
+
+	if ((tx->local->hw.flags & IEEE80211_HW_SOFTWARE_SEQUENCE) &&
+	    ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_control)) > 24)
+		ieee80211_include_sequence(tx->local, hdr);
+
+	return TXRX_CONTINUE;
+}
 
 /* This function is called whenever the AP is about to exceed the maximum limit
  * of buffered frames for power saving STAs. This situation should not really
@@ -1806,6 +1819,10 @@
 
 	memcpy(skb_put(skb, bh_len), b_head, bh_len);
 
+	if (hw->flags & IEEE80211_HW_SOFTWARE_SEQUENCE)
+		ieee80211_include_sequence(local,
+			(struct ieee80211_hdr *)skb->data);
+
 	ieee80211_beacon_add_tim(local, ap, skb);
 
 	if (b_tail) {
@@ -4323,6 +4340,7 @@
 static ieee80211_tx_handler ieee80211_tx_handlers[] =
 {
 	ieee80211_tx_h_check_assoc,
+	ieee80211_tx_h_sequence,
 	ieee80211_tx_h_ps_buf,
 	ieee80211_tx_h_select_key,
 	ieee80211_tx_h_michael_mic_add,
@@ -4497,6 +4515,7 @@
 
 	local->bridge_packets = 1;
 
+	local->seq_counter = 0;
 	local->rts_threshold = IEEE80211_MAX_RTS_THRESHOLD;
 	local->fragmentation_threshold = IEEE80211_MAX_FRAG_THRESHOLD;
 	local->short_retry_limit = 7;
diff -rNU3 dscape/net/d80211/ieee80211_i.h dscape_seq/net/d80211/ieee80211_i.h
--- dscape/net/d80211/ieee80211_i.h	2007-01-31 19:41:53.000000000 +0100
+++ dscape_seq/net/d80211/ieee80211_i.h	2007-01-31 20:06:26.000000000 +0100
@@ -405,6 +405,7 @@
 	int *supp_rates[NUM_IEEE80211_MODES];
 	int *basic_rates[NUM_IEEE80211_MODES];
 
+	u16 seq_counter;
 	int rts_threshold;
 	int cts_protect_erp_frames;
 	int fragmentation_threshold;
@@ -601,6 +602,20 @@
 	spin_unlock_bh(&local->sta_lock);
 }
 
+static inline void ieee80211_include_sequence(struct ieee80211_local *local,
+					      struct ieee80211_hdr *hdr)
+{
+	/*
+	 * Set the sequence number for this frame.
+	 */
+	hdr->seq_ctrl = cpu_to_le16(local->seq_counter & IEEE80211_SCTL_SEQ);
+
+	/*
+	 * Increase the sequence number.
+	 */
+	local->seq_counter = (local->seq_counter + 0x10) & IEEE80211_SCTL_SEQ;
+}
+
 /* ieee80211.c */
 void ieee80211_release_hw(struct ieee80211_local *local);
 int ieee80211_hw_config(struct ieee80211_local *local);
