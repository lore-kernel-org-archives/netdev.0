From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2] tg3: move init/deinit from open/close to probe/remove
Date: Thu,  8 Jan 2015 16:13:07 +0100
Message-ID: <1420729987-18476-1-git-send-email-ivecera@redhat.com>
Cc: prashant@broadcom.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218AbbAHPNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 10:13:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move init and deinit of PTP support from open/close functions
to probe/remove funcs to avoid removing/re-adding of associated PTP
device(s) during ifup/ifdown.

v2: tg3_ptp_init call moved to correct place (thx. Prashant)

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 553dcd8..356bd5b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11556,11 +11556,7 @@ static int tg3_start(struct tg3 *tp, bool reset_phy, bool test_irq,
 	tg3_flag_set(tp, INIT_COMPLETE);
 	tg3_enable_ints(tp);
 
-	if (init)
-		tg3_ptp_init(tp);
-	else
-		tg3_ptp_resume(tp);
-
+	tg3_ptp_resume(tp);
 
 	tg3_full_unlock(tp);
 
@@ -11681,13 +11677,6 @@ static int tg3_open(struct net_device *dev)
 		pci_set_power_state(tp->pdev, PCI_D3hot);
 	}
 
-	if (tg3_flag(tp, PTP_CAPABLE)) {
-		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
-						   &tp->pdev->dev);
-		if (IS_ERR(tp->ptp_clock))
-			tp->ptp_clock = NULL;
-	}
-
 	return err;
 }
 
@@ -11701,8 +11690,6 @@ static int tg3_close(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	tg3_ptp_fini(tp);
-
 	tg3_stop(tp);
 
 	/* Clear stats across close / open calls */
@@ -17880,6 +17867,14 @@ static int tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
+	if (tg3_flag(tp, PTP_CAPABLE)) {
+		tg3_ptp_init(tp);
+		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
+						   &tp->pdev->dev);
+		if (IS_ERR(tp->ptp_clock))
+			tp->ptp_clock = NULL;
+	}
+
 	netdev_info(dev, "Tigon3 [partno(%s) rev %04x] (%s) MAC address %pM\n",
 		    tp->board_part_number,
 		    tg3_chip_rev_id(tp),
@@ -17955,6 +17950,8 @@ static void tg3_remove_one(struct pci_dev *pdev)
 	if (dev) {
 		struct tg3 *tp = netdev_priv(dev);
 
+		tg3_ptp_fini(tp);
+
 		release_firmware(tp->fw);
 
 		tg3_reset_task_cancel(tp);
-- 
2.0.5
