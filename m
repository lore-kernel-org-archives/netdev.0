From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/5] ixgbe: Add support for the new ethtool
	n-tuple programming interface
Date: Wed, 06 Jan 2010 20:49:53 -0800
Message-ID: <20100107044952.28605.35232.stgit@localhost.localdomain>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Luca Deri <deri@ntop.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:51048 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932635Ab0AGEuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:50:14 -0500
In-Reply-To: <20100107044741.28605.31414.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds n-tuple filter programming to 82599.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Luca Deri <deri@ntop.org>
CC: Joseph Gasparakis <joseph.gasparakis@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    4 +
 drivers/net/ixgbe/ixgbe_82599.c   |  106 ++++++++++++++++++++++++++++++++-----
 drivers/net/ixgbe/ixgbe_ethtool.c |   81 ++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_type.h    |    9 +++
 4 files changed, 187 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5e60358..eba2880 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -429,6 +429,10 @@ extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
                                                  struct ixgbe_atr_input *input,
                                                  u8 queue);
+extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
+                                      struct ixgbe_atr_input *input,
+                                      struct ixgbe_atr_input_masks *input_masks,
+                                      u16 soft_id, u8 queue);
 extern s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input,
                                        u16 vlan_id);
 extern s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5383405..57c92f7 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1434,6 +1434,9 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
 	/* Send interrupt when 64 filters are left */
 	fdirctrl |= 4 << IXGBE_FDIRCTRL_FULL_THRESH_SHIFT;
 
+	/* Initialize the drop queue to Rx queue 127 */
+	fdirctrl |= (127 << IXGBE_FDIRCTRL_DROP_Q_SHIFT);
+
 	switch (pballoc) {
 	case IXGBE_FDIR_PBALLOC_64K:
 		/* 2k - 1 perfect filters */
@@ -1623,6 +1626,7 @@ static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
  *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
  *  @input: input stream to modify
  *  @vlan: the VLAN id to load
+ *  @vlan_mask: bitwise mask for the VLAN
  **/
 s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
 {
@@ -1636,6 +1640,7 @@ s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
  *  ixgbe_atr_set_src_ipv4_82599 - Sets the source IPv4 address
  *  @input: input stream to modify
  *  @src_addr: the IP address to load
+ *  @src_addr_mask: bitwise mask for the source IP address
  **/
 s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
 {
@@ -1653,6 +1658,7 @@ s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
  *  ixgbe_atr_set_dst_ipv4_82599 - Sets the destination IPv4 address
  *  @input: input stream to modify
  *  @dst_addr: the IP address to load
+ *  @dst_addr_mask: bitwise mask for the destination IP address
  **/
 s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
 {
@@ -1675,8 +1681,8 @@ s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
  *  @src_addr_4: the fourth 4 bytes of the IP address to load
  **/
 s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 src_addr_1, u32 src_addr_2,
-                                        u32 src_addr_3, u32 src_addr_4)
+                                 u32 src_addr_1, u32 src_addr_2,
+                                 u32 src_addr_3, u32 src_addr_4)
 {
 	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET] = src_addr_4 & 0xff;
 	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] =
@@ -1718,8 +1724,8 @@ s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
  *  @dst_addr_4: the fourth 4 bytes of the IP address to load
  **/
 s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
-                                        u32 dst_addr_1, u32 dst_addr_2,
-                                        u32 dst_addr_3, u32 dst_addr_4)
+                                 u32 dst_addr_1, u32 dst_addr_2,
+                                 u32 dst_addr_3, u32 dst_addr_4)
 {
 	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET] = dst_addr_4 & 0xff;
 	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] =
@@ -1756,6 +1762,7 @@ s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
  *  ixgbe_atr_set_src_port_82599 - Sets the source port
  *  @input: input stream to modify
  *  @src_port: the source port to load
+ *  @src_port_mask: bitwise mask for the source port
  **/
 s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
 {
@@ -1769,6 +1776,7 @@ s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
  *  ixgbe_atr_set_dst_port_82599 - Sets the destination port
  *  @input: input stream to modify
  *  @dst_port: the destination port to load
+ *  @dst_port_mask: bitwise mask for the destination port
  **/
 s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
 {
@@ -1797,7 +1805,7 @@ s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
  *  @vm_pool: the Virtual Machine pool to load
  **/
 s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
-                                       u8 vm_pool)
+                                u8 vm_pool)
 {
 	input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET] = vm_pool;
 
