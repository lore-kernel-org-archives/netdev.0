From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/7] chelsio: useless test in cxgb2::remove_one
Date: Wed, 6 Dec 2006 01:17:27 +0100
Message-ID: <20061206001727.GF2377@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39990 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758543AbWLFAU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:20:59 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_get_drvadata() is necessarily distinct from NULL if
cxgb2::init_one succeeded. cxgb2::remove_one is solely
issued through the PCI device callback.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/cxgb2.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index dc74fa2..2d5922a 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1392,26 +1392,26 @@ static inline void t1_sw_reset(struct pc
 static void __devexit remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct adapter *adapter = netdev_priv(dev);
+	int i;
 
-	if (dev) {
-		int i;
-		struct adapter *adapter = netdev_priv(dev);
-
-		for_each_port(adapter, i)
-			if (test_bit(i, &adapter->registered_device_map))
-				unregister_netdev(adapter->port[i].dev);
+	for_each_port(adapter, i) {
+		if (test_bit(i, &adapter->registered_device_map))
+			unregister_netdev(adapter->port[i].dev);
+	}
 
-		t1_free_sw_modules(adapter);
-		iounmap(adapter->regs);
-		while (--i >= 0)
-			if (adapter->port[i].dev)
-				free_netdev(adapter->port[i].dev);
+	t1_free_sw_modules(adapter);
+	iounmap(adapter->regs);
 
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
-		t1_sw_reset(pdev);
+	while (--i >= 0) {
+		if (adapter->port[i].dev)
+			free_netdev(adapter->port[i].dev);
 	}
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+	t1_sw_reset(pdev);
 }
 
 static struct pci_driver driver = {
-- 
1.4.4.1

