From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 25/29] fm10k: Add support for SR-IOV to driver
Date: Tue, 23 Sep 2014 04:16:53 -0700
Message-ID: <1411471017-28213-26-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755556AbaIWLR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:28 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch combines the recently added VF messaging and configuration
functionality with the interfaces provided by the kernel to allow for
configuration and management of SR-IOV.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile       |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  26 ++
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c    | 536 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  20 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  32 ++
 5 files changed, 614 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_iov.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index f70893a..70565ab 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -29,4 +29,4 @@ obj-$(CONFIG_FM10K) += fm10k.o
 
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
 	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o fm10k_vf.o \
-	      fm10k_mbx.o fm10k_tlv.o
+	      fm10k_mbx.o fm10k_iov.o fm10k_tlv.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 639698c..fb71871 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -218,6 +218,13 @@ struct fm10k_ring_feature {
 	u16 offset;	/* offset to start of feature */
 };
 
+struct fm10k_iov_data {
+	unsigned int		num_vfs;
+	unsigned int		next_vf_mbx;
+	struct rcu_head		rcu;
+	struct fm10k_vf_info	vf_info[0];
+};
+
 #define fm10k_vxlan_port_for_each(vp, intfc) \
 	list_for_each_entry(vp, &(intfc)->vxlan_port, list)
 struct fm10k_vxlan_port {
@@ -277,6 +284,9 @@ struct fm10k_intfc {
 	int num_q_vectors;	/* current number of q_vectors for device */
 	struct fm10k_ring_feature ring_feature[RING_F_ARRAY_SIZE];
 
+	/* SR-IOV information management structure */
+	struct fm10k_iov_data *iov_data;
+
 	struct fm10k_hw_stats stats;
 	struct fm10k_hw hw;
 	u32 __iomem *uc_addr;
@@ -441,4 +451,20 @@ int fm10k_close(struct net_device *netdev);
 
 /* Ethtool */
 void fm10k_set_ethtool_ops(struct net_device *dev);
+
+/* IOV */
+s32 fm10k_iov_event(struct fm10k_intfc *interface);
+s32 fm10k_iov_mbx(struct fm10k_intfc *interface);
+void fm10k_iov_suspend(struct pci_dev *pdev);
+int fm10k_iov_resume(struct pci_dev *pdev);
+void fm10k_iov_disable(struct pci_dev *pdev);
+int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs);
+s32 fm10k_iov_update_pvid(struct fm10k_intfc *interface, u16 glort, u16 pvid);
+int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac);
+int fm10k_ndo_set_vf_vlan(struct net_device *netdev,
+			  int vf_idx, u16 vid, u8 qos);
+int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int rate,
+			int unused);
+int fm10k_ndo_get_vf_config(struct net_device *netdev,
+			    int vf_idx, struct ifla_vf_info *ivi);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
new file mode 100644
index 0000000..0601908
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -0,0 +1,536 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k.h"
+#include "fm10k_vf.h"
+#include "fm10k_pf.h"
+
+static s32 fm10k_iov_msg_error(struct fm10k_hw *hw, u32 **results,
+			       struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_vf_info *vf_info = (struct fm10k_vf_info *)mbx;
+	struct fm10k_intfc *interface = hw->back;
+	struct pci_dev *pdev = interface->pdev;
+
+	dev_err(&pdev->dev, "Unknown message ID %u on VF %d\n",
+		**results & FM10K_TLV_ID_MASK, vf_info->vf_idx);
+
+	return fm10k_tlv_msg_error(hw, results, mbx);
+}
+
+static const struct fm10k_msg_data iov_mbx_data[] = {
+	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
+	FM10K_VF_MSG_MSIX_HANDLER(fm10k_iov_msg_msix_pf),
+	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_iov_msg_mac_vlan_pf),
+	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_iov_msg_lport_state_pf),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_iov_msg_error),
+};
+
+s32 fm10k_iov_event(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_iov_data *iov_data;
+	s64 mbicr, vflre;
+	int i;
+
+	/* if there is no iov_data then there is no mailboxes to process */
+	if (!ACCESS_ONCE(interface->iov_data))
+		return 0;
+
+	rcu_read_lock();
+
+	iov_data = interface->iov_data;
+
+	/* check again now that we are in the RCU block */
+	if (!iov_data)
+		goto read_unlock;
+
+	if (!(fm10k_read_reg(hw, FM10K_EICR) & FM10K_EICR_VFLR))
+		goto process_mbx;
+
+	/* read VFLRE to determine if any VFs have been reset */
+	do {
+		vflre = fm10k_read_reg(hw, FM10K_PFVFLRE(0));
+		vflre <<= 32;
+		vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(1));
+		vflre = (vflre << 32) | (vflre >> 32);
+		vflre |= fm10k_read_reg(hw, FM10K_PFVFLRE(0));
+
+		i = iov_data->num_vfs;
+
+		for (vflre <<= 64 - i; vflre && i--; vflre += vflre) {
+			struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+
+			if (vflre >= 0)
+				continue;
+
+			hw->iov.ops.reset_resources(hw, vf_info);
+			vf_info->mbx.ops.connect(hw, &vf_info->mbx);
+		}
+	} while (i != iov_data->num_vfs);
+
+process_mbx:
+	/* read MBICR to determine which VFs require attention */
+	mbicr = fm10k_read_reg(hw, FM10K_MBICR(1));
+	mbicr <<= 32;
+	mbicr |= fm10k_read_reg(hw, FM10K_MBICR(0));
+
+	i = iov_data->next_vf_mbx ? : iov_data->num_vfs;
+
+	for (mbicr <<= 64 - i; i--; mbicr += mbicr) {
+		struct fm10k_mbx_info *mbx = &iov_data->vf_info[i].mbx;
+
+		if (mbicr >= 0)
+			continue;
+
+		if (!hw->mbx.ops.tx_ready(&hw->mbx, FM10K_VFMBX_MSG_MTU))
+			break;
+
+		mbx->ops.process(hw, mbx);
+	}
+
+	if (i >= 0) {
+		iov_data->next_vf_mbx = i + 1;
+	} else if (iov_data->next_vf_mbx) {
+		iov_data->next_vf_mbx = 0;
+		goto process_mbx;
+	}
+read_unlock:
+	rcu_read_unlock();
+
+	return 0;
+}
+
+s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_iov_data *iov_data;
+	int i;
+
+	/* if there is no iov_data then there is no mailboxes to process */
+	if (!ACCESS_ONCE(interface->iov_data))
+		return 0;
+
+	rcu_read_lock();
+
+	iov_data = interface->iov_data;
+
+	/* check again now that we are in the RCU block */
+	if (!iov_data)
+		goto read_unlock;
+
+	/* lock the mailbox for transmit and receive */
+	fm10k_mbx_lock(interface);
+
+process_mbx:
+	for (i = iov_data->next_vf_mbx ? : iov_data->num_vfs; i--;) {
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+		struct fm10k_mbx_info *mbx = &vf_info->mbx;
+		u16 glort = vf_info->glort;
+
+		/* verify port mapping is valid, if not reset port */
+		if (vf_info->vf_flags && !fm10k_glort_valid_pf(hw, glort))
+			hw->iov.ops.reset_lport(hw, vf_info);
+
+		/* reset VFs that have mailbox timed out */
+		if (!mbx->timeout) {
+			hw->iov.ops.reset_resources(hw, vf_info);
+			mbx->ops.connect(hw, mbx);
+		}
+
+		/* no work pending, then just continue */
+		if (mbx->ops.tx_complete(mbx) && !mbx->ops.rx_ready(mbx))
+			continue;
+
+		/* guarantee we have free space in the SM mailbox */
+		if (!hw->mbx.ops.tx_ready(&hw->mbx, FM10K_VFMBX_MSG_MTU))
+			break;
+
+		/* cleanup mailbox and process received messages */
+		mbx->ops.process(hw, mbx);
+	}
+
+	if (i >= 0) {
+		iov_data->next_vf_mbx = i + 1;
+	} else if (iov_data->next_vf_mbx) {
+		iov_data->next_vf_mbx = 0;
+		goto process_mbx;
+	}
+
+	/* free the lock */
+	fm10k_mbx_unlock(interface);
+
+read_unlock:
+	rcu_read_unlock();
+
+	return 0;
+}
+
+void fm10k_iov_suspend(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+	int num_vfs, i;
+
+	/* pull out num_vfs from iov_data */
+	num_vfs = iov_data ? iov_data->num_vfs : 0;
+
+	/* shut down queue mapping for VFs */
+	fm10k_write_reg(hw, FM10K_DGLORTMAP(fm10k_dglort_vf_rss),
+			FM10K_DGLORTMAP_NONE);
+
+	/* Stop any active VFs and reset their resources */
+	for (i = 0; i < num_vfs; i++) {
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+
+		hw->iov.ops.reset_resources(hw, vf_info);
+		hw->iov.ops.reset_lport(hw, vf_info);
+	}
+}
+
+int fm10k_iov_resume(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_dglort_cfg dglort = { 0 };
+	struct fm10k_hw *hw = &interface->hw;
+	int num_vfs, i;
+
+	/* pull out num_vfs from iov_data */
+	num_vfs = iov_data ? iov_data->num_vfs : 0;
+
+	/* return error if iov_data is not already populated */
+	if (!iov_data)
+		return -ENOMEM;
+
+	/* allocate hardware resources for the VFs */
+	hw->iov.ops.assign_resources(hw, num_vfs, num_vfs);
+
+	/* configure DGLORT mapping for RSS */
+	dglort.glort = hw->mac.dglort_map & FM10K_DGLORTMAP_NONE;
+	dglort.idx = fm10k_dglort_vf_rss;
+	dglort.inner_rss = 1;
+	dglort.rss_l = fls(fm10k_queues_per_pool(hw) - 1);
+	dglort.queue_b = fm10k_vf_queue_index(hw, 0);
+	dglort.vsi_l = fls(hw->iov.total_vfs - 1);
+	dglort.vsi_b = 1;
+
+	hw->mac.ops.configure_dglort_map(hw, &dglort);
+
+	/* assign resources to the device */
+	for (i = 0; i < num_vfs; i++) {
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+
+		/* allocate all but the last GLORT to the VFs */
+		if (i == ((~hw->mac.dglort_map) >> FM10K_DGLORTMAP_MASK_SHIFT))
+			break;
+
+		/* assign GLORT to VF, and restrict it to multicast */
+		hw->iov.ops.set_lport(hw, vf_info, i,
+				      FM10K_VF_FLAG_MULTI_CAPABLE);
+
+		/* assign our default vid to the VF following reset */
+		vf_info->sw_vid = hw->mac.default_vid;
+
+		/* mailbox is disconnected so we don't send a message */
+		hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
+
+		/* now we are ready so we can connect */
+		vf_info->mbx.ops.connect(hw, &vf_info->mbx);
+	}
+
+	return 0;
+}
+
+s32 fm10k_iov_update_pvid(struct fm10k_intfc *interface, u16 glort, u16 pvid)
+{
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_vf_info *vf_info;
+	u16 vf_idx = (glort - hw->mac.dglort_map) & FM10K_DGLORTMAP_NONE;
+
+	/* no IOV support, not our message to process */
+	if (!iov_data)
+		return FM10K_ERR_PARAM;
+
+	/* glort outside our range, not our message to process */
+	if (vf_idx >= iov_data->num_vfs)
+		return FM10K_ERR_PARAM;
+
+	/* determine if an update has occured and if so notify the VF */
+	vf_info = &iov_data->vf_info[vf_idx];
+	if (vf_info->sw_vid != pvid) {
+		vf_info->sw_vid = pvid;
+		hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
+	}
+
+	return 0;
+}
+
+static void fm10k_iov_free_data(struct pci_dev *pdev)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+
+	if (!interface->iov_data)
+		return;
+
+	/* reclaim hardware resources */
+	fm10k_iov_suspend(pdev);
+
+	/* drop iov_data from interface */
+	kfree_rcu(interface->iov_data, rcu);
+	interface->iov_data = NULL;
+}
+
+static s32 fm10k_iov_alloc_data(struct pci_dev *pdev, int num_vfs)
+{
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+	size_t size;
+	int i, err;
+
+	/* return error if iov_data is already populated */
+	if (iov_data)
+		return -EBUSY;
+
+	/* The PF should always be able to assign resources */
+	if (!hw->iov.ops.assign_resources)
+		return -ENODEV;
+
+	/* nothing to do if no VFs are requested */
+	if (!num_vfs)
+		return 0;
+
+	/* allocate memory for VF storage */
+	size = offsetof(struct fm10k_iov_data, vf_info[num_vfs]);
+	iov_data = kzalloc(size, GFP_KERNEL);
+	if (!iov_data)
+		return -ENOMEM;
+
+	/* record number of VFs */
+	iov_data->num_vfs = num_vfs;
+
+	/* loop through vf_info structures initializing each entry */
+	for (i = 0; i < num_vfs; i++) {
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[i];
+
+		/* Record VF VSI value */
+		vf_info->vsi = i + 1;
+		vf_info->vf_idx = i;
+
+		/* initialize mailbox memory */
+		err = fm10k_pfvf_mbx_init(hw, &vf_info->mbx, iov_mbx_data, i);
+		if (err) {
+			dev_err(&pdev->dev,
+				"Unable to initialize SR-IOV mailbox\n");
+			kfree(iov_data);
+			return err;
+		}
+	}
+
+	/* assign iov_data to interface */
+	interface->iov_data = iov_data;
+
+	/* allocate hardware resources for the VFs */
+	fm10k_iov_resume(pdev);
+
+	return 0;
+}
+
+void fm10k_iov_disable(struct pci_dev *pdev)
+{
+	if (pci_num_vf(pdev) && pci_vfs_assigned(pdev))
+		dev_err(&pdev->dev,
+			"Cannot disable SR-IOV while VFs are assigned\n");
+	else
+		pci_disable_sriov(pdev);
+
+	fm10k_iov_free_data(pdev);
+}
+
+static void fm10k_disable_aer_comp_abort(struct pci_dev *pdev)
+{
+	u32 err_sev;
+	int pos;
+
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ERR);
+	if (!pos)
+		return;
+
+	pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &err_sev);
+	err_sev &= ~PCI_ERR_UNC_COMP_ABORT;
+	pci_write_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, err_sev);
+}
+
+int fm10k_iov_configure(struct pci_dev *pdev, int num_vfs)
+{
+	int current_vfs = pci_num_vf(pdev);
+	int err = 0;
+
+	if (current_vfs && pci_vfs_assigned(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot modify SR-IOV while VFs are assigned\n");
+		num_vfs = current_vfs;
+	} else {
+		pci_disable_sriov(pdev);
+		fm10k_iov_free_data(pdev);
+	}
+
+	/* allocate resources for the VFs */
+	err = fm10k_iov_alloc_data(pdev, num_vfs);
+	if (err)
+		return err;
+
+	/* allocate VFs if not already allocated */
+	if (num_vfs && (num_vfs != current_vfs)) {
+		/* Disable completer abort error reporting as
+		 * the VFs can trigger this any time they read a queue
+		 * that they don't own.
+		 */
+		fm10k_disable_aer_comp_abort(pdev);
+
+		err = pci_enable_sriov(pdev, num_vfs);
+		if (err) {
+			dev_err(&pdev->dev,
+				"Enable PCI SR-IOV failed: %d\n", err);
+			return err;
+		}
+	}
+
+	return num_vfs;
+}
+
+int fm10k_ndo_set_vf_mac(struct net_device *netdev, int vf_idx, u8 *mac)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_vf_info *vf_info;
+
+	/* verify SR-IOV is active and that vf idx is valid */
+	if (!iov_data || vf_idx >= iov_data->num_vfs)
+		return -EINVAL;
+
+	/* verify MAC addr is valid */
+	if (!is_zero_ether_addr(mac) && !is_valid_ether_addr(mac))
+		return -EINVAL;
+
+	/* record new MAC address */
+	vf_info = &iov_data->vf_info[vf_idx];
+	ether_addr_copy(vf_info->mac, mac);
+
+	/* assigning the MAC will send a mailbox message so lock is needed */
+	fm10k_mbx_lock(interface);
+
+	/* assign MAC address to VF */
+	hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
+
+	fm10k_mbx_unlock(interface);
+
+	return 0;
+}
+
+int fm10k_ndo_set_vf_vlan(struct net_device *netdev, int vf_idx, u16 vid,
+			  u8 qos)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_vf_info *vf_info;
+
+	/* verify SR-IOV is active and that vf idx is valid */
+	if (!iov_data || vf_idx >= iov_data->num_vfs)
+		return -EINVAL;
+
+	/* QOS is unsupported and VLAN IDs accepted range 0-4094 */
+	if (qos || (vid > (VLAN_VID_MASK - 1)))
+		return -EINVAL;
+
+	vf_info = &iov_data->vf_info[vf_idx];
+
+	/* exit if there is nothing to do */
+	if (vf_info->pf_vid == vid)
+		return 0;
+
+	/* record default VLAN ID for VF */
+	vf_info->pf_vid = vid;
+
+	/* assigning the VLAN will send a mailbox message so lock is needed */
+	fm10k_mbx_lock(interface);
+
+	/* Clear the VLAN table for the VF */
+	hw->mac.ops.update_vlan(hw, FM10K_VLAN_ALL, vf_info->vsi, false);
+
+	/* Update VF assignment and trigger reset */
+	hw->iov.ops.assign_default_mac_vlan(hw, vf_info);
+
+	fm10k_mbx_unlock(interface);
+
+	return 0;
+}
+
+int fm10k_ndo_set_vf_bw(struct net_device *netdev, int vf_idx, int unused,
+			int rate)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* verify SR-IOV is active and that vf idx is valid */
+	if (!iov_data || vf_idx >= iov_data->num_vfs)
+		return -EINVAL;
+
+	/* rate limit cannot be less than 10Mbs or greater than link speed */
+	if (rate && ((rate < FM10K_VF_TC_MIN) || rate > FM10K_VF_TC_MAX))
+		return -EINVAL;
+
+	/* store values */
+	iov_data->vf_info[vf_idx].rate = rate;
+
+	/* update hardware configuration */
+	hw->iov.ops.configure_tc(hw, vf_idx, rate);
+
+	return 0;
+}
+
+int fm10k_ndo_get_vf_config(struct net_device *netdev,
+			    int vf_idx, struct ifla_vf_info *ivi)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_iov_data *iov_data = interface->iov_data;
+	struct fm10k_vf_info *vf_info;
+
+	/* verify SR-IOV is active and that vf idx is valid */
+	if (!iov_data || vf_idx >= iov_data->num_vfs)
+		return -EINVAL;
+
+	vf_info = &iov_data->vf_info[vf_idx];
+
+	ivi->vf = vf_idx;
+	ivi->max_tx_rate = vf_info->rate;
+	ivi->min_tx_rate = 0;
+	ether_addr_copy(ivi->mac, vf_info->mac);
+	ivi->vlan = vf_info->pf_vid;
+	ivi->qos = 0;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index c0d6758..991abb2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -368,7 +368,21 @@ static void fm10k_request_glort_range(struct fm10k_intfc *interface)
 	if (hw->mac.dglort_map == FM10K_DGLORTMAP_NONE)
 		return;
 
