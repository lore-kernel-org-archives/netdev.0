From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 08:55:28 -0700
Message-ID: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35720 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbbEZPzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 11:55:31 -0400
Received: by iesa3 with SMTP id a3so95468929ies.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 08:55:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

By making sure sk->sk_gso_max_segs minimal value is one,
and sysctl_tcp_min_tso_segs minimal value is one as well,
tcp_tso_autosize() will return a non zero value.

We can then revert 843925f33fcc293d80acf2c5c8a78adf3344d49b
("tcp: Do not apply TSO segment limit to non-TSO packets")
and save few cpu cycles in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/sock.c            |    5 ++++-
 net/ipv4/sysctl_net_ipv4.c |    2 +-
 net/ipv4/tcp_output.c      |    4 ++--
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 29124fcdc42a6367c20aea2e2811ec4e72558d7e..e72633c346b197b9dd6c94800fa0c55110aedfb2 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1581,6 +1581,8 @@ EXPORT_SYMBOL_GPL(sk_clone_lock);
 
 void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
+	u32 max_segs = 1;
+
 	__sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
@@ -1592,9 +1594,10 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
 			sk->sk_gso_max_size = dst->dev->gso_max_size;
-			sk->sk_gso_max_segs = dst->dev->gso_max_segs;
+			max_segs = max_t(u32, dst->dev->gso_max_segs, 1);
 		}
 	}
+	sk->sk_gso_max_segs = max_segs;
 }
 EXPORT_SYMBOL_GPL(sk_setup_caps);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 841de32f1fee4e6faa55ebf855df7168ee996fc3..e64892769607a6089e10d5c9e63dc3564c983341 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -702,7 +702,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &gso_max_segs,
 	},
 	{
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 534e5fdb04c11152bae36f47a786e8b10b823cd3..190538a2a88ce061ca1352c6c993b7008e759a52 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2088,7 +2088,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
 			break;
 
-		if (tso_segs == 1 || !max_segs) {
+		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
 						     (tcp_skb_is_last(sk, skb) ?
 						      nonagle : TCP_NAGLE_PUSH))))
@@ -2101,7 +2101,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 
 		limit = mss_now;
-		if (tso_segs > 1 && max_segs && !tcp_urg_mode(tp))
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    min_t(unsigned int,
 							  cwnd_quota,
