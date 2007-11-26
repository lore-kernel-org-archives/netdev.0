From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/1][ATM]: [he] initialize lock and tasklet earlier
Date: Mon, 26 Nov 2007 11:33:31 -0500
Message-ID: <200711261633.lAQGXWvr027742@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:61385 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbXKZQeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 11:34:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if you are lucky (unlucky?) enough to have shared interrupts, the
interrupt handler can be called before the tasklet and lock are ready
for use.

commit 44b3e82778b0edf73147529c8b1c115d241a6a4d
Author: chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil>
Date:   Mon Nov 26 11:30:33 2007 -0500

    [ATM]: [he] initialize lock and tasklet earlier

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d33aba6..3b64a99 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -394,6 +394,11 @@ he_init_one(struct pci_dev *pci_dev, const struct pci_device_id *pci_ent)
 	he_dev->atm_dev->dev_data = he_dev;
 	atm_dev->dev_data = he_dev;
 	he_dev->number = atm_dev->number;
+#ifdef USE_TASKLET
+	tasklet_init(&he_dev->tasklet, he_tasklet, (unsigned long) he_dev);
+#endif
+	spin_lock_init(&he_dev->global_lock);
+
 	if (he_start(atm_dev)) {
 		he_stop(he_dev);
 		err = -ENODEV;
@@ -1173,11 +1178,6 @@ he_start(struct atm_dev *dev)
 	if ((err = he_init_irq(he_dev)) != 0)
 		return err;
 
-#ifdef USE_TASKLET
-	tasklet_init(&he_dev->tasklet, he_tasklet, (unsigned long) he_dev);
-#endif
-	spin_lock_init(&he_dev->global_lock);
-
 	/* 4.11 enable pci bus controller state machines */
 	host_cntl |= (OUTFF_ENB | CMDFF_ENB |
 				QUICK_RD_RETRY | QUICK_WR_RETRY | PERR_INT_ENB);
