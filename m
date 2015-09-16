From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] fm10k: re-enable VF after a full reset on detection of a Malicious event
Date: Tue, 15 Sep 2015 17:36:41 -0700
Message-ID: <1442363803-47237-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311AbbIPAgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:51 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Modify behavior of Malicious Driver Detection events. Presently, the
hardware disables the VF queues and re-assigns them to the PF. This
causes the VF in question to continuously Tx hang, because it assumes
that it can transmit over the queues in question. For transient events,
this results in continuous logging of malicious events.

New behavior is to reset the LPORT and VF state, so that the VF will
have to reset and re-enable itself. This does mean that malicious VFs
will possibly be able to continue and attempt malicious events again.
However, it is expected that system administrators will step in and
manually remove or disable the VF in question.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 30 ++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9bdc04d..3d71c52 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -880,10 +880,12 @@ void fm10k_netpoll(struct net_device *netdev)
 
 #endif
 #define FM10K_ERR_MSG(type) case (type): error = #type; break
-static void fm10k_print_fault(struct fm10k_intfc *interface, int type,
+static void fm10k_handle_fault(struct fm10k_intfc *interface, int type,
 			      struct fm10k_fault *fault)
 {
 	struct pci_dev *pdev = interface->pdev;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_iov_data *iov_data = interface->iov_data;
 	char *error;
 
 	switch (type) {
@@ -937,6 +939,30 @@ static void fm10k_print_fault(struct fm10k_intfc *interface, int type,
 		 "%s Address: 0x%llx SpecInfo: 0x%x Func: %02x.%0x\n",
 		 error, fault->address, fault->specinfo,
 		 PCI_SLOT(fault->func), PCI_FUNC(fault->func));
+
+	/* For VF faults, clear out the respective LPORT, reset the queue
+	 * resources, and then reconnect to the mailbox. This allows the
+	 * VF in question to resume behavior. For transient faults that are
+	 * the result of non-malicious behavior this will log the fault and
+	 * allow the VF to resume functionality. Obviously for malicious VFs
+	 * they will be able to attempt malicious behavior again. In this
+	 * case, the system administrator will need to step in and manually
+	 * remove or disable the VF in question.
+	 */
+	if (fault->func && iov_data) {
+		int vf = fault->func - 1;
+		struct fm10k_vf_info *vf_info = &iov_data->vf_info[vf];
+
+		hw->iov.ops.reset_lport(hw, vf_info);
+		hw->iov.ops.reset_resources(hw, vf_info);
+
+		/* reset_lport disables the VF, so re-enable it */
+		hw->iov.ops.set_lport(hw, vf_info, vf,
+				      FM10K_VF_FLAG_MULTI_CAPABLE);
+
+		/* reset_resources will disconnect from the mbx  */
+		vf_info->mbx.ops.connect(hw, &vf_info->mbx);
+	}
 }
 
 static void fm10k_report_fault(struct fm10k_intfc *interface, u32 eicr)
@@ -960,7 +986,7 @@ static void fm10k_report_fault(struct fm10k_intfc *interface, u32 eicr)
 			continue;
 		}
 
-		fm10k_print_fault(interface, type, &fault);
+		fm10k_handle_fault(interface, type, &fault);
 	}
 }
 
-- 
2.4.3
