From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: nfnetlink_acct: Adding quota support to accounting framework
Date: Thu, 29 May 2014 17:54:59 +0200
Message-ID: <1401378900-12436-3-git-send-email-pablo@netfilter.org>
References: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58798 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934189AbaE2PzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:55:13 -0400
In-Reply-To: <1401378900-12436-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Poirier <mathieu.poirier@linaro.org>

nfacct objects already support accounting at the byte and packet
level.  As such it is a natural extension to add the possiblity to
define a ceiling limit for both metrics.

All the support for quotas itself is added to nfnetlink acctounting
framework to stay coherent with current accounting object management.
Quota limit checks are implemented in xt_nfacct filter where
statistic collection is already done.

Pablo Neira Ayuso has also contributed to this feature.

Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_acct.h      |    8 ++-
 include/uapi/linux/netfilter/nfnetlink.h      |    2 +
 include/uapi/linux/netfilter/nfnetlink_acct.h |    9 +++
 net/netfilter/nfnetlink_acct.c                |   85 +++++++++++++++++++++++++
 net/netfilter/xt_nfacct.c                     |    5 +-
 5 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_acct.h b/include/linux/netfilter/nfnetlink_acct.h
index b2e85e5..6ec9757 100644
--- a/include/linux/netfilter/nfnetlink_acct.h
+++ b/include/linux/netfilter/nfnetlink_acct.h
@@ -3,11 +3,17 @@
 
 #include <uapi/linux/netfilter/nfnetlink_acct.h>
 
+enum {
+	NFACCT_NO_QUOTA		= -1,
+	NFACCT_UNDERQUOTA,
+	NFACCT_OVERQUOTA,
+};
 
 struct nf_acct;
 
 struct nf_acct *nfnl_acct_find_get(const char *filter_name);
 void nfnl_acct_put(struct nf_acct *acct);
 void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct);
-
+extern int nfnl_acct_overquota(const struct sk_buff *skb,
+			      struct nf_acct *nfacct);
 #endif /* _NFNL_ACCT_H */
diff --git a/include/uapi/linux/netfilter/nfnetlink.h b/include/uapi/linux/netfilter/nfnetlink.h
index 596ddd4..354a7e5 100644
--- a/include/uapi/linux/netfilter/nfnetlink.h
+++ b/include/uapi/linux/netfilter/nfnetlink.h
@@ -20,6 +20,8 @@ enum nfnetlink_groups {
 #define NFNLGRP_CONNTRACK_EXP_DESTROY	NFNLGRP_CONNTRACK_EXP_DESTROY
 	NFNLGRP_NFTABLES,
 #define NFNLGRP_NFTABLES                NFNLGRP_NFTABLES
+	NFNLGRP_ACCT_QUOTA,
+#define NFNLGRP_ACCT_QUOTA		NFNLGRP_ACCT_QUOTA
 	__NFNLGRP_MAX,
 };
 #define NFNLGRP_MAX	(__NFNLGRP_MAX - 1)
diff --git a/include/uapi/linux/netfilter/nfnetlink_acct.h b/include/uapi/linux/netfilter/nfnetlink_acct.h
index c7b6269..51404ec 100644
--- a/include/uapi/linux/netfilter/nfnetlink_acct.h
+++ b/include/uapi/linux/netfilter/nfnetlink_acct.h
@@ -10,15 +10,24 @@ enum nfnl_acct_msg_types {
 	NFNL_MSG_ACCT_GET,
 	NFNL_MSG_ACCT_GET_CTRZERO,
 	NFNL_MSG_ACCT_DEL,
+	NFNL_MSG_ACCT_OVERQUOTA,
 	NFNL_MSG_ACCT_MAX
 };
 
+enum nfnl_acct_flags {
+	NFACCT_F_QUOTA_PKTS	= (1 << 0),
+	NFACCT_F_QUOTA_BYTES	= (1 << 1),
+	NFACCT_F_OVERQUOTA	= (1 << 2), /* can't be set from userspace */
+};
+
 enum nfnl_acct_type {
 	NFACCT_UNSPEC,
 	NFACCT_NAME,
 	NFACCT_PKTS,
 	NFACCT_BYTES,
 	NFACCT_USE,
+	NFACCT_FLAGS,
+	NFACCT_QUOTA,
 	__NFACCT_MAX
 };
 #define NFACCT_MAX (__NFACCT_MAX - 1)
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index c7b6d46..70e86bb 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -32,18 +32,24 @@ static LIST_HEAD(nfnl_acct_list);
 struct nf_acct {
 	atomic64_t		pkts;
 	atomic64_t		bytes;
+	unsigned long		flags;
 	struct list_head	head;
 	atomic_t		refcnt;
 	char			name[NFACCT_NAME_MAX];
 	struct rcu_head		rcu_head;
+	char			data[0];
 };
 
+#define NFACCT_F_QUOTA (NFACCT_F_QUOTA_PKTS | NFACCT_F_QUOTA_BYTES)
+
 static int
 nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
 {
 	struct nf_acct *nfacct, *matching = NULL;
 	char *acct_name;
+	unsigned int size = 0;
+	u32 flags = 0;
 
 	if (!tb[NFACCT_NAME])
 		return -EINVAL;
@@ -68,15 +74,39 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 			/* reset counters if you request a replacement. */
 			atomic64_set(&matching->pkts, 0);
 			atomic64_set(&matching->bytes, 0);
+			smp_mb__before_clear_bit();
+			/* reset overquota flag if quota is enabled. */
+			if ((matching->flags & NFACCT_F_QUOTA))
+				clear_bit(NFACCT_F_OVERQUOTA, &matching->flags);
 			return 0;
 		}
 		return -EBUSY;
 	}
 
 	nfacct = kzalloc(sizeof(struct nf_acct), GFP_KERNEL);
