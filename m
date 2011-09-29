From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] ixgbevf: Fix broken trunk vlan
Date: Wed, 28 Sep 2011 23:30:10 -0700
Message-ID: <1317277816-6024-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18142 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621Ab1I2GaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:20 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Changes to clean up the vlan rx path broke trunk vlan.  Trunk vlans in
a VF driver are those set using:

"ip link set <pfdev> vf <n> <vlanid>"

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
CC: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d72905b..4930c46 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -293,12 +293,10 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
+	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (is_vlan) {
-		u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
-
+	if (is_vlan && test_bit(tag, adapter->active_vlans))
 		__vlan_hwaccel_put_tag(skb, tag);
-	}
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
 			napi_gro_receive(&q_vector->napi, skb);
-- 
1.7.6.2
