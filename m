From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix minor tx timeout bug
Date: Sun, 20 Sep 2009 22:20:38 -0700
Message-ID: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:61689 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753753AbZIUFUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 01:20:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix minor bug in netdev tx timeout handling which could
always lead to firmware reset instead of pci function reset.

netxen_nic_reset_context() requires __NX_RESETTING bit
cleared.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f7bdde1..b8c7235 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1903,12 +1903,13 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 
 		netif_wake_queue(adapter->netdev);
 
-		goto done;
+		clear_bit(__NX_RESETTING, &adapter->state);
 
 	} else {
+		clear_bit(__NX_RESETTING, &adapter->state);
 		if (!netxen_nic_reset_context(adapter)) {
 			adapter->netdev->trans_start = jiffies;
-			goto done;
+			return;
 		}
 
 		/* context reset failed, fall through for fw reset */
@@ -1916,8 +1917,6 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 
 request_reset:
 	adapter->need_fw_reset = 1;
-done:
-	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
-- 
1.6.0.2

