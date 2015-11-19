From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/7] netfilter: implement xt_cgroup2 match
Date: Thu, 19 Nov 2015 13:52:51 -0500
Message-ID: <1447959171-20749-8-git-send-email-tj@kernel.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, Tejun Heo <tj@kernel.org>,
	Jan Engelhardt <jengelh@inai.de>
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447959171-20749-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements xt_cgroup2 which matches cgroup2 membership of
the associated socket.  The match is recursive and invertible.

For rationales on introducing another cgroup based match, please refer
to a preceding commit "sock, cgroup: add sock->sk_cgroup".

v2: Included linux/limits.h from xt_cgroup2.h for PATH_MAX.  Added
    explicit alignment to the priv field.  Both suggested by Jan.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
CC: Neil Horman <nhorman@tuxdriver.com>
Cc: Jan Engelhardt <jengelh@inai.de>
---
 include/uapi/linux/netfilter/xt_cgroup2.h | 15 ++++++
 net/netfilter/Kconfig                     | 10 ++++
 net/netfilter/Makefile                    |  1 +
 net/netfilter/xt_cgroup2.c                | 78 +++++++++++++++++++++++++++++++
 4 files changed, 104 insertions(+)
 create mode 100644 include/uapi/linux/netfilter/xt_cgroup2.h
 create mode 100644 net/netfilter/xt_cgroup2.c

diff --git a/include/uapi/linux/netfilter/xt_cgroup2.h b/include/uapi/linux/netfilter/xt_cgroup2.h
new file mode 100644
index 0000000..ea51335
--- /dev/null
+++ b/include/uapi/linux/netfilter/xt_cgroup2.h
@@ -0,0 +1,15 @@
+#ifndef _XT_CGROUP2_H
+#define _XT_CGROUP2_H
+
+#include <linux/types.h>
+#include <linux/limits.h>
+
+struct xt_cgroup2_info {
+	char		path[PATH_MAX];
+	__u8		invert;
+
+	/* kernel internal data */
+	void		*priv __attribute__((aligned(8)));
+};
+
+#endif /* _XT_CGROUP2_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e22349e..5fd12dd 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -974,6 +974,16 @@ config NETFILTER_XT_MATCH_BPF
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config NETFILTER_XT_MATCH_CGROUP2
+	tristate '"cgroup2" match support'
+	depends on NETFILTER_ADVANCED
+	depends on CGROUPS
+	select SOCK_CGROUP_DATA
+	help
+	  cgroup2 matching allows you to match locally generated and
+	  early demuxed packets based on the v2 cgroup the socket is
+	  associated with on creation.
+
 config NETFILTER_XT_MATCH_CGROUP
 	tristate '"control group" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7638c36..86cee05 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -152,6 +152,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_NFACCT) += xt_nfacct.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CGROUP2) += xt_cgroup2.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CGROUP) += xt_cgroup.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
diff --git a/net/netfilter/xt_cgroup2.c b/net/netfilter/xt_cgroup2.c
new file mode 100644
index 0000000..39884b3
--- /dev/null
+++ b/net/netfilter/xt_cgroup2.c
@@ -0,0 +1,78 @@
+#include <linux/skbuff.h>
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_cgroup2.h>
+#include <net/sock.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Tejun Heo <tj@kernel.org>");
+MODULE_DESCRIPTION("Xtables: cgroup2 socket ownership matching");
+MODULE_ALIAS("ipt_cgroup2");
+MODULE_ALIAS("ip6t_cgroup2");
+
+static int cgroup2_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_cgroup2_info *info = par->matchinfo;
+	struct cgroup *cgrp;
+
+	if (info->invert & ~1)
+		return -EINVAL;
+
+	cgrp = cgroup_get_from_path(info->path);
+	if (IS_ERR(cgrp)) {
+		pr_info("xt_cgroup2: invalid path, errno=%ld\n", PTR_ERR(cgrp));
+		return -EINVAL;
+	}
+	info->priv = cgrp;
+
+	return 0;
+}
+
+static bool cgroup2_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_cgroup2_info *info = par->matchinfo;
+	struct cgroup *ancestor = info->priv;
+	struct cgroup *cgrp;
+
+	if (!skb->sk || !sk_fullsock(skb->sk))
+		return false;
+
+	cgrp = sock_cgroup_ptr(&skb->sk->sk_cgrp_data);
+
+	return cgroup_is_descendant(cgrp, ancestor) ^ info->invert;
+}
+
+static void cgroup2_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	struct xt_cgroup2_info *info = par->matchinfo;
+
+	cgroup_put(info->priv);
+}
+
+static struct xt_match cgroup2_mt_reg __read_mostly = {
+	.name		= "cgroup2",
+	.revision	= 0,
+	.family		= NFPROTO_UNSPEC,
+	.checkentry	= cgroup2_mt_check,
+	.match		= cgroup2_mt,
+	.matchsize	= sizeof(struct xt_cgroup2_info),
+	.destroy	= cgroup2_mt_destroy,
+	.me		= THIS_MODULE,
+	.hooks		= (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_IN),
+};
+
+static int __init cgroup2_mt_init(void)
+{
+	return xt_register_match(&cgroup2_mt_reg);
+}
+
+static void __exit cgroup2_mt_exit(void)
+{
+	xt_unregister_match(&cgroup2_mt_reg);
+}
+
+module_init(cgroup2_mt_init);
+module_exit(cgroup2_mt_exit);
-- 
2.5.0
