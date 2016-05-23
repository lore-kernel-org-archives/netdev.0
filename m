From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH] net/qlge: Avoids recursive EEH error
Date: Mon, 23 May 2016 11:58:28 +1000
Message-ID: <1463968708-28368-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	davem@davemloft.net, shriyakul@in.ibm.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:37459 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbcEWB7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 21:59:32 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 23 May 2016 11:59:29 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 5E6773578057
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 11:59:28 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u4N1xKLC45613084
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 11:59:28 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u4N1wtOY011838
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 11:58:56 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One timer, whose handler keeps reading on MMIO register for EEH
core to detect error in time, is started when the PCI device driver
is loaded. MMIO register can't be accessed during PE reset in EEH
recovery. Otherwise, the unexpected recursive error is triggered.
The timer isn't closed that time if the interface isn't brought
up. So the unexpected recursive error is seen during EEH recovery
when the interface is down.

This avoids the unexpected recursive EEH error by closing the timer
in qlge_io_error_detected() before EEH PE reset unconditionally. The
timer is started unconditionally after EEH PE reset in qlge_io_resume().
Also, the timer should be closed unconditionally when the device is
removed from the system permanently in qlge_io_error_detected().

Reported-by: Shriya R. Kulkarni <shriyakul@in.ibm.com>
Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 83d7210..fd5d1c9 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4846,7 +4846,6 @@ static void ql_eeh_close(struct net_device *ndev)
 	}
 
 	/* Disabling the timer */
-	del_timer_sync(&qdev->timer);
 	ql_cancel_all_work_sync(qdev);
 
 	for (i = 0; i < qdev->rss_ring_count; i++)
@@ -4873,6 +4872,7 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 		return PCI_ERS_RESULT_CAN_RECOVER;
 	case pci_channel_io_frozen:
 		netif_device_detach(ndev);
+		del_timer_sync(&qdev->timer);
 		if (netif_running(ndev))
 			ql_eeh_close(ndev);
 		pci_disable_device(pdev);
@@ -4880,6 +4880,7 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 	case pci_channel_io_perm_failure:
 		dev_err(&pdev->dev,
 			"%s: pci_channel_io_perm_failure.\n", __func__);
+		del_timer_sync(&qdev->timer);
 		ql_eeh_close(ndev);
 		set_bit(QL_EEH_FATAL, &qdev->flags);
 		return PCI_ERS_RESULT_DISCONNECT;
-- 
2.1.0
