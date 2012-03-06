From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: [PATCH 1/1] netfilter: xt_recent: Add optional mask option for xt_recent
Date: Tue,  6 Mar 2012 13:24:44 +0200
Message-ID: <1331033084-23803-1-git-send-email-denys@visp.net.lb>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Denys Fedoryshchenko <denys@visp.net.lb>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use case for this feature:
1)In some occasions if you need to allow,block,match specific subnet.
2)I can use recent as a trigger when netfilter rule matches, with mask 0.0.0.0

Example:

If you ping 8.8.8.8, after that you can't ping 2.2.2.10

Tested for backward compatibility:
)old (userspace) iptables, new kernel
)old kernel, new iptables
)new kernel, new iptables

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
---
 include/linux/netfilter.h           |   11 +++++
 include/linux/netfilter/xt_recent.h |   10 +++++
 net/netfilter/xt_recent.c           |   70 +++++++++++++++++++++++++++++++----
 3 files changed, 83 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index b809265..c132de6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -85,6 +85,17 @@ static inline int NF_DROP_GETERR(int verdict)
	return -(verdict >> NF_VERDICT_QBITS);
 }

+
+static inline void nf_inet_addr_mask(const union nf_inet_addr *a1,
+				    union nf_inet_addr *result,
+				    const union nf_inet_addr *mask)
+{
+	result->all[0] = a1->all[0] & mask->all[0];
+	result->all[1] = a1->all[1] & mask->all[1];
+	result->all[2] = a1->all[2] & mask->all[2];
+	result->all[3] = a1->all[3] & mask->all[3];
+}
+
 static inline int nf_inet_addr_cmp(const union nf_inet_addr *a1,
				   const union nf_inet_addr *a2)
 {
diff --git a/include/linux/netfilter/xt_recent.h b/include/linux/netfilter/xt_recent.h
index 83318e0..6ef36c1 100644
--- a/include/linux/netfilter/xt_recent.h
+++ b/include/linux/netfilter/xt_recent.h
@@ -32,4 +32,14 @@ struct xt_recent_mtinfo {
	__u8 side;
 };

+struct xt_recent_mtinfo_v1 {
+	__u32 seconds;
+	__u32 hit_count;
+	__u8 check_set;
+	__u8 invert;
+	char name[XT_RECENT_NAME_LEN];
+	__u8 side;
+	union nf_inet_addr mask;
+};
+
 #endif /* _LINUX_NETFILTER_XT_RECENT_H */
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index d2ff15a..bdc38fa 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -75,6 +75,7 @@ struct recent_entry {
 struct recent_table {
	struct list_head	list;
	char			name[XT_RECENT_NAME_LEN];
+	union nf_inet_addr	mask;
	unsigned int		refcnt;
	unsigned int		entries;
	struct list_head	lru_list;
@@ -228,10 +229,11 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
	struct net *net = dev_net(par->in ? par->in : par->out);
	struct recent_net *recent_net = recent_pernet(net);
-	const struct xt_recent_mtinfo *info = par->matchinfo;
+	const struct xt_recent_mtinfo_v1 *info = par->matchinfo;
	struct recent_table *t;
	struct recent_entry *e;
	union nf_inet_addr addr = {};
+	union nf_inet_addr addr_masked;
	u_int8_t ttl;
	bool ret = info->invert;

@@ -261,12 +263,15 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)

	spin_lock_bh(&recent_lock);
	t = recent_table_lookup(recent_net, info->name);
-	e = recent_entry_lookup(t, &addr, par->family,
+
+	nf_inet_addr_mask(&addr, &addr_masked, &t->mask);
+
+	e = recent_entry_lookup(t, &addr_masked, par->family,
				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
	if (e == NULL) {
		if (!(info->check_set & XT_RECENT_SET))
			goto out;
-		e = recent_entry_init(t, &addr, par->family, ttl);
+		e = recent_entry_init(t, &addr_masked, par->family, ttl);
		if (e == NULL)
			par->hotdrop = true;
		ret = !ret;
@@ -306,10 +311,10 @@ out:
	return ret;
 }

-static int recent_mt_check(const struct xt_mtchk_param *par)
+static int recent_mt_check(const struct xt_mtchk_param *par,
+	const struct xt_recent_mtinfo_v1 *info)
 {
	struct recent_net *recent_net = recent_pernet(par->net);
-	const struct xt_recent_mtinfo *info = par->matchinfo;
	struct recent_table *t;
 #ifdef CONFIG_PROC_FS
	struct proc_dir_entry *pde;
@@ -361,6 +366,8 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
		goto out;
	}
	t->refcnt = 1;
+
+	memcpy(&t->mask, &info->mask, sizeof(t->mask));
	strcpy(t->name, info->name);
	INIT_LIST_HEAD(&t->lru_list);
	for (i = 0; i < ip_list_hash_size; i++)
@@ -385,10 +392,37 @@ out:
	return ret;
 }

+static int recent_mt_check_v0(const struct xt_mtchk_param *par)
+{
+	const struct xt_recent_mtinfo_v0 *info_v0 = par->matchinfo;
+	struct xt_recent_mtinfo_v1 *info_v1 = par->matchinfo;
+	int ret;
+
+	info_v1 = kzalloc(sizeof(struct xt_recent_mtinfo_v1),
+		    GFP_KERNEL);
+	if (info_v1 == NULL)
+		return -ENOMEM;
+
+
+	/* Copy old data */
+	memcpy(info_v1, info_v0, sizeof(struct xt_recent_mtinfo));
+	/* Default mask will make same behavior as old recent */
+	memset(info_v1->mask.all, 0xFF, sizeof(info_v1->mask.all));
+	ret = recent_mt_check(par, info_v1);
+
+	kfree(info_v1);
+	return ret;
+}
+
+static int recent_mt_check_v1(const struct xt_mtchk_param *par)
+{
+	return recent_mt_check(par, par->matchinfo);
+}
+
 static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 {
	struct recent_net *recent_net = recent_pernet(par->net);
-	const struct xt_recent_mtinfo *info = par->matchinfo;
+	const struct xt_recent_mtinfo_v1 *info = par->matchinfo;
	struct recent_table *t;

	mutex_lock(&recent_mutex);
@@ -625,7 +659,7 @@ static struct xt_match recent_mt_reg[] __read_mostly = {
		.family     = NFPROTO_IPV4,
		.match      = recent_mt,
		.matchsize  = sizeof(struct xt_recent_mtinfo),
-		.checkentry = recent_mt_check,
+		.checkentry = recent_mt_check_v0,
		.destroy    = recent_mt_destroy,
		.me         = THIS_MODULE,
	},
@@ -635,10 +669,30 @@ static struct xt_match recent_mt_reg[] __read_mostly = {
		.family     = NFPROTO_IPV6,
		.match      = recent_mt,
		.matchsize  = sizeof(struct xt_recent_mtinfo),
-		.checkentry = recent_mt_check,
+		.checkentry = recent_mt_check_v0,
		.destroy    = recent_mt_destroy,
		.me         = THIS_MODULE,
	},
+	{
+		.name       = "recent",
+		.revision   = 1,
+		.family     = NFPROTO_IPV4,
+		.match      = recent_mt,
+		.matchsize  = sizeof(struct xt_recent_mtinfo_v1),
+		.checkentry = recent_mt_check_v1,
+		.destroy    = recent_mt_destroy,
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "recent",
+		.revision   = 1,
+		.family     = NFPROTO_IPV6,
+		.match      = recent_mt,
+		.matchsize  = sizeof(struct xt_recent_mtinfo_v1),
+		.checkentry = recent_mt_check_v1,
+		.destroy    = recent_mt_destroy,
+		.me         = THIS_MODULE,
+	}
 };

 static int __init recent_mt_init(void)
--
1.7.3.4
