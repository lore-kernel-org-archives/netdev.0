From: Shaohua Li <shli@kernel.org>
Subject: [RFC net 1/2] net: set skb hash for IP6 TCP reset packet
Date: Thu, 13 Jul 2017 10:56:57 -0700
Message-ID: <5595e60068d7c18c7f0749d8a355a008123ca0d8.1499967945.git.shli@fb.com>
References: <cover.1499967945.git.shli@fb.com>
Cc: eric.dumazet@gmail.com, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37462 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752677AbdGMR5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 13:57:16 -0400
In-Reply-To: <cover.1499967945.git.shli@fb.com>
In-Reply-To: <cover.1499967945.git.shli@fb.com>
References: <cover.1499967945.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

Please see below tcpdump output:
21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 3282214508, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wscale 7], length 0
21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 1923801573, ack 3282214509, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 2500903437,nop,wscale 7], length 0
21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31, ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 30
21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack 31, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 24
21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ack 25, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 0
21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ack 26, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.5555: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55, ack 26, win 342, options [nop,nop,TS val 2500904438 ecr 2500903438], length 24
21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-header TCP (6) payload length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.55804: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 1923801599, win 0, length 0

The tcp reset packet has a different flowlabel, which causes our router
doesn't correctly close tcp connection.  The reason is the normal packet
gets the skb->hash from sk->sk_txhash, which is generated randomly.
ip6_make_flowlabel then uses the hash to create a flowlabel. The reset
packet doesn't get assigned a hash, so the flowlabel is calculated with
flowi6.

The solution is to save the hash value for timeout sock and use it for
reset packet.

Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/net/inet_timewait_sock.h | 10 ++++++++++
 net/ipv4/inet_timewait_sock.c    |  1 +
 net/ipv6/tcp_ipv6.c              |  7 +++++++
 3 files changed, 18 insertions(+)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 6a75d67..b568224 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -77,6 +77,7 @@ struct inet_timewait_sock {
 				tw_pad		: 2,	/* 2 bits hole */
 				tw_tos		: 8;
 	kmemcheck_bitfield_end(flags);
+	__u32			tw_txhash;
 	struct timer_list	tw_timer;
 	struct inet_bind_bucket	*tw_tb;
 };
@@ -87,6 +88,15 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 	return (struct inet_timewait_sock *)sk;
 }
 
+static inline void skb_set_hash_from_twsk(struct sk_buff *skb,
+	struct inet_timewait_sock *twsk)
+{
+	if (twsk->tw_txhash) {
+		skb->l4_hash = 1;
+		skb->hash = twsk->tw_txhash;
+	}
+}
+
 void inet_twsk_free(struct inet_timewait_sock *tw);
 void inet_twsk_put(struct inet_timewait_sock *tw);
 
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 5b03915..6f460e7 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -190,6 +190,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 		twsk_net_set(tw, sock_net(sk));
 		setup_pinned_timer(&tw->tw_timer, tw_timer_handler,
 				   (unsigned long)tw);
+		tw->tw_txhash	   = sk->sk_txhash;
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
 		 * to a non null value before everything is setup for this
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2521690..2e656d2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -805,6 +805,13 @@ static void tcp_v6_send_response(const struct sock *sk, struct sk_buff *skb, u32
 	t1 = skb_push(buff, tot_len);
 	skb_reset_transport_header(buff);
 
+	if (sk) {
+		if (sk_fullsock(sk))
+			skb_set_hash_from_sk(buff, (struct sock *)sk);
+		else
+			skb_set_hash_from_twsk(buff, inet_twsk(sk));
+	}
+
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));
 	t1->dest = th->source;
-- 
2.9.3
