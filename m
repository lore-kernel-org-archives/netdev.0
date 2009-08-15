From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5] cnic: Fix locking in start/stop calls.
Date: Fri, 14 Aug 2009 18:49:46 -0700
Message-ID: <1250300987-18407-5-git-send-email-mchan@broadcom.com>
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

The slow path ulp_start and ulp_stop calls to the bnx2i driver
are sleepable calls and therefore should not be protected using
rcu_read_lock.  Fix it by using mutex and setting a bit during
these calls.  cnic_unregister_device() will now wait for the bit
to clear before completing the call.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |   44 ++++++++++++++++++++++++++++----------------
 drivers/net/cnic.h |    1 +
 2 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 2db81f0..4ff618a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -466,6 +466,7 @@ EXPORT_SYMBOL(cnic_register_driver);
 static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	int i = 0;
 
 	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
 		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
@@ -486,6 +487,15 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 
 	synchronize_rcu();
 
+	while (test_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[ulp_type]) &&
+	       i < 20) {
+		msleep(100);
+		i++;
+	}
+	if (test_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[ulp_type]))
+		printk(KERN_WARNING PFX "%s: Failed waiting for ULP up call"
+					" to complete.\n", dev->netdev->name);
+
 	return 0;
 }
 EXPORT_SYMBOL(cnic_unregister_driver);
@@ -1076,18 +1086,23 @@ static void cnic_ulp_stop(struct cnic_dev *dev)
 	if (cp->cnic_uinfo)
 		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 
-	rcu_read_lock();
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
 
-		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
-		if (!ulp_ops)
+		mutex_lock(&cnic_lock);
+		ulp_ops = cp->ulp_ops[if_type];
+		if (!ulp_ops) {
+			mutex_unlock(&cnic_lock);
 			continue;
+		}
+		set_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+		mutex_unlock(&cnic_lock);
 
 		if (test_and_clear_bit(ULP_F_START, &cp->ulp_flags[if_type]))
 			ulp_ops->cnic_stop(cp->ulp_handle[if_type]);
+
+		clear_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
 	}
-	rcu_read_unlock();
 }
 
 static void cnic_ulp_start(struct cnic_dev *dev)
@@ -1095,18 +1110,23 @@ static void cnic_ulp_start(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	int if_type;
 
-	rcu_read_lock();
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
 
-		ulp_ops = rcu_dereference(cp->ulp_ops[if_type]);
-		if (!ulp_ops || !ulp_ops->cnic_start)
+		mutex_lock(&cnic_lock);
+		ulp_ops = cp->ulp_ops[if_type];
+		if (!ulp_ops || !ulp_ops->cnic_start) {
+			mutex_unlock(&cnic_lock);
 			continue;
+		}
+		set_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
+		mutex_unlock(&cnic_lock);
 
 		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[if_type]))
 			ulp_ops->cnic_start(cp->ulp_handle[if_type]);
+
+		clear_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[if_type]);
 	}
-	rcu_read_unlock();
 }
 
 static int cnic_ctl(void *data, struct cnic_ctl_info *info)
@@ -1116,22 +1136,18 @@ static int cnic_ctl(void *data, struct cnic_ctl_info *info)
 	switch (info->cmd) {
 	case CNIC_CTL_STOP_CMD:
 		cnic_hold(dev);
-		mutex_lock(&cnic_lock);
 
 		cnic_ulp_stop(dev);
 		cnic_stop_hw(dev);
 
-		mutex_unlock(&cnic_lock);
 		cnic_put(dev);
 		break;
 	case CNIC_CTL_START_CMD:
 		cnic_hold(dev);
-		mutex_lock(&cnic_lock);
 
 		if (!cnic_start_hw(dev))
 			cnic_ulp_start(dev);
 
-		mutex_unlock(&cnic_lock);
 		cnic_put(dev);
 		break;
 	default:
@@ -2667,10 +2683,8 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 				cnic_put(dev);
 				goto done;
 			}
-			mutex_lock(&cnic_lock);
 			if (!cnic_start_hw(dev))
 				cnic_ulp_start(dev);
-			mutex_unlock(&cnic_lock);
 		}
 
 		rcu_read_lock();
@@ -2689,10 +2703,8 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 		rcu_read_unlock();
 
 		if (event == NETDEV_GOING_DOWN) {
-			mutex_lock(&cnic_lock);
 			cnic_ulp_stop(dev);
 			cnic_stop_hw(dev);
-			mutex_unlock(&cnic_lock);
 			cnic_unregister_netdev(dev);
 		} else if (event == NETDEV_UNREGISTER) {
 			write_lock(&cnic_dev_lock);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 5192d4a..a94b302 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -176,6 +176,7 @@ struct cnic_local {
 	unsigned long ulp_flags[MAX_CNIC_ULP_TYPE];
 #define ULP_F_INIT	0
 #define ULP_F_START	1
+#define ULP_F_CALL_PENDING	2
 	struct cnic_ulp_ops *ulp_ops[MAX_CNIC_ULP_TYPE];
 
 	/* protected by ulp_lock */
-- 
1.5.6.GIT


