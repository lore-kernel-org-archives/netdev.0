From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-2.6.24] cxgb3 - napi update
Date: Sun, 09 Sep 2007 00:09:17 -0700
Message-ID: <20070909070917.27016.76853.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28470 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbXIIHKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 03:10:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Embed napi_struct directly into sge_qset.
Use napi_schedule/napi_complete.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |   20 +++-------
 drivers/net/cxgb3/cxgb3_main.c |   57 ++++++++++--------------------
 drivers/net/cxgb3/sge.c        |   77 +++++++++++++++-------------------------
 3 files changed, 55 insertions(+), 99 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index e723e7b..0442617 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -49,11 +49,13 @@
 typedef irqreturn_t(*intr_handler_t) (int, void *);
 
 struct vlan_group;
-
 struct adapter;
+struct sge_qset;
+
 struct port_info {
 	struct adapter *adapter;
 	struct vlan_group *vlan_grp;
+	struct sge_qset *qs;
 	const struct port_type_info *port_type;
 	u8 port_id;
 	u8 rx_csum_offload;
@@ -172,12 +174,12 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_MAX		/* must be last */
 };
 
-struct adapter_napi;
 struct sge_qset {		/* an SGE queue set */
+	struct adapter *adap;
+	struct napi_struct napi;
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
-	struct adapter_napi *anapi;
 	struct net_device *netdev;
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
@@ -189,13 +191,6 @@ struct sge {
 	spinlock_t reg_lock;	/* guards non-atomic SGE registers (eg context) */
 };
 
-struct adapter_napi {
-	struct napi_struct napi;
-	struct adapter *adapter;
-	int port;
-	int qset;
-};
-
 struct adapter {
 	struct t3cdev tdev;
 	struct list_head adapter_list;
@@ -230,8 +225,6 @@ struct adapter {
 	struct delayed_work adap_check_task;
 	struct work_struct ext_intr_handler_task;
 
-	struct adapter_napi napi[SGE_QSETS];
-
 	struct dentry *debugfs_root;
 
 	struct mutex mdio_lock;
@@ -283,8 +276,7 @@ int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
 void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p);
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct adapter_napi *anapi,
-		      struct net_device *dev);
+		      int ntxq, struct net_device *dev);
 int t3_get_desc(const struct sge_qset *qs, unsigned int qnum, unsigned int idx,
 		unsigned char *data);
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index f5ce06d..5db7d4e 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -339,24 +339,17 @@ static void setup_rss(struct adapter *adap)
 		      V_RRCPLCPUSIZE(6), cpus, rspq_map);
 }
 
