From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net: bpf: be friendly to kmemcheck
Date: Sat,  6 Sep 2014 11:42:47 +0200
Message-ID: <1409996567-2170-4-git-send-email-dborkman@redhat.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Mikulas Patocka <mpatocka@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaIFJnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Sep 2014 05:43:00 -0400
In-Reply-To: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Mikulas Patocka, kmemcheck currently barks out a
false positive since we don't have special kmemcheck annotation
for bitfields used in bpf_prog structure.

We currently have jited:1, len:31 and thus when accessing len
while CONFIG_KMEMCHECK enabled, kmemcheck throws a warning that
we're reading uninitialized memory.

As we don't need the whole bit universe for pages member, we
can just split it to u16 and use a bool flag for jited instead
of a bitfield.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/arm/net/bpf_jit_32.c       | 2 +-
 arch/mips/net/bpf_jit.c         | 2 +-
 arch/powerpc/net/bpf_jit_comp.c | 2 +-
 arch/s390/net/bpf_jit_comp.c    | 2 +-
 arch/sparc/net/bpf_jit_comp.c   | 2 +-
 arch/x86/net/bpf_jit_comp.c     | 2 +-
 include/linux/filter.h          | 6 +++---
 net/core/filter.c               | 2 +-
 8 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 2d1a5b9..6b45f64 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -933,7 +933,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 
 	set_memory_ro((unsigned long)header, header->pages);
 	fp->bpf_func = (void *)ctx.target;
-	fp->jited = 1;
+	fp->jited = true;
 out:
 	kfree(ctx.offsets);
 	return;
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index cfa83cf..0e97ccd 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1417,7 +1417,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
 	fp->bpf_func = (void *)ctx.target;
-	fp->jited = 1;
+	fp->jited = true;
 
 out:
 	kfree(ctx.offsets);
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 40c53ff..cbae2df 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -686,7 +686,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
 		fp->bpf_func = (void *)image;
-		fp->jited = 1;
+		fp->jited = true;
 	}
 out:
 	kfree(addrs);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index b734f97..555f5c7 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -842,7 +842,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	if (jit.start) {
 		set_memory_ro((unsigned long)header, header->pages);
 		fp->bpf_func = (void *) jit.start;
-		fp->jited = 1;
+		fp->jited = true;
 	}
 out:
 	kfree(addrs);
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index f7a736b..b2ad9dc 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -801,7 +801,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
 		fp->bpf_func = (void *)image;
-		fp->jited = 1;
+		fp->jited = true;
 	}
 out:
 	kfree(addrs);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 9de0b54..d56cd1f 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -955,7 +955,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 		bpf_flush_icache(header, image + proglen);
 		set_memory_ro((unsigned long)header, header->pages);
 		prog->bpf_func = (void *)image;
-		prog->jited = 1;
+		prog->jited = true;
 	}
 out:
 	kfree(addrs);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 868764f..4b59ede 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -300,9 +300,9 @@ struct bpf_work_struct {
 };
 
 struct bpf_prog {
-	u32			pages;		/* Number of allocated pages */
-	u32			jited:1,	/* Is our filter JIT'ed? */
-				len:31;		/* Number of filter blocks */
+	u16			pages;		/* Number of allocated pages */
+	bool			jited;		/* Is our filter JIT'ed? */
+	u32			len;		/* Number of filter blocks */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	struct bpf_work_struct	*work;		/* Deferred free work struct */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
diff --git a/net/core/filter.c b/net/core/filter.c
index fa5b7d0..dfc716f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -972,7 +972,7 @@ static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp)
 	int err;
 
 	fp->bpf_func = NULL;
-	fp->jited = 0;
+	fp->jited = false;
 
 	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
-- 
1.7.11.7
