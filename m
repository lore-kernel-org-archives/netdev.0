From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 3/5] Implement TFRC-SP calc of mean length of loss intervals,
 accordingly to section 3 of RFC 4828
Date: Tue, 08 Sep 2009 15:28:51 -0300
Message-ID: <4AA6A263.8000106@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedded.ufcg.edu.br ([150.165.63.2]:18705 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbZIHS2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 14:28:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement TFRC-SP calc of mean length of loss intervals accordingly to section 3 of RFC 4828

Changes:
 - Modify tfrc_sp_lh_calc_i_mean header, now receiving the current ccval, so it can determine
   if a loss interval is too recent
 - Consider number of losses in each loss interval
 - Only consider open loss interval if it is at least 2 rtt old
 - Changes function signatures as necessary

Signed-off-by: Ivo Calado, Erivaldo Xavier, Leandro Sales <ivocalado@embedded.ufcg.edu.br>, <desadoc@gmail.com>, <leandroal@gmail.com>

Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c
===================================================================
--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 10:37:16.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c	2009-09-08 10:42:30.000000000 -0300
@@ -67,10 +67,11 @@
 		}
 }
 
-static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_ccval)
 {
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
 	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
+	u32 losses;
 
 	if (k <= 0)
 		return;
@@ -78,6 +79,15 @@
 	for (i = 0; i <= k; i++) {
 		i_i = tfrc_lh_get_interval(lh, i);
 
+		if (SUB16(curr_ccval,
+		    tfrc_lh_get_loss_interval(lh, i)->li_ccval) <= 8) {
+
+			losses = tfrc_lh_get_loss_interval(lh, i)->li_losses;
+
+			if (losses > 0)
+				i_i = div64_u64(i_i, losses);
+		}
+
 		if (i < k) {
 			i_tot0 += i_i * tfrc_lh_weights[i];
 			w_tot  += tfrc_lh_weights[i];
@@ -87,6 +97,11 @@
 	}
 
 	lh->i_mean = max(i_tot0, i_tot1) / w_tot;
+	BUG_ON(w_tot == 0);
+	if (SUB16(curr_ccval, tfrc_lh_get_loss_interval(lh, 0)->li_ccval) > 8)
+		lh->i_mean = max(i_tot0, i_tot1) / w_tot;
+	else
+		lh->i_mean = i_tot1 / w_tot;
 }
 
 /*
@@ -127,7 +142,7 @@
 		return;
 
 	cur->li_length = len;
-	tfrc_sp_lh_calc_i_mean(lh);
+	tfrc_sp_lh_calc_i_mean(lh, dccp_hdr(skb)->dccph_ccval);
 }
 
 /* RFC 4342, 10.2: test for the existence of packet with sequence number S */
@@ -148,7 +163,8 @@
 bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *lh,
 			     struct tfrc_rx_hist *rh,
 			     u32 (*calc_first_li)(struct sock *),
-			     struct sock *sk)
+			     struct sock *sk,
+			     __u8 ccval)
 {
 	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh);
 	struct tfrc_rx_hist_entry *cong_evt;
@@ -217,7 +233,7 @@
 		if (lh->counter > (2*LIH_SIZE))
 			lh->counter -= LIH_SIZE;
 
-		tfrc_sp_lh_calc_i_mean(lh);
+		tfrc_sp_lh_calc_i_mean(lh, ccval);
 	}
 
 	return true;
Index: dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
===================================================================
--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:37:16.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h	2009-09-08 10:42:30.000000000 -0300
@@ -73,7 +73,8 @@
 extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *,
 				    struct tfrc_rx_hist *,
 				    u32 (*first_li)(struct sock *),
-				    struct sock *);
+				    struct sock *,
+				    __u8 ccval);
 extern void tfrc_sp_lh_update_i_mean(struct tfrc_loss_hist *lh,
 				     struct sk_buff *);
 extern void tfrc_sp_lh_cleanup(struct tfrc_loss_hist *lh);
Index: dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c
===================================================================
--- dccp_tree_work5.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:37:16.000000000 -0300
+++ dccp_tree_work5/net/dccp/ccids/lib/packet_history_sp.c	2009-09-08 10:42:30.000000000 -0300
@@ -369,7 +369,8 @@
 		/*
 		* Update Loss Interval database and recycle RX records
 		*/
-		new_event = tfrc_sp_lh_interval_add(lh, h, first_li, sk);
+		new_event = tfrc_sp_lh_interval_add(lh, h, first_li, sk,
+						dccp_hdr(skb)->dccph_ccval);
 		__three_after_loss(h);
 
 	} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(skb)) {
@@ -378,7 +379,8 @@
 		* the RFC considers ECN marks - a future implementation may
 		* find it useful to also check ECN marks on non-data packets.
 		*/
-		new_event = tfrc_sp_lh_interval_add(lh, h, first_li, sk);
+		new_event = tfrc_sp_lh_interval_add(lh, h, first_li, sk,
+						dccp_hdr(skb)->dccph_ccval);
 		/*
 		* Also combinations of loss and ECN-marks (as per the warning)
 		* are not supported. The permutations of loss combined with or


