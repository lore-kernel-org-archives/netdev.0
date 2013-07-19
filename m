From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 4/9] qlcnic: Fix multicast packet handling for PF and VF.
Date: Fri, 19 Jul 2013 16:56:29 -0400
Message-ID: <1374267394-27697-5-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0253.outbound.messaging.microsoft.com ([213.199.154.253]:14119
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752117Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Multicast MAC was not getting programmed due to which multicast
  packets were being dropped by FW.

This patch fixes commit 168e4fb54c11865668ad50eff81b5f2729e0e0f4
("qlcnic: Secondary unicast MAC address support.") which introduced
bug in handling multicast packets.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 5b5d2ed..4ed7e73 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -516,20 +516,18 @@ void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 	if (netdev->flags & IFF_PROMISC) {
 		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
 			mode = VPORT_MISS_MODE_ACCEPT_ALL;
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		if (netdev_mc_count(netdev) > ahw->max_mc_count) {
-			mode = VPORT_MISS_MODE_ACCEPT_MULTI;
-		} else if (!netdev_mc_empty(netdev) &&
-			   !qlcnic_sriov_vf_check(adapter)) {
-				netdev_for_each_mc_addr(ha, netdev)
-					qlcnic_nic_add_mac(adapter, ha->addr,
-							   vlan);
-		}
-		if (mode != VPORT_MISS_MODE_ACCEPT_MULTI &&
-		    qlcnic_sriov_vf_check(adapter))
-			qlcnic_vf_add_mc_list(netdev, vlan);
+	} else if ((netdev->flags & IFF_ALLMULTI) ||
+		   (netdev_mc_count(netdev) > ahw->max_mc_count)) {
+		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+	} else if (!netdev_mc_empty(netdev) &&
+		   !qlcnic_sriov_vf_check(adapter)) {
+		netdev_for_each_mc_addr(ha, netdev)
+			qlcnic_nic_add_mac(adapter, ha->addr, vlan);
 	}
 
+	if (qlcnic_sriov_vf_check(adapter))
+		qlcnic_vf_add_mc_list(netdev, vlan);
+
 	/* configure unicast MAC address, if there is not sufficient space
 	 * to store all the unicast addresses then enable promiscuous mode
 	 */
-- 
1.7.1
