From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V3 03/21] bnxt_re: register with the NIC driver
Date: Tue, 20 Dec 2016 01:13:13 -0800
Message-ID: <1482225211-22423-4-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34592 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932313AbcLTJOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 04:14:03 -0500
Received: by mail-qk0-f177.google.com with SMTP id q68so42199766qki.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 01:14:03 -0800 (PST)
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch handles the registration with the bnxt_en driver.
The bnxt_re driver first registers with netdev notifier chain and upon
receiving the NETDEV_REGISTER event, it registers with bnxt_en driver.

	1. bnxt_en's ulp_probe function returns a structure that contains
	   information 	about the device and additional entry points.
	2. bnxt_en driver returns 'struct bnxt_eth_dev' that contains set
	   of operation  vectors that bnxt_re driver invokes later.
	3. bnxt_request_msix() allows the bnxt_re driver to specify the
	   number of MSI-X vectors that are needed.
	4. bnxt_send_fw_msg () is used to send messages to the FW
	5. bnxt_register_async_events() is used to register for async
	   event callbacks.

v2: Remove some sparse warning. Also, remove some unused code from unreg
    path.
v3: Removed condition checks for rdev reported during static code analysis.
    Check the return value of try_module_get while getting bnxt_en
    reference.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_re.h      |  51 ++++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c | 448 ++++++++++++++++++++++++++++
 2 files changed, 499 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index f9b8542..8b73e3d 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -42,5 +42,56 @@
 #define ROCE_DRV_MODULE_NAME		"bnxt_re"
 #define ROCE_DRV_MODULE_VERSION		"1.0.0"
 
+#define BNXT_RE_REF_WAIT_COUNT		10
 #define BNXT_RE_DESC	"Broadcom NetXtreme-C/E RoCE Driver"
+
+struct bnxt_re_work {
+	struct work_struct	work;
+	unsigned long		event;
+	struct bnxt_re_dev      *rdev;
+	struct net_device	*vlan_dev;
+};
+
+#define BNXT_RE_MIN_MSIX		2
+#define BNXT_RE_MAX_MSIX		16
+struct bnxt_re_dev {
+	struct ib_device		ibdev;
+	struct list_head		list;
+	atomic_t			ref_count;
+	unsigned long			flags;
+#define BNXT_RE_FLAG_NETDEV_REGISTERED	0
+#define BNXT_RE_FLAG_IBDEV_REGISTERED	1
+#define BNXT_RE_FLAG_GOT_MSIX		2
+#define BNXT_RE_FLAG_RCFW_CHANNEL_EN	8
+#define BNXT_RE_FLAG_QOS_WORK_REG	16
+	struct net_device		*netdev;
+	unsigned int			version, major, minor;
+	struct bnxt_en_dev		*en_dev;
+	struct bnxt_msix_entry		msix_entries[BNXT_RE_MAX_MSIX];
+	int				num_msix;
+
+	int				id;
+
+	atomic_t			qp_count;
+	struct mutex			qp_lock;	/* protect qp list */
+	struct list_head		qp_list;
+
+	atomic_t			cq_count;
+	atomic_t			srq_count;
+	atomic_t			mr_count;
+	atomic_t			mw_count;
+	/* Max of 2 lossless traffic class supported per port */
+	u16				cosq[2];
+};
+
+#define to_bnxt_re_dev(ptr, member)	\
+	container_of((ptr), struct bnxt_re_dev, member)
+
+static inline struct device *rdev_to_dev(struct bnxt_re_dev *rdev)
+{
+	if (rdev)
+		return  &rdev->ibdev.dev;
+	return NULL;
+}
+
 #endif
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 6c22d51..fbd2ad3 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -38,10 +38,24 @@
 
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <linux/mutex.h>
 #include <linux/list.h>
 #include <linux/rculist.h>
+#include <linux/spinlock.h>
+#include <linux/pci.h>
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_user_verbs.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_addr.h>
+
+#include "bnxt_ulp.h"
+#include "bnxt_re_hsi.h"
 #include "bnxt_re.h"
+#include "bnxt.h"
 static char version[] =
 		BNXT_RE_DESC " v" ROCE_DRV_MODULE_VERSION "\n";
 
@@ -55,6 +69,384 @@ static struct list_head bnxt_re_dev_list = LIST_HEAD_INIT(bnxt_re_dev_list);
 /* Mutex to protect the list of bnxt_re devices added */
 static DEFINE_MUTEX(bnxt_re_dev_lock);
 static struct workqueue_struct *bnxt_re_wq;
