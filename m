From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next] qed: Fix iWARP out of order flow
Date: Tue, 17 Oct 2017 10:23:25 +0300
Message-ID: <1508225005-3572-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Manish Rangankar" <Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Out of order flow is not working for iWARP.
This patch got cut out from initial series that added out
of order support for iWARP.

Make out of order code common for iWARP and iSCSI.
Add new configuration option CONFIG_QED_OOO. Set by
qedr and qedi Kconfigs.

Fixes: d1abfd0b4ee2 ("qed: Add iWARP out of order support")

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Manish Rangankar <Manish.Rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

---
 drivers/infiniband/hw/qedr/Kconfig          |  1 +
 drivers/net/ethernet/qlogic/Kconfig         |  3 +++
 drivers/net/ethernet/qlogic/qed/Makefile    |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c |  7 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_ooo.c   | 16 +++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_ooo.h   |  2 +-
 drivers/scsi/qedi/Kconfig                   |  1 +
 7 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/Kconfig b/drivers/infiniband/hw/qedr/Kconfig
index 6c9f392..60e867d 100644
--- a/drivers/infiniband/hw/qedr/Kconfig
+++ b/drivers/infiniband/hw/qedr/Kconfig
@@ -2,6 +2,7 @@ config INFINIBAND_QEDR
 	tristate "QLogic RoCE driver"
 	depends on 64BIT && QEDE
 	select QED_LL2
+	select QED_OOO
 	select QED_RDMA
 	---help---
 	  This driver provides low-level InfiniBand over Ethernet
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index c2e24af..26ddf09 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -117,4 +117,7 @@ config QED_ISCSI
 config QED_FCOE
 	bool
 
+config QED_OOO
+	bool
+
 endif # NET_VENDOR_QLOGIC
diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index 82dd470..c3c5999 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -6,5 +6,6 @@ qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
 qed-$(CONFIG_QED_LL2) += qed_ll2.o
 qed-$(CONFIG_QED_RDMA) += qed_roce.o qed_rdma.o qed_iwarp.o
-qed-$(CONFIG_QED_ISCSI) += qed_iscsi.o qed_ooo.o
+qed-$(CONFIG_QED_ISCSI) += qed_iscsi.o
 qed-$(CONFIG_QED_FCOE) += qed_fcoe.o
+qed-$(CONFIG_QED_OOO) += qed_ooo.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index b2b1f87..409041e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1410,13 +1410,18 @@ int qed_iwarp_alloc(struct qed_hwfn *p_hwfn)
 	INIT_LIST_HEAD(&p_hwfn->p_rdma_info->iwarp.ep_free_list);
 	spin_lock_init(&p_hwfn->p_rdma_info->iwarp.iw_lock);
 
-	return qed_iwarp_prealloc_ep(p_hwfn, true);
+	rc = qed_iwarp_prealloc_ep(p_hwfn, true);
+	if (rc)
+		return rc;
+
+	return qed_ooo_alloc(p_hwfn);
 }
 
 void qed_iwarp_resc_free(struct qed_hwfn *p_hwfn)
 {
 	struct qed_iwarp_info *iwarp_info = &p_hwfn->p_rdma_info->iwarp;
 
+	qed_ooo_free(p_hwfn);
 	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->tcp_cid_map, 1);
 	kfree(iwarp_info->mpa_bufs);
 	kfree(iwarp_info->partial_fpdus);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ooo.c b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
index 0006365..6172354 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ooo.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ooo.c
@@ -103,18 +103,28 @@ int qed_ooo_alloc(struct qed_hwfn *p_hwfn)
 {
 	u16 max_num_archipelagos = 0, cid_base;
 	struct qed_ooo_info *p_ooo_info;
+	enum protocol_type proto;
 	u16 max_num_isles = 0;
 	u32 i;
 
-	if (p_hwfn->hw_info.personality != QED_PCI_ISCSI) {
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ISCSI:
+		proto = PROTOCOLID_ISCSI;
+		break;
+	case QED_PCI_ETH_RDMA:
+	case QED_PCI_ETH_IWARP:
+		proto = PROTOCOLID_IWARP;
+		break;
+	default:
 		DP_NOTICE(p_hwfn,
 			  "Failed to allocate qed_ooo_info: unknown personality\n");
 		return -EINVAL;
 	}
 
-	max_num_archipelagos = p_hwfn->pf_params.iscsi_pf_params.num_cons;
+	max_num_archipelagos = (u16)qed_cxt_get_proto_cid_count(p_hwfn, proto,
+								NULL);
 	max_num_isles = QED_MAX_NUM_ISLES + max_num_archipelagos;
-	cid_base = (u16)qed_cxt_get_proto_cid_start(p_hwfn, PROTOCOLID_ISCSI);
+	cid_base = (u16)qed_cxt_get_proto_cid_start(p_hwfn, proto);
 
 	if (!max_num_archipelagos) {
 		DP_NOTICE(p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ooo.h b/drivers/net/ethernet/qlogic/qed/qed_ooo.h
index e8ed40b..49c4e75 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ooo.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ooo.h
@@ -83,7 +83,7 @@ struct qed_ooo_info {
 	u16 cid_base;
 };
 
-#if IS_ENABLED(CONFIG_QED_ISCSI)
+#if IS_ENABLED(CONFIG_QED_OOO)
 void qed_ooo_save_history_entry(struct qed_hwfn *p_hwfn,
 				struct qed_ooo_info *p_ooo_info,
 				struct ooo_opaque *p_cqe);
diff --git a/drivers/scsi/qedi/Kconfig b/drivers/scsi/qedi/Kconfig
index 2ff753c..d1db92d 100644
--- a/drivers/scsi/qedi/Kconfig
+++ b/drivers/scsi/qedi/Kconfig
@@ -4,6 +4,7 @@ config QEDI
 	depends on QED
 	select SCSI_ISCSI_ATTRS
 	select QED_LL2
+	select QED_OOO
 	select QED_ISCSI
 	select ISCSI_BOOT_SYSFS
 	---help---
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
