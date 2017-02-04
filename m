From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/9] epic100: use napi_complete_done()
Date: Sat,  4 Feb 2017 10:20:32 -0800
Message-ID: <20170204182038.3752-4-edumazet@google.com>
References: <20170204182038.3752-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34105 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdBDSVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 13:21:18 -0500
Received: by mail-pg0-f52.google.com with SMTP id 14so15911120pgg.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 10:21:18 -0800 (PST)
In-Reply-To: <20170204182038.3752-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use napi_complete_done() instead of __napi_complete() to :

1) Get support of gro_flush_timeout if opt-in
2) Not rearm interrupts for busy-polling users.
3) use standard NAPI API.
4) get rid of baroque code and ease maintenance.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/smsc/epic100.c | 33 +++++++++------------------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 55a95e1d69d68b45ec85a8648e85d24e3673..2c67b7d71b3c2e3d10be019f1d95c9b191a0 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -264,7 +264,6 @@ struct epic_private {
 	spinlock_t lock;				/* Group with Tx control cache line. */
 	spinlock_t napi_lock;
 	struct napi_struct napi;
-	unsigned int reschedule_in_poll;
 	unsigned int cur_tx, dirty_tx;
 
 	unsigned int cur_rx, dirty_rx;
@@ -400,7 +399,6 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&ep->lock);
 	spin_lock_init(&ep->napi_lock);
-	ep->reschedule_in_poll = 0;
 
 	/* Bring the chip out of low-power mode. */
 	ew32(GENCTL, 0x4200);
@@ -1086,13 +1084,12 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 	handled = 1;
 
-	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
+	if (status & EpicNapiEvent) {
 		spin_lock(&ep->napi_lock);
 		if (napi_schedule_prep(&ep->napi)) {
 			epic_napi_irq_off(dev, ep);
 			__napi_schedule(&ep->napi);
-		} else
-			ep->reschedule_in_poll++;
+		}
 		spin_unlock(&ep->napi_lock);
 	}
 	status &= ~EpicNapiEvent;
@@ -1248,37 +1245,25 @@ static int epic_poll(struct napi_struct *napi, int budget)
 {
 	struct epic_private *ep = container_of(napi, struct epic_private, napi);
 	struct net_device *dev = ep->mii.dev;
-	int work_done = 0;
 	void __iomem *ioaddr = ep->ioaddr;
-
-rx_action:
+	int work_done;
 
 	epic_tx(dev, ep);
 
-	work_done += epic_rx(dev, budget);
+	work_done = epic_rx(dev, budget);
 
 	epic_rx_err(dev, ep);
 
 	if (work_done < budget) {
-		unsigned long flags;
-		int more;
-
-		/* A bit baroque but it avoids a (space hungry) spin_unlock */
+		if (napi_complete_done(napi, work_done)) {
+			unsigned long flags;
 
-		spin_lock_irqsave(&ep->napi_lock, flags);
+			spin_lock_irqsave(&ep->napi_lock, flags);
 
-		more = ep->reschedule_in_poll;
-		if (!more) {
-			__napi_complete(napi);
 			ew32(INTSTAT, EpicNapiEvent);
 			epic_napi_irq_on(dev, ep);
-		} else
-			ep->reschedule_in_poll--;
-
-		spin_unlock_irqrestore(&ep->napi_lock, flags);
-
-		if (more)
-			goto rx_action;
+			spin_unlock_irqrestore(&ep->napi_lock, flags);
+		}
 	}
 
 	return work_done;
-- 
2.11.0.483.g087da7b7c-goog
