From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 11:13:54 -0400
Message-ID: <20070501151354.GB1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:34987 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbXEAPOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 11:14:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

While testing a failover scenario, I managed to trigger an ack storm 
between a Linux box and another system.  Although the cause of this particular 
ACK storm was due to the other box forgetting that it sent out a FIN (the 
second node was unaware of the FIN the first sent in its dying gasp, which 
is what I'm trying to fix, but it's a tricky race), the resulting Linux 
behaviour wasn't very robust.  Is there any particularly good reason that 
FIN flag gets cleared on a connection which is being shut down?  The trace 
that motivates this can be seen at 
http://www.kvack.org/~bcrl/ack-storm.log .  As near as I can tell, a 
similar effect can occur between two Linux boxes if the right packets get 
reordered/dropped during connection teardown.

		-ben

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0faacf9..1e54291 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -635,9 +635,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	TCP_SKB_CB(buff)->end_seq = TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(buff)->seq;
 
-	/* PSH and FIN should only be set in the second packet. */
+	/* PSH should only be set in the second packet. */
 	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_PSH);
 	TCP_SKB_CB(buff)->flags = flags;
 	TCP_SKB_CB(buff)->sacked = TCP_SKB_CB(skb)->sacked;
 	TCP_SKB_CB(skb)->sacked &= ~TCPCB_AT_TAIL;
@@ -1124,9 +1124,9 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 	TCP_SKB_CB(buff)->end_seq = TCP_SKB_CB(skb)->end_seq;
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(buff)->seq;
 
-	/* PSH and FIN should only be set in the second packet. */
+	/* PSH should only be set in the second packet. */
 	flags = TCP_SKB_CB(skb)->flags;
-	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_PSH);
 	TCP_SKB_CB(buff)->flags = flags;
 
 	/* This packet was never sent out yet, so no SACK bits. */
@@ -1308,7 +1308,7 @@ static int tcp_mtu_probe(struct sock *sk)
 			sk_stream_free_skb(sk, skb);
 		} else {
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
-						   ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
+						   ~(TCPCB_FLAG_PSH);
 			if (!skb_shinfo(skb)->nr_frags) {
 				skb_pull(skb, copy);
 				if (skb->ip_summed != CHECKSUM_PARTIAL)
