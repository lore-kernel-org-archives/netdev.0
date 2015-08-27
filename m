From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/5] net: Add set,get helpers for inetpeer addresses
Date: Thu, 27 Aug 2015 16:07:00 -0700
Message-ID: <1440716823-19568-3-git-send-email-dsa@cumulusnetworks.com>
References: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36158 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbbH0XHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:07:12 -0400
Received: by pacgr6 with SMTP id gr6so3524187pac.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:07:11 -0700 (PDT)
In-Reply-To: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use inetpeer set,get helpers in tcp_metrics rather than peeking into
the inetpeer_addr struct.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/inetpeer.h | 23 ++++++++++++++++++
 net/ipv4/tcp_metrics.c | 65 +++++++++++++++++++++-----------------------------
 2 files changed, 50 insertions(+), 38 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 002f0bd27001..f75b9e7036a2 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -71,6 +71,29 @@ void inet_initpeers(void) __init;
 
 #define INETPEER_METRICS_NEW	(~(u32) 0)
 
+static inline void inetpeer_set_addr_v4(struct inetpeer_addr *iaddr, __be32 ip)
+{
+	iaddr->addr.a4 = ip;
+	iaddr->family = AF_INET;
+}
+
+static inline __be32 inetpeer_get_addr_v4(struct inetpeer_addr *iaddr)
+{
+	return iaddr->addr.a4;
+}
+
+static inline void inetpeer_set_addr_v6(struct inetpeer_addr *iaddr,
+					struct in6_addr *in6)
+{
+	iaddr->addr.in6 = *in6;
+	iaddr->family = AF_INET6;
+}
+
+static inline struct in6_addr *inetpeer_get_addr_v6(struct inetpeer_addr *iaddr)
+{
+	return &iaddr->addr.in6;
+}
+
 /* can be called with or without local BH being disabled */
 struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 			       const struct inetpeer_addr *daddr,
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 3a4289268f97..4ef4dd4bf38c 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -247,14 +247,14 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	daddr.family = req->rsk_ops->family;
 	switch (daddr.family) {
 	case AF_INET:
-		saddr.addr.a4 = inet_rsk(req)->ir_loc_addr;
-		daddr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
+		inetpeer_set_addr_v4(&saddr, inet_rsk(req)->ir_loc_addr);
+		inetpeer_set_addr_v4(&daddr, inet_rsk(req)->ir_rmt_addr);
 		hash = ipv4_addr_hash(inet_rsk(req)->ir_rmt_addr);
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		saddr.addr.in6 = inet_rsk(req)->ir_v6_loc_addr;
-		daddr.addr.in6 = inet_rsk(req)->ir_v6_rmt_addr;
+		inetpeer_set_addr_v6(&saddr, &inet_rsk(req)->ir_v6_loc_addr);
+		inetpeer_set_addr_v6(&daddr, &inet_rsk(req)->ir_v6_rmt_addr);
 		hash = ipv6_addr_hash(&inet_rsk(req)->ir_v6_rmt_addr);
 		break;
 #endif
@@ -285,25 +285,19 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 	struct net *net;
 
 	if (tw->tw_family == AF_INET) {
-		saddr.family = AF_INET;
-		saddr.addr.a4 = tw->tw_rcv_saddr;
-		daddr.family = AF_INET;
-		daddr.addr.a4 = tw->tw_daddr;
+		inetpeer_set_addr_v4(&saddr, tw->tw_rcv_saddr);
+		inetpeer_set_addr_v4(&daddr, tw->tw_daddr);
 		hash = ipv4_addr_hash(tw->tw_daddr);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (tw->tw_family == AF_INET6) {
 		if (ipv6_addr_v4mapped(&tw->tw_v6_daddr)) {
-			saddr.family = AF_INET;
-			saddr.addr.a4 = tw->tw_rcv_saddr;
-			daddr.family = AF_INET;
-			daddr.addr.a4 = tw->tw_daddr;
+			inetpeer_set_addr_v4(&saddr, tw->tw_rcv_saddr);
+			inetpeer_set_addr_v4(&daddr, tw->tw_daddr);
 			hash = ipv4_addr_hash(tw->tw_daddr);
 		} else {
-			saddr.family = AF_INET6;
-			saddr.addr.in6 = tw->tw_v6_rcv_saddr;
-			daddr.family = AF_INET6;
-			daddr.addr.in6 = tw->tw_v6_daddr;
+			inetpeer_set_addr_v6(&saddr, &tw->tw_v6_rcv_saddr);
+			inetpeer_set_addr_v6(&daddr, &tw->tw_v6_daddr);
 			hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		}
 	}
@@ -335,25 +329,19 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	struct net *net;
 
 	if (sk->sk_family == AF_INET) {
-		saddr.family = AF_INET;
-		saddr.addr.a4 = inet_sk(sk)->inet_saddr;
-		daddr.family = AF_INET;
-		daddr.addr.a4 = inet_sk(sk)->inet_daddr;
+		inetpeer_set_addr_v4(&saddr, inet_sk(sk)->inet_saddr);
+		inetpeer_set_addr_v4(&daddr, inet_sk(sk)->inet_daddr);
 		hash = ipv4_addr_hash(inet_sk(sk)->inet_daddr);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (sk->sk_family == AF_INET6) {
 		if (ipv6_addr_v4mapped(&sk->sk_v6_daddr)) {
-			saddr.family = AF_INET;
-			saddr.addr.a4 = inet_sk(sk)->inet_saddr;
-			daddr.family = AF_INET;
-			daddr.addr.a4 = inet_sk(sk)->inet_daddr;
+			inetpeer_set_addr_v4(&saddr, inet_sk(sk)->inet_saddr);
+			inetpeer_set_addr_v4(&daddr, inet_sk(sk)->inet_daddr);
 			hash = ipv4_addr_hash(inet_sk(sk)->inet_daddr);
 		} else {
-			saddr.family = AF_INET6;
-			saddr.addr.in6 = sk->sk_v6_rcv_saddr;
-			daddr.family = AF_INET6;
-			daddr.addr.in6 = sk->sk_v6_daddr;
+			inetpeer_set_addr_v6(&saddr, &sk->sk_v6_rcv_saddr);
+			inetpeer_set_addr_v6(&daddr, &sk->sk_v6_daddr);
 			hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		}
 	}
@@ -796,18 +784,18 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 	switch (tm->tcpm_daddr.family) {
 	case AF_INET:
 		if (nla_put_in_addr(msg, TCP_METRICS_ATTR_ADDR_IPV4,
-				    tm->tcpm_daddr.addr.a4) < 0)
+				    inetpeer_get_addr_v4(&tm->tcpm_daddr)) < 0)
 			goto nla_put_failure;
 		if (nla_put_in_addr(msg, TCP_METRICS_ATTR_SADDR_IPV4,
-				    tm->tcpm_saddr.addr.a4) < 0)
+				    inetpeer_get_addr_v4(&tm->tcpm_saddr)) < 0)
 			goto nla_put_failure;
 		break;
 	case AF_INET6:
 		if (nla_put_in6_addr(msg, TCP_METRICS_ATTR_ADDR_IPV6,
-				     &tm->tcpm_daddr.addr.in6) < 0)
+				     inetpeer_get_addr_v6(&tm->tcpm_daddr)) < 0)
 			goto nla_put_failure;
 		if (nla_put_in6_addr(msg, TCP_METRICS_ATTR_SADDR_IPV6,
-				     &tm->tcpm_saddr.addr.in6) < 0)
+				     inetpeer_get_addr_v6(&tm->tcpm_saddr)) < 0)
 			goto nla_put_failure;
 		break;
 	default:
@@ -956,20 +944,21 @@ static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 
 	a = info->attrs[v4];
 	if (a) {
-		addr->family = AF_INET;
-		addr->addr.a4 = nla_get_in_addr(a);
+		inetpeer_set_addr_v4(addr, nla_get_in_addr(a));
 		if (hash)
-			*hash = ipv4_addr_hash(addr->addr.a4);
+			*hash = ipv4_addr_hash(inetpeer_get_addr_v4(addr));
 		return 0;
 	}
 	a = info->attrs[v6];
 	if (a) {
+		struct in6_addr in6;
+
 		if (nla_len(a) != sizeof(struct in6_addr))
 			return -EINVAL;
-		addr->family = AF_INET6;
-		addr->addr.in6 = nla_get_in6_addr(a);
+		in6 = nla_get_in6_addr(a);
+		inetpeer_set_addr_v6(addr, &in6);
 		if (hash)
-			*hash = ipv6_addr_hash(&addr->addr.in6);
+			*hash = ipv6_addr_hash(inetpeer_get_addr_v6(addr));
 		return 0;
 	}
 	return optional ? 1 : -EAFNOSUPPORT;
-- 
1.9.1
