From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v5 1/6] bpf: add new prog type for cgroup socket filtering
Date: Mon, 12 Sep 2016 18:12:10 +0200
Message-ID: <1473696735-11269-2-git-send-email-daniel@zonque.org>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:58953 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751463AbcILQMa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 12:12:30 -0400
In-Reply-To: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For now, this program type is equivalent to BPF_PROG_TYPE_SOCKET_FILTER in
terms of checks during the verification process. It may access the skb as
well.

Programs of this type will be attached to cgroups for network filtering
and accounting.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/uapi/linux/bpf.h | 9 +++++++++
 kernel/bpf/verifier.c    | 1 +
 net/core/filter.c        | 6 ++++++
 3 files changed, 16 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f896dfa..55f815e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -96,8 +96,17 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
+	BPF_PROG_TYPE_CGROUP_SOCKET,
 };
 
+enum bpf_attach_type {
+	BPF_CGROUP_INET_INGRESS,
+	BPF_CGROUP_INET_EGRESS,
+	__MAX_BPF_ATTACH_TYPE
+};
+
+#define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 90493a6..d5d2875 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1830,6 +1830,7 @@ static bool may_access_skb(enum bpf_prog_type type)
 	case BPF_PROG_TYPE_SOCKET_FILTER:
 	case BPF_PROG_TYPE_SCHED_CLS:
 	case BPF_PROG_TYPE_SCHED_ACT:
+	case BPF_PROG_TYPE_CGROUP_SOCKET:
 		return true;
 	default:
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index a83766b..176b6f2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2848,12 +2848,18 @@ static struct bpf_prog_type_list xdp_type __read_mostly = {
 	.type	= BPF_PROG_TYPE_XDP,
 };
 
+static struct bpf_prog_type_list cg_sk_type __read_mostly = {
+	.ops	= &sk_filter_ops,
+	.type	= BPF_PROG_TYPE_CGROUP_SOCKET,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
 	bpf_register_prog_type(&sched_cls_type);
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
+	bpf_register_prog_type(&cg_sk_type);
 
 	return 0;
 }
-- 
2.5.5
