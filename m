From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5] cnic: Fix locking in init/exit calls.
Date: Fri, 14 Aug 2009 18:49:47 -0700
Message-ID: <1250300987-18407-6-git-send-email-mchan@broadcom.com>
References: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1454 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755494AbZHOBnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 21:43:00 -0400
In-Reply-To: <1250300987-18407-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The slow path ulp_init and ulp_exit calls to the bnx2i driver
are sleepable calls and therefore should not be protected using
rcu_read_lock.  Fix it by using mutex and refcount during these
calls.  cnic_unregister_driver() will now wait for the refcount
to go to zero before completing the call.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c    |   48 +++++++++++++++++++++++++++++++++++++++---------
 drivers/net/cnic_if.h |    1 +
 2 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4ff618a..74c3429 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -138,6 +138,16 @@ static struct cnic_dev *cnic_from_netdev(struct net_device *netdev)
 	return NULL;
 }
 
+static inline void ulp_get(struct cnic_ulp_ops *ulp_ops)
+{
+	atomic_inc(&ulp_ops->ref_count);
+}
+
+static inline void ulp_put(struct cnic_ulp_ops *ulp_ops)
+{
+	atomic_dec(&ulp_ops->ref_count);
+}
+
 static void cnic_ctx_wr(struct cnic_dev *dev, u32 cid_addr, u32 off, u32 val)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -358,6 +368,7 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 	}
 	read_unlock(&cnic_dev_lock);
 
+	atomic_set(&ulp_ops->ref_count, 0);
 	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], ulp_ops);
 	mutex_unlock(&cnic_lock);
 
@@ -379,6 +390,8 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 int cnic_unregister_driver(int ulp_type)
 {
 	struct cnic_dev *dev;
+	struct cnic_ulp_ops *ulp_ops;
+	int i = 0;
 
 	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
 		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
@@ -386,7 +399,8 @@ int cnic_unregister_driver(int ulp_type)
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
-	if (!cnic_ulp_tbl[ulp_type]) {
+	ulp_ops = cnic_ulp_tbl[ulp_type];
+	if (!ulp_ops) {
 		printk(KERN_ERR PFX "cnic_unregister_driver: Type %d has not "
 				    "been registered\n", ulp_type);
 		goto out_unlock;
@@ -411,6 +425,14 @@ int cnic_unregister_driver(int ulp_type)
 
 	mutex_unlock(&cnic_lock);
 	synchronize_rcu();
+	while ((atomic_read(&ulp_ops->ref_count) != 0) && (i < 20)) {
+		msleep(100);
+		i++;
+	}
+
+	if (atomic_read(&ulp_ops->ref_count) != 0)
+		printk(KERN_WARNING PFX "%s: Failed waiting for ref count to go"
+					" to zero.\n", dev->netdev->name);
 	return 0;
 
 out_unlock:
@@ -1161,19 +1183,23 @@ static void cnic_ulp_init(struct cnic_dev *dev)
 	int i;
 	struct cnic_local *cp = dev->cnic_priv;
 
-	rcu_read_lock();
 	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
 		struct cnic_ulp_ops *ulp_ops;
 
-		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
-		if (!ulp_ops || !ulp_ops->cnic_init)
+		mutex_lock(&cnic_lock);
+		ulp_ops = cnic_ulp_tbl[i];
+		if (!ulp_ops || !ulp_ops->cnic_init) {
+			mutex_unlock(&cnic_lock);
 			continue;
+		}
+		ulp_get(ulp_ops);
+		mutex_unlock(&cnic_lock);
 
 		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[i]))
 			ulp_ops->cnic_init(dev);
 
+		ulp_put(ulp_ops);
 	}
-	rcu_read_unlock();
 }
 
 static void cnic_ulp_exit(struct cnic_dev *dev)
@@ -1181,19 +1207,23 @@ static void cnic_ulp_exit(struct cnic_dev *dev)
 	int i;
 	struct cnic_local *cp = dev->cnic_priv;
 
-	rcu_read_lock();
 	for (i = 0; i < MAX_CNIC_ULP_TYPE_EXT; i++) {
 		struct cnic_ulp_ops *ulp_ops;
 
-		ulp_ops = rcu_dereference(cnic_ulp_tbl[i]);
-		if (!ulp_ops || !ulp_ops->cnic_exit)
+		mutex_lock(&cnic_lock);
+		ulp_ops = cnic_ulp_tbl[i];
+		if (!ulp_ops || !ulp_ops->cnic_exit) {
+			mutex_unlock(&cnic_lock);
 			continue;
+		}
+		ulp_get(ulp_ops);
+		mutex_unlock(&cnic_lock);
 
 		if (test_and_clear_bit(ULP_F_INIT, &cp->ulp_flags[i]))
 			ulp_ops->cnic_exit(dev);
 
+		ulp_put(ulp_ops);
 	}
-	rcu_read_unlock();
 }
 
 static int cnic_cm_offload_pg(struct cnic_sock *csk)
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index d1bce27..a492357 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -290,6 +290,7 @@ struct cnic_ulp_ops {
 	void (*iscsi_nl_send_msg)(struct cnic_dev *dev, u32 msg_type,
 				  char *data, u16 data_size);
 	struct module *owner;
+	atomic_t ref_count;
 };
 
 extern int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops);
-- 
1.5.6.GIT


