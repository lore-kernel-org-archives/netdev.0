From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 8/9] bnx2x: Control number of vfs dynamically
Date: Mon, 18 Feb 2013 10:16:37 +0200
Message-ID: <1361175398-12888-9-git-send-email-yuvalmin@broadcom.com>
References: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2379 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757459Ab3BRJVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 04:21:32 -0500
In-Reply-To: <1361175398-12888-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

1. Support sysfs interface for getting the maximal number of virtual functions
   of a given physical function.
2. Support sysfs interface for getting and setting the current number of
   virtual functions.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   32 ++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |   81 +++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |   10 ++-
 4 files changed, 83 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index cbef837..63e4185 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1282,6 +1282,8 @@ struct bnx2x {
 	dma_addr_t		pf2vf_bulletin_mapping;
 
 	struct pf_vf_bulletin_content	old_bulletin;
+
+	u16 requested_nr_virtfn;
 #endif /* CONFIG_BNX2X_SRIOV */
 
 	struct net_device	*dev;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b643912..adc7ea4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11427,26 +11427,6 @@ static int bnx2x_init_bp(struct bnx2x *bp)
  * net_device service functions
  */
 
-static int bnx2x_open_epilog(struct bnx2x *bp)
-{
-	/* Enable sriov via delayed work. This must be done via delayed work
-	 * because it causes the probe of the vf devices to be run, which invoke
-	 * register_netdevice which must have rtnl lock taken. As we are holding
-	 * the lock right now, that could only work if the probe would not take
-	 * the lock. However, as the probe of the vf may be called from other
-	 * contexts as well (such as passthrough to vm failes) it can't assume
-	 * the lock is being held for it. Using delayed work here allows the
-	 * probe code to simply take the lock (i.e. wait for it to be released
-	 * if it is being held).
-	 */
-	smp_mb__before_clear_bit();
-	set_bit(BNX2X_SP_RTNL_ENABLE_SRIOV, &bp->sp_rtnl_state);
-	smp_mb__after_clear_bit();
-	schedule_delayed_work(&bp->sp_rtnl_task, 0);
-
-	return 0;
-}
-
 /* called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
 {
@@ -12502,13 +12482,8 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 			goto init_one_exit;
 	}
 
-	/* Enable SRIOV if capability found in configuration space.
-	 * Once the generic SR-IOV framework makes it in from the
-	 * pci tree this will be revised, to allow dynamic control
-	 * over the number of VFs. Right now, change the num of vfs
-	 * param below to enable SR-IOV.
-	 */
-	rc = bnx2x_iov_init_one(bp, int_mode, 0/*num vfs*/);
+	/* Enable SRIOV if capability found in configuration space */
+	rc = bnx2x_iov_init_one(bp, int_mode, BNX2X_MAX_NUM_OF_VFS);
 	if (rc)
 		goto init_one_exit;
 
@@ -12824,6 +12799,9 @@ static struct pci_driver bnx2x_pci_driver = {
 	.suspend     = bnx2x_suspend,
 	.resume      = bnx2x_resume,
 	.err_handler = &bnx2x_err_handler,
+#ifdef CONFIG_BNX2X_SRIOV
+	.sriov_configure = bnx2x_sriov_configure,
+#endif
 };
 
 static int __init bnx2x_init(void)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 80fb4dd..c05a37a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1979,8 +1979,11 @@ int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 	if (iov->total == 0)
 		goto failed;
 
-	/* calculate the actual number of VFs */
-	iov->nr_virtfn = min_t(u16, iov->total, (u16)num_vfs_param);
+	/* module param can limit the resources allocated to VFs*/
+	iov->nr_virtfn = min_t(u16, iov->total, num_vfs_param);
+
+	DP(BNX2X_MSG_IOV, "num_vfs_param was %d, nr_virtfn was %d\n",
+	   num_vfs_param, iov->nr_virtfn);
 
 	/* allocate the vf array */
 	bp->vfdb->vfs = kzalloc(sizeof(struct bnx2x_virtf) *
@@ -3027,21 +3030,50 @@ void bnx2x_unlock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	vf->op_current = CHANNEL_TLV_NONE;
 }
 
-void bnx2x_enable_sriov(struct bnx2x *bp)
+int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs_param)
 {
-	int rc = 0;
 
-	/* disbale sriov in case it is still enabled */
-	pci_disable_sriov(bp->pdev);
-	DP(BNX2X_MSG_IOV, "sriov disabled\n");
+	struct bnx2x *bp = netdev_priv(pci_get_drvdata(dev));
 
-	/* enable sriov */
-	DP(BNX2X_MSG_IOV, "vf num (%d)\n", (bp->vfdb->sriov.nr_virtfn));
-	rc = pci_enable_sriov(bp->pdev, (bp->vfdb->sriov.nr_virtfn));
-	if (rc)
+	DP(BNX2X_MSG_IOV, "bnx2x_sriov_configure called with %d, BNX2X_NR_VIRTFN(bp) was %d\n",
+	   num_vfs_param, BNX2X_NR_VIRTFN(bp));
+
+	/* pci_disable_sriov removes non passed-through vfs, releasing them */
+	if (num_vfs_param == 0) {
+		pci_disable_sriov(dev);
+		return 0;
+	}
+
+	/* we are always bound by the total_vfs in the configuration space */
+	if (num_vfs_param > BNX2X_NR_VIRTFN(bp)) {
+		BNX2X_ERR("truncating requested number of VFs (%d) down to maximum allowed (%d)\n",
+			  num_vfs_param, BNX2X_NR_VIRTFN(bp));
+		num_vfs_param = BNX2X_NR_VIRTFN(bp);
+	}
+
+	/* we want to register the requested amount whether or not we can enable
+	 * SR-IOV right now.
+	 */
+	bp->requested_nr_virtfn = num_vfs_param;
+
+	/* HW channel is only operational when PF is up */
+	if (bp->state != BNX2X_STATE_OPEN)
+		return num_vfs_param;
+
+	return bnx2x_enable_sriov(bp);
+}
+
+int bnx2x_enable_sriov(struct bnx2x *bp)
+{
+	int rc = 0, req_vfs = bp->requested_nr_virtfn;
+
+	rc = pci_enable_sriov(bp->pdev, req_vfs);
+	if (rc) {
 		BNX2X_ERR("pci_enable_sriov failed with %d\n", rc);
-	else
-		DP(BNX2X_MSG_IOV, "sriov enabled\n");
+		return rc;
+	}
+	DP(BNX2X_MSG_IOV, "sriov enabled (%d vfs)\n", req_vfs);
+	return req_vfs;
 }
 
 void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp)
