From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: add support for per queue tx scheduling
Date: Mon, 22 Aug 2016 16:29:07 +0530
Message-ID: <5179d625c8572e51fd81ddaa86c101c054e03f6a.1471848005.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:60377 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752247AbcHVLB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:01:56 -0400
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bind/unbind specified tx queues to/from scheduling
classes.  If a queue is already bound to a scheduling class, it is
unbound first and then bound to a new specified class.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |   8 +
 drivers/net/ethernet/chelsio/cxgb4/sched.c | 321 +++++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sched.h |  18 ++
 3 files changed, 347 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 17a6dd0..eb30612 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -881,6 +881,14 @@ struct ch_sched_params {
 	} u;
 };
 
+/* Support for "sched_queue" command to allow one or more NIC TX Queues
+ * to be bound to a TX Scheduling Class.
+ */
+struct ch_sched_queue {
+	s8   queue;    /* queue index */
+	s8   class;    /* class index */
+};
+
 /* Defined bit width of user definable filter tuples
  */
 #define ETHTYPE_BITWIDTH 16
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
index 6158daf..539de76 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -67,6 +67,312 @@ static int t4_sched_class_fw_cmd(struct port_info *pi,
 	return err;
 }
 
+/* Spinlock must be held by caller */
+static int t4_sched_bind_unbind_op(struct port_info *pi, void *arg,
+				   enum sched_bind_type type, bool bind)
+{
+	struct adapter *adap = pi->adapter;
+	u32 fw_mnem, fw_class, fw_param;
+	unsigned int pf = adap->pf;
+	unsigned int vf = 0;
+	int err = 0;
+
+	switch (type) {
+	case SCHED_QUEUE: {
+		struct sched_queue_entry *qe;
+
+		qe = (struct sched_queue_entry *)arg;
+
+		/* Create a template for the FW_PARAMS_CMD mnemonic and
+		 * value (TX Scheduling Class in this case).
+		 */
+		fw_mnem = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
+			   FW_PARAMS_PARAM_X_V(
+				   FW_PARAMS_PARAM_DMAQ_EQ_SCHEDCLASS_ETH));
+		fw_class = bind ? qe->param.class : FW_SCHED_CLS_NONE;
+		fw_param = (fw_mnem | FW_PARAMS_PARAM_YZ_V(qe->cntxt_id));
+
+		pf = adap->pf;
+		vf = 0;
+		break;
+	}
+	default:
+		err = -ENOTSUPP;
+		goto out;
+	}
+
+	err = t4_set_params(adap, adap->mbox, pf, vf, 1, &fw_param, &fw_class);
+
+out:
+	return err;
+}
+
+static struct sched_class *t4_sched_queue_lookup(struct port_info *pi,
+						 const unsigned int qid,
+						 int *index)
+{
+	struct sched_table *s = pi->sched_tbl;
+	struct sched_class *e, *end;
+	struct sched_class *found = NULL;
+	int i;
+
+	/* Look for a class with matching bound queue parameters */
+	end = &s->tab[s->sched_size];
+	for (e = &s->tab[0]; e != end; ++e) {
+		struct sched_queue_entry *qe;
+
+		i = 0;
+		if (e->state == SCHED_STATE_UNUSED)
+			continue;
+
+		list_for_each_entry(qe, &e->queue_list, list) {
+			if (qe->cntxt_id == qid) {
+				found = e;
+				if (index)
+					*index = i;
+				break;
+			}
+			i++;
+		}
+
+		if (found)
+			break;
+	}
+
+	return found;
+}
+
+static int t4_sched_queue_unbind(struct port_info *pi, struct ch_sched_queue *p)
+{
+	struct adapter *adap = pi->adapter;
+	struct sched_class *e;
+	struct sched_queue_entry *qe = NULL;
+	struct sge_eth_txq *txq;
+	unsigned int qid;
+	int index = -1;
+	int err = 0;
+
+	if (p->queue < 0 || p->queue >= pi->nqsets)
+		return -ERANGE;
+
+	txq = &adap->sge.ethtxq[pi->first_qset + p->queue];
+	qid = txq->q.cntxt_id;
+
+	/* Find the existing class that the queue is bound to */
+	e = t4_sched_queue_lookup(pi, qid, &index);
+	if (e && index >= 0) {
+		int i = 0;
+
+		spin_lock(&e->lock);
+		list_for_each_entry(qe, &e->queue_list, list) {
+			if (i == index)
+				break;
+			i++;
+		}
+		err = t4_sched_bind_unbind_op(pi, (void *)qe, SCHED_QUEUE,
+					      false);
+		if (err) {
+			spin_unlock(&e->lock);
+			goto out;
+		}
+
+		list_del(&qe->list);
+		t4_free_mem(qe);
+		if (atomic_dec_and_test(&e->refcnt)) {
+			e->state = SCHED_STATE_UNUSED;
+			memset(&e->info, 0, sizeof(e->info));
+		}
+		spin_unlock(&e->lock);
+	}
+out:
+	return err;
+}
+
+static int t4_sched_queue_bind(struct port_info *pi, struct ch_sched_queue *p)
+{
+	struct adapter *adap = pi->adapter;
+	struct sched_table *s = pi->sched_tbl;
+	struct sched_class *e;
+	struct sched_queue_entry *qe = NULL;
+	struct sge_eth_txq *txq;
+	unsigned int qid;
+	int err = 0;
+
+	if (p->queue < 0 || p->queue >= pi->nqsets)
+		return -ERANGE;
+
+	qe = t4_alloc_mem(sizeof(struct sched_queue_entry));
+	if (!qe)
+		return -ENOMEM;
+
+	txq = &adap->sge.ethtxq[pi->first_qset + p->queue];
+	qid = txq->q.cntxt_id;
+
+	/* Unbind queue from any existing class */
+	err = t4_sched_queue_unbind(pi, p);
+	if (err)
+		goto out;
+
+	/* Bind queue to specified class */
+	memset(qe, 0, sizeof(*qe));
+	qe->cntxt_id = qid;
+	memcpy(&qe->param, p, sizeof(qe->param));
+
+	e = &s->tab[qe->param.class];
+	spin_lock(&e->lock);
+	err = t4_sched_bind_unbind_op(pi, (void *)qe, SCHED_QUEUE, true);
+	if (err) {
+		t4_free_mem(qe);
+		spin_unlock(&e->lock);
+		goto out;
+	}
+
+	list_add_tail(&qe->list, &e->queue_list);
+	atomic_inc(&e->refcnt);
+	spin_unlock(&e->lock);
+out:
+	return err;
+}
+
+static void t4_sched_class_unbind_all(struct port_info *pi,
+				      struct sched_class *e,
+				      enum sched_bind_type type)
+{
+	if (!e)
+		return;
+
+	switch (type) {
+	case SCHED_QUEUE: {
+		struct sched_queue_entry *qe;
+
+		list_for_each_entry(qe, &e->queue_list, list)
+			t4_sched_queue_unbind(pi, &qe->param);
+		break;
+	}
+	default:
+		break;
+	}
+}
+
+static int t4_sched_class_bind_unbind_op(struct port_info *pi, void *arg,
+					 enum sched_bind_type type, bool bind)
+{
+	int err = 0;
+
+	if (!arg)
+		return -EINVAL;
+
+	switch (type) {
+	case SCHED_QUEUE: {
+		struct ch_sched_queue *qe = (struct ch_sched_queue *)arg;
+
+		if (bind)
+			err = t4_sched_queue_bind(pi, qe);
+		else
+			err = t4_sched_queue_unbind(pi, qe);
+		break;
+	}
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+/**
+ * cxgb4_sched_class_bind - Bind an entity to a scheduling class
+ * @dev: net_device pointer
+ * @arg: Entity opaque data
+ * @type: Entity type (Queue)
+ *
+ * Binds an entity (queue) to a scheduling class.  If the entity
+ * is bound to another class, it will be unbound from the other class
+ * and bound to the class specified in @arg.
+ */
+int cxgb4_sched_class_bind(struct net_device *dev, void *arg,
+			   enum sched_bind_type type)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	struct sched_table *s;
+	int err = 0;
+	u8 class_id;
+
+	if (!can_sched(dev))
+		return -ENOTSUPP;
+
+	if (!arg)
+		return -EINVAL;
+
+	switch (type) {
+	case SCHED_QUEUE: {
+		struct ch_sched_queue *qe = (struct ch_sched_queue *)arg;
+
+		class_id = qe->class;
+		break;
+	}
+	default:
+		return -ENOTSUPP;
+	}
+
+	if (!valid_class_id(dev, class_id))
+		return -EINVAL;
+
+	if (class_id == SCHED_CLS_NONE)
+		return -ENOTSUPP;
+
+	s = pi->sched_tbl;
+	write_lock(&s->rw_lock);
+	err = t4_sched_class_bind_unbind_op(pi, arg, type, true);
+	write_unlock(&s->rw_lock);
+
+	return err;
+}
+
+/**
+ * cxgb4_sched_class_unbind - Unbind an entity from a scheduling class
+ * @dev: net_device pointer
+ * @arg: Entity opaque data
+ * @type: Entity type (Queue)
+ *
+ * Unbinds an entity (queue) from a scheduling class.
+ */
+int cxgb4_sched_class_unbind(struct net_device *dev, void *arg,
+			     enum sched_bind_type type)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	struct sched_table *s;
+	int err = 0;
+	u8 class_id;
+
+	if (!can_sched(dev))
+		return -ENOTSUPP;
+
+	if (!arg)
+		return -EINVAL;
+
+	switch (type) {
+	case SCHED_QUEUE: {
+		struct ch_sched_queue *qe = (struct ch_sched_queue *)arg;
+
+		class_id = qe->class;
+		break;
+	}
+	default:
+		return -ENOTSUPP;
+	}
+
+	if (!valid_class_id(dev, class_id))
+		return -EINVAL;
+
+	s = pi->sched_tbl;
+	write_lock(&s->rw_lock);
+	err = t4_sched_class_bind_unbind_op(pi, arg, type, false);
+	write_unlock(&s->rw_lock);
+
+	return err;
+}
+
 /* If @p is NULL, fetch any available unused class */
 static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
 						const struct ch_sched_params *p)
