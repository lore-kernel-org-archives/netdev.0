From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/34] ipvs: address family of LBLCR entry depends on svc family
Date: Mon, 29 Sep 2014 14:39:13 +0200
Message-ID: <1411994363-8451-25-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

The LBLCR entries should use svc->af, not dest->af.
Needed to support svc->af != dest->af.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_lblcr.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 3f21a2f..2229d2d 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -362,18 +362,18 @@ ip_vs_lblcr_get(int af, struct ip_vs_lblcr_table *tbl,
  */
 static inline struct ip_vs_lblcr_entry *
 ip_vs_lblcr_new(struct ip_vs_lblcr_table *tbl, const union nf_inet_addr *daddr,
-		struct ip_vs_dest *dest)
+		u16 af, struct ip_vs_dest *dest)
 {
 	struct ip_vs_lblcr_entry *en;
 
-	en = ip_vs_lblcr_get(dest->af, tbl, daddr);
+	en = ip_vs_lblcr_get(af, tbl, daddr);
 	if (!en) {
 		en = kmalloc(sizeof(*en), GFP_ATOMIC);
 		if (!en)
 			return NULL;
 
-		en->af = dest->af;
-		ip_vs_addr_copy(dest->af, &en->addr, daddr);
+		en->af = af;
+		ip_vs_addr_copy(af, &en->addr, daddr);
 		en->lastuse = jiffies;
 
 		/* initialize its dest set */
@@ -706,13 +706,13 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 	/* If we fail to create a cache entry, we'll just use the valid dest */
 	spin_lock_bh(&svc->sched_lock);
 	if (!tbl->dead)
-		ip_vs_lblcr_new(tbl, &iph->daddr, dest);
+		ip_vs_lblcr_new(tbl, &iph->daddr, svc->af, dest);
 	spin_unlock_bh(&svc->sched_lock);
 
 out:
 	IP_VS_DBG_BUF(6, "LBLCR: destination IP address %s --> server %s:%d\n",
 		      IP_VS_DBG_ADDR(svc->af, &iph->daddr),
-		      IP_VS_DBG_ADDR(svc->af, &dest->addr), ntohs(dest->port));
+		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port));
 
 	return dest;
 }
-- 
1.7.10.4

