From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC 17/19] RDMA/qedr: Add iWARP connection management qp related callbacks
Date: Mon, 26 Jun 2017 21:07:07 +0300
Message-ID: <1498500429-22557-18-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <michal.kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch implements the following iWARP callbacks:
qp_add_ref
qp_rem_ref
get_qp

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

---
 drivers/infiniband/hw/qedr/Makefile     |  2 +-
 drivers/infiniband/hw/qedr/main.c       | 10 ++++++
 drivers/infiniband/hw/qedr/qedr.h       |  5 ++-
 drivers/infiniband/hw/qedr/qedr_iw_cm.c | 57 +++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/qedr_iw_cm.h | 37 +++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.c      | 38 ++++++++++++++++++++--
 6 files changed, 145 insertions(+), 4 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/qedr_iw_cm.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr_iw_cm.h

diff --git a/drivers/infiniband/hw/qedr/Makefile b/drivers/infiniband/hw/qedr/Makefile
index 331a361..1c0bc4f 100644
--- a/drivers/infiniband/hw/qedr/Makefile
+++ b/drivers/infiniband/hw/qedr/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_INFINIBAND_QEDR) := qedr.o
 
-qedr-y := main.o verbs.o qedr_roce_cm.o
+qedr-y := main.o verbs.o qedr_roce_cm.o qedr_iw_cm.o
diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index ad227b5..ebac63f 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -39,12 +39,14 @@
 #include <linux/iommu.h>
 #include <linux/pci.h>
 #include <net/addrconf.h>
+#include <linux/idr.h>
 
 #include <linux/qed/qed_chain.h>
 #include <linux/qed/qed_if.h>
 #include "qedr.h"
 #include "verbs.h"
 #include <rdma/qedr-abi.h>
+#include "qedr_iw_cm.h"
 
 MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");
 MODULE_AUTHOR("QLogic Corporation");
@@ -143,6 +145,9 @@ int qedr_iw_register_device(struct qedr_dev *dev)
 	dev->ibdev.iwcm = kzalloc(sizeof(*dev->ibdev.iwcm), GFP_KERNEL);
 	if (!dev->ibdev.iwcm)
 		return -ENOMEM;
+	dev->ibdev.iwcm->add_ref = qedr_iw_qp_add_ref;
+	dev->ibdev.iwcm->rem_ref = qedr_iw_qp_rem_ref;
+	dev->ibdev.iwcm->get_qp = qedr_iw_get_qp;
 
 	memcpy(dev->ibdev.iwcm->ifname,
 	       dev->ndev->name, sizeof(dev->ibdev.iwcm->ifname));
@@ -315,6 +320,11 @@ static int qedr_alloc_resources(struct qedr_dev *dev)
 
 	spin_lock_init(&dev->sgid_lock);
 
+	if (IS_IWARP(dev)) {
+		spin_lock_init(&dev->idr_lock);
+		idr_init(&dev->qpidr);
+	}
+
 	/* Allocate Status blocks for CNQ */
 	dev->sb_array = kcalloc(dev->num_cnq, sizeof(*dev->sb_array),
 				GFP_KERNEL);
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 0c0a39a..5dd82d1 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -33,6 +33,7 @@
 #define __QEDR_H__
 
 #include <linux/pci.h>
+#include <linux/idr.h>
 #include <rdma/ib_addr.h>
 #include <linux/qed/qed_if.h>
 #include <linux/qed/qed_chain.h>
@@ -164,7 +165,8 @@ struct qedr_dev {
 	struct qedr_cq		*gsi_rqcq;
 	struct qedr_qp		*gsi_qp;
 	enum qed_rdma_type	rdma_type;
-
+	spinlock_t		idr_lock; /* Protect qpidr data-structure */
+	struct idr		qpidr;
 	unsigned long enet_state;
 };
 
