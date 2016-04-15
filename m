From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: [PATCH net-next 1/2] act_bpf: send back eBPF bytecode through netlink socket
Date: Fri, 15 Apr 2016 12:07:35 +0200
Message-ID: <1460714856-7221-2-git-send-email-quentin.monnet@6wind.com>
References: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37583 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbcDOKIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 06:08:11 -0400
Received: by mail-wm0-f54.google.com with SMTP id n3so25137284wmn.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 03:08:10 -0700 (PDT)
In-Reply-To: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new BPF traffic control action is set up with tc, the bytecode is
sent back to userspace through a netlink socket for cBPF, but not for
eBPF (the file descriptor pointing to the object file containing the
bytecode is sent instead).

This patch makes act_bpf module send the bytecode for eBPF as well (in
addition to the file descriptor).

It also adds a new BPF netlink attribute (a flag) in order to
differenciate what BPF version is in use, so that userspace tools can
process it properly.

Signed-off-by: Quentin Monnet <quentin.monnet@6wind.com>
---
 include/uapi/linux/tc_act/tc_bpf.h |  1 +
 net/sched/act_bpf.c                | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/uapi/linux/tc_act/tc_bpf.h b/include/uapi/linux/tc_act/tc_bpf.h
index 07f17cc70bb3..8c9a44324467 100644
--- a/include/uapi/linux/tc_act/tc_bpf.h
+++ b/include/uapi/linux/tc_act/tc_bpf.h
@@ -26,6 +26,7 @@ enum {
 	TCA_ACT_BPF_OPS,
 	TCA_ACT_BPF_FD,
 	TCA_ACT_BPF_NAME,
+	TCA_ACT_BPF_EBPF,
 	__TCA_ACT_BPF_MAX,
 };
 #define TCA_ACT_BPF_MAX (__TCA_ACT_BPF_MAX - 1)
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 8c9f1f0459ab..fcd30f0b3b75 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -118,6 +118,28 @@ static int tcf_bpf_dump_bpf_info(const struct tcf_bpf *prog,
 static int tcf_bpf_dump_ebpf_info(const struct tcf_bpf *prog,
 				  struct sk_buff *skb)
 {
+	struct bpf_prog *filter;
+
+	if (nla_put_flag(skb, TCA_ACT_BPF_EBPF))
+		return -EMSGSIZE;
+
+	rcu_read_lock();
+	filter = rcu_dereference(prog->filter);
+	if (filter) {
+		if (nla_put_u16(skb, TCA_ACT_BPF_OPS_LEN, filter->len)) {
+			rcu_read_unlock();
+			return -EMSGSIZE;
+		}
+
+		if (nla_put(skb, TCA_ACT_BPF_OPS,
+			    filter->len * sizeof(struct sock_filter),
+			    filter->insnsi)) {
+			rcu_read_unlock();
+			return -EMSGSIZE;
+		}
+	}
+	rcu_read_unlock();
+
 	if (nla_put_u32(skb, TCA_ACT_BPF_FD, prog->bpf_fd))
 		return -EMSGSIZE;
 
@@ -170,6 +192,7 @@ static const struct nla_policy act_bpf_policy[TCA_ACT_BPF_MAX + 1] = {
 	[TCA_ACT_BPF_PARMS]	= { .len = sizeof(struct tc_act_bpf) },
 	[TCA_ACT_BPF_FD]	= { .type = NLA_U32 },
 	[TCA_ACT_BPF_NAME]	= { .type = NLA_NUL_STRING, .len = ACT_BPF_NAME_LEN },
+	[TCA_ACT_BPF_EBPF]	= { .type = NLA_FLAG },
 	[TCA_ACT_BPF_OPS_LEN]	= { .type = NLA_U16 },
 	[TCA_ACT_BPF_OPS]	= { .type = NLA_BINARY,
 				    .len = sizeof(struct sock_filter) * BPF_MAXINSNS },
-- 
2.7.4
