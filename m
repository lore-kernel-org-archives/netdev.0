From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] act_bpf: add initial eBPF support for actions
Date: Fri, 20 Mar 2015 15:11:12 +0100
Message-ID: <6fcca3889ace4f7f090470e50a001aca721bd0d9.1426859241.git.daniel@iogearbox.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55543 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbCTOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:11:17 -0400
In-Reply-To: <cover.1426859241.git.daniel@iogearbox.net>
In-Reply-To: <cover.1426859241.git.daniel@iogearbox.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work extends the "classic" BPF programmable tc action by extending
its scope also to native eBPF code!

Together with commit e2e9b6541dd4 ("cls_bpf: add initial eBPF support
for programmable classifiers") this adds the facility to implement fully
flexible classifier and actions for tc that can be implemented in a C
subset in user space, "safely" loaded into the kernel, and being run in
native speed when JITed.

Also, since eBPF maps can be shared between eBPF programs, it offers the
possibility that cls_bpf and act_bpf can share data 1) between themselves
and 2) between user space applications. That means that, f.e. customized
runtime statistics can be collected in user space, but also more importantly
classifier and action behaviour could be altered based on map input from
the user space application.

For the remaining details on the workflow and integration, see the cls_bpf
commit e2e9b6541dd4. Preliminary iproute2 part can be found under [1].

  [1] http://git.breakpoint.cc/cgit/dborkman/iproute2.git/log/?h=ebpf-act

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 include/net/tc_act/tc_bpf.h        |   6 +-
 include/uapi/linux/tc_act/tc_bpf.h |   2 +
 net/sched/act_bpf.c                | 295 ++++++++++++++++++++++++++-----------
 3 files changed, 220 insertions(+), 83 deletions(-)

diff --git a/include/net/tc_act/tc_bpf.h b/include/net/tc_act/tc_bpf.h
index 86a070f..a152e98 100644
--- a/include/net/tc_act/tc_bpf.h
+++ b/include/net/tc_act/tc_bpf.h
@@ -16,8 +16,12 @@
 struct tcf_bpf {
 	struct tcf_common	common;
 	struct bpf_prog		*filter;
+	union {
+		u32		bpf_fd;
+		u16		bpf_num_ops;
+	};
 	struct sock_filter	*bpf_ops;
-	u16			bpf_num_ops;
+	const char		*bpf_name;
 };
 #define to_bpf(a) \
 	container_of(a->priv, struct tcf_bpf, common)
diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index 5288bd77..07f17cc 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -24,6 +24,8 @@ enum {
 	TCA_ACT_BPF_PARMS,
 	TCA_ACT_BPF_OPS_LEN,
 	TCA_ACT_BPF_OPS,
+	TCA_ACT_BPF_FD,
+	TCA_ACT_BPF_NAME,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 5f6288f..4d2cede 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -13,26 +13,40 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/filter.h>
+#include <linux/bpf.h>
+
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 #include <linux/tc_act/tc_bpf.h>
 #include <net/tc_act/tc_bpf.h>
 
-#define BPF_TAB_MASK     15
+#define BPF_TAB_MASK		15
+#define ACT_BPF_NAME_LEN	256
+
+struct tcf_bpf_cfg {
+	struct bpf_prog *filter;
+	struct sock_filter *bpf_ops;
+	char *bpf_name;
+	u32 bpf_fd;
+	u16 bpf_num_ops;
+};
 
-static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
+static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
 		   struct tcf_result *res)
 {
-	struct tcf_bpf *b = a->priv;
+	struct tcf_bpf *prog = act->priv;
 	int action, filter_res;
 
-	spin_lock(&b->tcf_lock);
+	spin_lock(&prog->tcf_lock);
 
-	b->tcf_tm.lastuse = jiffies;
-	bstats_update(&b->tcf_bstats, skb);
+	prog->tcf_tm.lastuse = jiffies;
+	bstats_update(&prog->tcf_bstats, skb);
 
-	filter_res = BPF_PROG_RUN(b->filter, skb);
+	/* Needed here for accessing maps. */
+	rcu_read_lock();
+	filter_res = BPF_PROG_RUN(prog->filter, skb);
+	rcu_read_unlock();
 
 	/* A BPF program may overwrite the default action opcode.
 	 * Similarly as in cls_bpf, if filter_res == -1 we use the
@@ -52,52 +66,87 @@ static int tcf_bpf(struct sk_buff *skb, const struct tc_action *a,
 		break;
 	case TC_ACT_SHOT:
 		action = filter_res;
-		b->tcf_qstats.drops++;
+		prog->tcf_qstats.drops++;
 		break;
 	case TC_ACT_UNSPEC:
-		action = b->tcf_action;
+		action = prog->tcf_action;
 		break;
 	default:
 		action = TC_ACT_UNSPEC;
 		break;
 	}
 
-	spin_unlock(&b->tcf_lock);
+	spin_unlock(&prog->tcf_lock);
 	return action;
 }
 
-static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *a,
+static bool tcf_bpf_is_ebpf(const struct tcf_bpf *prog)
+{
+	return !prog->bpf_ops;
+}
+
+static int tcf_bpf_dump_bpf_info(const struct tcf_bpf *prog,
+				 struct sk_buff *skb)
+{
+	struct nlattr *nla;
+
+	if (nla_put_u16(skb, TCA_ACT_BPF_OPS_LEN, prog->bpf_num_ops))
+		return -EMSGSIZE;
+
+	nla = nla_reserve(skb, TCA_ACT_BPF_OPS, prog->bpf_num_ops *
+			  sizeof(struct sock_filter));
+	if (nla == NULL)
+		return -EMSGSIZE;
+
+	memcpy(nla_data(nla), prog->bpf_ops, nla_len(nla));
+
+	return 0;
+}
+
+static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
+				  struct sk_buff *skb)
+{
+	if (nla_put_u32(skb, TCA_ACT_BPF_FD, prog->bpf_fd))
+		return -EMSGSIZE;
+
+	if (prog->bpf_name &&
+	    nla_put_string(skb, TCA_ACT_BPF_NAME, prog->bpf_name))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
 			int bind, int ref)
 {
 	unsigned char *tp = skb_tail_pointer(skb);
-	struct tcf_bpf *b = a->priv;
+	struct tcf_bpf *prog = act->priv;
 	struct tc_act_bpf opt = {
-		.index    = b->tcf_index,
-		.refcnt   = b->tcf_refcnt - ref,
-		.bindcnt  = b->tcf_bindcnt - bind,
-		.action   = b->tcf_action,
+		.index   = prog->tcf_index,
+		.refcnt  = prog->tcf_refcnt - ref,
+		.bindcnt = prog->tcf_bindcnt - bind,
+		.action  = prog->tcf_action,
 	};
-	struct tcf_t t;
-	struct nlattr *nla;
+	struct tcf_t tm;
+	int ret;
 
 	if (nla_put(skb, TCA_ACT_BPF_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
-	if (nla_put_u16(skb, TCA_ACT_BPF_OPS_LEN, b->bpf_num_ops))
-		goto nla_put_failure;
-
-	nla = nla_reserve(skb, TCA_ACT_BPF_OPS, b->bpf_num_ops *
-			  sizeof(struct sock_filter));
-	if (!nla)
+	if (tcf_bpf_is_ebpf(prog))
+		ret = tcf_bpf_dump_ebpf_info(prog, skb);
+	else
+		ret = tcf_bpf_dump_bpf_info(prog, skb);
+	if (ret)
 		goto nla_put_failure;
 
-	memcpy(nla_data(nla), b->bpf_ops, nla_len(nla));
+	tm.install = jiffies_to_clock_t(jiffies - prog->tcf_tm.install);
+	tm.lastuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.lastuse);
+	tm.expires = jiffies_to_clock_t(prog->tcf_tm.expires);
 
-	t.install = jiffies_to_clock_t(jiffies - b->tcf_tm.install);
-	t.lastuse = jiffies_to_clock_t(jiffies - b->tcf_tm.lastuse);
-	t.expires = jiffies_to_clock_t(b->tcf_tm.expires);
-	if (nla_put(skb, TCA_ACT_BPF_TM, sizeof(t), &t))
+	if (nla_put(skb, TCA_ACT_BPF_TM, sizeof(tm), &tm))
 		goto nla_put_failure;
+
 	return skb->len;
 
 nla_put_failure:
@@ -107,36 +156,21 @@ nla_put_failure:
 
 static const struct nla_policy act_bpf_policy[TCA_ACT_BPF_MAX + 1] = {
 	[TCA_ACT_BPF_PARMS]	= { .len = sizeof(struct tc_act_bpf) },
+	[TCA_ACT_BPF_FD]	= { .type = NLA_U32 },
+	[TCA_ACT_BPF_NAME]	= { .type = NLA_NUL_STRING, .len = ACT_BPF_NAME_LEN },
 	[TCA_ACT_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_ACT_BPF_OPS]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
 };
 
-static int tcf_bpf_init(struct net *net, struct nlattr *nla,
-			struct nlattr *est, struct tc_action *a,
-			int ovr, int bind)
+static int tcf_bpf_init_from_ops(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
 {
-	struct nlattr *tb[TCA_ACT_BPF_MAX + 1];
-	struct tc_act_bpf *parm;
-	struct tcf_bpf *b;
-	u16 bpf_size, bpf_num_ops;
 	struct sock_filter *bpf_ops;
-	struct sock_fprog_kern tmp;
+	struct sock_fprog_kern fprog_tmp;
 	struct bpf_prog *fp;
+	u16 bpf_size, bpf_num_ops;
 	int ret;
 
-	if (!nla)
-		return -EINVAL;
-
-	ret = nla_parse_nested(tb, TCA_ACT_BPF_MAX, nla, act_bpf_policy);
-	if (ret < 0)
-		return ret;
-
-	if (!tb[TCA_ACT_BPF_PARMS] ||
-	    !tb[TCA_ACT_BPF_OPS_LEN] || !tb[TCA_ACT_BPF_OPS])
-		return -EINVAL;
-	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
-
 	bpf_num_ops = nla_get_u16(tb[TCA_ACT_BPF_OPS_LEN]);
 	if (bpf_num_ops	> BPF_MAXINSNS || bpf_num_ops == 0)
 		return -EINVAL;
@@ -146,68 +180,165 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 		return -EINVAL;
 
 	bpf_ops = kzalloc(bpf_size, GFP_KERNEL);
-	if (!bpf_ops)
+	if (bpf_ops == NULL)
 		return -ENOMEM;
 
 	memcpy(bpf_ops, nla_data(tb[TCA_ACT_BPF_OPS]), bpf_size);
 
-	tmp.len = bpf_num_ops;
-	tmp.filter = bpf_ops;
+	fprog_tmp.len = bpf_num_ops;
+	fprog_tmp.filter = bpf_ops;
 
-	ret = bpf_prog_create(&fp, &tmp);
-	if (ret)
-		goto free_bpf_ops;
+	ret = bpf_prog_create(&fp, &fprog_tmp);
+	if (ret < 0) {
+		kfree(bpf_ops);
+		return ret;
+	}
 
-	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*b), bind);
-		if (ret)
+	cfg->bpf_ops = bpf_ops;
+	cfg->bpf_num_ops = bpf_num_ops;
+	cfg->filter = fp;
+
+	return 0;
+}
+
+static int tcf_bpf_init_from_efd(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
+{
+	struct bpf_prog *fp;
+	char *name = NULL;
+	u32 bpf_fd;
+
+	bpf_fd = nla_get_u32(tb[TCA_ACT_BPF_FD]);
+
+	fp = bpf_prog_get(bpf_fd);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	if (fp->type != BPF_PROG_TYPE_SCHED_ACT) {
+		bpf_prog_put(fp);
+		return -EINVAL;
+	}
+
+	if (tb[TCA_ACT_BPF_NAME]) {
+		name = kmemdup(nla_data(tb[TCA_ACT_BPF_NAME]),
+			       nla_len(tb[TCA_ACT_BPF_NAME]),
+			       GFP_KERNEL);
+		if (!name) {
+			bpf_prog_put(fp);
+			return -ENOMEM;
+		}
+	}
+
+	cfg->bpf_fd = bpf_fd;
+	cfg->bpf_name = name;
+	cfg->filter = fp;
+
+	return 0;
+}
+
+static int tcf_bpf_init(struct net *net, struct nlattr *nla,
+			struct nlattr *est, struct tc_action *act,
+			int replace, int bind)
+{
+	struct nlattr *tb[TCA_ACT_BPF_MAX + 1];
+	struct tc_act_bpf *parm;
+	struct tcf_bpf *prog;
+	struct tcf_bpf_cfg cfg;
+	bool is_bpf, is_ebpf;
+	int ret;
+
+	if (!nla)
+		return -EINVAL;
+
+	ret = nla_parse_nested(tb, TCA_ACT_BPF_MAX, nla, act_bpf_policy);
+	if (ret < 0)
+		return ret;
+
+	is_bpf = tb[TCA_ACT_BPF_OPS_LEN] && tb[TCA_ACT_BPF_OPS];
+	is_ebpf = tb[TCA_ACT_BPF_FD];
+
+	if ((!is_bpf && !is_ebpf) || (is_bpf && is_ebpf) ||
+	    !tb[TCA_ACT_BPF_PARMS])
+		return -EINVAL;
+
+	parm = nla_data(tb[TCA_ACT_BPF_PARMS]);
+
+	memset(&cfg, 0, sizeof(cfg));
+
+	ret = is_bpf ? tcf_bpf_init_from_ops(tb, &cfg) :
+		       tcf_bpf_init_from_efd(tb, &cfg);
+	if (ret < 0)
+		return ret;
+
+	if (!tcf_hash_check(parm->index, act, bind)) {
+		ret = tcf_hash_create(parm->index, est, act,
+				      sizeof(*prog), bind);
+		if (ret < 0)
 			goto destroy_fp;
 
 		ret = ACT_P_CREATED;
 	} else {
+		/* Don't override defaults. */
 		if (bind)
 			goto destroy_fp;
-		tcf_hash_release(a, bind);
-		if (!ovr) {
+
+		tcf_hash_release(act, bind);
+		if (!replace) {
 			ret = -EEXIST;
 			goto destroy_fp;
 		}
 	}
 
-	b = to_bpf(a);
-	spin_lock_bh(&b->tcf_lock);
-	b->tcf_action = parm->action;
-	b->bpf_num_ops = bpf_num_ops;
-	b->bpf_ops = bpf_ops;
-	b->filter = fp;
-	spin_unlock_bh(&b->tcf_lock);
+	prog = to_bpf(act);
+	spin_lock_bh(&prog->tcf_lock);
+
+	prog->bpf_ops = cfg.bpf_ops;
+	prog->bpf_name = cfg.bpf_name;
+
+	if (cfg.bpf_num_ops)
+		prog->bpf_num_ops = cfg.bpf_num_ops;
+	if (cfg.bpf_fd)
+		prog->bpf_fd = cfg.bpf_fd;
+
+	prog->tcf_action = parm->action;
+	prog->filter = cfg.filter;
+
+	spin_unlock_bh(&prog->tcf_lock);
 
 	if (ret == ACT_P_CREATED)
-		tcf_hash_insert(a);
+		tcf_hash_insert(act);
+
 	return ret;
 
 destroy_fp:
-	bpf_prog_destroy(fp);
-free_bpf_ops:
-	kfree(bpf_ops);
+	if (is_ebpf)
+		bpf_prog_put(cfg.filter);
+	else
+		bpf_prog_destroy(cfg.filter);
+
+	kfree(cfg.bpf_ops);
+	kfree(cfg.bpf_name);
+
 	return ret;
 }
 
-static void tcf_bpf_cleanup(struct tc_action *a, int bind)
+static void tcf_bpf_cleanup(struct tc_action *act, int bind)
 {
-	struct tcf_bpf *b = a->priv;
+	const struct tcf_bpf *prog = act->priv;
 
-	bpf_prog_destroy(b->filter);
+	if (tcf_bpf_is_ebpf(prog))
+		bpf_prog_put(prog->filter);
+	else
+		bpf_prog_destroy(prog->filter);
 }
 
-static struct tc_action_ops act_bpf_ops = {
-	.kind =		"bpf",
-	.type =		TCA_ACT_BPF,
-	.owner =	THIS_MODULE,
-	.act =		tcf_bpf,
-	.dump =		tcf_bpf_dump,
-	.cleanup =	tcf_bpf_cleanup,
-	.init =		tcf_bpf_init,
+static struct tc_action_ops act_bpf_ops __read_mostly = {
+	.kind		=	"bpf",
+	.type		=	TCA_ACT_BPF,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_bpf,
+	.dump		=	tcf_bpf_dump,
+	.cleanup	=	tcf_bpf_cleanup,
+	.init		=	tcf_bpf_init,
 };
 
 static int __init bpf_init_module(void)
-- 
1.9.3
