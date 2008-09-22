From: akpm@linux-foundation.org
Subject: [patch 09/21] forcedeth: add pci_enable_device() to nv_resume()
Date: Mon, 22 Sep 2008 14:52:15 -0700
Message-ID: <200809222152.m8MLqGSx031961@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	simon@fire.lp0.eu, aabdulla@nvidia.com, jgarzik@redhat.com,
	ranma+kernel@tdiedrich.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56311 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754277AbYIVV7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Arlott <simon@fire.lp0.eu>

My NIC stops working after resuming from standby, it's not receiving any
interrupts.

Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth:
reorder suspend/resume code) introduces pci_disable_device to nv_suspend,
but there's no corresponding pci_enable_device in nv_resume - so I added
one (copied from e1000).  This results in interrupts being re-enabled
after suspend.

However, the NIC (10de:0373) still doesn't work after resume.

Cc: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Cc: Jeff Garzik <jgarzik@redhat.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff -puN drivers/net/forcedeth.c~forcedeth-add-pci_enable_device-to-nv_resume drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-add-pci_enable_device-to-nv_resume
+++ a/drivers/net/forcedeth.c
@@ -5968,6 +5968,13 @@ static int nv_resume(struct pci_dev *pde
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		printk(KERN_ERR "forcedeth: Cannot enable PCI device from suspend\n");
+		return rc;
+	}
+	pci_set_master(pdev);
+
 	/* ack any pending wake events, disable PME */
 	pci_enable_wake(pdev, PCI_D0, 0);
 
_
