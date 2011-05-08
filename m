From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/15] ipv4: Create inet_csk_route_child_sock().
Date: Sun, 08 May 2011 15:37:47 -0700 (PDT)
Message-ID: <20110508.153747.260107635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755824Ab1EHWiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5935924C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is just like inet_csk_route_req() except that it operates after
we've created the new child socket.

In this way we can use the new socket's cork flow for proper route
key storage.

This will be used by DCCP and TCP child socket creation handling.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    3 +++
 net/ipv4/inet_connection_sock.c    |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 6ac4e3b..4367d91 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -250,6 +250,9 @@ extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 extern struct dst_entry* inet_csk_route_req(struct sock *sk,
 					    const struct request_sock *req);
+extern struct dst_entry* inet_csk_route_child_sock(struct sock *sk,
+						   struct sock *newsk,
+						   const struct request_sock *req);
 
 static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 					    struct request_sock *req,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 54944da..3a2ba56 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -379,6 +379,39 @@ no_route:
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
 
+struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
+					    struct sock *newsk,
+					    const struct request_sock *req)
+{
+	const struct inet_request_sock *ireq = inet_rsk(req);
+	struct inet_sock *newinet = inet_sk(newsk);
+	struct ip_options_rcu *opt = ireq->opt;
+	struct net *net = sock_net(sk);
+	struct flowi4 *fl4;
+	struct rtable *rt;
+
+	fl4 = &newinet->cork.fl.u.ip4;
+	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
+			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
+			   sk->sk_protocol, inet_sk_flowi_flags(sk),
+			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->rmt_addr,
+			   ireq->loc_addr, ireq->rmt_port, inet_sk(sk)->inet_sport);
+	security_req_classify_flow(req, flowi4_to_flowi(fl4));
+	rt = ip_route_output_flow(net, fl4, sk);
+	if (IS_ERR(rt))
+		goto no_route;
+	if (opt && opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
+		goto route_err;
+	return &rt->dst;
+
+route_err:
+	ip_rt_put(rt);
+no_route:
+	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(inet_csk_route_child_sock);
+
 static inline u32 inet_synq_hash(const __be32 raddr, const __be16 rport,
 				 const u32 rnd, const u32 synq_hsize)
 {
-- 
1.7.5.1

