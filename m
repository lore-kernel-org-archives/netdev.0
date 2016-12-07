From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 3/7] bnxt_en: Move function reset to bnxt_init_one().
Date: Wed,  7 Dec 2016 00:26:17 -0500
Message-ID: <1481088381-30411-4-git-send-email-michael.chan@broadcom.com>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33869 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752298AbcLGF04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:26:56 -0500
Received: by mail-pg0-f48.google.com with SMTP id x23so157759573pgx.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:26:56 -0800 (PST)
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that MSIX is enabled in bnxt_init_one(), resources may be allocated by
the RDMA driver before the network device is opened.  So we cannot do
function reset in bnxt_open() which will clear all the resources.

The proper place to do function reset now is in bnxt_init_one().
If we get AER, we'll do function reset as well.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 25 ++++++-------------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 -
 2 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index da302eb..30b482b 100644
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
1.8.3.1
