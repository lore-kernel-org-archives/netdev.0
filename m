From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/5] bpf: add bpf_skb_load_bytes helper
Date: Thu, 17 Dec 2015 23:51:53 +0100
Message-ID: <99ae8804e2a0dfa81aaa3b0cd22540f32f08eee4.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53863 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbLQWwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:03 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hacking tc programs with eBPF, one of the issues that come up
from time to time is to load addresses from headers. In eBPF as in
classic BPF, we have BPF_LD | BPF_ABS | BPF_{B,H,W} instructions that
extract a byte, half-word or word out of the skb data though helpers
such as bpf_load_pointer() (interpreter case).

F.e. extracting a whole IPv6 address could possibly look like ...

  union v6addr {
    struct {
      __u32 p1;
      __u32 p2;
      __u32 p3;
      __u32 p4;
    };
    __u8 addr[16];
  };

  [...]

  a.p1 = htonl(load_word(skb, off));
  a.p2 = htonl(load_word(skb, off +  4));
  a.p3 = htonl(load_word(skb, off +  8));
  a.p4 = htonl(load_word(skb, off + 12));

  [...]

  /* access to a.addr[...] */

This work adds a complementary helper bpf_skb_load_bytes() (we also
have bpf_skb_store_bytes()) as an alternative where the same call
would look like from an eBPF program:

  ret = bpf_skb_load_bytes(skb, off, addr, sizeof(addr));

Same verifier restrictions apply as in ffeedafbf023 ("bpf: introduce
current->pid, tgid, uid, gid, comm accessors") case, where stack memory
access needs to be statically verified and thus guaranteed to be
initialized in first use (otherwise verifier cannot tell whether a
subsequent access to it is valid or not as it's runtime dependent).

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  1 +
 net/core/filter.c        | 35 ++++++++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 9ea2d22..8bed7f1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -269,6 +269,7 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_perf_event_output,
+	BPF_FUNC_skb_load_bytes,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 672eefb..34bf6fc 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1245,6 +1245,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 }
 
 #define BPF_RECOMPUTE_CSUM(flags)	((flags) & 1)
+#define BPF_LDST_LEN			16U
 
 static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 {
@@ -1252,7 +1253,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	int offset = (int) r2;
 	void *from = (void *) (long) r3;
 	unsigned int len = (unsigned int) r4;
-	char buf[16];
+	char buf[BPF_LDST_LEN];
 	void *ptr;
 
 	/* bpf verifier guarantees that:
@@ -1299,6 +1300,36 @@ const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	const struct sk_buff *skb = (const struct sk_buff *)(unsigned long) r1;
+	int offset = (int) r2;
+	void *to = (void *)(unsigned long) r3;
+	unsigned int len = (unsigned int) r4;
+	void *ptr;
+
+	if (unlikely((u32) offset > 0xffff || len > BPF_LDST_LEN))
+		return -EFAULT;
+
+	ptr = skb_header_pointer(skb, offset, len, to);
+	if (unlikely(!ptr))
+		return -EFAULT;
+	if (ptr != to)
+		memcpy(to, ptr, len);
+
+	return 0;
+}
+
+const struct bpf_func_proto bpf_skb_load_bytes_proto = {
+	.func		= bpf_skb_load_bytes,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_PTR_TO_STACK,
+	.arg4_type	= ARG_CONST_STACK_SIZE,
+};
+
 #define BPF_HEADER_FIELD_SIZE(flags)	((flags) & 0x0f)
 #define BPF_IS_PSEUDO_HEADER(flags)	((flags) & 0x10)
 
@@ -1654,6 +1685,8 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
 		return &bpf_skb_store_bytes_proto;
+	case BPF_FUNC_skb_load_bytes:
+		return &bpf_skb_load_bytes_proto;
 	case BPF_FUNC_l3_csum_replace:
 		return &bpf_l3_csum_replace_proto;
 	case BPF_FUNC_l4_csum_replace:
-- 
1.9.3
