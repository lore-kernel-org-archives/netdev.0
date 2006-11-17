From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/4] chelsio: free_netdev
Date: Fri, 17 Nov 2006 11:25:23 -0800
Message-ID: <20061117112523.399e4122@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:41908 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753025AbWKQUKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 15:10:14 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network devices need to be free'd with free_netdev() not kfree()
otherwise the kernel will panic if an application has /sys/class/net/ethX/value
open and reads it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/cxgb2.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- chelsio-t2.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio-t2/drivers/net/chelsio/cxgb2.c
@@ -1141,11 +1141,11 @@ static int __devinit init_one(struct pci
 	t1_free_sw_modules(adapter);
  out_free_dev:
 	if (adapter) {
-		if (adapter->regs) iounmap(adapter->regs);
+		if (adapter->regs)
+			iounmap(adapter->regs);
 		for (i = bi->port_number - 1; i >= 0; --i)
-			if (adapter->port[i].dev) {
-				kfree(adapter->port[i].dev);
-			}
+			if (adapter->port[i].dev)
+				free_netdev(adapter->port[i].dev);
 	}
 	pci_release_regions(pdev);
  out_disable_pdev:
@@ -1175,9 +1175,9 @@ static void __devexit remove_one(struct 
 		t1_free_sw_modules(adapter);
 		iounmap(adapter->regs);
 		while (--i >= 0)
-			if (adapter->port[i].dev) {
-				kfree(adapter->port[i].dev);
-			}
+			if (adapter->port[i].dev)
+				free_netdev(adapter->port[i].dev);
+
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
