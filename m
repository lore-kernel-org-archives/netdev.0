From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/27] netfilter: reduce direct skb->nfct usage
Date: Fri,  3 Feb 2017 13:25:32 +0100
Message-ID: <1486124738-3013-22-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59014 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753251AbdBCM2p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:45 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AED49C9EC7
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9B58CDA80C
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6A4D6DA81F
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:41 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Next patch makes direct skb->nfct access illegal, reduce noise
in next patch by using accessors we already have.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h               |  9 ++++++---
 net/netfilter/nf_conntrack_core.c | 15 +++++++++------
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cd6018a9ee24..2a344ebd7ebe 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1554,10 +1554,13 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
-		nf_conntrack_put(skb->nfct);
-		skb->nfct = &nf_ct_untracked_get()->ct_general;
+		struct nf_conn *untracked;
+
+		nf_conntrack_put(&ct->ct_general);
+		untracked = nf_ct_untracked_get();
+		nf_conntrack_get(&untracked->ct_general);
+		skb->nfct = &untracked->ct_general;
 		skb->nfctinfo = IP_CT_NEW;
-		nf_conntrack_get(skb->nfct);
 	}
 #endif
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 86186a2e2715..adb7af3a4c4c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -686,8 +686,11 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
 	    !nfct_nat(ct) &&
 	    !nf_ct_is_dying(ct) &&
 	    atomic_inc_not_zero(&ct->ct_general.use)) {
-		nf_ct_acct_merge(ct, ctinfo, (struct nf_conn *)skb->nfct);
-		nf_conntrack_put(skb->nfct);
+		enum ip_conntrack_info oldinfo;
+		struct nf_conn *loser_ct = nf_ct_get(skb, &oldinfo);
+
+		nf_ct_acct_merge(ct, ctinfo, loser_ct);
+		nf_conntrack_put(&loser_ct->ct_general);
 		/* Assign conntrack already in hashes to this skbuff. Don't
 		 * modify skb->nfctinfo to ensure consistent stateful filtering.
 		 */
@@ -1288,7 +1291,7 @@ unsigned int
 nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		struct sk_buff *skb)
 {
-	struct nf_conn *ct, *tmpl = NULL;
+	struct nf_conn *ct, *tmpl;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -1298,9 +1301,9 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	int set_reply = 0;
 	int ret;
 
-	if (skb->nfct) {
+	tmpl = nf_ct_get(skb, &ctinfo);
+	if (tmpl) {
 		/* Previously seen (loopback or untracked)?  Ignore. */
-		tmpl = (struct nf_conn *)skb->nfct;
 		if (!nf_ct_is_template(tmpl)) {
 			NF_CT_STAT_INC_ATOMIC(net, ignore);
 			return NF_ACCEPT;
@@ -1364,7 +1367,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
-		nf_conntrack_put(skb->nfct);
+		nf_conntrack_put(&ct->ct_general);
 		skb->nfct = NULL;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		if (ret == -NF_DROP)
-- 
2.1.4
