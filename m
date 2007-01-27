From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Sat, 27 Jan 2007 18:49:49 +0200
Message-ID: <20070127164949.GC4829@galon.ev-en.org>
References: <20070127164702.GA4829@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:54598
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbXA0Qtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 11:49:50 -0500
Content-Disposition: inline
In-Reply-To: <20070127164702.GA4829@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move DSACK code outside the SACK fast-path checking code. If the DSACK
determined that the information was too old we stayed with a partial cache
copied. Most likely this matters very little since the next packet will not be
DSACK and we will find it in the cache. but it's still not good form and there
is little reason to couple the two checks.

Since the SACK receive cache doesn't need the data to be in host order we also
remove the ntohl in the checking loop.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6-rc6/net/ipv4/tcp_input.c
===================================================================
--- 2.6-rc6.orig/net/ipv4/tcp_input.c	2007-01-27 15:06:30.000000000 +0200
+++ 2.6-rc6/net/ipv4/tcp_input.c	2007-01-27 15:59:15.000000000 +0200
@@ -948,16 +948,43 @@
 		tp->fackets_out = 0;
 	prior_fackets = tp->fackets_out;
 
+	/* Check for D-SACK. */
+	if (before(ntohl(sp[0].start_seq), TCP_SKB_CB(ack_skb)->ack_seq)) {
+		dup_sack = 1;
+		tp->rx_opt.sack_ok |= 4;
+		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+	} else if (num_sacks > 1 &&
+			!after(ntohl(sp[0].end_seq), ntohl(sp[1].end_seq)) &&
+			!before(ntohl(sp[0].start_seq), ntohl(sp[1].start_seq))) {
+		dup_sack = 1;
+		tp->rx_opt.sack_ok |= 4;
+		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+	}
+
+	/* D-SACK for already forgotten data...
+	 * Do dumb counting. */
+	if (dup_sack &&
+			!after(ntohl(sp[0].end_seq), prior_snd_una) &&
+			after(ntohl(sp[0].end_seq), tp->undo_marker))
+		tp->undo_retrans--;
+
+	/* Eliminate too old ACKs, but take into
+	 * account more or less fresh ones, they can
+	 * contain valid SACK info.
+	 */
+	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
+		return 0;
+
 	/* SACK fastpath:
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
 	 * and use retrans queue hinting otherwise slowpath */
 	flag = 1;
-	for (i = 0; i< num_sacks; i++) {
-		__u32 start_seq = ntohl(sp[i].start_seq);
-		__u32 end_seq =	 ntohl(sp[i].end_seq);
+	for (i = 0; i < num_sacks; i++) {
+		__u32 start_seq = sp[i].start_seq;
+		__u32 end_seq = sp[i].end_seq;
 
-		if (i == 0){
+		if (i == 0) {
 			if (tp->recv_sack_cache[i].start_seq != start_seq)
 				flag = 0;
 		} else {
@@ -967,37 +994,6 @@
 		}
 		tp->recv_sack_cache[i].start_seq = start_seq;
 		tp->recv_sack_cache[i].end_seq = end_seq;
-
-		/* Check for D-SACK. */
-		if (i == 0) {
-			u32 ack = TCP_SKB_CB(ack_skb)->ack_seq;
-
-			if (before(start_seq, ack)) {
-				dup_sack = 1;
-				tp->rx_opt.sack_ok |= 4;
-				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
-			} else if (num_sacks > 1 &&
-				   !after(end_seq, ntohl(sp[1].end_seq)) &&
-				   !before(start_seq, ntohl(sp[1].start_seq))) {
-				dup_sack = 1;
-				tp->rx_opt.sack_ok |= 4;
-				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
-			}
-
-			/* D-SACK for already forgotten data...
-			 * Do dumb counting. */
-			if (dup_sack &&
-			    !after(end_seq, prior_snd_una) &&
-			    after(end_seq, tp->undo_marker))
-				tp->undo_retrans--;
-
-			/* Eliminate too old ACKs, but take into
-			 * account more or less fresh ones, they can
-			 * contain valid SACK info.
-			 */
-			if (before(ack, prior_snd_una - tp->max_window))
-				return 0;
-		}
 	}
 
 	if (flag)
