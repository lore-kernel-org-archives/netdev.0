From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 2/6] ARM: net: handle negative offsets in BPF JIT.
Date: Thu, 16 Jul 2015 18:46:31 +0200
Message-ID: <1437065195-10887-3-git-send-email-nschichan@freebox.fr>
References: <1437065195-10887-1-git-send-email-nschichan@freebox.fr>
Cc: Russell King <linux@arm.linux.org.uk>,
	Alexei Starovoitov <ast@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437065195-10887-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, the JIT would reject negative offsets known during code
generation and mishandle negative offsets provided at runtime.

Fix that by calling bpf_internal_load_pointer_neg_helper()
appropriately in the jit_get_skb_{b,h,w} slow path helpers and by forcing
the execution flow to the slow path helpers when the offset is
negative.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 47 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 9 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 21f5ace..d9b2524 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -74,32 +74,52 @@ struct jit_ctx {
 
 int bpf_jit_enable __read_mostly;
 
-static u64 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
+static inline int call_neg_helper(struct sk_buff *skb, int offset, void *ret,
+		      unsigned int size)
+{
+	void *ptr = bpf_internal_load_pointer_neg_helper(skb, offset, size);
+
+	if (!ptr)
+		return -EFAULT;
+	memcpy(ret, ptr, size);
+	return 0;
+}
+
+static u64 jit_get_skb_b(struct sk_buff *skb, int offset)
 {
 	u8 ret;
 	int err;
 
-	err = skb_copy_bits(skb, offset, &ret, 1);
+	if (offset < 0)
+		err = call_neg_helper(skb, offset, &ret, 1);
+	else
+		err = skb_copy_bits(skb, offset, &ret, 1);
 
 	return (u64)err << 32 | ret;
 }
 
-static u64 jit_get_skb_h(struct sk_buff *skb, unsigned offset)
+static u64 jit_get_skb_h(struct sk_buff *skb, int offset)
 {
 	u16 ret;
 	int err;
 
-	err = skb_copy_bits(skb, offset, &ret, 2);
+	if (offset < 0)
+		err = call_neg_helper(skb, offset, &ret, 2);
+	else
+		err = skb_copy_bits(skb, offset, &ret, 2);
 
 	return (u64)err << 32 | ntohs(ret);
 }
 
-static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
+static u64 jit_get_skb_w(struct sk_buff *skb, int offset)
 {
 	u32 ret;
 	int err;
 
-	err = skb_copy_bits(skb, offset, &ret, 4);
+	if (offset < 0)
+		err = call_neg_helper(skb, offset, &ret, 4);
+	else
+		err = skb_copy_bits(skb, offset, &ret, 4);
 
 	return (u64)err << 32 | ntohl(ret);
 }
@@ -536,9 +556,6 @@ static int build_body(struct jit_ctx *ctx)
 		case BPF_LD | BPF_B | BPF_ABS:
 			load_order = 0;
 load:
-			/* the interpreter will deal with the negative K */
-			if ((int)k < 0)
-				return -ENOTSUPP;
 			emit_mov_i(r_off, k, ctx);
 load_common:
 			ctx->seen |= SEEN_DATA | SEEN_CALL;
@@ -553,6 +570,18 @@ load_common:
 				condt = ARM_COND_HI;
 			}
 
+			/*
+			 * test for negative offset, only if we are
+			 * currently scheduled to take the fast
+			 * path. this will update the flags so that
+			 * the slowpath instruction are ignored if the
+			 * offset is negative.
+			 *
+			 * for loard_order == 0 the HI condition will
+			 * make loads at offset 0 take the slow path too.
+			 */
+			_emit(condt, ARM_CMP_I(r_off, 0), ctx);
+
 			_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
 			      ctx);
 
-- 
1.9.1
