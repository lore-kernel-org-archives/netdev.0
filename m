From: Chema Gonzalez <chema@google.com>
Subject: [PATCH v5 net-next 1/3] net: flow_dissector: avoid multiple calls in BPF
Date: Fri, 16 May 2014 11:41:41 -0700
Message-ID: <1400265701-10333-1-git-send-email-chema@google.com>
References: <1398882591-30422-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:40382 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757390AbaEPSln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:41:43 -0400
Received: by mail-ie0-f201.google.com with SMTP id rp18so34992iec.4
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 11:41:42 -0700 (PDT)
In-Reply-To: <1398882591-30422-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want multiple calls to __skb_get_poff() in the same filter to only
cause one invocation to the flow dissector. In order to reuse the result
of the flow dissector invocation (skb_flow_dissect()), we add a flow_keys
variable in the eBPF runner stack (__sk_run_filter() function), and pass
it as an argument to __skb_get_poff(). __skb_get_poff() inits the variable
the very first time it is called, and reuses the result in any further
invocation.

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
ld toff
ld toff
ld toff
ld tproto
ld tproto
ld tproto
ret #-1
drop: ret #0
$ ./tools/net/bpf_asm tools/net/ipv4_tcp_poff2.bpf
16,40 0 0 12,21 0 13 2048,48 0 0 23,21 0 11 6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963260,32 0 0 4294963260,32 0 0 4294963260,32 0 0 4294963264,32 0 0 4294963264,32 0 0 4294963264,6 0 0 4294967295,6 0 0 0,

And then, in a VM, I ran:

$ tcpdump -n -i eth0 -f "16,40 0 0 12,21 0 13 2048,48 0 0 23,21 0 11
6,32 0 0 4294963252,32 0 0 4294963252,32 0 0 4294963252,32 0 0
4294963252,32 0 0 4294963260,32 0 0 4294963260,32 0 0 4294963260,32 0
0 4294963264,32 0 0 4294963264,32 0 0 4294963264,6 0 0 4294967295,6 0
0 0,"

This tcpdump is github's tcpdump HEAD with
https://github.com/the-tcpdump-group/libpcap/pull/353.

Adding some labels shows how the flow dissector is only called for
the first "ld poff":

...
[   14.400269] --------__sk_run_filter(): setting flow: {0, 481192, -30720, 1013, 8} is inited? 0
[   14.401528] --------__skb_get_poff(): checking flow dissector: {0, 481192, -30720, 1013, 8} is inited? 0
[   14.403088] --------__skb_get_poff(): before calling flow dissector: {0, 481192, -30720, 1013, 8}
[   14.404068] --------__skb_get_poff(): after calling flow dissector: {23374016, -26957632, -174123520, 34, 6}
[   14.405154] --------__skb_get_poff(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.406264] --------__skb_get_poff(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.407412] --------__skb_get_poff(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.408520] --------__skb_get_tra_offset(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.409673] --------__skb_get_tra_offset(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.410845] --------__skb_get_tra_offset(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.412008] --------__skb_get_tra_protocol(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.413255] --------__skb_get_tra_protocol(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.414437] --------__skb_get_tra_protocol(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
[   14.415888] --------__sk_run_filter(): setting flow: {-1, 399522456, -30720, 1736, 8} is inited? 0
[   14.415929] --------__sk_run_filter(): setting flow: {0, 1400960, -30720, 56016, 7} is inited? 0
[   14.415932] --------__skb_get_poff(): checking flow dissector: {0, 1400960, -30720, 56016, 7} is inited? 0
[   14.415932] --------__skb_get_poff(): before calling flow dissector: {0, 1400960, -30720, 56016, 7}
[   14.415950] --------__skb_get_poff(): after calling flow dissector: {23374016, -26957632, -174123520, 34, 6}
[   14.415952] --------__skb_get_poff(): checking flow dissector: {23374016, -26957632, -174123520, 34, 6} is inited? 1
...

$ modprobe test_bpf
[    9.809183] test_bpf: #0 TAX 23 39 39 PASS
[    9.820202] test_bpf: #1 TXA 10 10 11 PASS
[    9.824239] test_bpf: #2 ADD_SUB_MUL_K 13 PASS
[    9.826369] test_bpf: #3 DIV_KX 45 PASS
[    9.831530] test_bpf: #4 AND_OR_LSH_K 15 14 PASS
[    9.835290] test_bpf: #5 LD_IND 11 11 11 PASS
[    9.839567] test_bpf: #6 LD_ABS 10 10 10 PASS
[    9.843381] test_bpf: #7 LD_ABS_LL 18 39 PASS
[    9.849925] test_bpf: #8 LD_IND_LL 18 18 18 PASS
[    9.856191] test_bpf: #9 LD_ABS_NET 15 18 PASS
[    9.860391] test_bpf: #10 LD_IND_NET 15 18 17 PASS
[    9.866310] test_bpf: #11 LD_PKTTYPE 44 47 PASS
[    9.876354] test_bpf: #12 LD_MARK 7 7 PASS
[    9.878626] test_bpf: #13 LD_RXHASH 8 8 PASS
[    9.880990] test_bpf: #14 LD_QUEUE 7 7 PASS
[    9.883251] test_bpf: #15 LD_PROTOCOL 20 20 PASS
[    9.888086] test_bpf: #16 LD_VLAN_TAG 9 9 PASS
[    9.890708] test_bpf: #17 LD_VLAN_TAG_PRESENT 10 11 PASS
[    9.893785] test_bpf: #18 LD_IFINDEX 11 11 PASS
[    9.896924] test_bpf: #19 LD_HATYPE 13 14 PASS
[    9.900458] test_bpf: #20 LD_CPU 43 43 PASS
[    9.909919] test_bpf: #21 LD_NLATTR 18 23 PASS
[    9.914841] test_bpf: #22 LD_NLATTR_NEST 110 155 PASS
[    9.942252] test_bpf: #23 LD_PAYLOAD_OFF 134 93 PASS
[    9.965865] test_bpf: #24 LD_ANC_XOR 9 9 PASS
[    9.968571] test_bpf: #25 SPILL_FILL 26 26 26 PASS
[    9.977303] test_bpf: #26 JEQ 10 10 11 PASS
[    9.981278] test_bpf: #27 JGT 10 11 11 PASS
[    9.985383] test_bpf: #28 JGE 13 18 19 PASS
[    9.991189] test_bpf: #29 JSET 24 29 67 PASS
[   10.004116] test_bpf: #30 tcpdump port 22 9 32 37 PASS
[   10.012935] test_bpf: #31 tcpdump complex 9 28 79 PASS
[   10.025630] test_bpf: #32 RET_A 7 7 PASS
[   10.027799] test_bpf: #33 INT: ADD trivial 12 PASS
[   10.029827] test_bpf: #34 INT: MUL_X 10 PASS
[   10.031588] test_bpf: #35 INT: MUL_X2 12 PASS
[   10.033561] test_bpf: #36 INT: MUL32_X 12 PASS
[   10.035462] test_bpf: #37 INT: ADD 64-bit 583 PASS
[   10.094546] test_bpf: #38 INT: ADD 32-bit 525 PASS
[   10.147935] test_bpf: #39 INT: SUB 386 PASS
[   10.187293] test_bpf: #40 INT: XOR 142 PASS
[   10.202252] test_bpf: #41 INT: MUL 171 PASS
[   10.220148] test_bpf: #42 INT: ALU MIX 33 PASS
[   10.224212] test_bpf: #43 INT: DIV + ABS 24 26 PASS
[   10.230178] test_bpf: #44 INT: DIV by zero 10 7 PASS
[   10.232817] test_bpf: #45 check: missing ret PASS
[   10.233604] test_bpf: #46 check: div_k_0 PASS
[   10.234273] test_bpf: #47 check: unknown insn PASS
[   10.235008] test_bpf: #48 check: out of range spill/fill PASS

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 include/linux/skbuff.h    |  3 ++-
 net/core/filter.c         | 26 +++++++++++++++++++++++++-
 net/core/flow_dissector.c | 16 ++++++++++------
 3 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7a9beeb..5f42eee 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3065,7 +3065,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
-u32 __skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow,
+		bool *flow_initted);
 
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
diff --git a/net/core/filter.c b/net/core/filter.c
index 32c5b44..fc20588 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -66,6 +66,11 @@
 #define CTX	regs[BPF_REG_CTX]
 #define K	insn->imm
 