@@ -399,6 +401,7 @@ struct qedr_qp {
 	/* Relevant to qps created from user space only (applications) */
 	struct qedr_userq usq;
 	struct qedr_userq urq;
+	atomic_t refcnt;
 };
 
 struct qedr_ah {
diff --git a/drivers/infiniband/hw/qedr/qedr_iw_cm.c b/drivers/infiniband/hw/qedr/qedr_iw_cm.c
new file mode 100644
index 0000000..8811dbc
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_iw_cm.c
@@ -0,0 +1,57 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2017  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include "qedr.h"
+void qedr_iw_qp_add_ref(struct ib_qp *ibqp)
+{
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+
+	atomic_inc(&qp->refcnt);
+}
+
+void qedr_iw_qp_rem_ref(struct ib_qp *ibqp)
+{
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+
+	if (atomic_dec_and_test(&qp->refcnt)) {
+		spin_lock_irq(&qp->dev->idr_lock);
+		idr_remove(&qp->dev->qpidr, qp->qp_id);
+		spin_unlock_irq(&qp->dev->idr_lock);
+		kfree(qp);
+	}
+}
+
+struct ib_qp *qedr_iw_get_qp(struct ib_device *ibdev, int qpn)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibdev);
+
+	return idr_find(&dev->qpidr, qpn);
+}
diff --git a/drivers/infiniband/hw/qedr/qedr_iw_cm.h b/drivers/infiniband/hw/qedr/qedr_iw_cm.h
new file mode 100644
index 0000000..ea6d17af
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_iw_cm.h
@@ -0,0 +1,37 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015-2017  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <rdma/iw_cm.h>
+void qedr_iw_qp_add_ref(struct ib_qp *qp);
+
+void qedr_iw_qp_rem_ref(struct ib_qp *qp);
+
+struct ib_qp *qedr_iw_get_qp(struct ib_device *dev, int qpn);
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index fc9ff13..cccae13 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -1272,6 +1272,7 @@ static void qedr_set_common_qp_params(struct qedr_dev *dev,
 				      struct ib_qp_init_attr *attrs)
 {
 	spin_lock_init(&qp->q_lock);
+	atomic_set(&qp->refcnt, 1);
 	qp->pd = pd;
 	qp->qp_type = attrs->qp_type;
 	qp->max_inline_data = attrs->cap.max_inline_data;
@@ -1342,6 +1343,33 @@ static inline void qedr_qp_user_print(struct qedr_dev *dev, struct qedr_qp *qp)
 		 qp->usq.buf_len, qp->urq.buf_addr, qp->urq.buf_len);
 }
 
+static int qedr_idr_add(struct qedr_dev *dev, void *ptr, u32 id)
+{
+	int rc;
+
+	if (!IS_IWARP(dev))
+		return 0;
+
+	idr_preload(GFP_KERNEL);
+	spin_lock_irq(&dev->idr_lock);
+
+	rc = idr_alloc(&dev->qpidr, ptr, id, id + 1, GFP_ATOMIC);
+
+	spin_unlock_irq(&dev->idr_lock);
+	idr_preload_end();
+
+	return rc < 0 ? rc : 0;
+}
+
+static void qedr_idr_remove(struct qedr_dev *dev, u32 id)
+{
+	if (!IS_IWARP(dev))
+		return;
+
+	spin_lock_irq(&dev->idr_lock);
+	idr_remove(&dev->qpidr, id);
+	spin_unlock_irq(&dev->idr_lock);
+}
 static void qedr_cleanup_user(struct qedr_dev *dev, struct qedr_qp *qp)
 {
 	if (qp->usq.umem)
@@ -1692,6 +1720,10 @@ struct ib_qp *qedr_create_qp(struct ib_pd *ibpd,
 
 	qp->ibqp.qp_num = qp->qp_id;
 
+	rc = qedr_idr_add(dev, qp, qp->qp_id);
+	if (rc)
+		goto err;
+
 	return &qp->ibqp;
 
 err:
@@ -2224,8 +2256,10 @@ int qedr_destroy_qp(struct ib_qp *ibqp)
 
 	qedr_free_qp_resources(dev, qp);
 
-	kfree(qp);
-
+	if (atomic_dec_and_test(&qp->refcnt)) {
+		qedr_idr_remove(dev, qp->qp_id);
+		kfree(qp);
+	}
 	return rc;
 }
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
