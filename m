From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Sat, 21 Nov 2015 11:14:01 -0500
Message-ID: <1448122441-9335-10-git-send-email-tj@kernel.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com, Tejun Heo <tj@kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jan Engelhardt <jengelh@inai.de>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.co
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448122441-9335-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements xt_cgroup path match which matches cgroup2
membership of the associated socket.  The match is recursive and
invertible.

For rationales on introducing another cgroup based match, please refer
to a preceding commit "sock, cgroup: add sock->sk_cgroup".

v3: Folded into xt_cgroup as a new revision interface as suggested by
    Pablo.

v2: Included linux/limits.h from xt_cgroup2.h for PATH_MAX.  Added
    explicit alignment to the priv field.  Both suggested by Jan.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: Neil Horman <nhorman@tuxdriver.com>
Cc: Jan Engelhardt <jengelh@inai.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_cgroup.h | 13 ++++++
 net/netfilter/xt_cgroup.c                | 69 ++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/include/uapi/linux/netfilter/xt_cgroup.h b/include/uapi/linux/netfilter/xt_cgroup.h
index 577c9e0..1e4b37b 100644
--- a/include/uapi/linux/netfilter/xt_cgroup.h
+++ b/include/uapi/linux/netfilter/xt_cgroup.h
@@ -2,10 +2,23 @@
 #define _UAPI_XT_CGROUP_H
 
 #include <linux/types.h>
+#include <linux/limits.h>
 
 struct xt_cgroup_info_v0 {
 	__u32 id;
 	__u32 invert;
 };
 
+struct xt_cgroup_info_v1 {
+	__u8		has_path;
+	__u8		has_classid;
+	__u8		invert_path;
+	__u8		invert_classid;
+	char		path[PATH_MAX];
+	__u32		classid;
+
+	/* kernel internal data */
+	void		*priv __attribute__((aligned(8)));
+};
+
 #endif /* _UAPI_XT_CGROUP_H */
diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index 1730025..a086a91 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -34,6 +34,37 @@ static int cgroup_mt_check_v0(const struct xt_mtchk_param *par)
 	return 0;
 }
 
+static int cgroup_mt_check_v1(const struct xt_mtchk_param *par)
+{
+	struct xt_cgroup_info_v1 *info = par->matchinfo;
+	struct cgroup *cgrp;
+
+	if ((info->invert_path & ~1) || (info->invert_classid & ~1))
+		return -EINVAL;
+
+	if (!info->has_path && !info->has_classid) {
+		pr_info("xt_cgroup: no path or classid specified\n");
+		return -EINVAL;
+	}
+
+	if (info->has_path && info->has_classid) {
+		pr_info("xt_cgroup: both path and classid specified\n");
+		return -EINVAL;
+	}
+
+	if (info->has_path) {
+		cgrp = cgroup_get_from_path(info->path);
+		if (IS_ERR(cgrp)) {
+			pr_info("xt_cgroup: invalid path, errno=%ld\n",
+				PTR_ERR(cgrp));
+			return -EINVAL;
+		}
+		info->priv = cgrp;
+	}
+
+	return 0;
+}
+
 static bool
 cgroup_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
@@ -46,6 +77,31 @@ cgroup_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 		info->invert;
 }
 
+static bool cgroup_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cgroup_info_v1 *info = par->matchinfo;
+	struct sock_cgroup_data *skcd = &skb->sk->sk_cgrp_data;
+	struct cgroup *ancestor = info->priv;
+
+	if (!skb->sk || !sk_fullsock(skb->sk))
+		return false;
+
+	if (ancestor)
+		return cgroup_is_descendant(sock_cgroup_ptr(skcd), ancestor) ^
+			info->invert_path;
+	else
+		return (info->classid == sock_cgroup_classid(skcd)) ^
+			info->invert_classid;
+}
+
+static void cgroup_mt_destroy_v1(const struct xt_mtdtor_param *par)
+{
+	struct xt_cgroup_info_v1 *info = par->matchinfo;
+
+	if (info->priv)
+		cgroup_put(info->priv);
+}
+
 static struct xt_match cgroup_mt_reg[] __read_mostly = {
 	{
 		.name		= "cgroup",
@@ -59,6 +115,19 @@ static struct xt_match cgroup_mt_reg[] __read_mostly = {
 				  (1 << NF_INET_POST_ROUTING) |
 				  (1 << NF_INET_LOCAL_IN),
 	},
+	{
+		.name		= "cgroup",
+		.revision	= 1,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= cgroup_mt_check_v1,
+		.match		= cgroup_mt_v1,
+		.matchsize	= sizeof(struct xt_cgroup_info_v1),
+		.destroy	= cgroup_mt_destroy_v1,
+		.me		= THIS_MODULE,
+		.hooks		= (1 << NF_INET_LOCAL_OUT) |
+				  (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+	},
 };
 
 static int __init cgroup_mt_init(void)
-- 
2.5.0
