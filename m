From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH net-next] net: ixgbe: Fix cls_u32 offload support for ports and fields with masks.
Date: Fri,  4 Mar 2016 11:47:49 -0800
Message-ID: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759984AbcCDTvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 14:51:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix support for 16 bit source/dest port matches in ixgbe model.
u32 uses a single 32-bit key value for both source and destination ports
starting at offset 0. So replace the 2 functions with a single function
that takes this key value/mask to program both source and dest ports.

Remove the incorrect check for mask in ixgbe_configure_clsu32()

Tested with the following filters:

 #tc qdisc add dev p4p1 ingress
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:1 u32 ht 800: \
	match ip dst 11.0.0.1/24 match ip src 11.0.0.2/24 action drop

 #tc filter del dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:1 u32
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1: u32 divisor 1
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:10 u32 ht 800: link 1: \
	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1:0:10 u32 ht 1: \
	match tcp src 1024 ffff match tcp dst 80 ffff action drop

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 17 ++++-------------
 2 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 10ccd96..c520f98 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8348,8 +8348,7 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 		int j;
 
 		for (j = 0; field_ptr[j].val; j++) {
-			if (field_ptr[j].off == off &&
-			    field_ptr[j].mask == m) {
+			if (field_ptr[j].off == off) {
 				field_ptr[j].val(input, &mask, val, m);
 				input->filter.formatted.flow_type |=
 					field_ptr[j].type;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
index ce48872..40d1730 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -65,28 +65,19 @@ static struct ixgbe_mat_field ixgbe_ipv4_fields[] = {
 	{ .val = NULL } /* terminal node */
 };
 
-static inline int ixgbe_mat_prgm_sport(struct ixgbe_fdir_filter *input,
+static inline int ixgbe_mat_prgm_ports(struct ixgbe_fdir_filter *input,
 				       union ixgbe_atr_input *mask,
 				       u32 val, u32 m)
 {
 	input->filter.formatted.src_port = val & 0xffff;
 	mask->formatted.src_port = m & 0xffff;
-	return 0;
-};
-
-static inline int ixgbe_mat_prgm_dport(struct ixgbe_fdir_filter *input,
-				       union ixgbe_atr_input *mask,
-				       u32 val, u32 m)
-{
-	input->filter.formatted.dst_port = val & 0xffff;
-	mask->formatted.dst_port = m & 0xffff;
+	input->filter.formatted.dst_port = val >> 16;
+	mask->formatted.dst_port = m  >> 16;
 	return 0;
 };
 
 static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
-	{.off = 0, .mask = 0xffff, .val = ixgbe_mat_prgm_sport,
-	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
-	{.off = 2, .mask = 0xffff, .val = ixgbe_mat_prgm_dport,
+	{.off = 0, .mask = 0xffffffff, .val = ixgbe_mat_prgm_ports,
 	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
 	{ .val = NULL } /* terminal node */
 };
-- 
2.1.0
