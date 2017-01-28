From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 2/2] tcp: include locally failed retries in retransmission stats
Date: Fri, 27 Jan 2017 16:24:39 -0800
Message-ID: <20170128002439.128487-2-ycheng@google.com>
References: <20170128002439.128487-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34177 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdA1AYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 19:24:50 -0500
Received: by mail-pf0-f176.google.com with SMTP id e4so76373478pfg.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 16:24:49 -0800 (PST)
In-Reply-To: <20170128002439.128487-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the retransmission stats are not incremented if the
retransmit fails locally. But we always increment the other packet
counters that track total packet/bytes sent.  Awkwardly while we
don't count these failed retransmits in RETRANSSEGS, we do count
them in FAILEDRETRANS.

If the qdisc is dropping many packets this could under-estimate
TCP retransmission rate substantially from both SNMP or per-socket
TCP_INFO stats. This patch changes this by always incrementing
retransmission stats on retransmission attempts and failures.

Another motivation is to properly track retransmists in
SCM_TIMESTAMPING_OPT_STATS. Since SCM_TSTAMP_SCHED collection is
triggered in tcp_transmit_skb(), If tp->total_retrans is incremented
after the function, we'll always mis-count by the amount of the
latest retransmission.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 671c69535671..7b2d8762f15f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2771,6 +2771,13 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 	if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN_ECN) == TCPHDR_SYN_ECN)
 		tcp_ecn_clear_syn(sk, skb);
 
+	/* Update global and local TCP statistics. */
+	segs = tcp_skb_pcount(skb);
+	TCP_ADD_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS, segs);
+	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
+		__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
+	tp->total_retrans += segs;
+
 	/* make sure skb->data is aligned on arches that require it
 	 * and check if ack-trimming & collapsing extended the headroom
 	 * beyond what csum_start can cover.
@@ -2788,14 +2795,9 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 	}
 
 	if (likely(!err)) {
-		segs = tcp_skb_pcount(skb);
-
 		TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
-		/* Update global TCP statistics. */
-		TCP_ADD_STATS(sock_net(sk), TCP_MIB_RETRANSSEGS, segs);
-		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
-			__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
-		tp->total_retrans += segs;
+	} else if (err != -EBUSY) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
 	return err;
 }
@@ -2818,8 +2820,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 		if (!tp->retrans_stamp)
 			tp->retrans_stamp = tcp_skb_timestamp(skb);
 
-	} else if (err != -EBUSY) {
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPRETRANSFAIL);
 	}
 
 	if (tp->undo_retrans < 0)
-- 
2.11.0.483.g087da7b7c-goog
