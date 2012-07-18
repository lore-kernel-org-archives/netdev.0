From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] ixgbevf: fix VF untagging when 802.1 prio is set
Date: Wed, 18 Jul 2012 13:31:48 -0700
Message-ID: <1342643516-2696-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pascal Bouchareine <pascal@gandi.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939Ab2GRUcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:00 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pascal Bouchareine <pascal@gandi.net>

We have had an issue when using ixgbe+ixgbevf and 802.1 VLAN tagging.

When attaching a VLAN to a VF, frames with a 802.1q priority appeared
untagged on the VF hence not reaching the VLAN, where frames with
priority 0 where tagged as expected and seen by the VLAN device.

This seems due to the way ixgbevf is looking up the full tag
(prio+cfi+vlan) against the adapter active_vlans, as a condition to mark
the skb tagged.

Signed-off-by: Pascal Bouchareine <pascal@gandi.net>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c98cdf7..b88218c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -279,7 +279,7 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (is_vlan && test_bit(tag, adapter->active_vlans))
+	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
 		__vlan_hwaccel_put_tag(skb, tag);
 
 	napi_gro_receive(&q_vector->napi, skb);
-- 
1.7.10.4
