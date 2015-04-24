From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix crash in build_skb()
Date: Fri, 24 Apr 2015 16:05:01 -0700
Message-ID: <1429916701.22254.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <553AB56F.4000600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35218 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946298AbbDXXFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 19:05:04 -0400
Received: by iejt8 with SMTP id t8so94055139iej.2
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 16:05:03 -0700 (PDT)
In-Reply-To: <553AB56F.4000600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When I added pfmemalloc support in build_skb(), I forgot netlink
was using build_skb() with a vmalloc() area.

In this patch I introduce __build_skb() for netlink use,
and build_skb() is a wrapper handling both skb->head_frag and
skb->pfmemalloc

This means netlink no longer has to hack skb->head_frag

[ 1567.700067] kernel BUG at arch/x86/mm/physaddr.c:26!
[ 1567.700067] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[ 1567.700067] Dumping ftrace buffer:
[ 1567.700067]    (ftrace buffer empty)
[ 1567.700067] Modules linked in:
[ 1567.700067] CPU: 9 PID: 16186 Comm: trinity-c182 Not tainted 4.0.0-next-20150424-sasha-00037-g4796e21 #2167
[ 1567.700067] task: ffff880127efb000 ti: ffff880246770000 task.ti: ffff880246770000
[ 1567.700067] RIP: __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 3))
[ 1567.700067] RSP: 0018:ffff8802467779d8  EFLAGS: 00010202
[ 1567.700067] RAX: 000041000ed8e000 RBX: ffffc9008ed8e000 RCX: 000000000000002c
[ 1567.700067] RDX: 0000000000000004 RSI: 0000000000000000 RDI: ffffffffb3fd6049
[ 1567.700067] RBP: ffff8802467779f8 R08: 0000000000000019 R09: ffff8801d0168000
[ 1567.700067] R10: ffff8801d01680c7 R11: ffffed003a02d019 R12: ffffc9000ed8e000
[ 1567.700067] R13: 0000000000000f40 R14: 0000000000001180 R15: ffffc9000ed8e000
[ 1567.700067] FS:  00007f2a7da3f700(0000) GS:ffff8801d1000000(0000) knlGS:0000000000000000
[ 1567.700067] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1567.700067] CR2: 0000000000738308 CR3: 000000022e329000 CR4: 00000000000007e0
[ 1567.700067] Stack:
[ 1567.700067]  ffffc9000ed8e000 ffff8801d0168000 ffffc9000ed8e000 ffff8801d0168000
[ 1567.700067]  ffff880246777a28 ffffffffad7c0a21 0000000000001080 ffff880246777c08
[ 1567.700067]  ffff88060d302e68 ffff880246777b58 ffff880246777b88 ffffffffad9a6821
[ 1567.700067] Call Trace:
[ 1567.700067] build_skb (include/linux/mm.h:508 net/core/skbuff.c:316)
[ 1567.700067] netlink_sendmsg (net/netlink/af_netlink.c:1633 net/netlink/af_netlink.c:2329)
[ 1567.774369] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 1567.774369] ? netlink_unicast (net/netlink/af_netlink.c:2273)
[ 1567.774369] ? netlink_unicast (net/netlink/af_netlink.c:2273)
[ 1567.774369] sock_sendmsg (net/socket.c:614 net/socket.c:623)
[ 1567.774369] sock_write_iter (net/socket.c:823)
[ 1567.774369] ? sock_sendmsg (net/socket.c:806)
[ 1567.774369] __vfs_write (fs/read_write.c:479 fs/read_write.c:491)
[ 1567.774369] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 1567.774369] ? default_llseek (fs/read_write.c:487)
[ 1567.774369] ? vtime_account_user (kernel/sched/cputime.c:701)
[ 1567.774369] ? rw_verify_area (fs/read_write.c:406 (discriminator 4))
[ 1567.774369] vfs_write (fs/read_write.c:539)
[ 1567.774369] SyS_write (fs/read_write.c:586 fs/read_write.c:577)
[ 1567.774369] ? SyS_read (fs/read_write.c:577)
[ 1567.774369] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1567.774369] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[ 1567.774369] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 1567.774369] system_call_fastpath (arch/x86/kernel/entry_64.S:261)

Fixes: 79930f5892e ("net: do not deplete pfmemalloc reserve")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/skbuff.h   |    1 +
 net/core/skbuff.c        |   31 ++++++++++++++++++++++---------
 net/netlink/af_netlink.c |    6 ++----
 3 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 06793b598f44..66e374d62f64 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -773,6 +773,7 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 
 struct sk_buff *__alloc_skb(unsigned int size, gfp_t priority, int flags,
 			    int node);
+struct sk_buff *__build_skb(void *data, unsigned int frag_size);
 struct sk_buff *build_skb(void *data, unsigned int frag_size);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 456ead534e10..3cfff2a3d651 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -280,13 +280,14 @@ nodata:
 EXPORT_SYMBOL(__alloc_skb);
 
 /**
- * build_skb - build a network buffer
+ * __build_skb - build a network buffer
  * @data: data buffer provided by caller
- * @frag_size: size of fragment, or 0 if head was kmalloced
+ * @frag_size: size of data, or 0 if head was kmalloced
  *
  * Allocate a new &sk_buff. Caller provides space holding head and
  * skb_shared_info. @data must have been allocated by kmalloc() only if
- * @frag_size is 0, otherwise data should come from the page allocator.
+ * @frag_size is 0, otherwise data should come from the page allocator
+ *  or vmalloc()
  * The return is the new skb buffer.
  * On a failure the return is %NULL, and @data is not freed.
  * Notes :
@@ -297,7 +298,7 @@ EXPORT_SYMBOL(__alloc_skb);
  *  before giving packet to stack.
  *  RX rings only contains data buffers, not full skbs.
  */
-struct sk_buff *build_skb(void *data, unsigned int frag_size)
+struct sk_buff *__build_skb(void *data, unsigned int frag_size)
 {
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
@@ -311,11 +312,6 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
-	if (frag_size) {
-		skb->head_frag = 1;
-		if (virt_to_head_page(data)->pfmemalloc)
-			skb->pfmemalloc = 1;
-	}
 	atomic_set(&skb->users, 1);
 	skb->head = data;
 	skb->data = data;
@@ -332,6 +328,23 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 
 	return skb;
 }
+
+/* build_skb() is wrapper over __build_skb(), that specifically
+ * takes care of skb->head and skb->pfmemalloc
+ * This means that if @frag_size is not zero, then @data must be backed
+ * by a page fragment, not kmalloc() or vmalloc()
+ */
+struct sk_buff *build_skb(void *data, unsigned int frag_size)
+{
+	struct sk_buff *skb = __build_skb(data, frag_size);
+
+	if (skb && frag_size) {
+		skb->head_frag = 1;
+		if (virt_to_head_page(data)->pfmemalloc)
+			skb->pfmemalloc = 1;
+	}
+	return skb;
+}
 EXPORT_SYMBOL(build_skb);
 
 struct netdev_alloc_cache {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 19909d0786a2..ec4adbdcb9b4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1629,13 +1629,11 @@ static struct sk_buff *netlink_alloc_large_skb(unsigned int size,
 	if (data == NULL)
 		return NULL;
 
-	skb = build_skb(data, size);
+	skb = __build_skb(data, size);
 	if (skb == NULL)
 		vfree(data);
-	else {
-		skb->head_frag = 0;
+	else
 		skb->destructor = netlink_skb_destructor;
-	}
 
 	return skb;
 }
