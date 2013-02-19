From: pablo@netfilter.org
Subject: [PATCH 4/7] netfilter: xt_CT: add alias flag
Date: Tue, 19 Feb 2013 01:10:48 +0100
Message-ID: <1361232651-5626-5-git-send-email-pablo@netfilter.org>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the alias flag to support full NOTRACK target
aliasing.

Based on initial patch from Jozsef Kadlecsik.

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hi>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_CT.h |    6 +++++-
 net/netfilter/xt_CT.c                |   32 +++++++++++++++++++++++++++++---
 2 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_CT.h b/include/uapi/linux/netfilter/xt_CT.h
index a064b8a..5a688c1 100644
--- a/include/uapi/linux/netfilter/xt_CT.h
+++ b/include/uapi/linux/netfilter/xt_CT.h
@@ -3,7 +3,11 @@
 
 #include <linux/types.h>
 
-#define XT_CT_NOTRACK	0x1
+enum {
+	XT_CT_NOTRACK		= 1 << 0,
+	XT_CT_NOTRACK_ALIAS	= 1 << 1,
+	XT_CT_MASK		= XT_CT_NOTRACK | XT_CT_NOTRACK_ALIAS,
+};
 
 struct xt_ct_target_info {
 	__u16 flags;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index d69f1c7..a60261c 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -185,9 +185,6 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	struct nf_conn *ct;
 	int ret = -EOPNOTSUPP;
 
-	if (info->flags & ~XT_CT_NOTRACK)
-		return -EINVAL;
-
 	if (info->flags & XT_CT_NOTRACK) {
 		ct = nf_ct_untracked_get();
 		atomic_inc(&ct->ct_general.use);
@@ -256,6 +253,9 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 	};
 	int ret;
 
+	if (info->flags & ~XT_CT_NOTRACK)
+		return -EINVAL;
+
 	memcpy(info_v1.helper, info->helper, sizeof(info->helper));
 
 	ret = xt_ct_tg_check(par, &info_v1);
@@ -269,6 +269,21 @@ static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 
 static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 {
+	struct xt_ct_target_info_v1 *info = par->targinfo;
+
+	if (info->flags & ~XT_CT_NOTRACK)
+		return -EINVAL;
+
+	return xt_ct_tg_check(par, par->targinfo);
+}
+
+static int xt_ct_tg_check_v2(const struct xt_tgchk_param *par)
+{
+	struct xt_ct_target_info_v1 *info = par->targinfo;
+
+	if (info->flags & ~XT_CT_MASK)
+		return -EINVAL;
+
 	return xt_ct_tg_check(par, par->targinfo);
 }
 
@@ -350,6 +365,17 @@ static struct xt_target xt_ct_tg_reg[] __read_mostly = {
 		.table		= "raw",
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "CT",
+		.family		= NFPROTO_UNSPEC,
+		.revision	= 2,
+		.targetsize	= sizeof(struct xt_ct_target_info_v1),
+		.checkentry	= xt_ct_tg_check_v2,
+		.destroy	= xt_ct_tg_destroy_v1,
+		.target		= xt_ct_target_v1,
+		.table		= "raw",
+		.me		= THIS_MODULE,
+	},
 };
 
 static unsigned int
-- 
1.7.10.4

