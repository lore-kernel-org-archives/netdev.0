From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] fm10k: ignore invalid multicast address entries
Date: Tue, 16 Jun 2015 06:47:13 -0700
Message-ID: <1434462448-140563-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Ngai-Mint Kwan <ngai-mint.kwan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24718 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756693AbbFPNrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 09:47:32 -0400
In-Reply-To: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This change fixes an issue with adding an invalid multicast address
using the iproute2 tool (ip maddr add <MADDR> dev <dev>). The iproute2
tool and the kernel do not validate or filter the multicast addresses
when adding them to the multicast list. Thus, when synchronizing this
list with an invalid entry, the action will be aborted with an error
since the fm10k driver currently validates the list. Consequently,
multicast entries beyond the invalid one will not be processed and
communicated with the switch via the mailbox. This change makes it so
that invalid addresses will simply be skipped and allows synchronizing
the full list to proceed.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 2f4f41b..4c6b511 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -923,18 +923,12 @@ static int __fm10k_mc_sync(struct net_device *dev,
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_hw *hw = &interface->hw;
 	u16 vid, glort = interface->glort;
-	s32 err;
-
-	if (!is_multicast_ether_addr(addr))
-		return -EADDRNOTAVAIL;
 
 	/* update table with current entries */
 	for (vid = hw->mac.default_vid ? fm10k_find_next_vlan(interface, 0) : 0;
 	     vid < VLAN_N_VID;
 	     vid = fm10k_find_next_vlan(interface, vid)) {
-		err = hw->mac.ops.update_mc_addr(hw, glort, addr, vid, sync);
-		if (err)
-			return err;
+		hw->mac.ops.update_mc_addr(hw, glort, addr, vid, sync);
 	}
 
 	return 0;
-- 
2.4.3
