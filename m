From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2x: Don't disable/enable SR-IOV when
 loading
Date: Sat, 28 Sep 2013 08:46:09 +0300
Message-ID: <1380347172-16670-4-git-send-email-yuvalmin@broadcom.com>
References: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4232 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab3I1Fqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 01:46:40 -0400
In-Reply-To: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Current bnx2x implementation controls the number of VFs only by
standard sysfs support, and will reject setting the number of VFs
when the PF is not loaded.
As a result, there is no need to schedule a delayed work to enable
SR-IOV when PF is loaded, as the number of VFs at that point
must be 0.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 23 -----------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  2 --
 3 files changed, 1 insertion(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a6704b5..467689f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11740,7 +11740,7 @@ static int bnx2x_open(struct net_device *dev)
 	rc = bnx2x_nic_load(bp, LOAD_OPEN);
 	if (rc)
 		return rc;
-	return bnx2x_open_epilog(bp);
+	return 0;
 }
 
 /* called with rtnl_lock */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 7991f10..03cfee1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3635,29 +3635,6 @@ alloc_mem_err:
 	return -ENOMEM;
 }
 
-int bnx2x_open_epilog(struct bnx2x *bp)
-{
-	/* Enable sriov via delayed work. This must be done via delayed work
-	 * because it causes the probe of the vf devices to be run, which invoke
-	 * register_netdevice which must have rtnl lock taken. As we are holding
-	 * the lock right now, that could only work if the probe would not take
-	 * the lock. However, as the probe of the vf may be called from other
-	 * contexts as well (such as passthrough to vm fails) it can't assume
-	 * the lock is being held for it. Using delayed work here allows the
-	 * probe code to simply take the lock (i.e. wait for it to be released
-	 * if it is being held). We only want to do this if the number of VFs
-	 * was set before PF driver was loaded.
-	 */
-	if (IS_SRIOV(bp) && BNX2X_NR_VIRTFN(bp)) {
-		smp_mb__before_clear_bit();
-		set_bit(BNX2X_SP_RTNL_ENABLE_SRIOV, &bp->sp_rtnl_state);
-		smp_mb__after_clear_bit();
-		schedule_delayed_work(&bp->sp_rtnl_task, 0);
-	}
-
-	return 0;
-}
-
 void bnx2x_iov_channel_down(struct bnx2x *bp)
 {
 	int vf_idx;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 059f0d4..1ff6a93 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -782,7 +782,6 @@ static inline int bnx2x_vf_headroom(struct bnx2x *bp)
 void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp);
 int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs);
 void bnx2x_iov_channel_down(struct bnx2x *bp);
-int bnx2x_open_epilog(struct bnx2x *bp);
 
 #else /* CONFIG_BNX2X_SRIOV */
 
@@ -842,7 +841,6 @@ static inline int bnx2x_vf_pci_alloc(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp) {}
 static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {return 0; }
 static inline void bnx2x_iov_channel_down(struct bnx2x *bp) {}
-static inline int bnx2x_open_epilog(struct bnx2x *bp) {return 0; }
 
 #endif /* CONFIG_BNX2X_SRIOV */
 #endif /* bnx2x_sriov.h */
-- 
1.8.1.227.g44fe835
