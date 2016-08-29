From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] fm10k: don't re-map queues when a mailbox message suffices
Date: Mon, 29 Aug 2016 02:13:46 -0700
Message-ID: <1472462026-42133-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44642 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932511AbcH2JNw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:52 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When the PF assigns a new MAC address to a VF it uses the base address
registers to store the MAC address. This allows a VF which loads after
this setup the ability to get the initial address without having to wait
for a mailbox message. Unfortunately to do this, the PF must take queue
ownership away from the VF, which can cause fault errors when there is
already an active VF driver.

This queue ownership assignment causes race condition between the PF and
the VF such that potentially a VF can cause FUM fault errors due to
normal PF/VF driver behavior.

It is not safe to simply allow the PF to write the base address
registers without taking queue ownership back as the PF must also
disable the queues, and this would impact active VF use. The current
code is safe because the queue ownership will prevent the VF from
actually writing but does trigger the FUM fault.

We can do better by simply avoiding the register write process when
a mailbox message suffices. If the message can be sent over the mailbox,
then we will not perform the queue ownership assignment and we won't
update the base address to be the same as the MAC address.

We do still have to write the TXQCTL registers in order to update the
VID of the queue. This is necessary because the TXQCTL register is
read-only from the VF, and thus the VF cannot do this for itself. This
register does not need to wait for the Tx queue to be disabled and is
safe for the PF to write during normal VF operation, so we move this
write to the top of the function above the mailbox message. Without
this, the TXQCTL register would be misconfigured and cause the VF to Tx
hang.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 46 ++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 682299d..23fb319 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -867,10 +867,6 @@ static s32 fm10k_iov_assign_default_mac_vlan_pf(struct fm10k_hw *hw,
 	vf_q_idx = fm10k_vf_queue_index(hw, vf_idx);
 	qmap_idx = qmap_stride * vf_idx;
 
-	/* MAP Tx queue back to 0 temporarily, and disable it */
-	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), 0);
-	fm10k_write_reg(hw, FM10K_TXDCTL(vf_q_idx), 0);
-
 	/* Determine correct default VLAN ID. The FM10K_VLAN_OVERRIDE bit is
 	 * used here to indicate to the VF that it will not have privilege to
 	 * write VLAN_TABLE. All policy is enforced on the PF but this allows
@@ -886,9 +882,35 @@ static s32 fm10k_iov_assign_default_mac_vlan_pf(struct fm10k_hw *hw,
 	fm10k_tlv_attr_put_mac_vlan(msg, FM10K_MAC_VLAN_MSG_DEFAULT_MAC,
 				    vf_info->mac, vf_vid);
 
-	/* load onto outgoing mailbox, ignore any errors on enqueue */
-	if (vf_info->mbx.ops.enqueue_tx)
-		vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
+	/* Configure Queue control register with new VLAN ID. The TXQCTL
+	 * register is RO from the VF, so the PF must do this even in the
+	 * case of notifying the VF of a new VID via the mailbox.
+	 */
+	txqctl = ((u32)vf_vid << FM10K_TXQCTL_VID_SHIFT) &
+		 FM10K_TXQCTL_VID_MASK;
+	txqctl |= (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
+		  FM10K_TXQCTL_VF | vf_idx;
+
+	for (i = 0; i < queues_per_pool; i++)
+		fm10k_write_reg(hw, FM10K_TXQCTL(vf_q_idx + i), txqctl);
+
+	/* try loading a message onto outgoing mailbox first */
+	if (vf_info->mbx.ops.enqueue_tx) {
+		err = vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
+		if (err != FM10K_MBX_ERR_NO_MBX)
+			return err;
+		err = 0;
+	}
+
+	/* If we aren't connected to a mailbox, this is most likely because
+	 * the VF driver is not running. It should thus be safe to re-map
+	 * queues and use the registers to pass the MAC address so that the VF
+	 * driver gets correct information during its initialization.
+	 */
+
+	/* MAP Tx queue back to 0 temporarily, and disable it */
+	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), 0);
+	fm10k_write_reg(hw, FM10K_TXDCTL(vf_q_idx), 0);
 
 	/* verify ring has disabled before modifying base address registers */
 	txdctl = fm10k_read_reg(hw, FM10K_TXDCTL(vf_q_idx));
@@ -927,16 +949,6 @@ static s32 fm10k_iov_assign_default_mac_vlan_pf(struct fm10k_hw *hw,
 						   FM10K_TDLEN_ITR_SCALE_SHIFT);
 
 err_out:
-	/* configure Queue control register */
-	txqctl = ((u32)vf_vid << FM10K_TXQCTL_VID_SHIFT) &
-		 FM10K_TXQCTL_VID_MASK;
-	txqctl |= (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
-		  FM10K_TXQCTL_VF | vf_idx;
-
-	/* assign VLAN ID */
-	for (i = 0; i < queues_per_pool; i++)
-		fm10k_write_reg(hw, FM10K_TXQCTL(vf_q_idx + i), txqctl);
-
 	/* restore the queue back to VF ownership */
 	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), vf_q_idx);
 	return err;
-- 
2.7.4
