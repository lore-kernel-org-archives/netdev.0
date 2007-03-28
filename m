From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Extract out DSACK detection logic
Date: Wed, 28 Mar 2007 16:30:28 -0700 (PDT)
Message-ID: <20070328.163028.58455314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933860AbXC1Xa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 19:30:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EAEF0AE41A5
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 16:30:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm about to reattempt the hacks to make tcp_sacktag_write_queue()
use the RB tree lookups.

In order to make the changes easier to review I'm trying to clean
up the function a little bit.  This one pulls out the DSACK
detection logic.

I'm starting to pepper get_unaligned() calls around the sack
block accesses as I've been getting a few of these in my logs
on sparc64 lately:

[68089.285478] Kernel unaligned access at TPC[60e3c4] tcp_sacktag_write_queue+0x40/0x86c

it's pretty easy to make it happen with NOP TCP options and
stuff like that, and we have get_unaligned() calls for other
TCP options already.

Pushed to net-2.6.22

commit d9367183d9d8fd1853e3bc4d0b1af077553e0e8a
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Mar 28 16:27:47 2007 -0700

    [TCP]: Extract DSACK detection code from tcp_sacktag_write_queue().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c855791..a5a8987 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -936,6 +936,39 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
  * Both of these heuristics are not used in Loss state, when we cannot
  * account for retransmits accurately.
  */
+static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
+			   struct tcp_sack_block_wire *sp, int num_sacks,
+			   u32 prior_snd_una)
+{
+	u32 start_seq_0 = ntohl(get_unaligned(&sp[0].start_seq));
+	u32 end_seq_0 = ntohl(get_unaligned(&sp[0].end_seq));
+	int dup_sack = 0;
+
+	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
+		dup_sack = 1;
+		tp->rx_opt.sack_ok |= 4;
+		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+	} else if (num_sacks > 1) {
+		u32 end_seq_1 = ntohl(get_unaligned(&sp[1].end_seq));
+		u32 start_seq_1 = ntohl(get_unaligned(&sp[1].start_seq));
+
+		if (!after(end_seq_0, end_seq_1) &&
+		    !before(start_seq_0, start_seq_1)) {
+			dup_sack = 1;
+			tp->rx_opt.sack_ok |= 4;
+			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+		}
+	}
+
+	/* D-SACK for already forgotten data... Do dumb counting. */
+	if (dup_sack &&
+	    !after(end_seq_0, prior_snd_una) &&
+	    after(end_seq_0, tp->undo_marker))
+		tp->undo_retrans--;
+
+	return dup_sack;
+}
+
 static int
 tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 			u32 prior_snd_una, u32 *mark_lost_entry_seq)
@@ -963,25 +996,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 		*mark_lost_entry_seq = tp->highest_sack;
 	prior_fackets = tp->fackets_out;
 
-	/* Check for D-SACK. */
-	if (before(ntohl(sp[0].start_seq), TCP_SKB_CB(ack_skb)->ack_seq)) {
-		dup_sack = 1;
-		tp->rx_opt.sack_ok |= 4;
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
-	} else if (num_sacks > 1 &&
-			!after(ntohl(sp[0].end_seq), ntohl(sp[1].end_seq)) &&
-			!before(ntohl(sp[0].start_seq), ntohl(sp[1].start_seq))) {
-		dup_sack = 1;
-		tp->rx_opt.sack_ok |= 4;
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
-	}
-
-	/* D-SACK for already forgotten data...
-	 * Do dumb counting. */
-	if (dup_sack &&
-			!after(ntohl(sp[0].end_seq), prior_snd_una) &&
-			after(ntohl(sp[0].end_seq), tp->undo_marker))
-		tp->undo_retrans--;
+	dup_sack = tcp_check_dsack(tp, ack_skb, sp, num_sacks, prior_snd_una);
 
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
