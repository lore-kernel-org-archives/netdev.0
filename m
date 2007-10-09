From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH 4/4] ibm_emac: Convert to use napi_struct independent of struct net_device
Date: Tue, 09 Oct 2007 15:48:56 -0700
Message-ID: <adazlyrgazr.fsf_-_@cisco.com>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
	<20071009.135145.95506679.davem@davemloft.net>
	<adahckzhprc.fsf@cisco.com> <adad4vnhpoq.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:8399 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbXJIWs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 18:48:57 -0400
In-Reply-To: <adad4vnhpoq.fsf_-_@cisco.com> (Roland Dreier's message of "Tue, 09 Oct 2007 15:46:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit da3dedd9 ("[NET]: Make NAPI polling independent of struct
net_device objects.") changed the interface to NAPI polling.  Fix up
the ibm_newemac driver so that it works with this new interface.  This
is actually a nice cleanup because ibm_newemac is one of the drivers
that wants to have multiple NAPI structures for a single net_device.

Compile-tested only as I don't have a system that uses the ibm_newemac
driver.  This conversion the conversion for the ibm_emac driver that
was tested on real PowerPC 440SPe hardware.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/ibm_newemac/mal.c |   55 ++++++++++++++--------------------------
 drivers/net/ibm_newemac/mal.h |    2 +-
 2 files changed, 20 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index c4335b7..5885411 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -235,10 +235,10 @@ static irqreturn_t mal_serr(int irq, void *dev_instance)
 
 static inline void mal_schedule_poll(struct mal_instance *mal)
 {
-	if (likely(netif_rx_schedule_prep(&mal->poll_dev))) {
+	if (likely(napi_schedule_prep(&mal->napi))) {
 		MAL_DBG2(mal, "schedule_poll" NL);
 		mal_disable_eob_irq(mal);
-		__netif_rx_schedule(&mal->poll_dev);
+		__napi_schedule(&mal->napi);
 	} else
 		MAL_DBG2(mal, "already in poll" NL);
 }
@@ -318,8 +318,7 @@ void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 		msleep(1);
 
 	/* Synchronize with the MAL NAPI poller. */
-	while (test_bit(__LINK_STATE_RX_SCHED, &mal->poll_dev.state))
-		msleep(1);
+	napi_disable(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
@@ -330,11 +329,11 @@ void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
 	// XXX might want to kick a poll now...
 }
 
-static int mal_poll(struct net_device *ndev, int *budget)
+static int mal_poll(struct napi_struct *napi, int budget)
 {
-	struct mal_instance *mal = netdev_priv(ndev);
+	struct mal_instance *mal = container_of(napi, struct mal_instance, napi);
 	struct list_head *l;
-	int rx_work_limit = min(ndev->quota, *budget), received = 0, done;
+	int received = 0;
 	unsigned long flags;
 
 	MAL_DBG2(mal, "poll(%d) %d ->" NL, *budget,
@@ -358,26 +357,21 @@ static int mal_poll(struct net_device *ndev, int *budget)
 		int n;
 		if (unlikely(test_bit(MAL_COMMAC_POLL_DISABLED, &mc->flags)))
 			continue;
-		n = mc->ops->poll_rx(mc->dev, rx_work_limit);
+		n = mc->ops->poll_rx(mc->dev, budget);
 		if (n) {
 			received += n;
-			rx_work_limit -= n;
-			if (rx_work_limit <= 0) {
-				done = 0;
-				// XXX What if this is the last one ?
-				goto more_work;
-			}
+			budget -= n;
+			if (budget <= 0)
+				goto more_work; // XXX What if this is the last one ?
 		}
 	}
 
 	/* We need to disable IRQs to protect from RXDE IRQ here */
 	spin_lock_irqsave(&mal->lock, flags);
-	__netif_rx_complete(ndev);
+	__napi_complete(napi);
 	mal_enable_eob_irq(mal);
 	spin_unlock_irqrestore(&mal->lock, flags);
 
-	done = 1;
-
 	/* Check for "rotting" packet(s) */
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
@@ -387,12 +381,12 @@ static int mal_poll(struct net_device *ndev, int *budget)
 		if (unlikely(mc->ops->peek_rx(mc->dev) ||
 			     test_bit(MAL_COMMAC_RX_STOPPED, &mc->flags))) {
 			MAL_DBG2(mal, "rotting packet" NL);
-			if (netif_rx_reschedule(ndev, received))
+			if (napi_reschedule(napi))
 				mal_disable_eob_irq(mal);
 			else
 				MAL_DBG2(mal, "already in poll list" NL);
 
-			if (rx_work_limit > 0)
+			if (budget > 0)
 				goto again;
 			else
 				goto more_work;
@@ -401,13 +395,8 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	}
 
  more_work:
-	ndev->quota -= received;
-	*budget -= received;
-
-	MAL_DBG2(mal, "poll() %d <- %d" NL, *budget,
-		 done ? 0 : 1);
-
-	return done ? 0 : 1;
+	MAL_DBG2(mal, "poll() %d <- %d" NL, budget, received);
+	return received;
 }
 
 static void mal_reset(struct mal_instance *mal)
@@ -538,11 +527,8 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	mal->poll_dev.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
-	mal->poll_dev.poll = mal_poll;
-	mal->poll_dev.priv = mal;
-	atomic_set(&mal->poll_dev.refcnt, 1);
+	mal->napi.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
+	mal->napi.poll = mal_poll;
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
 
@@ -653,11 +639,8 @@ static int __devexit mal_remove(struct of_device *ofdev)
 
 	MAL_DBG(mal, "remove" NL);
 
-	/* Syncronize with scheduled polling,
-	   stolen from net/core/dev.c:dev_close()
-	 */
-	clear_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	netif_poll_disable(&mal->poll_dev);
+	/* Synchronize with scheduled polling */
+	napi_disable(&mal->napi);
 
 	if (!list_empty(&mal->list)) {
 		/* This is *very* bad */
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index 57b69dc..cb1a16d 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -197,7 +197,7 @@ struct mal_instance {
 	int			serr_irq;	/* MAL System Error IRQ    */
 
 	struct list_head	poll_list;
-	struct net_device	poll_dev;
+	struct napi_struct	napi;
 
 	struct list_head	list;
 	u32			tx_chan_mask;
