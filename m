From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/2] cls_bpf: introduce integrated actions
Date: Tue, 15 Sep 2015 18:51:34 -0700
Message-ID: <1442368295-5204-2-git-send-email-ast@plumgrid.com>
References: <1442368295-5204-1-git-send-email-ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33516 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbIPBvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:51:44 -0400
Received: by pacex6 with SMTP id ex6so193230034pac.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 18:51:44 -0700 (PDT)
In-Reply-To: <1442368295-5204-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

Often cls_bpf classifier is used with single action drop attached.
Optimize this use case and let cls_bpf return both classid and action.
For backwards compatibility reasons enable this feature under
TCA_BPF_FLAG_ACT_DIRECT flag.

Then more interesting programs like the following are easier to write:
int cls_bpf_prog(struct __sk_buff *skb)
{
  /* classify arp, ip, ipv6 into different traffic classes
   * and drop all other packets
   */
  switch (skb->protocol) {
  case htons(ETH_P_ARP):
    skb->tc_classid = 1;
    break;
  case htons(ETH_P_IP):
    skb->tc_classid = 2;
    break;
  case htons(ETH_P_IPV6):
    skb->tc_classid = 3;
    break;
  default:
    return TC_ACT_SHOT;
  }

  return TC_ACT_OK;
}

Joint work with Daniel Borkmann.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/net/sch_generic.h    |    2 +-
 include/uapi/linux/bpf.h     |    1 +
 include/uapi/linux/pkt_cls.h |    3 +++
 net/core/filter.c            |   14 ++++++++++
 net/sched/cls_bpf.c          |   60 ++++++++++++++++++++++++++++++++++--------
 5 files changed, 68 insertions(+), 12 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 444faa89a55f..da61febb9091 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -251,7 +251,7 @@ struct tcf_proto {
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
 	u16			slave_dev_queue_mapping;
-	u16			_pad;
+	u16			tc_classid;
 #define QDISC_CB_PRIV_LEN 20
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 92a48e2d5461..2fbd1c71fa3b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -293,6 +293,7 @@ struct __sk_buff {
 	__u32 tc_index;
 	__u32 cb[5];
 	__u32 hash;
+	__u32 tc_classid;
 };
 
 struct bpf_tunnel_key {
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 4f0d1bc3647d..0a262a83f9d4 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -373,6 +373,8 @@ enum {
 
 /* BPF classifier */
 
+#define TCA_BPF_FLAG_ACT_DIRECT		(1 << 0)
+
 enum {
 	TCA_BPF_UNSPEC,
 	TCA_BPF_ACT,
@@ -382,6 +384,7 @@ enum {
 	TCA_BPF_OPS,
 	TCA_BPF_FD,
 	TCA_BPF_NAME,
+	TCA_BPF_FLAGS,
 	__TCA_BPF_MAX,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 13079f03902e..971d6ba89758 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1632,6 +1632,9 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type)
 {
+	if (off == offsetof(struct __sk_buff, tc_classid))
+		return false;
+
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct __sk_buff, cb[0]) ...
@@ -1648,6 +1651,9 @@ static bool sk_filter_is_valid_access(int off, int size,
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type)
 {
+	if (off == offsetof(struct __sk_buff, tc_classid))
+		return type == BPF_WRITE ? true : false;
+
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct __sk_buff, mark):
@@ -1760,6 +1766,14 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
 		break;
 
+	case offsetof(struct __sk_buff, tc_classid):
+		ctx_off -= offsetof(struct __sk_buff, tc_classid);
+		ctx_off += offsetof(struct sk_buff, cb);
+		ctx_off += offsetof(struct qdisc_skb_cb, tc_classid);
+		WARN_ON(type != BPF_WRITE);
+		*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
+		break;
+
 	case offsetof(struct __sk_buff, tc_index):
 #ifdef CONFIG_NET_SCHED
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, tc_index) != 2);
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index e5168f8b9640..77b0ef148256 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -38,6 +38,7 @@ struct cls_bpf_prog {
 	struct bpf_prog *filter;
 	struct list_head link;
 	struct tcf_result res;
+	bool exts_integrated;
 	struct tcf_exts exts;
 	u32 handle;
 	union {
@@ -52,6 +53,7 @@ struct cls_bpf_prog {
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 	[TCA_BPF_CLASSID]	= { .type = NLA_U32 },
+	[TCA_BPF_FLAGS]		= { .type = NLA_U32 },
 	[TCA_BPF_FD]		= { .type = NLA_U32 },
 	[TCA_BPF_NAME]		= { .type = NLA_NUL_STRING, .len = CLS_BPF_NAME_LEN },
 	[TCA_BPF_OPS_LEN]	= { .type = NLA_U16 },
@@ -59,6 +61,22 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
 };
 
+static int cls_bpf_exec_opcode(int code)
+{
+	switch (code) {
+	case TC_ACT_OK:
+	case TC_ACT_RECLASSIFY:
+	case TC_ACT_SHOT:
+	case TC_ACT_PIPE:
+	case TC_ACT_STOLEN:
+	case TC_ACT_QUEUED:
+	case TC_ACT_UNSPEC:
+		return code;
+	default:
+		return TC_ACT_UNSPEC;
+	}
+}
+
 static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
@@ -79,6 +97,8 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	list_for_each_entry_rcu(prog, &head->plist, link) {
 		int filter_res;
 
+		qdisc_skb_cb(skb)->tc_classid = prog->res.classid;
+
 		if (at_ingress) {
 			/* It is safe to push/pull even if skb_shared() */
 			__skb_push(skb, skb->mac_len);
@@ -88,6 +108,16 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			filter_res = BPF_PROG_RUN(prog->filter, skb);
 		}
 
+		if (prog->exts_integrated) {
+			res->class = prog->res.class;
+			res->classid = qdisc_skb_cb(skb)->tc_classid;
+
+			ret = cls_bpf_exec_opcode(filter_res);
+			if (ret == TC_ACT_UNSPEC)
+				continue;
+			break;
+		}
+
 		if (filter_res == 0)
 			continue;
 
@@ -195,8 +225,7 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
 	return ret;
 }
 
-static int cls_bpf_prog_from_ops(struct nlattr **tb,
-				 struct cls_bpf_prog *prog, u32 classid)
+static int cls_bpf_prog_from_ops(struct nlattr **tb, struct cls_bpf_prog *prog)
 {
 	struct sock_filter *bpf_ops;
 	struct sock_fprog_kern fprog_tmp;
@@ -230,15 +259,13 @@ static int cls_bpf_prog_from_ops(struct nlattr **tb,
 	prog->bpf_ops = bpf_ops;
 	prog->bpf_num_ops = bpf_num_ops;
 	prog->bpf_name = NULL;
-
 	prog->filter = fp;
-	prog->res.classid = classid;
 
 	return 0;
 }
 
-static int cls_bpf_prog_from_efd(struct nlattr **tb,
-				 struct cls_bpf_prog *prog, u32 classid)
+static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
+				 const struct tcf_proto *tp)
 {
 	struct bpf_prog *fp;
 	char *name = NULL;
@@ -268,9 +295,7 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb,
 	prog->bpf_ops = NULL;
 	prog->bpf_fd = bpf_fd;
 	prog->bpf_name = name;
-
 	prog->filter = fp;
-	prog->res.classid = classid;
 
 	return 0;
 }
@@ -280,8 +305,8 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 				   unsigned long base, struct nlattr **tb,
 				   struct nlattr *est, bool ovr)
 {
+	bool is_bpf, is_ebpf, have_exts = false;
 	struct tcf_exts exts;
-	bool is_bpf, is_ebpf;
 	u32 classid;
 	int ret;
 
@@ -298,9 +323,22 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 		return ret;
 
 	classid = nla_get_u32(tb[TCA_BPF_CLASSID]);
+	if (tb[TCA_BPF_FLAGS]) {
+		u32 bpf_flags = nla_get_u32(tb[TCA_BPF_FLAGS]);
+
+		if (bpf_flags & ~TCA_BPF_FLAG_ACT_DIRECT) {
+			tcf_exts_destroy(&exts);
+			return -EINVAL;
+		}
+
+		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
+	}
+
+	prog->res.classid = classid;
+	prog->exts_integrated = have_exts;
 
-	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog, classid) :
-		       cls_bpf_prog_from_efd(tb, prog, classid);
+	ret = is_bpf ? cls_bpf_prog_from_ops(tb, prog) :
+		       cls_bpf_prog_from_efd(tb, prog, tp);
 	if (ret < 0) {
 		tcf_exts_destroy(&exts);
 		return ret;
-- 
1.7.9.5
