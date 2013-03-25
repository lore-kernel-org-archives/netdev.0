From: pablo@netfilter.org
Subject: [PATCH 07/12] ipvs: fix hashing in ip_vs_svc_hashkey
Date: Mon, 25 Mar 2013 13:15:47 +0100
Message-ID: <1364213752-3934-8-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

net is a pointer in host order, mix it properly
with other keys in network order. Fixes sparse warning.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c68198b..a528178 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -271,16 +271,18 @@ ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
 {
 	register unsigned int porth = ntohs(port);
 	__be32 addr_fold = addr->ip;
+	__u32 ahash;
 
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
 		addr_fold = addr->ip6[0]^addr->ip6[1]^
 			    addr->ip6[2]^addr->ip6[3];
 #endif
-	addr_fold ^= ((size_t)net>>8);
+	ahash = ntohl(addr_fold);
+	ahash ^= ((size_t) net >> 8);
 
-	return (proto^ntohl(addr_fold)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
-		& IP_VS_SVC_TAB_MASK;
+	return (proto ^ ahash ^ (porth >> IP_VS_SVC_TAB_BITS) ^ porth) &
+	       IP_VS_SVC_TAB_MASK;
 }
 
 /*
-- 
1.7.10.4

