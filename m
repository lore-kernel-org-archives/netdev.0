From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v9 1/6] bpf: add new prog type for cgroup socket filtering
Date: Wed, 23 Nov 2016 16:52:25 +0100
Message-ID: <1479916350-28462-2-git-send-email-daniel@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49620 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935117AbcKWPwk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 10:52:40 -0500
In-Reply-To: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This program type is similar to BPF_PROG_TYPE_SOCKET_FILTER, except that
it does not allow BPF_LD_[ABS|IND] instructions and hooks up the
bpf_skb_load_bytes() helper.

Programs of this type will be attached to cgroups for network filtering
and accounting.

Signed-off-by: Daniel Mack <daniel@zonque.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  9 +++++++++
 net/core/filter.c        | 23 +++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f09c70b..1f3e6f1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -96,8 +96,17 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
+	BPF_PROG_TYPE_CGROUP_SKB,
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
diff --git a/net/core/filter.c b/net/core/filter.c
index 00351cd..e3813d6 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2576,6 +2576,17 @@ xdp_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+cg_skb_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_load_bytes:
+		return &bpf_skb_load_bytes_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
@@ -2938,6 +2949,12 @@ static const struct bpf_verifier_ops xdp_ops = {
 	.convert_ctx_access	= xdp_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops cg_skb_ops = {
+	.get_func_proto		= cg_skb_func_proto,
+	.is_valid_access	= sk_filter_is_valid_access,
+	.convert_ctx_access	= sk_filter_convert_ctx_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops	= &sk_filter_ops,
 	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
@@ -2958,12 +2975,18 @@ static struct bpf_prog_type_list xdp_type __read_mostly = {
 	.type	= BPF_PROG_TYPE_XDP,
 };
 
+static struct bpf_prog_type_list cg_skb_type __read_mostly = {
+	.ops	= &cg_skb_ops,
+	.type	= BPF_PROG_TYPE_CGROUP_SKB,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
 	bpf_register_prog_type(&sched_cls_type);
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
+	bpf_register_prog_type(&cg_skb_type);
 
 	return 0;
 }
-- 
2.7.4
