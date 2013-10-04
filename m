From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next] fix unsafe set_memory_rw from softirq
Date: Fri,  4 Oct 2013 00:14:06 -0700
Message-ID: <1380870846-3357-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:55022 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728Ab3JDHOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 03:14:11 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so3722090pab.39
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 00:14:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on x86 system with net.core.bpf_jit_enable = 1

sudo tcpdump -i eth1 'tcp port 22'

causes the warning:
[   56.766097]  Possible unsafe locking scenario:
[   56.766097]
[   56.780146]        CPU0
[   56.786807]        ----
[   56.793188]   lock(&(&vb->lock)->rlock);
[   56.799593]   <Interrupt>
[   56.805889]     lock(&(&vb->lock)->rlock);
[   56.812266]
[   56.812266]  *** DEADLOCK ***
[   56.812266]
[   56.830670] 1 lock held by ksoftirqd/1/13:
[   56.836838]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8118f44c>] vm_unmap_aliases+0x8c/0x380
[   56.849757]
[   56.849757] stack backtrace:
[   56.862194] CPU: 1 PID: 13 Comm: ksoftirqd/1 Not tainted 3.12.0-rc3+ #45
[   56.868721] Hardware name: System manufacturer System Product Name/P8Z77 WS, BIOS 3007 07/26/2012
[   56.882004]  ffffffff821944c0 ffff88080bbdb8c8 ffffffff8175a145 0000000000000007
[   56.895630]  ffff88080bbd5f40 ffff88080bbdb928 ffffffff81755b14 0000000000000001
[   56.909313]  ffff880800000001 ffff880800000000 ffffffff8101178f 0000000000000001
[   56.923006] Call Trace:
[   56.929532]  [<ffffffff8175a145>] dump_stack+0x55/0x76
[   56.936067]  [<ffffffff81755b14>] print_usage_bug+0x1f7/0x208
[   56.942445]  [<ffffffff8101178f>] ? save_stack_trace+0x2f/0x50
[   56.948932]  [<ffffffff810cc0a0>] ? check_usage_backwards+0x150/0x150
[   56.955470]  [<ffffffff810ccb52>] mark_lock+0x282/0x2c0
[   56.961945]  [<ffffffff810ccfed>] __lock_acquire+0x45d/0x1d50
[   56.968474]  [<ffffffff810cce6e>] ? __lock_acquire+0x2de/0x1d50
[   56.975140]  [<ffffffff81393bf5>] ? cpumask_next_and+0x55/0x90
[   56.981942]  [<ffffffff810cef72>] lock_acquire+0x92/0x1d0
[   56.988745]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
[   56.995619]  [<ffffffff817628f1>] _raw_spin_lock+0x41/0x50
[   57.002493]  [<ffffffff8118f52a>] ? vm_unmap_aliases+0x16a/0x380
[   57.009447]  [<ffffffff8118f52a>] vm_unmap_aliases+0x16a/0x380
[   57.016477]  [<ffffffff8118f44c>] ? vm_unmap_aliases+0x8c/0x380
[   57.023607]  [<ffffffff810436b0>] change_page_attr_set_clr+0xc0/0x460
[   57.030818]  [<ffffffff810cfb8d>] ? trace_hardirqs_on+0xd/0x10
[   57.037896]  [<ffffffff811a8330>] ? kmem_cache_free+0xb0/0x2b0
[   57.044789]  [<ffffffff811b59c3>] ? free_object_rcu+0x93/0xa0
[   57.051720]  [<ffffffff81043d9f>] set_memory_rw+0x2f/0x40
[   57.058727]  [<ffffffff8104e17c>] bpf_jit_free+0x2c/0x40
[   57.065577]  [<ffffffff81642cba>] sk_filter_release_rcu+0x1a/0x30
[   57.072338]  [<ffffffff811108e2>] rcu_process_callbacks+0x202/0x7c0
[   57.078962]  [<ffffffff81057f17>] __do_softirq+0xf7/0x3f0
[   57.085373]  [<ffffffff81058245>] run_ksoftirqd+0x35/0x70

cannot reuse jited filter memory, since it's readonly,
so use original bpf insns memory to hold work_struct

defer kfree of sk_filter until jit completed freeing