-static int init_napi(struct adapter *adap)
+static void init_napi(struct adapter *adap)
 {
-	int i, j, napi_idx = 0;
+	int i;
 
-	for_each_port(adap, i) {
-		struct net_device *dev = adap->port[i];
-		const struct port_info *pi = netdev_priv(dev);
+	for (i = 0; i < SGE_QSETS; i++) {
+		struct sge_qset *qs = &adap->sge.qs[i];
 
-		for (j = 0; j < pi->nqsets - 1; j++) {
-			netif_napi_add(dev, &adap->napi[napi_idx].napi,
-				       NULL, 64);
-			adap->napi[napi_idx].adapter = adap;
-			adap->napi[napi_idx].port = i;
-			adap->napi[napi_idx].qset = j;
-			napi_idx++;
-		}
+		if (qs->adap)
+			netif_napi_add(qs->netdev, &qs->napi, qs->napi.poll,
+				       64);
 	}
-	return 0;
 }
 
 /*
@@ -368,20 +361,17 @@ static void quiesce_rx(struct adapter *adap)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(adap->napi); i++) {
-		struct adapter_napi *anapi = &adap->napi[i];
-		napi_disable(&anapi->napi);
-	}
+	for (i = 0; i < SGE_QSETS; i++)
+		if (adap->sge.qs[i].adap)
+			napi_disable(&adap->sge.qs[i].napi);
 }
 
 static void enable_all_napi(struct adapter *adap)
 {
 	int i;
-
-	for (i = 0; i < ARRAY_SIZE(adap->napi); i++) {
-		struct adapter_napi *anapi = &adap->napi[i];
-		napi_enable(&anapi->napi);
-	}
+	for (i = 0; i < SGE_QSETS; i++)
+		if (adap->sge.qs[i].adap)
+			napi_enable(&adap->sge.qs[i].napi);
 }
 
 /**
@@ -394,7 +384,7 @@ static void enable_all_napi(struct adapter *adap)
  */
 static int setup_sge_qsets(struct adapter *adap)
 {
-	int i, j, err, irq_idx = 0, qset_idx = 0, anapi_idx = 0;
+	int i, j, err, irq_idx = 0, qset_idx = 0;
 	unsigned int ntxq = SGE_TXQ_PER_SET;
 
 	if (adap->params.rev > 0 && !(adap->flags & USING_MSI))
@@ -402,18 +392,14 @@ static int setup_sge_qsets(struct adapter *adap)
 
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
-		const struct port_info *pi = netdev_priv(dev);
+		struct port_info *pi = netdev_priv(dev);
 
+		pi->qs = &adap->sge.qs[pi->first_qset];
 		for (j = 0; j < pi->nqsets; ++j, ++qset_idx) {
-			struct adapter_napi *anapi;
-
-			anapi = &adap->napi[anapi_idx++];
-
 			err = t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
 							     irq_idx,
-				&adap->params.sge.qset[qset_idx], ntxq,
-				anapi, dev);
+				&adap->params.sge.qset[qset_idx], ntxq, dev);
 			if (err) {
 				t3_free_sge_resources(adap);
 				return err;
@@ -824,21 +810,18 @@ static int cxgb_up(struct adapter *adap)
 				goto out;
 		}
 
-		err = init_napi(adap);
-		if (err)
-			goto out;
-
 		err = t3_init_hw(adap, 0);
 		if (err)
 			goto out;
 
 		t3_write_reg(adap, A_ULPRX_TDDP_PSZ, V_HPZ0(PAGE_SHIFT - 12));
-		
+
 		err = setup_sge_qsets(adap);
 		if (err)
 			goto out;
 
 		setup_rss(adap);
+		init_napi(adap);
 		adap->flags |= FULL_INIT_DONE;
 	}
 
@@ -865,6 +848,7 @@ static int cxgb_up(struct adapter *adap)
 				      adap->name, adap)))
 		goto irq_err;
 
+	enable_all_napi(adap);
 	t3_sge_start(adap);
 	t3_intr_enable(adap);
 
@@ -991,7 +975,6 @@ static int cxgb_open(struct net_device *dev)
 	int other_ports = adapter->open_device_map & PORT_MASK;
 	int err;
 
