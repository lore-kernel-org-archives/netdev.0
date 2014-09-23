From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 24/29] fm10k: Add support for SR-IOV to PF core files
Date: Tue, 23 Sep 2014 04:16:52 -0700
Message-ID: <1411471017-28213-25-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52942 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816AbaIWLRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:25 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a set of functions to fm10k_pf.c which allows for
configuring the VF via a set of standardized TLV messages.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 808 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h   |   9 +
 drivers/net/ethernet/intel/fm10k/fm10k_type.h |  58 ++
 3 files changed, 874 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 8da382c..0b6ce10 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -19,6 +19,7 @@
  */
 
 #include "fm10k_pf.h"
+#include "fm10k_vf.h"
 
 /**
  *  fm10k_reset_hw_pf - PF hardware reset
@@ -75,6 +76,19 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 }
 
 /**
+ *  fm10k_is_ari_hierarchy_pf - Indicate ARI hierarchy support
+ *  @hw: pointer to hardware structure
+ *
+ *  Looks at the ARI hierarchy bit to determine whether ARI is supported or not.
+ **/
+static bool fm10k_is_ari_hierarchy_pf(struct fm10k_hw *hw)
+{
+	u16 sriov_ctrl = fm10k_read_pci_cfg_word(hw, FM10K_PCIE_SRIOV_CTRL);
+
+	return !!(sriov_ctrl & FM10K_PCIE_SRIOV_CTRL_VFARI);
+}
+
+/**
  *  fm10k_init_hw_pf - PF hardware initialization
  *  @hw: pointer to hardware structure
  *
@@ -164,6 +178,9 @@ static s32 fm10k_init_hw_pf(struct fm10k_hw *hw)
 	/* record maximum queue count, we limit ourselves to 128 */
 	hw->mac.max_queues = FM10K_MAX_QUEUES_PF;
 
+	/* We support either 64 VFs or 7 VFs depending on if we have ARI */
+	hw->iov.total_vfs = fm10k_is_ari_hierarchy_pf(hw) ? 64 : 7;
+
 	return 0;
 }
 
@@ -444,7 +461,8 @@ static void fm10k_update_int_moderator_pf(struct fm10k_hw *hw)
 	fm10k_write_reg(hw, FM10K_ITR2(FM10K_ITR_REG_COUNT_PF), i);
 
 	/* reset ITR2[0] to point to last enabled PF vector */
-	fm10k_write_reg(hw, FM10K_ITR2(0), i);
+	if (!hw->iov.num_vfs)
+		fm10k_write_reg(hw, FM10K_ITR2(0), i);
 
 	/* Enable interrupt moderator */
 	fm10k_write_reg(hw, FM10K_INT_CTRL, FM10K_INT_CTRL_ENABLEMODERATOR);
@@ -571,6 +589,782 @@ static s32 fm10k_configure_dglort_map_pf(struct fm10k_hw *hw,
 	return 0;
 }
 
