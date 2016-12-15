From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 02/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) interface
Date: Wed, 14 Dec 2016 23:59:34 -0800
Message-ID: <1481788782-89964-3-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Create hfi_ibdev abstraction which hfi1_ibdev will extend.
Define HFI VNIC interface between hardware independent VNIC
functionality and the hardware dependent VNIC functionality.
Add VNIC control operations to add and remove VNIC devices,
to the hfi_ibdev structure.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/hw/hfi1/chip.c   |   2 +-
 drivers/infiniband/hw/hfi1/driver.c |  10 +-
 drivers/infiniband/hw/hfi1/hfi.h    |   2 +-
 drivers/infiniband/hw/hfi1/init.c   |   4 +-
 drivers/infiniband/hw/hfi1/intr.c   |   2 +-
 drivers/infiniband/hw/hfi1/mad.c    |   2 +-
 drivers/infiniband/hw/hfi1/qp.c     |  24 +++--
 drivers/infiniband/hw/hfi1/ruc.c    |   2 +-
 drivers/infiniband/hw/hfi1/sysfs.c  |  22 ++--
 drivers/infiniband/hw/hfi1/verbs.c  | 113 ++++++++++----------
 drivers/infiniband/hw/hfi1/verbs.h  |   9 +-
 include/rdma/opa_hfi.h              | 199 ++++++++++++++++++++++++++++++++++++
 12 files changed, 298 insertions(+), 93 deletions(-)
 create mode 100644 include/rdma/opa_hfi.h

diff --git a/drivers/infiniband/hw/hfi1/chip.c b/drivers/infiniband/hw/hfi1/chip.c
index 37d8af5..9263984 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -10452,7 +10452,7 @@ int set_link_state(struct hfi1_pportdata *ppd, u32 state)
 			sdma_all_running(dd);
 
 			/* Signal the IB layer that the port has went active */
-			event.device = &dd->verbs_dev.rdi.ibdev;
+			event.device = &dd->verbs_dev.hfidev.rdi.ibdev;
 			event.element.port_num = ppd->port;
 			event.event = IB_EVENT_PORT_ACTIVE;
 		}
