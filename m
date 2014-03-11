From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 1/9] net: rename fp->bpf_func to fp->run_filter
Date: Tue, 11 Mar 2014 10:19:12 +0100
Message-ID: <1394529560-3490-2-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is a cleanup / rename for the function that actually
performs the filtering from bpf_func to a generic run_filter. This
change was introduced to generalize the socket filtering
infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 arch/arm/net/bpf_jit_32.c       |    6 +++---
 arch/powerpc/net/bpf_jit_comp.c |    6 +++---
 arch/s390/net/bpf_jit_comp.c    |    6 +++---
 arch/sparc/net/bpf_jit_comp.c   |    6 +++---
 arch/x86/net/bpf_jit_comp.c     |    6 +++---
 include/linux/filter.h          |    6 +++---
 net/core/filter.c               |    2 +-
 7 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 271b5e9..65bd347 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -924,7 +924,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		/* there are 2 passes here */
 		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
-	fp->bpf_func = (void *)ctx.target;
+	fp->run_filter = (void *)ctx.target;
 out:
 	kfree(ctx.offsets);
 	return;
@@ -932,7 +932,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
-		module_free(NULL, fp->bpf_func);
+	if (fp->run_filter != sk_run_filter)
+		module_free(NULL, fp->run_filter);
 	kfree(fp);
 }
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 555034f..6491d72 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -688,7 +688,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		/* Function descriptor nastiness: Address + TOC */
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
-		fp->bpf_func = (void *)image;
+		fp->run_filter = (void *)image;
 	}
 out:
 	kfree(addrs);
@@ -697,7 +697,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
-		module_free(NULL, fp->bpf_func);
+	if (fp->run_filter != sk_run_filter)
+		module_free(NULL, fp->run_filter);
 	kfree(fp);
 }
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 708d60e..23089df 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -876,7 +876,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	}
 	if (jit.start) {
 		set_memory_ro((unsigned long)header, header->pages);
-		fp->bpf_func = (void *) jit.start;
+		fp->run_filter = (void *) jit.start;
 	}
 out:
 	kfree(addrs);
@@ -884,10 +884,10 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+	unsigned long addr = (unsigned long)fp->run_filter & PAGE_MASK;
 	struct bpf_binary_header *header = (void *)addr;
 
-	if (fp->bpf_func == sk_run_filter)
+	if (fp->run_filter == sk_run_filter)
 		goto free_filter;
 	set_memory_rw(addr, header->pages);
 	module_free(NULL, header);
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 01fe994..ee1cd30 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -808,7 +808,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
+		fp->run_filter = (void *)image;
 	}
 out:
 	kfree(addrs);
@@ -817,7 +817,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
-		module_free(NULL, fp->bpf_func);
+	if (fp->run_filter != sk_run_filter)
+		module_free(NULL, fp->run_filter);
 	kfree(fp);
 }
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 4ed75dd..bfadd14 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -771,7 +771,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 	if (image) {
 		bpf_flush_icache(header, image + proglen);
 		set_memory_ro((unsigned long)header, header->pages);
-		fp->bpf_func = (void *)image;
+		fp->run_filter = (void *)image;
 	}
 out:
 	kfree(addrs);
@@ -781,7 +781,7 @@ out:
 static void bpf_jit_free_deferred(struct work_struct *work)
 {
 	struct sk_filter *fp = container_of(work, struct sk_filter, work);
-	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+	unsigned long addr = (unsigned long)fp->run_filter & PAGE_MASK;
 	struct bpf_binary_header *header = (void *)addr;
 
 	set_memory_rw(addr, header->pages);
@@ -791,7 +791,7 @@ static void bpf_jit_free_deferred(struct work_struct *work)
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter) {
+	if (fp->run_filter != sk_run_filter) {
 		INIT_WORK(&fp->work, bpf_jit_free_deferred);
 		schedule_work(&fp->work);
 	} else {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index e568c8e..6c5d597 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -27,8 +27,8 @@ struct sk_filter
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
 	struct rcu_head		rcu;
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct sock_filter *filter);
+	unsigned int		(*run_filter)(const struct sk_buff *skb,
+					      const struct sock_filter *filter);
 	union {
 		struct sock_filter     	insns[0];
 		struct work_struct	work;
@@ -70,7 +70,7 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 		print_hex_dump(KERN_ERR, "JIT code: ", DUMP_PREFIX_OFFSET,
 			       16, 1, image, proglen, false);
 }
-#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
+#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->run_filter)(SKB, FILTER->insns)
 #else
 #include <linux/slab.h>
 static inline void bpf_jit_compile(struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index ad30d62..0f63e67 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -645,7 +645,7 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 {
 	int err;
 
-	fp->bpf_func = sk_run_filter;
+	fp->run_filter = sk_run_filter;
 
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err)
-- 
1.7.10.4

