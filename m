From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 06/21] [next] qlge: Expand granularity on holding hardware semaphore.
Date: Fri, 23 Jan 2009 07:16:24 -0800
Message-ID: <1232723799-8620-6-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbZAWPRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:45 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This semaphore must be held when we change frame routing, MAC
addresses etc.  In many cases several values will be changed
iteratively. This patch causes the sem to be held until all
values are changed, rather than take/give for each value.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c  |   12 +++++++
 drivers/net/qlge/qlge_main.c |   71 +++++++++++++++++++++++++-----------------
 2 files changed, 54 insertions(+), 29 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 379b895..cdf12d3 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -83,6 +83,11 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 {
 	int i;
 	u32 value[3];
+
+	i = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (i)
+		return;
+
 	for (i = 0; i < 4; i++) {
 		if (ql_get_mac_addr_reg(qdev, MAC_ADDR_TYPE_CAM_MAC, i, value)) {
 			printk(KERN_ERR PFX
@@ -111,12 +116,18 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 				       qdev->ndev->name, i, value[1], value[0]);
 		}
 	}
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
 void ql_dump_routing_entries(struct ql_adapter *qdev)
 {
 	int i;
 	u32 value;
+
+	i = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (i)
+		return;
+
 	for (i = 0; i < 16; i++) {
 		value = 0;
 		if (ql_get_routing_reg(qdev, i, &value)) {
@@ -131,6 +142,7 @@ void ql_dump_routing_entries(struct ql_adapter *qdev)
 				       qdev->ndev->name, i, value);
 		}
 	}
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
 void ql_dump_regs(struct ql_adapter *qdev)
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 236597d..0db99b4 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -265,9 +265,6 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 	u32 offset = 0;
 	int status;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return status;
 	switch (type) {
 	case MAC_ADDR_TYPE_MULTI_MAC:
 	case MAC_ADDR_TYPE_CAM_MAC:
@@ -326,7 +323,6 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 		status = -EPERM;
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	return status;
 }
 
@@ -339,9 +335,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 	u32 offset = 0;
 	int status = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return status;
 	switch (type) {
 	case MAC_ADDR_TYPE_MULTI_MAC:
 	case MAC_ADDR_TYPE_CAM_MAC:
@@ -433,7 +426,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 		status = -EPERM;
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	return status;
 }
 
@@ -444,10 +436,6 @@ int ql_get_routing_reg(struct ql_adapter *qdev, u32 index, u32 *value)
 {
 	int status = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
-	if (status)
-		goto exit;
-
 	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MW, 0);
 	if (status)
 		goto exit;
@@ -459,7 +447,6 @@ int ql_get_routing_reg(struct ql_adapter *qdev, u32 index, u32 *value)
 		goto exit;
 	*value = ql_read32(qdev, RT_DATA);
 exit:
-	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
 }
 
@@ -474,10 +461,6 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 	int status;
 	u32 value = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
-	if (status)
-		return status;
-
 	QPRINTK(qdev, IFUP, DEBUG,
 		"%s %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s mask %s the routing reg.\n",
 		(enable ? "Adding" : "Removing"),
@@ -573,7 +556,6 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 		ql_write32(qdev, RT_DATA, enable ? mask : 0);
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 	return status;
 }
 
@@ -1730,19 +1712,29 @@ static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = MAC_ADDR_E;
+	int status;
 
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return;
 	spin_lock(&qdev->hw_lock);
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to init vlan address.\n");
 	}
 	spin_unlock(&qdev->hw_lock);
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
 static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = 0;
+	int status;
+
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return;
 
 	spin_lock(&qdev->hw_lock);
 	if (ql_set_mac_addr_reg
@@ -1750,6 +1742,7 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 		QPRINTK(qdev, IFUP, ERR, "Failed to clear vlan address.\n");
 	}
 	spin_unlock(&qdev->hw_lock);
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 
 }
 
@@ -2951,13 +2944,17 @@ static int ql_route_initialize(struct ql_adapter *qdev)
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
 
@@ -2965,13 +2962,13 @@ static int ql_route_initialize(struct ql_adapter *qdev)
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
@@ -2982,17 +2979,17 @@ static int ql_route_initialize(struct ql_adapter *qdev)
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
 
@@ -3000,8 +2997,12 @@ static int ql_cam_route_initialize(struct ql_adapter *qdev)
 {
 	int status;
 
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return status;
 	status = ql_set_mac_addr_reg(qdev, (u8 *) qdev->ndev->perm_addr,
 			     MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to init mac address.\n");
 		return status;
@@ -3444,8 +3445,11 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct dev_mc_list *mc_ptr;
-	int i;
+	int i, status;
 
+	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (status)
+		return;
 	spin_lock(&qdev->hw_lock);
 	/*
 	 * Set or clear promiscuous mode if a
@@ -3501,14 +3505,21 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 	}
 
 	if (ndev->mc_count) {
+		status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+		if (status)
+			goto exit;
 		for (i = 0, mc_ptr = ndev->mc_list; mc_ptr;
-		     i++, mc_ptr = mc_ptr->next)
-			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
-						MAC_ADDR_TYPE_MULTI_MAC, i)) {
+		     i++, mc_ptr = mc_ptr->next) {
+			status = ql_set_mac_addr_reg(qdev,
+					(u8 *) mc_ptr->dmi_addr,
+					MAC_ADDR_TYPE_MULTI_MAC, i);
+			if (status) {
 				QPRINTK(qdev, HW, ERR,
 					"Failed to loadmulticast address.\n");
+				ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 				goto exit;
 			}
+		}
 		if (ql_set_routing_reg
 		    (qdev, RT_IDX_MCAST_MATCH_SLOT, RT_IDX_MCAST_MATCH, 1)) {
 			QPRINTK(qdev, HW, ERR,
@@ -3516,9 +3527,11 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		} else {
 			set_bit(QL_ALLMULTI, &qdev->flags);
 		}
+		ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	}
 exit:
 	spin_unlock(&qdev->hw_lock);
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
 static int qlge_set_mac_address(struct net_device *ndev, void *p)
-- 
1.6.0.2

