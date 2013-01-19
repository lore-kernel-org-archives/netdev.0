From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: SR-IOV: dynamic IEEE DCBx default priority changes
Date: Sat, 19 Jan 2013 05:14:50 -0800
Message-ID: <1358601299-10404-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4331 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012Ab3ASNPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:06 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

IEEE DCBx has a mechanism to change the default user priority. In
the normal case the OS can handle this via cgroups, iptables, socket,
options etc.

With SR-IOV and direct assigned VF devices the default priority
needs to be set by the PF device so the inserted VLAN tag is
correct.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c | 40 ++++++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  9 ------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h  |  8 +++++
 3 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index f1e002d..6718fb4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -30,6 +30,7 @@
 #include <linux/dcbnl.h>
 #include "ixgbe_dcb_82598.h"
 #include "ixgbe_dcb_82599.h"
+#include "ixgbe_sriov.h"
 
 /* Callbacks for DCB netlink in the kernel */
 #define BIT_DCB_MODE	0x01
@@ -643,9 +644,11 @@ static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 		return err;
 
 	err = dcb_ieee_setapp(dev, app);
+	if (err)
+		return err;
 
 #ifdef IXGBE_FCOE
-	if (!err && app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	if (app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
 	    app->protocol == ETH_P_FCOE) {
 		u8 app_mask = dcb_ieee_getapp_mask(dev, app);
 
@@ -656,6 +659,23 @@ static int ixgbe_dcbnl_ieee_setapp(struct net_device *dev,
 		ixgbe_dcbnl_devreset(dev);
 	}
 #endif
+
+	/* VF devices should use default UP when available */
+	if (app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	    app->protocol == 0) {
+		int vf;
+
+		adapter->default_up = app->priority;
+
+		for (vf = 0; vf < adapter->num_vfs; vf++) {
+			struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+
+			if (!vfinfo->pf_qos)
+				ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+						app->priority, vf);
+		}
+	}
+
 	return 0;
 }
 
@@ -683,6 +703,24 @@ static int ixgbe_dcbnl_ieee_delapp(struct net_device *dev,
 		ixgbe_dcbnl_devreset(dev);
 	}
 #endif
+	/* IF default priority is being removed clear VF default UP */
+	if (app->selector == IEEE_8021QAZ_APP_SEL_ETHERTYPE &&
+	    app->protocol == 0 && adapter->default_up == app->priority) {
+		int vf;
+		long unsigned int app_mask = dcb_ieee_getapp_mask(dev, app);
+		int qos = app_mask ? find_first_bit(&app_mask, 8) : 0;
+
+		adapter->default_up = qos;
+
+		for (vf = 0; vf < adapter->num_vfs; vf++) {
+			struct vf_data_storage *vfinfo = &adapter->vfinfo[vf];
+
+			if (!vfinfo->pf_qos)
+				ixgbe_set_vmvir(adapter, vfinfo->pf_vlan,
+						qos, vf);
+		}
+	}
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 85cddac..647734b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -447,15 +447,6 @@ static void ixgbe_set_vmolr(struct ixgbe_hw *hw, u32 vf, bool aupe)
 	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vf), vmolr);
 }
 
-static void ixgbe_set_vmvir(struct ixgbe_adapter *adapter,
-			    u16 vid, u16 qos, u32 vf)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 vmvir = vid | (qos << VLAN_PRIO_SHIFT) | IXGBE_VMVIR_VLANA_DEFAULT;
-
-	IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), vmvir);
-}
-
 static void ixgbe_clear_vmvir(struct ixgbe_adapter *adapter, u32 vf)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 1be1d30..21bc1dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -47,6 +47,14 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			const struct ixgbe_info *ii);
 #endif
 
+static inline void ixgbe_set_vmvir(struct ixgbe_adapter *adapter,
+				   u16 vid, u16 qos, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmvir = vid | (qos << VLAN_PRIO_SHIFT) | IXGBE_VMVIR_VLANA_DEFAULT;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VMVIR(vf), vmvir);
+}
 
 #endif /* _IXGBE_SRIOV_H_ */
 
-- 
1.7.11.7
