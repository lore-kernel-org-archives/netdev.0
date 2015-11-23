From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbevf: fix spoofed packets with random MAC
Date: Mon, 23 Nov 2015 11:36:15 -0800
Message-ID: <1448307376-20063-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754800AbbKWTgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:23 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

If ixgbevf is loaded while the corresponding PF interface is down
and the driver assigns a random MAC address, that address can be
overwritten with the value of hw->mac.perm_addr, which would be 0 at
that point.

To avoid this case we init hw->mac.perm_addr to the randomly generated
address and do not set it unless we receive ACK from ixgbe.

Reported-by: John Greene <jogreene@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 1 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 47c71e1..dbbd1be 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2664,6 +2664,7 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 		dev_info(&pdev->dev, "Assigning random MAC address\n");
 		eth_hw_addr_random(netdev);
 		ether_addr_copy(hw->mac.addr, netdev->dev_addr);
+		ether_addr_copy(hw->mac.perm_addr, netdev->dev_addr);
 	}
 
 	/* Enable dynamic interrupt throttling rates */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 427f360..61a98f4 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -117,7 +117,9 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 	    msgbuf[0] != (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_NACK))
 		return IXGBE_ERR_INVALID_MAC_ADDR;
 
-	ether_addr_copy(hw->mac.perm_addr, addr);
+	if (msgbuf[0] == (IXGBE_VF_RESET | IXGBE_VT_MSGTYPE_ACK))
+		ether_addr_copy(hw->mac.perm_addr, addr);
+
 	hw->mac.mc_filter_type = msgbuf[IXGBE_VF_MC_TYPE_WORD];
 
 	return 0;
-- 
2.5.0
