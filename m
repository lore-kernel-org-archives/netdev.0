From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/5] net: filter: let unattached filters use sock_fprog_kern
Date: Fri, 23 May 2014 18:43:58 +0200
Message-ID: <1400863441-3711-3-git-send-email-dborkman@redhat.com>
References: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbaEWQoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:08 -0400
In-Reply-To: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_unattached_filter_create() API is used by BPF filters that
are not directly attached or related to sockets, and are used in
team, ptp, xt_bpf, cls_bpf, etc. As such all users do their own
internal managment of obtaining filter blocks and thus already
have them in kernel memory and set up before calling into
sk_unattached_filter_create(). As a result, due to __user annotation
in sock_fprog, sparse triggers false positives (incorrect type in
assignment [different address space]) when filters are set up before
passing them to sk_unattached_filter_create(). Therefore, let
sk_unattached_filter_create() API use sock_fprog_kern to overcome
this issue.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/isdn/i4l/isdn_ppp.c              |  4 ++--
 drivers/net/ppp/ppp_generic.c            |  4 ++--
 drivers/net/team/team_mode_loadbalance.c | 10 +++++-----
 include/linux/filter.h                   |  2 +-
 lib/test_bpf.c                           |  2 +-
 net/core/filter.c                        |  2 +-
 net/core/ptp_classifier.c                |  2 +-
 net/netfilter/xt_bpf.c                   |  5 +++--
 net/sched/cls_bpf.c                      |  4 ++--
 9 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index a5da511..61ac632 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -634,7 +634,7 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 #ifdef CONFIG_IPPP_FILTER
 	case PPPIOCSPASS:
 	{
-		struct sock_fprog fprog;
+		struct sock_fprog_kern fprog;
 		struct sock_filter *code;
 		int err, len = get_filter(argp, &code);
 
@@ -653,7 +653,7 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 	}
 	case PPPIOCSACTIVE:
 	{
-		struct sock_fprog fprog;
+		struct sock_fprog_kern fprog;
 		struct sock_filter *code;
 		int err, len = get_filter(argp, &code);
 
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index e3923eb..91d6c12 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -757,7 +757,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		err = get_filter(argp, &code);
 		if (err >= 0) {
-			struct sock_fprog fprog = {
+			struct sock_fprog_kern fprog = {
 				.len = err,
 				.filter = code,
 			};
@@ -778,7 +778,7 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		err = get_filter(argp, &code);
 		if (err >= 0) {
-			struct sock_fprog fprog = {
+			struct sock_fprog_kern fprog = {
 				.len = err,
 				.filter = code,
 			};
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index dbde341..0a6ee07 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -49,7 +49,7 @@ struct lb_port_mapping {
 struct lb_priv_ex {
 	struct team *team;
 	struct lb_port_mapping tx_hash_to_port_mapping[LB_TX_HASHTABLE_SIZE];
-	struct sock_fprog *orig_fprog;
+	struct sock_fprog_kern *orig_fprog;
 	struct {
 		unsigned int refresh_interval; /* in tenths of second */
 		struct delayed_work refresh_dw;
@@ -241,10 +241,10 @@ static int lb_bpf_func_get(struct team *team, struct team_gsetter_ctx *ctx)
 	return 0;
 }
 
-static int __fprog_create(struct sock_fprog **pfprog, u32 data_len,
+static int __fprog_create(struct sock_fprog_kern **pfprog, u32 data_len,
 			  const void *data)
 {
-	struct sock_fprog *fprog;
+	struct sock_fprog_kern *fprog;
 	struct sock_filter *filter = (struct sock_filter *) data;
 
 	if (data_len % sizeof(struct sock_filter))
@@ -262,7 +262,7 @@ static int __fprog_create(struct sock_fprog **pfprog, u32 data_len,
 	return 0;
 }
 
-static void __fprog_destroy(struct sock_fprog *fprog)
+static void __fprog_destroy(struct sock_fprog_kern *fprog)
 {
 	kfree(fprog->filter);
 	kfree(fprog);
@@ -273,7 +273,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 	struct lb_priv *lb_priv = get_lb_priv(team);
 	struct sk_filter *fp = NULL;
 	struct sk_filter *orig_fp;
-	struct sock_fprog *fprog = NULL;
+	struct sock_fprog_kern *fprog = NULL;
 	int err;
 
 	if (ctx->data.bin_val.len) {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 2b0056a..625f4de 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -188,7 +188,7 @@ int sk_convert_filter(struct sock_filter *prog, int len,
 		      struct sock_filter_int *new_prog, int *new_len);
 
 int sk_unattached_filter_create(struct sk_filter **pfp,
-				struct sock_fprog *fprog);
+				struct sock_fprog_kern *fprog);
 void sk_unattached_filter_destroy(struct sk_filter *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 3d80adb..e03991e 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1472,7 +1472,7 @@ static int run_one(struct sk_filter *fp, struct bpf_test *t)
 static __init int test_bpf(void)
 {
 	struct sk_filter *fp, *fp_ext = NULL;
-	struct sock_fprog fprog;
+	struct sock_fprog_kern fprog;
 	int err, i, err_cnt = 0;
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
diff --git a/net/core/filter.c b/net/core/filter.c
index b3b0889..2c2d35d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1585,7 +1585,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
  * a negative errno code is returned. On success the return is zero.
  */
 int sk_unattached_filter_create(struct sk_filter **pfp,
-				struct sock_fprog *fprog)
+				struct sock_fprog_kern *fprog)
 {
 	unsigned int fsize = sk_filter_proglen(fprog);
 	struct sk_filter *fp;
diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index 37d8615..d3027a7 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -133,7 +133,7 @@ void __init ptp_classifier_init(void)
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x06,  0,  0, 0x00000000 },
 	};
-	struct sock_fprog ptp_prog = {
+	struct sock_fprog_kern ptp_prog = {
 		.len = ARRAY_SIZE(ptp_filter), .filter = ptp_filter,
 	};
 
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
index 12d4da8..bbffdbd 100644
--- a/net/netfilter/xt_bpf.c
+++ b/net/netfilter/xt_bpf.c
@@ -23,10 +23,11 @@ MODULE_ALIAS("ip6t_bpf");
 static int bpf_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_bpf_info *info = par->matchinfo;
-	struct sock_fprog program;
+	struct sock_fprog_kern program;
 
 	program.len = info->bpf_program_num_elem;
-	program.filter = (struct sock_filter __user *) info->bpf_program;
+	program.filter = info->bpf_program;
+
 	if (sk_unattached_filter_create(&info->filter, &program)) {
 		pr_info("bpf: check failed: parse error\n");
 		return -EINVAL;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 1618696..13f64df 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -160,7 +160,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 {
 	struct sock_filter *bpf_ops, *bpf_old;
 	struct tcf_exts exts;
-	struct sock_fprog tmp;
+	struct sock_fprog_kern tmp;
 	struct sk_filter *fp, *fp_old;
 	u16 bpf_size, bpf_len;
 	u32 classid;
@@ -191,7 +191,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	memcpy(bpf_ops, nla_data(tb[TCA_BPF_OPS]), bpf_size);
 
 	tmp.len = bpf_len;
-	tmp.filter = (struct sock_filter __user *) bpf_ops;
+	tmp.filter = bpf_ops;
 
 	ret = sk_unattached_filter_create(&fp, &tmp);
 	if (ret)
-- 
1.7.11.7