+u16 fm10k_queues_per_pool(struct fm10k_hw *hw)
+{
+	u16 num_pools = hw->iov.num_pools;
+
+	return (num_pools > 32) ? 2 : (num_pools > 16) ? 4 : (num_pools > 8) ?
+	       8 : FM10K_MAX_QUEUES_POOL;
+}
+
+u16 fm10k_vf_queue_index(struct fm10k_hw *hw, u16 vf_idx)
+{
+	u16 num_vfs = hw->iov.num_vfs;
+	u16 vf_q_idx = FM10K_MAX_QUEUES;
+
+	vf_q_idx -= fm10k_queues_per_pool(hw) * (num_vfs - vf_idx);
+
+	return vf_q_idx;
+}
+
+static u16 fm10k_vectors_per_pool(struct fm10k_hw *hw)
+{
+	u16 num_pools = hw->iov.num_pools;
+
+	return (num_pools > 32) ? 8 : (num_pools > 16) ? 16 :
+	       FM10K_MAX_VECTORS_POOL;
+}
+
+static u16 fm10k_vf_vector_index(struct fm10k_hw *hw, u16 vf_idx)
+{
+	u16 vf_v_idx = FM10K_MAX_VECTORS_PF;
+
+	vf_v_idx += fm10k_vectors_per_pool(hw) * vf_idx;
+
+	return vf_v_idx;
+}
+
+/**
+ *  fm10k_iov_assign_resources_pf - Assign pool resources for virtualization
+ *  @hw: pointer to the HW structure
+ *  @num_vfs: number of VFs to be allocated
+ *  @num_pools: number of virtualization pools to be allocated
+ *
+ *  Allocates queues and traffic classes to virtualization entities to prepare
+ *  the PF for SR-IOV and VMDq
+ **/
+static s32 fm10k_iov_assign_resources_pf(struct fm10k_hw *hw, u16 num_vfs,
+					 u16 num_pools)
+{
+	u16 qmap_stride, qpp, vpp, vf_q_idx, vf_q_idx0, qmap_idx;
+	u32 vid = hw->mac.default_vid << FM10K_TXQCTL_VID_SHIFT;
+	int i, j;
+
+	/* hardware only supports up to 64 pools */
+	if (num_pools > 64)
+		return FM10K_ERR_PARAM;
+
+	/* the number of VFs cannot exceed the number of pools */
+	if ((num_vfs > num_pools) || (num_vfs > hw->iov.total_vfs))
+		return FM10K_ERR_PARAM;
+
+	/* record number of virtualization entities */
+	hw->iov.num_vfs = num_vfs;
+	hw->iov.num_pools = num_pools;
+
+	/* determine qmap offsets and counts */
+	qmap_stride = (num_vfs > 8) ? 32 : 256;
+	qpp = fm10k_queues_per_pool(hw);
+	vpp = fm10k_vectors_per_pool(hw);
+
+	/* calculate starting index for queues */
+	vf_q_idx = fm10k_vf_queue_index(hw, 0);
+	qmap_idx = 0;
+
+	/* establish TCs with -1 credits and no quanta to prevent transmit */
+	for (i = 0; i < num_vfs; i++) {
+		fm10k_write_reg(hw, FM10K_TC_MAXCREDIT(i), 0);
+		fm10k_write_reg(hw, FM10K_TC_RATE(i), 0);
+		fm10k_write_reg(hw, FM10K_TC_CREDIT(i),
+				FM10K_TC_CREDIT_CREDIT_MASK);
+	}
+
+	/* zero out all mbmem registers */
+	for (i = FM10K_VFMBMEM_LEN * num_vfs; i--;)
+		fm10k_write_reg(hw, FM10K_MBMEM(i), 0);
+
+	/* clear event notification of VF FLR */
+	fm10k_write_reg(hw, FM10K_PFVFLREC(0), ~0);
+	fm10k_write_reg(hw, FM10K_PFVFLREC(1), ~0);
+
+	/* loop through unallocated rings assigning them back to PF */
+	for (i = FM10K_MAX_QUEUES_PF; i < vf_q_idx; i++) {
+		fm10k_write_reg(hw, FM10K_TXDCTL(i), 0);
+		fm10k_write_reg(hw, FM10K_TXQCTL(i), FM10K_TXQCTL_PF | vid);
+		fm10k_write_reg(hw, FM10K_RXQCTL(i), FM10K_RXQCTL_PF);
+	}
+
+	/* PF should have already updated VFITR2[0] */
+
+	/* update all ITR registers to flow to VFITR2[0] */
+	for (i = FM10K_ITR_REG_COUNT_PF + 1; i < FM10K_ITR_REG_COUNT; i++) {
+		if (!(i & (vpp - 1)))
+			fm10k_write_reg(hw, FM10K_ITR2(i), i - vpp);
+		else
+			fm10k_write_reg(hw, FM10K_ITR2(i), i - 1);
+	}
+
+	/* update PF ITR2[0] to reference the last vector */
+	fm10k_write_reg(hw, FM10K_ITR2(0),
+			fm10k_vf_vector_index(hw, num_vfs - 1));
+
+	/* loop through rings populating rings and TCs */
+	for (i = 0; i < num_vfs; i++) {
+		/* record index for VF queue 0 for use in end of loop */
+		vf_q_idx0 = vf_q_idx;
+
+		for (j = 0; j < qpp; j++, qmap_idx++, vf_q_idx++) {
+			/* assign VF and locked TC to queues */
+			fm10k_write_reg(hw, FM10K_TXDCTL(vf_q_idx), 0);
+			fm10k_write_reg(hw, FM10K_TXQCTL(vf_q_idx),
+					(i << FM10K_TXQCTL_TC_SHIFT) | i |
+					FM10K_TXQCTL_VF | vid);
+			fm10k_write_reg(hw, FM10K_RXDCTL(vf_q_idx),
+					FM10K_RXDCTL_WRITE_BACK_MIN_DELAY |
+					FM10K_RXDCTL_DROP_ON_EMPTY);
+			fm10k_write_reg(hw, FM10K_RXQCTL(vf_q_idx),
+					FM10K_RXQCTL_VF |
+					(i << FM10K_RXQCTL_VF_SHIFT));
+
+			/* map queue pair to VF */
+			fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), vf_q_idx);
+			fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx), vf_q_idx);
+		}
+
+		/* repeat the first ring for all of the remaining VF rings */
+		for (; j < qmap_stride; j++, qmap_idx++) {
+			fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), vf_q_idx0);
+			fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx), vf_q_idx0);
+		}
+	}
+
+	/* loop through remaining indexes assigning all to queue 0 */
+	while (qmap_idx < FM10K_TQMAP_TABLE_SIZE) {
+		fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), 0);
+		fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx), 0);
+		qmap_idx++;
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_iov_configure_tc_pf - Configure the shaping group for VF
+ *  @hw: pointer to the HW structure
+ *  @vf_idx: index of VF receiving GLORT
+ *  @rate: Rate indicated in Mb/s
+ *
+ *  Configured the TC for a given VF to allow only up to a given number
+ *  of Mb/s of outgoing Tx throughput.
+ **/
+static s32 fm10k_iov_configure_tc_pf(struct fm10k_hw *hw, u16 vf_idx, int rate)
+{
+	/* configure defaults */
+	u32 interval = FM10K_TC_RATE_INTERVAL_4US_GEN3;
+	u32 tc_rate = FM10K_TC_RATE_QUANTA_MASK;
+
+	/* verify vf is in range */
+	if (vf_idx >= hw->iov.num_vfs)
+		return FM10K_ERR_PARAM;
+
+	/* set interval to align with 4.096 usec in all modes */
+	switch (hw->bus.speed) {
+	case fm10k_bus_speed_2500:
+		interval = FM10K_TC_RATE_INTERVAL_4US_GEN1;
+		break;
+	case fm10k_bus_speed_5000:
+		interval = FM10K_TC_RATE_INTERVAL_4US_GEN2;
+		break;
+	default:
+		break;
+	}
+
+	if (rate) {
+		if (rate > FM10K_VF_TC_MAX || rate < FM10K_VF_TC_MIN)
+			return FM10K_ERR_PARAM;
+
+		/* The quanta is measured in Bytes per 4.096 or 8.192 usec
+		 * The rate is provided in Mbits per second
+		 * To tralslate from rate to quanta we need to multiply the
+		 * rate by 8.192 usec and divide by 8 bits/byte.  To avoid
+		 * dealing with floating point we can round the values up
+		 * to the nearest whole number ratio which gives us 128 / 125.
+		 */
+		tc_rate = (rate * 128) / 125;
+
+		/* try to keep the rate limiting accurate by increasing
+		 * the number of credits and interval for rates less than 4Gb/s
+		 */
+		if (rate < 4000)
+			interval <<= 1;
+		else
+			tc_rate >>= 1;
+	}
+
+	/* update rate limiter with new values */
+	fm10k_write_reg(hw, FM10K_TC_RATE(vf_idx), tc_rate | interval);
+	fm10k_write_reg(hw, FM10K_TC_MAXCREDIT(vf_idx), FM10K_TC_MAXCREDIT_64K);
+	fm10k_write_reg(hw, FM10K_TC_CREDIT(vf_idx), FM10K_TC_MAXCREDIT_64K);
+
+	return 0;
+}
+
+/**
+ *  fm10k_iov_assign_int_moderator_pf - Add VF interrupts to moderator list
+ *  @hw: pointer to the HW structure
+ *  @vf_idx: index of VF receiving GLORT
+ *
+ *  Update the interrupt moderator linked list to include any MSI-X
+ *  interrupts which the VF has enabled in the MSI-X vector table.
+ **/
+static s32 fm10k_iov_assign_int_moderator_pf(struct fm10k_hw *hw, u16 vf_idx)
+{
+	u16 vf_v_idx, vf_v_limit, i;
+
+	/* verify vf is in range */
+	if (vf_idx >= hw->iov.num_vfs)
+		return FM10K_ERR_PARAM;
+
+	/* determine vector offset and count*/
+	vf_v_idx = fm10k_vf_vector_index(hw, vf_idx);
+	vf_v_limit = vf_v_idx + fm10k_vectors_per_pool(hw);
+
+	/* search for first vector that is not masked */
+	for (i = vf_v_limit - 1; i > vf_v_idx; i--) {
+		if (!fm10k_read_reg(hw, FM10K_MSIX_VECTOR_MASK(i)))
+			break;
+	}
+
+	/* reset linked list so it now includes our active vectors */
+	if (vf_idx == (hw->iov.num_vfs - 1))
+		fm10k_write_reg(hw, FM10K_ITR2(0), i);
+	else
+		fm10k_write_reg(hw, FM10K_ITR2(vf_v_limit), i);
+
+	return 0;
+}
+
+/**
+ *  fm10k_iov_assign_default_mac_vlan_pf - Assign a MAC and VLAN to VF
+ *  @hw: pointer to the HW structure
+ *  @vf_info: pointer to VF information structure
+ *
+ *  Assign a MAC address and default VLAN to a VF and notify it of the update
+ **/
+static s32 fm10k_iov_assign_default_mac_vlan_pf(struct fm10k_hw *hw,
+						struct fm10k_vf_info *vf_info)
+{
+	u16 qmap_stride, queues_per_pool, vf_q_idx, timeout, qmap_idx, i;
+	u32 msg[4], txdctl, txqctl, tdbal = 0, tdbah = 0;
+	s32 err = 0;
+	u16 vf_idx, vf_vid;
+
+	/* verify vf is in range */
+	if (!vf_info || vf_info->vf_idx >= hw->iov.num_vfs)
+		return FM10K_ERR_PARAM;
+
+	/* determine qmap offsets and counts */
+	qmap_stride = (hw->iov.num_vfs > 8) ? 32 : 256;
+	queues_per_pool = fm10k_queues_per_pool(hw);
+
+	/* calculate starting index for queues */
+	vf_idx = vf_info->vf_idx;
+	vf_q_idx = fm10k_vf_queue_index(hw, vf_idx);
+	qmap_idx = qmap_stride * vf_idx;
+
+	/* MAP Tx queue back to 0 temporarily, and disable it */
+	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), 0);
+	fm10k_write_reg(hw, FM10K_TXDCTL(vf_q_idx), 0);
+
+	/* determine correct default VLAN ID */
+	if (vf_info->pf_vid)
+		vf_vid = vf_info->pf_vid | FM10K_VLAN_CLEAR;
+	else
+		vf_vid = vf_info->sw_vid;
+
+	/* generate MAC_ADDR request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_MAC_VLAN);
+	fm10k_tlv_attr_put_mac_vlan(msg, FM10K_MAC_VLAN_MSG_DEFAULT_MAC,
+				    vf_info->mac, vf_vid);
+
+	/* load onto outgoing mailbox, ignore any errors on enqueue */
+	if (vf_info->mbx.ops.enqueue_tx)
+		vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
+
+	/* verify ring has disabled before modifying base address registers */
+	txdctl = fm10k_read_reg(hw, FM10K_TXDCTL(vf_q_idx));
+	for (timeout = 0; txdctl & FM10K_TXDCTL_ENABLE; timeout++) {
+		/* limit ourselves to a 1ms timeout */
+		if (timeout == 10) {
+			err = FM10K_ERR_DMA_PENDING;
+			goto err_out;
+		}
+
+		usleep_range(100, 200);
+		txdctl = fm10k_read_reg(hw, FM10K_TXDCTL(vf_q_idx));
+	}
+
+	/* Update base address registers to contain MAC address */
+	if (is_valid_ether_addr(vf_info->mac)) {
+		tdbal = (((u32)vf_info->mac[3]) << 24) |
+			(((u32)vf_info->mac[4]) << 16) |
+			(((u32)vf_info->mac[5]) << 8);
+
+		tdbah = (((u32)0xFF)	        << 24) |
+			(((u32)vf_info->mac[0]) << 16) |
+			(((u32)vf_info->mac[1]) << 8) |
+			((u32)vf_info->mac[2]);
+	}
+
+	/* Record the base address into queue 0 */
+	fm10k_write_reg(hw, FM10K_TDBAL(vf_q_idx), tdbal);
+	fm10k_write_reg(hw, FM10K_TDBAH(vf_q_idx), tdbah);
+
+err_out:
+	/* configure Queue control register */
+	txqctl = ((u32)vf_vid << FM10K_TXQCTL_VID_SHIFT) &
+		 FM10K_TXQCTL_VID_MASK;
+	txqctl |= (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
+		  FM10K_TXQCTL_VF | vf_idx;
+
+	/* assign VID */
+	for (i = 0; i < queues_per_pool; i++)
+		fm10k_write_reg(hw, FM10K_TXQCTL(vf_q_idx + i), txqctl);
+
+	/* restore the queue back to VF ownership */
+	fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx), vf_q_idx);
+	return err;
+}
+
+/**
+ *  fm10k_iov_reset_resources_pf - Reassign queues and interrupts to a VF
+ *  @hw: pointer to the HW structure
+ *  @vf_info: pointer to VF information structure
+ *
+ *  Reassign the interrupts and queues to a VF following an FLR
+ **/
+static s32 fm10k_iov_reset_resources_pf(struct fm10k_hw *hw,
+					struct fm10k_vf_info *vf_info)
+{
+	u16 qmap_stride, queues_per_pool, vf_q_idx, qmap_idx;
+	u32 tdbal = 0, tdbah = 0, txqctl, rxqctl;
+	u16 vf_v_idx, vf_v_limit, vf_vid;
+	u8 vf_idx = vf_info->vf_idx;
+	int i;
+
+	/* verify vf is in range */
+	if (vf_idx >= hw->iov.num_vfs)
+		return FM10K_ERR_PARAM;
+
+	/* clear event notification of VF FLR */
+	fm10k_write_reg(hw, FM10K_PFVFLREC(vf_idx / 32), 1 << (vf_idx % 32));
+
+	/* force timeout and then disconnect the mailbox */
+	vf_info->mbx.timeout = 0;
+	if (vf_info->mbx.ops.disconnect)
+		vf_info->mbx.ops.disconnect(hw, &vf_info->mbx);
+
+	/* determine vector offset and count*/
+	vf_v_idx = fm10k_vf_vector_index(hw, vf_idx);
+	vf_v_limit = vf_v_idx + fm10k_vectors_per_pool(hw);
+
+	/* determine qmap offsets and counts */
+	qmap_stride = (hw->iov.num_vfs > 8) ? 32 : 256;
+	queues_per_pool = fm10k_queues_per_pool(hw);
+	qmap_idx = qmap_stride * vf_idx;
+
+	/* make all the queues inaccessible to the VF */
+	for (i = qmap_idx; i < (qmap_idx + qmap_stride); i++) {
+		fm10k_write_reg(hw, FM10K_TQMAP(i), 0);
+		fm10k_write_reg(hw, FM10K_RQMAP(i), 0);
+	}
+
+	/* calculate starting index for queues */
+	vf_q_idx = fm10k_vf_queue_index(hw, vf_idx);
+
+	/* determine correct default VLAN ID */
+	if (vf_info->pf_vid)
+		vf_vid = vf_info->pf_vid;
+	else
+		vf_vid = vf_info->sw_vid;
+
+	/* configure Queue control register */
+	txqctl = ((u32)vf_vid << FM10K_TXQCTL_VID_SHIFT) |
+		 (vf_idx << FM10K_TXQCTL_TC_SHIFT) |
+		 FM10K_TXQCTL_VF | vf_idx;
+	rxqctl = FM10K_RXQCTL_VF | (vf_idx << FM10K_RXQCTL_VF_SHIFT);
+
+	/* stop further DMA and reset queue ownership back to VF */
+	for (i = vf_q_idx; i < (queues_per_pool + vf_q_idx); i++) {
+		fm10k_write_reg(hw, FM10K_TXDCTL(i), 0);
+		fm10k_write_reg(hw, FM10K_TXQCTL(i), txqctl);
+		fm10k_write_reg(hw, FM10K_RXDCTL(i),
+				FM10K_RXDCTL_WRITE_BACK_MIN_DELAY |
+				FM10K_RXDCTL_DROP_ON_EMPTY);
+		fm10k_write_reg(hw, FM10K_RXQCTL(i), rxqctl);
+	}
+
+	/* reset TC with -1 credits and no quanta to prevent transmit */
+	fm10k_write_reg(hw, FM10K_TC_MAXCREDIT(vf_idx), 0);
+	fm10k_write_reg(hw, FM10K_TC_RATE(vf_idx), 0);
+	fm10k_write_reg(hw, FM10K_TC_CREDIT(vf_idx),
+			FM10K_TC_CREDIT_CREDIT_MASK);
+
+	/* update our first entry in the table based on previous VF */
+	if (!vf_idx)
+		hw->mac.ops.update_int_moderator(hw);
+	else
+		hw->iov.ops.assign_int_moderator(hw, vf_idx - 1);
+
+	/* reset linked list so it now includes our active vectors */
+	if (vf_idx == (hw->iov.num_vfs - 1))
+		fm10k_write_reg(hw, FM10K_ITR2(0), vf_v_idx);
+	else
+		fm10k_write_reg(hw, FM10K_ITR2(vf_v_limit), vf_v_idx);
+
+	/* link remaining vectors so that next points to previous */
+	for (vf_v_idx++; vf_v_idx < vf_v_limit; vf_v_idx++)
+		fm10k_write_reg(hw, FM10K_ITR2(vf_v_idx), vf_v_idx - 1);
+
+	/* zero out MBMEM, VLAN_TABLE, RETA, RSSRK, and MRQC registers */
+	for (i = FM10K_VFMBMEM_LEN; i--;)
+		fm10k_write_reg(hw, FM10K_MBMEM_VF(vf_idx, i), 0);
+	for (i = FM10K_VLAN_TABLE_SIZE; i--;)
+		fm10k_write_reg(hw, FM10K_VLAN_TABLE(vf_info->vsi, i), 0);
+	for (i = FM10K_RETA_SIZE; i--;)
+		fm10k_write_reg(hw, FM10K_RETA(vf_info->vsi, i), 0);
+	for (i = FM10K_RSSRK_SIZE; i--;)
+		fm10k_write_reg(hw, FM10K_RSSRK(vf_info->vsi, i), 0);
+	fm10k_write_reg(hw, FM10K_MRQC(vf_info->vsi), 0);
+
+	/* Update base address registers to contain MAC address */
+	if (is_valid_ether_addr(vf_info->mac)) {
+		tdbal = (((u32)vf_info->mac[3]) << 24) |
+			(((u32)vf_info->mac[4]) << 16) |
+			(((u32)vf_info->mac[5]) << 8);
+		tdbah = (((u32)0xFF)	   << 24) |
+			(((u32)vf_info->mac[0]) << 16) |
+			(((u32)vf_info->mac[1]) << 8) |
+			((u32)vf_info->mac[2]);
+	}
+
+	/* map queue pairs back to VF from last to first*/
+	for (i = queues_per_pool; i--;) {
+		fm10k_write_reg(hw, FM10K_TDBAL(vf_q_idx + i), tdbal);
+		fm10k_write_reg(hw, FM10K_TDBAH(vf_q_idx + i), tdbah);
+		fm10k_write_reg(hw, FM10K_TQMAP(qmap_idx + i), vf_q_idx + i);
+		fm10k_write_reg(hw, FM10K_RQMAP(qmap_idx + i), vf_q_idx + i);
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_iov_set_lport_pf - Assign and enable a logical port for a given VF
+ *  @hw: pointer to hardware structure
+ *  @vf_info: pointer to VF information structure
+ *  @lport_idx: Logical port offset from the hardware glort
+ *  @flags: Set of capability flags to extend port beyond basic functionality
+ *
+ *  This function allows enabling a VF port by assigning it a GLORT and
+ *  setting the flags so that it can enable an Rx mode.
+ **/
+static s32 fm10k_iov_set_lport_pf(struct fm10k_hw *hw,
+				  struct fm10k_vf_info *vf_info,
+				  u16 lport_idx, u8 flags)
+{
+	u16 glort = (hw->mac.dglort_map + lport_idx) & FM10K_DGLORTMAP_NONE;
+
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	vf_info->vf_flags = flags | FM10K_VF_FLAG_NONE_CAPABLE;
+	vf_info->glort = glort;
+
+	return 0;
+}
+
+/**
+ *  fm10k_iov_reset_lport_pf - Disable a logical port for a given VF
+ *  @hw: pointer to hardware structure
+ *  @vf_info: pointer to VF information structure
+ *
+ *  This function disables a VF port by stripping it of a GLORT and
+ *  setting the flags so that it cannot enable any Rx mode.
+ **/
+static void fm10k_iov_reset_lport_pf(struct fm10k_hw *hw,
+				     struct fm10k_vf_info *vf_info)
+{
+	u32 msg[1];
+
+	/* need to disable the port if it is already enabled */
+	if (FM10K_VF_FLAG_ENABLED(vf_info)) {
+		/* notify switch that this port has been disabled */
+		fm10k_update_lport_state_pf(hw, vf_info->glort, 1, false);
+
+		/* generate port state response to notify VF it is not ready */
+		fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_LPORT_STATE);
+		vf_info->mbx.ops.enqueue_tx(hw, &vf_info->mbx, msg);
+	}
+
+	/* clear flags and glort if it exists */
+	vf_info->vf_flags = 0;
+	vf_info->glort = 0;
+}
+
+/**
+ *  fm10k_iov_update_stats_pf - Updates hardware related statistics for VFs
+ *  @hw: pointer to hardware structure
+ *  @q: stats for all queues of a VF
+ *  @vf_idx: index of VF
+ *
+ *  This function collects queue stats for VFs.
+ **/
+static void fm10k_iov_update_stats_pf(struct fm10k_hw *hw,
+				      struct fm10k_hw_stats_q *q,
+				      u16 vf_idx)
+{
+	u32 idx, qpp;
+
+	/* get stats for all of the queues */
+	qpp = fm10k_queues_per_pool(hw);
+	idx = fm10k_vf_queue_index(hw, vf_idx);
+	fm10k_update_hw_stats_q(hw, q, idx, qpp);
+}
+
+/**
+ *  fm10k_iov_msg_msix_pf - Message handler for MSI-X request from VF
+ *  @hw: Pointer to hardware structure
+ *  @results: Pointer array to message, results[0] is pointer to message
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This function is a default handler for MSI-X requests from the VF.  The
+ *  assumption is that in this case it is acceptable to just directly
+ *  hand off the message form the VF to the underlying shared code.
+ **/
+s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *hw, u32 **results,
+			  struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_vf_info *vf_info = (struct fm10k_vf_info *)mbx;
+	u8 vf_idx = vf_info->vf_idx;
+
+	return hw->iov.ops.assign_int_moderator(hw, vf_idx);
+}
+
+/**
+ *  fm10k_iov_msg_mac_vlan_pf - Message handler for MAC/VLAN request from VF
+ *  @hw: Pointer to hardware structure
+ *  @results: Pointer array to message, results[0] is pointer to message
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This function is a default handler for MAC/VLAN requests from the VF.
+ *  The assumption is that in this case it is acceptable to just directly
+ *  hand off the message form the VF to the underlying shared code.
+ **/
+s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
+			      struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_vf_info *vf_info = (struct fm10k_vf_info *)mbx;
+	int err = 0;
+	u8 mac[ETH_ALEN];
+	u32 *result;
+	u16 vlan;
+	u32 vid;
+
+	/* we shouldn't be updating rules on a disabled interface */
+	if (!FM10K_VF_FLAG_ENABLED(vf_info))
+		err = FM10K_ERR_PARAM;
+
+	if (!err && !!results[FM10K_MAC_VLAN_MSG_VLAN]) {
+		result = results[FM10K_MAC_VLAN_MSG_VLAN];
+
+		/* record VLAN id requested */
+		err = fm10k_tlv_attr_get_u32(result, &vid);
+		if (err)
+			return err;
+
+		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
+		if (!vid || (vid == FM10K_VLAN_CLEAR)) {
+			if (vf_info->pf_vid)
+				vid |= vf_info->pf_vid;
+			else
+				vid |= vf_info->sw_vid;
+		} else if (vid != vf_info->pf_vid) {
+			return FM10K_ERR_PARAM;
+		}
+
+		/* update VSI info for VF in regards to VLAN table */
+		err = hw->mac.ops.update_vlan(hw, vid, vf_info->vsi,
+					      !(vid & FM10K_VLAN_CLEAR));
+	}
+
+	if (!err && !!results[FM10K_MAC_VLAN_MSG_MAC]) {
+		result = results[FM10K_MAC_VLAN_MSG_MAC];
+
+		/* record unicast MAC address requested */
+		err = fm10k_tlv_attr_get_mac_vlan(result, mac, &vlan);
+		if (err)
+			return err;
+
+		/* block attempts to set MAC for a locked device */
+		if (is_valid_ether_addr(vf_info->mac) &&
+		    memcmp(mac, vf_info->mac, ETH_ALEN))
+			return FM10K_ERR_PARAM;
+
+		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
+		if (!vlan || (vlan == FM10K_VLAN_CLEAR)) {
+			if (vf_info->pf_vid)
+				vlan |= vf_info->pf_vid;
+			else
+				vlan |= vf_info->sw_vid;
+		} else if (vf_info->pf_vid) {
+			return FM10K_ERR_PARAM;
+		}
+
+		/* notify switch of request for new unicast address */
+		err = hw->mac.ops.update_uc_addr(hw, vf_info->glort, mac, vlan,
+						 !(vlan & FM10K_VLAN_CLEAR), 0);
+	}
+
+	if (!err && !!results[FM10K_MAC_VLAN_MSG_MULTICAST]) {
+		result = results[FM10K_MAC_VLAN_MSG_MULTICAST];
+
+		/* record multicast MAC address requested */
+		err = fm10k_tlv_attr_get_mac_vlan(result, mac, &vlan);
+		if (err)
+			return err;
+
+		/* verify that the VF is allowed to request multicast */
+		if (!(vf_info->vf_flags & FM10K_VF_FLAG_MULTI_ENABLED))
+			return FM10K_ERR_PARAM;
+
+		/* if VLAN ID is 0, set the default VLAN ID instead of 0 */
+		if (!vlan || (vlan == FM10K_VLAN_CLEAR)) {
+			if (vf_info->pf_vid)
+				vlan |= vf_info->pf_vid;
+			else
+				vlan |= vf_info->sw_vid;
+		} else if (vf_info->pf_vid) {
+			return FM10K_ERR_PARAM;
+		}
+
+		/* notify switch of request for new multicast address */
+		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort, mac,
+						 !(vlan & FM10K_VLAN_CLEAR), 0);
+	}
+
+	return err;
+}
+
+/**
+ *  fm10k_iov_supported_xcast_mode_pf - Determine best match for xcast mode
+ *  @vf_info: VF info structure containing capability flags
+ *  @mode: Requested xcast mode
+ *
+ *  This function outputs the mode that most closely matches the requested
+ *  mode.  If not modes match it will request we disable the port
+ **/
+static u8 fm10k_iov_supported_xcast_mode_pf(struct fm10k_vf_info *vf_info,
+					    u8 mode)
+{
+	u8 vf_flags = vf_info->vf_flags;
+
+	/* match up mode to capabilities as best as possible */
+	switch (mode) {
+	case FM10K_XCAST_MODE_PROMISC:
+		if (vf_flags & FM10K_VF_FLAG_PROMISC_CAPABLE)
+			return FM10K_XCAST_MODE_PROMISC;
+		/* fallthough */
+	case FM10K_XCAST_MODE_ALLMULTI:
+		if (vf_flags & FM10K_VF_FLAG_ALLMULTI_CAPABLE)
+			return FM10K_XCAST_MODE_ALLMULTI;
+		/* fallthough */
+	case FM10K_XCAST_MODE_MULTI:
+		if (vf_flags & FM10K_VF_FLAG_MULTI_CAPABLE)
+			return FM10K_XCAST_MODE_MULTI;
+		/* fallthough */
+	case FM10K_XCAST_MODE_NONE:
+		if (vf_flags & FM10K_VF_FLAG_NONE_CAPABLE)
+			return FM10K_XCAST_MODE_NONE;
+		/* fallthough */
+	default:
+		break;
+	}
+
+	/* disable interface as it should not be able to request any */
+	return FM10K_XCAST_MODE_DISABLE;
+}
+
+/**
+ *  fm10k_iov_msg_lport_state_pf - Message handler for port state requests
+ *  @hw: Pointer to hardware structure
+ *  @results: Pointer array to message, results[0] is pointer to message
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This function is a default handler for port state requests.  The port
+ *  state requests for now are basic and consist of enabling or disabling
+ *  the port.
+ **/
+s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *hw, u32 **results,
+				 struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_vf_info *vf_info = (struct fm10k_vf_info *)mbx;
+	u32 *result;
+	s32 err = 0;
+	u32 msg[2];
+	u8 mode = 0;
+
+	/* verify VF is allowed to enable even minimal mode */
+	if (!(vf_info->vf_flags & FM10K_VF_FLAG_NONE_CAPABLE))
+		return FM10K_ERR_PARAM;
+
+	if (!!results[FM10K_LPORT_STATE_MSG_XCAST_MODE]) {
+		result = results[FM10K_LPORT_STATE_MSG_XCAST_MODE];
+
+		/* XCAST mode update requested */
+		err = fm10k_tlv_attr_get_u8(result, &mode);
+		if (err)
+			return FM10K_ERR_PARAM;
+
+		/* prep for possible demotion depending on capabilities */
+		mode = fm10k_iov_supported_xcast_mode_pf(vf_info, mode);
+
+		/* if mode is not currently enabled, enable it */
+		if (!(FM10K_VF_FLAG_ENABLED(vf_info) & (1 << mode)))
+			fm10k_update_xcast_mode_pf(hw, vf_info->glort, mode);
+
+		/* swap mode back to a bit flag */
+		mode = FM10K_VF_FLAG_SET_MODE(mode);
+	} else if (!results[FM10K_LPORT_STATE_MSG_DISABLE]) {
+		/* need to disable the port if it is already enabled */
+		if (FM10K_VF_FLAG_ENABLED(vf_info))
+			err = fm10k_update_lport_state_pf(hw, vf_info->glort,
+							  1, false);
+
+		/* when enabling the port we should reset the rate limiters */
+		hw->iov.ops.configure_tc(hw, vf_info->vf_idx, vf_info->rate);
+
+		/* set mode for minimal functionality */
+		mode = FM10K_VF_FLAG_SET_MODE_NONE;
+
+		/* generate port state response to notify VF it is ready */
+		fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_LPORT_STATE);
+		fm10k_tlv_attr_put_bool(msg, FM10K_LPORT_STATE_MSG_READY);
+		mbx->ops.enqueue_tx(hw, mbx, msg);
+	}
+
+	/* if enable state toggled note the update */
+	if (!err && (!FM10K_VF_FLAG_ENABLED(vf_info) != !mode))
+		err = fm10k_update_lport_state_pf(hw, vf_info->glort, 1,
+						  !!mode);
+
+	/* if state change succeeded, then update our stored state */
+	mode |= FM10K_VF_FLAG_CAPABLE(vf_info);
+	if (!err)
+		vf_info->vf_flags = mode;
+
+	return err;
+}
+
+const struct fm10k_msg_data fm10k_iov_msg_data_pf[] = {
+	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
+	FM10K_VF_MSG_MSIX_HANDLER(fm10k_iov_msg_msix_pf),
+	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_iov_msg_mac_vlan_pf),
+	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_iov_msg_lport_state_pf),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
+};
+
 /**
  *  fm10k_update_stats_hw_pf - Updates hardware related statistics of PF
  *  @hw: pointer to hardware structure
@@ -961,6 +1755,17 @@ static struct fm10k_mac_ops mac_ops_pf = {
 	.get_host_state		= &fm10k_get_host_state_pf,
 };
 
+static struct fm10k_iov_ops iov_ops_pf = {
+	.assign_resources		= &fm10k_iov_assign_resources_pf,
+	.configure_tc			= &fm10k_iov_configure_tc_pf,
+	.assign_int_moderator		= &fm10k_iov_assign_int_moderator_pf,
+	.assign_default_mac_vlan	= fm10k_iov_assign_default_mac_vlan_pf,
+	.reset_resources		= &fm10k_iov_reset_resources_pf,
+	.set_lport			= &fm10k_iov_set_lport_pf,
+	.reset_lport			= &fm10k_iov_reset_lport_pf,
+	.update_stats			= &fm10k_iov_update_stats_pf,
+};
+
 static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
 {
 	fm10k_get_invariants_generic(hw);
@@ -972,4 +1777,5 @@ struct fm10k_info fm10k_pf_info = {
 	.mac		= fm10k_mac_pf,
 	.get_invariants	= &fm10k_get_invariants_pf,
 	.mac_ops	= &mac_ops_pf,
+	.iov_ops	= &iov_ops_pf,
 };
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index 108a7a7..7ab1db4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -25,6 +25,8 @@
 #include "fm10k_common.h"
 
 bool fm10k_glort_valid_pf(struct fm10k_hw *hw, u16 glort);
+u16 fm10k_queues_per_pool(struct fm10k_hw *hw);
+u16 fm10k_vf_queue_index(struct fm10k_hw *hw, u16 vf_idx);
 
 enum fm10k_pf_tlv_msg_id_v1 {
 	FM10K_PF_MSG_ID_TEST			= 0x000, /* msg ID reserved */
