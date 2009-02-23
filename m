From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] [net-next] qlge: Increase MAC addr hw sem granularity.
Date: Mon, 23 Feb 2009 12:42:14 -0800
Message-ID: <1235421737-32296-2-git-send-email-ron.mercer@qlogic.com>
References: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:3006 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbZBWUpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 15:45:39 -0500
In-Reply-To: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of taking/giving the semaphore repeatedly when iterating over
several adderesses, we have the caller hold it until all are done.  This
reduces PCI bus chatter and possible waits.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_dbg.c  |    9 +++++++
 drivers/net/qlge/qlge_main.c |   51 ++++++++++++++++++++++++++++--------------
 2 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 379b895..40a70c3 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -83,6 +83,10 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 {
 	int i;
 	u32 value[3];
+
+	i = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (i)
+		return;
 	for (i = 0; i < 4; i++) {
 		if (ql_get_mac_addr_reg(qdev, MAC_ADDR_TYPE_CAM_MAC, i, value)) {
 			printk(KERN_ERR PFX
@@ -111,12 +115,16 @@ static void ql_dump_cam_entries(struct ql_adapter *qdev)
 				       qdev->ndev->name, i, value[1], value[0]);
 		}
 	}
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
 void ql_dump_routing_entries(struct ql_adapter *qdev)
 {
 	int i;
 	u32 value;
+	i = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (i)
+		return;
 	for (i = 0; i < 16; i++) {
 		value = 0;
 		if (ql_get_routing_reg(qdev, i, &value)) {
@@ -131,6 +139,7 @@ void ql_dump_routing_entries(struct ql_adapter *qdev)
 				       qdev->ndev->name, i, value);
 		}
 	}
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
 void ql_dump_regs(struct ql_adapter *qdev)
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3a041b6..d316e50 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -247,9 +247,6 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 	u32 offset = 0;
 	int status;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return status;
 	switch (type) {
 	case MAC_ADDR_TYPE_MULTI_MAC:
 	case MAC_ADDR_TYPE_CAM_MAC:
@@ -308,7 +305,6 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 		status = -EPERM;
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	return status;
 }
 
@@ -321,9 +317,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 	u32 offset = 0;
 	int status = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return status;
 	switch (type) {
 	case MAC_ADDR_TYPE_MULTI_MAC:
 	case MAC_ADDR_TYPE_CAM_MAC:
@@ -415,7 +408,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 		status = -EPERM;
 	}
 exit:
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	return status;
 }
 
@@ -1690,19 +1682,29 @@ static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
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
@@ -1710,6 +1712,7 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 		QPRINTK(qdev, IFUP, ERR, "Failed to clear vlan address.\n");
 	}
 	spin_unlock(&qdev->hw_lock);
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 
 }
 
@@ -2962,8 +2965,12 @@ static int ql_cam_route_initialize(struct ql_adapter *qdev)
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
@@ -3428,8 +3435,11 @@ static void qlge_set_multicast_list(struct net_device *ndev)
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
@@ -3485,14 +3495,19 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 	}
 
 	if (ndev->mc_count) {
+		status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+		if (status)
+			goto exit;
 		for (i = 0, mc_ptr = ndev->mc_list; mc_ptr;
 		     i++, mc_ptr = mc_ptr->next)
 			if (ql_set_mac_addr_reg(qdev, (u8 *) mc_ptr->dmi_addr,
 						MAC_ADDR_TYPE_MULTI_MAC, i)) {
 				QPRINTK(qdev, HW, ERR,
 					"Failed to loadmulticast address.\n");
+				ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 				goto exit;
 			}
+		ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 		if (ql_set_routing_reg
 		    (qdev, RT_IDX_MCAST_MATCH_SLOT, RT_IDX_MCAST_MATCH, 1)) {
 			QPRINTK(qdev, HW, ERR,
@@ -3509,7 +3524,7 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct sockaddr *addr = p;
-	int ret = 0;
+	int status;
 
 	if (netif_running(ndev))
 		return -EBUSY;
@@ -3518,15 +3533,17 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return status;
 	spin_lock(&qdev->hw_lock);
-	if (ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
-			MAC_ADDR_TYPE_CAM_MAC, qdev->func)) {/* Unicast */
-		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
-		ret = -1;
-	}
+	status = ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
+			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
 	spin_unlock(&qdev->hw_lock);
-
-	return ret;
+	if (status)
+		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
+	return status;
 }
 
 static void qlge_tx_timeout(struct net_device *ndev)
-- 
1.6.0.2

