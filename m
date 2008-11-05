From: Chuck Ebbert <cebbert@redhat.com>
Subject: [proposed patch] via-rhine: prevent oops when requesting an IRQ
Date: Tue, 4 Nov 2008 19:23:57 -0500
Message-ID: <20081104192357.2b0dbe22@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33549 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbYKEAYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 19:24:20 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mA50OKOA001037
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 19:24:20 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mA50OJwj006742
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 19:24:19 -0500
Received: from localhost.localdomain (dhcp-100-2-144.bos.redhat.com [10.16.2.144])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mA50OJtS000372
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 19:24:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

via-rhine: prevent oops when requesting an IRQ

via-rhine requests an IRQ before it's ready to handle an interrupt.
It oopses when CONFIG_DEBUG_SHIRQ is enabled.

https://bugzilla.redhat.com/show_bug.cgi?id=469303

---

NOTE: UNTESTED: Is it okay to init the hardware before requesting the
IRQ, or should that be done afterward?

Index: linux-2.6.27.noarch/drivers/net/via-rhine.c
===================================================================
--- linux-2.6.27.noarch.orig/drivers/net/via-rhine.c
+++ linux-2.6.27.noarch/drivers/net/via-rhine.c
@@ -1141,24 +1141,27 @@ static int rhine_open(struct net_device 
 	void __iomem *ioaddr = rp->base;
 	int rc;
 
-	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
-			dev);
+	rc = alloc_ring(dev);
 	if (rc)
 		return rc;
 
-	if (debug > 1)
-		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
-		       dev->name, rp->pdev->irq);
-
-	rc = alloc_ring(dev);
-	if (rc) {
-		free_irq(rp->pdev->irq, dev);
-		return rc;
-	}
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
 	init_registers(dev);
+
+	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
+			dev);
+	if (rc) {
+		free_tbufs(dev);
+		free_rbufs(dev);
+		free_ring(dev);
+		return rc;
+	}
+
+	if (debug > 1)
+		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
+		       dev->name, rp->pdev->irq);
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
 		       "MII status: %4.4x.\n",
