From: Dmitriy Monakhov <dmonakhov@openvz.org>
Subject: [PATCH] Broadcom 4400 resume small fix (v2)
Date: Wed, 10 Jan 2007 20:13:37 +0300
Message-ID: <87bql6ztxa.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Gary Zambrano <zambrano@broadcom.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:3489 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964969AbXAJRNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 12:13:46 -0500
To: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

Changes from v1:
- Fix according to Francois Romieu comments.

LOG:
Some issues in b44_resume().
- Return value of pci_enable_device() was ignored.
- If request_irq() has failed we have to just disable device and exit.

Signed-off-by: Dmitriy Monakhov <dmonakhov@openvz.org>
-------

--=-=-=
Content-Disposition: inline; filename=diff-ms-net-b44-resume-fix

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 5eb2ec6..42c57bf 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2315,16 +2315,27 @@ static int b44_resume(struct pci_dev *pd
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct b44 *bp = netdev_priv(dev);
+	int rc = 0;
 
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		printk(KERN_ERR PFX "%s: pci_enable_device failed\n",
+			dev->name);
+		return rc;
+	}
+
 	pci_set_master(pdev);
 
 	if (!netif_running(dev))
 		return 0;
 
-	if (request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev))
+	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc) {
 		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
+		pci_disable_device(pdev);
+		return rc;
+	}
 
 	spin_lock_irq(&bp->lock);
 

--=-=-=--

