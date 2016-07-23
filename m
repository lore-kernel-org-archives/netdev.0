From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/25] netfilter: conntrack: support a fixed size of 128 distinct labels
Date: Sat, 23 Jul 2016 13:08:35 +0200
Message-ID: <1469272119-29942-22-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

The conntrack label extension is currently variable-sized, e.g. if
only 2 labels are used by iptables rules then the labels->bits[] array
will only contain one element.

We track size of each label storage area in the 'words' member.

But in nftables and openvswitch we always have to ask for worst-case
since we don't know what bit will be used at configuration time.

As most arches are 64bit we need to allocate 24 bytes in this case:

struct nf_conn_labels {
    u8            words;   /*     0     1 */
    /* XXX 7 bytes hole, try to pack */
    long unsigned bits[2]; /*     8     24 */

Make bits a fixed size and drop the words member, it simplifies
the code and only increases memory requirements on x86 when
less than 64bit labels are required.

We still only allocate the extension if its needed.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h | 16 ++++------------
 net/netfilter/nf_conntrack_labels.c         | 13 +++----------
 net/netfilter/nf_conntrack_netlink.c        | 10 +++++-----
 net/netfilter/nft_ct.c                      | 13 +++----------
 net/netfilter/xt_connlabel.c                |  2 +-
 net/openvswitch/conntrack.c                 |  4 ++--
 6 files changed, 18 insertions(+), 40 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index c5f8fc73..0fd4989 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -10,8 +10,7 @@
 #define NF_CT_LABELS_MAX_SIZE ((XT_CONNLABEL_MAXBIT + 1) / BITS_PER_BYTE)
 
 struct nf_conn_labels {
-	u8 words;
-	unsigned long bits[];
+	unsigned long bits[NF_CT_LABELS_MAX_SIZE / sizeof(long)];
 };
 
