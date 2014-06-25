From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [net-next v2 07/13] tcp: move around a few calls in tcp_v6_conn_request
Date: Wed, 25 Jun 2014 17:09:56 +0300
Message-ID: <1403705402-14388-8-git-send-email-octavian.purdila@intel.com>
References: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Cc: Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45776 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757360AbaFYOKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:10:34 -0400
In-Reply-To: <1403705402-14388-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the tcp_v6_conn_request calls flow similar with that of
tcp_v4_conn_request.

Note that want_cookie can be true only if isn is zero and that is why
we can move the if (want_cookie) block out of the if (!isn) block.

Moving security_inet_conn_request() has a couple of side effects:
missing inet_rsk(req)->ecn_ok update and the req->cookie_ts
update. However, neither SELinux nor Smack security hooks seems to
check them. This change should also avoid future different behaviour
for IPv4 and IPv6 in the security hooks.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
---
 net/ipv6/tcp_ipv6.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d780d88..91b8a2e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1070,16 +1070,16 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	af_ops->init_req(req, sk, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_release;
+
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, skb, sock_net(sk));
 
-	if (!isn) {
-		if (want_cookie) {
-			isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
-			req->cookie_ts = tmp_opt.tstamp_ok;
-			goto have_isn;
-		}
-
+	if (want_cookie) {
+		isn = cookie_init_sequence(af_ops, sk, skb, &req->mss);
+		req->cookie_ts = tmp_opt.tstamp_ok;
+	} else if (!isn) {
 		/* VJ's idea. We save last timestamp seen
 		 * from the destination in peer table, when entering
 		 * state TIME-WAIT, and check against it before
@@ -1116,10 +1116,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 		isn = tcp_v6_init_sequence(skb);
 	}
-have_isn:
-
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_release;
 
 	if (!dst) {
 		dst = af_ops->route_req(sk, (struct flowi *)&fl6, req, NULL);
-- 
1.8.3.2
