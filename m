From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] test_bpf: Add backward jump test case
Date: Fri, 22 May 2015 08:36:40 -0700
Message-ID: <1432309000-11545-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33081 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757493AbbEVPgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 11:36:51 -0400
Received: by pdbqa5 with SMTP id qa5so22372528pdb.0
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 08:36:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

Currently the testsuite does not have a test case with a backward jump.
The s390x JIT (kernel 4.0) had a bug in that area.
So add one new test case for this now.

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index aaa0a40a7eb3..9b012a811ee1 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -3940,6 +3940,22 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JGT | BPF_K jump backwards */
+	{
+		"JMP_JGT_K: if (3 > 2) return 1 (jump backwards)",
+		.u.insns_int = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2), /* goto start */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1), /* out: */
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0), /* start: */
+			BPF_LD_IMM64(R1, 3), /* note: this takes 2 insns */
+			BPF_JMP_IMM(BPF_JGT, R1, 2, -6), /* goto out */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	{
 		"JMP_JGE_K: if (3 >= 3) return 1",
 		.u.insns_int = {
-- 
1.7.9.5
