From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/11] bnxt_en: Do function reset on the 1st PF open only.
Date: Fri,  1 Jul 2016 18:46:21 -0400
Message-ID: <1467413189-29566-4-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34169 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbcGAWqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:45 -0400
Received: by mail-pa0-f51.google.com with SMTP id bz2so42228769pad.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:45 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling the firmware to do function reset on the PF will kill all the VFs.
To prevent that, we call function reset on the 1st PF open before any VF
can be activated.  On subsequent PF opens (with possibly some active VFs),
a bit has been set and we'll skip the function reset.  VF driver will
always do function reset on every open.  If there is an AER event, we will
always do function reset.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 22 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 673f4d6..b489fb6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5295,12 +5295,19 @@ static int bnxt_open(struct net_device *dev)
 	struct bnxt *bp = netdev_priv(dev);
 	int rc = 0;
 
-	rc = bnxt_hwrm_func_reset(bp);
-	if (rc) {
-		netdev_err(bp->dev, "hwrm chip reset failure rc: %x\n",
-			   rc);
-		rc = -1;
-		return rc;
+	if (!test_bit(BNXT_STATE_FN_RST_DONE, &bp->state)) {
+		rc = bnxt_hwrm_func_reset(bp);
+		if (rc) {
+			netdev_err(bp->dev, "hwrm chip reset failure rc: %x\n",
+				   rc);
+			rc = -EBUSY;
+			return rc;
+		}
+		/* Do func_reset during the 1st PF open only to prevent killing
+		 * the VFs when the PF is brought down and up.
+		 */
+		if (BNXT_PF(bp))
+			set_bit(BNXT_STATE_FN_RST_DONE, &bp->state);
 	}
 	return __bnxt_open_nic(bp, true, true);
 }
@@ -6676,6 +6683,7 @@ static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
 					       pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct bnxt *bp = netdev_priv(netdev);
 
 	netdev_info(netdev, "PCI I/O error detected\n");
 
@@ -6690,6 +6698,8 @@ static pci_ers_result_t bnxt_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		bnxt_close(netdev);
 
+	/* So that func_reset will be done during slot_reset */
+	clear_bit(BNXT_STATE_FN_RST_DONE, &bp->state);
 	pci_disable_device(pdev);
 	rtnl_unlock();
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 084b3f2..1d5a3cd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1018,6 +1018,7 @@ struct bnxt {
 	unsigned long		state;
 #define BNXT_STATE_OPEN		0
 #define BNXT_STATE_IN_SP_TASK	1
+#define BNXT_STATE_FN_RST_DONE	2
 
 	struct bnxt_irq	*irq_tbl;
 	u8			mac_addr[ETH_ALEN];
-- 
1.8.3.1
