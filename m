From: Grant Grundler <grundler@parisc-linux.org>
Subject: PATCH for [Bug 8952] tulip driver oops in tulip_interrupt when
	hibernating with swsusp/suspend2
Date: Mon, 12 May 2008 00:37:51 -0600
Message-ID: <20080512063751.GH32317@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:45438 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbYELGiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 02:38:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
The following patch is seems to fix the tulip suspend/resume panic:
	http://bugzilla.kernel.org/show_bug.cgi?id=8952#c46

My attempts at a cleaner patch failed and Pavel thinks this is OK.
Since suspend/resume is getting an overhaul in 2.6.27 (per comment
#49 by  Rafael J. Wysocki), it makes sense to invest more time as
part of that rework and apply the known fix to 2.6.26.

hth,
grant

Original from:  kernelbugs@tap.homeip.net
Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f9d13fa..088d3bf 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1729,12 +1729,15 @@ static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 	if (!dev)
 		return -EINVAL;
 
-	if (netif_running(dev))
-		tulip_down(dev);
+	if (!netif_running(dev))
+		goto save_state:
+
+	tulip_down(dev);
 
 	netif_device_detach(dev);
 	free_irq(dev->irq, dev);
 
+save_state:
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -1754,6 +1757,9 @@ static int tulip_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
+	if (!netif_running(dev))
+		return 0;
+
 	if ((retval = pci_enable_device(pdev))) {
 		printk (KERN_ERR "tulip: pci_enable_device failed in resume\n");
 		return retval;
