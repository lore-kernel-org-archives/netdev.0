From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 5/5] tcp: plug dst leak in tcp_v6_conn_request()
Date: Sun, 24 Jun 2012 01:22:04 -0400
Message-ID: <1340515324-2152-5-git-send-email-ncardwell@google.com>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:34024 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab2FXF3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 01:29:31 -0400
Received: by bkty5 with SMTP id y5so173134bkt.1
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 22:29:30 -0700 (PDT)
In-Reply-To: <1340515324-2152-1-git-send-email-ncardwell@google.com>
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
index 500a296..846fe80 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -475,7 +475,8 @@ out:
 }
 
 
-static int tcp_v6_send_synack(struct sock *sk,
+static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
+			      struct flowi6 *fl6,
 			      struct request_sock *req,
 			      struct request_values *rvp,
 			      u16 queue_mapping)
@@ -484,12 +485,10 @@ static int tcp_v6_send_synack(struct sock *sk,
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
@@ -497,9 +496,9 @@ static int tcp_v6_send_synack(struct sock *sk,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
-		fl6.daddr = treq->rmt_addr;
+		fl6->daddr = treq->rmt_addr;
 		skb_set_queue_mapping(skb, queue_mapping);
-		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
@@ -513,8 +512,10 @@ done:
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
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_release;
 
-	if (tcp_v6_send_synack(sk, req,
+	if (tcp_v6_send_synack(sk, dst, &fl6, req,
 			       (struct request_values *)&tmp_ext,
 			       skb_get_queue_mapping(skb)) ||
 	    want_cookie)
-- 
1.7.7.3
