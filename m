From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/5] ixgb: call netif_carrier_off early on down
Date: Fri, 20 Mar 2015 17:57:41 -0700
Message-ID: <1426899465-15789-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50519 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbbCUA55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 20:57:57 -0400
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

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 11a1bdb..31f9145 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -285,6 +285,8 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 	/* prevent the interrupt handler from restarting watchdog */
 	set_bit(__IXGB_DOWN, &adapter->flags);
 
+	netif_carrier_off(netdev);
+
 	napi_disable(&adapter->napi);
 	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
@@ -298,7 +300,6 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
-	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
 	ixgb_reset(adapter);
-- 
1.9.3
