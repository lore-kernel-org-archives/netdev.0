From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] e1000e: call netif_carrier_off early on down
Date: Fri, 20 Mar 2015 17:57:42 -0700
Message-ID: <1426899465-15789-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50519 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbbCUA56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 20:57:58 -0400
In-Reply-To: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>

When bringing down an interface netif_carrier_off() should be
one the first things we do, since this will prevent the stack
from queuing more packets to this interface.
This operation is very fast, and should make the device behave
much nicer when trying to bring down an interface under load.

Also, this would Do The Right Thing (TM) if this device has some
sort of fail-over teaming and redirect traffic to the other IF.

Move netif_carrier_off as early as possible.

CC: Kristen Carlson Accardi <kristen@linux.intel.com>
Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 4be4576..8c95fb8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4084,6 +4084,8 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 	 */
 	set_bit(__E1000_DOWN, &adapter->state);
 
+	netif_carrier_off(netdev);
+
 	/* disable receives in the hardware */
 	rctl = er32(RCTL);
 	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
@@ -4108,8 +4110,6 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	netif_carrier_off(netdev);
-
 	spin_lock(&adapter->stats64_lock);
 	e1000e_update_stats(adapter);
 	spin_unlock(&adapter->stats64_lock);
-- 
1.9.3
