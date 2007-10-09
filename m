From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] [PATCH 2/4] ibm_emac: Convert to use napi_struct
	independent of struct net_device
Date: Tue, 09 Oct 2007 15:47:37 -0700
Message-ID: <ada8x6bhpme.fsf_-_@cisco.com>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
	<20071009.135145.95506679.davem@davemloft.net>
	<adahckzhprc.fsf@cisco.com> <adad4vnhpoq.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adad4vnhpoq.fsf_-_@cisco.com> (Roland Dreier's message of "Tue,
	09 Oct 2007 15:46:13 -0700")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Commit da3dedd9 ("[NET]: Make NAPI polling independent of struct
net_device objects.") changed the interface to NAPI polling.  Fix up
the ibm_emac driver so that it works with this new interface.  This is
actually a nice cleanup because ibm_emac is one of the drivers that
wants to have multiple NAPI structures for a single net_device.

Tested with the internal MAC of a PowerPC 440SPe SoC with an AMCC
'Yucca' evaluation board.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/ibm_emac/ibm_emac_mal.c |   48 ++++++++++++----------------------
 drivers/net/ibm_emac/ibm_emac_mal.h |    2 +-
 include/linux/netdevice.h           |   10 +++++++
 3 files changed, 28 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
index cabd984..cc3ddc9 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ b/drivers/net/ibm_emac/ibm_emac_mal.c
@@ -207,10 +207,10 @@ static irqreturn_t mal_serr(int irq, void *dev_instance)
 
 static inline void mal_schedule_poll(struct ibm_ocp_mal *mal)
 {
-	if (likely(netif_rx_schedule_prep(&mal->poll_dev))) {
+	if (likely(napi_schedule_prep(&mal->napi))) {
 		MAL_DBG2("%d: schedule_poll" NL, mal->def->index);
 		mal_disable_eob_irq(mal);
-		__netif_rx_schedule(&mal->poll_dev);
+		__napi_schedule(&mal->napi);
 	} else
 		MAL_DBG2("%d: already in poll" NL, mal->def->index);
 }
@@ -273,11 +273,11 @@ static irqreturn_t mal_rxde(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-static int mal_poll(struct net_device *ndev, int *budget)
+static int mal_poll(struct napi_struct *napi, int budget)
 {
-	struct ibm_ocp_mal *mal = ndev->priv;
+	struct ibm_ocp_mal *mal = container_of(napi, struct ibm_ocp_mal, napi);
 	struct list_head *l;
-	int rx_work_limit = min(ndev->quota, *budget), received = 0, done;
+	int received = 0;
 
 	MAL_DBG2("%d: poll(%d) %d ->" NL, mal->def->index, *budget,
 		 rx_work_limit);
@@ -295,38 +295,34 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
 		    list_entry(l, struct mal_commac, poll_list);
-		int n = mc->ops->poll_rx(mc->dev, rx_work_limit);
+		int n = mc->ops->poll_rx(mc->dev, budget);
 		if (n) {
 			received += n;
-			rx_work_limit -= n;
-			if (rx_work_limit <= 0) {
-				done = 0;
+			budget -= n;
+			if (budget <= 0)
 				goto more_work;	// XXX What if this is the last one ?
-			}
 		}
 	}
 
 	/* We need to disable IRQs to protect from RXDE IRQ here */
 	local_irq_disable();
-	__netif_rx_complete(ndev);
+	__napi_complete(napi);
 	mal_enable_eob_irq(mal);
 	local_irq_enable();
 
-	done = 1;
-
 	/* Check for "rotting" packet(s) */
 	list_for_each(l, &mal->poll_list) {
 		struct mal_commac *mc =
 		    list_entry(l, struct mal_commac, poll_list);
 		if (unlikely(mc->ops->peek_rx(mc->dev) || mc->rx_stopped)) {
 			MAL_DBG2("%d: rotting packet" NL, mal->def->index);
-			if (netif_rx_reschedule(ndev, received))
+			if (napi_reschedule(napi))
 				mal_disable_eob_irq(mal);
 			else
 				MAL_DBG2("%d: already in poll list" NL,
 					 mal->def->index);
 
-			if (rx_work_limit > 0)
+			if (budget > 0)
 				goto again;
 			else
 				goto more_work;
@@ -335,12 +331,8 @@ static int mal_poll(struct net_device *ndev, int *budget)
 	}
 
       more_work:
-	ndev->quota -= received;
-	*budget -= received;
-
-	MAL_DBG2("%d: poll() %d <- %d" NL, mal->def->index, *budget,
-		 done ? 0 : 1);
-	return done ? 0 : 1;
+	MAL_DBG2("%d: poll() %d <- %d" NL, mal->def->index, budget, received);
+	return received;
 }
 
 static void mal_reset(struct ibm_ocp_mal *mal)
@@ -425,11 +417,8 @@ static int __init mal_probe(struct ocp_device *ocpdev)
 	mal->def = ocpdev->def;
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	mal->poll_dev.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
-	mal->poll_dev.poll = mal_poll;
-	mal->poll_dev.priv = mal;
-	atomic_set(&mal->poll_dev.refcnt, 1);
+	mal->napi.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
+	mal->napi.poll = mal_poll;
 
 	INIT_LIST_HEAD(&mal->list);
 
@@ -520,11 +509,8 @@ static void __exit mal_remove(struct ocp_device *ocpdev)
 
 	MAL_DBG("%d: remove" NL, mal->def->index);
 
-	/* Syncronize with scheduled polling, 
-	   stolen from net/core/dev.c:dev_close() 
-	 */
-	clear_bit(__LINK_STATE_START, &mal->poll_dev.state);
-	netif_poll_disable(&mal->poll_dev);
+	/* Synchronize with scheduled polling */
+	napi_disable(&mal->napi);
 
 	if (!list_empty(&mal->list)) {
 		/* This is *very* bad */
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index 64bc338..8f54d62 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -195,7 +195,7 @@ struct ibm_ocp_mal {
 	dcr_host_t		dcrhost;
 
 	struct list_head	poll_list;
-	struct net_device	poll_dev;
+	struct napi_struct	napi;
 
 	struct list_head	list;
 	u32			tx_chan_mask;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91cd3f3..4848c7a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -349,6 +349,16 @@ static inline void napi_schedule(struct napi_struct *n)
 		__napi_schedule(n);
 }
 
+/* Try to reschedule poll. Called by dev->poll() after napi_complete().  */
+static inline int napi_reschedule(struct napi_struct *napi)
+{
+	if (napi_schedule_prep(napi)) {
+		__napi_schedule(napi);
+		return 1;
+	}
+	return 0;
+}
+
 /**
  *	napi_complete - NAPI processing complete
  *	@n: napi context
