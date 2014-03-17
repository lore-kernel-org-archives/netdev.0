From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/16] ixgbevf: Protect ixgbevf_down with __IXGBEVF_DOWN bit
Date: Mon, 17 Mar 2014 05:45:16 -0700
Message-ID: <1395060316-16897-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933267AbaCQMp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:45:27 -0400
In-Reply-To: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The ixgbevf_down function can now prevent multiple executions by
doing test_and_set_bit on __IXGBEVF_DOWN. This did not work before
introduction of the __IXGBEVF_REMOVING bit, because of overloading
of __IXGBEVF_DOWN. Also add smp_mb__before_clear_bit call before
clearing the __IXGBEVF_DOWN bit.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 940d924..a2cba53 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1620,6 +1620,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
+	smp_mb__before_clear_bit();
 	clear_bit(__IXGBEVF_DOWN, &adapter->state);
 	ixgbevf_napi_enable_all(adapter);
 
@@ -1744,7 +1745,8 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 	int i;
 
 	/* signal that we are down to the interrupt handler */
-	set_bit(__IXGBEVF_DOWN, &adapter->state);
+	if (test_and_set_bit(__IXGBEVF_DOWN, &adapter->state))
+		return; /* do nothing if already down */
 
 	/* disable all enabled rx queues */
 	for (i = 0; i < adapter->num_rx_queues; i++)
-- 
1.8.3.1
