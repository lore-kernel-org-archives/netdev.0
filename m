From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf: add helper to invalidate hash
Date: Fri, 23 Sep 2016 01:28:37 +0200
Message-ID: <01f91d9562c3af7df96a064ee908ed813ab882ac.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42488 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757505AbcIVX2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:28:54 -0400
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
In-Reply-To: <cover.1474586162.git.daniel@iogearbox.net>
References: <cover.1474586162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a small helper that complements 36bbef52c7eb ("bpf: direct packet
write and access for helpers for clsact progs") for invalidating the
current skb->hash after mangling on headers via direct packet write.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  7 +++++++
 net/core/filter.c        | 18 ++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e07432b..f09c70b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -419,6 +419,13 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_csum_update,
 
+	/**
+	 * bpf_set_hash_invalid(skb)
+	 * Invalidate current skb>hash.
+	 * @skb: pointer to skb
+	 */
+	BPF_FUNC_set_hash_invalid,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index acf84fb..00351cd 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1777,6 +1777,22 @@ static const struct bpf_func_proto bpf_get_hash_recalc_proto = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_1(bpf_set_hash_invalid, struct sk_buff *, skb)
+{
+	/* After all direct packet write, this can be used once for
+	 * triggering a lazy recalc on next skb_get_hash() invocation.
+	 */
+	skb_clear_hash(skb);
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_set_hash_invalid_proto = {
+	.func		= bpf_set_hash_invalid,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+};
+
 BPF_CALL_3(bpf_skb_vlan_push, struct sk_buff *, skb, __be16, vlan_proto,
 	   u16, vlan_tci)
 {
@@ -2534,6 +2550,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_route_realm_proto;
 	case BPF_FUNC_get_hash_recalc:
 		return &bpf_get_hash_recalc_proto;
+	case BPF_FUNC_set_hash_invalid:
+		return &bpf_set_hash_invalid_proto;
 	case BPF_FUNC_perf_event_output:
 		return &bpf_skb_event_output_proto;
 	case BPF_FUNC_get_smp_processor_id:
-- 
1.9.3
