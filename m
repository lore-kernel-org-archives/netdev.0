From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/1] netxen: protect tx timeout recovery by rtnl lock
Date: Fri,  6 Aug 2010 06:33:31 -0700
Message-ID: <1281101611-16893-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24947 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761334Ab0HFNdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 09:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6ce6ce1..fd86e18 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2001,27 +2001,26 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	if (++adapter->tx_timeo_cnt >= NX_MAX_TX_TIMEOUTS)
 		goto request_reset;
 
+	rtnl_lock();
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		/* try to scrub interrupt */
 		netxen_napi_disable(adapter);
 
-		adapter->netdev->trans_start = jiffies;
-
 		netxen_napi_enable(adapter);
 
 		netif_wake_queue(adapter->netdev);
 
 		clear_bit(__NX_RESETTING, &adapter->state);
-		return;
 	} else {
 		clear_bit(__NX_RESETTING, &adapter->state);
-		if (!netxen_nic_reset_context(adapter)) {
-			adapter->netdev->trans_start = jiffies;
-			return;
+		if (netxen_nic_reset_context(adapter)) {
+			rtnl_unlock();
+			goto request_reset;
 		}
-
-		/* context reset failed, fall through for fw reset */
 	}
+	adapter->netdev->trans_start = jiffies;
+	rtnl_unlock();
+	return;
 
 request_reset:
 	adapter->need_fw_reset = 1;
-- 
1.6.0.2

