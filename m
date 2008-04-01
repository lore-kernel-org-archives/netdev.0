From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of	netif_rx()
Date: Tue, 01 Apr 2008 11:19:06 +0200
Message-ID: <47F1FE0A.9090501@cosmosbay.com>
References: <47BDC848.50607@cosmosbay.com> <20080226.182120.183405235.davem@davemloft.net> <47C92F49.4070100@cosmosbay.com> <20080323.032949.194309002.davem@davemloft.net> <47E6A5FD.6060407@cosmosbay.com> <20080331094823.GA11651@elte.hu> <47F0B66C.6080404@cosmosbay.com> <20080331101237.GA12324@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020607020203040007000907"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:53789 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbYDAJTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 05:19:18 -0400
In-Reply-To: <20080331101237.GA12324@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020607020203040007000907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>
>  =20
>> Problem is to check available space :
>>
>> It depends on stack growing UP or DOWN, and depends on caller running =

>> on process stack, or softirq stack, or even hardirq stack.
>>    =20
>
> ok - i wish such threads were on lkml so that everyone not just the=20
> netdev kabal can read it. It's quite ugly, but if we want to check stac=
k=20
> free space i'd suggest for you to put a stack_can_recurse() call into=20
> arch/x86/kernel/process.c and offer a default __weak implementation in =

> kernel/fork.c that always returns 0.
>
> the rule on x86 should be something like this: on 4K stacks and 64-bit =

> [which have irqstacks] free stack space can go as low as 25%. On 8K=20
> stacks [which doesnt have irqstacks but nests irqs] it should not go=20
> below 50% before falling back to the explicitly queued packet branch.
>
> this way other pieces of kernel code code can choose between on-stack=20
> fast recursion and explicit iterators. Although i'm not sure i like the=
=20
> whole concept to begin with ...
>
>  =20

Hi Ingo

I took the time to prepare a patch to implement =20
arch_stack_can_recurse() as you suggested.

Thank you

[PATCH] x86 : arch_stack_can_recurse() introduction

Some paths in kernel would like to chose between on-stack fast recursion =

and explicit iterators.

One identified spot is in net loopback driver, where we can avoid=20
netif_rx() and its slowdown if
sufficient stack space is available.

We introduce a generic arch_stack_can_recurse() which default to a weak=20
function returning 0.

 On x86 arch, we implement following logic :

   32 bits and 4K stacks (separate irq stacks) : can use up to 25% of sta=
ck
   64 bits, 8K stacks (separate irq stacks)    : can use up to 25% of sta=
ck
   32 bits and 8K stacks (no irq stacks)       : can use up to 50% of sta=
ck

Example of use in drivers/net/loopback.c, function  loopback_xmit()

if (arch_stack_can_recurse())
    netif_receive_skb(skb); /* immediate delivery to stack */
else
    netif_rx(skb); /* defer to softirq handling */

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------020607020203040007000907
Content-Type: text/plain;
 name="can_recurse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_recurse.patch"

diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 0e613e7..6edc1d3 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -43,3 +43,25 @@ void arch_task_cache_init(void)
 				  __alignof__(union thread_xstate),
 				  SLAB_PANIC, NULL);
 }
+
+
+/*
+ * Used to check if we can recurse without risking stack overflow
+ * Rules are :
+ *   32 bits and 4K stacks (separate irq stacks) : can use up to 25% of stack
+ *   64 bits, 8K stacks (separate irq stacks)    : can use up to 25% of stack
+ *   32 bits and 8K stacks (no irq stacks)       : can use up to 50% of stack
+ */
+#if defined(CONFIG_4KSTACKS) || defined(CONFIG_X86_64)
+# define STACK_RECURSE_LIMIT (THREAD_SIZE/4)
+#else
+# define STACK_RECURSE_LIMIT (THREAD_SIZE/2)
+#endif
+
+int arch_stack_can_recurse()
+{
+	unsigned long offset_stack = current_stack_pointer & (THREAD_SIZE - 1);
+	unsigned long avail_stack = offset_stack - sizeof(struct thread_info);
+
+	return avail_stack >= STACK_RECURSE_LIMIT;
+}
diff --git a/include/asm-x86/thread_info_64.h b/include/asm-x86/thread_info_64.h
index f23fefc..9a913c4 100644
--- a/include/asm-x86/thread_info_64.h
+++ b/include/asm-x86/thread_info_64.h
@@ -60,6 +60,9 @@ struct thread_info {
 #define init_thread_info	(init_thread_union.thread_info)
 #define init_stack		(init_thread_union.stack)
 
+/* how to get the current stack pointer from C */
+register unsigned long current_stack_pointer asm("rsp") __used;
+
 static inline struct thread_info *current_thread_info(void)
 {
 	struct thread_info *ti;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ca720f0..445b8da 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1600,6 +1600,8 @@ union thread_union {
 	unsigned long stack[THREAD_SIZE/sizeof(long)];
 };
 
+extern int arch_stack_can_recurse(void);
+
 #ifndef __HAVE_ARCH_KSTACK_END
 static inline int kstack_end(void *addr)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index a19df75..cd5d1e1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -136,6 +136,11 @@ void __attribute__((weak)) arch_task_cache_init(void)
 {
 }
 
+int __attribute__((weak)) arch_stack_can_recurse(void)
+{
+	return 0;
+}
+
 void __init fork_init(unsigned long mempages)
 {
 #ifndef __HAVE_ARCH_TASK_STRUCT_ALLOCATOR

--------------020607020203040007000907--


