From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/5] s390/bpf: recache skb->data/hlen for skb_vlan_push/pop
Date: Tue, 28 Jul 2015 16:10:00 +0200
Message-ID: <1438092600-16221-6-git-send-email-holzheu@linux.vnet.ibm.com>
References: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:35072 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755599AbbG1OKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:10:20 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Tue, 28 Jul 2015 15:10:18 +0100
In-Reply-To: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow eBPF programs attached to TC qdiscs call skb_vlan_push/pop
via helper functions. These functions may change skb->data/hlen.
This data is cached by s390 JIT to improve performance of ld_abs/ld_ind
instructions. Therefore after a change we have to reload the data.

In case of usage of skb_vlan_push/pop, in the prologue we store
the SKB pointer on the stack and restore it after BPF_JMP_CALL
to skb_vlan_push/pop.

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit.h      |  5 +++-
 arch/s390/net/bpf_jit_comp.c | 55 ++++++++++++++++++++++++++------------------
 2 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/arch/s390/net/bpf_jit.h b/arch/s390/net/bpf_jit.h
index f6498ee..f010c93 100644
--- a/arch/s390/net/bpf_jit.h
+++ b/arch/s390/net/bpf_jit.h
@@ -36,6 +36,8 @@ extern u8 sk_load_word[], sk_load_half[], sk_load_byte[];
  *	      |   BPF stack   |     |
  *	      |		      |     |
  *	      +---------------+     |
+ *	      | 8 byte skbp   |     |
+ * R15+170 -> +---------------+     |
  *	      | 8 byte hlen   |     |
  * R15+168 -> +---------------+     |
  *	      | 4 byte align  |     |
@@ -51,11 +53,12 @@ extern u8 sk_load_word[], sk_load_half[], sk_load_byte[];
  * We get 160 bytes stack space from calling function, but only use
  * 12 * 8 byte for old backchain, r15..r6, and tail_call_cnt.
  */
-#define STK_SPACE	(MAX_BPF_STACK + 8 + 4 + 4 + 160)
+#define STK_SPACE	(MAX_BPF_STACK + 8 + 8 + 4 + 4 + 160)
 #define STK_160_UNUSED	(160 - 12 * 8)
 #define STK_OFF		(STK_SPACE - STK_160_UNUSED)
 #define STK_OFF_TMP	160	/* Offset of tmp buffer on stack */
 #define STK_OFF_HLEN	168	/* Offset of SKB header length on stack */
+#define STK_OFF_SKBP	170	/* Offset of SKB pointer on stack */
 
 #define STK_OFF_R6	(160 - 11 * 8)	/* Offset of r6 on stack */
 #define STK_OFF_TCCNT	(160 - 12 * 8)	/* Offset of tail_call_cnt on stack */
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index a025ddc..ece46d4 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -53,6 +53,7 @@ struct bpf_jit {
 #define SEEN_LITERAL	8	/* code uses literals */
 #define SEEN_FUNC	16	/* calls C functions */
 #define SEEN_TAIL_CALL	32	/* code uses tail calls */
+#define SEEN_SKB_CHANGE	64	/* code changes skb data */
 #define SEEN_STACK	(SEEN_FUNC | SEEN_MEM | SEEN_SKB)
 
 /*
@@ -382,6 +383,26 @@ static void save_restore_regs(struct bpf_jit *jit, int op)
 }
 
 /*
+ * For SKB access %b1 contains the SKB pointer. For "bpf_jit.S"
+ * we store the SKB header length on the stack and the SKB data
+ * pointer in REG_SKB_DATA.
+ */
+static void emit_load_skb_data_hlen(struct bpf_jit *jit)
+{
+	/* Header length: llgf %w1,<len>(%b1) */
+	EMIT6_DISP_LH(0xe3000000, 0x0016, REG_W1, REG_0, BPF_REG_1,
+		      offsetof(struct sk_buff, len));
+	/* s %w1,<data_len>(%b1) */
+	EMIT4_DISP(0x5b000000, REG_W1, BPF_REG_1,
+		   offsetof(struct sk_buff, data_len));
+	/* stg %w1,ST_OFF_HLEN(%r0,%r15) */
+	EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0, REG_15, STK_OFF_HLEN);
+	/* lg %skb_data,data_off(%b1) */
+	EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
+		      BPF_REG_1, offsetof(struct sk_buff, data));
+}
+
+/*
  * Emit function prologue
  *
  * Save registers and create stack frame if necessary.
@@ -421,25 +442,12 @@ static void bpf_jit_prologue(struct bpf_jit *jit, bool is_classic)
 			EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0,
 				      REG_15, 152);
 	}
-	/*
-	 * For SKB access %b1 contains the SKB pointer. For "bpf_jit.S"
-	 * we store the SKB header length on the stack and the SKB data
-	 * pointer in REG_SKB_DATA.
-	 */
-	if (jit->seen & SEEN_SKB) {
-		/* Header length: llgf %w1,<len>(%b1) */
-		EMIT6_DISP_LH(0xe3000000, 0x0016, REG_W1, REG_0, BPF_REG_1,
-			      offsetof(struct sk_buff, len));
-		/* s %w1,<data_len>(%b1) */
-		EMIT4_DISP(0x5b000000, REG_W1, BPF_REG_1,
-			   offsetof(struct sk_buff, data_len));
-		/* stg %w1,ST_OFF_HLEN(%r0,%r15) */
+	if (jit->seen & SEEN_SKB)
+		emit_load_skb_data_hlen(jit);
+	if (jit->seen & SEEN_SKB_CHANGE)
+		/* stg %b1,ST_OFF_SKBP(%r0,%r15) */
 		EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0, REG_15,
-			      STK_OFF_HLEN);
-		/* lg %skb_data,data_off(%b1) */
-		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
-			      BPF_REG_1, offsetof(struct sk_buff, data));
-	}
+			      STK_OFF_SKBP);
 	/* Clear A (%b0) and X (%b7) registers for converted BPF programs */
 	if (is_classic) {
 		if (REG_SEEN(BPF_REG_A))
@@ -967,10 +975,6 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		 */
 		const u64 func = (u64)__bpf_call_base + imm;
 
-		if (bpf_helper_changes_skb_data((void *)func))
-			/* TODO reload skb->data, hlen */
-			return -1;
-
 		REG_SET_SEEN(BPF_REG_5);
 		jit->seen |= SEEN_FUNC;
 		/* lg %w1,<d(imm)>(%l) */
@@ -980,6 +984,13 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		EMIT2(0x0d00, REG_14, REG_W1);
 		/* lgr %b0,%r2: load return value into %b0 */
 		EMIT4(0xb9040000, BPF_REG_0, REG_2);
+		if (bpf_helper_changes_skb_data((void *)func)) {
+			jit->seen |= SEEN_SKB_CHANGE;
+			/* lg %b1,ST_OFF_SKBP(%r15) */
+			EMIT6_DISP_LH(0xe3000000, 0x0004, BPF_REG_1, REG_0,
+				      REG_15, STK_OFF_SKBP);
+			emit_load_skb_data_hlen(jit);
+		}
 		break;
 	}
 	case BPF_JMP | BPF_CALL | BPF_X:
-- 
2.3.8
