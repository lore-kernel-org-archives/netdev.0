From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] ipv6: Create inet6_csk_route_req().
Date: Thu, 02 Dec 2010 12:42:19 -0800 (PST)
Message-ID: <20101202.124219.39177804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757917Ab0LBUlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AB54824C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Brother of ipv4's inet_csk_route_req().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet6_connection_sock.h |    3 +++
 net/ipv6/inet6_connection_sock.c    |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index aae08f6..ff01350 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -25,6 +25,9 @@ struct sockaddr;
 extern int inet6_csk_bind_conflict(const struct sock *sk,
 				   const struct inet_bind_bucket *tb);
 
+extern struct dst_entry* inet6_csk_route_req(struct sock *sk,
+					     const struct request_sock *req);
+
 extern struct request_sock *inet6_csk_search_req(const struct sock *sk,
 						 struct request_sock ***prevp,
 						 const __be16 rport,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 861d252..e46305d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -54,6 +54,38 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 
 EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
+struct dst_entry *inet6_csk_route_req(struct sock *sk,
+				      const struct request_sock *req)
+{
+	struct inet6_request_sock *treq = inet6_rsk(req);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *final_p, final;
+	struct dst_entry *dst;
+	struct flowi fl;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.proto = IPPROTO_TCP;
+	ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
+	final_p = fl6_update_dst(&fl, np->opt, &final);
+	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
+	fl.oif = sk->sk_bound_dev_if;
+	fl.mark = sk->sk_mark;
+	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
+	fl.fl_ip_sport = inet_rsk(req)->loc_port;
+	security_req_classify_flow(req, &fl);
+
+	if (ip6_dst_lookup(sk, &dst, &fl))
+		return NULL;
+
+	if (final_p)
+		ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+	if ((xfrm_lookup(sock_net(sk), &dst, &fl, sk, 0)) < 0)
+		return NULL;
+
+	return dst;
+}
+
 /*
  * request_sock (formerly open request) hash tables.
  */
-- 
1.7.3.2

