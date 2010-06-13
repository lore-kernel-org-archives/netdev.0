From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next-2.6] ipv6: syncookies: do not skip ->iif initialization
Date: Sun, 13 Jun 2010 23:29:39 +0200
Message-ID: <1276464579-4399-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Glenn Griffin <ggriffin.kernel@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:35603 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752936Ab0FMVbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 17:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When syncookies are in effect, req->iif is left uninitialized.
In case of e.g. link-local addresses the route lookup then fails
and no syn-ack is sent.

Rearrange things so ->iif is also initialized in the syncookie case.

want_cookie can only be true when the isn was zero, thus move the want_cookie
check into the "!isn" branch.

Cc: Glenn Griffin <ggriffin.kernel@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/tcp_ipv6.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5887141..f875345 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1272,10 +1272,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
-	if (want_cookie) {
-		isn = cookie_v6_init_sequence(sk, skb, &req->mss);
-		req->cookie_ts = tmp_opt.tstamp_ok;
-	} else if (!isn) {
+	if (!isn) {
 		if (ipv6_opt_accepted(sk, skb) ||
 		    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 		    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
@@ -1288,8 +1285,12 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (!sk->sk_bound_dev_if &&
 		    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
 			treq->iif = inet6_iif(skb);
-
-		isn = tcp_v6_init_sequence(skb);
+		if (!want_cookie) {
+			isn = tcp_v6_init_sequence(skb);
+		} else {
+			isn = cookie_v6_init_sequence(sk, skb, &req->mss);
+			req->cookie_ts = tmp_opt.tstamp_ok;
+		}
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-- 
1.6.4.4

