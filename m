From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/5] cnic: Refine registration with bnx2.
Date: Fri, 14 Aug 2009 18:49:44 -0700
Message-ID: <1250300987-18407-3-git-send-email-mchan@broadcom.com>
References: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Register and unregister with bnx2 during NETDEV_UP and NETDEV_DOWN
events.  This simplifies the sequence of events and allows locking
fixes in the next patch.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |   49 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index ecde186..2db81f0 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2393,21 +2393,45 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	return 0;
 }
 
-static int cnic_start_hw(struct cnic_dev *dev)
+static int cnic_register_netdev(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	int err;
 
-	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
-		return -EALREADY;
+	if (!ethdev)
+		return -ENODEV;
+
+	if (ethdev->drv_state & CNIC_DRV_STATE_REGD)
+		return 0;
 
 	err = ethdev->drv_register_cnic(dev->netdev, cp->cnic_ops, dev);
-	if (err) {
+	if (err)
 		printk(KERN_ERR PFX "%s: register_cnic failed\n",
 		       dev->netdev->name);
-		goto err2;
-	}
+
+	return err;
+}
+
+static void cnic_unregister_netdev(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+
+	if (!ethdev)
+		return;
+
+	ethdev->drv_unregister_cnic(dev->netdev);
+}
+
+static int cnic_start_hw(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	int err;
+
+	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EALREADY;
 
 	dev->regview = ethdev->io_base;
 	cp->chip_id = ethdev->chip_id;
@@ -2438,18 +2462,13 @@ static int cnic_start_hw(struct cnic_dev *dev)
 	return 0;
 
 err1:
-	ethdev->drv_unregister_cnic(dev->netdev);
 	cp->free_resc(dev);
 	pci_dev_put(dev->pcidev);
-err2:
 	return err;
 }
 
 static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 {
-	struct cnic_local *cp = dev->cnic_priv;
-	struct cnic_eth_dev *ethdev = cp->ethdev;
-
 	cnic_disable_bnx2_int_sync(dev);
 
 	cnic_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 0);
@@ -2461,8 +2480,6 @@ static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 	cnic_setup_5709_context(dev, 0);
 	cnic_free_irq(dev);
 
-	ethdev->drv_unregister_cnic(dev->netdev);
-
 	cnic_free_resc(dev);
 }
 
@@ -2646,6 +2663,10 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 		else if (event == NETDEV_UNREGISTER)
 			cnic_ulp_exit(dev);
 		else if (event == NETDEV_UP) {
+			if (cnic_register_netdev(dev) != 0) {
+				cnic_put(dev);
+				goto done;
+			}
 			mutex_lock(&cnic_lock);
 			if (!cnic_start_hw(dev))
 				cnic_ulp_start(dev);
@@ -2672,6 +2693,7 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 			cnic_ulp_stop(dev);
 			cnic_stop_hw(dev);
 			mutex_unlock(&cnic_lock);
+			cnic_unregister_netdev(dev);
 		} else if (event == NETDEV_UNREGISTER) {
 			write_lock(&cnic_dev_lock);
 			list_del_init(&dev->list);
@@ -2703,6 +2725,7 @@ static void cnic_release(void)
 		}
 
 		cnic_ulp_exit(dev);
+		cnic_unregister_netdev(dev);
 		list_del_init(&dev->list);
 		cnic_free_dev(dev);
 	}
-- 
1.5.6.GIT


