From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/3] netxen: fix thermal check and shutdown
Date: Fri, 17 Jul 2009 18:27:08 -0700
Message-ID: <1247880428-4895-4-git-send-email-dhananjay@netxen.com>
References: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:44295 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754326AbZGRB1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2009 21:27:10 -0400
In-Reply-To: <1247880428-4895-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check temperature for all PCI functions, that can allow
graceful shutdown of all interfaces on the overheated card.

Old code was only monitoring temperature for function 0 only.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 370c52f..637ac8b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1535,10 +1535,12 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 		printk(KERN_ALERT
 		       "%s: Device temperature %d degrees C exceeds"
 		       " maximum allowed. Hardware has been shut down.\n",
-		       netxen_nic_driver_name, temp_val);
+		       netdev->name, temp_val);
+
+		netif_device_detach(netdev);
+		netxen_nic_down(adapter, netdev);
+		netxen_nic_detach(adapter);
 
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
 		rv = 1;
 	} else if (temp_state == NX_TEMP_WARN) {
 		if (adapter->temp == NX_TEMP_NORMAL) {
@@ -1546,13 +1548,13 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 			       "%s: Device temperature %d degrees C "
 			       "exceeds operating range."
 			       " Immediate action needed.\n",
-			       netxen_nic_driver_name, temp_val);
+			       netdev->name, temp_val);
 		}
 	} else {
 		if (adapter->temp == NX_TEMP_WARN) {
 			printk(KERN_INFO
 			       "%s: Device temperature is now %d degrees C"
-			       " in normal range.\n", netxen_nic_driver_name,
+			       " in normal range.\n", netdev->name,
 			       temp_val);
 		}
 	}
@@ -1625,7 +1627,7 @@ void netxen_watchdog_task(struct work_struct *work)
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, watchdog_task);
 
-	if ((adapter->portnum  == 0) && netxen_nic_check_temp(adapter))
+	if (netxen_nic_check_temp(adapter))
 		return;
 
 	if (!adapter->has_link_events)
-- 
1.6.0.2