@@ -199,6 +505,11 @@ struct sched_class *cxgb4_sched_class_alloc(struct net_device *dev,
 	return t4_sched_class_alloc(pi, p);
 }
 
+static void t4_sched_class_free(struct port_info *pi, struct sched_class *e)
+{
+	t4_sched_class_unbind_all(pi, e, SCHED_QUEUE);
+}
+
 struct sched_table *t4_init_sched(unsigned int sched_size)
 {
 	struct sched_table *s;
@@ -215,6 +526,7 @@ struct sched_table *t4_init_sched(unsigned int sched_size)
 		memset(&s->tab[i], 0, sizeof(struct sched_class));
 		s->tab[i].idx = i;
 		s->tab[i].state = SCHED_STATE_UNUSED;
+		INIT_LIST_HEAD(&s->tab[i].queue_list);
 		spin_lock_init(&s->tab[i].lock);
 		atomic_set(&s->tab[i].refcnt, 0);
 	}
@@ -230,6 +542,15 @@ void t4_cleanup_sched(struct adapter *adap)
 		struct port_info *pi = netdev2pinfo(adap->port[i]);
 
 		s = pi->sched_tbl;
+		for (i = 0; i < s->sched_size; i++) {
+			struct sched_class *e;
+
+			write_lock(&s->rw_lock);
+			e = &s->tab[i];
+			if (e->state == SCHED_STATE_ACTIVE)
+				t4_sched_class_free(pi, e);
+			write_unlock(&s->rw_lock);
+		}
 		t4_free_mem(s);
 	}
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.h b/drivers/net/ethernet/chelsio/cxgb4/sched.h
index 60b09e9..ac415eb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.h
@@ -40,6 +40,8 @@
 
 #define SCHED_CLS_NONE 0xff
 
+#define FW_SCHED_CLS_NONE 0xffffffff
+
 enum {
 	SCHED_STATE_ACTIVE,
 	SCHED_STATE_UNUSED,
@@ -49,10 +51,21 @@ enum sched_fw_ops {
 	SCHED_FW_OP_ADD,
 };
 
+enum sched_bind_type {
+	SCHED_QUEUE,
+};
+
+struct sched_queue_entry {
+	struct list_head list;
+	unsigned int cntxt_id;
+	struct ch_sched_queue param;
+};
+
 struct sched_class {
 	u8 state;
 	u8 idx;
 	struct ch_sched_params info;
+	struct list_head queue_list;
 	spinlock_t lock; /* Per class lock */
 	atomic_t refcnt;
 };
@@ -81,6 +94,11 @@ static inline bool valid_class_id(struct net_device *dev, u8 class_id)
 	return true;
 }
 
+int cxgb4_sched_class_bind(struct net_device *dev, void *arg,
+			   enum sched_bind_type type);
+int cxgb4_sched_class_unbind(struct net_device *dev, void *arg,
+			     enum sched_bind_type type);
+
 struct sched_class *cxgb4_sched_class_alloc(struct net_device *dev,
 					    struct ch_sched_params *p);
 
-- 
2.5.3
