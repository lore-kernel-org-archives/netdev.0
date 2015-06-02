From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net 2/2] s390/bpf: fix bpf frame pointer setup
Date: Mon,  1 Jun 2015 22:48:35 -0700
Message-ID: <1433224115-28411-2-git-send-email-ast@plumgrid.com>
References: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34590 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbbFBFso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:48:44 -0400
Received: by payr10 with SMTP id r10so43123895pay.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 22:48:44 -0700 (PDT)
In-Reply-To: <1433224115-28411-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

Currently the bpf frame pointer is set to the old r15. This is
wrong because of packed stack. Fix this and adjust the frame pointer
to respect packed stack. This now generates a prolog like the following:

 3ff8001c3fa: eb67f0480024   stmg    %r6,%r7,72(%r15)
 3ff8001c400: ebcff0780024   stmg    %r12,%r15,120(%r15)
 3ff8001c406: b904001f       lgr     %r1,%r15      <- load backchain
 3ff8001c40a: 41d0f048       la      %r13,72(%r15) <- load adjusted bfp
 3ff8001c40e: a7fbfd98       aghi    %r15,-616
 3ff8001c412: e310f0980024   stg     %r1,152(%r15) <- save backchain

Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/s390/net/bpf_jit_comp.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 20c146d1251a..55423d8be580 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -384,13 +384,16 @@ static void bpf_jit_prologue(struct bpf_jit *jit)
 	}
 	/* Setup stack and backchain */
 	if (jit->seen & SEEN_STACK) {
-		/* lgr %bfp,%r15 (BPF frame pointer) */
-		EMIT4(0xb9040000, BPF_REG_FP, REG_15);
+		if (jit->seen & SEEN_FUNC)
+			/* lgr %w1,%r15 (backchain) */
+			EMIT4(0xb9040000, REG_W1, REG_15);
+		/* la %bfp,STK_160_UNUSED(%r15) (BPF frame pointer) */
+		EMIT4_DISP(0x41000000, BPF_REG_FP, REG_15, STK_160_UNUSED);
 		/* aghi %r15,-STK_OFF */
 		EMIT4_IMM(0xa70b0000, REG_15, -STK_OFF);
 		if (jit->seen & SEEN_FUNC)
-			/* stg %bfp,152(%r15) (backchain) */
-			EMIT6_DISP_LH(0xe3000000, 0x0024, BPF_REG_FP, REG_0,
+			/* stg %w1,152(%r15) (backchain) */
+			EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0,
 				      REG_15, 152);
 	}
 	/*
-- 
1.7.9.5