diff --git a/drivers/infiniband/hw/hfi1/driver.c b/drivers/infiniband/hw/hfi1/driver.c
index d426116..e219c3b 100644
--- a/drivers/infiniband/hw/hfi1/driver.c
+++ b/drivers/infiniband/hw/hfi1/driver.c
@@ -163,7 +163,8 @@ const char *get_unit_name(int unit)
 
 const char *get_card_name(struct rvt_dev_info *rdi)
 {
-	struct hfi1_ibdev *ibdev = container_of(rdi, struct hfi1_ibdev, rdi);
+	struct hfi1_ibdev *ibdev = container_of(rdi, struct hfi1_ibdev,
+						hfidev.rdi);
 	struct hfi1_devdata *dd = container_of(ibdev,
 					       struct hfi1_devdata, verbs_dev);
 	return get_unit_name(dd->unit);
@@ -171,7 +172,8 @@ const char *get_card_name(struct rvt_dev_info *rdi)
 
 struct pci_dev *get_pci_dev(struct rvt_dev_info *rdi)
 {
-	struct hfi1_ibdev *ibdev = container_of(rdi, struct hfi1_ibdev, rdi);
+	struct hfi1_ibdev *ibdev = container_of(rdi, struct hfi1_ibdev,
+						hfidev.rdi);
 	struct hfi1_devdata *dd = container_of(ibdev,
 					       struct hfi1_devdata, verbs_dev);
 	return dd->pcidev;
@@ -281,7 +283,7 @@ static void rcv_hdrerr(struct hfi1_ctxtdata *rcd, struct hfi1_pportdata *ppd,
 	int lnh = be16_to_cpu(rhdr->lrh[0]) & 3;
 	struct hfi1_ibport *ibp = &ppd->ibport_data;
 	struct hfi1_devdata *dd = ppd->dd;
-	struct rvt_dev_info *rdi = &dd->verbs_dev.rdi;
+	struct rvt_dev_info *rdi = &dd->verbs_dev.hfidev.rdi;
 
 	if (packet->rhf & (RHF_VCRC_ERR | RHF_ICRC_ERR))
 		return;
@@ -600,7 +602,7 @@ static void __prescan_rxq(struct hfi1_packet *packet)
 		struct rvt_qp *qp;
 		struct ib_header *hdr;
 		struct ib_other_headers *ohdr;
-		struct rvt_dev_info *rdi = &dd->verbs_dev.rdi;
+		struct rvt_dev_info *rdi = &dd->verbs_dev.hfidev.rdi;
 		u64 rhf = rhf_to_cpu(rhf_addr);
 		u32 etype = rhf_rcv_type(rhf), qpn, bth1;
 		int is_ecn = 0;
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index 4163596..1fc5b68 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -1601,7 +1601,7 @@ static inline struct hfi1_pportdata *ppd_from_ibp(struct hfi1_ibport *ibp)
 
 static inline struct hfi1_ibdev *dev_from_rdi(struct rvt_dev_info *rdi)
 {
-	return container_of(rdi, struct hfi1_ibdev, rdi);
+	return container_of(rdi, struct hfi1_ibdev, hfidev.rdi);
 }
 
 static inline struct hfi1_ibport *to_iport(struct ib_device *ibdev, u8 port)
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 60db615..13f6862 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1020,7 +1020,7 @@ static void __hfi1_free_devdata(struct kobject *kobj)
 	free_percpu(dd->int_counter);
 	free_percpu(dd->rcv_limit);
 	free_percpu(dd->send_schedule);
-	rvt_dealloc_device(&dd->verbs_dev.rdi);
+	rvt_dealloc_device(&dd->verbs_dev.hfidev.rdi);
 }
 
 static struct kobj_type hfi1_devdata_type = {
@@ -1133,7 +1133,7 @@ struct hfi1_devdata *hfi1_alloc_devdata(struct pci_dev *pdev, size_t extra)
 bail:
 	if (!list_empty(&dd->list))
 		list_del_init(&dd->list);
-	rvt_dealloc_device(&dd->verbs_dev.rdi);
+	rvt_dealloc_device(&dd->verbs_dev.hfidev.rdi);
 	return ERR_PTR(ret);
 }
 
diff --git a/drivers/infiniband/hw/hfi1/intr.c b/drivers/infiniband/hw/hfi1/intr.c
index 65348d1..b4f94b1 100644
--- a/drivers/infiniband/hw/hfi1/intr.c
+++ b/drivers/infiniband/hw/hfi1/intr.c
@@ -95,7 +95,7 @@ static void signal_ib_event(struct hfi1_pportdata *ppd, enum ib_event_type ev)
 	 */
 	if (!(dd->flags & HFI1_INITTED))
 		return;
-	event.device = &dd->verbs_dev.rdi.ibdev;
+	event.device = &dd->verbs_dev.hfidev.rdi.ibdev;
 	event.element.port_num = ppd->port;
 	event.event = ev;
 	ib_dispatch_event(&event);
diff --git a/drivers/infiniband/hw/hfi1/mad.c b/drivers/infiniband/hw/hfi1/mad.c
index 6e595af..ed8ae22 100644
--- a/drivers/infiniband/hw/hfi1/mad.c
+++ b/drivers/infiniband/hw/hfi1/mad.c
@@ -83,7 +83,7 @@ void hfi1_event_pkey_change(struct hfi1_devdata *dd, u8 port)
 	struct ib_event event;
 
 	event.event = IB_EVENT_PKEY_CHANGE;
-	event.device = &dd->verbs_dev.rdi.ibdev;
+	event.device = &dd->verbs_dev.hfidev.rdi.ibdev;
 	event.element.port_num = port;
 	ib_dispatch_event(&event);
 }
diff --git a/drivers/infiniband/hw/hfi1/qp.c b/drivers/infiniband/hw/hfi1/qp.c
index d752d67..cf0f6ed 100644
--- a/drivers/infiniband/hw/hfi1/qp.c
+++ b/drivers/infiniband/hw/hfi1/qp.c
@@ -659,7 +659,7 @@ struct qp_iter *qp_iter_init(struct hfi1_ibdev *dev)
 		return NULL;
 
 	iter->dev = dev;
-	iter->specials = dev->rdi.ibdev.phys_port_cnt * 2;
+	iter->specials = dev->hfidev.rdi.ibdev.phys_port_cnt * 2;
 
 	return iter;
 }
@@ -682,11 +682,13 @@ int qp_iter_next(struct qp_iter *iter)
 	 *
 	 * n = 0..iter->specials is the special qp indices
 	 *
-	 * n = iter->specials..dev->rdi.qp_dev->qp_table_size+iter->specials are
+	 * n = iter->specials..
+	 *     dev->hfidev.rdi.qp_dev->qp_table_size+iter->specials are
 	 * the potential hash bucket entries
 	 *
 	 */
