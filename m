From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] syncookies: free reqsk on xfrm_lookup error
Date: Mon, 28 Jul 2008 02:03:55 +0200
Message-ID: <1217203435-18351-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Glenn Griffin <ggriffin.kernel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41330 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750843AbYG0Xzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 19:55:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cookie_v6_check() did not call reqsk_free() if xfrm_lookup() fails,
leaking the request sock.

Compile tested only.

Cc: Glenn Griffin <ggriffin.kernel@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/syncookies.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index a46badd..ec394cf 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -199,10 +199,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq6 = inet6_rsk(req);
 	treq = tcp_rsk(req);
 
-	if (security_inet_conn_request(sk, skb, req)) {
-		reqsk_free(req);
-		goto out;
-	}
+	if (security_inet_conn_request(sk, skb, req))
+		goto out_free;
 
 	req->mss = mss;
 	ireq->rmt_port = th->source;
@@ -255,14 +253,13 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
 		security_req_classify_flow(req, &fl);
-		if (ip6_dst_lookup(sk, &dst, &fl)) {
-			reqsk_free(req);
-			goto out;
-		}
+		if (ip6_dst_lookup(sk, &dst, &fl))
+			goto out_free;
+
 		if (final_p)
 			ipv6_addr_copy(&fl.fl6_dst, final_p);
 		if ((xfrm_lookup(&dst, &fl, sk, 0)) < 0)
-			goto out;
+			goto out_free;
 	}
 
 	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
@@ -273,7 +270,10 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale = rcv_wscale;
 
 	ret = get_cookie_sock(sk, skb, req, dst);
-
-out:	return ret;
+out:
+	return ret;
+out_free:
+	reqsk_free(req);
+	return NULL;
 }
 
-- 
1.5.4.5

