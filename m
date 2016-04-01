From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v2 net-next 3/8] tcp: use one bit in TCP_SKB_CB to mark ACK timestamps
Date: Fri,  1 Apr 2016 11:04:35 -0400
Message-ID: <1459523080-29329-4-git-send-email-soheil.kdev@gmail.com>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33442 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbcDAPEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:04:45 -0400
Received: by mail-qk0-f196.google.com with SMTP id q184so4712834qkb.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:04:44 -0700 (PDT)
In-Reply-To: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Currently, to avoid a cache line miss for accessing skb_shinfo,
tcp_ack_tstamp skips socket that do not have
SOF_TIMESTAMPING_TX_ACK bit set in sk_tsflags. This is
implemented based on an implicit assumption that the
SOF_TIMESTAMPING_TX_ACK is set via socket options for the
duration that ACK timestamps are needed.

To implement per-write timestamps, this check should be
removed and replaced with a per-packet alternative that
quickly skips packets missing ACK timestamps marks without
a cache-line miss.

To enable per-packet marking without a cache line miss, use
one bit in TCP_SKB_CB to mark a whether a SKB might need a
ack tx timestamp or not. Further checks in tcp_ack_tstamp are not
modified and work as before.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>
---
 include/net/tcp.h    | 3 ++-
 net/ipv4/tcp.c       | 2 ++
 net/ipv4/tcp_input.c | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b91370f..f3a80ec 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -754,7 +754,8 @@ struct tcp_skb_cb {
 				TCPCB_REPAIRED)
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
-	/* 1 byte hole */
+	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
+			unused:7;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 08b8b96..ce3c9eb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -432,10 +432,12 @@ static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
 {
 	if (sk->sk_tsflags) {
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
+		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 		sock_tx_timestamp(sk, &shinfo->tx_flags);
 		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
 			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
+		tcb->txstamp_ack = !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
 	}
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e6e65f7..2d5fee4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3093,7 +3093,7 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
 	const struct skb_shared_info *shinfo;
 
 	/* Avoid cache line misses to get skb_shinfo() and shinfo->tx_flags */
-	if (likely(!(sk->sk_tsflags & SOF_TIMESTAMPING_TX_ACK)))
+	if (likely(!TCP_SKB_CB(skb)->txstamp_ack))
 		return;
 
 	shinfo = skb_shinfo(skb);
-- 
2.8.0.rc3.226.g39d4020