+struct sk_run_filter_ctx {
+	struct flow_keys flow;
+	bool flow_initted;
+};
+
 /* No hurry in this branch
  *
  * Exported for the bpf jit load helper.
@@ -252,6 +257,7 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 	};
 	void *ptr;
 	int off;
+	struct sk_run_filter_ctx *context;
 
 #define CONT	 ({ insn++; goto select_insn; })
 #define CONT_JMP ({ insn++; goto select_insn; })
@@ -259,6 +265,17 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
 	ARG1 = (u64) (unsigned long) ctx;
 
+	/* init context.
+	 *
+	 * Top (BPF_MEMWORDS * 4) bytes are used to represent classic BPF
+	 * mem[0-15] slots. We use the next sizeof(struct sk_run_filter_ctx)
+	 * bytes of stack to share context data (so far only the flow_keys
+	 * obtained from dissecting the flow, and a bool stating whether
+	 * such field has been inited)
+	 */
+	context = (void *)FP - BPF_MEMWORDS * 4 - sizeof(*context);
+	context->flow_initted = false;
+
 	/* Register for user BPF programs need to be reset first. */
 	regs[BPF_REG_A] = 0;
 	regs[BPF_REG_X] = 0;
@@ -602,7 +619,10 @@ static unsigned int pkt_type_offset(void)
 
 static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
-	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx);
+	struct sk_run_filter_ctx *context = (void *) r4 - BPF_MEMWORDS * 4 -
+			sizeof(*context);
+	return __skb_get_poff((struct sk_buff *)(unsigned long) ctx,
+			&context->flow, &context->flow_initted);
 }
 
 static u64 __skb_get_nlattr(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
@@ -783,6 +803,10 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG3, BPF_REG_X);
 		insn++;
 
+		/* arg4 = FP */
+		*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_ARG4, BPF_REG_FP);
+		insn++;
+
 		/* Emit call(ctx, arg2=A, arg3=X) */
 		insn->code = BPF_JMP | BPF_CALL;
 		switch (fp->k) {
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 107ed12..cefe1d2 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -275,16 +275,20 @@ EXPORT_SYMBOL(__skb_tx_hash);
  * truncate packets without needing to push actual payload to the user
  * space and can analyze headers only, instead.
  */
-u32 __skb_get_poff(const struct sk_buff *skb)
+u32 __skb_get_poff(const struct sk_buff *skb, struct flow_keys *flow,
+		bool *flow_initted)
 {
-	struct flow_keys keys;
 	u32 poff = 0;
 
-	if (!skb_flow_dissect(skb, &keys))
-		return 0;
+	/* check whether the flow dissector has already been run */
+	if (!*flow_initted) {
+		if (!skb_flow_dissect(skb, flow))
+			return 0;
+		*flow_initted = true;
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
