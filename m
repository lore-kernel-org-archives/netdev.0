From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 8/8] bpf: add bpf_set_hash helper for tc progs
Date: Sun, 11 Jun 2017 00:50:47 +0200
Message-ID: <d612032fbb7bfa9615a9feef9daac7307031c790.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57844 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751666AbdFJWvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:51:01 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow for tc BPF programs to set a skb->hash, apart from clearing
and triggering a recalc that we have right now. It allows for BPF
to implement a custom hashing routine for skb_get_hash().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h       |  8 +++++++-
 net/core/filter.c              | 20 ++++++++++++++++++++
 tools/include/uapi/linux/bpf.h |  8 +++++++-
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 9b2c10b..f94b48b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -513,6 +513,11 @@ enum bpf_attach_type {
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
  *     Return: uid of the socket owner on success or overflowuid if failed.
+ *
+ * u32 bpf_set_hash(skb, hash)
+ *     Set full skb->hash.
+ *     @skb: pointer to skb
+ *     @hash: hash to set
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -562,7 +567,8 @@ enum bpf_attach_type {
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
 	FN(get_socket_cookie),		\
-	FN(get_socket_uid),
+	FN(get_socket_uid),		\
+	FN(set_hash),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 4867391..a65a3b2 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1874,6 +1874,24 @@ int skb_do_redirect(struct sk_buff *skb)
 	.arg1_type	= ARG_PTR_TO_CTX,
 };
 
+BPF_CALL_2(bpf_set_hash, struct sk_buff *, skb, u32, hash)
+{
+	/* Set user specified hash as L4(+), so that it gets returned
+	 * on skb_get_hash() call unless BPF prog later on triggers a
+	 * skb_clear_hash().
+	 */
+	__skb_set_sw_hash(skb, hash, true);
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_set_hash_proto = {
+	.func		= bpf_set_hash,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 BPF_CALL_3(bpf_skb_vlan_push, struct sk_buff *, skb, __be16, vlan_proto,
 	   u16, vlan_tci)
 {
@@ -2744,6 +2762,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_get_hash_recalc_proto;
 	case BPF_FUNC_set_hash_invalid:
 		return &bpf_set_hash_invalid_proto;
+	case BPF_FUNC_set_hash:
+		return &bpf_set_hash_proto;
 	case BPF_FUNC_perf_event_output:
 		return &bpf_skb_event_output_proto;
 	case BPF_FUNC_get_smp_processor_id:
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 9b2c10b..f94b48b 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -513,6 +513,11 @@ enum bpf_attach_type {
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
  *     Return: uid of the socket owner on success or overflowuid if failed.
+ *
+ * u32 bpf_set_hash(skb, hash)
+ *     Set full skb->hash.
+ *     @skb: pointer to skb
+ *     @hash: hash to set
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -562,7 +567,8 @@ enum bpf_attach_type {
 	FN(xdp_adjust_head),		\
 	FN(probe_read_str),		\
 	FN(get_socket_cookie),		\
-	FN(get_socket_uid),
+	FN(get_socket_uid),		\
+	FN(set_hash),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
-- 
1.9.3
