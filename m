From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 11/21] [next] qlge: Cleanup spin lock usage for some register accesses.
Date: Fri, 23 Jan 2009 07:16:29 -0800
Message-ID: <1232723799-8620-11-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbZAWPSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:01 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 55c0f91..176d7e2 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -604,7 +604,6 @@ u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 {
 	u32 var = 0;
-	unsigned long hw_flags;
 	struct intr_context *ctx;
 
 	/* HW disables for us if we're MSIX multi interrupts and
@@ -614,14 +613,14 @@ static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 		return 0;
 
 	ctx = qdev->intr_context + intr;
-	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	spin_lock(&qdev->hw_lock);
 	if (!atomic_read(&ctx->irq_cnt)) {
 		ql_write32(qdev, INTR_EN,
 		ctx->intr_dis_mask);
 		var = ql_read32(qdev, STS);
 	}
 	atomic_inc(&ctx->irq_cnt);
-	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+	spin_unlock(&qdev->hw_lock);
 	return var;
 }
 
@@ -1714,16 +1713,17 @@ static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = MAC_ADDR_E;
 	int status;
+	unsigned long hw_flags = 0;
 
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
 		return;
-	spin_lock(&qdev->hw_lock);
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to init vlan address.\n");
 	}
-	spin_unlock(&qdev->hw_lock);
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
@@ -1731,18 +1731,19 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = 0;
+	unsigned long hw_flags = 0;
 	int status;
 
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
 		return;
 
-	spin_lock(&qdev->hw_lock);
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to clear vlan address.\n");
 	}
-	spin_unlock(&qdev->hw_lock);
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 
 }
@@ -3383,12 +3384,13 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct dev_mc_list *mc_ptr;
+	unsigned long hw_flags = 0;
 	int i, status;
 
 	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
 	if (status)
 		return;
-	spin_lock(&qdev->hw_lock);
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 	/*
 	 * Set or clear promiscuous mode if a
 	 * transition is taking place.
@@ -3468,7 +3470,7 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 	}
 exit:
-	spin_unlock(&qdev->hw_lock);
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
@@ -3476,7 +3478,8 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct sockaddr *addr = p;
-	int ret = 0;
+	unsigned long hw_flags = 0;
+	int status;
 
 	if (netif_running(ndev))
 		return -EBUSY;
@@ -3484,16 +3487,14 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
-
-	spin_lock(&qdev->hw_lock);
-	if (ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
-			MAC_ADDR_TYPE_CAM_MAC, qdev->func)) {/* Unicast */
+	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
+	status = ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
+			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
+	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+	if (status)
 		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
-		ret = -1;
-	}
-	spin_unlock(&qdev->hw_lock);
 
-	return ret;
+	return status;
 }
 
 static void qlge_tx_timeout(struct net_device *ndev)
-- 
1.6.0.2

