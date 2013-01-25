From: pablo@netfilter.org
Subject: [PATCH 04/21] netfilter: ctnetlink: allow userspace to modify labels
Date: Fri, 25 Jan 2013 14:54:36 +0100
Message-ID: <1359122093-3404-5-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Add the ability to set/clear labels assigned to a conntrack
via ctnetlink.

To allow userspace to only alter specific bits, Pablo suggested to add
a new CTA_LABELS_MASK attribute:

The new set of active labels is then determined via

active = (active & ~mask) ^ changeset

i.e., the mask selects those bits in the existing set that should be
changed.

This follows the same method already used by MARK and CONNMARK targets.

Omitting CTA_LABELS_MASK is the same as setting all bits in CTA_LABELS_MASK
to 1: The existing set is replaced by the one from userspace.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_labels.h        |    3 ++
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/netfilter/nf_conntrack_labels.c                |   43 +++++++++++++++++++
 net/netfilter/nf_conntrack_netlink.c               |   44 ++++++++++++++++++++
 4 files changed, 91 insertions(+)

diff --git a/include/net/netfilter/nf_conntrack_labels.h b/include/net/netfilter/nf_conntrack_labels.h
index b94fe31..a3ce5d0 100644
--- a/include/net/netfilter/nf_conntrack_labels.h
+++ b/include/net/netfilter/nf_conntrack_labels.h
@@ -46,6 +46,9 @@ static inline struct nf_conn_labels *nf_ct_labels_ext_add(struct nf_conn *ct)
 bool nf_connlabel_match(const struct nf_conn *ct, u16 bit);
 int nf_connlabel_set(struct nf_conn *ct, u16 bit);
 
+int nf_connlabels_replace(struct nf_conn *ct,
+			  const u32 *data, const u32 *mask, unsigned int words);
+
 #ifdef CONFIG_NF_CONNTRACK_LABELS
 int nf_conntrack_labels_init(struct net *net);
 void nf_conntrack_labels_fini(struct net *net);
diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index 9e71e0c..08fabc6 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -50,6 +50,7 @@ enum ctattr_type {
 	CTA_TIMESTAMP,
 	CTA_MARK_MASK,
 	CTA_LABELS,
+	CTA_LABELS_MASK,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index ac5d080..e1d1eb8 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -52,6 +52,49 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 }
 EXPORT_SYMBOL_GPL(nf_connlabel_set);
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
+static void replace_u32(u32 *address, u32 mask, u32 new)
+{
+	u32 old, tmp;
+
+	do {
+		old = *address;
+		tmp = (old & mask) ^ new;
+	} while (cmpxchg(address, old, tmp) != old);
+}
+
+int nf_connlabels_replace(struct nf_conn *ct,
+			  const u32 *data,
+			  const u32 *mask, unsigned int words32)
+{
+	struct nf_conn_labels *labels;
+	unsigned int size, i;
+	u32 *dst;
+
+	labels = nf_ct_labels_find(ct);
+	if (!labels)
+		return -ENOSPC;
+
+	size = labels->words * sizeof(long);
+	if (size < (words32 * sizeof(u32)))
+		words32 = size / sizeof(u32);
+
+	dst = (u32 *) labels->bits;
+	if (words32) {
+		for (i = 0; i < words32; i++)
+			replace_u32(&dst[i], mask ? ~mask[i] : 0, data[i]);
+	}
+
+	size /= sizeof(u32);
+	for (i = words32; i < size; i++) /* pad */
+		replace_u32(&dst[i], 0, 0);
+
+	nf_conntrack_event_cache(IPCT_LABEL, ct);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_connlabels_replace);
+#endif
+
 static struct nf_ct_ext_type labels_extend __read_mostly = {
 	.len    = sizeof(struct nf_conn_labels),
 	.align  = __alignof__(struct nf_conn_labels),
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5f53863..2334cc5 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -961,6 +961,7 @@ ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
 	return 0;
 }
 
+#define __CTA_LABELS_MAX_LENGTH ((XT_CONNLABEL_MAXBIT + 1) / BITS_PER_BYTE)
 static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_TUPLE_ORIG]	= { .type = NLA_NESTED },
 	[CTA_TUPLE_REPLY]	= { .type = NLA_NESTED },
@@ -977,6 +978,10 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_NAT_SEQ_ADJ_REPLY] = { .type = NLA_NESTED },
 	[CTA_ZONE]		= { .type = NLA_U16 },
 	[CTA_MARK_MASK]		= { .type = NLA_U32 },
+	[CTA_LABELS]		= { .type = NLA_BINARY,
+				    .len = __CTA_LABELS_MAX_LENGTH },
+	[CTA_LABELS_MASK]	= { .type = NLA_BINARY,
+				    .len = __CTA_LABELS_MAX_LENGTH },
 };
 
 static int
@@ -1505,6 +1510,31 @@ ctnetlink_change_nat_seq_adj(struct nf_conn *ct,
 #endif
 
 static int
+ctnetlink_attach_labels(struct nf_conn *ct, const struct nlattr * const cda[])
+{
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	size_t len = nla_len(cda[CTA_LABELS]);
+	const void *mask = cda[CTA_LABELS_MASK];
+
+	if (len & (sizeof(u32)-1)) /* must be multiple of u32 */
+		return -EINVAL;
+
+	if (mask) {
+		if (nla_len(cda[CTA_LABELS_MASK]) == 0 ||
+		    nla_len(cda[CTA_LABELS_MASK]) != len)
+			return -EINVAL;
+		mask = nla_data(cda[CTA_LABELS_MASK]);
+	}
+
+	len /= sizeof(u32);
+
+	return nf_connlabels_replace(ct, nla_data(cda[CTA_LABELS]), mask, len);
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
+static int
 ctnetlink_change_conntrack(struct nf_conn *ct,
 			   const struct nlattr * const cda[])
 {
@@ -1550,6 +1580,11 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 			return err;
 	}
 #endif
+	if (cda[CTA_LABELS]) {
+		err = ctnetlink_attach_labels(ct, cda);
+		if (err < 0)
+			return err;
+	}
 
 	return 0;
 }
@@ -1758,6 +1793,10 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			else
 				events = IPCT_NEW;
 
+			if (cda[CTA_LABELS] &&
+			    ctnetlink_attach_labels(ct, cda) == 0)
+				events |= (1 << IPCT_LABEL);
+
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
 						      (1 << IPCT_HELPER) |
@@ -2055,6 +2094,11 @@ ctnetlink_nfqueue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 		if (err < 0)
 			return err;
 	}
+	if (cda[CTA_LABELS]) {
+		err = ctnetlink_attach_labels(ct, cda);
+		if (err < 0)
+			return err;
+	}
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
 		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
-- 
1.7.10.4

