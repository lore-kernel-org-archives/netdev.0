From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/5] net: Introduce ipv4_addr_hash and use it for tcp metrics
Date: Thu, 27 Aug 2015 16:06:59 -0700
Message-ID: <1440716823-19568-2-git-send-email-dsa@cumulusnetworks.com>
References: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36131 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbbH0XHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:07:10 -0400
Received: by pacgr6 with SMTP id gr6so3523575pac.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:07:10 -0700 (PDT)
In-Reply-To: <1440716823-19568-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactors a common line into helper function.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip.h       |  5 +++++
 net/ipv4/tcp_metrics.c | 12 ++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bee5f3582e38..7b9e1c782aa3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -458,6 +458,11 @@ static __inline__ void inet_reset_saddr(struct sock *sk)
 
 #endif
 
+static inline unsigned int ipv4_addr_hash(__be32 ip)
+{
+	return (__force unsigned int) ip;
+}
+
 bool ip_call_ra_chain(struct sk_buff *skb);
 
 /*
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b3d64f61d922..3a4289268f97 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -249,7 +249,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	case AF_INET:
 		saddr.addr.a4 = inet_rsk(req)->ir_loc_addr;
 		daddr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
-		hash = (__force unsigned int) daddr.addr.a4;
+		hash = ipv4_addr_hash(inet_rsk(req)->ir_rmt_addr);
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
@@ -289,7 +289,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 		saddr.addr.a4 = tw->tw_rcv_saddr;
 		daddr.family = AF_INET;
 		daddr.addr.a4 = tw->tw_daddr;
-		hash = (__force unsigned int) daddr.addr.a4;
+		hash = ipv4_addr_hash(tw->tw_daddr);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (tw->tw_family == AF_INET6) {
@@ -298,7 +298,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 			saddr.addr.a4 = tw->tw_rcv_saddr;
 			daddr.family = AF_INET;
 			daddr.addr.a4 = tw->tw_daddr;
-			hash = (__force unsigned int) daddr.addr.a4;
+			hash = ipv4_addr_hash(tw->tw_daddr);
 		} else {
 			saddr.family = AF_INET6;
 			saddr.addr.in6 = tw->tw_v6_rcv_saddr;
@@ -339,7 +339,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		saddr.addr.a4 = inet_sk(sk)->inet_saddr;
 		daddr.family = AF_INET;
 		daddr.addr.a4 = inet_sk(sk)->inet_daddr;
-		hash = (__force unsigned int) daddr.addr.a4;
+		hash = ipv4_addr_hash(inet_sk(sk)->inet_daddr);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (sk->sk_family == AF_INET6) {
@@ -348,7 +348,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 			saddr.addr.a4 = inet_sk(sk)->inet_saddr;
 			daddr.family = AF_INET;
 			daddr.addr.a4 = inet_sk(sk)->inet_daddr;
-			hash = (__force unsigned int) daddr.addr.a4;
+			hash = ipv4_addr_hash(inet_sk(sk)->inet_daddr);
 		} else {
 			saddr.family = AF_INET6;
 			saddr.addr.in6 = sk->sk_v6_rcv_saddr;
@@ -959,7 +959,7 @@ static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 		addr->family = AF_INET;
 		addr->addr.a4 = nla_get_in_addr(a);
 		if (hash)
-			*hash = (__force unsigned int) addr->addr.a4;
+			*hash = ipv4_addr_hash(addr->addr.a4);
 		return 0;
 	}
 	a = info->attrs[v6];
-- 
1.9.1
