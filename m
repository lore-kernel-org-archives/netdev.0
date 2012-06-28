From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 3/4] tcp: use inet6_csk_route_req() in tcp_v6_send_synack()
Date: Thu, 28 Jun 2012 15:34:20 -0700
Message-ID: <1340922861-11684-3-git-send-email-ncardwell@google.com>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:37791 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab2F1Xph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:45:37 -0400
Received: by qabg24 with SMTP id g24so68366qab.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 16:45:36 -0700 (PDT)
In-Reply-To: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent change (earlier in this patch series) to set
flowi6_oif to treq->iif in inet6_csk_route_req(), the dst lookup in
these two functions is now identical, so tcp_v6_send_synack() can now
just call inet6_csk_route_req(), to reduce code duplication and keep
things closer to the IPv4 side, which is structured this way.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c |   29 ++++++-----------------------
 1 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3b79e94..c221086 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -485,34 +485,17 @@ static int tcp_v6_send_synack(struct sock *sk,
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
-	struct ipv6_txoptions *opt = NULL;
-	struct in6_addr * final_p, final;
+	struct ipv6_txoptions *opt = np->opt;
 	struct flowi6 fl6;
 	struct dst_entry *dst;
-	int err;
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.daddr = treq->rmt_addr;
-	fl6.saddr = treq->loc_addr;
-	fl6.flowlabel = 0;
-	fl6.flowi6_oif = treq->iif;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_dport = inet_rsk(req)->rmt_port;
-	fl6.fl6_sport = inet_rsk(req)->loc_port;
-	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
-
-	opt = np->opt;
-	final_p = fl6_update_dst(&fl6, opt, &final);
+	int err = -ENOMEM;
 
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
-		dst = NULL;
+	dst = inet6_csk_route_req(sk, &fl6, req);
+	if (!dst)
 		goto done;
-	}
+
 	skb = tcp_make_synack(sk, dst, req, rvp);
-	err = -ENOMEM;
+
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
-- 
1.7.4.1
