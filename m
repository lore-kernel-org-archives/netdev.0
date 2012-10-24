From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] net: allow configuration of the size of page in __netdev_alloc_frag
Date: Wed, 24 Oct 2012 12:42:16 +0100
Message-ID: <1351078936-14159-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	xen-devel@lists.xen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54722 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab2JXLmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 07:42:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 69b08f62e174 "net: use bigger pages in __netdev_alloc_frag"
lead to 70%+ packet loss under Xen when transmitting from physical (as
opposed to virtual) network devices.

This is because under Xen pages which are contiguous in the physical
address space may not be contiguous in the DMA space, in fact it is
very likely that they are not. I think there are other architectures
where this is true, although perhaps non quite so aggressive as to
have this property at a per-order-0-page granularity.

The real underlying bug here most likely lies in the swiotlb not
correctly handling compound pages, and Konrad is investigating this.
However even with the swiotlb issue fixed the current arrangement
seems likely to result in a lot of bounce buffering which seems likely
to more than offset any benefit from the use of larger pages.

Therefore make NETDEV_FRAG_PAGE_MAX_ORDER configurable at runtime and
use this to request order-0 frags under Xen. Also expose this setting
via sysctl.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xen.org
---
 arch/x86/xen/setup.c       |    7 +++++++
 include/linux/skbuff.h     |    2 ++
 net/core/skbuff.c          |    7 ++++---
 net/core/sysctl_net_core.c |    7 +++++++
 4 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/arch/x86/xen/setup.c b/arch/x86/xen/setup.c
index 8971a26..ad14d46 100644
--- a/arch/x86/xen/setup.c
+++ b/arch/x86/xen/setup.c
@@ -11,6 +11,7 @@
 #include <linux/memblock.h>
 #include <linux/cpuidle.h>
 #include <linux/cpufreq.h>
+#include <linux/skbuff.h>
 
 #include <asm/elf.h>
 #include <asm/vdso.h>
@@ -555,6 +556,12 @@ void __init xen_arch_setup(void)
 	       MAX_GUEST_CMDLINE > COMMAND_LINE_SIZE ?
 	       COMMAND_LINE_SIZE : MAX_GUEST_CMDLINE);
 
+	/*
+	 * Xen cannot handle DMA to/from compound pages so avoid
+	 * bounce buffering by not allocating large network frags.
+	 */
+	netdev_frag_page_max_order = 0;
+
 	/* Set up idle, making sure it calls safe_halt() pvop */
 #ifdef CONFIG_X86_32
 	boot_cpu_data.hlt_works_ok = 1;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a2c34e..a3a748f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1719,6 +1719,8 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 		kfree_skb(skb);
 }
 
+extern int netdev_frag_page_max_order;
+
 extern void *netdev_alloc_frag(unsigned int fragsz);
 
 extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6e04b1f..88cbe5f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -348,8 +348,9 @@ struct netdev_alloc_cache {
 };
 static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
 
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
-#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
+int netdev_frag_page_max_order __read_mostly = get_order(32768);
+
+#define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << netdev_frag_page_max_order)
 #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
 
 static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
@@ -363,7 +364,7 @@ static void *__netdev_alloc_frag(unsigned int fragsz, gfp_t gfp_mask)
 	nc = &__get_cpu_var(netdev_alloc_cache);
 	if (unlikely(!nc->frag.page)) {
 refill:
-		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
+		for (order = netdev_frag_page_max_order; ;) {
 			gfp_t gfp = gfp_mask;
 
 			if (order)
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index a7c3684..e5ab6df 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -129,6 +129,13 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "netdev_frag_page_max_order",
+		.data		= &netdev_frag_page_max_order,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_BPF_JIT
 	{
 		.procname	= "bpf_jit_enable",
-- 
1.7.2.5
