From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/7] i40e: fix TCP flag replication for hardware offload
Date: Fri, 18 Apr 2014 18:59:22 -0700
Message-ID: <1397872767-4001-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2813 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753868AbaDSB7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 21:59:31 -0400
In-Reply-To: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As reported by Eric Dumazet, the i40e driver was allowing the hardware
to replicate the PSH flag on all segments of a TSO operation.

This patch fixes the first/middle/last TCP flags settings which
makes the TSO operations work correctly.

With this change we are now configuring the CWR bit to only be set
in the first packet of a TSO, so this patch also enables TSO_ECN,
in order to advertise to the stack that we do the right thing
on the wire.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 861b722..59eada3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4271,6 +4271,14 @@ static int i40e_open(struct net_device *netdev)
 	if (err)
 		return err;
 
+	/* configure global TSO hardware offload settings */
+	wr32(&pf->hw, I40E_GLLAN_TSOMSK_F, be32_to_cpu(TCP_FLAG_PSH |
+						       TCP_FLAG_FIN) >> 16);
+	wr32(&pf->hw, I40E_GLLAN_TSOMSK_M, be32_to_cpu(TCP_FLAG_PSH |
+						       TCP_FLAG_FIN |
+						       TCP_FLAG_CWR) >> 16);
+	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
+
 #ifdef CONFIG_I40E_VXLAN
 	vxlan_get_rx_port(netdev);
 #endif
@@ -6712,6 +6720,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			   NETIF_F_HW_VLAN_CTAG_FILTER |
 			   NETIF_F_IPV6_CSUM	       |
 			   NETIF_F_TSO		       |
+			   NETIF_F_TSO_ECN	       |
 			   NETIF_F_TSO6		       |
 			   NETIF_F_RXCSUM	       |
 			   NETIF_F_NTUPLE	       |
-- 
1.9.0
