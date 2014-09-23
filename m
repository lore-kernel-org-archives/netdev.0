From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 08/29] fm10k: Add support for configuring PF interface
Date: Tue, 23 Sep 2014 04:16:36 -0700
Message-ID: <1411471017-28213-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15440 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315AbaIWLRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:08 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the operations which will configure filters on
the interface.  In addition with these patches we begin to introduce the PF
messages that will be sent to or received from the Switch Management
entity.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 587 +++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h |  98 +++++
 2 files changed, 683 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index b798cd5..8da382c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -181,6 +181,66 @@ static bool fm10k_is_slot_appropriate_pf(struct fm10k_hw *hw)
 }
 
 /**
+ *  fm10k_update_vlan_pf - Update status of VLAN ID in VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vid: VLAN ID to add to table
+ *  @vsi: Index indicating VF ID or PF ID in table
+ *  @set: Indicates if this is a set or clear operation
+ *
+ *  This function adds or removes the corresponding VLAN ID from the VLAN
+ *  filter table for the corresponding function.  In addition to the
+ *  standard set/clear that supports one bit a multi-bit write is
+ *  supported to set 64 bits at a time.
+ **/
+static s32 fm10k_update_vlan_pf(struct fm10k_hw *hw, u32 vid, u8 vsi, bool set)
+{
+	u32 vlan_table, reg, mask, bit, len;
+
+	/* verify the VSI index is valid */
+	if (vsi > FM10K_VLAN_TABLE_VSI_MAX)
+		return FM10K_ERR_PARAM;
+
+	/* VLAN multi-bit write:
+	 * The multi-bit write has several parts to it.
+	 *    3			  2		      1			  0
+	 *  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
+	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	 * | RSVD0 |         Length        |C|RSVD0|        VLAN ID        |
+	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+	 *
+	 * VLAN ID: Vlan Starting value
+	 * RSVD0: Reserved section, must be 0
+	 * C: Flag field, 0 is set, 1 is clear (Used in VF VLAN message)
+	 * Length: Number of times to repeat the bit being set
+	 */
+	len = vid >> 16;
+	vid = (vid << 17) >> 17;
+
+	/* verify the reserved 0 fields are 0 */
+	if (len >= FM10K_VLAN_TABLE_VID_MAX ||
+	    vid >= FM10K_VLAN_TABLE_VID_MAX)
+		return FM10K_ERR_PARAM;
+
+	/* Loop through the table updating all required VLANs */
+	for (reg = FM10K_VLAN_TABLE(vsi, vid / 32), bit = vid % 32;
+	     len < FM10K_VLAN_TABLE_VID_MAX;
+	     len -= 32 - bit, reg++, bit = 0) {
+		/* record the initial state of the register */
+		vlan_table = fm10k_read_reg(hw, reg);
+
+		/* truncate mask if we are at the start or end of the run */
+		mask = (~(u32)0 >> ((len < 31) ? 31 - len : 0)) << bit;
+
+		/* make necessary modifications to the register */
+		mask &= set ? ~vlan_table : vlan_table;
+		if (mask)
+			fm10k_write_reg(hw, reg, vlan_table ^ mask);
+	}
+
+	return 0;
+}
+
+/**
  *  fm10k_read_mac_addr_pf - Read device MAC address
  *  @hw: pointer to the HW structure
  *
@@ -221,6 +281,297 @@ static s32 fm10k_read_mac_addr_pf(struct fm10k_hw *hw)
 }
 
 /**
+ *  fm10k_glort_valid_pf - Validate that the provided glort is valid
+ *  @hw: pointer to the HW structure
+ *  @glort: base glort to be validated
+ *
+ *  This function will return an error if the provided glort is invalid
+ **/
+bool fm10k_glort_valid_pf(struct fm10k_hw *hw, u16 glort)
+{
+	glort &= hw->mac.dglort_map >> FM10K_DGLORTMAP_MASK_SHIFT;
+
+	return glort == (hw->mac.dglort_map & FM10K_DGLORTMAP_NONE);
+}
+
+/**
+ *  fm10k_update_uc_addr_pf - Update device unicast addresss
+ *  @hw: pointer to the HW structure
+ *  @glort: base resource tag for this request
+ *  @mac: MAC address to add/remove from table
+ *  @vid: VLAN ID to add/remove from table
+ *  @add: Indicates if this is an add or remove operation
+ *  @flags: flags field to indicate add and secure
+ *
+ *  This function generates a message to the Switch API requesting
+ *  that the given logical port add/remove the given L2 MAC/VLAN address.
+ **/
+static s32 fm10k_update_xc_addr_pf(struct fm10k_hw *hw, u16 glort,
+				   const u8 *mac, u16 vid, bool add, u8 flags)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	struct fm10k_mac_update mac_update;
+	u32 msg[5];
+
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	/* drop upper 4 bits of VLAN ID */
+	vid = (vid << 4) >> 4;
+
+	/* record fields */
+	mac_update.mac_lower = cpu_to_le32(((u32)mac[2] << 24) |
+						 ((u32)mac[3] << 16) |
+						 ((u32)mac[4] << 8) |
+						 ((u32)mac[5]));
+	mac_update.mac_upper = cpu_to_le16(((u32)mac[0] << 8) |
+						 ((u32)mac[1]));
+	mac_update.vlan = cpu_to_le16(vid);
+	mac_update.glort = cpu_to_le16(glort);
+	mac_update.action = add ? 0 : 1;
+	mac_update.flags = flags;
+
+	/* populate mac_update fields */
+	fm10k_tlv_msg_init(msg, FM10K_PF_MSG_ID_UPDATE_MAC_FWD_RULE);
+	fm10k_tlv_attr_put_le_struct(msg, FM10K_PF_ATTR_ID_MAC_UPDATE,
+				     &mac_update, sizeof(mac_update));
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_uc_addr_pf - Update device unicast addresss
+ *  @hw: pointer to the HW structure
+ *  @glort: base resource tag for this request
+ *  @mac: MAC address to add/remove from table
+ *  @vid: VLAN ID to add/remove from table
+ *  @add: Indicates if this is an add or remove operation
+ *  @flags: flags field to indicate add and secure
+ *
+ *  This function is used to add or remove unicast addresses for
+ *  the PF.
+ **/
+static s32 fm10k_update_uc_addr_pf(struct fm10k_hw *hw, u16 glort,
+				   const u8 *mac, u16 vid, bool add, u8 flags)
+{
+	/* verify MAC address is valid */
+	if (!is_valid_ether_addr(mac))
+		return FM10K_ERR_PARAM;
+
+	return fm10k_update_xc_addr_pf(hw, glort, mac, vid, add, flags);
+}
+
+/**
+ *  fm10k_update_mc_addr_pf - Update device multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @glort: base resource tag for this request
+ *  @mac: MAC address to add/remove from table
+ *  @vid: VLAN ID to add/remove from table
+ *  @add: Indicates if this is an add or remove operation
+ *
+ *  This function is used to add or remove multicast MAC addresses for
+ *  the PF.
+ **/
+static s32 fm10k_update_mc_addr_pf(struct fm10k_hw *hw, u16 glort,
+				   const u8 *mac, u16 vid, bool add)
+{
+	/* verify multicast address is valid */
+	if (!is_multicast_ether_addr(mac))
+		return FM10K_ERR_PARAM;
+
+	return fm10k_update_xc_addr_pf(hw, glort, mac, vid, add, 0);
+}
+
+/**
+ *  fm10k_update_xcast_mode_pf - Request update of multicast mode
+ *  @hw: pointer to hardware structure
+ *  @glort: base resource tag for this request
+ *  @mode: integer value indicating mode being requested
+ *
+ *  This function will attempt to request a higher mode for the port
+ *  so that it can enable either multicast, multicast promiscuous, or
+ *  promiscuous mode of operation.
+ **/
+static s32 fm10k_update_xcast_mode_pf(struct fm10k_hw *hw, u16 glort, u8 mode)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[3], xcast_mode;
+
+	if (mode > FM10K_XCAST_MODE_NONE)
+		return FM10K_ERR_PARAM;
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	/* write xcast mode as a single u32 value,
+	 * lower 16 bits: glort
+	 * upper 16 bits: mode
+	 */
+	xcast_mode = ((u32)mode << 16) | glort;
+
+	/* generate message requesting to change xcast mode */
+	fm10k_tlv_msg_init(msg, FM10K_PF_MSG_ID_XCAST_MODES);
+	fm10k_tlv_attr_put_u32(msg, FM10K_PF_ATTR_ID_XCAST_MODE, xcast_mode);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_int_moderator_pf - Update interrupt moderator linked list
+ *  @hw: pointer to hardware structure
+ *
+ *  This function walks through the MSI-X vector table to determine the
+ *  number of active interrupts and based on that information updates the
+ *  interrupt moderator linked list.
+ **/
+static void fm10k_update_int_moderator_pf(struct fm10k_hw *hw)
+{
+	u32 i;
+
+	/* Disable interrupt moderator */
+	fm10k_write_reg(hw, FM10K_INT_CTRL, 0);
+
+	/* loop through PF from last to first looking enabled vectors */
+	for (i = FM10K_ITR_REG_COUNT_PF - 1; i; i--) {
+		if (!fm10k_read_reg(hw, FM10K_MSIX_VECTOR_MASK(i)))
+			break;
+	}
+
+	/* always reset VFITR2[0] to point to last enabled PF vector*/
+	fm10k_write_reg(hw, FM10K_ITR2(FM10K_ITR_REG_COUNT_PF), i);
+
+	/* reset ITR2[0] to point to last enabled PF vector */
+	fm10k_write_reg(hw, FM10K_ITR2(0), i);
+
+	/* Enable interrupt moderator */
+	fm10k_write_reg(hw, FM10K_INT_CTRL, FM10K_INT_CTRL_ENABLEMODERATOR);
+}
+
+/**
+ *  fm10k_update_lport_state_pf - Notify the switch of a change in port state
+ *  @hw: pointer to the HW structure
+ *  @glort: base resource tag for this request
+ *  @count: number of logical ports being updated
+ *  @enable: boolean value indicating enable or disable
+ *
+ *  This function is used to add/remove a logical port from the switch.
+ **/
+static s32 fm10k_update_lport_state_pf(struct fm10k_hw *hw, u16 glort,
+				       u16 count, bool enable)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[3], lport_msg;
+
+	/* do nothing if we are being asked to create or destroy 0 ports */
+	if (!count)
+		return 0;
+
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	/* construct the lport message from the 2 pieces of data we have */
+	lport_msg = ((u32)count << 16) | glort;
+
+	/* generate lport create/delete message */
+	fm10k_tlv_msg_init(msg, enable ? FM10K_PF_MSG_ID_LPORT_CREATE :
+					 FM10K_PF_MSG_ID_LPORT_DELETE);
+	fm10k_tlv_attr_put_u32(msg, FM10K_PF_ATTR_ID_PORT, lport_msg);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_configure_dglort_map_pf - Configures GLORT entry and queues
+ *  @hw: pointer to hardware structure
+ *  @dglort: pointer to dglort configuration structure
+ *
+ *  Reads the configuration structure contained in dglort_cfg and uses
+ *  that information to then populate a DGLORTMAP/DEC entry and the queues
+ *  to which it has been assigned.
+ **/
+static s32 fm10k_configure_dglort_map_pf(struct fm10k_hw *hw,
+					 struct fm10k_dglort_cfg *dglort)
+{
+	u16 glort, queue_count, vsi_count, pc_count;
+	u16 vsi, queue, pc, q_idx;
+	u32 txqctl, dglortdec, dglortmap;
+
+	/* verify the dglort pointer */
+	if (!dglort)
+		return FM10K_ERR_PARAM;
+
+	/* verify the dglort values */
+	if ((dglort->idx > 7) || (dglort->rss_l > 7) || (dglort->pc_l > 3) ||
+	    (dglort->vsi_l > 6) || (dglort->vsi_b > 64) ||
+	    (dglort->queue_l > 8) || (dglort->queue_b >= 256))
+		return FM10K_ERR_PARAM;
+
+	/* determine count of VSIs and queues */
+	queue_count = 1 << (dglort->rss_l + dglort->pc_l);
+	vsi_count = 1 << (dglort->vsi_l + dglort->queue_l);
+	glort = dglort->glort;
+	q_idx = dglort->queue_b;
+
+	/* configure SGLORT for queues */
+	for (vsi = 0; vsi < vsi_count; vsi++, glort++) {
+		for (queue = 0; queue < queue_count; queue++, q_idx++) {
+			if (q_idx >= FM10K_MAX_QUEUES)
+				break;
+
+			fm10k_write_reg(hw, FM10K_TX_SGLORT(q_idx), glort);
+			fm10k_write_reg(hw, FM10K_RX_SGLORT(q_idx), glort);
+		}
+	}
+
+	/* determine count of PCs and queues */
+	queue_count = 1 << (dglort->queue_l + dglort->rss_l + dglort->vsi_l);
+	pc_count = 1 << dglort->pc_l;
+
+	/* configure PC for Tx queues */
+	for (pc = 0; pc < pc_count; pc++) {
+		q_idx = pc + dglort->queue_b;
+		for (queue = 0; queue < queue_count; queue++) {
+			if (q_idx >= FM10K_MAX_QUEUES)
+				break;
+
+			txqctl = fm10k_read_reg(hw, FM10K_TXQCTL(q_idx));
+			txqctl &= ~FM10K_TXQCTL_PC_MASK;
+			txqctl |= pc << FM10K_TXQCTL_PC_SHIFT;
+			fm10k_write_reg(hw, FM10K_TXQCTL(q_idx), txqctl);
+
+			q_idx += pc_count;
+		}
+	}
+
+	/* configure DGLORTDEC */
+	dglortdec = ((u32)(dglort->rss_l) << FM10K_DGLORTDEC_RSSLENGTH_SHIFT) |
+		    ((u32)(dglort->queue_b) << FM10K_DGLORTDEC_QBASE_SHIFT) |
+		    ((u32)(dglort->pc_l) << FM10K_DGLORTDEC_PCLENGTH_SHIFT) |
+		    ((u32)(dglort->vsi_b) << FM10K_DGLORTDEC_VSIBASE_SHIFT) |
+		    ((u32)(dglort->vsi_l) << FM10K_DGLORTDEC_VSILENGTH_SHIFT) |
+		    ((u32)(dglort->queue_l));
+	if (dglort->inner_rss)
+		dglortdec |=  FM10K_DGLORTDEC_INNERRSS_ENABLE;
+
+	/* configure DGLORTMAP */
+	dglortmap = (dglort->idx == fm10k_dglort_default) ?
+			FM10K_DGLORTMAP_ANY : FM10K_DGLORTMAP_ZERO;
+	dglortmap <<= dglort->vsi_l + dglort->queue_l + dglort->shared_l;
+	dglortmap |= dglort->glort;
+
+	/* write values to hardware */
+	fm10k_write_reg(hw, FM10K_DGLORTDEC(dglort->idx), dglortdec);
+	fm10k_write_reg(hw, FM10K_DGLORTMAP(dglort->idx), dglortmap);
+
+	return 0;
+}
+
+/**
  *  fm10k_update_stats_hw_pf - Updates hardware related statistics of PF
  *  @hw: pointer to hardware structure
  *  @stats: pointer to the stats structure to update
@@ -319,6 +670,22 @@ static void fm10k_rebind_hw_stats_pf(struct fm10k_hw *hw,
 }
 
 /**
+ *  fm10k_set_dma_mask_pf - Configures PhyAddrSpace to limit DMA to system
+ *  @hw: pointer to hardware structure
+ *  @dma_mask: 64 bit DMA mask required for platform
+ *
+ *  This function sets the PHYADDR.PhyAddrSpace bits for the endpoint in order
+ *  to limit the access to memory beyond what is physically in the system.
+ **/
+static void fm10k_set_dma_mask_pf(struct fm10k_hw *hw, u64 dma_mask)
+{
+	/* we need to write the upper 32 bits of DMA mask to PhyAddrSpace */
+	u32 phyaddr = (u32)(dma_mask >> 32);
+
+	fm10k_write_reg(hw, FM10K_PHYADDR, phyaddr);
+}
+
+/**
  *  fm10k_get_fault_pf - Record a fault in one of the interface units
  *  @hw: pointer to hardware structure
  *  @type: pointer to fault type register offset
@@ -371,6 +738,207 @@ static s32 fm10k_get_fault_pf(struct fm10k_hw *hw, int type,
 	return 0;
 }
 
+/**
+ *  fm10k_request_lport_map_pf - Request LPORT map from the switch API
+ *  @hw: pointer to hardware structure
+ *
+ **/
+static s32 fm10k_request_lport_map_pf(struct fm10k_hw *hw)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[1];
+
+	/* issue request asking for LPORT map */
+	fm10k_tlv_msg_init(msg, FM10K_PF_MSG_ID_LPORT_MAP);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_get_host_state_pf - Returns the state of the switch and mailbox
+ *  @hw: pointer to hardware structure
+ *  @switch_ready: pointer to boolean value that will record switch state
+ *
+ *  This funciton will check the DMA_CTRL2 register and mailbox in order
+ *  to determine if the switch is ready for the PF to begin requesting
+ *  addresses and mapping traffic to the local interface.
+ **/
+static s32 fm10k_get_host_state_pf(struct fm10k_hw *hw, bool *switch_ready)
+{
+	s32 ret_val = 0;
+	u32 dma_ctrl2;
+
+	/* verify the switch is ready for interraction */
+	dma_ctrl2 = fm10k_read_reg(hw, FM10K_DMA_CTRL2);
+	if (!(dma_ctrl2 & FM10K_DMA_CTRL2_SWITCH_READY))
+		goto out;
+
+	/* retrieve generic host state info */
+	ret_val = fm10k_get_host_state_generic(hw, switch_ready);
+	if (ret_val)
+		goto out;
+
+	/* interface cannot receive traffic without logical ports */
+	if (hw->mac.dglort_map == FM10K_DGLORTMAP_NONE)
+		ret_val = fm10k_request_lport_map_pf(hw);
+
+out:
+	return ret_val;
+}
+
+/* This structure defines the attibutes to be parsed below */
+const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[] = {
+	FM10K_TLV_ATTR_U32(FM10K_PF_ATTR_ID_LPORT_MAP),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_msg_lport_map_pf - Message handler for lport_map message from SM
+ *  @hw: Pointer to hardware structure
+ *  @results: pointer array containing parsed data
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This handler configures the lport mapping based on the reply from the
+ *  switch API.
+ **/
+s32 fm10k_msg_lport_map_pf(struct fm10k_hw *hw, u32 **results,
+			   struct fm10k_mbx_info *mbx)
+{
+	u16 glort, mask;
+	u32 dglort_map;
+	s32 err;
+
+	err = fm10k_tlv_attr_get_u32(results[FM10K_PF_ATTR_ID_LPORT_MAP],
+				     &dglort_map);
+	if (err)
+		return err;
+
+	/* extract values out of the header */
+	glort = FM10K_MSG_HDR_FIELD_GET(dglort_map, LPORT_MAP_GLORT);
+	mask = FM10K_MSG_HDR_FIELD_GET(dglort_map, LPORT_MAP_MASK);
+
+	/* verify mask is set and none of the masked bits in glort are set */
+	if (!mask || (glort & ~mask))
+		return FM10K_ERR_PARAM;
+
+	/* verify the mask is contiguous, and that it is 1's followed by 0's */
+	if (((~(mask - 1) & mask) + mask) & FM10K_DGLORTMAP_NONE)
+		return FM10K_ERR_PARAM;
+
+	/* record the glort, mask, and port count */
+	hw->mac.dglort_map = dglort_map;
+
+	return 0;
+}
+
+const struct fm10k_tlv_attr fm10k_update_pvid_msg_attr[] = {
+	FM10K_TLV_ATTR_U32(FM10K_PF_ATTR_ID_UPDATE_PVID),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_msg_update_pvid_pf - Message handler for port VLAN message from SM
+ *  @hw: Pointer to hardware structure
+ *  @results: pointer array containing parsed data
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This handler configures the default VLAN for the PF
+ **/
+s32 fm10k_msg_update_pvid_pf(struct fm10k_hw *hw, u32 **results,
+			     struct fm10k_mbx_info *mbx)
+{
+	u16 glort, pvid;
+	u32 pvid_update;
+	s32 err;
+
+	err = fm10k_tlv_attr_get_u32(results[FM10K_PF_ATTR_ID_UPDATE_PVID],
+				     &pvid_update);
+	if (err)
+		return err;
+
+	/* extract values from the pvid update */
+	glort = FM10K_MSG_HDR_FIELD_GET(pvid_update, UPDATE_PVID_GLORT);
+	pvid = FM10K_MSG_HDR_FIELD_GET(pvid_update, UPDATE_PVID_PVID);
+
+	/* if glort is not valid return error */
+	if (!fm10k_glort_valid_pf(hw, glort))
+		return FM10K_ERR_PARAM;
+
+	/* verify VID is valid */
+	if (pvid >= FM10K_VLAN_TABLE_VID_MAX)
+		return FM10K_ERR_PARAM;
+
+	/* record the port VLAN ID value */
+	hw->mac.default_vid = pvid;
+
+	return 0;
+}
+
+/**
+ *  fm10k_record_global_table_data - Move global table data to swapi table info
+ *  @from: pointer to source table data structure
+ *  @to: pointer to destination table info structure
+ *
+ *  This function is will copy table_data to the table_info contained in
+ *  the hw struct.
+ **/
+static void fm10k_record_global_table_data(struct fm10k_global_table_data *from,
+					   struct fm10k_swapi_table_info *to)
+{
+	/* convert from le32 struct to CPU byte ordered values */
+	to->used = le32_to_cpu(from->used);
+	to->avail = le32_to_cpu(from->avail);
+}
+
+const struct fm10k_tlv_attr fm10k_err_msg_attr[] = {
+	FM10K_TLV_ATTR_LE_STRUCT(FM10K_PF_ATTR_ID_ERR,
+				 sizeof(struct fm10k_swapi_error)),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_msg_err_pf - Message handler for error reply
+ *  @hw: Pointer to hardware structure
+ *  @results: pointer array containing parsed data
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This handler will capture the data for any error replies to previous
+ *  messages that the PF has sent.
+ **/
+s32 fm10k_msg_err_pf(struct fm10k_hw *hw, u32 **results,
+		     struct fm10k_mbx_info *mbx)
+{
+	struct fm10k_swapi_error err_msg;
+	s32 err;
+
+	/* extract structure from message */
+	err = fm10k_tlv_attr_get_le_struct(results[FM10K_PF_ATTR_ID_ERR],
+					   &err_msg, sizeof(err_msg));
+	if (err)
+		return err;
+
+	/* record table status */
+	fm10k_record_global_table_data(&err_msg.mac, &hw->swapi.mac);
+	fm10k_record_global_table_data(&err_msg.nexthop, &hw->swapi.nexthop);
+	fm10k_record_global_table_data(&err_msg.ffu, &hw->swapi.ffu);
+
+	/* record SW API status value */
+	hw->swapi.status = le32_to_cpu(err_msg.status);
+
+	return 0;
+}
+
+static const struct fm10k_msg_data fm10k_msg_data_pf[] = {
+	FM10K_PF_MSG_ERR_HANDLER(XCAST_MODES, fm10k_msg_err_pf),
+	FM10K_PF_MSG_ERR_HANDLER(UPDATE_MAC_FWD_RULE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_LPORT_MAP_HANDLER(fm10k_msg_lport_map_pf),
+	FM10K_PF_MSG_ERR_HANDLER(LPORT_CREATE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_ERR_HANDLER(LPORT_DELETE, fm10k_msg_err_pf),
+	FM10K_PF_MSG_UPDATE_PVID_HANDLER(fm10k_msg_update_pvid_pf),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
+};
+
 static struct fm10k_mac_ops mac_ops_pf = {
 	.get_bus_info		= &fm10k_get_bus_info_generic,
 	.reset_hw		= &fm10k_reset_hw_pf,
@@ -378,15 +946,30 @@ static struct fm10k_mac_ops mac_ops_pf = {
 	.start_hw		= &fm10k_start_hw_generic,
 	.stop_hw		= &fm10k_stop_hw_generic,
 	.is_slot_appropriate	= &fm10k_is_slot_appropriate_pf,
+	.update_vlan		= &fm10k_update_vlan_pf,
 	.read_mac_addr		= &fm10k_read_mac_addr_pf,
+	.update_uc_addr		= &fm10k_update_uc_addr_pf,
+	.update_mc_addr		= &fm10k_update_mc_addr_pf,
+	.update_xcast_mode	= &fm10k_update_xcast_mode_pf,
+	.update_int_moderator	= &fm10k_update_int_moderator_pf,
+	.update_lport_state	= &fm10k_update_lport_state_pf,
 	.update_hw_stats	= &fm10k_update_hw_stats_pf,
 	.rebind_hw_stats	= &fm10k_rebind_hw_stats_pf,
+	.configure_dglort_map	= &fm10k_configure_dglort_map_pf,
+	.set_dma_mask		= &fm10k_set_dma_mask_pf,
 	.get_fault		= &fm10k_get_fault_pf,
-	.get_host_state		= &fm10k_get_host_state_generic,
+	.get_host_state		= &fm10k_get_host_state_pf,
 };
 
+static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
+{
+	fm10k_get_invariants_generic(hw);
+
+	return fm10k_sm_mbx_init(hw, &hw->mbx, fm10k_msg_data_pf);
+}
+
 struct fm10k_info fm10k_pf_info = {
 	.mac		= fm10k_mac_pf,
-	.get_invariants	= &fm10k_get_invariants_generic,
+	.get_invariants	= &fm10k_get_invariants_pf,
 	.mac_ops	= &mac_ops_pf,
 };
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index 054392f..108a7a7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -24,5 +24,103 @@
 #include "fm10k_type.h"
 #include "fm10k_common.h"
 
+bool fm10k_glort_valid_pf(struct fm10k_hw *hw, u16 glort);
+
+enum fm10k_pf_tlv_msg_id_v1 {
+	FM10K_PF_MSG_ID_TEST			= 0x000, /* msg ID reserved */
+	FM10K_PF_MSG_ID_XCAST_MODES		= 0x001,
+	FM10K_PF_MSG_ID_UPDATE_MAC_FWD_RULE	= 0x002,
+	FM10K_PF_MSG_ID_LPORT_MAP		= 0x100,
+	FM10K_PF_MSG_ID_LPORT_CREATE		= 0x200,
+	FM10K_PF_MSG_ID_LPORT_DELETE		= 0x201,
+	FM10K_PF_MSG_ID_CONFIG			= 0x300,
+	FM10K_PF_MSG_ID_UPDATE_PVID		= 0x400,
+	FM10K_PF_MSG_ID_CREATE_FLOW_TABLE	= 0x501,
+	FM10K_PF_MSG_ID_DELETE_FLOW_TABLE	= 0x502,
+	FM10K_PF_MSG_ID_UPDATE_FLOW		= 0x503,
+	FM10K_PF_MSG_ID_DELETE_FLOW		= 0x504,
+	FM10K_PF_MSG_ID_SET_FLOW_STATE		= 0x505,
+	FM10K_PF_MSG_ID_GET_1588_INFO		= 0x506,
+	FM10K_PF_MSG_ID_1588_TIMESTAMP		= 0x701,
+};
+
+enum fm10k_pf_tlv_attr_id_v1 {
+	FM10K_PF_ATTR_ID_ERR			= 0x00,
+	FM10K_PF_ATTR_ID_LPORT_MAP		= 0x01,
+	FM10K_PF_ATTR_ID_XCAST_MODE		= 0x02,
+	FM10K_PF_ATTR_ID_MAC_UPDATE		= 0x03,
+	FM10K_PF_ATTR_ID_VLAN_UPDATE		= 0x04,
+	FM10K_PF_ATTR_ID_CONFIG			= 0x05,
+	FM10K_PF_ATTR_ID_CREATE_FLOW_TABLE	= 0x06,
+	FM10K_PF_ATTR_ID_DELETE_FLOW_TABLE	= 0x07,
+	FM10K_PF_ATTR_ID_UPDATE_FLOW		= 0x08,
+	FM10K_PF_ATTR_ID_FLOW_STATE		= 0x09,
+	FM10K_PF_ATTR_ID_FLOW_HANDLE		= 0x0A,
+	FM10K_PF_ATTR_ID_DELETE_FLOW		= 0x0B,
+	FM10K_PF_ATTR_ID_PORT			= 0x0C,
+	FM10K_PF_ATTR_ID_UPDATE_PVID		= 0x0D,
+	FM10K_PF_ATTR_ID_1588_TIMESTAMP		= 0x10,
+};
+
+#define FM10K_MSG_LPORT_MAP_GLORT_SHIFT	0
+#define FM10K_MSG_LPORT_MAP_GLORT_SIZE	16
+#define FM10K_MSG_LPORT_MAP_MASK_SHIFT	16
+#define FM10K_MSG_LPORT_MAP_MASK_SIZE	16
+
+#define FM10K_MSG_UPDATE_PVID_GLORT_SHIFT	0
+#define FM10K_MSG_UPDATE_PVID_GLORT_SIZE	16
+#define FM10K_MSG_UPDATE_PVID_PVID_SHIFT	16
+#define FM10K_MSG_UPDATE_PVID_PVID_SIZE		16
+
+struct fm10k_mac_update {
+	__le32	mac_lower;
+	__le16	mac_upper;
+	__le16	vlan;
+	__le16	glort;
+	u8	flags;
+	u8	action;
+};
+
+struct fm10k_global_table_data {
+	__le32	used;
+	__le32	avail;
+};
+
+struct fm10k_swapi_error {
+	__le32				status;
+	struct fm10k_global_table_data	mac;
+	struct fm10k_global_table_data	nexthop;
+	struct fm10k_global_table_data	ffu;
+};
+
+struct fm10k_swapi_1588_timestamp {
+	__le64 egress;
+	__le64 ingress;
+	__le16 dglort;
+	__le16 sglort;
+};
+
+s32 fm10k_msg_lport_map_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
+extern const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[];
+#define FM10K_PF_MSG_LPORT_MAP_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_LPORT_MAP, \
+			  fm10k_lport_map_msg_attr, func)
+s32 fm10k_msg_update_pvid_pf(struct fm10k_hw *, u32 **,
+			     struct fm10k_mbx_info *);
+extern const struct fm10k_tlv_attr fm10k_update_pvid_msg_attr[];
+#define FM10K_PF_MSG_UPDATE_PVID_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_UPDATE_PVID, \
+			  fm10k_update_pvid_msg_attr, func)
+
+s32 fm10k_msg_err_pf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
+extern const struct fm10k_tlv_attr fm10k_err_msg_attr[];
+#define FM10K_PF_MSG_ERR_HANDLER(msg, func) \
+	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_##msg, fm10k_err_msg_attr, func)
+
+extern const struct fm10k_tlv_attr fm10k_1588_timestamp_msg_attr[];
+#define FM10K_PF_MSG_1588_TIMESTAMP_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_PF_MSG_ID_1588_TIMESTAMP, \
+			  fm10k_1588_timestamp_msg_attr, func)
+
 extern struct fm10k_info fm10k_pf_info;
 #endif /* _FM10K_PF_H */
-- 
1.9.3
