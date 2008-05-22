From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 3/3] ps3: gelic: updown_lock semaphore to mutex
Date: Thu, 22 May 2008 00:00:03 -0700
Message-ID: <20080522195406.642307415@mvista.com>
References: <20080522195404.061391772@mvista.com>
Cc: netdev@vger.kernel.org, matthew@wil.cx, rusty@rustcorp.com.au,
	mingo@elte.hu, linux-kernel@vger.kernel.org, arjan@infradead.org,
	mokuno@sm.sony.co.jp, geoffrey.levand@am.sony.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:7571 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753028AbYEVUHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 16:07:34 -0400
Content-Disposition: inline; filename=ps3-gelic-net-updown_lock-semaphore-to-mutex.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ps3_gelic_net.c |   10 +++++-----
 drivers/net/ps3_gelic_net.h |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6.25/drivers/net/ps3_gelic_net.c
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_net.c
+++ linux-2.6.25/drivers/net/ps3_gelic_net.c
@@ -110,7 +110,7 @@ static void gelic_card_get_ether_port_st
 void gelic_card_up(struct gelic_card *card)
 {
 	pr_debug("%s: called\n", __func__);
-	down(&card->updown_lock);
+	mutex_lock(&card->updown_lock);
 	if (atomic_inc_return(&card->users) == 1) {
 		pr_debug("%s: real do\n", __func__);
 		/* enable irq */
@@ -120,7 +120,7 @@ void gelic_card_up(struct gelic_card *ca
 
 		napi_enable(&card->napi);
 	}
-	up(&card->updown_lock);
+	mutex_unlock(&card->updown_lock);
 	pr_debug("%s: done\n", __func__);
 }
 
@@ -128,7 +128,7 @@ void gelic_card_down(struct gelic_card *
 {
 	u64 mask;
 	pr_debug("%s: called\n", __func__);
-	down(&card->updown_lock);
+	mutex_lock(&card->updown_lock);
 	if (atomic_dec_if_positive(&card->users) == 0) {
 		pr_debug("%s: real do\n", __func__);
 		napi_disable(&card->napi);
@@ -146,7 +146,7 @@ void gelic_card_down(struct gelic_card *
 		/* stop tx */
 		gelic_card_disable_txdmac(card);
 	}
-	up(&card->updown_lock);
+	mutex_unlock(&card->updown_lock);
 	pr_debug("%s: done\n", __func__);
 }
 
@@ -1534,7 +1534,7 @@ static struct gelic_card *gelic_alloc_ca
 	INIT_WORK(&card->tx_timeout_task, gelic_net_tx_timeout_task);
 	init_waitqueue_head(&card->waitq);
 	atomic_set(&card->tx_timeout_task_counter, 0);
-	init_MUTEX(&card->updown_lock);
+	mutex_init(&card->updown_lock);
 	atomic_set(&card->users, 0);
 
 	return card;
Index: linux-2.6.25/drivers/net/ps3_gelic_net.h
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_net.h
+++ linux-2.6.25/drivers/net/ps3_gelic_net.h
@@ -298,7 +298,7 @@ struct gelic_card {
 	wait_queue_head_t waitq;
 
 	/* only first user should up the card */
-	struct semaphore updown_lock;
+	struct mutex updown_lock;
 	atomic_t users;
 
 	u64 ether_port_status;

-- 