@@ -1821,8 +1829,7 @@ s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
  *  @input: input stream to search
  *  @vlan: the VLAN id to load
  **/
-static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input,
-                                       u16 *vlan)
+static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
 {
 	*vlan = input->byte_stream[IXGBE_ATR_VLAN_OFFSET];
 	*vlan |= input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] << 8;
@@ -2078,23 +2085,26 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
  *  ixgbe_fdir_add_perfect_filter_82599 - Adds a perfect filter
  *  @hw: pointer to hardware structure
  *  @input: input bitstream
+ *  @input_masks: bitwise masks for relevant fields
+ *  @soft_id: software index into the silicon hash tables for filter storage
  *  @queue: queue index to direct traffic to
  *
  *  Note that the caller to this function must lock before calling, since the
  *  hardware writes must be protected from one another.
  **/
 s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
-                                               struct ixgbe_atr_input *input,
-                                               u16 soft_id,
-                                               u8 queue)
+                                      struct ixgbe_atr_input *input,
+                                      struct ixgbe_atr_input_masks *input_masks,
+                                      u16 soft_id, u8 queue)
 {
 	u32 fdircmd = 0;
 	u32 fdirhash;
-	u32 src_ipv4, dst_ipv4;
+	u32 src_ipv4 = 0, dst_ipv4 = 0;
 	u32 src_ipv6_1, src_ipv6_2, src_ipv6_3, src_ipv6_4;
 	u16 src_port, dst_port, vlan_id, flex_bytes;
 	u16 bucket_hash;
 	u8  l4type;
+	u8  fdirm = 0;
 
 	/* Get our input values */
 	ixgbe_atr_get_l4type_82599(input, &l4type);
@@ -2149,7 +2159,6 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
 		/* IPv4 */
 		ixgbe_atr_get_src_ipv4_82599(input, &src_ipv4);
 		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv4);
-
 	}
 
 	ixgbe_atr_get_dst_ipv4_82599(input, &dst_ipv4);
@@ -2158,7 +2167,78 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRVLAN, (vlan_id |
 	                            (flex_bytes << IXGBE_FDIRVLAN_FLEX_SHIFT)));
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRPORT, (src_port |
-	                       (dst_port << IXGBE_FDIRPORT_DESTINATION_SHIFT)));
+	              (dst_port << IXGBE_FDIRPORT_DESTINATION_SHIFT)));
+
+	/*
+	 * Program the relevant mask registers.  If src/dst_port or src/dst_addr
+	 * are zero, then assume a full mask for that field.  Also assume that
+	 * a VLAN of 0 is unspecified, so mask that out as well.  L4type
+	 * cannot be masked out in this implementation.
+	 *
+	 * This also assumes IPv4 only.  IPv6 masking isn't supported at this
+	 * point in time.
+	 */
+	if (src_ipv4 == 0)
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, 0xffffffff);
+	else
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, input_masks->src_ip_mask);
+
+	if (dst_ipv4 == 0)
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, 0xffffffff);
+	else
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, input_masks->dst_ip_mask);
+
+	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
+	case IXGBE_ATR_L4TYPE_TCP:
+		if (src_port == 0)
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, 0xffff);
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
+			                input_masks->src_port_mask);
+
+		if (dst_port == 0)
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
+			               (IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
+			                (0xffff << 16)));
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
+			               (IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
+			                (input_masks->dst_port_mask << 16)));
+		break;
+	case IXGBE_ATR_L4TYPE_UDP:
+		if (src_port == 0)
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, 0xffff);
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
+			                input_masks->src_port_mask);
+
+		if (dst_port == 0)
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
+			               (IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
+			                (0xffff << 16)));
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
+			               (IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
+			                (input_masks->src_port_mask << 16)));
+		break;
+	default:
+		/* this already would have failed above */
+		break;
+	}
+
+	/* Program the last mask register, FDIRM */
+	if (input_masks->vlan_id_mask || !vlan_id)
+		/* Mask both VLAN and VLANP - bits 0 and 1 */
+		fdirm |= 0x3;
+
+	if (input_masks->data_mask || !flex_bytes)
+		/* Flex bytes need masking, so mask the whole thing - bit 4 */
+		fdirm |= 0x10;
+
+	/* Now mask VM pool and destination IPv6 - bits 5 and 2 */
+	fdirm |= 0x24;
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRM, fdirm);
 
 	fdircmd |= IXGBE_FDIRCMD_CMD_ADD_FLOW;
 	fdircmd |= IXGBE_FDIRCMD_FILTER_UPDATE;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index d468c03..9235699 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2158,6 +2158,86 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 }
 
