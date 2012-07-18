From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbevf: fix VF untagging when 802.1 prio is set
Date: Tue, 17 Jul 2012 19:23:56 -0700
Message-ID: <1342578236-20036-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Pascal Bouchareine <pascal@gandi.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20629 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011Ab2GRCX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:23:58 -0400
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
index 41e3225..c16d32f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -304,7 +304,7 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (is_vlan && test_bit(tag, adapter->active_vlans))
+	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
 		__vlan_hwaccel_put_tag(skb, tag);
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-- 
1.7.10.4
