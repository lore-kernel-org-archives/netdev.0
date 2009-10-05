From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/3] qlge: Fix lock/mutex warnings.
Date: Mon,  5 Oct 2009 14:46:49 -0700
Message-ID: <1254779209-15174-4-git-send-email-ron.mercer@qlogic.com>
References: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:7750 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836AbZJEVyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 17:54:06 -0400
In-Reply-To: <1254779209-15174-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of spinlock and private mutex usage for exclusive access to the
HW semaphore register.  rtnl_lock already creates exclusive access to
this register in all driver API.
Add rtnl to firmware worker threads that also use the HW semaphore register.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |    2 +-
 drivers/net/qlge/qlge_ethtool.c |    2 --
 drivers/net/qlge/qlge_main.c    |   10 ----------
 drivers/net/qlge/qlge_mpi.c     |   12 ++++++++----
 4 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index f470fb9..3ec6e85 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -9,6 +9,7 @@
 
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 
 /*
  * General definitions...
@@ -1477,7 +1478,6 @@ struct ql_adapter {
 	u32 mailbox_in;
 	u32 mailbox_out;
 	struct mbox_params idc_mbc;
-	struct mutex	mpi_mutex;
 
 	int tx_ring_size;
 	int rx_ring_size;
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 68f9bd2..5207394 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -45,7 +45,6 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 	if (!netif_running(qdev->ndev))
 		return status;
 
-	spin_lock(&qdev->hw_lock);
 	/* Skip the default queue, and update the outbound handler
 	 * queues if they changed.
 	 */
@@ -92,7 +91,6 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 		}
 	}
 exit:
-	spin_unlock(&qdev->hw_lock);
 	return status;
 }
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c21eda0..6168071 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -34,7 +34,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
@@ -1926,12 +1925,10 @@ static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
 		return;
-	spin_lock(&qdev->hw_lock);
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to init vlan address.\n");
 	}
-	spin_unlock(&qdev->hw_lock);
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
@@ -1945,12 +1942,10 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 	if (status)
 		return;
 
-	spin_lock(&qdev->hw_lock);
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		QPRINTK(qdev, IFUP, ERR, "Failed to clear vlan address.\n");
 	}
-	spin_unlock(&qdev->hw_lock);
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 
 }
@@ -3587,7 +3582,6 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
 	if (status)
 		return;
-	spin_lock(&qdev->hw_lock);
 	/*
 	 * Set or clear promiscuous mode if a
 	 * transition is taking place.
@@ -3664,7 +3658,6 @@ static void qlge_set_multicast_list(struct net_device *ndev)
 		}
 	}
 exit:
-	spin_unlock(&qdev->hw_lock);
 	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
 }
 
@@ -3684,10 +3677,8 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
 		return status;
-	spin_lock(&qdev->hw_lock);
 	status = ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
 			MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
-	spin_unlock(&qdev->hw_lock);
 	if (status)
 		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
@@ -3930,7 +3921,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	INIT_DELAYED_WORK(&qdev->mpi_work, ql_mpi_work);
 	INIT_DELAYED_WORK(&qdev->mpi_port_cfg_work, ql_mpi_port_cfg_work);
 	INIT_DELAYED_WORK(&qdev->mpi_idc_work, ql_mpi_idc_work);
-	mutex_init(&qdev->mpi_mutex);
 	init_completion(&qdev->ide_completion);
 
 	if (!cards_found) {
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 6685bd9..c2e4307 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -472,7 +472,6 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	int status, count;
 
-	mutex_lock(&qdev->mpi_mutex);
 
 	/* Begin polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16));
@@ -541,7 +540,6 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		status = -EIO;
 	}
 end:
-	mutex_unlock(&qdev->mpi_mutex);
 	/* End polled mode for MPI */
 	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
 	return status;
@@ -776,7 +774,9 @@ static int ql_idc_wait(struct ql_adapter *qdev)
 static int ql_set_port_cfg(struct ql_adapter *qdev)
 {
 	int status;
+	rtnl_lock();
 	status = ql_mb_set_port_cfg(qdev);
+	rtnl_unlock();
 	if (status)
 		return status;
 	status = ql_idc_wait(qdev);
@@ -797,7 +797,9 @@ void ql_mpi_port_cfg_work(struct work_struct *work)
 	    container_of(work, struct ql_adapter, mpi_port_cfg_work.work);
 	int status;
 
+	rtnl_lock();
 	status = ql_mb_get_port_cfg(qdev);
+	rtnl_unlock();
 	if (status) {
 		QPRINTK(qdev, DRV, ERR,
 			"Bug: Failed to get port config data.\n");
@@ -855,7 +857,9 @@ void ql_mpi_idc_work(struct work_struct *work)
 		 * needs to be set.
 		 * */
 		set_bit(QL_CAM_RT_SET, &qdev->flags);
+		rtnl_lock();
 		status = ql_mb_idc_ack(qdev);
+		rtnl_unlock();
 		if (status) {
 			QPRINTK(qdev, DRV, ERR,
 			"Bug: No pending IDC!\n");
@@ -871,7 +875,7 @@ void ql_mpi_work(struct work_struct *work)
 	struct mbox_params *mbcp = &mbc;
 	int err = 0;
 
-	mutex_lock(&qdev->mpi_mutex);
+	rtnl_lock();
 
 	while (ql_read32(qdev, STS) & STS_PI) {
 		memset(mbcp, 0, sizeof(struct mbox_params));
@@ -884,7 +888,7 @@ void ql_mpi_work(struct work_struct *work)
 			break;
 	}
 
-	mutex_unlock(&qdev->mpi_mutex);
+	rtnl_unlock();
 	ql_enable_completion_interrupt(qdev, 0);
 }
 
-- 
1.6.0.2

