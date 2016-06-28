From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/6] bpf: don't use raw processor id in generic helper
Date: Tue, 28 Jun 2016 12:18:26 +0200
Message-ID: <7103e2085afa29c006cd5b94a6e4a2ac83efc30d.1467106475.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54356 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146AbcF1KsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 06:48:02 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use smp_processor_id() for the generic helper bpf_get_smp_processor_id()
instead of the raw variant. This allows for preemption checks when we
have DEBUG_PREEMPT, and otherwise uses the raw variant anyway. We only
need to keep the raw variant for socket filters, but we can reuse the
helper that is already there from cBPF side.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/helpers.c |  2 +-
 net/core/filter.c    | 10 +++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index ad7a057..1ea3afb 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -101,7 +101,7 @@ const struct bpf_func_proto bpf_get_prandom_u32_proto = {
 
 static u64 bpf_get_smp_processor_id(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
-	return raw_smp_processor_id();
+	return smp_processor_id();
 }
 
 const struct bpf_func_proto bpf_get_smp_processor_id_proto = {
diff --git a/net/core/filter.c b/net/core/filter.c
index cb9fc16..46c88d9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -150,6 +150,12 @@ static u64 __get_raw_cpu_id(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return raw_smp_processor_id();
 }
 
+static const struct bpf_func_proto bpf_get_raw_smp_processor_id_proto = {
+	.func		= __get_raw_cpu_id,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+};
+
 static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
 			      struct bpf_insn *insn_buf)
 {
@@ -2037,7 +2043,7 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_prandom_u32:
 		return &bpf_get_prandom_u32_proto;
 	case BPF_FUNC_get_smp_processor_id:
-		return &bpf_get_smp_processor_id_proto;
+		return &bpf_get_raw_smp_processor_id_proto;
 	case BPF_FUNC_tail_call:
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_ktime_get_ns:
@@ -2086,6 +2092,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_route_realm_proto;
 	case BPF_FUNC_perf_event_output:
 		return bpf_get_event_output_proto();
+	case BPF_FUNC_get_smp_processor_id:
+		return &bpf_get_smp_processor_id_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.9.3
