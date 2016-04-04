From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbe: Extend cls_u32 offload to support UDP headers
Date: Mon,  4 Apr 2016 15:14:56 -0700
Message-ID: <1459808097-26409-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14491 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609AbcDDWPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 18:15:05 -0400
In-Reply-To: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

Added support to match on UDP fields in the transport layer.
Extended core logic to support multiple headers.

Verified with the following filters :

	handle 1: u32 divisor 1
	u32 ht 800: order 1 link 1: \
	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
	u32 ht 1: order 2 \
	match tcp src 1024 ffff match tcp dst 23 ffff action drop
	handle 2: u32 divisor 1
	u32 ht 800: order 3 link 2: \
	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 17 ff
	u32 ht 2: order 4 \
	match udp src 1025 ffff match udp dst 24 ffff action drop

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 19 ++++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |  8 ++++++++
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d8b67d2..dcaac50 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8257,19 +8257,20 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 			return -EINVAL;
 
 		for (i = 0; nexthdr[i].jump; i++) {
-			if (nexthdr->o != cls->knode.sel->offoff ||
-			    nexthdr->s != cls->knode.sel->offshift ||
-			    nexthdr->m != cls->knode.sel->offmask ||
+			if (nexthdr[i].o != cls->knode.sel->offoff ||
+			    nexthdr[i].s != cls->knode.sel->offshift ||
+			    nexthdr[i].m != cls->knode.sel->offmask ||
 			    /* do not support multiple key jumps its just mad */
 			    cls->knode.sel->nkeys > 1)
 				return -EINVAL;
 
-			if (nexthdr->off != cls->knode.sel->keys[0].off ||
-			    nexthdr->val != cls->knode.sel->keys[0].val ||
-			    nexthdr->mask != cls->knode.sel->keys[0].mask)
-				return -EINVAL;
-
-			adapter->jump_tables[link_uhtid] = nexthdr->jump;
+			if (nexthdr[i].off == cls->knode.sel->keys[0].off &&
+			    nexthdr[i].val == cls->knode.sel->keys[0].val &&
+			    nexthdr[i].mask == cls->knode.sel->keys[0].mask) {
+				adapter->jump_tables[link_uhtid] =
+								nexthdr[i].jump;
+				break;
+			}
 		}
 		return 0;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
index 74c53ad..60adde5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
@@ -82,6 +82,12 @@ static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
 	{ .val = NULL } /* terminal node */
 };
 
+static struct ixgbe_mat_field ixgbe_udp_fields[] = {
+	{.off = 0, .val = ixgbe_mat_prgm_ports,
+	 .type = IXGBE_ATR_FLOW_TYPE_UDPV4},
+	{ .val = NULL } /* terminal node */
+};
+
 struct ixgbe_nexthdr {
 	/* offset, shift, and mask of position to next header */
 	unsigned int o;
@@ -98,6 +104,8 @@ struct ixgbe_nexthdr {
 static struct ixgbe_nexthdr ixgbe_ipv4_jumps[] = {
 	{ .o = 0, .s = 6, .m = 0xf,
 	  .off = 8, .val = 0x600, .mask = 0xff00, .jump = ixgbe_tcp_fields},
+	{ .o = 0, .s = 6, .m = 0xf,
+	  .off = 8, .val = 0x1100, .mask = 0xff00, .jump = ixgbe_udp_fields},
 	{ .jump = NULL } /* terminal node */
 };
 #endif /* _IXGBE_MODEL_H_ */
-- 
2.5.5
