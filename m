From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 2/3] powerpc: bpf: flush the entire JIT buffer
Date: Fri, 13 Jan 2017 22:40:01 +0530
Message-ID: <897d01cca8cd61a42493a4f6ba6bfca056419686.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net, davem@davemloft.net
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38091 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751166AbdAMRKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:10:36 -0500
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0DH9LCW049896
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:35 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27y0cwy3m3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:10:35 -0500
Received: from localhost
        by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Fri, 13 Jan 2017 22:40:30 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
        by d28dlp02.in.ibm.com (Postfix) with ESMTP id A9DB0394005E
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:27 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
        by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0DHAQC834275344
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
        by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0DHANKd010967
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 22:40:26 +0530
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With bpf_jit_binary_alloc(), we allocate at a page granularity and fill
the rest of the space with illegal instructions to mitigate BPF spraying
attacks, while having the actual JIT'ed BPF program at a random location
within the allocated space. Under this scenario, it would be better to
flush the entire allocated buffer rather than just the part containing
the actual program. We already flush the buffer from start to the end of
the BPF program. Extend this to include the illegal instructions after
the BPF program.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit_comp64.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 89b6a86..1e313db 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -1046,8 +1046,6 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 		 */
 		bpf_jit_dump(flen, proglen, pass, code_base);
 
-	bpf_flush_icache(bpf_hdr, image + alloclen);
-
 #ifdef PPC64_ELF_ABI_v1
 	/* Function descriptor nastiness: Address + TOC */
 	((u64 *)image)[0] = (u64)code_base;
@@ -1057,6 +1055,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	fp->bpf_func = (void *)image;
 	fp->jited = 1;
 
+	bpf_flush_icache(bpf_hdr, (u8 *)bpf_hdr + (bpf_hdr->pages * PAGE_SIZE));
+
 out:
 	kfree(addrs);
 
-- 
2.10.2