 static inline struct nf_conn_labels *nf_ct_labels_find(const struct nf_conn *ct)
@@ -26,20 +25,13 @@ static inline struct nf_conn_labels *nf_ct_labels_find(const struct nf_conn *ct)
 static inline struct nf_conn_labels *nf_ct_labels_ext_add(struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_LABELS
-	struct nf_conn_labels *cl_ext;
 	struct net *net = nf_ct_net(ct);
-	u8 words;
 
-	words = ACCESS_ONCE(net->ct.label_words);
-	if (words == 0)
+	if (net->ct.labels_used == 0)
 		return NULL;
 
-	cl_ext = nf_ct_ext_add_length(ct, NF_CT_EXT_LABELS,
-				      words * sizeof(long), GFP_ATOMIC);
-	if (cl_ext != NULL)
-		cl_ext->words = words;
-
-	return cl_ext;
+	return nf_ct_ext_add_length(ct, NF_CT_EXT_LABELS,
+				    sizeof(struct nf_conn_labels), GFP_ATOMIC);
 #else
 	return NULL;
 #endif
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index 252e6a7..7686200 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -20,7 +20,7 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 {
 	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
 
-	if (!labels || BIT_WORD(bit) >= labels->words)
+	if (!labels)
 		return -ENOSPC;
 
 	if (test_bit(bit, labels->bits))
@@ -60,7 +60,7 @@ int nf_connlabels_replace(struct nf_conn *ct,
 	if (!labels)
 		return -ENOSPC;
 
-	size = labels->words * sizeof(long);
+	size = sizeof(labels->bits);
 	if (size < (words32 * sizeof(u32)))
 		words32 = size / sizeof(u32);
 
@@ -80,16 +80,11 @@ EXPORT_SYMBOL_GPL(nf_connlabels_replace);
 
 int nf_connlabels_get(struct net *net, unsigned int bits)
 {
-	size_t words;
-
-	words = BIT_WORD(bits) + 1;
-	if (words > NF_CT_LABELS_MAX_SIZE / sizeof(long))
+	if (BIT_WORD(bits) >= NF_CT_LABELS_MAX_SIZE / sizeof(long))
 		return -ERANGE;
 
 	spin_lock(&nf_connlabels_lock);
 	net->ct.labels_used++;
-	if (words > net->ct.label_words)
-		net->ct.label_words = words;
 	spin_unlock(&nf_connlabels_lock);
 
 	return 0;
@@ -100,8 +95,6 @@ void nf_connlabels_put(struct net *net)
 {
 	spin_lock(&nf_connlabels_lock);
 	net->ct.labels_used--;
-	if (net->ct.labels_used == 0)
-		net->ct.label_words = 0;
 	spin_unlock(&nf_connlabels_lock);
 }
 EXPORT_SYMBOL_GPL(nf_connlabels_put);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a18d1ce..050bb34 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -346,25 +346,25 @@ static inline int ctnetlink_label_size(const struct nf_conn *ct)
 
 	if (!labels)
 		return 0;
-	return nla_total_size(labels->words * sizeof(long));
+	return nla_total_size(sizeof(labels->bits));
 }
 
 static int
 ctnetlink_dump_labels(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
-	unsigned int len, i;
+	unsigned int i;
 
 	if (!labels)
 		return 0;
 
-	len = labels->words * sizeof(long);
 	i = 0;
 	do {
 		if (labels->bits[i] != 0)
-			return nla_put(skb, CTA_LABELS, len, labels->bits);
+			return nla_put(skb, CTA_LABELS, sizeof(labels->bits),
+				       labels->bits);
 		i++;
-	} while (i < labels->words);
+	} while (i < ARRAY_SIZE(labels->bits));
 
 	return 0;
 }
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index d9e44ca..2f47d5d 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -113,18 +113,11 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 	case NFT_CT_LABELS: {
 		struct nf_conn_labels *labels = nf_ct_labels_find(ct);
-		unsigned int size;
 
-		if (!labels) {
+		if (labels)
+			memcpy(dest, labels->bits, NF_CT_LABELS_MAX_SIZE);
+		else
 			memset(dest, 0, NF_CT_LABELS_MAX_SIZE);
-			return;
-		}
-
-		size = labels->words * sizeof(long);
-		memcpy(dest, labels->bits, size);
-		if (size < NF_CT_LABELS_MAX_SIZE)
-			memset(((char *) dest) + size, 0,
-			       NF_CT_LABELS_MAX_SIZE - size);
 		return;
 	}
 #endif
diff --git a/net/netfilter/xt_connlabel.c b/net/netfilter/xt_connlabel.c
index a79af25..c9fba8a 100644
--- a/net/netfilter/xt_connlabel.c
+++ b/net/netfilter/xt_connlabel.c
@@ -25,7 +25,7 @@ static bool connlabel_match(const struct nf_conn *ct, u16 bit)
 	if (!labels)
 		return false;
 
-	return BIT_WORD(bit) < labels->words && test_bit(bit, labels->bits);
+	return test_bit(bit, labels->bits);
 }
 
 static bool
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index b4069a9..c644c78 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -135,7 +135,7 @@ static void ovs_ct_get_labels(const struct nf_conn *ct,
 	struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
 
 	if (cl) {
-		size_t len = cl->words * sizeof(long);
+		size_t len = sizeof(cl->bits);
 
 		if (len > OVS_CT_LABELS_LEN)
 			len = OVS_CT_LABELS_LEN;
@@ -274,7 +274,7 @@ static int ovs_ct_set_labels(struct sk_buff *skb, struct sw_flow_key *key,
 		nf_ct_labels_ext_add(ct);
 		cl = nf_ct_labels_find(ct);
 	}
-	if (!cl || cl->words * sizeof(long) < OVS_CT_LABELS_LEN)
+	if (!cl || sizeof(cl->bits) < OVS_CT_LABELS_LEN)
 		return -ENOSPC;
 
 	err = nf_connlabels_replace(ct, (u32 *)labels, (u32 *)mask,
-- 
2.1.4

