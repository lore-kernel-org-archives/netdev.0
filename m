From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net] tcp/dccp: fix other lockdep splats accessing ireq_opt
Date: Tue, 24 Oct 2017 08:20:31 -0700
Message-ID: <1508858431.30291.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171023095634.lednbqrxtbuooqcx@inn>
         <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: kernel test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:46473 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932169AbdJXPUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 11:20:33 -0400
Received: by mail-pf0-f193.google.com with SMTP id p87so19912467pfj.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 08:20:33 -0700 (PDT)
In-Reply-To: <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In my first attempt to fix the lockdep splat, I forgot we could
enter inet_csk_route_req() with a freshly allocated request socket,
for which refcount has not yet been elevated, due to complex
SLAB_TYPESAFE_BY_RCU rules.

We either are in rcu_read_lock() section _or_ we own a refcount on the
request.

Correct RCU verb to use here is rcu_dereference_check(), although it is
not possible to prove we actually own a reference on a shared
refcount :/

In v2, I added ireq_opt_deref() helper and use in three places, to fix other
possible splats.

[   49.844590]  lockdep_rcu_suspicious+0xea/0xf3
[   49.846487]  inet_csk_route_req+0x53/0x14d
[   49.848334]  tcp_v4_route_req+0xe/0x10
[   49.850174]  tcp_conn_request+0x31c/0x6a0
[   49.851992]  ? __lock_acquire+0x614/0x822
[   49.854015]  tcp_v4_conn_request+0x5a/0x79
[   49.855957]  ? tcp_v4_conn_request+0x5a/0x79
[   49.858052]  tcp_rcv_state_process+0x98/0xdcc
[   49.859990]  ? sk_filter_trim_cap+0x2f6/0x307
[   49.862085]  tcp_v4_do_rcv+0xfc/0x145
[   49.864055]  ? tcp_v4_do_rcv+0xfc/0x145
[   49.866173]  tcp_v4_rcv+0x5ab/0xaf9
[   49.868029]  ip_local_deliver_finish+0x1af/0x2e7
[   49.870064]  ip_local_deliver+0x1b2/0x1c5
[   49.871775]  ? inet_del_offload+0x45/0x45
[   49.873916]  ip_rcv_finish+0x3f7/0x471
[   49.875476]  ip_rcv+0x3f1/0x42f
[   49.876991]  ? ip_local_deliver_finish+0x2e7/0x2e7
[   49.878791]  __netif_receive_skb_core+0x6d3/0x950
[   49.880701]  ? process_backlog+0x7e/0x216
[   49.882589]  __netif_receive_skb+0x1d/0x5e
[   49.884122]  process_backlog+0x10c/0x216
[   49.885812]  net_rx_action+0x147/0x3df

Fixes: a6ca7abe53633 ("tcp/dccp: fix lockdep splat in inet_csk_route_req()")
Fixes: c92e8c02fe66 ("tcp/dccp: fix ireq->opt races")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kernel test robot <fengguang.wu@intel.com>
Reported-by: Maciej Żenczykowski <maze@google.com>
---
v3: fix typo in predicate

 include/net/inet_sock.h         |    6 ++++++
 net/dccp/ipv4.c                 |    2 +-
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/tcp_ipv4.c             |    2 +-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 425752f768d2f1a0efb13964204e07f27609e9db..db8162dd8c0bcbcaffcb1a0f6da1be139a5008d4 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -132,6 +132,12 @@ static inline int inet_request_bound_dev_if(const struct sock *sk,
 	return sk->sk_bound_dev_if;
 }
 
+static inline struct ip_options_rcu *ireq_opt_deref(const struct inet_request_sock *ireq)
+{
+	return rcu_dereference_check(ireq->ireq_opt,
+				     refcount_read(&ireq->req.rsk_refcnt) > 0);
+}
+
 struct inet_cork {
 	unsigned int		flags;
 	__be32			addr;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 0490916864f93d5466e87f5b97dc524b3ee57a2e..e65fcb45c3f6c1edc70fc9898ebe6404175b102f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -495,7 +495,7 @@ static int dccp_v4_send_response(const struct sock *sk, struct request_sock *req
 							      ireq->ir_rmt_addr);
 		err = ip_build_and_send_pkt(skb, sk, ireq->ir_loc_addr,
 					    ireq->ir_rmt_addr,
-					    rcu_dereference(ireq->ireq_opt));
+					    ireq_opt_deref(ireq));
 		err = net_xmit_eval(err);
 	}
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 18cd2eae758ff1a9d8a736e143417c7007b99067..b47a59cb3573b3b77aa5cbb9c2739a12ef37a237 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -543,8 +543,8 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 	struct ip_options_rcu *opt;
 	struct rtable *rt;
 
-	opt = rcu_dereference_protected(ireq->ireq_opt,
-					refcount_read(&req->rsk_refcnt) > 0);
+	opt = ireq_opt_deref(ireq);
+
 	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4c43365c374c8bf868fc0b862333244ca26d5016..5b027c69cbc540d4e933189f9de5baab5472eadb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -877,7 +877,7 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 
 		err = ip_build_and_send_pkt(skb, sk, ireq->ir_loc_addr,
 					    ireq->ir_rmt_addr,
-					    rcu_dereference(ireq->ireq_opt));
+					    ireq_opt_deref(ireq));
 		err = net_xmit_eval(err);
 	}
 
