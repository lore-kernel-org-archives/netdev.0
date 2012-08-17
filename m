From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] ipv4: Use netinet->inet_opt in inet_csk_route_child_sock()
Date: Fri, 17 Aug 2012 23:35:12 +0200
Message-ID: <1345239312-19266-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:54373 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab2HQVfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 17:35:25 -0400
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

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/inet_connection_sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index db0cf17..f16bdc4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -404,7 +404,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct inet_sock *newinet = inet_sk(newsk);
-	struct ip_options_rcu *opt = ireq->opt;
+	struct ip_options_rcu *opt = rcu_dereference(newinet->inet_opt);
 	struct net *net = sock_net(sk);
 	struct flowi4 *fl4;
 	struct rtable *rt;
-- 
1.7.9.5