-	interface->glort_count = mask + 1;
+	/* we support 3 possible GLORT configurations.
+	 * 1: VFs consume all but the last 1
+	 * 2: VFs and PF split glorts with possible gap between
+	 * 3: VFs allocated first 64, all others belong to PF
+	 */
+	if (mask <= hw->iov.total_vfs) {
+		interface->glort_count = 1;
+		interface->glort += mask;
+	} else if (mask < 64) {
+		interface->glort_count = (mask + 1) / 2;
+		interface->glort += interface->glort_count;
+	} else {
+		interface->glort_count = mask - 63;
+		interface->glort += 64;
+	}
 }
 
 /**
@@ -1325,6 +1339,10 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
 	.ndo_get_stats64	= fm10k_get_stats64,
 	.ndo_setup_tc		= fm10k_setup_tc,
+	.ndo_set_vf_mac		= fm10k_ndo_set_vf_mac,
+	.ndo_set_vf_vlan	= fm10k_ndo_set_vf_vlan,
+	.ndo_set_vf_rate	= fm10k_ndo_set_vf_bw,
+	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
 	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
 	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9cc4d62..7935c1a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -152,6 +152,8 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 
 	rtnl_lock();
 
+	fm10k_iov_suspend(interface->pdev);
+
 	if (netif_running(netdev))
 		fm10k_close(netdev);
 
@@ -171,6 +173,8 @@ static void fm10k_reinit(struct fm10k_intfc *interface)
 	if (netif_running(netdev))
 		fm10k_open(netdev);
 
+	fm10k_iov_resume(interface->pdev);
+
 	rtnl_unlock();
 
 	clear_bit(__FM10K_RESETTING, &interface->state);
@@ -260,6 +264,9 @@ static void fm10k_mbx_subtask(struct fm10k_intfc *interface)
 {
 	/* process upstream mailbox and update device state */
 	fm10k_watchdog_update_host_state(interface);
