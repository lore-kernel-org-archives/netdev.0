From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 7/8] qlge: Add/use function for link up/down.
Date: Thu,  2 Jul 2009 09:06:12 -0700
Message-ID: <1246550773-18417-7-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbZGBQLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:34 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to set/clear the mac address register when the link goes up/down
respectively.  Without this both ports of a 2-port device can end up
with the same mac address in a bonding scenario.
The new ql_link_on() and ql_link_off() will also be used in handling
certain firmware events.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 ++
 drivers/net/qlge/qlge_main.c |   26 +++++++++++++++++++++-----
 drivers/net/qlge/qlge_mpi.c  |    6 +++---
 3 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 156e02e..6ed5317 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1607,6 +1607,8 @@ int ql_mb_get_fw_state(struct ql_adapter *qdev);
 int ql_cam_route_initialize(struct ql_adapter *qdev);
 int ql_read_mpi_reg(struct ql_adapter *qdev, u32 reg, u32 *data);
 int ql_mb_about_fw(struct ql_adapter *qdev);
+void ql_link_on(struct ql_adapter *qdev);
+void ql_link_off(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 46dea2b..35ba95a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -448,6 +448,22 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 	return status;
 }
 
+void ql_link_on(struct ql_adapter *qdev)
+{
+	QPRINTK(qdev, LINK, ERR, "%s: Link is up.\n",
+				 qdev->ndev->name);
+	netif_carrier_on(qdev->ndev);
+	ql_set_mac_addr(qdev, 1);
+}
+
+void ql_link_off(struct ql_adapter *qdev)
+{
+	QPRINTK(qdev, LINK, ERR, "%s: Link is down.\n",
+				 qdev->ndev->name);
+	netif_carrier_off(qdev->ndev);
+	ql_set_mac_addr(qdev, 0);
+}
+
 /* Get a specific frame routing value from the CAM.
  * Used for debug and reg dump.
  */
@@ -1696,13 +1712,13 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 /* Fire up a handler to reset the MPI processor. */
 void ql_queue_fw_error(struct ql_adapter *qdev)
 {
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 	queue_delayed_work(qdev->workqueue, &qdev->mpi_reset_work, 0);
 }
 
 void ql_queue_asic_error(struct ql_adapter *qdev)
 {
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 	ql_disable_interrupts(qdev);
 	/* Clear adapter up bit to signal the recovery
 	 * process that it shouldn't kill the reset worker
@@ -3312,7 +3328,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	int i, status = 0;
 	struct rx_ring *rx_ring;
 
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 
 	/* Don't kill the reset worker thread if we
 	 * are in the process of recovery.
@@ -3384,7 +3400,7 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	 */
 	if ((ql_read32(qdev, STS) & qdev->port_init) &&
 			(ql_read32(qdev, STS) & qdev->port_link_up))
-		netif_carrier_on(qdev->ndev);
+		ql_link_on(qdev);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
 	netif_tx_start_all_queues(qdev->ndev);
@@ -4035,7 +4051,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 		pci_disable_device(pdev);
 		return err;
 	}
-	netif_carrier_off(ndev);
+	ql_link_off(qdev);
 	ql_display_dev_info(ndev);
 	cards_found++;
 	return 0;
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 71afbf8..6685bd9 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -238,7 +238,7 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 				&qdev->mpi_port_cfg_work, 0);
 	}
 
-	netif_carrier_on(qdev->ndev);
+	ql_link_on(qdev);
 }
 
 static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
@@ -251,7 +251,7 @@ static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	if (status)
 		QPRINTK(qdev, DRV, ERR, "Link down AEN broken!\n");
 
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 }
 
 static int ql_sfp_in(struct ql_adapter *qdev, struct mbox_params *mbcp)
@@ -849,7 +849,7 @@ void ql_mpi_idc_work(struct work_struct *work)
 	case MB_CMD_PORT_RESET:
 	case MB_CMD_SET_PORT_CFG:
 	case MB_CMD_STOP_FW:
-		netif_carrier_off(qdev->ndev);
+		ql_link_off(qdev);
 		/* Signal the resulting link up AEN
 		 * that the frame routing and mac addr
 		 * needs to be set.
-- 
1.6.0.2

