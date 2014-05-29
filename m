From: Chema Gonzalez <chema@google.com>
Subject: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple calls in eBPF
Date: Thu, 29 May 2014 11:55:58 -0700
Message-ID: <1401389758-13252-1-git-send-email-chema@google.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:43063 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaE2S4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 14:56:01 -0400
Received: by mail-pa0-f74.google.com with SMTP id rd3so140881pab.3
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 11:56:00 -0700 (PDT)
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes __skb_get_pay_offset() (the function called by
the eBPF call generated from "ld #poff") store the output of the flow
dissector (a flow_keys structure) in the eBPF stack. This way, multiple
invocations of this eBPF call in the same BPF filter will only require
one single call to the flow dissector.

Note that other eBPF calls that use the flow dissector can use the same
approach, and share the results, so at the end there is only one single
call to the flow dissector per packet.

Tested:

$ cat tools/net/ipv4_tcp_poff2.bpf
ldh [12]
jne #0x800, drop
ldb [23]
jneq #6, drop
ld poff
ld poff
ld poff
ld poff
ret #-1
drop: ret #0
$ ./tools/net/bpf_asm tools/net/ipv4_tcp_poff2.bpf
10,40 0 0 12,21 0 7 2048,48 0 0 23,21 0 5 6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,6 0 0 4294967295,6 0 0 0,

And then, in a VM, we ran:

$ tcpdump -n -i eth0 -f "10,40 0 0 12,21 0 7 2048,48 0 0 23,21 0 5 6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,6 0 0 4294967295,6 0 0 0,"

This tcpdump is github's tcpdump HEAD with pull request #353, which
allows using raw filters in tcpdump.

Debugging the kernel, we can see that there only the first "ld poff" call
does invoke the flow dissector. The other calls reuse the value in the
eBPF stack.

Also tested the test_bpf module.

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 include/linux/skbuff.h    |  3 +-
 lib/test_bpf.c            | 52 ++++++++++++++++++++++++++++
 net/core/filter.c         | 86 ++++++++++++++++++++++++++++++++++++++++++-----
 net/core/flow_dissector.c | 16 +++++----
 4 files changed, 141 insertions(+), 16 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7a9beeb..0214b5a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3065,7 +3065,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
-u32 __skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow,
+		u32 *flow_inited);
 
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index af677cb..0f8128f 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -446,6 +446,58 @@ static struct bpf_test tests[] = {
 		{ { 30, 0 }, { 100, 42 } },
 	},
 	{
+		"LD_PAYLOAD_OFF_STACK",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_IMM, 0x11111111),
+			BPF_STMT(BPF_ST, 0),
+			BPF_STMT(BPF_LD | BPF_IMM, 0x22222222),
+			BPF_STMT(BPF_ST, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 0xeeeeeeee),
+			BPF_STMT(BPF_ST, 14),
+			BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
+			BPF_STMT(BPF_ST, 15),
+			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
+			    SKF_AD_OFF + SKF_AD_PAY_OFFSET),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 54, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_LD | BPF_MEM, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x11111111, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_LD | BPF_MEM, 1),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x22222222, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_LD | BPF_MEM, 14),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0xeeeeeeee, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_LD | BPF_MEM, 15),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0xffffffff, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_RET | BPF_K, 1)
+		},
+		CLASSIC,
+		/* 01:02:03:04:05:06 < 07:08:09:0a:0b:0c, ethertype IPv4(0x0800)
+		 * length 94: 10.1.1.1.10000 > 10.1.1.2.22: Flags [P.],
+		 * seq 1:21, ack 2, win 14400, length 20
+		 */
+		{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
+		  0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
+		  0x08, 0x00,
+		  /* ip header */
+		  0x45, 0x10, 0x00, 0x5e,
+		  0x75, 0xb5, 0x40, 0x00,
+		  0x40, 0x06, 0xad, 0x2e,
+		  0x0a, 0x01, 0x01, 0x01, /* ip src */
+		  0x0a, 0x01, 0x01, 0x02, /* ip dst */
+		  /* tcp header */
+		  0x27, 0x10, 0x00, 0x16, /* tcp src/dst port */
+		  0x00, 0x00, 0x00, 0x01, /* tcp seq# */
+		  0x00, 0x00, 0x00, 0x02, /* tcp ack# */
+			0x50, 0x00, 0x38, 0x40,
+			0x9a, 0x42, 0x00, 0x00,
+		},
+		{ { 100, 1 } },
+	},
+	{
 		"LD_ANC_XOR",
 		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 10),
diff --git a/net/core/filter.c b/net/core/filter.c
index 2c2d35d..0c55252 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -66,6 +66,24 @@
 #define CTX	regs[BPF_REG_CTX]
 #define K	insn->imm
 
