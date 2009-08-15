From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5] bnx2: Use mutex on slow path cnic calls.
Date: Fri, 14 Aug 2009 18:49:45 -0700
Message-ID: <1250300987-18407-4-git-send-email-mchan@broadcom.com>
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

The slow path calls to the cnic driver are sleepable calls so we
cannot use rcu_read_lock().  Use mutex for these slow path calls
instead.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   17 +++++++++++------
 drivers/net/bnx2.h |    1 +
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b70cc99..06b9011 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -399,9 +399,11 @@ static int bnx2_unregister_cnic(struct net_device *dev)
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
 
+	mutex_lock(&bp->cnic_lock);
 	cp->drv_state = 0;
 	bnapi->cnic_present = 0;
 	rcu_assign_pointer(bp->cnic_ops, NULL);
+	mutex_unlock(&bp->cnic_lock);
 	synchronize_rcu();
 	return 0;
 }
@@ -429,13 +431,13 @@ bnx2_cnic_stop(struct bnx2 *bp)
 	struct cnic_ops *c_ops;
 	struct cnic_ctl_info info;
 
-	rcu_read_lock();
-	c_ops = rcu_dereference(bp->cnic_ops);
+	mutex_lock(&bp->cnic_lock);
+	c_ops = bp->cnic_ops;
 	if (c_ops) {
 		info.cmd = CNIC_CTL_STOP_CMD;
 		c_ops->cnic_ctl(bp->cnic_data, &info);
 	}
-	rcu_read_unlock();
+	mutex_unlock(&bp->cnic_lock);
 }
 
 static void
@@ -444,8 +446,8 @@ bnx2_cnic_start(struct bnx2 *bp)
 	struct cnic_ops *c_ops;
 	struct cnic_ctl_info info;
 
-	rcu_read_lock();
-	c_ops = rcu_dereference(bp->cnic_ops);
+	mutex_lock(&bp->cnic_lock);
+	c_ops = bp->cnic_ops;
 	if (c_ops) {
 		if (!(bp->flags & BNX2_FLAG_USING_MSIX)) {
 			struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
@@ -455,7 +457,7 @@ bnx2_cnic_start(struct bnx2 *bp)
 		info.cmd = CNIC_CTL_START_CMD;
 		c_ops->cnic_ctl(bp->cnic_data, &info);
 	}
-	rcu_read_unlock();
+	mutex_unlock(&bp->cnic_lock);
 }
 
 #else
@@ -7663,6 +7665,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	spin_lock_init(&bp->phy_lock);
 	spin_lock_init(&bp->indirect_lock);
+#ifdef BCM_CNIC
+	mutex_init(&bp->cnic_lock);
+#endif
 	INIT_WORK(&bp->reset_task, bnx2_reset_task);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index f1edfaa..a4f12fd 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6902,6 +6902,7 @@ struct bnx2 {
 	u32			idle_chk_status_idx;
 
 #ifdef BCM_CNIC
+	struct mutex		cnic_lock;
 	struct cnic_eth_dev	cnic_eth_dev;
 #endif
 
-- 
1.5.6.GIT