@@ -3404,3 +3436,26 @@ alloc_mem_err:
 		       sizeof(union pf_vf_bulletin));
 	return -ENOMEM;
 }
+
+int bnx2x_open_epilog(struct bnx2x *bp)
+{
+	/* Enable sriov via delayed work. This must be done via delayed work
+	 * because it causes the probe of the vf devices to be run, which invoke
+	 * register_netdevice which must have rtnl lock taken. As we are holding
+	 * the lock right now, that could only work if the probe would not take
+	 * the lock. However, as the probe of the vf may be called from other
+	 * contexts as well (such as passthrough to vm failes) it can't assume
+	 * the lock is being held for it. Using delayed work here allows the
+	 * probe code to simply take the lock (i.e. wait for it to be released
+	 * if it is being held). We only want to do this if the number of VFs
+	 * was set before PF driver was loaded.
+	 */
+	if (IS_SRIOV(bp) && BNX2X_NR_VIRTFN(bp)) {
+		smp_mb__before_clear_bit();
+		set_bit(BNX2X_SP_RTNL_ENABLE_SRIOV, &bp->sp_rtnl_state);
+		smp_mb__after_clear_bit();
+		schedule_delayed_work(&bp->sp_rtnl_task, 0);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 33d4951..2d26c6a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -51,6 +51,8 @@ struct bnx2x_sriov {
 	u16 stride;		/* following VF stride */
 	u32 pgsz;		/* page size for BAR alignment */
 	u8 link;		/* Function Dependency Link */
+
+	u16 requested_nr_virtfn;
 };
 
 /* bars */
@@ -753,12 +755,14 @@ static inline int bnx2x_vf_ustorm_prods_offset(struct bnx2x *bp,
 enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp);
 void bnx2x_vf_map_doorbells(struct bnx2x *bp);
 int bnx2x_vf_pci_alloc(struct bnx2x *bp);
-void bnx2x_enable_sriov(struct bnx2x *bp);
+int bnx2x_enable_sriov(struct bnx2x *bp);
 static inline int bnx2x_vf_headroom(struct bnx2x *bp)
 {
 	return bp->vfdb->sriov.nr_virtfn * BNX2X_CLIENTS_PER_VF;
 }
 void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp);
+int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs);
+int bnx2x_open_epilog(struct bnx2x *bp);
 
 #else /* CONFIG_BNX2X_SRIOV */
 
@@ -781,7 +785,7 @@ static inline void bnx2x_iov_init_dmae(struct bnx2x *bp) {}
 static inline int bnx2x_iov_init_one(struct bnx2x *bp, int int_mode_param,
 				     int num_vfs_param) {return 0; }
 static inline void bnx2x_iov_remove_one(struct bnx2x *bp) {}
-static inline void bnx2x_enable_sriov(struct bnx2x *bp) {}
+static inline int bnx2x_enable_sriov(struct bnx2x *bp) {return 0; }
 static inline int bnx2x_vfpf_acquire(struct bnx2x *bp,
 				     u8 tx_count, u8 rx_count) {return 0; }
 static inline int bnx2x_vfpf_release(struct bnx2x *bp) {return 0; }
@@ -807,6 +811,8 @@ static inline enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp
 static inline int bnx2x_vf_map_doorbells(struct bnx2x *bp) {return 0; }
 static inline int bnx2x_vf_pci_alloc(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp) {}
+static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {return 0; }
+static inline int bnx2x_open_epilog(struct bnx2x *bp) {return 0; }
 
 #endif /* CONFIG_BNX2X_SRIOV */
 #endif /* bnx2x_sriov.h */
-- 
1.7.9.GIT
