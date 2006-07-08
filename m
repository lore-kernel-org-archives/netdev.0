From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/2][ATM]: fix possible recursive locking in skb_migrate()
Date: Fri, 07 Jul 2006 20:50:23 -0400
Message-ID: <200607080050.k680oN6l022174@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.12.161]:43219 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S932468AbWGHAud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 20:50:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: fix possible recursive locking in skb_migrate()

ok this is a real potential deadlock in a way, it takes two locks of 2
skbuffs without doing any kind of lock ordering; I think the following
patch should fix it. Just sort the lock taking order by address of the
skb.. it's not pretty but it's the best this can do in a minimally
invasive way.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit c895a2f42057801ca096f5155e85bc2b2f381250
tree ee64100fdd0302fe5c12ce6c153eea8b94010f2b
parent 8bbf3465e23c41b92931e2d2172c184ccd1d2510
author chas williams <chas@relax.cmf.nrl.navy.mil> Fri, 07 Jul 2006 18:11:30 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Fri, 07 Jul 2006 18:11:30 -0400

 net/atm/ipcommon.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/atm/ipcommon.c b/net/atm/ipcommon.c
index 4b1faca..1d3de42 100644
--- a/net/atm/ipcommon.c
+++ b/net/atm/ipcommon.c
@@ -25,22 +25,27 @@ #endif
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
 
 
-void skb_migrate(struct sk_buff_head *from,struct sk_buff_head *to)
+void skb_migrate(struct sk_buff_head *from, struct sk_buff_head *to)
 {
 	unsigned long flags;
 	struct sk_buff *skb_from = (struct sk_buff *) from;
 	struct sk_buff *skb_to = (struct sk_buff *) to;
 	struct sk_buff *prev;
 
-	spin_lock_irqsave(&from->lock,flags);
-	spin_lock(&to->lock);
+	if ((unsigned long) from < (unsigned long) to) {
+		spin_lock_irqsave(&from->lock, flags);
+		spin_lock_nested(&to->lock, SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock_irqsave(&to->lock, flags);
+		spin_lock_nested(&from->lock, SINGLE_DEPTH_NESTING);
+	}
 	prev = from->prev;
 	from->next->prev = to->prev;
 	prev->next = skb_to;
@@ -51,7 +56,7 @@ void skb_migrate(struct sk_buff_head *fr
 	from->prev = skb_from;
 	from->next = skb_from;
 	from->qlen = 0;
-	spin_unlock_irqrestore(&from->lock,flags);
+	spin_unlock_irqrestore(&from->lock, flags);
 }
 
 
