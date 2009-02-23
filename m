From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/5] [net-next] qlge: Change frame route hw semaphore granularity.
Date: Mon, 23 Feb 2009 12:42:15 -0800
Message-ID: <1235421737-32296-3-git-send-email-ron.mercer@qlogic.com>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:3006 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbZBWUpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 15:45:41 -0500
In-Reply-To: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of taking/giving the hw semaphore repeatedly when iterating over
several frame to queue route settings, we have the caller hold it until
all are done.
This reduces PCI bus chatter and possible waits.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   31 +++++++++++++------------------
 1 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d316e50..16c056a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -418,10 +418,6 @@ int ql_get_routing_reg(struct ql_adapter *qdev, u32 index, u32 *value)
 {
 	int status = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
-	if (status)
-		goto exit;
-
 	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MW, 0);
 	if (status)
 		goto exit;
@@ -433,7 +429,6 @@ int ql_get_routing_reg(struct ql_adapter *qdev, u32 index, u32 *value)
 		goto exit;
 	*value = ql_read32(qdev, RT_DATA);
 exit:
-	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
 }
 
@@ -445,13 +440,9 @@ exit:
 static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 			      int enable)
 {
-	int status;
+	int status = -EINVAL; /* Return error if no mask match. */
 	u32 value = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
-	if (status)
-		return status;
-
 	QPRINTK(qdev, IFUP, DEBUG,
 		"%s %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s mask %s the routing reg.\n",
 		(enable ? "Adding" : "Removing"),
@@ -547,7 +538,6 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 		ql_write32(qdev, RT_DATA, enable ? mask : 0);
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
 }
 
@@ -2916,13 +2906,17 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 	int status = 0;
 	int i;
 
+	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (status)
+		return status;
+
 	/* Clear all the entries in the routing table. */
 	for (i = 0; i < 16; i++) {
 		status = ql_set_routing_reg(qdev, i, 0, 0);
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR,
 				"Failed to init routing register for CAM packets.\n");
-			return status;
+			goto exit;
 		}
 	}
 
@@ -2930,13 +2924,13 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR,
 			"Failed to init routing register for error packets.\n");
-		return status;
+		goto exit;
 	}
 	status = ql_set_routing_reg(qdev, RT_IDX_BCAST_SLOT, RT_IDX_BCAST, 1);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR,
 			"Failed to init routing register for broadcast packets.\n");
-		return status;
+		goto exit;
 	}
 	/* If we have more than one inbound queue, then turn on RSS in the
 	 * routing block.
@@ -2947,17 +2941,17 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR,
 				"Failed to init routing register for MATCH RSS packets.\n");
-			return status;
+			goto exit;
 		}
 	}
 
 	status = ql_set_routing_reg(qdev, RT_IDX_CAM_HIT_SLOT,
 				    RT_IDX_CAM_HIT, 1);
-	if (status) {
+	if (status)
 		QPRINTK(qdev, IFUP, ERR,
 			"Failed to init routing register for CAM packets.\n");
-		return status;
-	}
+exit:
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
 }
 
@@ -3518,6 +3512,7 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 	}
 exit:
 	spin_unlock(&qdev->hw_lock);
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
 static int qlge_set_mac_address(struct net_device *ndev, void *p)
-- 
1.6.0.2

