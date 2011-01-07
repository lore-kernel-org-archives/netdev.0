From: jeffrey.t.kirsher@intel.com
Subject: [net-next 12/12] ixgbe: update ntuple filter configuration
Date: Thu,  6 Jan 2011 16:29:59 -0800
Message-ID: <1294360199-9860-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50807 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171Ab1AGAaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:55 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes several issues found in ntuple filtering while I was
doing the ATR refactor.

Specifically I updated the masks to work correctly with the latest version
of ethtool, I cleaned up the exception handling and added detailed error
output when a filter is rejected, and corrected several bits that were set
incorrectly in ixgbe_type.h.

The previous version of this patch included a printk that was left over from
me fixing the filter setup.  This patch does not include that printk.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |   14 --
 drivers/net/ixgbe/ixgbe_82599.c   |  436 ++++++++++++-------------------------
 drivers/net/ixgbe/ixgbe_ethtool.c |  134 ++++++++----
 drivers/net/ixgbe/ixgbe_main.c    |   21 +-
 drivers/net/ixgbe/ixgbe_type.h    |   16 +-
 5 files changed, 250 insertions(+), 371 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 341b3db..3b8c924 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -533,20 +533,6 @@ extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
                                       union ixgbe_atr_input *input,
                                       struct ixgbe_atr_input_masks *input_masks,
                                       u16 soft_id, u8 queue);
