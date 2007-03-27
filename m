From: akpm@linux-foundation.org
Subject: [patch 07/10] SUN3/3X Lance trivial fix improved
Date: Mon, 26 Mar 2007 21:47:26 -0800
Message-ID: <200703270547.l2R5lQco008269@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	gorcunov@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40119 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934003AbXC0Frc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Cyrill V. Gorcunov" <gorcunov@gmail.com>

This patch adds checking for allocated DVMA memory and granted IRQ line.

Signed-off-by: Cyrill V. Gorcunov <gorcunov@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sun3lance.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff -puN drivers/net/sun3lance.c~sun3-3x-lance-trivial-fix-improved drivers/net/sun3lance.c
--- a/drivers/net/sun3lance.c~sun3-3x-lance-trivial-fix-improved
+++ a/drivers/net/sun3lance.c
@@ -336,13 +336,27 @@ static int __init lance_probe( struct ne
 
 	/* XXX - leak? */
 	MEM = dvma_malloc_align(sizeof(struct lance_memory), 0x10000);
+	if (MEM == NULL) {
+#ifdef CONFIG_SUN3
+		iounmap((void __iomem *)ioaddr);
+#endif
+		printk(KERN_WARNING "SUN3 Lance couldn't allocate DVMA memory\n");
+		return 0;
+	}
 
 	lp->iobase = (volatile unsigned short *)ioaddr;
 	dev->base_addr = (unsigned long)ioaddr; /* informational only */
 
 	REGA(CSR0) = CSR0_STOP;
 
-	request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev);
+	if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev) < 0) {
+#ifdef CONFIG_SUN3
+		iounmap((void __iomem *)ioaddr);
+#endif
+		dvma_free((void *)MEM);
+		printk(KERN_WARNING "SUN3 Lance unable to allocate IRQ\n");
+		return 0;
+	}
 	dev->irq = (unsigned short)LANCE_IRQ;
 
 
_
