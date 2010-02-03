From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Add check for eeh failure when closing device.
Date: Wed,  3 Feb 2010 09:24:12 -0800
Message-ID: <1265217853-26959-3-git-send-email-ron.mercer@qlogic.com>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:1451 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932719Ab0BCRbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 12:31:09 -0500
In-Reply-To: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix crash where resources are freed twice on an eeh recovery failure.
If eeh recovery fails we set a flag to indicate to close() that
resources have been freed.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 9169c4c..780a387 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -2005,6 +2005,7 @@ enum {
 	QL_SELFTEST = 9,
 	QL_LB_LINK_UP = 10,
 	QL_FRC_COREDUMP = 11,
+	QL_EEH_FATAL = 12,
 };
 
 /* link_status bit definitions */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 87ec720..7e00029 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3929,6 +3929,16 @@ static int qlge_close(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	/* If we hit pci_channel_io_perm_failure
+	 * failure condition, then we already
+	 * brought the adapter down.
+	 */
+	if (test_bit(QL_EEH_FATAL, &qdev->flags)) {
+		QPRINTK(qdev, DRV, ERR, "EEH fatal did unload.\n");
+		clear_bit(QL_EEH_FATAL, &qdev->flags);
+		return 0;
+	}
+
 	/*
 	 * Wait for device to recover from a reset.
 	 * (Rarely happens, but possible.)
@@ -4677,6 +4687,7 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 					       enum pci_channel_state state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
+	struct ql_adapter *qdev = netdev_priv(ndev);
 
 	switch (state) {
 	case pci_channel_io_normal:
@@ -4690,6 +4701,8 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 	case pci_channel_io_perm_failure:
 		dev_err(&pdev->dev,
 			"%s: pci_channel_io_perm_failure.\n", __func__);
+		ql_eeh_close(ndev);
+		set_bit(QL_EEH_FATAL, &qdev->flags);
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
@@ -4720,6 +4733,7 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 
 	if (ql_adapter_reset(qdev)) {
 		QPRINTK(qdev, DRV, ERR, "reset FAILED!\n");
+		set_bit(QL_EEH_FATAL, &qdev->flags);
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 
-- 
1.6.0.2