-extern s32 ixgbe_atr_set_vlan_id_82599(union ixgbe_atr_input *input,
-                                       u16 vlan_id);
-extern s32 ixgbe_atr_set_src_ipv4_82599(union ixgbe_atr_input *input,
-                                        u32 src_addr);
-extern s32 ixgbe_atr_set_dst_ipv4_82599(union ixgbe_atr_input *input,
-                                        u32 dst_addr);
-extern s32 ixgbe_atr_set_src_port_82599(union ixgbe_atr_input *input,
-                                        u16 src_port);
-extern s32 ixgbe_atr_set_dst_port_82599(union ixgbe_atr_input *input,
-                                        u16 dst_port);
-extern s32 ixgbe_atr_set_flex_byte_82599(union ixgbe_atr_input *input,
-                                         u16 flex_byte);
-extern s32 ixgbe_atr_set_l4type_82599(union ixgbe_atr_input *input,
-                                      u8 l4type);
 extern void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
                                    struct ixgbe_ring *ring);
 extern void ixgbe_clear_rscctl(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index d41931f..8d316d9 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1422,211 +1422,6 @@ static u32 ixgbe_atr_compute_sig_hash_82599(union ixgbe_atr_hash_dword input,
 }
 
 /**
- *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
- *  @input: input stream to modify
- *  @vlan: the VLAN id to load
- **/
-s32 ixgbe_atr_set_vlan_id_82599(union ixgbe_atr_input *input, __be16 vlan)
-{
-	input->formatted.vlan_id = vlan;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_src_ipv4_82599 - Sets the source IPv4 address
- *  @input: input stream to modify
- *  @src_addr: the IP address to load
- **/
-s32 ixgbe_atr_set_src_ipv4_82599(union ixgbe_atr_input *input, __be32 src_addr)
-{
-	input->formatted.src_ip[0] = src_addr;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_dst_ipv4_82599 - Sets the destination IPv4 address
- *  @input: input stream to modify
- *  @dst_addr: the IP address to load
- **/
-s32 ixgbe_atr_set_dst_ipv4_82599(union ixgbe_atr_input *input, __be32 dst_addr)
-{
-	input->formatted.dst_ip[0] = dst_addr;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_src_port_82599 - Sets the source port
- *  @input: input stream to modify
- *  @src_port: the source port to load
- **/
-s32 ixgbe_atr_set_src_port_82599(union ixgbe_atr_input *input, __be16 src_port)
-{
-	input->formatted.src_port = src_port;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_dst_port_82599 - Sets the destination port
- *  @input: input stream to modify
- *  @dst_port: the destination port to load
- **/
-s32 ixgbe_atr_set_dst_port_82599(union ixgbe_atr_input *input, __be16 dst_port)
-{
-	input->formatted.dst_port = dst_port;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_flex_byte_82599 - Sets the flexible bytes
- *  @input: input stream to modify
- *  @flex_bytes: the flexible bytes to load
- **/
-s32 ixgbe_atr_set_flex_byte_82599(union ixgbe_atr_input *input,
-				  __be16 flex_bytes)
-{
-	input->formatted.flex_bytes = flex_bytes;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_set_l4type_82599 - Sets the layer 4 packet type
- *  @input: input stream to modify
- *  @l4type: the layer 4 type value to load
- **/
-s32 ixgbe_atr_set_l4type_82599(union ixgbe_atr_input *input, u8 l4type)
-{
-	input->formatted.flow_type = l4type;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_vlan_id_82599 - Gets the VLAN id from the ATR input stream
- *  @input: input stream to search
- *  @vlan: the VLAN id to load
- **/
-static s32 ixgbe_atr_get_vlan_id_82599(union ixgbe_atr_input *input, __be16 *vlan)
-{
-	*vlan = input->formatted.vlan_id;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_src_ipv4_82599 - Gets the source IPv4 address
- *  @input: input stream to search
- *  @src_addr: the IP address to load
- **/
-static s32 ixgbe_atr_get_src_ipv4_82599(union ixgbe_atr_input *input,
-                                        __be32 *src_addr)
-{
-	*src_addr = input->formatted.src_ip[0];
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_dst_ipv4_82599 - Gets the destination IPv4 address
- *  @input: input stream to search
- *  @dst_addr: the IP address to load
- **/
-static s32 ixgbe_atr_get_dst_ipv4_82599(union ixgbe_atr_input *input,
-                                        __be32 *dst_addr)
-{
-	*dst_addr = input->formatted.dst_ip[0];
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_src_ipv6_82599 - Gets the source IPv6 address
- *  @input: input stream to search
- *  @src_addr_1: the first 4 bytes of the IP address to load
- *  @src_addr_2: the second 4 bytes of the IP address to load
- *  @src_addr_3: the third 4 bytes of the IP address to load
- *  @src_addr_4: the fourth 4 bytes of the IP address to load
- **/
-static s32 ixgbe_atr_get_src_ipv6_82599(union ixgbe_atr_input *input,
-                                        __be32 *src_addr_0, __be32 *src_addr_1,
-                                        __be32 *src_addr_2, __be32 *src_addr_3)
-{
-	*src_addr_0 = input->formatted.src_ip[0];
-	*src_addr_1 = input->formatted.src_ip[1];
-	*src_addr_2 = input->formatted.src_ip[2];
-	*src_addr_3 = input->formatted.src_ip[3];
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_src_port_82599 - Gets the source port
- *  @input: input stream to modify
- *  @src_port: the source port to load
- *
- *  Even though the input is given in big-endian, the FDIRPORT registers
- *  expect the ports to be programmed in little-endian.  Hence the need to swap
- *  endianness when retrieving the data.  This can be confusing since the
- *  internal hash engine expects it to be big-endian.
- **/
-static s32 ixgbe_atr_get_src_port_82599(union ixgbe_atr_input *input,
-                                        __be16 *src_port)
-{
-	*src_port = input->formatted.src_port;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_dst_port_82599 - Gets the destination port
- *  @input: input stream to modify
- *  @dst_port: the destination port to load
- *
- *  Even though the input is given in big-endian, the FDIRPORT registers
- *  expect the ports to be programmed in little-endian.  Hence the need to swap
- *  endianness when retrieving the data.  This can be confusing since the
- *  internal hash engine expects it to be big-endian.
- **/
-static s32 ixgbe_atr_get_dst_port_82599(union ixgbe_atr_input *input,
-                                        __be16 *dst_port)
-{
-	*dst_port = input->formatted.dst_port;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_flex_byte_82599 - Gets the flexible bytes
- *  @input: input stream to modify
- *  @flex_bytes: the flexible bytes to load
- **/
-static s32 ixgbe_atr_get_flex_byte_82599(union ixgbe_atr_input *input,
-                                         __be16 *flex_bytes)
-{
-	*flex_bytes = input->formatted.flex_bytes;
-
-	return 0;
-}
-
-/**
- *  ixgbe_atr_get_l4type_82599 - Gets the layer 4 packet type
- *  @input: input stream to modify
- *  @l4type: the layer 4 type value to load
- **/
-static s32 ixgbe_atr_get_l4type_82599(union ixgbe_atr_input *input,
-                                      u8 *l4type)
-{
-	*l4type = input->formatted.flow_type;
-
-	return 0;
-}
-
-/**
  *  ixgbe_atr_add_signature_filter_82599 - Adds a signature hash filter
  *  @hw: pointer to hardware structure
  *  @input: unique input dword
@@ -1679,6 +1474,43 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_get_fdirtcpm_82599 - generate a tcp port from atr_input_masks
+ *  @input_mask: mask to be bit swapped
+ *
+ *  The source and destination port masks for flow director are bit swapped
+ *  in that bit 15 effects bit 0, 14 effects 1, 13, 2 etc.  In order to
+ *  generate a correctly swapped value we need to bit swap the mask and that
+ *  is what is accomplished by this function.
+ **/
+static u32 ixgbe_get_fdirtcpm_82599(struct ixgbe_atr_input_masks *input_masks)
+{
+	u32 mask = ntohs(input_masks->dst_port_mask);
+	mask <<= IXGBE_FDIRTCPM_DPORTM_SHIFT;
+	mask |= ntohs(input_masks->src_port_mask);
+	mask = ((mask & 0x55555555) << 1) | ((mask & 0xAAAAAAAA) >> 1);
+	mask = ((mask & 0x33333333) << 2) | ((mask & 0xCCCCCCCC) >> 2);
+	mask = ((mask & 0x0F0F0F0F) << 4) | ((mask & 0xF0F0F0F0) >> 4);
+	return ((mask & 0x00FF00FF) << 8) | ((mask & 0xFF00FF00) >> 8);
+}
+
+/*
+ * These two macros are meant to address the fact that we have registers
+ * that are either all or in part big-endian.  As a result on big-endian
+ * systems we will end up byte swapping the value to little-endian before
+ * it is byte swapped again and written to the hardware in the original
+ * big-endian format.
+ */
+#define IXGBE_STORE_AS_BE32(_value) \
+	(((u32)(_value) >> 24) | (((u32)(_value) & 0x00FF0000) >> 8) | \
+	 (((u32)(_value) & 0x0000FF00) << 8) | ((u32)(_value) << 24))
+
+#define IXGBE_WRITE_REG_BE32(a, reg, value) \
+	IXGBE_WRITE_REG((a), (reg), IXGBE_STORE_AS_BE32(ntohl(value)))
+
+#define IXGBE_STORE_AS_BE16(_value) \
+	(((u16)(_value) >> 8) | ((u16)(_value) << 8))
+
+/**
  *  ixgbe_fdir_add_perfect_filter_82599 - Adds a perfect filter
  *  @hw: pointer to hardware structure
  *  @input: input bitstream
@@ -1694,131 +1526,135 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
                                       struct ixgbe_atr_input_masks *input_masks,
                                       u16 soft_id, u8 queue)
 {
-	u32 fdircmd = 0;
 	u32 fdirhash;
-	u32 src_ipv4 = 0, dst_ipv4 = 0;
-	u32 src_ipv6_1, src_ipv6_2, src_ipv6_3, src_ipv6_4;
-	u16 src_port, dst_port, vlan_id, flex_bytes;
-	u16 bucket_hash;
-	u8  l4type;
-	u8  fdirm = 0;
-
-	/* Get our input values */
-	ixgbe_atr_get_l4type_82599(input, &l4type);
+	u32 fdircmd;
+	u32 fdirport, fdirtcpm;
+	u32 fdirvlan;
+	/* start with VLAN, flex bytes, VM pool, and IPv6 destination masked */
+	u32 fdirm = IXGBE_FDIRM_VLANID | IXGBE_FDIRM_VLANP | IXGBE_FDIRM_FLEX |
+		    IXGBE_FDIRM_POOL | IXGBE_FDIRM_DIPv6;
 
 	/*
-	 * Check l4type formatting, and bail out before we touch the hardware
+	 * Check flow_type formatting, and bail out before we touch the hardware
 	 * if there's a configuration issue
 	 */
-	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
-	case IXGBE_ATR_L4TYPE_TCP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_TCP;
-		break;
-	case IXGBE_ATR_L4TYPE_UDP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_UDP;
-		break;
-	case IXGBE_ATR_L4TYPE_SCTP:
-		fdircmd |= IXGBE_FDIRCMD_L4TYPE_SCTP;
+	switch (input->formatted.flow_type) {
+	case IXGBE_ATR_FLOW_TYPE_IPV4:
+		/* use the L4 protocol mask for raw IPv4/IPv6 traffic */
+		fdirm |= IXGBE_FDIRM_L4P;
+	case IXGBE_ATR_FLOW_TYPE_SCTPV4:
+		if (input_masks->dst_port_mask || input_masks->src_port_mask) {
+			hw_dbg(hw, " Error on src/dst port mask\n");
+			return IXGBE_ERR_CONFIG;
+		}
+	case IXGBE_ATR_FLOW_TYPE_TCPV4:
+	case IXGBE_ATR_FLOW_TYPE_UDPV4:
 		break;
 	default:
-		hw_dbg(hw, "Error on l4type input\n");
+		hw_dbg(hw, " Error on flow type input\n");
 		return IXGBE_ERR_CONFIG;
 	}
 
-	bucket_hash = ixgbe_atr_compute_hash_82599(input,
-	                                           IXGBE_ATR_BUCKET_HASH_KEY);
-
-	/* bucket_hash is only 15 bits */
-	bucket_hash &= IXGBE_ATR_HASH_MASK;
-
-	ixgbe_atr_get_vlan_id_82599(input, &vlan_id);
-	ixgbe_atr_get_src_port_82599(input, &src_port);
-	ixgbe_atr_get_dst_port_82599(input, &dst_port);
-	ixgbe_atr_get_flex_byte_82599(input, &flex_bytes);
-
-	fdirhash = soft_id << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT | bucket_hash;
-
-	/* Now figure out if we're IPv4 or IPv6 */
-	if (l4type & IXGBE_ATR_L4TYPE_IPV6_MASK) {
-		/* IPv6 */
-		ixgbe_atr_get_src_ipv6_82599(input, &src_ipv6_1, &src_ipv6_2,
-	                                     &src_ipv6_3, &src_ipv6_4);
-
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(0), src_ipv6_1);
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(1), src_ipv6_2);
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(2), src_ipv6_3);
-		/* The last 4 bytes is the same register as IPv4 */
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv6_4);
-
-		fdircmd |= IXGBE_FDIRCMD_IPV6;
-		fdircmd |= IXGBE_FDIRCMD_IPv6DMATCH;
-	} else {
-		/* IPv4 */
-		ixgbe_atr_get_src_ipv4_82599(input, &src_ipv4);
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv4);
-	}
-
-	ixgbe_atr_get_dst_ipv4_82599(input, &dst_ipv4);
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRIPDA, dst_ipv4);
-
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRVLAN, (vlan_id |
-	                            (flex_bytes << IXGBE_FDIRVLAN_FLEX_SHIFT)));
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRPORT, (src_port |
-	              (dst_port << IXGBE_FDIRPORT_DESTINATION_SHIFT)));
-
 	/*
-	 * Program the relevant mask registers.  L4type cannot be
-	 * masked out in this implementation.
+	 * Program the relevant mask registers.  If src/dst_port or src/dst_addr
+	 * are zero, then assume a full mask for that field.  Also assume that
+	 * a VLAN of 0 is unspecified, so mask that out as well.  L4type
+	 * cannot be masked out in this implementation.
 	 *
 	 * This also assumes IPv4 only.  IPv6 masking isn't supported at this
 	 * point in time.
 	 */
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, input_masks->src_ip_mask);
-	IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, input_masks->dst_ip_mask);
-
-	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
-	case IXGBE_ATR_L4TYPE_TCP:
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, input_masks->src_port_mask);
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
-				(IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
-				 (input_masks->dst_port_mask << 16)));
+
+	/* Program FDIRM */
+	switch (ntohs(input_masks->vlan_id_mask) & 0xEFFF) {
+	case 0xEFFF:
+		/* Unmask VLAN ID - bit 0 and fall through to unmask prio */
+		fdirm &= ~IXGBE_FDIRM_VLANID;
+	case 0xE000:
+		/* Unmask VLAN prio - bit 1 */
+		fdirm &= ~IXGBE_FDIRM_VLANP;
 		break;
-	case IXGBE_ATR_L4TYPE_UDP:
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, input_masks->src_port_mask);
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
-				(IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
-				 (input_masks->src_port_mask << 16)));
+	case 0x0FFF:
+		/* Unmask VLAN ID - bit 0 */
+		fdirm &= ~IXGBE_FDIRM_VLANID;
 		break;
-	default:
-		/* this already would have failed above */
+	case 0x0000:
+		/* do nothing, vlans already masked */
 		break;
+	default:
+		hw_dbg(hw, " Error on VLAN mask\n");
+		return IXGBE_ERR_CONFIG;
 	}
 
