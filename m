From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/23] netfilter: connlabels: change nf_connlabels_get bit arg to 'highest used'
Date: Fri, 22 Apr 2016 15:39:52 +0200
Message-ID: <1461332394-3994-22-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45274 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbcDVNkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:25 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id F08CB6EF29
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D2A3BB505B
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 01DA4B505B
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:20 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

nf_connlabel_set() takes the bit number that we would like to set.
nf_connlabels_get() however took the number of bits that we want to
support.

So e.g. nf_connlabels_get(32) support bits 0 to 31, but not 32.
This changes nf_connlabels_get() to take the highest bit that we want
to set.

Callers then don't have to cope with a potential integer wrap
when using nf_connlabels_get(bit + 1) anymore.

Current callers are fine, this change is only to make folloup
nft ct label set support simpler.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h | 4 ++--
 net/netfilter/nf_conntrack_labels.c         | 9 +++++----
 net/netfilter/nft_ct.c                      | 2 ++
 net/netfilter/xt_connlabel.c                | 2 +-
 net/openvswitch/conntrack.c                 | 2 +-
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index 5167818..c5f8fc73 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -53,11 +53,11 @@ int nf_connlabels_replace(struct nf_conn *ct,
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 int nf_conntrack_labels_init(void);
 void nf_conntrack_labels_fini(void);
-int nf_connlabels_get(struct net *net, unsigned int n_bits);
+int nf_connlabels_get(struct net *net, unsigned int bit);
 void nf_connlabels_put(struct net *net);
 #else
 static inline int nf_conntrack_labels_init(void) { return 0; }
 static inline void nf_conntrack_labels_fini(void) {}
-static inline int nf_connlabels_get(struct net *net, unsigned int n_bits) { return 0; }
+static inline int nf_connlabels_get(struct net *net, unsigned int bit) { return 0; }
 static inline void nf_connlabels_put(struct net *net) {}
 #endif
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index bd7f26b..252e6a7 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -78,15 +78,14 @@ int nf_connlabels_replace(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_replace);
 
-int nf_connlabels_get(struct net *net, unsigned int n_bits)
+int nf_connlabels_get(struct net *net, unsigned int bits)
 {
 	size_t words;
 
-	if (n_bits > (NF_CT_LABELS_MAX_SIZE * BITS_PER_BYTE))
+	words = BIT_WORD(bits) + 1;
+	if (words > NF_CT_LABELS_MAX_SIZE / sizeof(long))
 		return -ERANGE;
 
-	words = BITS_TO_LONGS(n_bits);
-
 	spin_lock(&nf_connlabels_lock);
 	net->ct.labels_used++;
 	if (words > net->ct.label_words)
@@ -115,6 +114,8 @@ static struct nf_ct_ext_type labels_extend __read_mostly = {
 
 int nf_conntrack_labels_init(void)
 {
+	BUILD_BUG_ON(NF_CT_LABELS_MAX_SIZE / sizeof(long) >= U8_MAX);
+
 	spin_lock_init(&nf_connlabels_lock);
 	return nf_ct_extend_register(&labels_extend);
 }
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index d4a4619..25998fa 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -484,6 +484,8 @@ static struct nft_expr_type nft_ct_type __read_mostly = {
 
 static int __init nft_ct_module_init(void)
 {
+	BUILD_BUG_ON(NF_CT_LABELS_MAX_SIZE > NFT_REG_SIZE);
+
 	return nft_register_expr(&nft_ct_type);
 }
 
diff --git a/net/netfilter/xt_connlabel.c b/net/netfilter/xt_connlabel.c
index d9b3e53..a79af25 100644
--- a/net/netfilter/xt_connlabel.c
+++ b/net/netfilter/xt_connlabel.c
@@ -65,7 +65,7 @@ static int connlabel_mt_check(const struct xt_mtchk_param *par)
 		return ret;
 	}
 
-	ret = nf_connlabels_get(par->net, info->bit + 1);
+	ret = nf_connlabels_get(par->net, info->bit);
 	if (ret < 0)
 		nf_ct_l3proto_module_put(par->family);
 	return ret;
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 1b9d286..e5fe24a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1344,7 +1344,7 @@ void ovs_ct_init(struct net *net)
 	unsigned int n_bits = sizeof(struct ovs_key_ct_labels) * BITS_PER_BYTE;
 	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
-	if (nf_connlabels_get(net, n_bits)) {
+	if (nf_connlabels_get(net, n_bits - 1)) {
 		ovs_net->xt_label = false;
 		OVS_NLERR(true, "Failed to set connlabel length");
 	} else {
-- 
2.1.4