-	enable_all_napi(adapter);
 	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0) {
 		quiesce_rx(adapter);
 		return err;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 723b74f..069c1ac 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1071,7 +1071,7 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int ndesc, pidx, credits, gen, compl;
 	const struct port_info *pi = netdev_priv(dev);
 	struct adapter *adap = pi->adapter;
-	struct sge_qset *qs = &adap->sge.qs[pi->first_qset];
+	struct sge_qset *qs = pi->qs;
 	struct sge_txq *q = &qs->txq[TXQ_ETH];
 
 	/*
@@ -1323,13 +1323,12 @@ static void restart_ctrlq(unsigned long data)
 	struct sk_buff *skb;
 	struct sge_qset *qs = (struct sge_qset *)data;
 	struct sge_txq *q = &qs->txq[TXQ_CTRL];
-	const struct port_info *pi = netdev_priv(qs->netdev);
-	struct adapter *adap = pi->adapter;
 
 	spin_lock(&q->lock);
       again:reclaim_completed_tx_imm(q);
 
-	while (q->in_use < q->size && (skb = __skb_dequeue(&q->sendq)) != NULL) {
+	while (q->in_use < q->size &&
+	       (skb = __skb_dequeue(&q->sendq)) != NULL) {
 
 		write_imm(&q->desc[q->pidx], skb, skb->len, q->gen);
 
@@ -1351,7 +1350,7 @@ static void restart_ctrlq(unsigned long data)
 	}
 
 	spin_unlock(&q->lock);
-	t3_write_reg(adap, A_SG_KDOORBELL,
+	t3_write_reg(qs->adap, A_SG_KDOORBELL,
 		     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
 }
 
@@ -1635,8 +1634,7 @@ static inline void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
 	else {
 		struct sge_qset *qs = rspq_to_qset(q);
 
-		if (napi_schedule_prep(&qs->anapi->napi))
-			__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
+		napi_schedule(&qs->napi);
 		q->rx_head = skb;
 	}
 	q->rx_tail = skb;
@@ -1674,11 +1672,9 @@ static inline void deliver_partial_bundle(struct t3cdev *tdev,
  */
 static int ofld_poll(struct napi_struct *napi, int budget)
 {
-	struct adapter_napi *anapi = container_of(napi, struct adapter_napi, napi);
-	struct adapter *adapter = anapi->adapter;
-	struct net_device *dev = adapter->port[anapi->port];
-	struct sge_qset *qs = &adapter->sge.qs[anapi->qset];
+	struct sge_qset *qs = container_of(napi, struct sge_qset, napi);
 	struct sge_rspq *q = &qs->rspq;
+	struct adapter *adapter = qs->adap;
 	int work_done = 0;
 
 	while (work_done < budget) {
@@ -1688,7 +1684,7 @@ static int ofld_poll(struct napi_struct *napi, int budget)
 		spin_lock_irq(&q->lock);
 		head = q->rx_head;
 		if (!head) {
-			__netif_rx_complete(dev, napi);
+			napi_complete(napi);
 			spin_unlock_irq(&q->lock);
 			return work_done;
 		}
@@ -2071,15 +2067,12 @@ static inline int is_pure_response(const struct rsp_desc *r)
  */
 static int napi_rx_handler(struct napi_struct *napi, int budget)
 {
-	struct adapter_napi *anapi = container_of(napi, struct adapter_napi, napi);
-	struct adapter *adap = anapi->adapter;
-	struct net_device *dev = adap->port[anapi->port];
-	struct sge_qset *qs = &adap->sge.qs[anapi->qset];
-	int effective_budget = budget;
-	int work_done = process_responses(adap, qs, effective_budget);
+	struct sge_qset *qs = container_of(napi, struct sge_qset, napi);
+	struct adapter *adap = qs->adap;
+	int work_done = process_responses(adap, qs, budget);
 
-	if (likely(work_done < effective_budget)) {
-		netif_rx_complete(dev, napi);
+	if (likely(work_done < budget)) {
+		napi_complete(napi);
 
 		/*
 		 * Because we don't atomically flush the following
@@ -2190,8 +2183,7 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 			     V_NEWTIMER(q->holdoff_tmr) | V_NEWINDEX(q->cidx));
 		return 0;
 	}
-	if (likely(napi_schedule_prep(&qs->anapi->napi)))
-		__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
+	napi_schedule(&qs->napi);
 	return 1;
 }
 
@@ -2202,7 +2194,7 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->anapi->adapter;
+	struct adapter *adap = qs->adap;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
@@ -2221,12 +2213,11 @@ irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->anapi->adapter;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
 
-	if (handle_responses(adap, q) < 0)
+	if (handle_responses(qs->adap, q) < 0)
 		q->unhandled_irqs++;
 	spin_unlock(&q->lock);
 	return IRQ_HANDLED;
@@ -2273,10 +2264,9 @@ static int rspq_check_napi(struct sge_qset *qs)
 {
 	struct sge_rspq *q = &qs->rspq;
 
-	if (!napi_is_scheduled(&qs->anapi->napi) &&
+	if (!napi_is_scheduled(&qs->napi) &&
 	    is_new_response(&q->desc[q->cidx], q)) {
-		if (likely(napi_schedule_prep(&qs->anapi->napi)))
-			__netif_rx_schedule(qs->netdev, &qs->anapi->napi);
+		napi_schedule(&qs->napi);
 		return 1;
 	}
 	return 0;
@@ -2402,7 +2392,6 @@ static irqreturn_t t3b_intr(int irq, void *cookie)
 static irqreturn_t t3b_intr_napi(int irq, void *cookie)
 {
 	u32 map;
-	struct net_device *dev;
 	struct adapter *adap = cookie;
 	struct sge_qset *qs0 = &adap->sge.qs[0];
 	struct sge_rspq *q0 = &qs0->rspq;
@@ -2418,19 +2407,11 @@ static irqreturn_t t3b_intr_napi(int irq, void *cookie)
 	if (unlikely(map & F_ERRINTR))
 		t3_slow_intr_handler(adap);
 
-	if (likely(map & 1)) {
-		dev = qs0->netdev;
-
-		if (likely(napi_schedule_prep(&qs0->anapi->napi)))
-			__netif_rx_schedule(dev, &qs0->anapi->napi);
-	}
-	if (map & 2) {
-		struct sge_qset *qs1 = &adap->sge.qs[1];
+	if (likely(map & 1))
+		napi_schedule(&qs0->napi);
 
-		dev = qs1->netdev;
-		if (likely(napi_schedule_prep(&qs1->anapi->napi)))
-			__netif_rx_schedule(dev, &qs1->anapi->napi);
-	}
+	if (map & 2)
+		napi_schedule(&adap->sge.qs[1].napi);
 
 	spin_unlock(&q0->lock);
 	return IRQ_HANDLED;
@@ -2509,7 +2490,7 @@ static void sge_timer_cb(unsigned long data)
 {
 	spinlock_t *lock;
 	struct sge_qset *qs = (struct sge_qset *)data;
-	struct adapter *adap = qs->anapi->adapter;
+	struct adapter *adap = qs->adap;
 
 	if (spin_trylock(&qs->txq[TXQ_ETH].lock)) {
 		reclaim_completed_tx(adap, &qs->txq[TXQ_ETH]);
@@ -2520,9 +2501,9 @@ static void sge_timer_cb(unsigned long data)
 		spin_unlock(&qs->txq[TXQ_OFLD].lock);
 	}
 	lock = (adap->flags & USING_MSIX) ? &qs->rspq.lock :
-	    &adap->sge.qs[0].rspq.lock;
+					    &adap->sge.qs[0].rspq.lock;
 	if (spin_trylock_irq(lock)) {
-		if (!napi_is_scheduled(&qs->anapi->napi)) {
+		if (!napi_is_scheduled(&qs->napi)) {
 			u32 status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
 
 			if (qs->fl[0].credits < qs->fl[0].size)
@@ -2558,7 +2539,7 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
 {
 	qs->rspq.holdoff_tmr = max(p->coalesce_usecs * 10, 1U);/* can't be 0 */
 	qs->rspq.polling = p->polling;
-	qs->anapi->napi.poll = p->polling ? napi_rx_handler : ofld_poll;
+	qs->napi.poll = p->polling ? napi_rx_handler : ofld_poll;
 }
 
 /**
@@ -2578,8 +2559,7 @@ void t3_update_qset_coalesce(struct sge_qset *qs, const struct qset_params *p)
  */
 int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
-		      int ntxq, struct adapter_napi *anapi,
-		      struct net_device *dev)
+		      int ntxq, struct net_device *dev)
 {
 	int i, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
@@ -2700,7 +2680,8 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	}
 
 	spin_unlock(&adapter->sge.reg_lock);
-	q->anapi = anapi;
+
+	q->adap = adapter;
 	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
 
