From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 07/15] drivers/net/cnic.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:54 -0800
Message-ID: <abc8f90b86adf40514e06b9e5fe9a1483c09630a.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1057 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842Ab0BRBCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:11 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Remove periods from formats
Coalesce long formats
Use __func__

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cnic.c |   87 ++++++++++++++++++++++------------------------------
 1 files changed, 37 insertions(+), 50 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4332b3a..6aecef9 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -10,6 +10,8 @@
  * Modified and maintained by: Michael Chan <mchan@broadcom.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -47,7 +49,6 @@
 #include "cnic_defs.h"
 
 #define DRV_MODULE_NAME		"cnic"
-#define PFX DRV_MODULE_NAME	": "
 
 static char version[] __devinitdata =
 	"Broadcom NetXtreme II CNIC Driver " DRV_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
@@ -409,14 +410,13 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 	struct cnic_dev *dev;
 
 	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
-		printk(KERN_ERR PFX "cnic_register_driver: Bad type %d\n",
-		       ulp_type);
+		pr_err("%s: Bad type %d\n", __func__, ulp_type);
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
 	if (cnic_ulp_tbl[ulp_type]) {
-		printk(KERN_ERR PFX "cnic_register_driver: Type %d has already "
-				    "been registered\n", ulp_type);
+		pr_err("%s: Type %d has already been registered\n",
+		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
 		return -EBUSY;
 	}
@@ -455,15 +455,14 @@ int cnic_unregister_driver(int ulp_type)
 	int i = 0;
 
 	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
-		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
-		       ulp_type);
+		pr_err("%s: Bad type %d\n", __func__, ulp_type);
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
 	ulp_ops = cnic_ulp_tbl[ulp_type];
 	if (!ulp_ops) {
-		printk(KERN_ERR PFX "cnic_unregister_driver: Type %d has not "
-				    "been registered\n", ulp_type);
+		pr_err("%s: Type %d has not been registered\n",
+		       __func__, ulp_type);
 		goto out_unlock;
 	}
 	read_lock(&cnic_dev_lock);
@@ -471,8 +470,8 @@ int cnic_unregister_driver(int ulp_type)
 		struct cnic_local *cp = dev->cnic_priv;
 
 		if (rcu_dereference(cp->ulp_ops[ulp_type])) {
-			printk(KERN_ERR PFX "cnic_unregister_driver: Type %d "
-			       "still has devices registered\n", ulp_type);
+			pr_err("%s: Type %d still has devices registered\n",
+			       __func__, ulp_type);
 			read_unlock(&cnic_dev_lock);
 			goto out_unlock;
 		}
@@ -492,8 +491,7 @@ int cnic_unregister_driver(int ulp_type)
 	}
 
 	if (atomic_read(&ulp_ops->ref_count) != 0)
-		printk(KERN_WARNING PFX "%s: Failed waiting for ref count to go"
-					" to zero.\n", dev->netdev->name);
+		netdev_warn(dev->netdev, "Failed waiting for ref count to go to zero\n");
 	return 0;
 
 out_unlock:
@@ -511,20 +509,19 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
 	struct cnic_ulp_ops *ulp_ops;
 
 	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
-		printk(KERN_ERR PFX "cnic_register_device: Bad type %d\n",
-		       ulp_type);
+		pr_err("%s: Bad type %d\n", __func__, ulp_type);
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
 	if (cnic_ulp_tbl[ulp_type] == NULL) {
-		printk(KERN_ERR PFX "cnic_register_device: Driver with type %d "
-				    "has not been registered\n", ulp_type);
+		pr_err("%s: Driver with type %d has not been registered\n",
+		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
 		return -EAGAIN;
 	}
 	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
-		printk(KERN_ERR PFX "cnic_register_device: Type %d has already "
-		       "been registered to this device\n", ulp_type);
+		pr_err("%s: Type %d has already been registered to this device\n",
+		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
 		return -EBUSY;
 	}
@@ -552,8 +549,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 	int i = 0;
 
 	if (ulp_type < 0 || ulp_type >= MAX_CNIC_ULP_TYPE) {
-		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
-		       ulp_type);
+		pr_err("%s: Bad type %d\n", __func__, ulp_type);
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
@@ -561,8 +557,8 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 		rcu_assign_pointer(cp->ulp_ops[ulp_type], NULL);
 		cnic_put(dev);
 	} else {
-		printk(KERN_ERR PFX "cnic_unregister_device: device not "
-		       "registered to this ulp type %d\n", ulp_type);
+		pr_err("%s: device not registered to this ulp type %d\n",
+		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
 		return -EINVAL;
 	}
@@ -576,8 +572,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 		i++;
 	}
 	if (test_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[ulp_type]))
-		printk(KERN_WARNING PFX "%s: Failed waiting for ULP up call"
-					" to complete.\n", dev->netdev->name);
+		netdev_warn(dev->netdev, "Failed waiting for ULP up call to complete\n");
 
 	return 0;
 }
@@ -1865,8 +1860,7 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 	}
 
 	if (sizeof(*conn_buf) > CNIC_KWQ16_DATA_SIZE) {
-		printk(KERN_ERR PFX "%s: conn_buf size too big\n",
-			       dev->netdev->name);
+		netdev_err(dev->netdev, "conn_buf size too big\n");
 		return -ENOMEM;
 	}
 	conn_buf = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
