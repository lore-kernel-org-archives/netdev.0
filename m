From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 1/3] powerpc: bpf: remove redundant check for non-null image
Date: Fri, 13 Jan 2017 22:40:00 +0530
Message-ID: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net, davem@davemloft.net
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:35820 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751052AbdAMRK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:10:29 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0DH9XRs088835
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:29 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27y00agjpq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:29 -0500
Received: from localhost
        by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Fri, 13 Jan 2017 22:40:25 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
        by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0DB3A1258026
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:41:57 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
        by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0DH9YTr27066590
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:39:34 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
        by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0DHAG0q010692
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:22 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

We have a check earlier to ensure we don't proceed if image is NULL. As
such, the redundant check can be removed.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
[Added similar changes for classic BPF JIT]
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit_comp.c   | 17 +++++++++--------
 arch/powerpc/net/bpf_jit_comp64.c | 16 ++++++++--------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 7e706f3..f9941b3 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -662,16 +662,17 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		 */
 		bpf_jit_dump(flen, proglen, pass, code_base);
 
-	if (image) {
-		bpf_flush_icache(code_base, code_base + (proglen/4));
+	bpf_flush_icache(code_base, code_base + (proglen/4));
+
 #ifdef CONFIG_PPC64
-		/* Function descriptor nastiness: Address + TOC */
-		((u64 *)image)[0] = (u64)code_base;
-		((u64 *)image)[1] = local_paca->kernel_toc;
+	/* Function descriptor nastiness: Address + TOC */
+	((u64 *)image)[0] = (u64)code_base;
+	((u64 *)image)[1] = local_paca->kernel_toc;
 #endif
-		fp->bpf_func = (void *)image;
-		fp->jited = 1;
-	}
+
+	fp->bpf_func = (void *)image;
+	fp->jited = 1;
+
 out:
 	kfree(addrs);
 	return;
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 0fe98a5..89b6a86 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -1046,16 +1046,16 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 		 */
 		bpf_jit_dump(flen, proglen, pass, code_base);
 
-	if (image) {
-		bpf_flush_icache(bpf_hdr, image + alloclen);
+	bpf_flush_icache(bpf_hdr, image + alloclen);
+
 #ifdef PPC64_ELF_ABI_v1
-		/* Function descriptor nastiness: Address + TOC */
-		((u64 *)image)[0] = (u64)code_base;
-		((u64 *)image)[1] = local_paca->kernel_toc;
+	/* Function descriptor nastiness: Address + TOC */
+	((u64 *)image)[0] = (u64)code_base;
+	((u64 *)image)[1] = local_paca->kernel_toc;
 #endif
-		fp->bpf_func = (void *)image;
-		fp->jited = 1;
-	}
+
+	fp->bpf_func = (void *)image;
+	fp->jited = 1;
 
 out:
 	kfree(addrs);
-- 
2.10.2