-	/* Program the last mask register, FDIRM */
-	if (input_masks->vlan_id_mask)
-		/* Mask both VLAN and VLANP - bits 0 and 1 */
-		fdirm |= 0x3;
-
-	if (input_masks->data_mask)
-		/* Flex bytes need masking, so mask the whole thing - bit 4 */
-		fdirm |= 0x10;
+	if (input_masks->flex_mask & 0xFFFF) {
+		if ((input_masks->flex_mask & 0xFFFF) != 0xFFFF) {
+			hw_dbg(hw, " Error on flexible byte mask\n");
+			return IXGBE_ERR_CONFIG;
+		}
+		/* Unmask Flex Bytes - bit 4 */
+		fdirm &= ~IXGBE_FDIRM_FLEX;
+	}
 
 	/* Now mask VM pool and destination IPv6 - bits 5 and 2 */
-	fdirm |= 0x24;
-
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRM, fdirm);
 
-	fdircmd |= IXGBE_FDIRCMD_CMD_ADD_FLOW;
-	fdircmd |= IXGBE_FDIRCMD_FILTER_UPDATE;
-	fdircmd |= IXGBE_FDIRCMD_LAST;
-	fdircmd |= IXGBE_FDIRCMD_QUEUE_EN;
-	fdircmd |= queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT;
+	/* store the TCP/UDP port masks, bit reversed from port layout */
+	fdirtcpm = ixgbe_get_fdirtcpm_82599(input_masks);
+
+	/* write both the same so that UDP and TCP use the same mask */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, ~fdirtcpm);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, ~fdirtcpm);
+
+	/* store source and destination IP masks (big-enian) */
+	IXGBE_WRITE_REG_BE32(hw, IXGBE_FDIRSIP4M,
+			     ~input_masks->src_ip_mask[0]);
+	IXGBE_WRITE_REG_BE32(hw, IXGBE_FDIRDIP4M,
+			     ~input_masks->dst_ip_mask[0]);
+
+	/* Apply masks to input data */
+	input->formatted.vlan_id &= input_masks->vlan_id_mask;
+	input->formatted.flex_bytes &= input_masks->flex_mask;
+	input->formatted.src_port &= input_masks->src_port_mask;
+	input->formatted.dst_port &= input_masks->dst_port_mask;
+	input->formatted.src_ip[0] &= input_masks->src_ip_mask[0];
+	input->formatted.dst_ip[0] &= input_masks->dst_ip_mask[0];
+
+	/* record vlan (little-endian) and flex_bytes(big-endian) */
+	fdirvlan =
+		IXGBE_STORE_AS_BE16(ntohs(input->formatted.flex_bytes));
+	fdirvlan <<= IXGBE_FDIRVLAN_FLEX_SHIFT;
+	fdirvlan |= ntohs(input->formatted.vlan_id);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRVLAN, fdirvlan);
+
+	/* record source and destination port (little-endian)*/
+	fdirport = ntohs(input->formatted.dst_port);
+	fdirport <<= IXGBE_FDIRPORT_DESTINATION_SHIFT;
+	fdirport |= ntohs(input->formatted.src_port);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRPORT, fdirport);
+
+	/* record the first 32 bits of the destination address (big-endian) */
+	IXGBE_WRITE_REG_BE32(hw, IXGBE_FDIRIPDA, input->formatted.dst_ip[0]);
+
+	/* record the source address (big-endian) */
+	IXGBE_WRITE_REG_BE32(hw, IXGBE_FDIRIPSA, input->formatted.src_ip[0]);
+
+	/* configure FDIRCMD register */
+	fdircmd = IXGBE_FDIRCMD_CMD_ADD_FLOW | IXGBE_FDIRCMD_FILTER_UPDATE |
+		  IXGBE_FDIRCMD_LAST | IXGBE_FDIRCMD_QUEUE_EN;
+	fdircmd |= input->formatted.flow_type << IXGBE_FDIRCMD_FLOW_TYPE_SHIFT;
+	fdircmd |= (u32)queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT;
+
+	/* we only want the bucket hash so drop the upper 16 bits */
+	fdirhash = ixgbe_atr_compute_hash_82599(input,
+						IXGBE_ATR_BUCKET_HASH_KEY);
+	fdirhash |= soft_id << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT;
 
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRHASH, fdirhash);
 	IXGBE_WRITE_REG(hw, IXGBE_FDIRCMD, fdircmd);
 
 	return 0;
 }
