From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v4 2/7] ixbge: Protect ixgbe_down with __IXGBE_DOWN bit
Date: Tue, 14 Jan 2014 18:53:12 -0800
Message-ID: <1389754397-2507-3-git-send-email-aaron.f.brown@intel.com>
References: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26829 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbaAOCxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 21:53:31 -0500
In-Reply-To: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The ixgbe_down function can now prevent multiple executions by
doing test_and_set_bit on __IXGBE_DOWN. This did not work before
introduction of the __IXGBE_REMOVING bit, because of overloading
of __IXGBE_DOWN. Also add smp_mb__before_clear_bit call before
clearing the __IXGBE_DOWN bit.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bf7d177..44a2619 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4573,6 +4573,7 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	if (hw->mac.ops.enable_tx_laser)
 		hw->mac.ops.enable_tx_laser(hw);
 
+	smp_mb__before_clear_bit();
 	clear_bit(__IXGBE_DOWN, &adapter->state);
 	ixgbe_napi_enable_all(adapter);
 
@@ -4784,7 +4785,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	int i;
 
 	/* signal that we are down to the interrupt handler */
-	set_bit(__IXGBE_DOWN, &adapter->state);
+	if (test_and_set_bit(__IXGBE_DOWN, &adapter->state))
+		return; /* do nothing if already down */
 
 	/* disable receives */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
-- 
1.8.5.GIT
