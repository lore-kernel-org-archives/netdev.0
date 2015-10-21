From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 07/12] IXGBEVF: Add new mail box event for migration
Date: Thu, 22 Oct 2015 00:37:39 +0800
Message-ID: <1445445464-5056-8-git-send-email-tianyu.lan@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>
To: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VF status in the PF driver needs to be restored after migration and reset
VF hardware. This patch is to add a new event for VF driver to notify PF
driver to restore status.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/mbx.h |  3 +++
 drivers/net/ethernet/intel/ixgbevf/vf.c  | 10 ++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
 3 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 82f44e0..22761d8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -112,6 +112,9 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
 #define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
 
+/* mail box event for live migration  */
+#define IXGBE_VF_NOTIFY_RESUME  0x0c /* VF notify PF migration to restore status */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index d1339b0..1e4e5e6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -717,6 +717,15 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	return err;
 }
 
+static void ixgbevf_notify_resume_vf(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	u32 msgbuf[1];
+
+	msgbuf[0] = IXGBE_VF_NOTIFY_RESUME;
+	mbx->ops.write_posted(hw, msgbuf, 1);
+}
+
 static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.init_hw		= ixgbevf_init_hw_vf,
 	.reset_hw		= ixgbevf_reset_hw_vf,
@@ -729,6 +738,7 @@ static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.update_mc_addr_list	= ixgbevf_update_mc_addr_list_vf,
 	.set_uc_addr		= ixgbevf_set_uc_addr_vf,
 	.set_vfta		= ixgbevf_set_vfta_vf,
+	.notify_resume		= ixgbevf_notify_resume_vf,
 };
 
 const struct ixgbevf_info ixgbevf_82599_vf_info = {
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 6a3f4eb..a25fe81 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -70,6 +70,7 @@ struct ixgbe_mac_operations {
 	s32 (*disable_mc)(struct ixgbe_hw *);
 	s32 (*clear_vfta)(struct ixgbe_hw *);
 	s32 (*set_vfta)(struct ixgbe_hw *, u32, u32, bool);
+	void (*notify_resume)(struct ixgbe_hw *); 
 };
 
 enum ixgbe_mac_type {
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
