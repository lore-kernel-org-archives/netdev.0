From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] chelsio: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:35 -0700
Message-ID: <20171005005135.GA23444@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/chelsio/cxgb/sge.c | 30 +++++++++++++-----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 0f13a7f7c1d3..30de26ef3da4 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1882,10 +1882,10 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 /*
  * Callback for the Tx buffer reclaim timer.  Runs with softirqs disabled.
  */
-static void sge_tx_reclaim_cb(unsigned long data)
+static void sge_tx_reclaim_cb(struct timer_list *t)
 {
 	int i;
-	struct sge *sge = (struct sge *)data;
+	struct sge *sge = from_timer(sge, t, tx_reclaim_timer);
 
 	for (i = 0; i < SGE_CMDQ_N; ++i) {
 		struct cmdQ *q = &sge->cmdQ[i];
@@ -1978,10 +1978,10 @@ void t1_sge_start(struct sge *sge)
 /*
  * Callback for the T2 ESPI 'stuck packet feature' workaorund
  */
-static void espibug_workaround_t204(unsigned long data)
+static void espibug_workaround_t204(struct timer_list *t)
 {
-	struct adapter *adapter = (struct adapter *)data;
-	struct sge *sge = adapter->sge;
+	struct sge *sge = from_timer(sge, t, espibug_timer);
+	struct adapter *adapter = sge->adapter;
 	unsigned int nports = adapter->params.nports;
 	u32 seop[MAX_NPORTS];
 
@@ -2021,10 +2021,10 @@ static void espibug_workaround_t204(unsigned long data)
 	mod_timer(&sge->espibug_timer, jiffies + sge->espibug_timeout);
 }
 
-static void espibug_workaround(unsigned long data)
+static void espibug_workaround(struct timer_list *t)
 {
-	struct adapter *adapter = (struct adapter *)data;
-	struct sge *sge = adapter->sge;
+	struct sge *sge = from_timer(sge, t, espibug_timer);
+	struct adapter *adapter = sge->adapter;
 
 	if (netif_running(adapter->port[0].dev)) {
 	        struct sk_buff *skb = sge->espibug_skb[0];
@@ -2075,19 +2075,15 @@ struct sge *t1_sge_create(struct adapter *adapter, struct sge_params *p)
 			goto nomem_port;
 	}
 
-	init_timer(&sge->tx_reclaim_timer);
-	sge->tx_reclaim_timer.data = (unsigned long)sge;
-	sge->tx_reclaim_timer.function = sge_tx_reclaim_cb;
+	timer_setup(&sge->tx_reclaim_timer, sge_tx_reclaim_cb, 0);
 
 	if (is_T2(sge->adapter)) {
-		init_timer(&sge->espibug_timer);
+		timer_setup(&sge->espibug_timer,
+			    adapter->params.nports > 1 ? espibug_workaround_t204 : espibug_workaround,
+			    0);
 
-		if (adapter->params.nports > 1) {
+		if (adapter->params.nports > 1)
 			tx_sched_init(sge);
-			sge->espibug_timer.function = espibug_workaround_t204;
-		} else
-			sge->espibug_timer.function = espibug_workaround;
-		sge->espibug_timer.data = (unsigned long)sge->adapter;
 
 		sge->espibug_timeout = 1;
 		/* for T204, every 10ms */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