+	if (tb[NFACCT_FLAGS]) {
+		flags = ntohl(nla_get_be32(tb[NFACCT_FLAGS]));
+		if (flags & ~NFACCT_F_QUOTA)
+			return -EOPNOTSUPP;
+		if ((flags & NFACCT_F_QUOTA) == NFACCT_F_QUOTA)
+			return -EINVAL;
+		if (flags & NFACCT_F_OVERQUOTA)
+			return -EINVAL;
+
+		size += sizeof(u64);
+	}
+
+	nfacct = kzalloc(sizeof(struct nf_acct) + size, GFP_KERNEL);
 	if (nfacct == NULL)
 		return -ENOMEM;
 
+	if (flags & NFACCT_F_QUOTA) {
+		u64 *quota = (u64 *)nfacct->data;
+
+		*quota = be64_to_cpu(nla_get_be64(tb[NFACCT_QUOTA]));
+		nfacct->flags = flags;
+	}
+
 	strncpy(nfacct->name, nla_data(tb[NFACCT_NAME]), NFACCT_NAME_MAX);
 
 	if (tb[NFACCT_BYTES]) {
@@ -117,6 +147,9 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	if (type == NFNL_MSG_ACCT_GET_CTRZERO) {
 		pkts = atomic64_xchg(&acct->pkts, 0);
 		bytes = atomic64_xchg(&acct->bytes, 0);
+		smp_mb__before_clear_bit();
+		if (acct->flags & NFACCT_F_QUOTA)
+			clear_bit(NFACCT_F_OVERQUOTA, &acct->flags);
 	} else {
 		pkts = atomic64_read(&acct->pkts);
 		bytes = atomic64_read(&acct->bytes);
@@ -125,7 +158,13 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	    nla_put_be64(skb, NFACCT_BYTES, cpu_to_be64(bytes)) ||
 	    nla_put_be32(skb, NFACCT_USE, htonl(atomic_read(&acct->refcnt))))
 		goto nla_put_failure;
+	if (acct->flags & NFACCT_F_QUOTA) {
+		u64 *quota = (u64 *)acct->data;
 
+		if (nla_put_be32(skb, NFACCT_FLAGS, htonl(acct->flags)) ||
+		    nla_put_be64(skb, NFACCT_QUOTA, cpu_to_be64(*quota)))
+			goto nla_put_failure;
+	}
 	nlmsg_end(skb, nlh);
 	return skb->len;
 
@@ -270,6 +309,8 @@ static const struct nla_policy nfnl_acct_policy[NFACCT_MAX+1] = {
 	[NFACCT_NAME] = { .type = NLA_NUL_STRING, .len = NFACCT_NAME_MAX-1 },
 	[NFACCT_BYTES] = { .type = NLA_U64 },
 	[NFACCT_PKTS] = { .type = NLA_U64 },
+	[NFACCT_FLAGS] = { .type = NLA_U32 },
+	[NFACCT_QUOTA] = { .type = NLA_U64 },
 };
 
 static const struct nfnl_callback nfnl_acct_cb[NFNL_MSG_ACCT_MAX] = {
@@ -336,6 +377,50 @@ void nfnl_acct_update(const struct sk_buff *skb, struct nf_acct *nfacct)
 }
 EXPORT_SYMBOL_GPL(nfnl_acct_update);
 
+static void nfnl_overquota_report(struct nf_acct *nfacct)
+{
+	int ret;
+	struct sk_buff *skb;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (skb == NULL)
+		return;
+
+	ret = nfnl_acct_fill_info(skb, 0, 0, NFNL_MSG_ACCT_OVERQUOTA, 0,
+				  nfacct);
+	if (ret <= 0) {
+		kfree_skb(skb);
+		return;
+	}
+	netlink_broadcast(init_net.nfnl, skb, 0, NFNLGRP_ACCT_QUOTA,
+			  GFP_ATOMIC);
+}
+
+int nfnl_acct_overquota(const struct sk_buff *skb, struct nf_acct *nfacct)
+{
+	u64 now;
+	u64 *quota;
+	int ret = NFACCT_UNDERQUOTA;
+
+	/* no place here if we don't have a quota */
+	if (!(nfacct->flags & NFACCT_F_QUOTA))
+		return NFACCT_NO_QUOTA;
+
+	quota = (u64 *)nfacct->data;
+	now = (nfacct->flags & NFACCT_F_QUOTA_PKTS) ?
+	       atomic64_read(&nfacct->pkts) : atomic64_read(&nfacct->bytes);
+
+	ret = now > *quota;
+
+	if (now >= *quota &&
+	    !test_and_set_bit(NFACCT_F_OVERQUOTA, &nfacct->flags)) {
+		nfnl_overquota_report(nfacct);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(nfnl_acct_overquota);
+
 static int __init nfnl_acct_init(void)
 {
 	int ret;
diff --git a/net/netfilter/xt_nfacct.c b/net/netfilter/xt_nfacct.c
index b3be0ef..8c646ed 100644
--- a/net/netfilter/xt_nfacct.c
+++ b/net/netfilter/xt_nfacct.c
@@ -21,11 +21,14 @@ MODULE_ALIAS("ip6t_nfacct");
 
 static bool nfacct_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
+	int overquota;
 	const struct xt_nfacct_match_info *info = par->targinfo;
 
 	nfnl_acct_update(skb, info->nfacct);
 
-	return true;
+	overquota = nfnl_acct_overquota(skb, info->nfacct);
+
+	return overquota == NFACCT_UNDERQUOTA ? false : true;
 }
 
 static int
-- 
1.7.10.4
