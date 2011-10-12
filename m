From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] ixgbe: Add protection from VF invalid target DMA
Date: Tue, 11 Oct 2011 20:38:17 -0700
Message-ID: <1318390708-12232-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41058 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000Ab1JLDib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 23:38:31 -0400
In-Reply-To: <1318390708-12232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

It is possible for a VF to set an invalid target DMA address in its
Tx/Rx descriptor buffer pointers.  The workarounds in this patch
will guard against such an event and issue a VFLR to the VF in response.
The VFLR will shut down the VF until an administrator can take action
to investigate the event and correct the problem.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  172 ++++++++++++++++++++++++-
 2 files changed, 175 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 38940d7..c1f76aa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -116,6 +116,8 @@
 #define MAX_EMULATION_MAC_ADDRS         16
 #define IXGBE_MAX_PF_MACVLANS           15
 #define VMDQ_P(p)   ((p) + adapter->num_vfs)
+#define IXGBE_82599_VF_DEVICE_ID        0x10ED
+#define IXGBE_X540_VF_DEVICE_ID         0x1515
 
 struct vf_data_storage {
 	unsigned char vf_mac_addresses[ETH_ALEN];
@@ -512,6 +514,8 @@ struct ixgbe_adapter {
 	struct hlist_head fdir_filter_list;
 	union ixgbe_atr_input fdir_mask;
 	int fdir_filter_count;
+	u32 timer_event_accumulator;
+	u32 vferr_refcount;
 };
 
 struct ixgbe_fdir_filter {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1519a23..b95c6e9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6112,6 +6112,51 @@ static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
 }
 
+#ifdef CONFIG_PCI_IOV
+static void ixgbe_check_for_bad_vf(struct ixgbe_adapter *adapter)
+{
+	int vf;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	u32 gpc;
+	u32 ciaa, ciad;
+
+	gpc = IXGBE_READ_REG(hw, IXGBE_TXDGPC);
+	if (gpc) /* If incrementing then no need for the check below */
+		return;
+	/*
+	 * Check to see if a bad DMA write target from an errant or
+	 * malicious VF has caused a PCIe error.  If so then we can
+	 * issue a VFLR to the offending VF(s) and then resume without
+	 * requesting a full slot reset.
+	 */
+
+	for (vf = 0; vf < adapter->num_vfs; vf++) {
+		ciaa = (vf << 16) | 0x80000000;
+		/* 32 bit read so align, we really want status at offset 6 */
+		ciaa |= PCI_COMMAND;
+		IXGBE_WRITE_REG(hw, IXGBE_CIAA_82599, ciaa);
+		ciad = IXGBE_READ_REG(hw, IXGBE_CIAD_82599);
+		ciaa &= 0x7FFFFFFF;
+		/* disable debug mode asap after reading data */
+		IXGBE_WRITE_REG(hw, IXGBE_CIAA_82599, ciaa);
+		/* Get the upper 16 bits which will be the PCI status reg */
+		ciad >>= 16;
+		if (ciad & PCI_STATUS_REC_MASTER_ABORT) {
+			netdev_err(netdev, "VF %d Hung DMA\n", vf);
+			/* Issue VFLR */
+			ciaa = (vf << 16) | 0x80000000;
+			ciaa |= 0xA8;
+			IXGBE_WRITE_REG(hw, IXGBE_CIAA_82599, ciaa);
+			ciad = 0x00008000;  /* VFLR */
+			IXGBE_WRITE_REG(hw, IXGBE_CIAD_82599, ciad);
+			ciaa &= 0x7FFFFFFF;
+			IXGBE_WRITE_REG(hw, IXGBE_CIAA_82599, ciaa);
+		}
+	}
+}
+
+#endif
 /**
  * ixgbe_service_timer - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
@@ -6120,17 +6165,49 @@ static void ixgbe_service_timer(unsigned long data)
 {
 	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
 	unsigned long next_event_offset;
+	bool ready = true;
 
+#ifdef CONFIG_PCI_IOV
+	ready = false;
+
+	/*
+	 * don't bother with SR-IOV VF DMA hang check if there are
+	 * no VFs or the link is down
+	 */
+	if (!adapter->num_vfs ||
+	    (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)) {
+		ready = true;
+		goto normal_timer_service;
+	}
+
+	/* If we have VFs allocated then we must check for DMA hangs */
+	ixgbe_check_for_bad_vf(adapter);
+	next_event_offset = HZ / 50;
+	adapter->timer_event_accumulator++;
+
+	if (adapter->timer_event_accumulator >= 100) {
+		ready = true;
+		adapter->timer_event_accumulator = 0;
+	}
+
+	goto schedule_event;
+
+normal_timer_service:
+#endif
 	/* poll faster when waiting for link */
 	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
 		next_event_offset = HZ / 10;
 	else
 		next_event_offset = HZ * 2;
 
+#ifdef CONFIG_PCI_IOV
+schedule_event:
+#endif
 	/* Reset the timer */
 	mod_timer(&adapter->service_timer, next_event_offset + jiffies);
 
-	ixgbe_service_event_schedule(adapter);
+	if (ready)
+		ixgbe_service_event_schedule(adapter);
 }
 
 static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
