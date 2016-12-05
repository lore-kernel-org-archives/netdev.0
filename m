From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH 03/28] bnxt_en: Move function reset to bnxt_init_one().
Date: Sun,  4 Dec 2016 22:38:07 -0800
Message-ID: <1480919912-1079-4-git-send-email-selvin.xavier@broadcom.com>
References: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
Cc: linux-rdma@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Selvin Xavier <selvin.xavier@broadcom.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:33868 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbcLEGpp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 01:45:45 -0500
In-Reply-To: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>

Now that MSIX is enabled in bnxt_init_one(), resources may be allocated by
the RDMA driver before the network device is opened.  So we cannot do
function reset in bnxt_open() which will clear all the resources.

The proper place to do function reset now is in bnxt_init_one().
If we get AER, we'll do function reset as well.

Cc: David Miller <davem@davemloft.net>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 25 ++++++-------------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 -
 2 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9178bf8..8b00ef4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5613,22 +5613,7 @@ int bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 static int bnxt_open(struct net_device *dev)
 {
 	struct bnxt *bp = netdev_priv(dev);
-	int rc = 0;
 
-	if (!test_bit(BNXT_STATE_FN_RST_DONE, &bp->state)) {
-		rc = bnxt_hwrm_func_reset(bp);
-		if (rc) {
-			netdev_err(bp->dev, "hwrm chip reset failure rc: %x\n",
-				   rc);
-			rc = -EBUSY;
-			return rc;
-		}
-		/* Do func_reset during the 1st PF open only to prevent killing
-		 * the VFs when the PF is brought down and up.
-		 */
-		if (BNXT_PF(bp))
-			set_bit(BNXT_STATE_FN_RST_DONE, &bp->state);
-	}
 	return __bnxt_open_nic(bp, true, true);
 }
 
@@ -7028,6 +7013,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
+	rc = bnxt_hwrm_func_reset(bp);
+	if (rc)
+		goto init_err;
+
 	rc = bnxt_init_int_mode(bp);
 	if (rc)
 		goto init_err;
@@ -7069,7 +7058,6 @@ static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
 					       pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct bnxt *bp = netdev_priv(netdev);
 
 	netdev_info(netdev, "PCI I/O error detected\n");
 
@@ -7084,8 +7072,6 @@ static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		bnxt_close(netdev);
 
-	/* So that func_reset will be done during slot_reset */
-	clear_bit(BNXT_STATE_FN_RST_DONE, &bp->state);
 	pci_disable_device(pdev);
 	rtnl_unlock();
 
@@ -7119,7 +7105,8 @@ static pci_ers_result_t bnxt_io_slot_reset(struct pci_dev *pdev)
 	} else {
 		pci_set_master(pdev);
 
-		if (netif_running(netdev))
+		err = bnxt_hwrm_func_reset(bp);
+		if (!err && netif_running(netdev))
 			err = bnxt_open(netdev);
 
 		if (!err)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 1461355..0ee2cc4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1021,7 +1021,6 @@ struct bnxt {
 	unsigned long		state;
 #define BNXT_STATE_OPEN		0
 #define BNXT_STATE_IN_SP_TASK	1
-#define BNXT_STATE_FN_RST_DONE	2
 
 	struct bnxt_irq	*irq_tbl;
 	int			total_irqs;
-- 
2.5.5