+
+	/* process downstream mailboxes */
+	fm10k_iov_mbx(interface);
 }
 
 /**
@@ -975,6 +982,7 @@ static irqreturn_t fm10k_msix_mbx_pf(int irq, void *data)
 	/* service mailboxes */
 	if (fm10k_mbx_trylock(interface)) {
 		mbx->ops.process(hw, mbx);
+		fm10k_iov_event(interface);
 		fm10k_mbx_unlock(interface);
 	}
 
@@ -1159,6 +1167,11 @@ static s32 fm10k_update_pvid(struct fm10k_hw *hw, u32 **results,
 
 	interface = container_of(hw, struct fm10k_intfc, hw);
 
+	/* check to see if this belongs to one of the VFs */
+	err = fm10k_iov_update_pvid(interface, glort, pvid);
+	if (!err)
+		return 0;
+
 	/* we need to reset if default VLAN was just updated */
 	if (pvid != hw->mac.default_vid)
 		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
@@ -1477,6 +1490,10 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	memcpy(&hw->mac.ops, fi->mac_ops, sizeof(hw->mac.ops));
 	hw->mac.type = fi->mac;
 
+	/* Setup IOV handlers */
+	if (fi->iov_ops)
+		memcpy(&hw->iov.ops, fi->iov_ops, sizeof(hw->iov.ops));
+
 	/* Set common capability flags and settings */
 	rss = min_t(int, FM10K_MAX_RSS_INDICES, num_online_cpus());
 	interface->ring_feature[RING_F_RSS].limit = rss;
@@ -1509,6 +1526,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	/* initialize hardware statistics */
 	hw->mac.ops.update_hw_stats(hw, &interface->stats);
 
+	/* Set upper limit on IOV VFs that can be allocated */
+	pci_sriov_set_totalvfs(pdev, hw->iov.total_vfs);
+
 	/* Start with random Ethernet address */
 	eth_random_addr(hw->mac.addr);
 
@@ -1708,6 +1728,9 @@ static int fm10k_probe(struct pci_dev *pdev,
 	/* print warning for non-optimal configurations */
 	fm10k_slot_warn(interface);
 
+	/* enable SR-IOV after registering netdev to enforce PF/VF ordering */
+	fm10k_iov_configure(pdev, 0);
+
 	/* clear the service task disable bit to allow service task to start */
 	clear_bit(__FM10K_SERVICE_DISABLE, &interface->state);
 
@@ -1751,6 +1774,9 @@ static void fm10k_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
+	/* release VFs */
+	fm10k_iov_disable(pdev);
+
 	/* disable mailbox interrupt */
 	fm10k_mbx_free_irq(interface);
 
@@ -1827,6 +1853,9 @@ static int fm10k_resume(struct pci_dev *pdev)
 	if (err)
 		return err;
 
+	/* restore SR-IOV interface */
+	fm10k_iov_resume(pdev);
+
 	netif_device_attach(netdev);
 
 	return 0;
@@ -1848,6 +1877,8 @@ static int fm10k_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netif_device_detach(netdev);
 
+	fm10k_iov_suspend(pdev);
+
 	rtnl_lock();
 
 	if (netif_running(netdev))
@@ -1989,6 +2020,7 @@ static struct pci_driver fm10k_driver = {
 	.suspend		= fm10k_suspend,
 	.resume			= fm10k_resume,
 #endif
+	.sriov_configure	= fm10k_iov_configure,
 	.err_handler		= &fm10k_err_handler
 };
 
-- 
1.9.3
