From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_make_synack() consumes dst parameter
Date: Mon, 04 Jun 2012 08:33:21 +0200
Message-ID: <1338791601.2760.1725.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:43567 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab2FDGdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 02:33:25 -0400
Received: by wgbds11 with SMTP id ds11so2126707wgb.1
        for <netdev@vger.kernel.org>; Sun, 03 Jun 2012 23:33:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_make_synack() clones the dst, and callers release it.

We can avoid two atomic operations per SYNACK if tcp_make_synack()
consumes dst instead of cloning it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
To be applied after "tcp: tcp_make_synack() can use alloc_skb()"

 net/ipv4/tcp_ipv4.c   |    1 -
 net/ipv4/tcp_output.c |   18 ++++++++++++++----
 net/ipv6/tcp_ipv6.c   |    1 -
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c8d28c4..3d9c1a4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -848,7 +848,6 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 		err = net_xmit_eval(err);
 	}
 
-	dst_release(dst);
 	return err;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f0b0e44..c465d3e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2442,7 +2442,16 @@ int tcp_send_synack(struct sock *sk)
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
 
-/* Prepare a SYN-ACK. */
+/**
+ * tcp_make_synack - Prepare a SYN-ACK.
+ * sk: listener socket
+ * dst: dst entry attached to the SYNACK
+ * req: request_sock pointer
+ * rvp: request_values pointer
+ *
+ * Allocate one skb and build a SYNACK packet.
+ * @dst is consumed : Caller should not use it again.
+ */
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct request_values *rvp)
@@ -2462,13 +2471,14 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
 	skb = alloc_skb(MAX_TCP_HEADER + 15 + s_data_desired, GFP_ATOMIC);
-	if (skb == NULL)
+	if (unlikely(!skb)) {
+		dst_release(dst);
 		return NULL;
-
+	}
 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
 
-	skb_dst_set(skb, dst_clone(dst));
+	skb_dst_set(skb, dst);
 
 	mss = dst_metric_advmss(dst);
 	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3a9aec2..8075825 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -522,7 +522,6 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 done:
 	if (opt && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
-	dst_release(dst);
 	return err;
 }
 
