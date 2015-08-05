From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 4/9] netfilter: connlabels: Export setting connlabel length
Date: Tue,  4 Aug 2015 21:49:54 -0700
Message-ID: <1438750199-9061-5-git-send-email-joestringer@nicira.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36538 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbHEEuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 00:50:25 -0400
Received: by pacgq8 with SMTP id gq8so25527189pac.3
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 21:50:24 -0700 (PDT)
In-Reply-To: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions to change connlabel length into nf_conntrack_labels.c so
they may be reused by other modules like OVS and nftables without
needing to jump through xt_match_check() hoops.

Suggested-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Protect connlabel modification with spinlock.
    Fix reference leak in error case.
    Style fixups.
---
 include/net/netfilter/nf_conntrack_labels.h |  4 ++++
 net/netfilter/nf_conntrack_labels.c         | 32 +++++++++++++++++++++++++++++
 net/netfilter/xt_connlabel.c                | 16 ++++-----------
 3 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index dec6336..7e2b1d0 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -54,7 +54,11 @@ int nf_connlabels_replace(struct nf_conn *ct,
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 int nf_conntrack_labels_init(void);
 void nf_conntrack_labels_fini(void);
+int nf_connlabels_get(struct net *net, unsigned int n_bits);
+void nf_connlabels_put(struct net *net);
 #else
 static inline int nf_conntrack_labels_init(void) { return 0; }
 static inline void nf_conntrack_labels_fini(void) {}
+static inline int nf_connlabels_get(struct net *net, unsigned int n_bits) { return 0; }
+static inline void nf_connlabels_put(struct net *net) {}
 #endif
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index bb53f12..06e71a0 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -14,6 +14,8 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_labels.h>
 
+static spinlock_t nf_connlabels_lock;
+
 static unsigned int label_bits(const struct nf_conn_labels *l)
 {
 	unsigned int longs = l->words;
@@ -91,6 +93,35 @@ int nf_connlabels_replace(struct nf_conn *ct,
 EXPORT_SYMBOL_GPL(nf_connlabels_replace);
 #endif
 
+int nf_connlabels_get(struct net *net, unsigned int n_bits)
+{
+	size_t words;
+
+	if (n_bits > (NF_CT_LABELS_MAX_SIZE * BITS_PER_BYTE))
+		return -ERANGE;
+
+	words = BITS_TO_LONGS(n_bits);
+
+	spin_lock(&nf_connlabels_lock);
+	net->ct.labels_used++;
+	if (words > net->ct.label_words)
+		net->ct.label_words = words;
+	spin_unlock(&nf_connlabels_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_connlabels_get);
+
+void nf_connlabels_put(struct net *net)
+{
+	spin_lock(&nf_connlabels_lock);
+	net->ct.labels_used--;
+	if (net->ct.labels_used == 0)
+		net->ct.label_words = 0;
+	spin_unlock(&nf_connlabels_lock);
+}
+EXPORT_SYMBOL_GPL(nf_connlabels_put);
+
 static struct nf_ct_ext_type labels_extend __read_mostly = {
 	.len    = sizeof(struct nf_conn_labels),
 	.align  = __alignof__(struct nf_conn_labels),
@@ -99,6 +130,7 @@ static struct nf_ct_ext_type labels_extend __read_mostly = {
 
 int nf_conntrack_labels_init(void)
 {
+	spin_lock_init(&nf_connlabels_lock);
 	return nf_ct_extend_register(&labels_extend);
 }
 
diff --git a/net/netfilter/xt_connlabel.c b/net/netfilter/xt_connlabel.c
index 9f8719d..bb9cbeb 100644
--- a/net/netfilter/xt_connlabel.c
+++ b/net/netfilter/xt_connlabel.c
@@ -42,10 +42,6 @@ static int connlabel_mt_check(const struct xt_mtchk_param *par)
 			    XT_CONNLABEL_OP_SET;
 	struct xt_connlabel_mtinfo *info = par->matchinfo;
 	int ret;
-	size_t words;
-
-	if (info->bit > XT_CONNLABEL_MAXBIT)
-		return -ERANGE;
 
 	if (info->options & ~options) {
 		pr_err("Unknown options in mask %x\n", info->options);
@@ -59,19 +55,15 @@ static int connlabel_mt_check(const struct xt_mtchk_param *par)
 		return ret;
 	}
 
-	par->net->ct.labels_used++;
-	words = BITS_TO_LONGS(info->bit+1);
-	if (words > par->net->ct.label_words)
-		par->net->ct.label_words = words;
-
+	ret = nf_connlabels_get(par->net, info->bit + 1);
+	if (ret < 0)
+		nf_ct_l3proto_module_put(par->family);
 	return ret;
 }
 
 static void connlabel_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	par->net->ct.labels_used--;
-	if (par->net->ct.labels_used == 0)
-		par->net->ct.label_words = 0;
+	nf_connlabels_put(par->net);
 	nf_ct_l3proto_module_put(par->family);
 }
 
-- 
2.1.4
