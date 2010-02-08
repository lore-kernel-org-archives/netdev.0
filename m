From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 37/41] CAPI: Clean up capiminor_*_ack
Date: Mon,  8 Feb 2010 21:12:41 +0100
Message-ID: <6bb0675357ac036a8b769d8bf34005076b287016.1265659937.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:54017 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994Ab0BHUNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:16 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for irqsave acquisition of acklock, bh-safe is sufficient.
Moverover, move kfree out of the lock and do not take acklock at all
in capiminor_del_all_ack as we are the last user of the list here.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 074496f..40b81b4 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -149,7 +149,6 @@ static struct tty_driver *capinc_tty_driver;
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
 
 
@@ -676,7 +671,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 				CAPIMSG_U16(skb->data, CAPIMSG_BASELEN+4+2));
 #endif
 		kfree_skb(skb);
-		(void)capiminor_del_ack(mp, datahandle);
+		capiminor_del_ack(mp, datahandle);
 		tty = tty_port_tty_get(&mp->port);
 		if (tty) {
 			tty_wakeup(tty);
-- 
1.6.0.2

