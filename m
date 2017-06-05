From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 6/8] bpf: Add jited_len to struct bpf_prog
Date: Mon, 5 Jun 2017 12:15:51 -0700
Message-ID: <a82d6b6eb8cdf799953d625fb2eb3e499b8ddf8c.1496686606.git.kafai@fb.com>
References: <cover.1496686606.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58028 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751313AbdFETP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:15:59 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v55JFlV1023606
        for <netdev@vger.kernel.org>; Mon, 5 Jun 2017 12:15:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2awc0s08t0-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:15:58 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 671abf9a4a2311e793a90002c95209d8-d5d3a8f0 for <netdev@vger.kernel.org>;        Mon,
 05 Jun 2017 12:15:57 -0700
In-Reply-To: <cover.1496686606.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add jited_len to struct bpf_prog.  It will be
useful for the struct bpf_prog_info which will
be added in the later patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c     | 1 +
 arch/powerpc/net/bpf_jit_comp64.c | 1 +
 arch/s390/net/bpf_jit_comp.c      | 1 +
 arch/sparc/net/bpf_jit_comp_64.c  | 1 +
 arch/x86/net/bpf_jit_comp.c       | 1 +
 include/linux/filter.h            | 1 +
 6 files changed, 6 insertions(+)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index b1d38eeb24f6..4f95873d7142 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -900,6 +900,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	bpf_jit_binary_lock_ro(header);
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
+	prog->jited_len = image_size;
 
 out_off:
 	kfree(ctx.offset);
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index a01366584a4b..861c5af1c9c4 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -1052,6 +1052,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 
 	fp->bpf_func = (void *)image;
 	fp->jited = 1;
+	fp->jited_len = alloclen;
 
 	bpf_flush_icache(bpf_hdr, (u8 *)bpf_hdr + (bpf_hdr->pages * PAGE_SIZE));
 
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 42ad3832586c..01c6fbc3e85b 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1329,6 +1329,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	bpf_jit_binary_lock_ro(header);
 	fp->bpf_func = (void *) jit.prg_buf;
 	fp->jited = 1;
+	fp->jited_len = jit.size;
 free_addrs:
 	kfree(jit.addrs);
 out:
diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 098874a81f6e..8799ae9a8788 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -1560,6 +1560,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
+	prog->jited_len = image_size;
 
 out_off:
 	kfree(ctx.offset);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 617eac9c4511..e1324f280e06 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1167,6 +1167,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		bpf_jit_binary_lock_ro(header);
 		prog->bpf_func = (void *)image;
 		prog->jited = 1;
+		prog->jited_len = proglen;
 	} else {
 		prog = orig_prog;
 	}
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a20ba40fcb73..1e2dddf21f3b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -432,6 +432,7 @@ struct bpf_prog {
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
+	u32			jited_len;	/* Size of jited insns in bytes */
 	u8			tag[BPF_TAG_SIZE];
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-- 
2.9.3
