From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 11/11] ixgbe: Fix cls_u32 offload support for L4 ports
Date: Wed, 30 Mar 2016 16:00:55 -0700
Message-ID: <1459378855-139837-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:43003 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbcC3XA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:00:59 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Fix support for 16 bit source/dest port matches in ixgbe model.
u32 uses a single 32-bit key value for both source and destination ports
starting at offset 0. So replace the 2 functions with a single function
that takes this key value/mask to program both source and dest ports.

Verified with the following filter:

 #tc qdisc add dev p4p1 ingress
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1: u32 divisor 1
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:10 u32 ht 800: link 1: \
	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1:0:10 u32 ht 1: \
	match tcp src 1024 ffff match tcp dst 80 ffff action drop
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1:0:11 u32 ht 1: \
	match tcp src 1025 ffff action drop
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 1:0:12 u32 ht 1: \
	match tcp dst 81 ffff action drop

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
index 61f7290..74c53ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -64,28 +64,20 @@ static struct ixgbe_mat_field ixgbe_ipv4_fields[] = {
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
+	input->filter.formatted.dst_port = val >> 16;
+	mask->formatted.dst_port = m >> 16;
 
-static inline int ixgbe_mat_prgm_dport(struct ixgbe_fdir_filter *input,
-				       union ixgbe_atr_input *mask,
-				       u32 val, u32 m)
-{
-	input->filter.formatted.dst_port = val & 0xffff;
-	mask->formatted.dst_port = m & 0xffff;
 	return 0;
 };
 
 static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
-	{.off = 0, .val = ixgbe_mat_prgm_sport,
-	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
-	{.off = 2, .val = ixgbe_mat_prgm_dport,
+	{.off = 0, .val = ixgbe_mat_prgm_ports,
 	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
 	{ .val = NULL } /* terminal node */
 };
-- 
2.5.5
