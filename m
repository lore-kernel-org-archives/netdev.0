From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/5] s390/bpf: Only clear A and X for converted BPF programs
Date: Tue, 28 Jul 2015 16:09:59 +0200
Message-ID: <1438092600-16221-5-git-send-email-holzheu@linux.vnet.ibm.com>
References: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:52915 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301AbbG1OKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:10:43 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Tue, 28 Jul 2015 15:10:40 +0100
In-Reply-To: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only classic BPF programs that have been converted to eBPF need to clear
the A and X registers. We can check for converted programs with:

  bpf_prog->type == BPF_PROG_TYPE_UNSPEC

So add the check and skip initialization for real eBPF programs.

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index bea5cfc..a025ddc 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -387,7 +387,7 @@ static void save_restore_regs(struct bpf_jit *jit, int op)
  * Save registers and create stack frame if necessary.
  * See stack frame layout desription in "bpf_jit.h"!
  */
-static void bpf_jit_prologue(struct bpf_jit *jit)
+static void bpf_jit_prologue(struct bpf_jit *jit, bool is_classic)
 {
 	if (jit->seen & SEEN_TAIL_CALL) {
 		/* xc STK_OFF_TCCNT(4,%r15),STK_OFF_TCCNT(%r15) */
@@ -440,13 +440,15 @@ static void bpf_jit_prologue(struct bpf_jit *jit)
 		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
 			      BPF_REG_1, offsetof(struct sk_buff, data));
 	}
-	/* BPF compatibility: clear A (%b0) and X (%b7) registers */
-	if (REG_SEEN(BPF_REG_A))
-		/* lghi %ba,0 */
-		EMIT4_IMM(0xa7090000, BPF_REG_A, 0);
-	if (REG_SEEN(BPF_REG_X))
-		/* lghi %bx,0 */
-		EMIT4_IMM(0xa7090000, BPF_REG_X, 0);
+	/* Clear A (%b0) and X (%b7) registers for converted BPF programs */
+	if (is_classic) {
+		if (REG_SEEN(BPF_REG_A))
+			/* lghi %ba,0 */
+			EMIT4_IMM(0xa7090000, BPF_REG_A, 0);
+		if (REG_SEEN(BPF_REG_X))
+			/* lghi %bx,0 */
+			EMIT4_IMM(0xa7090000, BPF_REG_X, 0);
+	}
 }
 
 /*
@@ -1232,7 +1234,7 @@ static int bpf_jit_prog(struct bpf_jit *jit, struct bpf_prog *fp)
 	jit->lit = jit->lit_start;
 	jit->prg = 0;
 
-	bpf_jit_prologue(jit);
+	bpf_jit_prologue(jit, fp->type == BPF_PROG_TYPE_UNSPEC);
 	for (i = 0; i < fp->len; i += insn_count) {
 		insn_count = bpf_jit_insn(jit, fp, i);
 		if (insn_count < 0)
-- 
2.3.8
