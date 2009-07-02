From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 6/8] qlge: Fix MAC address bonding issue.
Date: Thu,  2 Jul 2009 09:06:11 -0700
Message-ID: <1246550773-18417-6-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZGBQLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:34 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This addes functionality to set/clear the MAC address in the hardware
when the link goes up/down.
The MAC address register is persistent across function resets. In
bonding the same address can bounce from one port to the other.  This
can cause packets to be delivered to the wrong port.
This patch clears the MAC address in the hardware when the link is down
and sets it when the link comes up.
It was found that pulling/pushing the cable from one port to another
causes the same MAC address to be in both ports.
The next patch in this series will use this functionality as well.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   50 ++++++++++++++++++++++++++++++++++++------
 1 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 74ed84a..46dea2b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -413,6 +413,41 @@ exit:
 	return status;
 }
 
+/* Set or clear MAC address in hardware. We sometimes
+ * have to clear it to prevent wrong frame routing
+ * especially in a bonding environment.
+ */
+static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
+{
+	int status;
+	char zero_mac_addr[ETH_ALEN];
+	char *addr;
+
+	if (set) {
+		addr = &qdev->ndev->dev_addr[0];
+		QPRINTK(qdev, IFUP, DEBUG,
+			"Set Mac addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+			addr[0], addr[1], addr[2], addr[3],
+			addr[4], addr[5]);
+	} else {
+		memset(zero_mac_addr, 0, ETH_ALEN);
+		addr = &zero_mac_addr[0];
+		QPRINTK(qdev, IFUP, DEBUG,
+				"Clearing MAC address on %s\n",
+				qdev->ndev->name);
+	}
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return status;
+	status = ql_set_mac_addr_reg(qdev, (u8 *) addr,
+			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		QPRINTK(qdev, IFUP, ERR, "Failed to init mac "
+			"address.\n");
+	return status;
+}
+
 /* Get a specific frame routing value from the CAM.
  * Used for debug and reg dump.
  */
@@ -3112,14 +3147,15 @@ exit:
 
 int ql_cam_route_initialize(struct ql_adapter *qdev)
 {
-	int status;
+	int status, set;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return status;
-	status = ql_set_mac_addr_reg(qdev, (u8 *) qdev->ndev->perm_addr,
-			     MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
+	/* If check if the link is up and use to
+	 * determine if we are setting or clearing
+	 * the MAC address in the CAM.
+	 */
+	set = ql_read32(qdev, STS);
+	set &= qdev->port_link_up;
+	status = ql_set_mac_addr(qdev, set);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to init mac address.\n");
 		return status;
-- 
1.6.0.2