+
 /**
  *  ixgbe_read_analog_reg8_82599 - Reads 8 bit Omer analog register
  *  @hw: pointer to hardware structure
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 76e40e2..2002ea8 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2277,10 +2277,11 @@ static int ixgbe_set_rx_ntuple(struct net_device *dev,
                                struct ethtool_rx_ntuple *cmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	struct ethtool_rx_ntuple_flow_spec fs = cmd->fs;
+	struct ethtool_rx_ntuple_flow_spec *fs = &cmd->fs;
 	union ixgbe_atr_input input_struct;
 	struct ixgbe_atr_input_masks input_masks;
 	int target_queue;
+	int err;
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
 		return -EOPNOTSUPP;
@@ -2289,67 +2290,122 @@ static int ixgbe_set_rx_ntuple(struct net_device *dev,
 	 * Don't allow programming if the action is a queue greater than
 	 * the number of online Tx queues.
 	 */
-	if ((fs.action >= adapter->num_tx_queues) ||
-	    (fs.action < ETHTOOL_RXNTUPLE_ACTION_DROP))
+	if ((fs->action >= adapter->num_tx_queues) ||
+	    (fs->action < ETHTOOL_RXNTUPLE_ACTION_DROP))
 		return -EINVAL;
 
 	memset(&input_struct, 0, sizeof(union ixgbe_atr_input));
 	memset(&input_masks, 0, sizeof(struct ixgbe_atr_input_masks));
 
