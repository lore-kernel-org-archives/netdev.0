From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 4/4] tcp: plug dst leak in tcp_v6_conn_request()
Date: Thu, 28 Jun 2012 15:34:21 -0700
Message-ID: <1340922861-11684-4-git-send-email-ncardwell@google.com>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:50146 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab2F1Xpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:45:46 -0400
Received: by vcbfl13 with SMTP id fl13so270997vcb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 16:45:45 -0700 (PDT)
In-Reply-To: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in tcp_v6_conn_request() was implicitly assuming that
tcp_v6_send_synack() would take care of dst_release(), much as
tcp_v4_send_synack() already does. This resulted in
tcp_v6_conn_request() leaking a dst if sysctl_tw_recycle is enabled.

This commit restructures tcp_v6_send_synack() so that it accepts a dst
pointer and takes care of releasing the dst that is passed in, to plug
the leak and avoid future surprises by bringing the IPv6 behavior in
line with the IPv4 side.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c221086..5edabf6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -477,7 +477,8 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk,
+static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
+			      struct flowi6 *fl6,
 			      struct request_sock *req,
 			      struct request_values *rvp,
 			      u16 queue_mapping)
@@ -486,12 +487,10 @@ static int tcp_v6_send_synack(struct sock *sk,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
 	struct ipv6_txoptions *opt = np->opt;
-	struct flowi6 fl6;
-	struct dst_entry *dst;
 	int err = -ENOMEM;
 
-	dst = inet6_csk_route_req(sk, &fl6, req);
-	if (!dst)
+	/* First, grab a route. */
+	if (!dst && (dst = inet6_csk_route_req(sk, fl6, req)) == NULL)
 		goto done;
 
 	skb = tcp_make_synack(sk, dst, req, rvp);
@@ -499,9 +498,9 @@ static int tcp_v6_send_synack(struct sock *sk,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
-		fl6.daddr = treq->rmt_addr;
+		fl6->daddr = treq->rmt_addr;
 		skb_set_queue_mapping(skb, queue_mapping);
-		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
@@ -514,8 +513,10 @@ done:
 static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
 			     struct request_values *rvp)
 {
+	struct flowi6 fl6;
+
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v6_send_synack(sk, req, rvp, 0);
+	return tcp_v6_send_synack(sk, NULL, &fl6, req, rvp, 0);
 }
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
@@ -1200,7 +1201,7 @@ have_isn:
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req,
+	if (tcp_v6_send_synack(sk, dst, &fl6, req,
 			       (struct request_values *)&tmp_ext,
 			       skb_get_queue_mapping(skb)) ||
 	    want_cookie)
-- 
1.7.4.1
