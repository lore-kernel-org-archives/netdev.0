From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/27] netfilter: guarantee 8 byte minalign for template addresses
Date: Fri,  3 Feb 2017 13:25:35 +0100
Message-ID: <1486124738-3013-25-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The next change will merge skb->nfct pointer and skb->nfctinfo
status bits into single skb->_nfct (unsigned long) area.

For this to work nf_conn addresses must always be aligned at least on
an 8 byte boundary since we will need the lower 3bits to store nfctinfo.

Conntrack templates are allocated via kmalloc.
kbuild test robot reported
BUILD_BUG_ON failed: NFCT_INFOMASK >= ARCH_KMALLOC_MINALIGN
on v1 of this patchset, so not all platforms meet this requirement.

Do manual alignment if needed,  the alignment offset is stored in the
nf_conn entry protocol area. This works because templates are not
handed off to L4 protocol trackers.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  2 ++
 net/netfilter/nf_conntrack_core.c    | 29 ++++++++++++++++++++++++-----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index d704aed11684..06d3d2d24fe0 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -163,6 +163,8 @@ void nf_conntrack_alter_reply(struct nf_conn *ct,
 int nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			     const struct nf_conn *ignored_conntrack);
 
+#define NFCT_INFOMASK	7UL
+
 /* Return conntrack_info and tuple hash for given skb. */
 static inline struct nf_conn *
 nf_ct_get(const struct sk_buff *skb, enum ip_conntrack_info *ctinfo)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c9bd10747864..768968fba7f6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -350,16 +350,31 @@ static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
 	spin_unlock(&pcpu->lock);
 }
 
+#define NFCT_ALIGN(len)	(((len) + NFCT_INFOMASK) & ~NFCT_INFOMASK)
+
 /* Released via destroy_conntrack() */
 struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 				 const struct nf_conntrack_zone *zone,
 				 gfp_t flags)
 {
-	struct nf_conn *tmpl;
+	struct nf_conn *tmpl, *p;
 
-	tmpl = kzalloc(sizeof(*tmpl), flags);
-	if (tmpl == NULL)
-		return NULL;
+	if (ARCH_KMALLOC_MINALIGN <= NFCT_INFOMASK) {
+		tmpl = kzalloc(sizeof(*tmpl) + NFCT_INFOMASK, flags);
+		if (!tmpl)
+			return NULL;
+
+		p = tmpl;
+		tmpl = (struct nf_conn *)NFCT_ALIGN((unsigned long)p);
+		if (tmpl != p) {
+			tmpl = (struct nf_conn *)NFCT_ALIGN((unsigned long)p);
+			tmpl->proto.tmpl_padto = (char *)tmpl - (char *)p;
+		}
+	} else {
+		tmpl = kzalloc(sizeof(*tmpl), flags);
+		if (!tmpl)
+			return NULL;
+	}
 
 	tmpl->status = IPS_TEMPLATE;
 	write_pnet(&tmpl->ct_net, net);
@@ -374,7 +389,11 @@ void nf_ct_tmpl_free(struct nf_conn *tmpl)
 {
 	nf_ct_ext_destroy(tmpl);
 	nf_ct_ext_free(tmpl);
-	kfree(tmpl);
+
+	if (ARCH_KMALLOC_MINALIGN <= NFCT_INFOMASK)
+		kfree((char *)tmpl - tmpl->proto.tmpl_padto);
+	else
+		kfree(tmpl);
 }
 EXPORT_SYMBOL_GPL(nf_ct_tmpl_free);
 
-- 
2.1.4