-	input_masks.src_ip_mask = fs.m_u.tcp_ip4_spec.ip4src;
-	input_masks.dst_ip_mask = fs.m_u.tcp_ip4_spec.ip4dst;
-	input_masks.src_port_mask = fs.m_u.tcp_ip4_spec.psrc;
-	input_masks.dst_port_mask = fs.m_u.tcp_ip4_spec.pdst;
-	input_masks.vlan_id_mask = fs.vlan_tag_mask;
-	/* only use the lowest 2 bytes for flex bytes */
-	input_masks.data_mask = (fs.data_mask & 0xffff);
-
-	switch (fs.flow_type) {
+	/* record flow type */
+	switch (fs->flow_type) {
+	case IPV4_FLOW:
+		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_IPV4;
+		break;
 	case TCP_V4_FLOW:
-		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_TCP);
+		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
 		break;
 	case UDP_V4_FLOW:
-		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_UDP);
+		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_UDPV4;
 		break;
 	case SCTP_V4_FLOW:
-		ixgbe_atr_set_l4type_82599(&input_struct, IXGBE_ATR_L4TYPE_SCTP);
+		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_SCTPV4;
 		break;
 	default:
 		return -1;
 	}
 
-	/* Mask bits from the inputs based on user-supplied mask */
-	ixgbe_atr_set_src_ipv4_82599(&input_struct,
-	            (fs.h_u.tcp_ip4_spec.ip4src & ~fs.m_u.tcp_ip4_spec.ip4src));
-	ixgbe_atr_set_dst_ipv4_82599(&input_struct,
-	            (fs.h_u.tcp_ip4_spec.ip4dst & ~fs.m_u.tcp_ip4_spec.ip4dst));
-	/* 82599 expects these to be byte-swapped for perfect filtering */
-	ixgbe_atr_set_src_port_82599(&input_struct,
-	       ((ntohs(fs.h_u.tcp_ip4_spec.psrc)) & ~fs.m_u.tcp_ip4_spec.psrc));
-	ixgbe_atr_set_dst_port_82599(&input_struct,
-	       ((ntohs(fs.h_u.tcp_ip4_spec.pdst)) & ~fs.m_u.tcp_ip4_spec.pdst));
-
-	/* VLAN and Flex bytes are either completely masked or not */
-	if (!fs.vlan_tag_mask)
-		ixgbe_atr_set_vlan_id_82599(&input_struct, fs.vlan_tag);
-
-	if (!input_masks.data_mask)
-		/* make sure we only use the first 2 bytes of user data */
-		ixgbe_atr_set_flex_byte_82599(&input_struct,
-		                              (fs.data & 0xffff));
+	/* copy vlan tag minus the CFI bit */
+	if ((fs->vlan_tag & 0xEFFF) || (~fs->vlan_tag_mask & 0xEFFF)) {
+		input_struct.formatted.vlan_id = htons(fs->vlan_tag & 0xEFFF);
+		if (!fs->vlan_tag_mask) {
+			input_masks.vlan_id_mask = htons(0xEFFF);
+		} else {
+			switch (~fs->vlan_tag_mask & 0xEFFF) {
+			/* all of these are valid vlan-mask values */
+			case 0xEFFF:
+			case 0xE000:
+			case 0x0FFF:
+			case 0x0000:
+				input_masks.vlan_id_mask =
+					htons(~fs->vlan_tag_mask);
+				break;
+			/* exit with error if vlan-mask is invalid */
+			default:
+				e_err(drv, "Partial VLAN ID or "
+				      "priority mask in vlan-mask is not "
+				      "supported by hardware\n");
+				return -1;
+			}
+		}
+	}
+
+	/* make sure we only use the first 2 bytes of user data */
+	if ((fs->data & 0xFFFF) || (~fs->data_mask & 0xFFFF)) {
+		input_struct.formatted.flex_bytes = htons(fs->data & 0xFFFF);
+		if (!(fs->data_mask & 0xFFFF)) {
+			input_masks.flex_mask = 0xFFFF;
+		} else if (~fs->data_mask & 0xFFFF) {
+			e_err(drv, "Partial user-def-mask is not "
+			      "supported by hardware\n");
+			return -1;
+		}
+	}
+
+	/*
+	 * Copy input into formatted structures
+	 *
+	 * These assignments are based on the following logic
+	 * If neither input or mask are set assume value is masked out.
+	 * If input is set, but mask is not mask should default to accept all.
+	 * If input is not set, but mask is set then mask likely results in 0.
+	 * If input is set and mask is set then assign both.
+	 */
+	if (fs->h_u.tcp_ip4_spec.ip4src || ~fs->m_u.tcp_ip4_spec.ip4src) {
+		input_struct.formatted.src_ip[0] = fs->h_u.tcp_ip4_spec.ip4src;
+		if (!fs->m_u.tcp_ip4_spec.ip4src)
+			input_masks.src_ip_mask[0] = 0xFFFFFFFF;
+		else
+			input_masks.src_ip_mask[0] =
+				~fs->m_u.tcp_ip4_spec.ip4src;
+	}
+	if (fs->h_u.tcp_ip4_spec.ip4dst || ~fs->m_u.tcp_ip4_spec.ip4dst) {
+		input_struct.formatted.dst_ip[0] = fs->h_u.tcp_ip4_spec.ip4dst;
+		if (!fs->m_u.tcp_ip4_spec.ip4dst)
+			input_masks.dst_ip_mask[0] = 0xFFFFFFFF;
+		else
+			input_masks.dst_ip_mask[0] =
+				~fs->m_u.tcp_ip4_spec.ip4dst;
+	}
+	if (fs->h_u.tcp_ip4_spec.psrc || ~fs->m_u.tcp_ip4_spec.psrc) {
+		input_struct.formatted.src_port = fs->h_u.tcp_ip4_spec.psrc;
+		if (!fs->m_u.tcp_ip4_spec.psrc)
+			input_masks.src_port_mask = 0xFFFF;
+		else
+			input_masks.src_port_mask = ~fs->m_u.tcp_ip4_spec.psrc;
+	}
+	if (fs->h_u.tcp_ip4_spec.pdst || ~fs->m_u.tcp_ip4_spec.pdst) {
+		input_struct.formatted.dst_port = fs->h_u.tcp_ip4_spec.pdst;
+		if (!fs->m_u.tcp_ip4_spec.pdst)
+			input_masks.dst_port_mask = 0xFFFF;
+		else
+			input_masks.dst_port_mask = ~fs->m_u.tcp_ip4_spec.pdst;
+	}
 
 	/* determine if we need to drop or route the packet */
