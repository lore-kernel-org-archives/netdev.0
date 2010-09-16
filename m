From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] ethtool,
 ixgbe: Move RX n-tuple mask fixup to ethtool
Date: Thu, 16 Sep 2010 22:28:07 +0100
Message-ID: <1284672488.2283.33.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, Alex, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, PJ Waskiewicz
	<peter.p.waskiewicz.jr@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The ethtool utility does not set masks for flow parameters that are
not specified, so if both value and mask are 0 then this must be
treated as equivalent to a mask with all bits set.  Currently that is
done in the only driver that implements RX n-tuple filtering, ixgbe.
Move it to the ethtool core.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is compile-tested only.

Ben.

 drivers/net/ixgbe/ixgbe_82599.c |   57 +++++++++-----------------------------
 include/linux/ethtool.h         |    5 ++-
 net/core/ethtool.c              |   34 +++++++++++++++++++++++
 3 files changed, 51 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 3e06a61..e80657c 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1910,56 +1910,27 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
 	              (dst_port << IXGBE_FDIRPORT_DESTINATION_SHIFT)));
 
 	/*
-	 * Program the relevant mask registers.  If src/dst_port or src/dst_addr
-	 * are zero, then assume a full mask for that field.  Also assume that
-	 * a VLAN of 0 is unspecified, so mask that out as well.  L4type
-	 * cannot be masked out in this implementation.
+	 * Program the relevant mask registers.  L4type cannot be
+	 * masked out in this implementation.
 	 *
 	 * This also assumes IPv4 only.  IPv6 masking isn't supported at this
 	 * point in time.
 	 */
-	if (src_ipv4 == 0)
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, 0xffffffff);
-	else
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, input_masks->src_ip_mask);
-
-	if (dst_ipv4 == 0)
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, 0xffffffff);
-	else
-		IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, input_masks->dst_ip_mask);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRSIP4M, input_masks->src_ip_mask);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRDIP4M, input_masks->dst_ip_mask);
 
 	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
 	case IXGBE_ATR_L4TYPE_TCP:
-		if (src_port == 0)
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, 0xffff);
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
-			                input_masks->src_port_mask);
-
-		if (dst_port == 0)
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
-			               (IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
-			                (0xffff << 16)));
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
-			               (IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
-			                (input_masks->dst_port_mask << 16)));
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM, input_masks->src_port_mask);
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRTCPM,
+				(IXGBE_READ_REG(hw, IXGBE_FDIRTCPM) |
+				 (input_masks->dst_port_mask << 16)));
 		break;
 	case IXGBE_ATR_L4TYPE_UDP:
-		if (src_port == 0)
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, 0xffff);
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
-			                input_masks->src_port_mask);
-
-		if (dst_port == 0)
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
-			               (IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
-			                (0xffff << 16)));
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
-			               (IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
-			                (input_masks->src_port_mask << 16)));
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM, input_masks->src_port_mask);
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRUDPM,
+				(IXGBE_READ_REG(hw, IXGBE_FDIRUDPM) |
+				 (input_masks->src_port_mask << 16)));
 		break;
 	default:
 		/* this already would have failed above */
@@ -1967,11 +1938,11 @@ s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
 	}
 
 	/* Program the last mask register, FDIRM */
-	if (input_masks->vlan_id_mask || !vlan_id)
+	if (input_masks->vlan_id_mask)
 		/* Mask both VLAN and VLANP - bits 0 and 1 */
 		fdirm |= 0x3;
 
-	if (input_masks->data_mask || !flex_bytes)
+	if (input_masks->data_mask)
 		/* Flex bytes need masking, so mask the whole thing - bit 4 */
 		fdirm |= 0x10;
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index d64e246..00334ee 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -470,8 +470,9 @@ struct ethtool_rxfh_indir {
  * @action: RX ring/queue index to deliver to (non-negative) or other action
  *	(negative, e.g. %ETHTOOL_RXNTUPLE_ACTION_DROP)
  *
- * Zero values in @h_u may be ignored, as if all the corresponding
- * mask bits were set.
+ * For flow types %TCP_V4_FLOW, %UDP_V4_FLOW and %SCTP_V4_FLOW, where
+ * a field value and mask are both zero this is treated as if all mask
+ * bits are set i.e. the field is ignored.
  */
 struct ethtool_rx_ntuple_flow_spec {
 	__u32		 flow_type;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fcd62757..34fae15 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -485,6 +485,38 @@ static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 	list->count++;
 }
 
+/*
+ * ethtool does not (or did not) set masks for flow parameters that are
+ * not specified, so if both value and mask are 0 then this must be
+ * treated as equivalent to a mask with all bits set.  Implement that
+ * here rather than in drivers.
+ */
+static void rx_ntuple_fix_masks(struct ethtool_rx_ntuple_flow_spec *fs)
+{
+	struct ethtool_tcpip4_spec *entry = &fs->h_u.tcp_ip4_spec;
+	struct ethtool_tcpip4_spec *mask = &fs->m_u.tcp_ip4_spec;
+
+	if (fs->flow_type != TCP_V4_FLOW &&
+	    fs->flow_type != UDP_V4_FLOW &&
+	    fs->flow_type != SCTP_V4_FLOW)
+		return;
+
+	if (!(entry->ip4src | mask->ip4src))
+		mask->ip4src = htonl(0xffffffff);
+	if (!(entry->ip4dst | mask->ip4dst))
+		mask->ip4dst = htonl(0xffffffff);
+	if (!(entry->psrc | mask->psrc))
+		mask->psrc = htons(0xffff);
+	if (!(entry->pdst | mask->pdst))
+		mask->pdst = htons(0xffff);
+	if (!(entry->tos | mask->tos))
+		mask->tos = 0xff;
+	if (!(fs->vlan_tag | fs->vlan_tag_mask))
+		fs->vlan_tag_mask = 0xffff;
+	if (!(fs->data | fs->data_mask))
+		fs->data_mask = 0xffffffffffffffffULL;
+}
+
 static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 						    void __user *useraddr)
 {
@@ -499,6 +531,8 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
 
+	rx_ntuple_fix_masks(&cmd.fs);
+
 	/*
 	 * Cache filter in dev struct for GET operation only if
 	 * the underlying driver doesn't have its own GET operation, and
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
