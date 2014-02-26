From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 10/16] atm: nicstar: remove interruptible_sleep_on_timeout
Date: Wed, 26 Feb 2014 12:01:50 +0100
Message-ID: <1393412516-3762435-11-git-send-email-arnd@arndb.de>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are trying to finally kill off interruptible_sleep_on_timeout.
the two uses in the nicstar driver can be trivially replaced
with wait_event_interruptible_lock_irq_timeout, which prevents the
wake-up race and is able to check the buffer state with scq->lock
held.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/atm/nicstar.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 9587e95..e1b17d57 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -1739,10 +1739,9 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 		}
 
 		scq->full = 1;
-		spin_unlock_irqrestore(&scq->lock, flags);
-		interruptible_sleep_on_timeout(&scq->scqfull_waitq,
-					       SCQFULL_TIMEOUT);
-		spin_lock_irqsave(&scq->lock, flags);
+		wait_event_interruptible_lock_irq_timeout(scq->scqfull_waitq,
+				scq->tail != scq->next, scq->lock,
+				SCQFULL_TIMEOUT);
 
 		if (scq->full) {
 			spin_unlock_irqrestore(&scq->lock, flags);
@@ -1789,10 +1788,10 @@ static int push_scqe(ns_dev * card, vc_map * vc, scq_info * scq, ns_scqe * tbd,
 			scq->full = 1;
 			if (has_run++)
 				break;
-			spin_unlock_irqrestore(&scq->lock, flags);
-			interruptible_sleep_on_timeout(&scq->scqfull_waitq,
+			wait_event_interruptible_lock_irq_timeout(scq->scqfull_waitq,
+						       scq->tail != scq->next,
+						       scq->lock,
 						       SCQFULL_TIMEOUT);
-			spin_lock_irqsave(&scq->lock, flags);
 		}
 
 		if (!scq->full) {
-- 
1.8.3.2
