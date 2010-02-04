From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v2 2/3] ixgbe: Add support for the new ethtool
	n-tuple programming interface
Date: Wed, 03 Feb 2010 23:48:32 -0800
Message-ID: <20100204074831.16559.58911.stgit@localhost.localdomain>
References: <20100204074811.16559.84676.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:55502 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756670Ab0BDHst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 02:48:49 -0500
In-Reply-To: <20100204074811.16559.84676.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds n-tuple filter programming to 82599.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    4 +
 drivers/net/ixgbe/ixgbe_82599.c   |  106 +++++++++++++++++++++++++++++++----
 drivers/net/ixgbe/ixgbe_ethtool.c |  111 ++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_main.c    |   13 ++++
 drivers/net/ixgbe/ixgbe_type.h    |    9 +++
 5 files changed, 225 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index bffbe0d..19e94ee 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -453,6 +453,10 @@ extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
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
index d4ed6ad..4fa8633 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1439,6 +1439,9 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
 	/* Send interrupt when 64 filters are left */
 	fdirctrl |= 4 << IXGBE_FDIRCTRL_FULL_THRESH_SHIFT;
 
+	/* Initialize the drop queue to Rx queue 127 */
+	fdirctrl |= (127 << IXGBE_FDIRCTRL_DROP_Q_SHIFT);
+
 	switch (pballoc) {
 	case IXGBE_FDIR_PBALLOC_64K:
 		/* 2k - 1 perfect filters */
@@ -1628,6 +1631,7 @@ static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
  *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
  *  @input: input stream to modify
  *  @vlan: the VLAN id to load
+ *  @vlan_mask: bitwise mask for the VLAN
  **/
 s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
 {
@@ -1641,6 +1645,7 @@ s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
  *  ixgbe_atr_set_src_ipv4_82599 - Sets the source IPv4 address
  *  @input: input stream to modify
  *  @src_addr: the IP address to load
+ *  @src_addr_mask: bitwise mask for the source IP address
  **/
 s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
 {
@@ -1658,6 +1663,7 @@ s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
  *  ixgbe_atr_set_dst_ipv4_82599 - Sets the destination IPv4 address
  *  @input: input stream to modify
  *  @dst_addr: the IP address to load
+ *  @dst_addr_mask: bitwise mask for the destination IP address
  **/
 s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
 {
@@ -1680,8 +1686,8 @@ s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
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
@@ -1723,8 +1729,8 @@ s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
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
@@ -1761,6 +1767,7 @@ s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
  *  ixgbe_atr_set_src_port_82599 - Sets the source port
  *  @input: input stream to modify
  *  @src_port: the source port to load
+ *  @src_port_mask: bitwise mask for the source port
  **/
 s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
 {
@@ -1774,6 +1781,7 @@ s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
  *  ixgbe_atr_set_dst_port_82599 - Sets the destination port
  *  @input: input stream to modify
  *  @dst_port: the destination port to load
+ *  @dst_port_mask: bitwise mask for the destination port
  **/
 s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
 {
@@ -1802,7 +1810,7 @@ s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
  *  @vm_pool: the Virtual Machine pool to load
  **/
 s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
-                                       u8 vm_pool)
+                                u8 vm_pool)
 {
 	input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET] = vm_pool;
 
@@ -1826,8 +1834,7 @@ s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
  *  @input: input stream to search
  *  @vlan: the VLAN id to load
  **/
-static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input,
-                                       u16 *vlan)
+static s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
 {
 	*vlan = input->byte_stream[IXGBE_ATR_VLAN_OFFSET];
 	*vlan |= input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] << 8;
@@ -2083,23 +2090,26 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
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
@@ -2154,7 +2164,6 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
 		/* IPv4 */
 		ixgbe_atr_get_src_ipv4_82599(input, &src_ipv4);
 		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv4);
-
 	}
 
 	ixgbe_atr_get_dst_ipv4_82599(input, &dst_ipv4);
@@ -2163,7 +2172,78 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
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
index 07a9410..0d23434 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -979,6 +979,9 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
+	case ETH_SS_NTUPLE_FILTERS:
+		return (ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
+		        ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -2150,23 +2153,124 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	bool need_reset = false;
 
 	ethtool_op_set_flags(netdev, data);
 
-	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
-		return 0;
-
 	/* if state changes we need to update adapter->flags and reset */
 	if ((!!(data & ETH_FLAG_LRO)) != 
 	    (!!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
 		adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
+		need_reset = true;
+	}
+
+	/*
+	 * Check if Flow Director n-tuple support was enabled or disabled.  If
+	 * the state changed, we need to reset.
+	 */
+	if ((adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) &&
+	    (!(data & ETH_FLAG_NTUPLE))) {
+		/* turn off Flow Director perfect, set hash and reset */
+		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		need_reset = true;
+	} else if ((!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) &&
+	           (data & ETH_FLAG_NTUPLE)) {
+		/* turn off Flow Director hash, enable perfect and reset */
+		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		need_reset = true;
+	} else {
+		/* no state change */
+	}
+
+	if (need_reset) {
 		if (netif_running(netdev))
 			ixgbe_reinit_locked(adapter);
 		else
 			ixgbe_reset(adapter);
 	}
+
 	return 0;
+}
+
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
+	 * Don't allow programming if the action is a queue greater than
+	 * the number of online Tx queues.
+	 */
+	if ((fs.action >= adapter->num_tx_queues) ||
+	    (fs.action < ETHTOOL_RXNTUPLE_ACTION_DROP))
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
 }
 
 static const struct ethtool_ops ixgbe_ethtool_ops = {
@@ -2204,6 +2308,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.set_rx_ntuple          = ixgbe_set_rx_ntuple,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2a3c831..ca57e74 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4187,6 +4187,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *dev = adapter->netdev;
 	unsigned int rss;
 #ifdef CONFIG_IXGBE_DCB
 	int j;
@@ -4214,10 +4215,18 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
-		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		if (dev->features & NETIF_F_NTUPLE) {
+			/* Flow Director perfect filter enabled */
+			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			adapter->atr_sample_rate = 0;
+			spin_lock_init(&adapter->fdir_perfect_lock);
+		} else {
+			/* Flow Director hash filters enabled */
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->atr_sample_rate = 20;
+		}
 		adapter->ring_feature[RING_F_FDIR].indices =
 		                                         IXGBE_MAX_FDIR_INDICES;
-		adapter->atr_sample_rate = 20;
 		adapter->fdir_pballoc = 0;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0db67c1..2be9074 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2129,6 +2129,15 @@ struct ixgbe_atr_input {
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

