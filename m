From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: chelsio/cxgb*: Convert timers to use
 timer_setup()
Date: Thu, 26 Oct 2017 22:54:53 -0700
Message-ID: <20171027055453.GA101265@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Raspatur <santosh@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Santosh Raspatur <santosh@chelsio.com>
Cc: Ganesh Goudar <ganeshgr@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c             | 12 ++++++------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c |  7 +++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c             | 12 ++++++------
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           | 12 ++++++------
 4 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index e2d342647b19..e3d28ae75360 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2853,9 +2853,9 @@ void t3_sge_err_intr_handler(struct adapter *adapter)
  *	bother cleaning them up here.
  *
  */
-static void sge_timer_tx(unsigned long data)
+static void sge_timer_tx(struct timer_list *t)
 {
-	struct sge_qset *qs = (struct sge_qset *)data;
+	struct sge_qset *qs = from_timer(qs, t, tx_reclaim_timer);
 	struct port_info *pi = netdev_priv(qs->netdev);
 	struct adapter *adap = pi->adapter;
 	unsigned int tbd[SGE_TXQ_PER_SET] = {0, 0};
@@ -2893,10 +2893,10 @@ static void sge_timer_tx(unsigned long data)
  *	starved.
  *
  */
-static void sge_timer_rx(unsigned long data)
+static void sge_timer_rx(struct timer_list *t)
 {
 	spinlock_t *lock;
-	struct sge_qset *qs = (struct sge_qset *)data;
+	struct sge_qset *qs = from_timer(qs, t, rx_reclaim_timer);
 	struct port_info *pi = netdev_priv(qs->netdev);
 	struct adapter *adap = pi->adapter;
 	u32 status;
@@ -2976,8 +2976,8 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	struct sge_qset *q = &adapter->sge.qs[id];
 
 	init_qset_cntxt(q, id);
-	setup_timer(&q->tx_reclaim_timer, sge_timer_tx, (unsigned long)q);
-	setup_timer(&q->rx_reclaim_timer, sge_timer_rx, (unsigned long)q);
+	timer_setup(&q->tx_reclaim_timer, sge_timer_tx, 0);
+	timer_setup(&q->rx_reclaim_timer, sge_timer_rx, 0);
 
 	q->fl[0].desc = alloc_ring(adapter->pdev, p->fl_size,
 				   sizeof(struct rx_desc),
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index 92a311767381..0c154c663748 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -366,9 +366,9 @@ int cxgb4_tc_flower_destroy(struct net_device *dev,
 	return ret;
 }
 
-static void ch_flower_stats_cb(unsigned long data)
+static void ch_flower_stats_cb(struct timer_list *t)
 {
-	struct adapter *adap = (struct adapter *)data;
+	struct adapter *adap = from_timer(adap, t, flower_stats_timer);
 	struct ch_tc_flower_entry *flower_entry;
 	struct ch_tc_flower_stats *ofld_stats;
 	unsigned int i;
@@ -440,8 +440,7 @@ int cxgb4_tc_flower_stats(struct net_device *dev,
 void cxgb4_init_tc_flower(struct adapter *adap)
 {
 	hash_init(adap->flower_anymatch_tbl);
-	setup_timer(&adap->flower_stats_timer, ch_flower_stats_cb,
-		    (unsigned long)adap);
+	timer_setup(&adap->flower_stats_timer, ch_flower_stats_cb, 0);
 	mod_timer(&adap->flower_stats_timer, jiffies + STATS_CHECK_PERIOD);
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 4ef68f69b58c..486b01fe23bd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2583,11 +2583,11 @@ irq_handler_t t4_intr_handler(struct adapter *adap)
 	return t4_intr_intx;
 }
 
-static void sge_rx_timer_cb(unsigned long data)
+static void sge_rx_timer_cb(struct timer_list *t)
 {
 	unsigned long m;
 	unsigned int i;
-	struct adapter *adap = (struct adapter *)data;
+	struct adapter *adap = from_timer(adap, t, sge.rx_timer);
 	struct sge *s = &adap->sge;
 
 	for (i = 0; i < BITS_TO_LONGS(s->egr_sz); i++)
@@ -2620,11 +2620,11 @@ static void sge_rx_timer_cb(unsigned long data)
 	mod_timer(&s->rx_timer, jiffies + RX_QCHECK_PERIOD);
 }
 
-static void sge_tx_timer_cb(unsigned long data)
+static void sge_tx_timer_cb(struct timer_list *t)
 {
 	unsigned long m;
 	unsigned int i, budget;
-	struct adapter *adap = (struct adapter *)data;
+	struct adapter *adap = from_timer(adap, t, sge.tx_timer);
 	struct sge *s = &adap->sge;
 
 	for (i = 0; i < BITS_TO_LONGS(s->egr_sz); i++)
@@ -3458,8 +3458,8 @@ int t4_sge_init(struct adapter *adap)
 	/* Set up timers used for recuring callbacks to process RX and TX
 	 * administrative tasks.
 	 */
-	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adap);
-	setup_timer(&s->tx_timer, sge_tx_timer_cb, (unsigned long)adap);
+	timer_setup(&s->rx_timer, sge_rx_timer_cb, 0);
+	timer_setup(&s->tx_timer, sge_tx_timer_cb, 0);
 
 	spin_lock_init(&s->intrq_lock);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 05498e7f2840..14d7e673c656 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2058,9 +2058,9 @@ irq_handler_t t4vf_intr_handler(struct adapter *adapter)
  *	when out of memory a queue can become empty.  We schedule NAPI to do
  *	the actual refill.
  */
-static void sge_rx_timer_cb(unsigned long data)
+static void sge_rx_timer_cb(struct timer_list *t)
 {
-	struct adapter *adapter = (struct adapter *)data;
+	struct adapter *adapter = from_timer(adapter, t, sge.rx_timer);
 	struct sge *s = &adapter->sge;
 	unsigned int i;
 
@@ -2117,9 +2117,9 @@ static void sge_rx_timer_cb(unsigned long data)
  *	when no new packets are being submitted.  This is essential for pktgen,
  *	at least.
  */
-static void sge_tx_timer_cb(unsigned long data)
+static void sge_tx_timer_cb(struct timer_list *t)
 {
-	struct adapter *adapter = (struct adapter *)data;
+	struct adapter *adapter = from_timer(adapter, t, sge.tx_timer);
 	struct sge *s = &adapter->sge;
 	unsigned int i, budget;
 
@@ -2676,8 +2676,8 @@ int t4vf_sge_init(struct adapter *adapter)
 	/*
 	 * Set up tasklet timers.
 	 */
-	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adapter);
-	setup_timer(&s->tx_timer, sge_tx_timer_cb, (unsigned long)adapter);
+	timer_setup(&s->rx_timer, sge_rx_timer_cb, 0);
+	timer_setup(&s->tx_timer, sge_tx_timer_cb, 0);
 
 	/*
 	 * Initialize Forwarded Interrupt Queue lock.
-- 
2.7.4


-- 
Kees Cook
Pixel Security
