From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH v2] ipv4: Use newinet->inet_opt in inet_csk_route_child_sock()
Date: Mon, 20 Aug 2012 14:52:09 +0200
Message-ID: <1345467129-4540-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36066 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874Ab2HTMwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 08:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 0e734419923bd ("ipv4: Use inet_csk_route_child_sock() in DCCP and
TCP."), inet_csk_route_child_sock() is called instead of
inet_csk_route_req().

However, after creating the child-sock in tcp/dccp_v4_syn_recv_sock(),
ireq->opt is set to NULL, before calling inet_csk_route_child_sock().
Thus, inside inet_csk_route_child_sock() opt is always NULL and the
SRR-options are not respected anymore.
Packets sent by the server won't have the correct destination-IP.

This patch fixes it by accessing newinet->inet_opt instead of ireq->opt
inside inet_csk_route_child_sock().

Reported-by: Luca Boccassi <luca.boccassi@gmail.com>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
v2:
	* Added rcu_read_(un)lock()
	* Fixed typo in the patch-subject
	* Added "Reported-by"
---
 net/ipv4/inet_connection_sock.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index db0cf17..7f75f21 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -404,12 +404,15 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct inet_sock *newinet = inet_sk(newsk);
-	struct ip_options_rcu *opt = ireq->opt;
+	struct ip_options_rcu *opt;
 	struct net *net = sock_net(sk);
 	struct flowi4 *fl4;
 	struct rtable *rt;
 
 	fl4 = &newinet->cork.fl.u.ip4;
+
+	rcu_read_lock();
+	opt = rcu_dereference(newinet->inet_opt);
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
@@ -421,11 +424,13 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 		goto no_route;
 	if (opt && opt->opt.is_strictroute && rt->rt_gateway)
 		goto route_err;
+	rcu_read_unlock();
 	return &rt->dst;
 
 route_err:
 	ip_rt_put(rt);
 no_route:
+	rcu_read_unlock();
 	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
-- 
1.7.9.5
