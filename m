From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: factorize sk_txhash init
Date: Tue, 22 Sep 2015 20:44:17 -0700
Message-ID: <1442979857.29850.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442878107.29850.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36788 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934919AbbIWDoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 23:44:19 -0400
Received: by pacbt3 with SMTP id bt3so9467131pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 20:44:18 -0700 (PDT)
In-Reply-To: <1442878107.29850.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Neal suggested to move sk_txhash init into tcp_create_openreq_child(),
called both from IPv4 and IPv6.

This opportunity was missed in commit 58d607d3e52f ("tcp: provide
skb->hash to synack packets")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
v2: respin

 net/ipv4/tcp_ipv4.c      |    1 -
 net/ipv4/tcp_minisocks.c |    1 +
 net/ipv6/tcp_ipv6.c      |    2 --
 3 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d671d742a239..7e2646542312 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1276,7 +1276,6 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newinet->mc_index     = inet_iif(skb);
 	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
 	newinet->rcv_tos      = ip_hdr(skb)->tos;
-	newsk->sk_txhash      = tcp_rsk(req)->txhash;
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 10933d01b982..85830bb92d04 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -471,6 +471,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_enable_early_retrans(newtp);
 		newtp->tlp_high_seq = 0;
 		newtp->lsndtime = treq->snt_synack.stamp_jiffies;
+		newsk->sk_txhash = treq->txhash;
 		newtp->last_oow_ack_time = 0;
 		newtp->total_retrans = req->num_retrans;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f9c0e2640671..a004e0b0b3e9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1090,8 +1090,6 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
 	newsk->sk_bound_dev_if = ireq->ir_iif;
 
-	newsk->sk_txhash = tcp_rsk(req)->txhash;
-
 	/* Now IPv6 options...
 
 	   First: no IPv4 options.
