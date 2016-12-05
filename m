From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon,  5 Dec 2016 15:28:04 -0500
Message-ID: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: pablo@netfilter.org, netdev@vger.kernel.org, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

Add support for attaching an eBPF object by file descriptor.

The iptables binary can be called with a path to an elf object or a
pinned bpf object. Also pass the mode and path to the kernel to be
able to return it later for iptables dump and save.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/netfilter/xt_bpf.h | 21 ++++++++
 net/netfilter/xt_bpf.c                | 96 +++++++++++++++++++++++++++++------
 2 files changed, 101 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index 1fad2c2..652d2b6 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -2,9 +2,11 @@
 #define _XT_BPF_H
 
 #include <linux/filter.h>
+#include <linux/limits.h>
 #include <linux/types.h>
 
 #define XT_BPF_MAX_NUM_INSTR	64
+#define XT_BPF_MAX_NUM_INSTR_V1	(PATH_MAX / sizeof(struct sock_filter))
 
 struct bpf_prog;
 
@@ -16,4 +18,23 @@ struct xt_bpf_info {
 	struct bpf_prog *filter __attribute__((aligned(8)));
 };
 
+enum xt_bpf_modes {
+	XT_BPF_MODE_BYTECODE,
+	XT_BPF_MODE_FD_PINNED,
+	XT_BPF_MODE_FD_ELF,
+};
+
+struct xt_bpf_info_v1 {
+	__u16 mode;
+	__u16 bpf_program_num_elem;
+	__s32 fd;
+	union {
+		struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR_V1];
+		char path[PATH_MAX];
+	};
+
+	/* only used in the kernel */
+	struct bpf_prog *filter __attribute__((aligned(8)));
+};
+
 #endif /*_XT_BPF_H */
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
index dffee9d47..2dedaa2 100644
--- a/net/netfilter/xt_bpf.c
+++ b/net/netfilter/xt_bpf.c
@@ -10,6 +10,7 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/filter.h>
+#include <linux/bpf.h>
 
 #include <linux/netfilter/xt_bpf.h>
 #include <linux/netfilter/x_tables.h>
@@ -20,15 +21,15 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_bpf");
 MODULE_ALIAS("ip6t_bpf");
 
-static int bpf_mt_check(const struct xt_mtchk_param *par)
+static int __bpf_mt_check_bytecode(struct sock_filter *insns, __u16 len,
+				   struct bpf_prog **ret)
 {
-	struct xt_bpf_info *info = par->matchinfo;
 	struct sock_fprog_kern program;
 
-	program.len = info->bpf_program_num_elem;
-	program.filter = info->bpf_program;
+	program.len = len;
+	program.filter = insns;
 
-	if (bpf_prog_create(&info->filter, &program)) {
+	if (bpf_prog_create(ret, &program)) {
 		pr_info("bpf: check failed: parse error\n");
 		return -EINVAL;
 	}
@@ -36,6 +37,42 @@ static int bpf_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
+static int __bpf_mt_check_fd(int fd, struct bpf_prog **ret)
+{
+	struct bpf_prog *prog;
+
+	prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_FILTER);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	*ret = prog;
+	return 0;
+}
+
+static int bpf_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_bpf_info *info = par->matchinfo;
+
+	return __bpf_mt_check_bytecode(info->bpf_program,
+				       info->bpf_program_num_elem,
+				       &info->filter);
+}
+
+static int bpf_mt_check_v1(const struct xt_mtchk_param *par)
+{
+	struct xt_bpf_info_v1 *info = par->matchinfo;
+
+	if (info->mode == XT_BPF_MODE_BYTECODE)
+		return __bpf_mt_check_bytecode(info->bpf_program,
+					       info->bpf_program_num_elem,
+					       &info->filter);
+	else if (info->mode == XT_BPF_MODE_FD_PINNED ||
+		 info->mode == XT_BPF_MODE_FD_ELF)
+		return __bpf_mt_check_fd(info->fd, &info->filter);
+	else
+		return -EINVAL;
+}
+
 static bool bpf_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
@@ -43,31 +80,58 @@ static bool bpf_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	return BPF_PROG_RUN(info->filter, skb);
 }
 
+static bool bpf_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_bpf_info_v1 *info = par->matchinfo;
+
+	return !!bpf_prog_run_save_cb(info->filter, (struct sk_buff *) skb);
+}
+
 static void bpf_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
+
+	bpf_prog_destroy(info->filter);
+}
+
+static void bpf_mt_destroy_v1(const struct xt_mtdtor_param *par)
+{
+	const struct xt_bpf_info_v1 *info = par->matchinfo;
+
 	bpf_prog_destroy(info->filter);
 }
 
-static struct xt_match bpf_mt_reg __read_mostly = {
-	.name		= "bpf",
-	.revision	= 0,
-	.family		= NFPROTO_UNSPEC,
-	.checkentry	= bpf_mt_check,
-	.match		= bpf_mt,
-	.destroy	= bpf_mt_destroy,
-	.matchsize	= sizeof(struct xt_bpf_info),
-	.me		= THIS_MODULE,
+static struct xt_match bpf_mt_reg[] __read_mostly = {
+	{
+		.name		= "bpf",
+		.revision	= 0,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= bpf_mt_check,
+		.match		= bpf_mt,
+		.destroy	= bpf_mt_destroy,
+		.matchsize	= sizeof(struct xt_bpf_info),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "bpf",
+		.revision	= 1,
+		.family		= NFPROTO_UNSPEC,
+		.checkentry	= bpf_mt_check_v1,
+		.match		= bpf_mt_v1,
+		.destroy	= bpf_mt_destroy_v1,
+		.matchsize	= sizeof(struct xt_bpf_info_v1),
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init bpf_mt_init(void)
 {
-	return xt_register_match(&bpf_mt_reg);
+	return xt_register_matches(bpf_mt_reg, ARRAY_SIZE(bpf_mt_reg));
 }
 
 static void __exit bpf_mt_exit(void)
 {
-	xt_unregister_match(&bpf_mt_reg);
+	xt_unregister_matches(bpf_mt_reg, ARRAY_SIZE(bpf_mt_reg));
 }
 
 module_init(bpf_mt_init);
-- 
2.8.0.rc3.226.g39d4020