-	for (; n <  dev->rdi.qp_dev->qp_table_size + iter->specials; n++) {
+	for (; n <  dev->hfidev.rdi.qp_dev->qp_table_size + iter->specials;
+	     n++) {
 		if (pqp) {
 			qp = rcu_dereference(pqp->next);
 		} else {
@@ -695,7 +697,7 @@ int qp_iter_next(struct qp_iter *iter)
 				struct hfi1_ibport *ibp;
 				int pidx;
 
-				pidx = n % dev->rdi.ibdev.phys_port_cnt;
+				pidx = n % dev->hfidev.rdi.ibdev.phys_port_cnt;
 				ppd = &dd_from_dev(dev)->pport[pidx];
 				ibp = &ppd->ibport_data;
 
@@ -705,7 +707,7 @@ int qp_iter_next(struct qp_iter *iter)
 					qp = rcu_dereference(ibp->rvp.qp[1]);
 			} else {
 				qp = rcu_dereference(
-					dev->rdi.qp_dev->qp_table[
+					dev->hfidev.rdi.qp_dev->qp_table[
 						(n - iter->specials)]);
 			}
 		}
@@ -836,7 +838,7 @@ unsigned free_all_qps(struct rvt_dev_info *rdi)
 {
 	struct hfi1_ibdev *verbs_dev = container_of(rdi,
 						    struct hfi1_ibdev,
-						    rdi);
+						    hfidev.rdi);
 	struct hfi1_devdata *dd = container_of(verbs_dev,
 					       struct hfi1_devdata,
 					       verbs_dev);
@@ -922,7 +924,7 @@ u32 mtu_from_qp(struct rvt_dev_info *rdi, struct rvt_qp *qp, u32 pmtu)
 	u32 mtu;
 	struct hfi1_ibdev *verbs_dev = container_of(rdi,
 						    struct hfi1_ibdev,
-						    rdi);
+						    hfidev.rdi);
 	struct hfi1_devdata *dd = container_of(verbs_dev,
 					       struct hfi1_devdata,
 					       verbs_dev);
@@ -945,7 +947,7 @@ int get_pmtu_from_attr(struct rvt_dev_info *rdi, struct rvt_qp *qp,
 	int mtu, pidx = qp->port_num - 1;
 	struct hfi1_ibdev *verbs_dev = container_of(rdi,
 						    struct hfi1_ibdev,
-						    rdi);
+						    hfidev.rdi);
 	struct hfi1_devdata *dd = container_of(verbs_dev,
 					       struct hfi1_devdata,
 					       verbs_dev);
@@ -1004,9 +1006,9 @@ void hfi1_error_port_qps(struct hfi1_ibport *ibp, u8 sl)
 	rcu_read_lock();
 
 	/* Deal only with RC/UC qps that use the given SL. */
-	for (n = 0; n < dev->rdi.qp_dev->qp_table_size; n++) {
-		for (qp = rcu_dereference(dev->rdi.qp_dev->qp_table[n]); qp;
-			qp = rcu_dereference(qp->next)) {
+	for (n = 0; n < dev->hfidev.rdi.qp_dev->qp_table_size; n++) {
+		for (qp = rcu_dereference(dev->hfidev.rdi.qp_dev->qp_table[n]);
+		     qp; qp = rcu_dereference(qp->next)) {
 			if (qp->port_num == ppd->port &&
 			    (qp->ibqp.qp_type == IB_QPT_UC ||
 			     qp->ibqp.qp_type == IB_QPT_RC) &&
diff --git a/drivers/infiniband/hw/hfi1/ruc.c b/drivers/infiniband/hw/hfi1/ruc.c
index 717ed4b15..175d352 100644
--- a/drivers/infiniband/hw/hfi1/ruc.c
+++ b/drivers/infiniband/hw/hfi1/ruc.c
@@ -103,7 +103,7 @@ static int init_sge(struct rvt_qp *qp, struct rvt_rwqe *wqe)
 	struct rvt_pd *pd;
 	struct rvt_sge_state *ss;
 
-	rkt = &to_idev(qp->ibqp.device)->rdi.lkey_table;
+	rkt = &to_idev(qp->ibqp.device)->hfidev.rdi.lkey_table;
 	pd = ibpd_to_rvtpd(qp->ibqp.srq ? qp->ibqp.srq->pd : qp->ibqp.pd);
 	ss = &qp->r_sge;
 	ss->sg_list = qp->r_sg_list;
diff --git a/drivers/infiniband/hw/hfi1/sysfs.c b/drivers/infiniband/hw/hfi1/sysfs.c
index edba224..06bff50 100644
--- a/drivers/infiniband/hw/hfi1/sysfs.c
+++ b/drivers/infiniband/hw/hfi1/sysfs.c
@@ -498,7 +498,7 @@ static ssize_t show_rev(struct device *device, struct device_attribute *attr,
 			char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 
 	return sprintf(buf, "%x\n", dd_from_dev(dev)->minrev);
 }
@@ -507,7 +507,7 @@ static ssize_t show_hfi(struct device *device, struct device_attribute *attr,
 			char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 	int ret;
 
@@ -522,7 +522,7 @@ static ssize_t show_boardversion(struct device *device,
 				 struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	/* The string printed here is already newline-terminated. */
@@ -533,7 +533,7 @@ static ssize_t show_nctxts(struct device *device,
 			   struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	/*
@@ -551,7 +551,7 @@ static ssize_t show_nfreectxts(struct device *device,
 			       struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	/* Return the number of free user ports (contexts) available. */
@@ -562,7 +562,7 @@ static ssize_t show_serial(struct device *device,
 			   struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	return scnprintf(buf, PAGE_SIZE, "%s", dd->serial);
@@ -573,7 +573,7 @@ static ssize_t store_chip_reset(struct device *device,
 				size_t count)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 	int ret;
 
@@ -602,7 +602,7 @@ static ssize_t show_tempsense(struct device *device,
 			      struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 	struct hfi1_temp temp;
 	int ret;
@@ -627,7 +627,7 @@ static ssize_t show_sdma_affinity(struct device *device,
 				  struct device_attribute *attr, char *buf)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	return hfi1_get_sdma_affinity(dd, buf);
@@ -638,7 +638,7 @@ static ssize_t store_sdma_affinity(struct device *device,
 				   const char *buf, size_t count)
 {
 	struct hfi1_ibdev *dev =
-		container_of(device, struct hfi1_ibdev, rdi.ibdev.dev);
+		container_of(device, struct hfi1_ibdev, hfidev.rdi.ibdev.dev);
 	struct hfi1_devdata *dd = dd_from_dev(dev);
 
 	return hfi1_set_sdma_affinity(dd, buf, count);
@@ -852,7 +852,7 @@ static SDE_ATTR(cpu_list, S_IWUSR | S_IRUGO,
  */
 int hfi1_verbs_register_sysfs(struct hfi1_devdata *dd)
 {
-	struct ib_device *dev = &dd->verbs_dev.rdi.ibdev;
+	struct ib_device *dev = &dd->verbs_dev.hfidev.rdi.ibdev;
 	struct device *class_dev = &dev->dev;
 	int i, j, ret;
 
diff --git a/drivers/infiniband/hw/hfi1/verbs.c b/drivers/infiniband/hw/hfi1/verbs.c
index 95ed4d6..9355c4c 100644
--- a/drivers/infiniband/hw/hfi1/verbs.c
+++ b/drivers/infiniband/hw/hfi1/verbs.c
@@ -577,7 +577,7 @@ void hfi1_ib_rcv(struct hfi1_packet *packet)
 	u32 tlen = packet->tlen;
 	struct hfi1_pportdata *ppd = rcd->ppd;
 	struct hfi1_ibport *ibp = &ppd->ibport_data;
-	struct rvt_dev_info *rdi = &ppd->dd->verbs_dev.rdi;
+	struct rvt_dev_info *rdi = &ppd->dd->verbs_dev.hfidev.rdi;
 	opcode_handler packet_handler;
 	unsigned long flags;
 	u32 qp_num;
@@ -1301,7 +1301,7 @@ int hfi1_verbs_send(struct rvt_qp *qp, struct hfi1_pkt_state *ps)
  */
 static void hfi1_fill_device_attr(struct hfi1_devdata *dd)
 {
-	struct rvt_dev_info *rdi = &dd->verbs_dev.rdi;
+	struct rvt_dev_info *rdi = &dd->verbs_dev.hfidev.rdi;
 	u16 ver = dd->dc8051_ver;
 
 	memset(&rdi->dparms.props, 0, sizeof(rdi->dparms.props));
@@ -1747,9 +1747,10 @@ static int get_hw_stats(struct ib_device *ibdev, struct rdma_hw_stats *stats,
 int hfi1_register_ib_device(struct hfi1_devdata *dd)
 {
 	struct hfi1_ibdev *dev = &dd->verbs_dev;
-	struct ib_device *ibdev = &dev->rdi.ibdev;
+	struct ib_device *ibdev = &dev->hfidev.rdi.ibdev;
 	struct hfi1_pportdata *ppd = dd->pport;
 	struct hfi1_ibport *ibp = &ppd->ibport_data;
+	struct rvt_dev_info *rdi = &dd->verbs_dev.hfidev.rdi;
 	unsigned i;
 	int ret;
 	size_t lcpysz = IB_DEVICE_NAME_MAX;
@@ -1799,77 +1800,77 @@ int hfi1_register_ib_device(struct hfi1_devdata *dd)
 	/*
 	 * Fill in rvt info object.
 	 */
-	dd->verbs_dev.rdi.driver_f.port_callback = hfi1_create_port_files;
-	dd->verbs_dev.rdi.driver_f.get_card_name = get_card_name;
-	dd->verbs_dev.rdi.driver_f.get_pci_dev = get_pci_dev;
-	dd->verbs_dev.rdi.driver_f.check_ah = hfi1_check_ah;
-	dd->verbs_dev.rdi.driver_f.notify_new_ah = hfi1_notify_new_ah;
-	dd->verbs_dev.rdi.driver_f.get_guid_be = hfi1_get_guid_be;
-	dd->verbs_dev.rdi.driver_f.query_port_state = query_port;
-	dd->verbs_dev.rdi.driver_f.shut_down_port = shut_down_port;
-	dd->verbs_dev.rdi.driver_f.cap_mask_chg = hfi1_cap_mask_chg;
+	rdi->driver_f.port_callback = hfi1_create_port_files;
+	rdi->driver_f.get_card_name = get_card_name;
+	rdi->driver_f.get_pci_dev = get_pci_dev;
+	rdi->driver_f.check_ah = hfi1_check_ah;
+	rdi->driver_f.notify_new_ah = hfi1_notify_new_ah;
+	rdi->driver_f.get_guid_be = hfi1_get_guid_be;
+	rdi->driver_f.query_port_state = query_port;
+	rdi->driver_f.shut_down_port = shut_down_port;
+	rdi->driver_f.cap_mask_chg = hfi1_cap_mask_chg;
 	/*
 	 * Fill in rvt info device attributes.
 	 */
 	hfi1_fill_device_attr(dd);
 
 	/* queue pair */
-	dd->verbs_dev.rdi.dparms.qp_table_size = hfi1_qp_table_size;
-	dd->verbs_dev.rdi.dparms.qpn_start = 0;
-	dd->verbs_dev.rdi.dparms.qpn_inc = 1;
-	dd->verbs_dev.rdi.dparms.qos_shift = dd->qos_shift;
-	dd->verbs_dev.rdi.dparms.qpn_res_start = kdeth_qp << 16;
-	dd->verbs_dev.rdi.dparms.qpn_res_end =
-	dd->verbs_dev.rdi.dparms.qpn_res_start + 65535;
-	dd->verbs_dev.rdi.dparms.max_rdma_atomic = HFI1_MAX_RDMA_ATOMIC;
-	dd->verbs_dev.rdi.dparms.psn_mask = PSN_MASK;
-	dd->verbs_dev.rdi.dparms.psn_shift = PSN_SHIFT;
-	dd->verbs_dev.rdi.dparms.psn_modify_mask = PSN_MODIFY_MASK;
-	dd->verbs_dev.rdi.dparms.core_cap_flags = RDMA_CORE_PORT_INTEL_OPA;
-	dd->verbs_dev.rdi.dparms.max_mad_size = OPA_MGMT_MAD_SIZE;
-
-	dd->verbs_dev.rdi.driver_f.qp_priv_alloc = qp_priv_alloc;
-	dd->verbs_dev.rdi.driver_f.qp_priv_free = qp_priv_free;
-	dd->verbs_dev.rdi.driver_f.free_all_qps = free_all_qps;
-	dd->verbs_dev.rdi.driver_f.notify_qp_reset = notify_qp_reset;
-	dd->verbs_dev.rdi.driver_f.do_send = hfi1_do_send;
-	dd->verbs_dev.rdi.driver_f.schedule_send = hfi1_schedule_send;
-	dd->verbs_dev.rdi.driver_f.schedule_send_no_lock = _hfi1_schedule_send;
-	dd->verbs_dev.rdi.driver_f.get_pmtu_from_attr = get_pmtu_from_attr;
-	dd->verbs_dev.rdi.driver_f.notify_error_qp = notify_error_qp;
-	dd->verbs_dev.rdi.driver_f.flush_qp_waiters = flush_qp_waiters;
-	dd->verbs_dev.rdi.driver_f.stop_send_queue = stop_send_queue;
-	dd->verbs_dev.rdi.driver_f.quiesce_qp = quiesce_qp;
-	dd->verbs_dev.rdi.driver_f.notify_error_qp = notify_error_qp;
-	dd->verbs_dev.rdi.driver_f.mtu_from_qp = mtu_from_qp;
-	dd->verbs_dev.rdi.driver_f.mtu_to_path_mtu = mtu_to_path_mtu;
-	dd->verbs_dev.rdi.driver_f.check_modify_qp = hfi1_check_modify_qp;
-	dd->verbs_dev.rdi.driver_f.modify_qp = hfi1_modify_qp;
-	dd->verbs_dev.rdi.driver_f.check_send_wqe = hfi1_check_send_wqe;
+	rdi->dparms.qp_table_size = hfi1_qp_table_size;
+	rdi->dparms.qpn_start = 0;
+	rdi->dparms.qpn_inc = 1;
+	rdi->dparms.qos_shift = dd->qos_shift;
+	rdi->dparms.qpn_res_start = kdeth_qp << 16;
+	rdi->dparms.qpn_res_end =
+	rdi->dparms.qpn_res_start + 65535;
+	rdi->dparms.max_rdma_atomic = HFI1_MAX_RDMA_ATOMIC;
+	rdi->dparms.psn_mask = PSN_MASK;
+	rdi->dparms.psn_shift = PSN_SHIFT;
+	rdi->dparms.psn_modify_mask = PSN_MODIFY_MASK;
+	rdi->dparms.core_cap_flags = RDMA_CORE_PORT_INTEL_OPA;
+	rdi->dparms.max_mad_size = OPA_MGMT_MAD_SIZE;
+
+	rdi->driver_f.qp_priv_alloc = qp_priv_alloc;
+	rdi->driver_f.qp_priv_free = qp_priv_free;
+	rdi->driver_f.free_all_qps = free_all_qps;
+	rdi->driver_f.notify_qp_reset = notify_qp_reset;
+	rdi->driver_f.do_send = hfi1_do_send;
+	rdi->driver_f.schedule_send = hfi1_schedule_send;
+	rdi->driver_f.schedule_send_no_lock = _hfi1_schedule_send;
+	rdi->driver_f.get_pmtu_from_attr = get_pmtu_from_attr;
+	rdi->driver_f.notify_error_qp = notify_error_qp;
+	rdi->driver_f.flush_qp_waiters = flush_qp_waiters;
+	rdi->driver_f.stop_send_queue = stop_send_queue;
+	rdi->driver_f.quiesce_qp = quiesce_qp;
+	rdi->driver_f.notify_error_qp = notify_error_qp;
+	rdi->driver_f.mtu_from_qp = mtu_from_qp;
+	rdi->driver_f.mtu_to_path_mtu = mtu_to_path_mtu;
+	rdi->driver_f.check_modify_qp = hfi1_check_modify_qp;
+	rdi->driver_f.modify_qp = hfi1_modify_qp;
+	rdi->driver_f.check_send_wqe = hfi1_check_send_wqe;
 
 	/* completeion queue */
-	snprintf(dd->verbs_dev.rdi.dparms.cq_name,
-		 sizeof(dd->verbs_dev.rdi.dparms.cq_name),
+	snprintf(rdi->dparms.cq_name,
+		 sizeof(rdi->dparms.cq_name),
 		 "hfi1_cq%d", dd->unit);
-	dd->verbs_dev.rdi.dparms.node = dd->node;
+	rdi->dparms.node = dd->node;
 
 	/* misc settings */
-	dd->verbs_dev.rdi.flags = 0; /* Let rdmavt handle it all */
-	dd->verbs_dev.rdi.dparms.lkey_table_size = hfi1_lkey_table_size;
-	dd->verbs_dev.rdi.dparms.nports = dd->num_pports;
-	dd->verbs_dev.rdi.dparms.npkeys = hfi1_get_npkeys(dd);
+	rdi->flags = 0; /* Let rdmavt handle it all */
+	rdi->dparms.lkey_table_size = hfi1_lkey_table_size;
+	rdi->dparms.nports = dd->num_pports;
+	rdi->dparms.npkeys = hfi1_get_npkeys(dd);
 
 	/* post send table */
-	dd->verbs_dev.rdi.post_parms = hfi1_post_parms;
+	rdi->post_parms = hfi1_post_parms;
 
 	ppd = dd->pport;
 	for (i = 0; i < dd->num_pports; i++, ppd++)
-		rvt_init_port(&dd->verbs_dev.rdi,
+		rvt_init_port(rdi,
 			      &ppd->ibport_data.rvp,
 			      i,
 			      ppd->pkeys);
 
-	ret = rvt_register_device(&dd->verbs_dev.rdi);
+	ret = rvt_register_device(rdi);
 	if (ret)
 		goto err_verbs_txreq;
 
@@ -1880,7 +1881,7 @@ int hfi1_register_ib_device(struct hfi1_devdata *dd)
 	return ret;
 
 err_class:
-	rvt_unregister_device(&dd->verbs_dev.rdi);
+	rvt_unregister_device(rdi);
 err_verbs_txreq:
 	verbs_txreq_exit(dev);
 	dd_dev_err(dd, "cannot register verbs: %d!\n", -ret);
@@ -1893,7 +1894,7 @@ void hfi1_unregister_ib_device(struct hfi1_devdata *dd)
 
 	hfi1_verbs_unregister_sysfs(dd);
 
-	rvt_unregister_device(&dd->verbs_dev.rdi);
+	rvt_unregister_device(&dd->verbs_dev.hfidev.rdi);
 
 	if (!list_empty(&dev->txwait))
 		dd_dev_err(dd, "txwait list not empty!\n");
diff --git a/drivers/infiniband/hw/hfi1/verbs.h b/drivers/infiniband/hw/hfi1/verbs.h
index e6b8930..72412ed 100644
--- a/drivers/infiniband/hw/hfi1/verbs.h
+++ b/drivers/infiniband/hw/hfi1/verbs.h
@@ -64,6 +64,7 @@
 #include <rdma/rdma_vt.h>
 #include <rdma/rdmavt_qp.h>
 #include <rdma/rdmavt_cq.h>
+#include <rdma/opa_hfi.h>
 
 struct hfi1_ctxtdata;
 struct hfi1_pportdata;
@@ -174,7 +175,7 @@ struct hfi1_ibport {
 };
 
 struct hfi1_ibdev {
-	struct rvt_dev_info rdi; /* Must be first */
+	struct hfi_ibdev hfidev; /* Must be first */
 
 	/* QP numbers are shared by all IB ports */
 	/* protect txwait list */
@@ -201,10 +202,10 @@ struct hfi1_ibdev {
 
 static inline struct hfi1_ibdev *to_idev(struct ib_device *ibdev)
 {
-	struct rvt_dev_info *rdi;
+	struct hfi_ibdev *hfidev;
 
-	rdi = container_of(ibdev, struct rvt_dev_info, ibdev);
-	return container_of(rdi, struct hfi1_ibdev, rdi);
+	hfidev = to_hfi_ibdev(ibdev);
+	return container_of(hfidev, struct hfi1_ibdev, hfidev);
 }
 
 static inline struct rvt_qp *iowait_to_qp(struct  iowait *s_iowait)
diff --git a/include/rdma/opa_hfi.h b/include/rdma/opa_hfi.h
new file mode 100644
index 0000000..ef61d65
--- /dev/null
+++ b/include/rdma/opa_hfi.h
@@ -0,0 +1,199 @@
+#ifndef _OPA_HFI_H
+#define _OPA_HFI_H
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains Intel Omni-Path (OPA) Host Fabric Interface (HFI)
+ * specific declarations.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/module.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_vt.h>
+
+/* Maximum possible number of VNICs */
+#define HFI_MAX_NUM_VNICS     255
+
+#define HFI_VNIC_MAX_QUEUE    16
+
+#define HFI_VNIC_CAP_SG   BIT(0)
+
+enum {
+	/* Packet received on queue 0 */
+	HFI_VNIC_EVT_RX0,
+	/* Tx wakeup notification on queue 0 */
+	HFI_VNIC_EVT_TX0
+		= HFI_VNIC_EVT_RX0 + HFI_VNIC_MAX_QUEUE,
+	HFI_VNIC_NUM_EVTS
+		= HFI_VNIC_EVT_TX0 + HFI_VNIC_MAX_QUEUE,
+};
+
+struct hfi_vnic_port;
+
+typedef void (*hfi_vnic_evt_cb_fn)(struct hfi_vnic_port *vport, u8 evt);
+
+/**
+ * struct hfi_vnic_ops - HFI HW specific VNIC functions
+ * @open: Open the vnic port
+ * @close: Close the vnic port
+ * @put_skb: transmit an skb
+ * @get_skb: receive an skb
+ * @get_read_avail: return number of available to read
+ * @get_write_avail: return whether write space is available or not
+ * @select_queue: select tx queue
+ * @config_notify: enable/disable notification
+ */
+struct hfi_vnic_ops {
+	int (*open)(struct hfi_vnic_port *vport,
+		    hfi_vnic_evt_cb_fn cb);
+	void (*close)(struct hfi_vnic_port *vport);
+	int (*put_skb)(struct hfi_vnic_port *vport,
+		       u8 q_idx, struct sk_buff *skb);
+	struct sk_buff *(*get_skb)(struct hfi_vnic_port *vport, u8 q_idx);
+	u16 (*get_read_avail)(struct hfi_vnic_port *vport, u8 q_idx);
+	bool (*get_write_avail)(struct hfi_vnic_port *vport, u8 q_idx);
+	u8 (*select_queue)(struct hfi_vnic_port *vport, u8 vl, u8 entropy);
+	void (*config_notify)(struct hfi_vnic_port *vport,
+			      u8 evt, bool enable);
+};
+
+/**
+ * struct hfi_vnic_stats - HFI HW specific statistics
+ * @rx_fifo_errors: receive packets dropped due to fifo full
+ * @tx_fifo_errors: transmit packets dropped due to fifo full
+ * @rx_missed_errors: receive packets missed due to no memory
+ * @tx_carrier_errors: packet transmits when STL link is down
+ * @rx_bad_veswid: receive packets with invalid vesw id
+ * @rx_logic_errors: receive packets dropped due to other errors
+ * @tx_logic_errors: transmit packets dropped due to other errors
+ *
+ * This structure holds any statistics information that is
+ * collected by HW specific driver layer.
+ */
+struct hfi_vnic_stats {
+	u64  rx_fifo_errors;
+	u64  tx_fifo_errors;
+	u64  rx_missed_errors;
+	u64  tx_carrier_errors;
+	u64  rx_bad_veswid;
+	u64  rx_logic_errors;
+	u64  tx_logic_errors;
+};
+
+/**
+ * struct hfi_vnic_info - HFI HW specific VNIC information
+ * @cap: capabilities
+ * @num_rx_q: number of receive queues
+ * @num_tx_q: number of transmit queues
+ */
+struct hfi_vnic_info {
+	u32  cap;
+	u8   num_rx_q;
+	u8   num_tx_q;
+};
+
+/**
+ * struct hfi_vnic_port - HFI virtual NIC port
+ * @vesw_id: virtual ethernet switch id
+ * @netdev: pointer to associated netdev
+ * @port_num: hfi port instance
+ * @vport_num: vnic port instance on the hfi port
+ * @ops: hfi vnic operations
+ * @hfi_priv: hfi private data pointer
+ * @hfi_info: hfi information
+ * @hfi_stats: per queue hfi statistics
+ */
+struct hfi_vnic_port {
+	u16                          vesw_id;
+	struct net_device           *netdev;
+	u8                           port_num;
+	u8                           vport_num;
+
+	struct hfi_vnic_ops         *ops;
+	void                        *hfi_priv;
+	struct hfi_vnic_info         hfi_info;
+	struct hfi_vnic_stats        hfi_stats[HFI_VNIC_MAX_QUEUE];
+};
+
+/**
+ * struct hfi_vnic_ctrl_ops - HFI HW specific VNIC control functions
+ * @add_vport: add a vnic port
+ * @rem_vport: remove a vnic port
+ */
+struct hfi_vnic_ctrl_ops {
+	struct hfi_vnic_port *(*add_vport)(struct ib_device *device,
+					   u8 port_num, u8 vport_num);
+	void (*rem_vport)(struct hfi_vnic_port *vport);
+};
+
+/**
+ * struct hfi_ibdev - HFI extension of rdmavt device
+ * @rdi: rdmavt device interface
+ * @vnic_ctrl_ops: VNIC control operations
+ */
+struct hfi_ibdev {
+	struct rvt_dev_info rdi; /* Must be first */
+
+	struct hfi_vnic_ctrl_ops vnic_ctrl_ops;
+};
+
+static inline struct hfi_ibdev *to_hfi_ibdev(struct ib_device *ibdev)
+{
+	struct rvt_dev_info *rdi;
+
+	rdi = container_of(ibdev, struct rvt_dev_info, ibdev);
+	return container_of(rdi, struct hfi_ibdev, rdi);
+}
+
+static inline bool is_hfi_ibdev(struct ib_device *ibdev)
+{
+	return !memcmp(ibdev->name, "hfi", 3);
+}
+
+#endif /* _OPA_HFI_H */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
