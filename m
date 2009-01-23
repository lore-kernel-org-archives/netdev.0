From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 02/21] [next] qlge: Add new functions for signaling link up/down.
Date: Fri, 23 Jan 2009 07:16:20 -0800
Message-ID: <1232723799-8620-2-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbZAWPRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:44 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Centralize this call as it will also be used by firmware events.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   38 ++++++++++++++++++++++++--------------
 1 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index a530f5b..e6f9146 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -240,6 +240,24 @@ exit:
 	return status;
 }
 
+static void ql_link_on(struct ql_adapter *qdev)
+{
+	if (!netif_carrier_ok(qdev->ndev)) {
+		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
+		netif_carrier_on(qdev->ndev);
+		netif_wake_queue(qdev->ndev);
+	}
+}
+
+static void ql_link_off(struct ql_adapter *qdev)
+{
+	if (netif_carrier_ok(qdev->ndev)) {
+		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
+		netif_carrier_off(qdev->ndev);
+		netif_stop_queue(qdev->ndev);
+	}
+}
+
 /* Get a specific MAC address from the CAM.  Used for debug and reg dump. */
 int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 			u32 *value)
@@ -1524,15 +1542,13 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 /* Fire up a handler to reset the MPI processor. */
 void ql_queue_fw_error(struct ql_adapter *qdev)
 {
-	netif_stop_queue(qdev->ndev);
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 	queue_delayed_work(qdev->workqueue, &qdev->mpi_reset_work, 0);
 }
 
 void ql_queue_asic_error(struct ql_adapter *qdev)
 {
-	netif_stop_queue(qdev->ndev);
-	netif_carrier_off(qdev->ndev);
+	ql_link_off(qdev);
 	ql_disable_interrupts(qdev);
 	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
 }
@@ -3116,12 +3132,10 @@ static void ql_display_dev_info(struct net_device *ndev)
 
 static int ql_adapter_down(struct ql_adapter *qdev)
 {
-	struct net_device *ndev = qdev->ndev;
 	int i, status = 0;
 	struct rx_ring *rx_ring;
 
-	netif_stop_queue(ndev);
-	netif_carrier_off(ndev);
+	ql_link_off(qdev);
 
 	cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
@@ -3179,11 +3193,8 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
-	if ((ql_read32(qdev, STS) & qdev->port_init)) {
-		netif_carrier_on(qdev->ndev);
-		netif_start_queue(qdev->ndev);
-	}
-
+	if ((ql_read32(qdev, STS) & qdev->port_init))
+		ql_link_on(qdev);
 	return 0;
 err_init:
 	ql_adapter_reset(qdev);
@@ -3816,8 +3827,7 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 
-	netif_carrier_off(ndev);
-	netif_stop_queue(ndev);
+	ql_link_off(qdev);
 	ql_adapter_reset(qdev);
 
 	/* Make sure the EEPROM is good */
-- 
1.6.0.2

