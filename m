From: Dave Jones <davej@redhat.com>
Subject: delay via-rhine irq initialisation.
Date: Tue, 11 Dec 2007 18:39:09 -0500
Message-ID: <20071211233909.GA22470@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbXLKXjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 18:39:12 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lBBNdBPe000893
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 18:39:11 -0500
Received: from gelk.kernelslacker.org (vpn-14-2.rdu.redhat.com [10.11.14.2])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lBBNdAIF016324
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 18:39:11 -0500
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.2/8.13.8) with ESMTP id lBBNdASP022480
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 18:39:10 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.2/8.14.2/Submit) id lBBNd9ia022479
	for netdev@vger.kernel.org; Tue, 11 Dec 2007 18:39:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With CONFIG_DEBUG_SHIRQ set, via-rhine complains during init.
(See https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=377721 for a report).

Does this diff look right?
(I don't have a via-rhine handy to test with)

We may be able to get away with moving the request_irq to just after the
alloc_tbufs(), but I feel if a real interrupt occured, this diff would
stand more chance of doing the right thing.

Comments?

	Dave

Delay irq registration until after we've allocated ring buffers,
otherwise DEBUG_SHIRQ will complain.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 07263cd..37b3efb 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1151,24 +1151,28 @@ static int rhine_open(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 	int rc;
 
-	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
-			dev);
-	if (rc)
-		return rc;
-
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: rhine_open() irq %d.\n",
 		       dev->name, rp->pdev->irq);
 
 	rc = alloc_ring(dev);
-	if (rc) {
-		free_irq(rp->pdev->irq, dev);
+	if (rc)
 		return rc;
-	}
+
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
 	init_registers(dev);
+
+	rc = request_irq(rp->pdev->irq, &rhine_interrupt, IRQF_SHARED, dev->name,
+			dev);
+	if (rc) {
+		free_rbufs(dev);
+		free_tbufs(dev);
+		free_ring(dev);
+		return rc;
+	}
+
 	if (debug > 2)
 		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
 		       "MII status: %4.4x.\n",
-- 
http://www.codemonkey.org.uk
