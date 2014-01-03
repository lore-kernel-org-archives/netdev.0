From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/11] ixbge: Protect ixgbe_down with __IXGBE_DOWN bit
Date: Thu,  2 Jan 2014 21:18:20 -0800
Message-ID: <1388726310-2996-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48918 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841AbaACFSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:18:37 -0500
In-Reply-To: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The ixgbe_down function can now prevent multiple executions by
doing test_and_set_bit on __IXGBE_DOWN. This did not work before
introduction of the __IXGBE_REMOVED bit, because of overloading
of __IXGBE_DOWN. Also add smp_mb__before_clear_bit call before
clearing the __IXGBE_DOWN bit.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cc06854..90a0b4a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4572,6 +4572,7 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	if (hw->mac.ops.enable_tx_laser)
 		hw->mac.ops.enable_tx_laser(hw);
 
+	smp_mb__before_clear_bit();
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
@@ -4783,7 +4784,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	int i;
 
 	/* signal that we are down to the interrupt handler */
-	set_bit(__IXGBE_DOWN, &adapter->state);
+	if (test_and_set_bit(__IXGBE_DOWN, &adapter->state))
+		return; /* do nothing if already down */
 
 	/* disable receives */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
-- 
1.8.3.1
