From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 10/11] ixgbe: Fix cls_u32 offload support for fields with masks
Date: Wed, 30 Mar 2016 16:00:54 -0700
Message-ID: <1459378855-139837-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65047 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbcC3XBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:03 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

Remove the incorrect check for mask in ixgbe_configure_clsu32 and
drop the 'mask' field that is not required in struct ixgbe_mat_field

Verified with the following filters:

 #tc qdisc add dev p4p1 ingress
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:1 u32 ht 800: \
	match ip dst 10.0.0.1/8 match ip src 10.0.0.2/8 action drop
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:2 u32 ht 800: \
	match ip dst 11.0.0.1/16 match ip src 11.0.0.2/16 action drop
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:3 u32 ht 800: \
	match ip dst 12.0.0.1/24 match ip src 12.0.0.2/24 action drop
 #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
	handle 800:0:4 u32 ht 800: \
	match ip dst 13.0.0.1/32 match ip src 13.0.0.2/32 action drop

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 9 ++++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ca9c543..7df3fe2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8331,8 +8331,7 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 		int j;
 
 		for (j = 0; field_ptr[j].val; j++) {
-			if (field_ptr[j].off == off &&
-			    field_ptr[j].mask == m) {
+			if (field_ptr[j].off == off) {
 				field_ptr[j].val(input, &mask, val, m);
 				input->filter.formatted.flow_type |=
 					field_ptr[j].type;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
index ce48872..61f7290 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -32,7 +32,6 @@
 
 struct ixgbe_mat_field {
 	unsigned int off;
-	unsigned int mask;
 	int (*val)(struct ixgbe_fdir_filter *input,
 		   union ixgbe_atr_input *mask,
 		   u32 val, u32 m);
@@ -58,9 +57,9 @@ static inline int ixgbe_mat_prgm_dip(struct ixgbe_fdir_filter *input,
 }
 
 static struct ixgbe_mat_field ixgbe_ipv4_fields[] = {
-	{ .off = 12, .mask = -1, .val = ixgbe_mat_prgm_sip,
+	{ .off = 12, .val = ixgbe_mat_prgm_sip,
 	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
-	{ .off = 16, .mask = -1, .val = ixgbe_mat_prgm_dip,
+	{ .off = 16, .val = ixgbe_mat_prgm_dip,
 	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
 	{ .val = NULL } /* terminal node */
 };
@@ -84,9 +83,9 @@ static inline int ixgbe_mat_prgm_dport(struct ixgbe_fdir_filter *input,
 };
 
 static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
-	{.off = 0, .mask = 0xffff, .val = ixgbe_mat_prgm_sport,
+	{.off = 0, .val = ixgbe_mat_prgm_sport,
 	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
-	{.off = 2, .mask = 0xffff, .val = ixgbe_mat_prgm_dport,
+	{.off = 2, .val = ixgbe_mat_prgm_dport,
 	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
 	{ .val = NULL } /* terminal node */
 };
-- 
2.5.5
