From: pablo@netfilter.org
Subject: [PATCH 20/25] netfilter: xt_recent: add address masking option
Date: Mon, 11 Jun 2012 16:43:56 +0200
Message-ID: <1339425841-24171-21-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32918 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436Ab2FKOpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 10:45:09 -0400
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>

The mask option allows you put all address belonging that mask into
the same recent slot. This can be useful in case that recent is used
to detect attacks from the same network segment.

Tested for backward compatibility.

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/feature-removal-schedule.txt |    7 ++++
 include/linux/netfilter.h                  |   10 +++++
 include/linux/netfilter/xt_recent.h        |   10 +++++
 net/netfilter/xt_recent.c                  |   62 ++++++++++++++++++++++++----
 4 files changed, 80 insertions(+), 9 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 24ac00f..bc4b9c6 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -574,6 +574,13 @@ Why:	Remount currently allows changing bound subsystems and
 
 ----------------------------
 
+What:  xt_recent rev 0
+When:  2013
+Who:   Pablo Neira Ayuso <pablo@netfilter.org>
+Files: net/netfilter/xt_recent.c
+
+----------------------------
+
 What:	KVM debugfs statistics
 When:	2013
 Why:	KVM tracepoints provide mostly equivalent information in a much more
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index ff9c84c..4541f33 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -94,6 +94,16 @@ static inline int nf_inet_addr_cmp(const union nf_inet_addr *a1,
 	       a1->all[3] == a2->all[3];
 }
 
+static inline void nf_inet_addr_mask(const union nf_inet_addr *a1,
+				     union nf_inet_addr *result,
+				     const union nf_inet_addr *mask)
+{
+	result->all[0] = a1->all[0] & mask->all[0];
+	result->all[1] = a1->all[1] & mask->all[1];
+	result->all[2] = a1->all[2] & mask->all[2];
+	result->all[3] = a1->all[3] & mask->all[3];
+}
+
 extern void netfilter_init(void);
 
 /* Largest hook number + 1 */
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
index fc0d6db..ae2ad1e 100644
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
@@ -228,10 +229,10 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	struct recent_net *recent_net = recent_pernet(net);
-	const struct xt_recent_mtinfo *info = par->matchinfo;
+	const struct xt_recent_mtinfo_v1 *info = par->matchinfo;
 	struct recent_table *t;
 	struct recent_entry *e;
-	union nf_inet_addr addr = {};
+	union nf_inet_addr addr = {}, addr_mask;
 	u_int8_t ttl;
 	bool ret = info->invert;
 
@@ -261,12 +262,15 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	spin_lock_bh(&recent_lock);
 	t = recent_table_lookup(recent_net, info->name);
-	e = recent_entry_lookup(t, &addr, par->family,
+
+	nf_inet_addr_mask(&addr, &addr_mask, &t->mask);
+
+	e = recent_entry_lookup(t, &addr_mask, par->family,
 				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
 	if (e == NULL) {
 		if (!(info->check_set & XT_RECENT_SET))
 			goto out;
-		e = recent_entry_init(t, &addr, par->family, ttl);
+		e = recent_entry_init(t, &addr_mask, par->family, ttl);
 		if (e == NULL)
 			par->hotdrop = true;
 		ret = !ret;
@@ -306,10 +310,10 @@ out:
 	return ret;
 }
 
-static int recent_mt_check(const struct xt_mtchk_param *par)
+static int recent_mt_check(const struct xt_mtchk_param *par,
+			   const struct xt_recent_mtinfo_v1 *info)
 {
 	struct recent_net *recent_net = recent_pernet(par->net);
-	const struct xt_recent_mtinfo *info = par->matchinfo;
 	struct recent_table *t;
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
@@ -361,6 +365,8 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 		goto out;
 	}
 	t->refcnt = 1;
+
+	memcpy(&t->mask, &info->mask, sizeof(t->mask));
 	strcpy(t->name, info->name);
 	INIT_LIST_HEAD(&t->lru_list);
 	for (i = 0; i < ip_list_hash_size; i++)
@@ -385,10 +391,28 @@ out:
 	return ret;
 }
 
+static int recent_mt_check_v0(const struct xt_mtchk_param *par)
+{
+	const struct xt_recent_mtinfo_v0 *info_v0 = par->matchinfo;
+	struct xt_recent_mtinfo_v1 info_v1;
+
+	/* Copy revision 0 structure to revision 1 */
+	memcpy(&info_v1, info_v0, sizeof(struct xt_recent_mtinfo));
+	/* Set default mask to ensure backward compatible behaviour */
+	memset(info_v1.mask.all, 0xFF, sizeof(info_v1.mask.all));
+
+	return recent_mt_check(par, &info_v1);
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
@@ -625,7 +649,7 @@ static struct xt_match recent_mt_reg[] __read_mostly = {
 		.family     = NFPROTO_IPV4,
 		.match      = recent_mt,
 		.matchsize  = sizeof(struct xt_recent_mtinfo),
-		.checkentry = recent_mt_check,
+		.checkentry = recent_mt_check_v0,
 		.destroy    = recent_mt_destroy,
 		.me         = THIS_MODULE,
 	},
@@ -635,10 +659,30 @@ static struct xt_match recent_mt_reg[] __read_mostly = {
 		.family     = NFPROTO_IPV6,
 		.match      = recent_mt,
 		.matchsize  = sizeof(struct xt_recent_mtinfo),
-		.checkentry = recent_mt_check,
+		.checkentry = recent_mt_check_v0,
+		.destroy    = recent_mt_destroy,
+		.me         = THIS_MODULE,
+	},
+	{
+		.name       = "recent",
+		.revision   = 1,
+		.family     = NFPROTO_IPV4,
+		.match      = recent_mt,
+		.matchsize  = sizeof(struct xt_recent_mtinfo_v1),
+		.checkentry = recent_mt_check_v1,
 		.destroy    = recent_mt_destroy,
 		.me         = THIS_MODULE,
 	},
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
1.7.10
