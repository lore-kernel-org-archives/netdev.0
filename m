From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 27/31] CAPI: Clean up capiminor_*_ack
Date: Fri, 8 Jan 2010 13:49:23 +0100
Message-ID: <b625023392854912753fbf8d9a582c3fafa2beb4.1264201408.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:50177 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177Ab0AVX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:27:10 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for irqsave acquisition of acklock, bh-safe is sufficient.
Moverover, move kfree out of the lock and do not take acklock at all
in capiminor_del_all_ack as we are the last user of the list here.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 32a6f04..7a04492 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -149,7 +149,6 @@ static LIST_HEAD(capiminor_list);
 static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
 {
 	struct ackqueue_entry *n;
-	unsigned long flags;
 
 	n = kmalloc(sizeof(*n), GFP_ATOMIC);
 	if (unlikely(!n)) {
@@ -158,44 +157,40 @@ static int capiminor_add_ack(struct capiminor *mp, u16 datahandle)
 	}
 	n->datahandle = datahandle;
 	INIT_LIST_HEAD(&n->list);
-	spin_lock_irqsave(&mp->ackqlock, flags);
+	spin_lock_bh(&mp->ackqlock);
 	list_add_tail(&n->list, &mp->ackqueue);
 	mp->nack++;
-	spin_unlock_irqrestore(&mp->ackqlock, flags);
+	spin_unlock_bh(&mp->ackqlock);
 	return 0;
 }
 
 static int capiminor_del_ack(struct capiminor *mp, u16 datahandle)
 {
 	struct ackqueue_entry *p, *tmp;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mp->ackqlock, flags);
+	spin_lock_bh(&mp->ackqlock);
 	list_for_each_entry_safe(p, tmp, &mp->ackqueue, list) {
  		if (p->datahandle == datahandle) {
 			list_del(&p->list);
-			kfree(p);
 			mp->nack--;
-			spin_unlock_irqrestore(&mp->ackqlock, flags);
+			spin_unlock_bh(&mp->ackqlock);
+			kfree(p);
 			return 0;
 		}
 	}
-	spin_unlock_irqrestore(&mp->ackqlock, flags);
+	spin_unlock_bh(&mp->ackqlock);
 	return -1;
 }
 
 static void capiminor_del_all_ack(struct capiminor *mp)
 {
 	struct ackqueue_entry *p, *tmp;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mp->ackqlock, flags);
 	list_for_each_entry_safe(p, tmp, &mp->ackqueue, list) {
 		list_del(&p->list);
 		kfree(p);
 		mp->nack--;
 	}
-	spin_unlock_irqrestore(&mp->ackqlock, flags);
 }
 
 
@@ -628,7 +623,8 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 				CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+2));
 #endif
 		kfree_skb(skb);
-		(void)capiminor_del_ack(mp, datahandle);
+		capiminor_del_ack(mp, datahandle);
+
 		mutex_lock(&mp->ttylock);
 		if (mp->tty)
 			tty_wakeup(mp->tty);
-- 
1.6.0.2