+static int ixgbe_set_rx_ntuple(struct net_device *dev,
+                               struct ethtool_rx_ntuple *cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ethtool_rx_ntuple_flow_spec fs = cmd->fs;
+	struct ixgbe_atr_input input_struct;
+	struct ixgbe_atr_input_masks input_masks;
+	int target_queue;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		return -EOPNOTSUPP;
+
+	/*
+	 * Don't allow programming if we're not in perfect filter mode, or
+	 * if the action is a queue greater than the number of online Tx
+	 * queues.
+	 */
+	if ((!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) ||
+	    (fs.action >= adapter->num_tx_queues))
+		return -EINVAL;
+
+	memset(&input_struct, 0, sizeof(struct ixgbe_atr_input));
+	memset(&input_masks, 0, sizeof(struct ixgbe_atr_input_masks));
+
+	input_masks.src_ip_mask = fs.m_u.tcp_ip4_spec.ip4src;
+	input_masks.dst_ip_mask = fs.m_u.tcp_ip4_spec.ip4dst;
+	input_masks.src_port_mask = fs.m_u.tcp_ip4_spec.psrc;
+	input_masks.dst_port_mask = fs.m_u.tcp_ip4_spec.pdst;
+	input_masks.vlan_id_mask = fs.vlan_tag_mask;
+	/* only use the lowest 2 bytes for flex bytes */
+	input_masks.data_mask = (fs.data_mask & 0xffff);
+
+	switch (fs.flow_type) {
+	case TCP_V4_FLOW:
+		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_TCP);
+		break;
+	case UDP_V4_FLOW:
+		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_UDP);
+		break;
+	case SCTP_V4_FLOW:
+		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_SCTP);
+		break;
+	default:
+		return -1;
+	}
+
+	/* Mask bits from the inputs based on user-supplied mask */
+	ixgbe_atr_set_src_ipv4_82599(&input_struct,
+	            (fs.h_u.tcp_ip4_spec.ip4src & ~fs.m_u.tcp_ip4_spec.ip4src));
+	ixgbe_atr_set_dst_ipv4_82599(&input_struct,
+	            (fs.h_u.tcp_ip4_spec.ip4dst & ~fs.m_u.tcp_ip4_spec.ip4dst));
+	/* 82599 expects these to be byte-swapped for perfect filtering */
+	ixgbe_atr_set_src_port_82599(&input_struct,
+	       ((ntohs(fs.h_u.tcp_ip4_spec.psrc)) & ~fs.m_u.tcp_ip4_spec.psrc));
+	ixgbe_atr_set_dst_port_82599(&input_struct,
+	       ((ntohs(fs.h_u.tcp_ip4_spec.pdst)) & ~fs.m_u.tcp_ip4_spec.pdst));
+
+	/* VLAN and Flex bytes are either completely masked or not */
+	if (!fs.vlan_tag_mask)
+		ixgbe_atr_set_vlan_id_82599(&input_struct, fs.vlan_tag);
+
+	if (!input_masks.data_mask)
+		/* make sure we only use the first 2 bytes of user data */
+		ixgbe_atr_set_flex_byte_82599(&input_struct,
+		                              (fs.data & 0xffff));
+
+	/* determine if we need to drop or route the packet */
+	if (fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
+		target_queue = MAX_RX_QUEUES - 1;
+	else
+		target_queue = fs.action;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+	ixgbe_fdir_add_perfect_filter_82599(&adapter->hw, &input_struct,
+	                                    &input_masks, 0, target_queue);
+	spin_unlock(&adapter->fdir_perfect_lock);
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2193,6 +2273,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.set_rx_ntuple          = ixgbe_set_rx_ntuple,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 84650c6..6950f62 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2109,6 +2109,15 @@ struct ixgbe_atr_input {
 	u8 byte_stream[42];
 };
 
+struct ixgbe_atr_input_masks {
+	u32 src_ip_mask;
+	u32 dst_ip_mask;
+	u16 src_port_mask;
+	u16 dst_port_mask;
+	u16 vlan_id_mask;
+	u16 data_mask;
+};
+
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,
 	ixgbe_eeprom_spi,

