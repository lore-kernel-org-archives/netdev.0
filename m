From: Lan Tianyu <tianyu.lan@intel.com>
Subject: [RFC Patch 05/12] IXGBE: Add new sysfs interface of "notify_vf"
Date: Thu, 22 Oct 2015 00:37:37 +0800
Message-ID: <1445445464-5056-6-git-send-email-tianyu.lan@intel.com>
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

This patch is to add new sysfs interface of "notify_vf" under sysfs
directory of VF PCI device for Qemu to notify VF when migration status
is changed.

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 30 ++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  4 ++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index e247d67..5cc7817 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -217,10 +217,37 @@ static ssize_t ixgbe_store_state_in_pf(struct device *dev,
 	return count;
 }
 
+static ssize_t ixgbe_store_notify_vf(struct device *dev,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct ixgbe_adapter *adapter = to_adapter(dev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct pci_dev *vf_pdev = to_pci_dev(dev);
+	int vfn = vf_pdev->virtfn_index;
+	u32 ivar;
+
+	/* Enable VF mailbox irq first */
+	IXGBE_WRITE_REG(hw, IXGBE_PVTEIMS(vfn), 0x4);
+	IXGBE_WRITE_REG(hw, IXGBE_PVTEIAM(vfn), 0x4);
+	IXGBE_WRITE_REG(hw, IXGBE_PVTEIAC(vfn), 0x4);
+
+	ivar = IXGBE_READ_REG(hw, IXGBE_PVTIVAR_MISC(vfn));
+	ivar &= ~0xFF;
+	ivar |= 0x2 | IXGBE_IVAR_ALLOC_VAL;
+	IXGBE_WRITE_REG(hw, IXGBE_PVTIVAR_MISC(vfn), ivar);
+
+	ixgbe_ping_vf(adapter, vfn);
+	return count;
+}
+
 static struct device_attribute ixgbe_per_state_in_pf_attribute =
 	__ATTR(state_in_pf, S_IRUGO | S_IWUSR,
 		ixgbe_show_state_in_pf, ixgbe_store_state_in_pf);
 
+static struct device_attribute ixgbe_per_notify_vf_attribute =
+	__ATTR(notify_vf, S_IWUSR, NULL, ixgbe_store_notify_vf);
+
 void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
@@ -241,6 +268,8 @@ void ixgbe_add_vf_attrib(struct ixgbe_adapter *adapter)
 		if (vfdev->is_virtfn) {
 			ret = device_create_file(&vfdev->dev,
 					&ixgbe_per_state_in_pf_attribute);
+			ret |= device_create_file(&vfdev->dev,
+					&ixgbe_per_notify_vf_attribute);
 			if (ret)
 				pr_warn("Unable to add VF attribute for dev %s,\n",
 					dev_name(&vfdev->dev));
@@ -269,6 +298,7 @@ void ixgbe_remove_vf_attrib(struct ixgbe_adapter *adapter)
 	while (vfdev) {
 		if (vfdev->is_virtfn) {
 			device_remove_file(&vfdev->dev, &ixgbe_per_state_in_pf_attribute);
+			device_remove_file(&vfdev->dev, &ixgbe_per_notify_vf_attribute);
 		}
 
 		vfdev = pci_get_device(pdev->vendor, vf_id, vfdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index dd6ba59..c6ddb66 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2302,6 +2302,10 @@ enum {
 #define IXGBE_PVFTDT(P)		(0x06018 + (0x40 * (P)))
 #define IXGBE_PVFTDWBAL(P)	(0x06038 + (0x40 * (P)))
 #define IXGBE_PVFTDWBAH(P)	(0x0603C + (0x40 * (P)))
+#define IXGBE_PVTEIMS(P)	(0x00D00 + (4 * (P)))
+#define IXGBE_PVTIVAR_MISC(P)	(0x04E00 + (4 * (P)))
+#define IXGBE_PVTEIAC(P)       (0x00F00 + (4 * P))
+#define IXGBE_PVTEIAM(P)       (0x04D00 + (4 * P))
 
 #define IXGBE_PVFTDWBALn(q_per_pool, vf_number, vf_q_index) \
 		(IXGBE_PVFTDWBAL((q_per_pool)*(vf_number) + (vf_q_index)))
-- 
1.8.4.rc0.1.g8f6a3e5.dirty
