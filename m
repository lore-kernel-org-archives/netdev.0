From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/5] s390/bpf: clear correct BPF accumulator register
Date: Tue, 28 Jul 2015 16:09:56 +0200
Message-ID: <1438092600-16221-2-git-send-email-holzheu@linux.vnet.ibm.com>
References: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:59049 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbG1OKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:10:19 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Tue, 28 Jul 2015 15:10:17 +0100
In-Reply-To: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we assumed the following BPF to eBPF register mapping:

 - BPF_REG_A -> BPF_REG_7
 - BPF_REG_X -> BPF_REG_8

Unfortunately this mapping is wrong. The correct mapping is:

 - BPF_REG_A -> BPF_REG_0
 - BPF_REG_X -> BPF_REG_7

So clear the correct registers and use the BPF_REG_A and BPF_REG_X
macros instead of BPF_REG_0/7.

Fixes: 054623105728 ("s390/bpf: Add s390x eBPF JIT compiler backend")
Cc: stable@vger.kernel.org # 4.0+
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 79c731e..01ad166 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -448,13 +448,13 @@ static void bpf_jit_prologue(struct bpf_jit *jit)
 		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
 			      BPF_REG_1, offsetof(struct sk_buff, data));
 	}
-	/* BPF compatibility: clear A (%b7) and X (%b8) registers */
-	if (REG_SEEN(BPF_REG_7))
-		/* lghi %b7,0 */
-		EMIT4_IMM(0xa7090000, BPF_REG_7, 0);
-	if (REG_SEEN(BPF_REG_8))
-		/* lghi %b8,0 */
-		EMIT4_IMM(0xa7090000, BPF_REG_8, 0);
+	/* BPF compatibility: clear A (%b0) and X (%b7) registers */
+	if (REG_SEEN(BPF_REG_A))
+		/* lghi %ba,0 */
+		EMIT4_IMM(0xa7090000, BPF_REG_A, 0);
+	if (REG_SEEN(BPF_REG_X))
+		/* lghi %bx,0 */
+		EMIT4_IMM(0xa7090000, BPF_REG_X, 0);
 }
 
 /*
-- 
2.3.8