-	if (fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
+	if (fs->action == ETHTOOL_RXNTUPLE_ACTION_DROP)
 		target_queue = MAX_RX_QUEUES - 1;
 	else
-		target_queue = fs.action;
+		target_queue = fs->action;
 
 	spin_lock(&adapter->fdir_perfect_lock);
-	ixgbe_fdir_add_perfect_filter_82599(&adapter->hw, &input_struct,
-	                                    &input_masks, 0, target_queue);
+	err = ixgbe_fdir_add_perfect_filter_82599(&adapter->hw,
+						  &input_struct,
+						  &input_masks, 0,
+						  target_queue);
 	spin_unlock(&adapter->fdir_perfect_lock);
 
-	return 0;
+	return err ? -1 : 0;
 }
 
 static const struct ethtool_ops ixgbe_ethtool_ops = {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 490818c..a060610 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4821,6 +4821,12 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+	if (adapter->flags & (IXGBE_FLAG_FDIR_HASH_CAPABLE |
+			      IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+		e_err(probe,
+		      "Flow Director is not supported while multiple "
+		      "queues are disabled.  Disabling Flow Director\n");
+	}
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 	adapter->atr_sample_rate = 0;
@@ -5126,16 +5132,11 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
-		if (dev->features & NETIF_F_NTUPLE) {
-			/* Flow Director perfect filter enabled */
-			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-			adapter->atr_sample_rate = 0;
-			spin_lock_init(&adapter->fdir_perfect_lock);
-		} else {
-			/* Flow Director hash filters enabled */
-			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			adapter->atr_sample_rate = 20;
-		}
+		/* n-tuple support exists, always init our spinlock */
+		spin_lock_init(&adapter->fdir_perfect_lock);
+		/* Flow Director hash filters enabled */
+		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		adapter->atr_sample_rate = 20;
 		adapter->ring_feature[RING_F_FDIR].indices =
 							 IXGBE_MAX_FDIR_INDICES;
 		adapter->fdir_pballoc = 0;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 0d9392d..fd3358f 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1947,10 +1947,9 @@ enum ixgbe_fdir_pballoc_type {
 #define IXGBE_FDIRM_VLANID                      0x00000001
 #define IXGBE_FDIRM_VLANP                       0x00000002
 #define IXGBE_FDIRM_POOL                        0x00000004
-#define IXGBE_FDIRM_L3P                         0x00000008
-#define IXGBE_FDIRM_L4P                         0x00000010
-#define IXGBE_FDIRM_FLEX                        0x00000020
-#define IXGBE_FDIRM_DIPv6                       0x00000040
+#define IXGBE_FDIRM_L4P                         0x00000008
+#define IXGBE_FDIRM_FLEX                        0x00000010
+#define IXGBE_FDIRM_DIPv6                       0x00000020
 
 #define IXGBE_FDIRFREE_FREE_MASK                0xFFFF
 #define IXGBE_FDIRFREE_FREE_SHIFT               0
@@ -2215,12 +2214,13 @@ union ixgbe_atr_hash_dword {
 };
 
 struct ixgbe_atr_input_masks {
-	__be32 src_ip_mask;
-	__be32 dst_ip_mask;
+	__be16 rsvd0;
+	__be16 vlan_id_mask;
+	__be32 dst_ip_mask[4];
+	__be32 src_ip_mask[4];
 	__be16 src_port_mask;
 	__be16 dst_port_mask;
-	__be16 vlan_id_mask;
-	__be16 data_mask;
+	__be16 flex_mask;
 };
 
 enum ixgbe_eeprom_type {
-- 
1.7.3.4

