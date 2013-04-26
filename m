From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] e1000e: panic caused by Rx traffic arriving while interface going down
Date: Thu, 25 Apr 2013 21:57:05 -0700
Message-ID: <1366952231-16727-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53194 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943Ab3DZE5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:17 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

An "unable to handle kernel paging request" panic can occur when receiving
traffic while the interface is going down.  Wait for NAPI to be done with
current context after disabling interrupts and then disable NAPI.

See https://bugzilla.vyatta.com/show_bug.cgi?id=8837.

Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index da7f2fa..a27e3bc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4016,6 +4016,8 @@ void e1000e_down(struct e1000_adapter *adapter)
 
 	e1000_irq_disable(adapter);
 
+	napi_synchronize(&adapter->napi);
+
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
@@ -4372,12 +4374,13 @@ static int e1000_close(struct net_device *netdev)
 
 	pm_runtime_get_sync(&pdev->dev);
 
-	napi_disable(&adapter->napi);
-
 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
 		e1000e_down(adapter);
 		e1000_free_irq(adapter);
 	}
+
+	napi_disable(&adapter->napi);
+
 	e1000_power_down_phy(adapter);
 
 	e1000e_free_tx_resources(adapter->tx_ring);
-- 
1.7.11.7
