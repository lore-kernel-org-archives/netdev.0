From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/3] ebpf: migrate bpf_prog's flags to bitfield
Date: Wed, 30 Sep 2015 01:41:50 +0200
Message-ID: <1b3e186eddba7b76ff2311d088512eed1fb47fae.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59686 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbbI2Xl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:41:57 -0400
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we need to add further flags to the bpf_prog structure, lets migrate
both bools to a bitfield representation. The size of the base structure
(excluding insns) remains unchanged at 40 bytes.

Add also tags for the kmemchecker, so that it doesn't throw false
positives. Even in case gcc would generate suboptimal code, it's not
being accessed in performance critical paths.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/arm/net/bpf_jit_32.c       | 2 +-
 arch/arm64/net/bpf_jit_comp.c   | 2 +-
 arch/mips/net/bpf_jit.c         | 2 +-
 arch/powerpc/net/bpf_jit_comp.c | 2 +-
 arch/s390/net/bpf_jit_comp.c    | 2 +-
 arch/sparc/net/bpf_jit_comp.c   | 2 +-
 arch/x86/net/bpf_jit_comp.c     | 2 +-
 include/linux/filter.h          | 6 ++++--
 kernel/bpf/core.c               | 4 ++++
 kernel/bpf/syscall.c            | 4 ++--
 net/core/filter.c               | 2 +-
 11 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 876060b..0df5fd5 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -1047,7 +1047,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 
 	set_memory_ro((unsigned long)header, header->pages);
 	fp->bpf_func = (void *)ctx.target;
-	fp->jited = true;
+	fp->jited = 1;
 out:
 	kfree(ctx.offsets);
 	return;
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index c047598..a44e529 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -744,7 +744,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 
 	set_memory_ro((unsigned long)header, header->pages);
 	prog->bpf_func = (void *)ctx.image;
-	prog->jited = true;
+	prog->jited = 1;
 out:
 	kfree(ctx.offset);
 }
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 0c4a133..77cb273 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1251,7 +1251,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
 	fp->bpf_func = (void *)ctx.target;
-	fp->jited = true;
+	fp->jited = 1;
 
 out:
 	kfree(ctx.offsets);
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 17cea18..0478216 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -679,7 +679,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		((u64 *)image)[1] = local_paca->kernel_toc;
 #endif
 		fp->bpf_func = (void *)image;
-		fp->jited = true;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index eeda051..9a0c4c2 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1310,7 +1310,7 @@ void bpf_int_jit_compile(struct bpf_prog *fp)
 	if (jit.prg_buf) {
 		set_memory_ro((unsigned long)header, header->pages);
 		fp->bpf_func = (void *) jit.prg_buf;
-		fp->jited = true;
+		fp->jited = 1;
 	}
 free_addrs:
 	kfree(jit.addrs);
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index f8b9f71..22564f5 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -812,7 +812,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
 		fp->bpf_func = (void *)image;
-		fp->jited = true;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 70efcd0..7599197 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1109,7 +1109,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 		bpf_flush_icache(header, image + proglen);
 		set_memory_ro((unsigned long)header, header->pages);
 		prog->bpf_func = (void *)image;
-		prog->jited = true;
+		prog->jited = 1;
 	}
 out:
 	kfree(addrs);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index fa2cab9..bad618f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -326,8 +326,10 @@ struct bpf_binary_header {
 
 struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
-	bool			jited;		/* Is our filter JIT'ed? */
-	bool			gpl_compatible;	/* Is our filter GPL compatible? */
+	kmemcheck_bitfield_begin(meta);
+	u16			jited:1,	/* Is our filter JIT'ed? */
+				gpl_compatible:1; /* Is filter GPL compatible? */
+	kmemcheck_bitfield_end(meta);
 	u32			len;		/* Number of filter blocks */
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 67c380c..c8855c2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -82,6 +82,8 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 	if (fp == NULL)
 		return NULL;
 
+	kmemcheck_annotate_bitfield(fp, meta);
+
 	aux = kzalloc(sizeof(*aux), GFP_KERNEL | gfp_extra_flags);
 	if (aux == NULL) {
 		vfree(fp);
@@ -110,6 +112,8 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 
 	fp = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 	if (fp != NULL) {
+		kmemcheck_annotate_bitfield(fp, meta);
+
 		memcpy(fp, fp_old, fp_old->pages * PAGE_SIZE);
 		fp->pages = size / PAGE_SIZE;
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 35bac8e..2190ab1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -553,10 +553,10 @@ static int bpf_prog_load(union bpf_attr *attr)
 		goto free_prog;
 
 	prog->orig_prog = NULL;
-	prog->jited = false;
+	prog->jited = 0;
 
 	atomic_set(&prog->aux->refcnt, 1);
-	prog->gpl_compatible = is_gpl;
+	prog->gpl_compatible = is_gpl ? 1 : 0;
 
 	/* find program type: socket_filter vs tracing_filter */
 	err = find_prog_type(type, prog);
diff --git a/net/core/filter.c b/net/core/filter.c
index 60e3fe7..04664ac 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1001,7 +1001,7 @@ static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
 	int err;
 
 	fp->bpf_func = NULL;
-	fp->jited = false;
+	fp->jited = 0;
 
 	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
-- 
1.9.3
