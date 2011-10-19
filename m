From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 01/10] cxgb4: Detect DB FULL events and notify RDMA ULD.
Date: Wed, 19 Oct 2011 22:40:55 +0530
Message-ID: <1319044264-779-2-git-send-email-vipul@chelsio.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1319044264-779-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   77 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 ++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    6 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    9 +++
 5 files changed, 103 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 223a7f7..e18b5ad 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -504,6 +504,8 @@ struct adapter {
 	void **tid_release_head;
 	spinlock_t tid_release_lock;
 	struct work_struct tid_release_task;
+	struct work_struct db_full_task;
+	struct work_struct db_drop_task;
 	bool tid_release_task_busy;
 
 	struct dentry *debugfs_root;
@@ -719,4 +721,6 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int eqid);
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
+void t4_db_full(struct adapter *adapter);
+void t4_db_dropped(struct adapter *adapter);
 #endif /* __CXGB4_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4c8f42a..870c320 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2371,6 +2371,16 @@ unsigned int cxgb4_port_chan(const struct net_device *dev)
 }
 EXPORT_SYMBOL(cxgb4_port_chan);
 
+unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo)
+{
+	struct adapter *adap = netdev2adap(dev);
+	u32 v;
+
+	v = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
+	return lpfifo ? G_LP_COUNT(v) : G_HP_COUNT(v);
+}
+EXPORT_SYMBOL(cxgb4_dbfifo_count);
+
 /**
  *	cxgb4_port_viid - get the VI id of a port
  *	@dev: the net device for the port
@@ -2451,6 +2461,69 @@ static struct notifier_block cxgb4_netevent_nb = {
 	.notifier_call = netevent_cb
 };
 
+static void notify_rdma_uld(struct adapter *adap, enum cxgb4_control cmd)
+{
+	mutex_lock(&uld_mutex);
+	if (adap->uld_handle[CXGB4_ULD_RDMA])
+		ulds[CXGB4_ULD_RDMA].control(adap->uld_handle[CXGB4_ULD_RDMA],
+				cmd);
+	mutex_unlock(&uld_mutex);
+}
+
+static void process_db_full(struct work_struct *work)
+{
+	struct adapter *adap;
+	static int delay = 1000;
+	u32 v;
+
+	adap = container_of(work, struct adapter, db_full_task);
+
+
+	/* stop LLD queues */
+
+	notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
+	do {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(usecs_to_jiffies(delay));
+		v = t4_read_reg(adap, A_SGE_DBFIFO_STATUS);
+		if (G_LP_COUNT(v) == 0 && G_HP_COUNT(v) == 0)
+			break;
+	} while (1);
+	notify_rdma_uld(adap, CXGB4_CONTROL_DB_EMPTY);
+
+
+	/*
+	 * The more we get db full interrupts, the more we'll delay
+	 * in re-enabling db rings on queues, capped off at 200ms.
+	 */
+	delay = min(delay << 1, 200000);
+
+	/* resume LLD queues */
+}
+
+static void process_db_drop(struct work_struct *work)
+{
+	struct adapter *adap;
+	adap = container_of(work, struct adapter, db_drop_task);
+
+
+	/*
+	 * sync the PIDX values in HW and SW for LLD queues.
+	 */
+
+	notify_rdma_uld(adap, CXGB4_CONTROL_DB_DROP);
+}
+
+void t4_db_full(struct adapter *adap)
+{
+	schedule_work(&adap->db_full_task);
+}
+
+void t4_db_dropped(struct adapter *adap)
+{
+	schedule_work(&adap->db_drop_task);
+}
+
 static void uld_attach(struct adapter *adap, unsigned int uld)
 {
 	void *handle;
@@ -2654,6 +2727,8 @@ static void cxgb_down(struct adapter *adapter)
 {
 	t4_intr_disable(adapter);
 	cancel_work_sync(&adapter->tid_release_task);
+	cancel_work_sync(&adapter->db_full_task);
+	cancel_work_sync(&adapter->db_drop_task);
 	adapter->tid_release_task_busy = false;
 	adapter->tid_release_head = NULL;
 
@@ -3606,6 +3681,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 	spin_lock_init(&adapter->tid_release_lock);
 
 	INIT_WORK(&adapter->tid_release_task, process_tid_release_list);
+	INIT_WORK(&adapter->db_full_task, process_db_full);
+	INIT_WORK(&adapter->db_drop_task, process_db_drop);
 
 	err = t4_prep_adapter(adapter);
 	if (err)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index b1d39b8..5cc2f27 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -163,6 +163,12 @@ enum cxgb4_state {
 	CXGB4_STATE_DETACH
 };
 
+enum cxgb4_control {
+	CXGB4_CONTROL_DB_FULL,
+	CXGB4_CONTROL_DB_EMPTY,
+	CXGB4_CONTROL_DB_DROP,
+};
+
 struct pci_dev;
 struct l2t_data;
 struct net_device;
@@ -225,6 +231,7 @@ struct cxgb4_uld_info {
 int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
 int cxgb4_unregister_uld(enum cxgb4_uld type);
 int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
+unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
 unsigned int cxgb4_port_viid(const struct net_device *dev);
 unsigned int cxgb4_port_idx(const struct net_device *dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 007ce23..3631fbb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2414,6 +2414,12 @@ void t4_sge_init(struct adapter *adap)
 			 RXPKTCPLMODE |
 			 (STAT_LEN == 128 ? EGRSTATUSPAGESIZE : 0));
 
+	t4_set_reg_field(adap, A_SGE_DBFIFO_STATUS,
+			V_HP_INT_THRESH(5) | V_LP_INT_THRESH(5),
+			V_HP_INT_THRESH(5) | V_LP_INT_THRESH(5));
+	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_ENABLE_DROP,
+			F_ENABLE_DROP);
+
 	for (i = v = 0; i < 32; i += 4)
 		v |= (PAGE_SHIFT - 10) << i;
 	t4_write_reg(adap, SGE_HOST_PAGE_SIZE, v);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index d1ec111..13609bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1013,6 +1013,8 @@ static void sge_intr_handler(struct adapter *adapter)
 		{ ERR_INVALID_CIDX_INC,
 		  "SGE GTS CIDX increment too large", -1, 0 },
 		{ ERR_CPL_OPCODE_0, "SGE received 0-length CPL", -1, 0 },
+		{ F_DBFIFO_LP_INT, NULL, -1, 0 },
+		{ F_DBFIFO_HP_INT, NULL, -1, 0 },
 		{ ERR_DROPPED_DB, "SGE doorbell dropped", -1, 0 },
 		{ ERR_DATA_CPL_ON_HIGH_QID1 | ERR_DATA_CPL_ON_HIGH_QID0,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
@@ -1042,6 +1044,12 @@ static void sge_intr_handler(struct adapter *adapter)
 		t4_write_reg(adapter, SGE_INT_CAUSE2, v >> 32);
 	}
 
+	err = t4_read_reg(adapter, A_SGE_INT_CAUSE3);
+	if (err & (F_DBFIFO_HP_INT|F_DBFIFO_LP_INT))
+		t4_db_full(adapter);
+	if (err & F_ERR_DROPPED_DB)
+		t4_db_dropped(adapter);
+
 	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3, sge_intr_info) ||
 	    v != 0)
 		t4_fatal_err(adapter);
@@ -1513,6 +1521,7 @@ void t4_intr_enable(struct adapter *adapter)
 		     ERR_BAD_DB_PIDX2 | ERR_BAD_DB_PIDX1 |
 		     ERR_BAD_DB_PIDX0 | ERR_ING_CTXT_PRIO |
 		     ERR_EGR_CTXT_PRIO | INGRESS_SIZE_ERR |
+		     F_DBFIFO_HP_INT | F_DBFIFO_LP_INT |
 		     EGRESS_SIZE_ERR);
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE), PF_INTR_MASK);
 	t4_set_reg_field(adapter, PL_INT_MAP0, 0, 1 << pf);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
