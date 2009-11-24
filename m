From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] r8169: restore mac addr in rtl8169_remove_one and rtl_shutdown
Date: Tue, 24 Nov 2009 19:26:06 +0100
Message-ID: <1259087166-14558-1-git-send-email-ivecera@redhat.com>
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245AbZKXS0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 13:26:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newer chipsets (all PCI-E) are known that they need full power cycle
(AC or battery removal) to reset MAC address to a  hardwired one. Previous
patch to address this problem loads the original MAC address from EEPROM.
But it brought other problem for which it is necessary to introduce a new
module parameter.
However, it might suffice to restore the initial MAC address before
shutdown/reboot/kexec and when removing the module.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/r8169.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b9221bd..0fe2fc9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3235,6 +3235,10 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	flush_scheduled_work();
 
 	unregister_netdev(dev);
+
+	/* restore original MAC address */
+	rtl_rar_set(tp, dev->perm_addr);
+
 	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
@@ -4881,6 +4885,9 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	rtl8169_net_suspend(dev);
 
+	/* restore original MAC address */
+	rtl_rar_set(tp, dev->perm_addr);
+
 	spin_lock_irq(&tp->lock);
 
 	rtl8169_asic_down(ioaddr);
-- 
1.6.4.4

