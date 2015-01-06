From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] tg3: move init/deinit from open/close to probe/remove
Date: Tue,  6 Jan 2015 21:28:42 +0100
Message-ID: <1420576122-23618-1-git-send-email-ivecera@redhat.com>
Cc: prashant@broadcom.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932434AbbAFU2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 15:28:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move init and deinit of PTP support from open/close functions
to probe/remove funcs to avoid removing/re-adding of associated PTP
device(s) during ifup/ifdown.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 553dcd8..e86bee4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11681,13 +11681,6 @@ static int tg3_open(struct net_device *dev)
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
 
@@ -11701,8 +11694,6 @@ static int tg3_close(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	tg3_ptp_fini(tp);
-
 	tg3_stop(tp);
 
 	/* Clear stats across close / open calls */
@@ -17880,6 +17871,13 @@ static int tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
+	if (tg3_flag(tp, PTP_CAPABLE)) {
+		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
+						   &tp->pdev->dev);
+		if (IS_ERR(tp->ptp_clock))
+			tp->ptp_clock = NULL;
+	}
+
 	netdev_info(dev, "Tigon3 [partno(%s) rev %04x] (%s) MAC address %pM\n",
 		    tp->board_part_number,
 		    tg3_chip_rev_id(tp),
@@ -17955,6 +17953,8 @@ static void tg3_remove_one(struct pci_dev *pdev)
 	if (dev) {
 		struct tg3 *tp = netdev_priv(dev);
 
+		tg3_ptp_fini(tp);
+
 		release_firmware(tp->fw);
 
 		tg3_reset_task_cancel(tp);
-- 
2.0.5
