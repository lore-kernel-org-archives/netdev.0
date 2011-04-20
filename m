From: timg@tpi.com (Tim Gardner)
Subject: [PATCH] atl1c: Fix work event interrupt/task races
Date: Wed, 20 Apr 2011 13:00:49 -0600 (MDT)
Message-ID: <20110420190049.185C6F88D3@sepang.rtg.net>
Cc: jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4125 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab1DTTbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 15:31:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eab846b1823e05a045a28d2c87e219ef1b6e3c49
Author: Tim Gardner <tim.gardner@canonical.com>
Date:   Wed Apr 20 11:31:09 2011 -0600

    atl1c: Fix work event interrupt/task races
    
    The mechanism used to initiate work events from the interrupt
    handler has a classic read/modify/write race between the interrupt
    handler that sets the condition, and the worker task that reads and
    clears the condition. Close these races by using atomic
    bit fields.
    
    Cc: stable@kernel.org
    Cc: Jie Yang <jie.yang@atheros.com>
    Signed-off-by: Tim Gardner <tim.gardner@canonical.com>

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 9ab5809..dec8110 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -566,9 +566,9 @@ struct atl1c_adapter {
 #define __AT_TESTING        0x0001
 #define __AT_RESETTING      0x0002
 #define __AT_DOWN           0x0003
-	u8 work_event;
-#define ATL1C_WORK_EVENT_RESET 		0x01
-#define ATL1C_WORK_EVENT_LINK_CHANGE	0x02
+	unsigned long work_event;
+#define	ATL1C_WORK_EVENT_RESET		0
+#define	ATL1C_WORK_EVENT_LINK_CHANGE	1
 	u32 msg_enable;
 
 	bool have_msi;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 3824382..dffc7f7 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -325,7 +325,7 @@ static void atl1c_link_chg_event(struct atl1c_adapter *adapter)
 		}
 	}
 
-	adapter->work_event |= ATL1C_WORK_EVENT_LINK_CHANGE;
+	set_bit(ATL1C_WORK_EVENT_LINK_CHANGE, &adapter->work_event);
 	schedule_work(&adapter->common_task);
 }
 
@@ -337,20 +337,16 @@ static void atl1c_common_task(struct work_struct *work)
 	adapter = container_of(work, struct atl1c_adapter, common_task);
 	netdev = adapter->netdev;
 
-	if (adapter->work_event & ATL1C_WORK_EVENT_RESET) {
-		adapter->work_event &= ~ATL1C_WORK_EVENT_RESET;
+	if (test_and_clear_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event)) {
 		netif_device_detach(netdev);
 		atl1c_down(adapter);
 		atl1c_up(adapter);
 		netif_device_attach(netdev);
-		return;
 	}
 
-	if (adapter->work_event & ATL1C_WORK_EVENT_LINK_CHANGE) {
-		adapter->work_event &= ~ATL1C_WORK_EVENT_LINK_CHANGE;
+	if (test_and_clear_bit(ATL1C_WORK_EVENT_LINK_CHANGE,
+		&adapter->work_event))
 		atl1c_check_link_status(adapter);
-	}
-	return;
 }
 
 
@@ -369,7 +365,7 @@ static void atl1c_tx_timeout(struct net_device *netdev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	/* Do the reset outside of interrupt context */
-	adapter->work_event |= ATL1C_WORK_EVENT_RESET;
+	set_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event);
 	schedule_work(&adapter->common_task);
 }
 
