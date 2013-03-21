From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] filter: bpf_jit_comp: refactor and unify BPF JIT image dump output
Date: Thu, 21 Mar 2013 22:22:03 +0100
Message-ID: <1363900923-3244-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Mircea Gherzan <mgherzan@gmail.com>,
	Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415Ab3CUVWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 17:22:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bpf_jit_enable > 1, then we dump the emitted JIT compiled image
after creation. Currently, only SPARC and PowerPC has similar output
as in the reference implementation on x86_64. Make a small helper
function in order to reduce duplicated code and make the dump output
uniform across architectures x86_64, SPARC, PPC, ARM (e.g. on ARM
flen, pass and proglen are currently not shown, but would be
interesting to know as well), also for future BPF JIT implementations
on other archs.

Cc: Mircea Gherzan <mgherzan@gmail.com>
Cc: Matt Evans <matt@ozlabs.org>
Cc: Eric Dumazet <eric.dumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/arm/net/bpf_jit_32.c       |  5 ++---
 arch/powerpc/net/bpf_jit_comp.c | 12 ++++--------
 arch/sparc/net/bpf_jit_comp.c   |  6 +-----
 arch/x86/net/bpf_jit_comp.c     |  9 ++-------
 include/linux/filter.h          | 10 ++++++++++
 5 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 6828ef6..ef4d571 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -918,9 +918,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 #endif
 
 	if (bpf_jit_enable > 1)
-		print_hex_dump(KERN_INFO, "BPF JIT code: ",
-			       DUMP_PREFIX_ADDRESS, 16, 4, ctx.target,
-			       alloc_size, false);
+		/* there are 2 passes here */
+		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
 	fp->bpf_func = (void *)ctx.target;
 out:
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index e834f1e..c427ae3 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -671,16 +671,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 	}
 
 	if (bpf_jit_enable > 1)
-		pr_info("flen=%d proglen=%u pass=%d image=%p\n",
-		       flen, proglen, pass, image);
+		/* Note that we output the base address of the code_base
+		 * rather than image, since opcodes are in code_base.
+		 */
+		bpf_jit_dump(flen, proglen, pass, code_base);
 
 	if (image) {
-		if (bpf_jit_enable > 1)
-			print_hex_dump(KERN_ERR, "JIT code: ",
-				       DUMP_PREFIX_ADDRESS,
-				       16, 1, code_base,
-				       proglen, false);
-
 		bpf_flush_icache(code_base, code_base + (proglen/4));
 		/* Function descriptor nastiness: Address + TOC */
 		((u64 *)image)[0] = (u64)code_base;
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 3109ca6..d36a85e 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -795,13 +795,9 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 	}
 
 	if (bpf_jit_enable > 1)
-		pr_err("flen=%d proglen=%u pass=%d image=%p\n",
-		       flen, proglen, pass, image);
+		bpf_jit_dump(flen, proglen, pass, image);
 
 	if (image) {
-		if (bpf_jit_enable > 1)
-			print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
-				       16, 1, image, proglen, false);
 		bpf_flush_icache(image, image + proglen);
 		fp->bpf_func = (void *)image;
 	}
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 3cbe4538..f66b540 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -725,17 +725,12 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 		}
 		oldproglen = proglen;
 	}
+
 	if (bpf_jit_enable > 1)
-		pr_err("flen=%d proglen=%u pass=%d image=%p\n",
-		       flen, proglen, pass, image);
+		bpf_jit_dump(flen, proglen, pass, image);
 
 	if (image) {
-		if (bpf_jit_enable > 1)
-			print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
-				       16, 1, image, proglen, false);
-
 		bpf_flush_icache(image, image + proglen);
-
 		fp->bpf_func = (void *)image;
 	}
 out:
diff --git a/include/linux/filter.h b/include/linux/filter.h
index c45eabc..cc10c5c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -50,6 +50,16 @@ extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, uns
 #ifdef CONFIG_BPF_JIT
 extern void bpf_jit_compile(struct sk_filter *fp);
 extern void bpf_jit_free(struct sk_filter *fp);
+
+static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
+				u32 pass, void *image)
+{
+	pr_err("flen=%u proglen=%u pass=%u image=%p\n",
+	       flen, proglen, pass, image);
+	if (image)
+		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_ADDRESS,
+			       16, 1, image, proglen, false);
+}
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #else
 static inline void bpf_jit_compile(struct sk_filter *fp)
-- 
1.7.11.7