+
+/* for handling bnxt_en callbacks later */
+static void bnxt_re_stop(void *p)
+{
+}
+
+static void bnxt_re_start(void *p)
+{
+}
+
+static void bnxt_re_sriov_config(void *p, int num_vfs)
+{
+}
+
+static struct bnxt_ulp_ops bnxt_re_ulp_ops = {
+	.ulp_async_notifier = NULL,
+	.ulp_stop = bnxt_re_stop,
+	.ulp_start = bnxt_re_start,
+	.ulp_sriov_config = bnxt_re_sriov_config
+};
+
+/* The rdev ref_count is to protect immature removal of the device */
+static inline void bnxt_re_hold(struct bnxt_re_dev *rdev)
+{
+	atomic_inc(&rdev->ref_count);
+}
+
+static inline void bnxt_re_put(struct bnxt_re_dev *rdev)
+{
+	atomic_dec(&rdev->ref_count);
+}
+
+/* RoCE -> Net driver */
+
+/* Driver registration routines used to let the networking driver (bnxt_en)
+ * to know that the RoCE driver is now installed
+ */
+static int bnxt_re_unregister_netdev(struct bnxt_re_dev *rdev, bool lock_wait)
+{
+	struct bnxt_en_dev *en_dev;
+	int rc;
+
+	if (!rdev)
+		return -EINVAL;
+
+	en_dev = rdev->en_dev;
+	/* Acquire rtnl lock if it is not invokded from netdev event */
+	if (lock_wait)
+		rtnl_lock();
+
+	rc = en_dev->en_ops->bnxt_unregister_device(rdev->en_dev,
+						    BNXT_ROCE_ULP);
+	if (lock_wait)
+		rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_register_netdev(struct bnxt_re_dev *rdev)
+{
+	struct bnxt_en_dev *en_dev;
+	int rc = 0;
+
+	if (!rdev)
+		return -EINVAL;
+
+	en_dev = rdev->en_dev;
+
+	rtnl_lock();
+	rc = en_dev->en_ops->bnxt_register_device(en_dev, BNXT_ROCE_ULP,
+						  &bnxt_re_ulp_ops, rdev);
+	rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_free_msix(struct bnxt_re_dev *rdev, bool lock_wait)
+{
+	struct bnxt_en_dev *en_dev;
+	int rc;
+
+	if (!rdev)
+		return -EINVAL;
+
+	en_dev = rdev->en_dev;
+
+	if (lock_wait)
+		rtnl_lock();
+
+	rc = en_dev->en_ops->bnxt_free_msix(rdev->en_dev, BNXT_ROCE_ULP);
+
+	if (lock_wait)
+		rtnl_unlock();
+	return rc;
+}
+
+static int bnxt_re_request_msix(struct bnxt_re_dev *rdev)
+{
+	int rc = 0, num_msix_want = BNXT_RE_MIN_MSIX, num_msix_got;
+	struct bnxt_en_dev *en_dev;
+
+	if (!rdev)
+		return -EINVAL;
+
+	en_dev = rdev->en_dev;
+
+	rtnl_lock();
+	num_msix_got = en_dev->en_ops->bnxt_request_msix(en_dev, BNXT_ROCE_ULP,
+							 rdev->msix_entries,
+							 num_msix_want);
+	if (num_msix_got < BNXT_RE_MIN_MSIX) {
+		rc = -EINVAL;
+		goto done;
+	}
+	if (num_msix_got != num_msix_want) {
+		dev_warn(rdev_to_dev(rdev),
+			 "Requested %d MSI-X vectors, got %d\n",
+			 num_msix_want, num_msix_got);
+	}
+	rdev->num_msix = num_msix_got;
+done:
+	rtnl_unlock();
+	return rc;
+}
+
+/* Device */
+
+static bool is_bnxt_re_dev(struct net_device *netdev)
+{
+	struct ethtool_drvinfo drvinfo;
+
+	if (netdev->ethtool_ops && netdev->ethtool_ops->get_drvinfo) {
+		memset(&drvinfo, 0, sizeof(drvinfo));
+		netdev->ethtool_ops->get_drvinfo(netdev, &drvinfo);
+
+		if (strcmp(drvinfo.driver, "bnxt_en"))
+			return false;
+		return true;
+	}
+	return false;
+}
+
+static struct bnxt_re_dev *bnxt_re_from_netdev(struct net_device *netdev)
+{
+	struct bnxt_re_dev *rdev;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(rdev, &bnxt_re_dev_list, list) {
+		if (rdev->netdev == netdev) {
+			rcu_read_unlock();
+			return rdev;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
+
+static void bnxt_re_dev_unprobe(struct net_device *netdev,
+				struct bnxt_en_dev *en_dev)
+{
+	dev_put(netdev);
+	module_put(en_dev->pdev->driver->driver.owner);
+}
+
+static struct bnxt_en_dev *bnxt_re_dev_probe(struct net_device *netdev)
+{
+	struct bnxt *bp = netdev_priv(netdev);
+	struct bnxt_en_dev *en_dev;
+	struct pci_dev *pdev;
+
+	/* Call bnxt_en's RoCE probe via indirect API */
+	if (!bp->ulp_probe)
+		return ERR_PTR(-EINVAL);
+
+	en_dev = bp->ulp_probe(netdev);
+	if (IS_ERR(en_dev))
+		return en_dev;
+
+	pdev = en_dev->pdev;
+	if (!pdev)
+		return ERR_PTR(-EINVAL);
+
+	/* Bump net device reference count */
+	if (!try_module_get(pdev->driver->driver.owner))
+		return ERR_PTR(-ENODEV);
+
+	dev_hold(netdev);
+
+	return en_dev;
+}
+
+static void bnxt_re_dev_remove(struct bnxt_re_dev *rdev)
+{
+	int i = BNXT_RE_REF_WAIT_COUNT;
+
+	/* Wait for rdev refcount to come down */
+	while ((atomic_read(&rdev->ref_count) > 1) && i--)
+		msleep(100);
+
+	if (atomic_read(&rdev->ref_count) > 1)
+		dev_err(rdev_to_dev(rdev),
+			"Failed waiting for ref count to deplete %d",
+			atomic_read(&rdev->ref_count));
+
+	atomic_set(&rdev->ref_count, 0);
+	dev_put(rdev->netdev);
+	rdev->netdev = NULL;
+
+	mutex_lock(&bnxt_re_dev_lock);
+	list_del_rcu(&rdev->list);
+	mutex_unlock(&bnxt_re_dev_lock);
+
+	synchronize_rcu();
+	flush_workqueue(bnxt_re_wq);
+
+	ib_dealloc_device(&rdev->ibdev);
+	/* rdev is gone */
+}
+
+static struct bnxt_re_dev *bnxt_re_dev_add(struct net_device *netdev,
+					   struct bnxt_en_dev *en_dev)
+{
+	struct bnxt_re_dev *rdev;
+
+	/* Allocate bnxt_re_dev instance here */
+	rdev = (struct bnxt_re_dev *)ib_alloc_device(sizeof(*rdev));
+	if (!rdev) {
+		dev_err(NULL, "%s: bnxt_re_dev allocation failure!",
+			ROCE_DRV_MODULE_NAME);
+		return NULL;
+	}
+	/* Default values */
+	atomic_set(&rdev->ref_count, 0);
+	rdev->netdev = netdev;
+	dev_hold(rdev->netdev);
+	rdev->en_dev = en_dev;
+	rdev->id = rdev->en_dev->pdev->devfn;
+	INIT_LIST_HEAD(&rdev->qp_list);
+	mutex_init(&rdev->qp_lock);
+	atomic_set(&rdev->qp_count, 0);
+	atomic_set(&rdev->cq_count, 0);
+	atomic_set(&rdev->srq_count, 0);
+	atomic_set(&rdev->mr_count, 0);
+	atomic_set(&rdev->mw_count, 0);
+	rdev->cosq[0] = 0xFFFF;
+	rdev->cosq[1] = 0xFFFF;
+
+	mutex_lock(&bnxt_re_dev_lock);
+	list_add_tail_rcu(&rdev->list, &bnxt_re_dev_list);
+	mutex_unlock(&bnxt_re_dev_lock);
+	return rdev;
+}
+
+static void bnxt_re_ib_unreg(struct bnxt_re_dev *rdev, bool lock_wait)
+{
+	int rc;
+
+	if (test_and_clear_bit(BNXT_RE_FLAG_GOT_MSIX, &rdev->flags)) {
+		rc = bnxt_re_free_msix(rdev, lock_wait);
+		if (rc)
+			dev_warn(rdev_to_dev(rdev),
+				 "Failed to free MSI-X vectors: %#x", rc);
+	}
+	if (test_and_clear_bit(BNXT_RE_FLAG_NETDEV_REGISTERED, &rdev->flags)) {
+		rc = bnxt_re_unregister_netdev(rdev, lock_wait);
+		if (rc)
+			dev_warn(rdev_to_dev(rdev),
+				 "Failed to unregister with netdev: %#x", rc);
+	}
+}
+
+static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
+{
+	int i, j, rc;
+
+	/* Registered a new RoCE device instance to netdev */
+	rc = bnxt_re_register_netdev(rdev);
+	if (rc) {
+		pr_err("Failed to register with netedev: %#x\n", rc);
+		return -EINVAL;
+	}
+	set_bit(BNXT_RE_FLAG_NETDEV_REGISTERED, &rdev->flags);
+
+	rc = bnxt_re_request_msix(rdev);
+	if (rc) {
+		pr_err("Failed to get MSI-X vectors: %#x\n", rc);
+		rc = -EINVAL;
+		goto fail;
+	}
+	set_bit(BNXT_RE_FLAG_GOT_MSIX, &rdev->flags);
+
+	return 0;
+fail:
+	bnxt_re_ib_unreg(rdev, true);
+	return rc;
+}
+
+static void bnxt_re_dev_unreg(struct bnxt_re_dev *rdev)
+{
+	struct bnxt_en_dev *en_dev = rdev->en_dev;
+	struct net_device *netdev = rdev->netdev;
+
+	bnxt_re_dev_remove(rdev);
+
+	if (netdev)
+		bnxt_re_dev_unprobe(netdev, en_dev);
+}
+
+static int bnxt_re_dev_reg(struct bnxt_re_dev **rdev, struct net_device *netdev)
+{
+	struct bnxt_en_dev *en_dev;
+	int rc = 0;
+
+	if (!is_bnxt_re_dev(netdev))
+		return -ENODEV;
+
+	en_dev = bnxt_re_dev_probe(netdev);
+	if (IS_ERR(en_dev)) {
+		pr_err("%s: Failed to probe\n", ROCE_DRV_MODULE_NAME);
+		rc = PTR_ERR(en_dev);
+		goto exit;
+	}
+	*rdev = bnxt_re_dev_add(netdev, en_dev);
+	if (!*rdev) {
+		rc = -ENOMEM;
+		bnxt_re_dev_unprobe(netdev, en_dev);
+		goto exit;
+	}
+	bnxt_re_hold(*rdev);
+exit:
+	return rc;
+}
+
+static void bnxt_re_remove_one(struct bnxt_re_dev *rdev)
+{
+	pci_dev_put(rdev->en_dev->pdev);
+}
+
+/* Handle all deferred netevents tasks */
+static void bnxt_re_task(struct work_struct *work)
+{
+	struct bnxt_re_work *re_work;
+	struct bnxt_re_dev *rdev;
+	int rc = 0;
+
+	re_work = container_of(work, struct bnxt_re_work, work);
+	rdev = re_work->rdev;
+
+	if (re_work->event != NETDEV_REGISTER &&
+	    !test_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags))
+		return;
+
+	switch (re_work->event) {
+	case NETDEV_REGISTER:
+		rc = bnxt_re_ib_reg(rdev);
+		if (rc)
+			dev_err(rdev_to_dev(rdev),
+				"Failed to register with IB: %#x", rc);
+		break;
+	case NETDEV_UP:
+
+		break;
+	case NETDEV_DOWN:
+
+		break;
+
+	case NETDEV_CHANGE:
+
+		break;
+	default:
+		break;
+	}
+	kfree(re_work);
+}
+
+static void bnxt_re_init_one(struct bnxt_re_dev *rdev)
+{
+	pci_dev_get(rdev->en_dev->pdev);
+}
+
 /*
  * "Notifier chain callback can be invoked for the same chain from
  * different CPUs at the same time".
@@ -72,6 +464,62 @@ static struct workqueue_struct *bnxt_re_wq;
 static int bnxt_re_netdev_event(struct notifier_block *notifier,
 				unsigned long event, void *ptr)
 {
+	struct net_device *real_dev, *netdev = netdev_notifier_info_to_dev(ptr);
+	struct bnxt_re_work *re_work;
+	struct bnxt_re_dev *rdev;
+	int rc = 0;
+
+	real_dev = rdma_vlan_dev_real_dev(netdev);
+	if (!real_dev)
+		real_dev = netdev;
+
+	rdev = bnxt_re_from_netdev(real_dev);
+	if (!rdev && event != NETDEV_REGISTER)
+		goto exit;
+	if (real_dev != netdev)
+		goto exit;
+
+	if (rdev)
+		bnxt_re_hold(rdev);
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		if (rdev)
+			break;
+		rc = bnxt_re_dev_reg(&rdev, real_dev);
+		if (rc == -ENODEV)
+			break;
+		if (rc) {
+			pr_err("Failed to register with the device %s: %#x\n",
+			       real_dev->name, rc);
+			break;
+		}
+		bnxt_re_init_one(rdev);
+		goto sch_work;
+
+	case NETDEV_UNREGISTER:
+		bnxt_re_ib_unreg(rdev, false);
+		bnxt_re_remove_one(rdev);
+		bnxt_re_dev_unreg(rdev);
+		break;
+
+	default:
+sch_work:
+		/* Allocate for the deferred task */
+		re_work = kzalloc(sizeof(*re_work), GFP_ATOMIC);
+		if (!re_work)
+			break;
+
+		re_work->rdev = rdev;
+		re_work->event = event;
+		re_work->vlan_dev = (real_dev == netdev ? NULL : netdev);
+		INIT_WORK(&re_work->work, bnxt_re_task);
+		queue_work(bnxt_re_wq, &re_work->work);
+		break;
+	}
+	if (rdev)
+		bnxt_re_put(rdev);
+exit:
 	return NOTIFY_DONE;
 }
 
-- 
2.5.5