@@ -122,5 +124,12 @@ extern const struct fm10k_tlv_attr fm10k_1588_timestamp_msg_attr[];
 	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_1588_TIMESTAMP, \
 			  fm10k_1588_timestamp_msg_attr, func)
 
+s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
+s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *, u32 **,
+			      struct fm10k_mbx_info *);
+s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *, u32 **,
+				 struct fm10k_mbx_info *);
+extern const struct fm10k_msg_data fm10k_iov_msg_data_pf[];
+
 extern struct fm10k_info fm10k_pf_info;
 #endif /* _FM10K_PF_H */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index cc1df60..ecaf93a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -567,6 +567,62 @@ enum fm10k_xcast_modes {
 	FM10K_XCAST_MODE_DISABLE	= 4
 };
 
+#define FM10K_VF_TC_MAX		100000	/* 100,000 Mb/s aka 100Gb/s */
+#define FM10K_VF_TC_MIN		1	/* 1 Mb/s is the slowest rate */
+
+struct fm10k_vf_info {
+	/* mbx must be first field in struct unless all default IOV message
+	 * handlers are redone as the assumption is that vf_info starts
+	 * at the same offset as the mailbox
+	 */
+	struct fm10k_mbx_info	mbx;		/* PF side of VF mailbox */
+	int			rate;		/* Tx BW cap as defined by OS */
+	u16			glort;		/* resource tag for this VF */
+	u16			sw_vid;		/* Switch API assigned VLAN */
+	u16			pf_vid;		/* PF assigned Default VLAN */
+	u8			mac[ETH_ALEN];	/* PF Default MAC address */
+	u8			vsi;		/* VSI idenfifier */
+	u8			vf_idx;		/* which VF this is */
+	u8			vf_flags;	/* flags indicating what modes
+						 * are supported for the port
+						 */
+};
+
+#define FM10K_VF_FLAG_ALLMULTI_CAPABLE	((u8)1 << FM10K_XCAST_MODE_ALLMULTI)
+#define FM10K_VF_FLAG_MULTI_CAPABLE	((u8)1 << FM10K_XCAST_MODE_MULTI)
+#define FM10K_VF_FLAG_PROMISC_CAPABLE	((u8)1 << FM10K_XCAST_MODE_PROMISC)
+#define FM10K_VF_FLAG_NONE_CAPABLE	((u8)1 << FM10K_XCAST_MODE_NONE)
+#define FM10K_VF_FLAG_CAPABLE(vf_info)	((vf_info)->vf_flags & (u8)0xF)
+#define FM10K_VF_FLAG_ENABLED(vf_info)	((vf_info)->vf_flags >> 4)
+#define FM10K_VF_FLAG_SET_MODE(mode)	((u8)0x10 << (mode))
+#define FM10K_VF_FLAG_SET_MODE_NONE \
+	FM10K_VF_FLAG_SET_MODE(FM10K_XCAST_MODE_NONE)
+#define FM10K_VF_FLAG_MULTI_ENABLED \
+	(FM10K_VF_FLAG_SET_MODE(FM10K_XCAST_MODE_ALLMULTI) | \
+	 FM10K_VF_FLAG_SET_MODE(FM10K_XCAST_MODE_MULTI) | \
+	 FM10K_VF_FLAG_SET_MODE(FM10K_XCAST_MODE_PROMISC))
+
+struct fm10k_iov_ops {
+	/* IOV related bring-up and tear-down */
+	s32 (*assign_resources)(struct fm10k_hw *, u16, u16);
+	s32 (*configure_tc)(struct fm10k_hw *, u16, int);
+	s32 (*assign_int_moderator)(struct fm10k_hw *, u16);
+	s32 (*assign_default_mac_vlan)(struct fm10k_hw *,
+				       struct fm10k_vf_info *);
+	s32 (*reset_resources)(struct fm10k_hw *,
+			       struct fm10k_vf_info *);
+	s32 (*set_lport)(struct fm10k_hw *, struct fm10k_vf_info *, u16, u8);
+	void (*reset_lport)(struct fm10k_hw *, struct fm10k_vf_info *);
+	void (*update_stats)(struct fm10k_hw *, struct fm10k_hw_stats_q *, u16);
+};
+
+struct fm10k_iov_info {
+	struct fm10k_iov_ops ops;
+	u16 total_vfs;
+	u16 num_vfs;
+	u16 num_pools;
+};
+
 enum fm10k_devices {
 	fm10k_device_pf,
 	fm10k_device_vf,
@@ -576,6 +632,7 @@ struct fm10k_info {
 	enum fm10k_mac_type	mac;
 	s32			(*get_invariants)(struct fm10k_hw *);
 	struct fm10k_mac_ops	*mac_ops;
+	struct fm10k_iov_ops	*iov_ops;
 };
 
 struct fm10k_hw {
@@ -584,6 +641,7 @@ struct fm10k_hw {
 	struct fm10k_mac_info mac;
 	struct fm10k_bus_info bus;
 	struct fm10k_bus_info bus_caps;
+	struct fm10k_iov_info iov;
 	struct fm10k_mbx_info mbx;
 	struct fm10k_swapi_info swapi;
 	u16 device_id;
-- 
1.9.3
