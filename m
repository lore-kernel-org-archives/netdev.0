From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 37/38] netfilter: connlimit: make same_source_net signed
Date: Mon, 17 Mar 2014 13:42:57 +0100
Message-ID: <1395060178-11833-38-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59546 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933186AbaCQMnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:51 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

currently returns 1 if they're the same.  Make it work like mem/strcmp
so it can be used as rbtree search function.

Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index ad290cc..dc5207f 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -78,13 +78,14 @@ static inline bool already_closed(const struct nf_conn *conn)
 		return 0;
 }
 
-static inline unsigned int
+static int
 same_source_net(const union nf_inet_addr *addr,
 		const union nf_inet_addr *mask,
 		const union nf_inet_addr *u3, u_int8_t family)
 {
 	if (family == NFPROTO_IPV4) {
-		return (addr->ip & mask->ip) == (u3->ip & mask->ip);
+		return ntohl(addr->ip & mask->ip) -
+		       ntohl(u3->ip & mask->ip);
 	} else {
 		union nf_inet_addr lh, rh;
 		unsigned int i;
@@ -94,7 +95,7 @@ same_source_net(const union nf_inet_addr *addr,
 			rh.ip6[i] = u3->ip6[i] & mask->ip6[i];
 		}
 
-		return memcmp(&lh.ip6, &rh.ip6, sizeof(lh.ip6)) == 0;
+		return memcmp(&lh.ip6, &rh.ip6, sizeof(lh.ip6));
 	}
 }
 
@@ -143,7 +144,7 @@ static int count_hlist(struct net *net,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->addr, family))
+		if (same_source_net(addr, mask, &conn->addr, family) == 0)
 			/* same source network -> be counted! */
 			++matches;
 		nf_ct_put(found_ct);
-- 
1.7.10.4
