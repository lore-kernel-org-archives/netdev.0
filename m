From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v4 1/9] net: filter: add jited flag to indicate jit compiled filters
Date: Fri, 28 Mar 2014 18:58:18 +0100
Message-ID: <1396029506-16776-2-git-send-email-dborkman@redhat.com>
References: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbaC1R6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 13:58:36 -0400
In-Reply-To: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a jited flag into sk_filter struct in order to indicate
whether a filter is currently jited or not. The size of sk_filter is
not being expanded as the 32 bit 'len' member allows upper bits to be
reused since a filter can currently only grow as large as BPF_MAXINSNS.

Therefore, there's enough room also for other in future needed flags to
reuse 'len' field if necessary. The jited flag also allows for having
alternative interpreter functions running as currently, we can only
detect jit compiled filters by testing fp->bpf_func to not equal the
address of sk_run_filter().

Joint work with Alexei Starovoitov.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 arch/arm/net/bpf_jit_32.c       | 3 ++-
 arch/powerpc/net/bpf_jit_comp.c | 3 ++-
 arch/s390/net/bpf_jit_comp.c    | 5 ++++-
 arch/sparc/net/bpf_jit_comp.c   | 3 ++-
 arch/x86/net/bpf_jit_comp.c     | 3 ++-
 include/linux/filter.h          | 3 ++-
 net/core/filter.c               | 1 +
 7 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 7ddb9c8..6f879c3 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -925,6 +925,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
 
 	fp->bpf_func = (void *)ctx.target;
+	fp->jited = 1;
 out:
 	kfree(ctx.offsets);
 	return;
@@ -932,7 +933,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
+	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
 	kfree(fp);
 }
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 4afad6c..808ce1c 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -689,6 +689,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
 		fp->bpf_func = (void *)image;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
@@ -697,7 +698,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
+	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
 	kfree(fp);
 }
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 153f8f2..9c36dc3 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -877,6 +877,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	if (jit.start) {
 		set_memory_ro((unsigned long)header, header->pages);
 		fp->bpf_func = (void *) jit.start;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
@@ -887,10 +888,12 @@ void bpf_jit_free(struct sk_filter *fp)
 	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
 	struct bpf_binary_header *header = (void *)addr;
 
-	if (fp->bpf_func == sk_run_filter)
+	if (!fp->jited)
 		goto free_filter;
+
 	set_memory_rw(addr, header->pages);
 	module_free(NULL, header);
+
 free_filter:
 	kfree(fp);
 }
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index d96d2a7..a82c6b2 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -809,6 +809,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
 		fp->bpf_func = (void *)image;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
@@ -817,7 +818,7 @@ out:
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter)
+	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
 	kfree(fp);
 }
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 293c57b..dc01773 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -772,6 +772,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 		bpf_flush_icache(header, image + proglen);
 		set_memory_ro((unsigned long)header, header->pages);
 		fp->bpf_func = (void *)image;
+		fp->jited = 1;
 	}
 out:
 	kfree(addrs);
@@ -791,7 +792,7 @@ static void bpf_jit_free_deferred(struct work_struct *work)
 
 void bpf_jit_free(struct sk_filter *fp)
 {
-	if (fp->bpf_func != sk_run_filter) {
+	if (fp->jited) {
 		INIT_WORK(&fp->work, bpf_jit_free_deferred);
 		schedule_work(&fp->work);
 	} else {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index e568c8e..e65e230 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -25,7 +25,8 @@ struct sock;
 struct sk_filter
 {
 	atomic_t		refcnt;
-	unsigned int         	len;	/* Number of filter blocks */
+	u32			jited:1,	/* Is our filter JIT'ed? */
+				len:31;		/* Number of filter blocks */
 	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter *filter);
diff --git a/net/core/filter.c b/net/core/filter.c
index 65b7596..bb3c764 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -646,6 +646,7 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 	int err;
 
 	fp->bpf_func = sk_run_filter;
+	fp->jited = 0;
 
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err)
-- 
1.7.11.7
