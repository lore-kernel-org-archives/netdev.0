From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/8] netfilter: prepare xt_cgroup for multi revisions
Date: Mon,  7 Dec 2015 17:38:54 -0500
Message-ID: <1449527935-27056-8-git-send-email-tj@kernel.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com, Tejun Heo <tj@kernel.org>,
	Jan Engelhardt <jengelh@inai.de>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449527935-27056-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xt_cgroup will grow cgroup2 path based match.  Postfix existing
symbols with _v0 and prepare for multi revision registration.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: Neil Horman <nhorman@tuxdriver.com>
Cc: Jan Engelhardt <jengelh@inai.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_cgroup.h |  2 +-
 net/netfilter/xt_cgroup.c                | 36 +++++++++++++++++---------------
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_cgroup.h b/include/uapi/linux/netfilter/xt_cgroup.h
index 43acb7e..577c9e0 100644
--- a/include/uapi/linux/netfilter/xt_cgroup.h
+++ b/include/uapi/linux/netfilter/xt_cgroup.h
@@ -3,7 +3,7 @@
 
 #include <linux/types.h>
 
-struct xt_cgroup_info {
+struct xt_cgroup_info_v0 {
 	__u32 id;
 	__u32 invert;
 };
diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index 54eaeb4..1730025 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -24,9 +24,9 @@ MODULE_DESCRIPTION("Xtables: process control group matching");
 MODULE_ALIAS("ipt_cgroup");
 MODULE_ALIAS("ip6t_cgroup");
 
-static int cgroup_mt_check(const struct xt_mtchk_param *par)
+static int cgroup_mt_check_v0(const struct xt_mtchk_param *par)
 {
-	struct xt_cgroup_info *info = par->matchinfo;
+	struct xt_cgroup_info_v0 *info = par->matchinfo;
 
 	if (info->invert & ~1)
 		return -EINVAL;
@@ -35,9 +35,9 @@ static int cgroup_mt_check(const struct xt_mtchk_param *par)
 }
 
 static bool
-cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
+cgroup_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_cgroup_info *info = par->matchinfo;
+	const struct xt_cgroup_info_v0 *info = par->matchinfo;
 
 	if (skb->sk == NULL || !sk_fullsock(skb->sk))
 		return false;
@@ -46,27 +46,29 @@ cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		info->invert;
 }
 
-static struct xt_match cgroup_mt_reg __read_mostly = {
-	.name       = "cgroup",
-	.revision   = 0,
-	.family     = NFPROTO_UNSPEC,
-	.checkentry = cgroup_mt_check,
-	.match      = cgroup_mt,
-	.matchsize  = sizeof(struct xt_cgroup_info),
-	.me         = THIS_MODULE,
-	.hooks      = (1 << NF_INET_LOCAL_OUT) |
-		      (1 << NF_INET_POST_ROUTING) |
-		      (1 << NF_INET_LOCAL_IN),
+static struct xt_match cgroup_mt_reg[] __read_mostly = {
+	{
+		.name		= "cgroup",
+		.revision	= 0,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= cgroup_mt_check_v0,
+		.match		= cgroup_mt_v0,
+		.matchsize	= sizeof(struct xt_cgroup_info_v0),
+		.me		= THIS_MODULE,
+		.hooks		= (1 << NF_INET_LOCAL_OUT) |
+				  (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+	},
 };
 
 static int __init cgroup_mt_init(void)
 {
-	return xt_register_match(&cgroup_mt_reg);
+	return xt_register_matches(cgroup_mt_reg, ARRAY_SIZE(cgroup_mt_reg));
 }
 
 static void __exit cgroup_mt_exit(void)
 {
-	xt_unregister_match(&cgroup_mt_reg);
+	xt_unregister_matches(cgroup_mt_reg, ARRAY_SIZE(cgroup_mt_reg));
 }
 
 module_init(cgroup_mt_init);
-- 
2.5.0
