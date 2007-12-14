From: akpm@linux-foundation.org
Subject: [patch 10/10] PLIP driver: convert killed_timer_sem to completion
Date: Thu, 13 Dec 2007 16:03:00 -0800
Message-ID: <200712140003.lBE031Fa025539@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias.kaehlcke@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58740 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935046AbXLNAJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:09:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>

PLIP driver: convert the semaphore killed_timer_sem to a completion

Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/plip.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/net/plip.c~plip-driver-convert-killed_timer_sem-to-completion drivers/net/plip.c
--- a/drivers/net/plip.c~plip-driver-convert-killed_timer_sem-to-completion
+++ a/drivers/net/plip.c
@@ -106,6 +106,7 @@ static const char version[] = "NET3 PLIP
 #include <linux/if_plip.h>
 #include <linux/workqueue.h>
 #include <linux/spinlock.h>
+#include <linux/completion.h>
 #include <linux/parport.h>
 #include <linux/bitops.h>
 
@@ -114,7 +115,6 @@ static const char version[] = "NET3 PLIP
 #include <asm/system.h>
 #include <asm/irq.h>
 #include <asm/byteorder.h>
-#include <asm/semaphore.h>
 
 /* Maximum number of devices to support. */
 #define PLIP_MAX  8
@@ -221,7 +221,7 @@ struct net_local {
 	int should_relinquish;
 	spinlock_t lock;
 	atomic_t kill_timer;
-	struct semaphore killed_timer_sem;
+	struct completion killed_timer_cmp;
 };
 
 static inline void enable_parport_interrupts (struct net_device *dev)
@@ -385,7 +385,7 @@ plip_timer_bh(struct work_struct *work)
 		schedule_delayed_work(&nl->timer, 1);
 	}
 	else {
-		up (&nl->killed_timer_sem);
+		complete(&nl->killed_timer_cmp);
 	}
 }
 
@@ -1112,9 +1112,9 @@ plip_close(struct net_device *dev)
 
 	if (dev->irq == -1)
 	{
-		init_MUTEX_LOCKED (&nl->killed_timer_sem);
+		init_completion(&nl->killed_timer_cmp);
 		atomic_set (&nl->kill_timer, 1);
-		down (&nl->killed_timer_sem);
+		wait_for_completion(&nl->killed_timer_cmp);
 	}
 
 #ifdef NOTDEF
_