@@ -2026,13 +2020,13 @@ static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
 			break;
 		default:
 			ret = 0;
-			printk(KERN_ERR PFX "%s: Unknown type of KWQE(0x%x)\n",
-			       dev->netdev->name, opcode);
+			netdev_err(dev->netdev, "Unknown type of KWQE(0x%x)\n",
+				   opcode);
 			break;
 		}
 		if (ret < 0)
-			printk(KERN_ERR PFX "%s: KWQE(0x%x) failed\n",
-			       dev->netdev->name, opcode);
+			netdev_err(dev->netdev, "KWQE(0x%x) failed\n",
+				   opcode);
 		i += work;
 	}
 	return 0;
@@ -2074,8 +2068,8 @@ static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 		else if (kcqe_layer == KCQE_FLAGS_LAYER_MASK_L2)
 			goto end;
 		else {
-			printk(KERN_ERR PFX "%s: Unknown type of KCQE(0x%x)\n",
-			       dev->netdev->name, kcqe_op_flag);
+			netdev_err(dev->netdev, "Unknown type of KCQE(0x%x)\n",
+				   kcqe_op_flag);
 			goto end;
 		}
 
@@ -3435,8 +3429,7 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 	return 0;
 
 failed:
-	printk(KERN_ERR PFX "%s: " "KCQ index not resetting to 0.\n",
-	       dev->netdev->name);
+	netdev_err(dev->netdev, "KCQ index not resetting to 0\n");
 	return -EBUSY;
 }
 
@@ -3758,8 +3751,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 
 	err = cnic_init_bnx2_irq(dev);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cnic_init_irq failed\n",
-		       dev->netdev->name);
+		netdev_err(dev->netdev, "cnic_init_irq failed\n");
 		cnic_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 0);
 		cnic_reg_wr_ind(dev, BNX2_COM_SCRATCH + 0x20, 0);
 		return err;
@@ -4122,8 +4114,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 			   offsetof(struct cstorm_status_block_c,
 				    index_values[HC_INDEX_C_ISCSI_EQ_CONS]));
 	if (eq_idx != 0) {
-		printk(KERN_ERR PFX "%s: EQ cons index %x != 0\n",
-		       dev->netdev->name, eq_idx);
+		netdev_err(dev->netdev, "EQ cons index %x != 0\n", eq_idx);
 		return -EBUSY;
 	}
 	ret = cnic_init_bnx2x_irq(dev);
@@ -4208,8 +4199,7 @@ static int cnic_register_netdev(struct cnic_dev *dev)
 
 	err = ethdev->drv_register_cnic(dev->netdev, cp->cnic_ops, dev);
 	if (err)
-		printk(KERN_ERR PFX "%s: register_cnic failed\n",
-		       dev->netdev->name);
+		netdev_err(dev->netdev, "register_cnic failed\n");
 
 	return err;
 }
@@ -4243,8 +4233,7 @@ static int cnic_start_hw(struct cnic_dev *dev)
 
 	err = cp->alloc_resc(dev);
 	if (err) {
-		printk(KERN_ERR PFX "%s: allocate resource failure\n",
-		       dev->netdev->name);
+		netdev_err(dev->netdev, "allocate resource failure\n");
 		goto err1;
 	}
 
@@ -4326,10 +4315,9 @@ static void cnic_free_dev(struct cnic_dev *dev)
 		i++;
 	}
 	if (atomic_read(&dev->ref_count) != 0)
-		printk(KERN_ERR PFX "%s: Failed waiting for ref count to go"
-				    " to zero.\n", dev->netdev->name);
+		netdev_err(dev->netdev, "Failed waiting for ref count to go to zero\n");
 
-	printk(KERN_INFO PFX "Removed CNIC device: %s\n", dev->netdev->name);
+	netdev_info(dev->netdev, "Removed CNIC device\n");
 	dev_put(dev->netdev);
 	kfree(dev);
 }
@@ -4345,8 +4333,7 @@ static struct cnic_dev *cnic_alloc_dev(struct net_device *dev,
 
 	cdev = kzalloc(alloc_size , GFP_KERNEL);
 	if (cdev == NULL) {
-		printk(KERN_ERR PFX "%s: allocate dev struct failure\n",
-		       dev->name);
+		netdev_err(dev, "allocate dev struct failure\n");
 		return NULL;
 	}
 
@@ -4364,7 +4351,7 @@ static struct cnic_dev *cnic_alloc_dev(struct net_device *dev,
 
 	spin_lock_init(&cp->cnic_ulp_lock);
 
-	printk(KERN_INFO PFX "Added CNIC device: %s\n", dev->name);
+	netdev_info(dev, "Added CNIC device\n");
 
 	return cdev;
 }
@@ -4605,7 +4592,7 @@ static int __init cnic_init(void)
 {
 	int rc = 0;
 
-	printk(KERN_INFO "%s", version);
+	pr_info("%s", version);
 
 	rc = register_netdevice_notifier(&cnic_netdev_notifier);
 	if (rc) {
-- 
1.7.0.14.g7e948

