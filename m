From: akpm@osdl.org
Subject: [patch 5/9] lockdep: fix atm/ipcommon.c deadlock
Date: Thu, 06 Jul 2006 23:58:24 -0700
Message-ID: <200607070658.k676wPcS030374@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, arjan@linux.intel.com,
	davem@davemloft.net, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14786 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751225AbWGGG6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:49 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@linux.intel.com>

> Linux version 2.6.17-git22 (duncan@baldrick) (gcc version 4.0.3 (Ubuntu 4.0.3-1ubuntu5)) #20 PREEMPT Tue Jul 4 10:35:04 CEST 2006
>
> [ 2381.598609] =============================================
> [ 2381.619314] [ INFO: possible recursive locking detected ]
> [ 2381.635497] ---------------------------------------------
> [ 2381.651706] atmarpd/2696 is trying to acquire lock:
> [ 2381.666354]  (&skb_queue_lock_key){-+..}, at: [<c028c540>] skb_migrate+0x24/0x6c
> [ 2381.688848]

ok this is a real potential deadlock in a way, it takes two locks of 2
skbuffs without doing any kind of lock ordering; I think the following
patch should fix it. Just sort the lock taking order by address of the
skb.. it's not pretty but it's the best this can do in a minimally
invasive way.

I still agree with the comment that this code shouldn't live in the atm
layer...

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/atm/ipcommon.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff -puN net/atm/ipcommon.c~lockdep-fix-atm-ipcommonc-deadlock net/atm/ipcommon.c
--- a/net/atm/ipcommon.c~lockdep-fix-atm-ipcommonc-deadlock
+++ a/net/atm/ipcommon.c
@@ -25,8 +25,8 @@
 /*
  * skb_migrate appends the list at "from" to "to", emptying "from" in the
  * process. skb_migrate is atomic with respect to all other skb operations on
- * "from" and "to". Note that it locks both lists at the same time, so beware
- * of potential deadlocks.
+ * "from" and "to". Note that it locks both lists at the same time, so to deal
+ * with the lock ordering, the locks are taken in address order.
  *
  * This function should live in skbuff.c or skbuff.h.
  */
@@ -39,8 +39,13 @@ void skb_migrate(struct sk_buff_head *fr
 	struct sk_buff *skb_to = (struct sk_buff *) to;
 	struct sk_buff *prev;
 
-	spin_lock_irqsave(&from->lock,flags);
-	spin_lock(&to->lock);
+	if (from < to) {
+		spin_lock_irqsave(&from->lock,flags);
+		spin_lock_nested(&to->lock, SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock_irqsave(&to->lock, flags);
+		spin_lock_nested(&from->lock, SINGLE_DEPTH_NESTING);
+	}
 	prev = from->prev;
 	from->next->prev = to->prev;
 	prev->next = skb_to;
_
