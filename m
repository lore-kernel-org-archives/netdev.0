From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/1] qla3xxx: Cleanup: Fix link print statements.
Date: Tue, 11 Nov 2008 09:54:54 -0800
Message-ID: <20081111175454.GD4328@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org, davej@redhat.com,
	cebbert@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:45085 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbYKKRy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 12:54:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed debug print statements and improved conditionals around informational statements.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   19 +++++--------------
 1 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 3cdd07c..508452c 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1515,9 +1515,6 @@ static u32 ql_get_link_state(struct ql3_adapter *qdev)
 		linkState = LS_UP;
 	} else {
 		linkState = LS_DOWN;
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Link is down.\n", qdev->ndev->name);
 	}
 	return linkState;
 }
@@ -1581,10 +1578,6 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 			ql_mac_enable(qdev, 1);
 		}
 
-		if (netif_msg_link(qdev))
-			printk(KERN_DEBUG PFX
-			       "%s: Change port_link_state LS_DOWN to LS_UP.\n",
-			       qdev->ndev->name);
 		qdev->port_link_state = LS_UP;
 		netif_start_queue(qdev->ndev);
 		netif_carrier_on(qdev->ndev);
@@ -1655,14 +1648,9 @@ static void ql_link_state_machine_work(struct work_struct *work)
 		/* Fall Through */
 
 	case LS_DOWN:
-		if (netif_msg_link(qdev))
-			printk(KERN_DEBUG PFX
-			       "%s: port_link_state = LS_DOWN.\n",
-			       qdev->ndev->name);
 		if (curr_link_state == LS_UP) {
 			if (netif_msg_link(qdev))
-				printk(KERN_DEBUG PFX
-				       "%s: curr_link_state = LS_UP.\n",
+				printk(KERN_INFO PFX "%s: Link is up.\n",
 				       qdev->ndev->name);
 			if (ql_is_auto_neg_complete(qdev))
 				ql_finish_auto_neg(qdev);
@@ -1670,6 +1658,7 @@ static void ql_link_state_machine_work(struct work_struct *work)
 			if (qdev->port_link_state == LS_UP)
 				ql_link_down_detect_clear(qdev);
 
+			qdev->port_link_state = LS_UP;
 		}
 		break;
 
@@ -1678,12 +1667,14 @@ static void ql_link_state_machine_work(struct work_struct *work)
 		 * See if the link is currently down or went down and came
 		 * back up
 		 */
-		if ((curr_link_state == LS_DOWN) || ql_link_down_detect(qdev)) {
+		if (curr_link_state == LS_DOWN) {
 			if (netif_msg_link(qdev))
 				printk(KERN_INFO PFX "%s: Link is down.\n",
 				       qdev->ndev->name);
 			qdev->port_link_state = LS_DOWN;
 		}
+		if (ql_link_down_detect(qdev))
+			qdev->port_link_state = LS_DOWN;
 		break;
 	}
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
-- 
1.6.0

