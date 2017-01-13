From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit endian operations
Date: Fri, 13 Jan 2017 22:40:02 +0530
Message-ID: <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net, davem@davemloft.net
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52478 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750877AbdAMRKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:10:43 -0500
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0DH9Y2w033558
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:37 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xv8m93qa-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:36 -0500
Received: from localhost
        by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Fri, 13 Jan 2017 22:40:32 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
        by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7F1121258026
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:42:04 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
        by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0DHAU9M40501454
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:30 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
        by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0DHAQrb011203
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:29 +0530
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generate instructions to perform the endian conversion using registers,
rather than generating two memory accesses.

The "way easier and faster" comment was obviously for the author, not
the processor.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit_comp64.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 1e313db..0413a89 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -599,16 +599,22 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 				break;
 			case 64:
 				/*
-				 * Way easier and faster(?) to store the value
-				 * into stack and then use ldbrx
+				 * We'll split it up into two words, swap those
+				 * independently and then merge them back.
 				 *
-				 * ctx->seen will be reliable in pass2, but
-				 * the instructions generated will remain the
-				 * same across all passes
+				 * First up, let's swap the most-significant word.
 				 */
-				PPC_STD(dst_reg, 1, bpf_jit_stack_local(ctx));
-				PPC_ADDI(b2p[TMP_REG_1], 1, bpf_jit_stack_local(ctx));
-				PPC_LDBRX(dst_reg, 0, b2p[TMP_REG_1]);
+				PPC_RLDICL(b2p[TMP_REG_1], dst_reg, 32, 32);
+				PPC_RLWINM(b2p[TMP_REG_2], b2p[TMP_REG_1], 8, 0, 31);
+				PPC_RLWIMI(b2p[TMP_REG_2], b2p[TMP_REG_1], 24, 0, 7);
+				PPC_RLWIMI(b2p[TMP_REG_2], b2p[TMP_REG_1], 24, 16, 23);
+				/* Then, the second half */
+				PPC_RLWINM(b2p[TMP_REG_1], dst_reg, 8, 0, 31);
+				PPC_RLWIMI(b2p[TMP_REG_1], dst_reg, 24, 0, 7);
+				PPC_RLWIMI(b2p[TMP_REG_1], dst_reg, 24, 16, 23);
+				/* Merge back */
+				PPC_RLDICR(dst_reg, b2p[TMP_REG_1], 32, 31);
+				PPC_OR(dst_reg, dst_reg, b2p[TMP_REG_2]);
 				break;
 			}
 			break;
-- 
2.10.2
