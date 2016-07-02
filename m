From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: add bpf_get_hash_recalc helper
Date: Sun,  3 Jul 2016 01:28:47 +0200
Message-ID: <6c3f3fd083314b49742d65c54e71e27804b26663.1467501451.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37467 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbcGBX3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 19:29:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_clear_hash() was invoked due to mangling of relevant headers and
BPF program needs skb->hash later on, we can add a helper to trigger hash
recalculation via bpf_get_hash_recalc().

The helper will return the newly retrieved hash directly, but later access
can also be done via skb context again through skb->hash directly (inline)
without needing to call the helper once more.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  9 +++++++++
 net/core/filter.c        | 19 +++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f44504d..c14ca1c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -348,6 +348,15 @@ enum bpf_func_id {
 	 *    < 0 error
 	 */
 	BPF_FUNC_skb_in_cgroup,
+
+	/**
+	 * bpf_get_hash_recalc(skb)
+	 * Retrieve and possibly recalculate skb->hash.
+	 * @skb: pointer to skb
+	 * Return: hash
+	 */
+	BPF_FUNC_get_hash_recalc,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 54071cf..10c4a2f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1729,6 +1729,23 @@ static const struct bpf_func_proto bpf_get_route_realm_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+static u64 bpf_get_hash_recalc(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* If skb_clear_hash() was called due to mangling, we can
+	 * trigger SW recalculation here. Later access to hash
+	 * can then use the inline skb->hash via context directly
+	 * instead of calling this helper again.
+	 */
+	return skb_get_hash((struct sk_buff *) (unsigned long) r1);
+}
+
+static const struct bpf_func_proto bpf_get_hash_recalc_proto = {
+	.func		= bpf_get_hash_recalc,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+};
+
 static u64 bpf_skb_vlan_push(u64 r1, u64 r2, u64 vlan_tci, u64 r4, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
@@ -2337,6 +2354,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_redirect_proto;
 	case BPF_FUNC_get_route_realm:
 		return &bpf_get_route_realm_proto;
+	case BPF_FUNC_get_hash_recalc:
+		return &bpf_get_hash_recalc_proto;
 	case BPF_FUNC_perf_event_output:
 		return bpf_get_event_output_proto();
 	case BPF_FUNC_get_smp_processor_id:
-- 
1.9.3
