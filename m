From: kaber@trash.net
Subject: [PATCH 25/72] IPVS: Fallback if persistence engine fails
Date: Thu, 21 Oct 2010 17:19:12 +0200
Message-ID: <1287674399-31455-26-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175Ab0JUPUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:08 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Fall back to normal persistence handling if the persistence
engine fails to recognise a packet.

This way, at least the packet will go somewhere.

It is envisaged that iptables could be used to block packets
such if this is not desired although nf_conntrack_sip would
likely need to be enhanced first.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |    6 +++---
 net/netfilter/ipvs/ip_vs_core.c |   10 ++++------
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4adedef..1d1a529 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -154,7 +154,7 @@ static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
 	const union nf_inet_addr *addr;
 	__be16 port;
 
-	if (p->pe && p->pe->hashkey_raw)
+	if (p->pe_data && p->pe->hashkey_raw)
 		return p->pe->hashkey_raw(p, ip_vs_conn_rnd, inverse) &
 			ip_vs_conn_tab_mask;
 
@@ -353,7 +353,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (p->pe && p->pe->ct_match) {
+		if (p->pe_data && p->pe->ct_match) {
 			if (p->pe->ct_match(p, cp))
 				goto out;
 			continue;
@@ -956,7 +956,7 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
 		size_t len = 0;
 
-		if (cp->dest && cp->dest->svc->pe &&
+		if (cp->dest && cp->pe_data &&
 		    cp->dest->svc->pe->show_pe_data) {
 			pe_data[0] = ' ';
 			len = strlen(cp->dest->svc->pe->name);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ab98893..e5fef7a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -176,7 +176,7 @@ ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 	return pp->state_transition(cp, direction, skb, pp);
 }
 
-static inline int
+static inline void
 ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 			      struct sk_buff *skb, int protocol,
 			      const union nf_inet_addr *caddr, __be16 cport,
@@ -186,8 +186,7 @@ ip_vs_conn_fill_param_persist(const struct ip_vs_service *svc,
 	ip_vs_conn_fill_param(svc->af, protocol, caddr, cport, vaddr, vport, p);
 	p->pe = svc->pe;
 	if (p->pe && p->pe->fill_param)
-		return p->pe->fill_param(p, skb);
-	return 0;
+		p->pe->fill_param(p, skb);
 }
 
 /*
@@ -268,9 +267,8 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				vaddr = &fwmark;
 			}
 		}
-		if (ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
-						  vaddr, vport, &param))
-			return NULL;
+		ip_vs_conn_fill_param_persist(svc, skb, protocol, &snet, 0,
+					      vaddr, vport, &param);
 	}
 
 	/* Check if a template already exists */
-- 
1.7.1

