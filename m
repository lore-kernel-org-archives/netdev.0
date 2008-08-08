From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/7] netxen: force link update across ifdown/ifup
Date: Fri,  8 Aug 2008 00:08:41 -0700
Message-ID: <1218179325-32493-4-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:60715 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752580AbYHHHIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 03:08:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-read link status in dev open(). Schedule link watchdog only
if dev is up.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 056f6b1..f69807c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -934,7 +934,6 @@ request_msi:
 		goto err_out_disable_msi;
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->ahw.linkup = 0;
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
@@ -1134,6 +1133,7 @@ static int netxen_nic_open(struct net_device *netdev)
 	if (adapter->set_mtu)
 		adapter->set_mtu(adapter, netdev->mtu);
 
+	adapter->ahw.linkup = 0;
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	napi_enable(&adapter->napi);
@@ -1171,10 +1171,8 @@ static int netxen_nic_close(struct net_device *netdev)
 
 	netxen_release_tx_buffers(adapter);
 
-	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
-		FLUSH_SCHEDULED_WORK();
-		del_timer_sync(&adapter->watchdog_timer);
-	}
+	FLUSH_SCHEDULED_WORK();
+	del_timer_sync(&adapter->watchdog_timer);
 
 	return 0;
 }
@@ -1477,7 +1475,8 @@ void netxen_watchdog_task(struct work_struct *work)
 
 	netxen_nic_handle_phy_intr(adapter);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	if (netif_running(adapter->netdev))
+		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
 static void netxen_tx_timeout(struct net_device *netdev)
-- 
1.5.4.3

