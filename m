From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] net/irda: fix lockdep annotation
Date: Mon, 16 Jan 2017 11:25:03 +0100
Message-ID: <20170116102503.23800-1-dvyukov@google.com>
Cc: glider@google.com, andreyknvl@google.com,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org
To: davej@redhat.com, samuel@sortiz.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38089 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdAPKZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 05:25:08 -0500
Received: by mail-wm0-f49.google.com with SMTP id r144so168159335wme.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 02:25:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current annotation uses a global variable as recursion counter.
The variable is not atomic nor protected with a mutex, but mutated
by multiple threads. This causes lockdep bug reports episodically:

BUG: looking up invalid subclass: 4294967295
...
_raw_spin_lock_irqsave_nested+0x120/0x180
hashbin_delete+0x4fe/0x750
__irias_delete_object+0xab/0x170
irias_delete_object+0x5f/0xc0
ircomm_tty_detach_cable+0x1d5/0x3f0
...

Make the hashbin_lock_depth variable atomic to prevent bug reports.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Fixes: c7630a4b932af ("[IrDA]: irda lockdep annotation")
---
 net/irda/irqueue.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index acbe61c7e683..b9fd74e6ca99 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -384,21 +384,23 @@ EXPORT_SYMBOL(hashbin_new);
  *    just supply kfree, which should take care of the job.
  */
 #ifdef CONFIG_LOCKDEP
-static int hashbin_lock_depth = 0;
+static atomic_t hashbin_lock_depth = ATOMIC_INIT(0);
 #endif
 int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 {
 	irda_queue_t* queue;
 	unsigned long flags = 0;
-	int i;
+	int i, depth = 0;
 
 	IRDA_ASSERT(hashbin != NULL, return -1;);
 	IRDA_ASSERT(hashbin->magic == HB_MAGIC, return -1;);
 
 	/* Synchronize */
 	if ( hashbin->hb_type & HB_LOCK ) {
-		spin_lock_irqsave_nested(&hashbin->hb_spinlock, flags,
-					 hashbin_lock_depth++);
+#ifdef CONFIG_LOCKDEP
+		depth = atomic_inc_return(&hashbin_lock_depth) - 1;
+#endif
+		spin_lock_irqsave_nested(&hashbin->hb_spinlock, flags, depth);
 	}
 
 	/*
@@ -423,7 +425,7 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 	if ( hashbin->hb_type & HB_LOCK) {
 		spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
 #ifdef CONFIG_LOCKDEP
-		hashbin_lock_depth--;
+		atomic_dec(&hashbin_lock_depth);
 #endif
 	}
 
-- 
2.11.0.483.g087da7b7c-goog
