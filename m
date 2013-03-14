From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v2 net-next 13/22] RDMA/cxgb4: Turn off db coalescing when RDMA QPs are in use.
Date: Thu, 14 Mar 2013 20:38:59 +0530
Message-ID: <1363273748-25330-14-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	naresh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	arvindb-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1363273748-25330-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/infiniband/hw/cxgb4/qp.c                |   20 ++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   19 +++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    3 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    4 ++++
 4 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index c460244..da4869f 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -42,10 +42,17 @@ static int ocqp_support = 1;
 module_param(ocqp_support, int, 0644);
 MODULE_PARM_DESC(ocqp_support, "Support on-chip SQs (default=1)");
 
-int db_fc_threshold = 2000;
+int db_fc_threshold = 1000;
 module_param(db_fc_threshold, int, 0644);
-MODULE_PARM_DESC(db_fc_threshold, "QP count/threshold that triggers automatic "
-		 "db flow control mode (default = 2000)");
+MODULE_PARM_DESC(db_fc_threshold,
+		 "QP count/threshold that triggers"
+		 " automatic db flow control mode (default = 1000)");
+
+int db_coalescing_threshold;
+module_param(db_coalescing_threshold, int, 0644);
+MODULE_PARM_DESC(db_coalescing_threshold,
+		 "QP count/threshold that triggers"
+		 " disabling db coalescing (default = 0)");
 
 static void set_state(struct c4iw_qp *qhp, enum c4iw_qp_state state)
 {
@@ -1448,6 +1455,8 @@ int c4iw_destroy_qp(struct ib_qp *ib_qp)
 		rhp->db_state = NORMAL;
 		idr_for_each(&rhp->qpidr, enable_qp_db, NULL);
 	}
+	if (rhp->qpcnt <= db_coalescing_threshold)
+		cxgb4_enable_db_coalescing(rhp->rdev.lldi.ports[0]);
 	spin_unlock_irq(&rhp->lock);
 	atomic_dec(&qhp->refcnt);
 	wait_event(qhp->wait, !atomic_read(&qhp->refcnt));
@@ -1559,11 +1568,14 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	spin_lock_irq(&rhp->lock);
 	if (rhp->db_state != NORMAL)
 		t4_disable_wq_db(&qhp->wq);
-	if (++rhp->qpcnt > db_fc_threshold && rhp->db_state == NORMAL) {
+	rhp->qpcnt++;
+	if (rhp->qpcnt > db_fc_threshold && rhp->db_state == NORMAL) {
 		rhp->rdev.stats.db_state_transitions++;
 		rhp->db_state = FLOW_CONTROL;
 		idr_for_each(&rhp->qpidr, disable_qp_db, NULL);
 	}
+	if (rhp->qpcnt > db_coalescing_threshold)
+		cxgb4_disable_db_coalescing(rhp->rdev.lldi.ports[0]);
 	ret = insert_handle_nolock(rhp, &rhp->qpidr, qhp, qhp->wq.sq.qid);
 	spin_unlock_irq(&rhp->lock);
 	if (ret)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a59bb23..e76cf03 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3397,6 +3397,25 @@ out:
 }
 EXPORT_SYMBOL(cxgb4_sync_txq_pidx);
 
+void cxgb4_disable_db_coalescing(struct net_device *dev)
+{
+	struct adapter *adap;
+
+	adap = netdev2adap(dev);
+	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_NOCOALESCE,
+			 F_NOCOALESCE);
+}
+EXPORT_SYMBOL(cxgb4_disable_db_coalescing);
+
+void cxgb4_enable_db_coalescing(struct net_device *dev)
+{
+	struct adapter *adap;
+
+	adap = netdev2adap(dev);
+	t4_set_reg_field(adap, A_SGE_DOORBELL_CONTROL, F_NOCOALESCE, 0);
+}
+EXPORT_SYMBOL(cxgb4_enable_db_coalescing);
+
 static struct pci_driver cxgb4_driver;
 
 static void check_neigh_update(struct neighbour *neigh)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index e2bbc7f..4faf4d0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -269,4 +269,7 @@ struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
 				   unsigned int skb_len, unsigned int pull_len);
 int cxgb4_sync_txq_pidx(struct net_device *dev, u16 qid, u16 pidx, u16 size);
 int cxgb4_flush_eq_cache(struct net_device *dev);
+void cxgb4_disable_db_coalescing(struct net_device *dev);
+void cxgb4_enable_db_coalescing(struct net_device *dev);
+
 #endif  /* !__CXGB4_OFLD_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 22cbcb3..ef146c0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -241,6 +241,10 @@
 #define SGE_DOORBELL_CONTROL 0x10a8
 #define  ENABLE_DROP        (1 << 13)
 
+#define S_NOCOALESCE    26
+#define V_NOCOALESCE(x) ((x) << S_NOCOALESCE)
+#define F_NOCOALESCE    V_NOCOALESCE(1U)
+
 #define SGE_TIMER_VALUE_0_AND_1 0x10b8
 #define  TIMERVALUE0_MASK   0xffff0000U
 #define  TIMERVALUE0_SHIFT  16
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
