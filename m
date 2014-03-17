From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/38] netfilter: nft_ct: labels get support
Date: Mon, 17 Mar 2014 13:42:23 +0100
Message-ID: <1395060178-11833-4-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This also adds NF_CT_LABELS_MAX_SIZE so it can be re-used
as BUILD_BUG_ON in nft_ct.

At this time, nft doesn't yet support writing to the label area;
when this changes the label->words handling needs to be moved
out of xt_connlabel.c into nf_conntrack_labels.c.

Also removes a useless run-time check: words cannot grow beyond
4 (32 bit) or 2 (64bit) since xt_connlabel enforces a maximum of
128 labels.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h |    4 +++-
 include/uapi/linux/netfilter/nf_tables.h    |    1 +
 net/netfilter/nf_conntrack_netlink.c        |    5 ++---
 net/netfilter/nft_ct.c                      |   24 ++++++++++++++++++++++++
 4 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index c985695..dec6336 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -7,6 +7,8 @@
 
 #include <uapi/linux/netfilter/xt_connlabel.h>
 
+#define NF_CT_LABELS_MAX_SIZE ((XT_CONNLABEL_MAXBIT + 1) / BITS_PER_BYTE)
+
 struct nf_conn_labels {
 	u8 words;
 	unsigned long bits[];
@@ -29,7 +31,7 @@ static inline struct nf_conn_labels *nf_ct_labels_ext_add(struct nf_conn *ct)
 	u8 words;
 
 	words = ACCESS_ONCE(net->ct.label_words);
-	if (words == 0 || WARN_ON_ONCE(words > 8))
+	if (words == 0)
 		return NULL;
 
 	cl_ext = nf_ct_ext_add_length(ct, NF_CT_EXT_LABELS,
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 83c985a..c84c452 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -601,6 +601,7 @@ enum nft_ct_keys {
 	NFT_CT_PROTOCOL,
 	NFT_CT_PROTO_SRC,
 	NFT_CT_PROTO_DST,
+	NFT_CT_LABELS,
 };
 
 /**
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index bb322d0..47e9369 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -966,7 +966,6 @@ ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
 	return 0;
 }
 
-#define __CTA_LABELS_MAX_LENGTH ((XT_CONNLABEL_MAXBIT + 1) / BITS_PER_BYTE)
 static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_TUPLE_ORIG]	= { .type = NLA_NESTED },
 	[CTA_TUPLE_REPLY]	= { .type = NLA_NESTED },
@@ -984,9 +983,9 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_ZONE]		= { .type = NLA_U16 },
 	[CTA_MARK_MASK]		= { .type = NLA_U32 },
 	[CTA_LABELS]		= { .type = NLA_BINARY,
-				    .len = __CTA_LABELS_MAX_LENGTH },
+				    .len = NF_CT_LABELS_MAX_SIZE },
 	[CTA_LABELS_MASK]	= { .type = NLA_BINARY,
-				    .len = __CTA_LABELS_MAX_LENGTH },
+				    .len = NF_CT_LABELS_MAX_SIZE },
 };
 
 static int
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 46e2754..e59b08f 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -19,6 +19,7 @@
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
+#include <net/netfilter/nf_conntrack_labels.h>
 
 struct nft_ct {
 	enum nft_ct_keys	key:8;
@@ -97,6 +98,26 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			goto err;
 		strncpy((char *)dest->data, helper->name, sizeof(dest->data));
 		return;
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS: {
+		struct nf_conn_labels *labels = nf_ct_labels_find(ct);
+		unsigned int size;
+
+		if (!labels) {
+			memset(dest->data, 0, sizeof(dest->data));
+			return;
+		}
+
+		BUILD_BUG_ON(NF_CT_LABELS_MAX_SIZE > sizeof(dest->data));
+		size = labels->words * sizeof(long);
+
+		memcpy(dest->data, labels->bits, size);
+		if (size < sizeof(dest->data))
+			memset(((char *) dest->data) + size, 0,
+			       sizeof(dest->data) - size);
+		return;
+	}
+#endif
 	}
 
 	tuple = &ct->tuplehash[priv->dir].tuple;
@@ -221,6 +242,9 @@ static int nft_ct_init_validate_get(const struct nft_expr *expr,
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	case NFT_CT_SECMARK:
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS:
+#endif
 	case NFT_CT_EXPIRATION:
 	case NFT_CT_HELPER:
 		if (tb[NFTA_CT_DIRECTION] != NULL)
-- 
1.7.10.4

