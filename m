From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next] tc: bpf: generalize pedit action
Date: Thu, 26 Mar 2015 19:53:57 -0700
Message-ID: <1427424837-7757-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

existing TC action 'pedit' can munge any bits of the packet.
Generalize it for use in bpf programs attached as cls_bpf and act_bpf via
bpf_skb_store_bytes() helper function.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---

pedit is limited to 32-bit masked rewrites. Here let it be flexible.

ptr = skb_header_pointer(skb, offset, len, buf);
memcpy(ptr, from, len);
if (ptr == buf)
  skb_store_bits(skb, offset, ptr, len);

^^ logic is the same as in pedit.
shifts, mask, invert style of rewrite is easily done by the program.
Just like arbitrary parsing of the packet and applying rewrites on demand.

 include/linux/bpf.h      |    1 +
 include/uapi/linux/bpf.h |    1 +
 kernel/bpf/verifier.c    |    2 ++
 net/core/filter.c        |   71 ++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 280a315de8d6..d5cda067115a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -59,6 +59,7 @@ enum bpf_arg_type {
 	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
 	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
 
+	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
 };
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 27dc4ec58840..74aab6e0d964 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -168,6 +168,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_get_prandom_u32, /* u32 prandom_u32(void) */
 	BPF_FUNC_get_smp_processor_id, /* u32 raw_smp_processor_id(void) */
+	BPF_FUNC_skb_store_bytes, /* int skb_store_bytes(skb, offset, from, len) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 0e714f799ec0..630a7bac1e51 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -773,6 +773,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = CONST_IMM;
 	} else if (arg_type == ARG_CONST_MAP_PTR) {
 		expected_type = CONST_PTR_TO_MAP;
+	} else if (arg_type == ARG_PTR_TO_CTX) {
+		expected_type = PTR_TO_CTX;
 	} else {
 		verbose("unsupported arg_type %d\n", arg_type);
 		return -EFAULT;
diff --git a/net/core/filter.c b/net/core/filter.c
index 32f43c59908c..444a07e4f68d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1175,6 +1175,56 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
+static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+	unsigned int offset = (unsigned int) r2;
+	void *from = (void *) (long) r3;
+	unsigned int len = (unsigned int) r4;
+	char buf[16];
+	void *ptr;
+
+	/* bpf verifier guarantees that:
+	 * 'from' pointer points to bpf program stack
+	 * 'len' bytes of it were initialized
+	 * 'len' > 0
+	 * 'skb' is a valid pointer to 'struct sk_buff'
+	 *
+	 * so check for invalid 'offset' and too large 'len'
+	 */
+	if (offset > 0xffff || len > sizeof(buf))
+		return -EFAULT;
+
+	if (skb_cloned(skb) && !skb_clone_writable(skb, offset + len))
+		return -EFAULT;
+
+	ptr = skb_header_pointer(skb, offset, len, buf);
+	if (unlikely(!ptr))
+		return -EFAULT;
+
+	skb_postpull_rcsum(skb, ptr, len);
+
+	memcpy(ptr, from, len);
+
+	if (ptr == buf)
+		/* skb_store_bits cannot return -EFAULT here */
+		skb_store_bits(skb, offset, ptr, len);
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(ptr, len, 0));
+	return 0;
+}
+
+const struct bpf_func_proto bpf_skb_store_bytes_proto = {
+	.func		= bpf_skb_store_bytes,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_PTR_TO_STACK,
+	.arg4_type	= ARG_CONST_STACK_SIZE,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -1194,6 +1244,17 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+tc_cls_act_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_skb_store_bytes:
+		return &bpf_skb_store_bytes_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
+}
+
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type)
 {
@@ -1270,18 +1331,24 @@ static const struct bpf_verifier_ops sk_filter_ops = {
 	.convert_ctx_access = sk_filter_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops tc_cls_act_ops = {
+	.get_func_proto = tc_cls_act_func_proto,
+	.is_valid_access = sk_filter_is_valid_access,
+	.convert_ctx_access = sk_filter_convert_ctx_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops = &sk_filter_ops,
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 static struct bpf_prog_type_list sched_cls_type __read_mostly = {
-	.ops = &sk_filter_ops,
+	.ops = &tc_cls_act_ops,
 	.type = BPF_PROG_TYPE_SCHED_CLS,
 };
 
 static struct bpf_prog_type_list sched_act_type __read_mostly = {
-	.ops = &sk_filter_ops,
+	.ops = &tc_cls_act_ops,
 	.type = BPF_PROG_TYPE_SCHED_ACT,
 };
 
-- 
1.7.9.5
