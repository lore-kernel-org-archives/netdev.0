From: Dongdong Deng <dongdong.deng@windriver.com>
Subject: [PATCH] e1000e: add netpoll support for MSI/MSI-X IRQ modes
Date: Tue, 26 Oct 2010 13:54:36 +0800
Message-ID: <1288072476-20720-1-git-send-email-dongdong.deng@windriver.com>
Cc: alexander.h.duyck@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	dongdong.deng@windriver.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: davem@davemloft.net, jesse@nicira.com, jeffrey.t.kirsher@intel.com,
	bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42142 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab0JZFsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 01:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With enabling CONFIG_PCI_MSI, e1000e could work in MSI/MSI-X IRQ mode,
and netpoll controller didn't deal with those IRQ modes on e1000e.

This patch add the handling MSI/MSI-X IRQ modes to netpoll controller,
so that netconsole could work with those IRQ modes.

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
---
 drivers/net/e1000e/netdev.c |   49 +++++++++++++++++++++++++++++++++++++++---
 1 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e561d15..36992ba 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5369,6 +5369,36 @@ static void e1000_shutdown(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
+
+static irqreturn_t e1000_intr_msix(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int vector, msix_irq;
+
+	if (adapter->msix_entries) {
+		vector = 0;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_intr_msix_rx(msix_irq, netdev);
+		enable_irq(msix_irq);
+
+		vector++;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_intr_msix_tx(msix_irq, netdev);
+		enable_irq(msix_irq);
+
+		vector++;
+		msix_irq = adapter->msix_entries[vector].vector;
+		disable_irq(msix_irq);
+		e1000_msix_other(msix_irq, netdev);
+		enable_irq(msix_irq);
+	}
+
+	return IRQ_HANDLED;
+}
+
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
  * without having to re-enable interrupts. It's not called while
@@ -5378,10 +5408,21 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
-	e1000_intr(adapter->pdev->irq, netdev);
-
-	enable_irq(adapter->pdev->irq);
+	switch (adapter->int_mode) {
+	case E1000E_INT_MODE_MSIX:
+		e1000_intr_msix(adapter->pdev->irq, netdev);
+		break;
+	case E1000E_INT_MODE_MSI:
+		disable_irq(adapter->pdev->irq);
+		e1000_intr_msi(adapter->pdev->irq, netdev);
+		enable_irq(adapter->pdev->irq);
+		break;
+	default: /* E1000E_INT_MODE_LEGACY */
+		disable_irq(adapter->pdev->irq);
+		e1000_intr(adapter->pdev->irq, netdev);
+		enable_irq(adapter->pdev->irq);
+		break;
+	}
 }
 #endif
 
-- 
1.6.0.4

