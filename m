From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/irda: fix lockdep annotation
Date: Thu, 19 Jan 2017 11:27:36 -0500 (EST)
Message-ID: <20170119.112736.1928027614533032571.davem@davemloft.net>
References: <20170116211052.46525-1-dvyukov@google.com>
        <20170117.151901.998994334183973013.davem@davemloft.net>
        <CACT4Y+Yx3wVAgxJRYKMOYM419NTSc9naSxUVfwCb21kjvAnF6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, samuel@sortiz.org, glider@google.com,
        andreyknvl@google.com, netdev@vger.kernel.org
To: dvyukov@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59268 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753514AbdASQ1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:27:55 -0500
In-Reply-To: <CACT4Y+Yx3wVAgxJRYKMOYM419NTSc9naSxUVfwCb21kjvAnF6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 19 Jan 2017 11:05:36 +0100

> Thanks for looking into it! This particular issue bothers my fuzzers
> considerably. I agree that removing recursion is better.
> So do how we proceed? Will you mail this as a real patch?

Someone needs to test this:

diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
index acbe61c..160dc89 100644
--- a/net/irda/irqueue.c
+++ b/net/irda/irqueue.c
@@ -383,9 +383,6 @@ EXPORT_SYMBOL(hashbin_new);
  *    for deallocating this structure if it's complex. If not the user can
  *    just supply kfree, which should take care of the job.
  */
-#ifdef CONFIG_LOCKDEP
-static int hashbin_lock_depth = 0;
-#endif
 int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 {
 	irda_queue_t* queue;
@@ -396,22 +393,27 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 	IRDA_ASSERT(hashbin->magic == HB_MAGIC, return -1;);
 
 	/* Synchronize */
-	if ( hashbin->hb_type & HB_LOCK ) {
-		spin_lock_irqsave_nested(&hashbin->hb_spinlock, flags,
-					 hashbin_lock_depth++);
-	}
+	if (hashbin->hb_type & HB_LOCK)
+		spin_lock_irqsave(&hashbin->hb_spinlock, flags);
 
 	/*
 	 *  Free the entries in the hashbin, TODO: use hashbin_clear when
 	 *  it has been shown to work
 	 */
 	for (i = 0; i < HASHBIN_SIZE; i ++ ) {
-		queue = dequeue_first((irda_queue_t**) &hashbin->hb_queue[i]);
-		while (queue ) {
-			if (free_func)
-				(*free_func)(queue);
-			queue = dequeue_first(
-				(irda_queue_t**) &hashbin->hb_queue[i]);
+		while (1) {
+			queue = dequeue_first((irda_queue_t**) &hashbin->hb_queue[i]);
+
+			if (!queue)
+				break;
+
+			if (free_func) {
+				if (hashbin->hb_type & HB_LOCK)
+					spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
+				free_func(queue);
+				if (hashbin->hb_type & HB_LOCK)
+					spin_lock_irqsave(&hashbin->hb_spinlock, flags);
+			}
 		}
 	}
 
@@ -420,12 +422,8 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 	hashbin->magic = ~HB_MAGIC;
 
 	/* Release lock */
-	if ( hashbin->hb_type & HB_LOCK) {
+	if (hashbin->hb_type & HB_LOCK)
 		spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
-#ifdef CONFIG_LOCKDEP
-		hashbin_lock_depth--;
-#endif
-	}
 
 	/*
 	 *  Free the hashbin structure