+/* classic BPF stack layout:
+ *
+ * This is the layout for the stack for eBPF filters generated from
+ * classic BPF filters.
+ *
+ * Top (BPF_MEMWORDS * 4) bytes are used to represent classic BPF
+ * mem[0-15] slots.
+ *
+ * Flow dissector users (poff so far) use the space just below mem[]
+ * to share the flow_keys obtained from dissecting the flow, and a
+ * bool stating whether such field has been inited.
+ */
+struct classic_bpf_stack_layout {
+	u32 flow_inited;
+	struct flow_keys flow;
+	u32 mem[BPF_MEMWORDS];
+};
+
 /* No hurry in this branch
  *
  * Exported for the bpf jit load helper.
@@ -596,9 +614,13 @@ static unsigned int pkt_type_offset(void)
 	return -1;
 }
 
-static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
+static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 fp, u64 r5)
 {
-	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
+	struct classic_bpf_stack_layout *stack_layout =
+	    (void *) fp - sizeof(struct classic_bpf_stack_layout);
+	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx,
+			      &stack_layout->flow,
+			      &stack_layout->flow_inited);
 }
 
 static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
@@ -779,7 +801,11 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG3, BPF_REG_X);
 		insn++;
 
-		/* Emit call(ctx, arg2=A, arg3=X) */
+		/* arg4 = FP */
+		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG4, BPF_REG_FP);
+		insn++;
+
+		/* Emit call(ctx, arg2=A, arg3=X, arg4=FP) */
 		insn->code = BPF_JMP | BPF_CALL;
 		switch (fp->k) {
 		case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
@@ -818,6 +844,45 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	return true;
 }
 
+void __sk_convert_filter_prologue(struct sock_filter *fp, int len,
+		struct sock_filter_int **new_insn)
+{
+	bool use_flow_dissector = false;
+	bool do_write_code = false;
+	int i;
+
+	/* check if there are any insn's that use the flow dissector */
+	for (i = 0; i < len; fp++, i++) {
+		if (BPF_CLASS(fp->code) == BPF_LD &&
+		    BPF_MODE(fp->code) == BPF_ABS &&
+		    fp->k == SKF_AD_OFF + SKF_AD_PAY_OFFSET) {
+			use_flow_dissector = true;
+			break;
+		}
+	}
+
+	do_write_code = (*new_insn != NULL);
+
+	/* first init the stack */
+	if (use_flow_dissector) {
+		/* stack_layout->flow_inited = 0; */
+		if (do_write_code) {
+			(*new_insn)->code = BPF_ST | BPF_MEM | BPF_W;
+			(*new_insn)->a_reg = BPF_REG_FP;
+			(*new_insn)->x_reg = 0;
+			(*new_insn)->off = (s16) (
+			-sizeof(struct classic_bpf_stack_layout) +
+			offsetof(struct classic_bpf_stack_layout, flow_inited));
+			(*new_insn)->imm = 0;
+		}
+		(*new_insn)++;
+	}
+	/* ctx = arg1 */
+	if (do_write_code)
+		**new_insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_CTX, BPF_REG_ARG1);
+	(*new_insn)++;
+}
+
 /**
  *	sk_convert_filter - convert filter program
  *	@prog: the user passed filter program
@@ -867,10 +932,7 @@ do_pass:
 	new_insn = new_prog;
 	fp = prog;
 
-	if (new_insn) {
-		*new_insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_CTX, BPF_REG_ARG1);
-	}
-	new_insn++;
+	__sk_convert_filter_prologue(fp, len, &new_insn);
 
 	for (i = 0; i < len; fp++, i++) {
 		struct sock_filter_int tmp_insns[6] = { };
@@ -1041,7 +1103,10 @@ do_pass:
 			insn->a_reg = BPF_REG_FP;
 			insn->x_reg = fp->code == BPF_ST ?
 				      BPF_REG_A : BPF_REG_X;
-			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
+			insn->off =
+			    -sizeof(struct classic_bpf_stack_layout) +
+			    offsetof(struct classic_bpf_stack_layout,
+				     mem[fp->k]);
 			break;
 
 		/* Load from stack. */
@@ -1051,7 +1116,10 @@ do_pass:
 			insn->a_reg = BPF_CLASS(fp->code) == BPF_LD ?
 				      BPF_REG_A : BPF_REG_X;
 			insn->x_reg = BPF_REG_FP;
-			insn->off = -(BPF_MEMWORDS - fp->k) * 4;
+			insn->off =
+			    -sizeof(struct classic_bpf_stack_layout) +
+			    offsetof(struct classic_bpf_stack_layout,
+				     mem[fp->k]);
 			break;
 
 		/* A = K or X = K */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12..bf3cb99 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -275,16 +275,20 @@ EXPORT_SYMBOL(__skb_tx_hash);
  * truncate packets without needing to push actual payload to the user
  * space and can analyze headers only, instead.
  */
-u32 __skb_get_poff(const struct sk_buff *skb)
+u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow,
+		u32 *flow_inited)
 {
-	struct flow_keys keys;
 	u32 poff = 0;
 
-	if (!skb_flow_dissect(skb, &keys))
-		return 0;
+	/* check whether the flow dissector has already been run */
+	if (!*flow_inited) {
+		if (!skb_flow_dissect(skb, flow))
+			return 0;
+		*flow_inited = 1;
+	}
 
-	poff += keys.thoff;
-	switch (keys.ip_proto) {
+	poff += flow->thoff;
+	switch (flow->ip_proto) {
 	case IPPROTO_TCP: {
 		const struct tcphdr *tcph;
 		struct tcphdr _tcph;
-- 
1.9.1.423.g4596e3a
