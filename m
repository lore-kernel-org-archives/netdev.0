From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 17/26] IPVS: Add connection hashing function for IPv6 entries.
Date: Wed, 11 Jun 2008 19:12:00 +0200
Message-ID: <1213204329-10973-18-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14475 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbYFKRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:34 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip_vs_conn_hashkey_v6() and call it instead of ip_vs_conn_hashkey()
when hashing IPv6 connection entries.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 1a4040d..4ee5dac 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -37,6 +37,9 @@
 
 #include <net/net_namespace.h>
 #include <net/ip_vs.h>
+#ifdef CONFIG_IP_VS_IPV6
+#include <net/ipv6.h>
+#endif
 
 
 /*
@@ -122,6 +125,13 @@ static unsigned int ip_vs_conn_hashkey(unsigned proto, __be32 addr, __be16 port)
 		& IP_VS_CONN_TAB_MASK;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static unsigned int ip_vs_conn_hashkey_v6(unsigned proto, const struct in6_addr *addr, __be16 port)
+{
+	return jhash_3words(jhash(addr, 16, ip_vs_conn_rnd), (__force u32)port, proto, ip_vs_conn_rnd)
+		& IP_VS_CONN_TAB_MASK;
+}
+#endif
 
 /*
  *	Hashes ip_vs_conn in ip_vs_conn_tab by proto,addr,port.
@@ -133,7 +143,12 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* Hash by protocol, client address and port */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		hash = ip_vs_conn_hashkey_v6(cp->protocol, &cp->caddr.v6, cp->cport);
+	else
+#endif
+		hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.v4, cp->cport);
 
 	ct_write_lock(hash);
 
@@ -164,7 +179,12 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	int ret;
 
 	/* unhash it and decrease its reference counter */
-	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
+#ifdef CONFIG_IP_VS_IPV6
+	if (cp->af == AF_INET6)
+		hash = ip_vs_conn_hashkey_v6(cp->protocol, &cp->caddr.v6, cp->cport);
+	else
+#endif
+		hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.v4, cp->cport);
 
 	ct_write_lock(hash);
 
-- 
1.5.3.6