@@ -7717,6 +7794,91 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
+#ifdef CONFIG_PCI_IOV
+	struct pci_dev *bdev, *vfdev;
+	u32 dw0, dw1, dw2, dw3;
+	int vf, pos;
+	u16 req_id, pf_func;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB ||
+	    adapter->num_vfs == 0)
+		goto skip_bad_vf_detection;
+
+	bdev = pdev->bus->self;
+	while (bdev && (bdev->pcie_type != PCI_EXP_TYPE_ROOT_PORT))
+		bdev = bdev->bus->self;
+
+	if (!bdev)
+		goto skip_bad_vf_detection;
+
+	pos = pci_find_ext_capability(bdev, PCI_EXT_CAP_ID_ERR);
+	if (!pos)
+		goto skip_bad_vf_detection;
+
+	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG, &dw0);
+	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 4, &dw1);
+	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 8, &dw2);
+	pci_read_config_dword(bdev, pos + PCI_ERR_HEADER_LOG + 12, &dw3);
+
+	req_id = dw1 >> 16;
+	/* On the 82599 if bit 7 of the requestor ID is set then it's a VF */
+	if (!(req_id & 0x0080))
+		goto skip_bad_vf_detection;
+
+	pf_func = req_id & 0x01;
+	if ((pf_func & 1) == (pdev->devfn & 1)) {
+		unsigned int device_id;
+
+		vf = (req_id & 0x7F) >> 1;
+		e_dev_err("VF %d has caused a PCIe error\n", vf);
+		e_dev_err("TLP: dw0: %8.8x\tdw1: %8.8x\tdw2: "
+				"%8.8x\tdw3: %8.8x\n",
+		dw0, dw1, dw2, dw3);
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+			device_id = IXGBE_82599_VF_DEVICE_ID;
+			break;
+		case ixgbe_mac_X540:
+			device_id = IXGBE_X540_VF_DEVICE_ID;
+			break;
+		default:
+			device_id = 0;
+			break;
+		}
+
+		/* Find the pci device of the offending VF */
+		vfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID, device_id, NULL);
+		while (vfdev) {
+			if (vfdev->devfn == (req_id & 0xFF))
+				break;
+			vfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID,
+					       device_id, vfdev);
+		}
+		/*
+		 * There's a slim chance the VF could have been hot plugged,
+		 * so if it is no longer present we don't need to issue the
+		 * VFLR.  Just clean up the AER in that case.
+		 */
+		if (vfdev) {
+			e_dev_err("Issuing VFLR to VF %d\n", vf);
+			pci_write_config_dword(vfdev, 0xA8, 0x00008000);
+		}
+
+		pci_cleanup_aer_uncorrect_error_status(pdev);
+	}
+
+	/*
+	 * Even though the error may have occurred on the other port
+	 * we still need to increment the vf error reference count for
+	 * both ports because the I/O resume function will be called
+	 * for both of them.
+	 */
+	adapter->vferr_refcount++;
+
+	return PCI_ERS_RESULT_RECOVERED;
+
+skip_bad_vf_detection:
+#endif /* CONFIG_PCI_IOV */
 	netif_device_detach(netdev);
 
 	if (state == pci_channel_io_perm_failure)
@@ -7779,6 +7941,14 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
+#ifdef CONFIG_PCI_IOV
+	if (adapter->vferr_refcount) {
+		e_info(drv, "Resuming after VF err\n");
+		adapter->vferr_refcount--;
+		return;
+	}
+
+#endif
 	if (netif_running(netdev))
 		ixgbe_up(adapter);
 
-- 
1.7.6.4
