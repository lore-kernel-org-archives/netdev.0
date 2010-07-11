From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/5] cxgb4: move the choice of interrupt type before net_device registration
Date: Sun, 11 Jul 2010 15:01:15 -0700
Message-ID: <1278885679-3738-2-git-send-email-dm@chelsio.com>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15494 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192Ab0GKWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:01:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6BM1JNR021624
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:20 -0700
In-Reply-To: <1278885679-3738-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to settle on the kind of interrupts we'll be using, a choice that
also impacts the number of queues, before registering and making visible
the net_devices.  Move the relevant code up a bit.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 2619997..743dc6f 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3507,6 +3507,12 @@ static int __devinit init_one(struct pci_dev *pdev,
 		adapter->params.offload = 0;
 	}
 
+	/* See what interrupts we'll be using */
+	if (msi > 1 && enable_msix(adapter) == 0)
+		adapter->flags |= USING_MSIX;
+	else if (msi > 0 && pci_enable_msi(pdev) == 0)
+		adapter->flags |= USING_MSI;
+
 	/*
 	 * The card is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole card but rather proceed only
@@ -3542,12 +3548,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		setup_debugfs(adapter);
 	}
 
-	/* See what interrupts we'll be using */
-	if (msi > 1 && enable_msix(adapter) == 0)
-		adapter->flags |= USING_MSIX;
-	else if (msi > 0 && pci_enable_msi(pdev) == 0)
-		adapter->flags |= USING_MSI;
-
 	if (is_offload(adapter))
 		attach_ulds(adapter);
 
@@ -3571,6 +3571,7 @@ sriov:
 			free_netdev(adapter->port[i]);
 	if (adapter->flags & FW_OK)
 		t4_fw_bye(adapter, 0);
+	disable_msi(adapter);
  out_unmap_bar:
 	iounmap(adapter->regs);
  out_free_adapter:
-- 
1.5.4

