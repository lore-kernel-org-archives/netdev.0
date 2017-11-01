From: Christoph Paasch <cpaasch@apple.com>
Subject: [PATCH net] tcp: Always cleanup skb before sending
Date: Wed, 01 Nov 2017 14:10:01 -0700
Message-ID: <20171101211001.57901-1-cpaasch@apple.com>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out2.apple.com ([17.151.62.25]:46287 "EHLO
        mail-in2.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933175AbdKAVJn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache
line misses") IPCB/IP6CB is no more at the beginning of the tcp_skb_cb.
This means that on the output path, we need to make sure that it has
been correctly initialized to 0, as is done in tcp_transmit_skb.

However, when going through the other code-path in TCP that can send an
skb (e.g., through tcp_v6_send_synack), we end up in a situation where
IP6CB has some of its fields set to unexpected values. Depending on the
layout of tcp_skb_cb across the different kernel-versions this can be
lastopt, flags,...

This patch makes sure that IPCB/IP6CB is always set to 0 before sending.

Cc: Eric Dumazet <edumazet@google.com>
Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
Signed-off-by: Christoph Paasch <cpaasch@apple.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_ipv4.c   |  6 ++++++
 net/ipv4/tcp_output.c | 20 ++++++++++++--------
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e6d0002a1b0b..a375ee8fc534 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2032,6 +2032,8 @@ static inline void tcp_listendrop(const struct sock *sk)
 
 enum hrtimer_restart tcp_pace_kick(struct hrtimer *timer);
 
+void tcp_skb_cleanup(struct sk_buff *skb);
+
 /*
  * Interface for adding Upper Level Protocols over TCP
  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5b027c69cbc5..db7dd65b1f19 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -709,6 +709,9 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 
 	arg.tos = ip_hdr(skb)->tos;
 	arg.uid = sock_net_uid(net, sk && sk_fullsock(sk) ? sk : NULL);
+
+	tcp_skb_cleanup(skb);
+
 	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
@@ -795,6 +798,9 @@ static void tcp_v4_send_ack(const struct sock *sk,
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
 	arg.uid = sock_net_uid(net, sk_fullsock(sk) ? sk : NULL);
+
+	tcp_skb_cleanup(skb);
+
 	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 823003eef3a2..6935a68d449b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -973,6 +973,16 @@ static void tcp_internal_pacing(struct sock *sk, const struct sk_buff *skb)
 		      HRTIMER_MODE_ABS_PINNED);
 }
 
+void tcp_skb_cleanup(struct sk_buff *skb)
+{
+	/* Our usage of tstamp should remain private */
+	skb->tstamp = 0;
+
+	/* Cleanup our debris for IP stacks */
+	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
+			       sizeof(struct inet6_skb_parm)));
+}
+
 /* This routine actually transmits TCP packets queued in by
  * tcp_do_sendmsg().  This is used by both the initial
  * transmission and possible later retransmissions.
@@ -1115,12 +1125,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	skb_shinfo(skb)->gso_segs = tcp_skb_pcount(skb);
 	skb_shinfo(skb)->gso_size = tcp_skb_mss(skb);
 
-	/* Our usage of tstamp should remain private */
-	skb->tstamp = 0;
-
-	/* Cleanup our debris for IP stacks */
-	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
-			       sizeof(struct inet6_skb_parm)));
+	tcp_skb_cleanup(skb);
 
 	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
 
@@ -3204,8 +3209,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	rcu_read_unlock();
 #endif
 
-	/* Do not fool tcpdump (if any), clean our debris */
-	skb->tstamp = 0;
+	tcp_skb_cleanup(skb);
 	return skb;
 }
 EXPORT_SYMBOL(tcp_make_synack);
-- 
2.14.1
