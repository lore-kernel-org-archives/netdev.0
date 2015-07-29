From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next v2 3/5] s390/bpf: increase BPF_SIZE_MAX
Date: Wed, 29 Jul 2015 21:15:16 +0200
Message-ID: <1438197318-16903-4-git-send-email-holzheu@linux.vnet.ibm.com>
References: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:36362 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbbG2TP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 15:15:28 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Wed, 29 Jul 2015 20:15:27 +0100
In-Reply-To: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have the restriction that jitted BPF programs can
have a maximum size of one page. The reason is that we use short
displacements for the literal pool.

The 20 bit displacements are available since z990 and BPF requires
z196 as minimum. Therefore we can remove this restriction and use
everywhere 20 bit signed long displacements.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 66926ab..04af367 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -45,7 +45,7 @@ struct bpf_jit {
 	int labels[1];		/* Labels for local jumps */
 };
 
-#define BPF_SIZE_MAX	4096	/* Max size for program */
+#define BPF_SIZE_MAX	0x7ffff	/* Max size for program (20 bit signed displ) */
 
 #define SEEN_SKB	1	/* skb access */
 #define SEEN_MEM	2	/* use mem[] for temporary storage */
@@ -203,15 +203,6 @@ static inline void reg_set_seen(struct bpf_jit *jit, u32 b1)
 	_EMIT6(op1 | __disp, op2);				\
 })
 
-#define EMIT6_DISP(op1, op2, b1, b2, b3, disp)			\
-({								\
-	_EMIT6_DISP(op1 | reg(b1, b2) << 16 |			\
-		    reg_high(b3) << 8, op2, disp);		\
-	REG_SET_SEEN(b1);					\
-	REG_SET_SEEN(b2);					\
-	REG_SET_SEEN(b3);					\
-})
-
 #define _EMIT6_DISP_LH(op1, op2, disp)				\
 ({								\
 	u32 _disp = (u32) disp;					\
@@ -981,8 +972,8 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		REG_SET_SEEN(BPF_REG_5);
 		jit->seen |= SEEN_FUNC;
 		/* lg %w1,<d(imm)>(%l) */
-		EMIT6_DISP(0xe3000000, 0x0004, REG_W1, REG_0, REG_L,
-			   EMIT_CONST_U64(func));
+		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_W1, REG_0, REG_L,
+			      EMIT_CONST_U64(func));
 		/* basr %r14,%w1 */
 		EMIT2(0x0d00, REG_14, REG_W1);
 		/* lgr %b0,%r2: load return value into %b0 */
-- 
2.3.8