tested on x86_64 and i386

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/arm/net/bpf_jit_32.c       |    1 +
 arch/powerpc/net/bpf_jit_comp.c |    1 +
 arch/s390/net/bpf_jit_comp.c    |    4 +++-
 arch/sparc/net/bpf_jit_comp.c   |    1 +
 arch/x86/net/bpf_jit_comp.c     |   18 +++++++++++++-----
 include/linux/filter.h          |   15 +++++++++++----
 include/net/sock.h              |    6 ++----
 net/core/filter.c               |    8 ++++----
 8 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index f50d223..99b44e0 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -930,4 +930,5 @@ void bpf_jit_free(struct sk_filter *fp)
 {
 	if (fp->bpf_func != sk_run_filter)
 		module_free(NULL, fp->bpf_func);
+	kfree(fp);
 }
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index bf56e33..2345bdb 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -691,4 +691,5 @@ void bpf_jit_free(struct sk_filter *fp)
 {
 	if (fp->bpf_func != sk_run_filter)
 		module_free(NULL, fp->bpf_func);
+	kfree(fp);
 }
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 7092392..a5df511 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -881,7 +881,9 @@ void bpf_jit_free(struct sk_filter *fp)
 	struct bpf_binary_header *header = (void *)addr;
 
 	if (fp->bpf_func == sk_run_filter)
-		return;
+		goto free_filter;
 	set_memory_rw(addr, header->pages);
 	module_free(NULL, header);
+free_filter:
+	kfree(fp);
 }
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 9c7be59..218b6b2 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -808,4 +808,5 @@ void bpf_jit_free(struct sk_filter *fp)
 {
 	if (fp->bpf_func != sk_run_filter)
 		module_free(NULL, fp->bpf_func);
+	kfree(fp);
 }
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 79c216a..516593e 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -772,13 +772,21 @@ out:
 	return;
 }
 
+static void bpf_jit_free_deferred(struct work_struct *work)
+{
+	struct sk_filter *fp = container_of(work, struct sk_filter, work);
+	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
+	struct bpf_binary_header *header = (void *)addr;
+
+	set_memory_rw(addr, header->pages);
+	module_free(NULL, header);
+	kfree(fp);
+}
+
 void bpf_jit_free(struct sk_filter *fp)
 {
 	if (fp->bpf_func != sk_run_filter) {
-		unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-		struct bpf_binary_header *header = (void *)addr;
-
-		set_memory_rw(addr, header->pages);
-		module_free(NULL, header);
+		INIT_WORK(&fp->work, bpf_jit_free_deferred);
+		schedule_work(&fp->work);
 	}
 }
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a6ac848..ff4e40c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -6,6 +6,7 @@
 
 #include <linux/atomic.h>
 #include <linux/compat.h>
+#include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
 
 #ifdef CONFIG_COMPAT
@@ -25,15 +26,19 @@ struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
+	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter *filter);
-	struct rcu_head		rcu;
-	struct sock_filter     	insns[0];
+	union {
+		struct sock_filter     	insns[0];
+		struct work_struct	work;
+	};
 };
 
-static inline unsigned int sk_filter_len(const struct sk_filter *fp)
+static inline unsigned int sk_filter_size(unsigned int proglen)
 {
-	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
+	return max(sizeof(struct sk_filter),
+		   offsetof(struct sk_filter, insns[proglen]));
 }
 
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
@@ -67,11 +72,13 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 }
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #else
+#include <linux/slab.h>
 static inline void bpf_jit_compile(struct sk_filter *fp)
 {
 }
 static inline void bpf_jit_free(struct sk_filter *fp)
 {
+	kfree(fp);
 }
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index e3bf213..1105357 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1612,16 +1612,14 @@ static inline void sk_filter_release(struct sk_filter *fp)
 
 static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-	unsigned int size = sk_filter_len(fp);
-
-	atomic_sub(size, &sk->sk_omem_alloc);
+	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 	sk_filter_release(fp);
 }
 
 static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
 	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_len(fp), &sk->sk_omem_alloc);
+	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 }
 
 /*
diff --git a/net/core/filter.c b/net/core/filter.c
index 6438f29..01b7808 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -644,7 +644,6 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
 	bpf_jit_free(fp);
-	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
 
@@ -683,7 +682,7 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 	if (fprog->filter == NULL)
 		return -EINVAL;
 
-	fp = kmalloc(fsize + sizeof(*fp), GFP_KERNEL);
+	fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
 	memcpy(fp->insns, fprog->filter, fsize);
@@ -723,6 +722,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
 	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
+	unsigned int sk_fsize = sk_filter_size(fprog->len);
 	int err;
 
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
@@ -732,11 +732,11 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (fprog->filter == NULL)
 		return -EINVAL;
 
-	fp = sock_kmalloc(sk, fsize+sizeof(*fp), GFP_KERNEL);
+	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
 	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
-		sock_kfree_s(sk, fp, fsize+sizeof(*fp));
+		sock_kfree_s(sk, fp, sk_fsize);
 		return -EFAULT;
 	}
 
-- 
1.7.9.5
