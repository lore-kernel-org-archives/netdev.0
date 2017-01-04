From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 3/4] netfilter: reduce direct skb->nfct usage
Date: Wed,  4 Jan 2017 16:35:49 +0100
Message-ID: <1483544150-10686-4-git-send-email-fw@strlen.de>
References: <1483544150-10686-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43814 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936443AbdADP6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:58:47 -0500
In-Reply-To: <1483544150-10686-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next patch makes direct skb->nfct access illegal, reduce noise
in next patch by using accessors we already have.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
2.7.3
