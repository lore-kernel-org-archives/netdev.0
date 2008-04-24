From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 10/15] m68k: Some network drivers do not check the platform
Date: Thu, 24 Apr 2008 20:29:50 +0200
Message-ID: <20080424183242.943446357@mail.of.borg>
References: <20080424182940.424312704@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yorgi.telenet-ops.be ([195.130.133.69]:43508 "EHLO
	yorgi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760489AbYDXSes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 14:34:48 -0400
Received: from wilson.telenet-ops.be (wilson.telenet-ops.be [195.130.132.42])
	by yorgi.telenet-ops.be (Postfix) with ESMTP id A518758A7B4
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 20:34:47 +0200 (CEST)
Content-Disposition: inline; filename=m68k-net-drivers-break-multiplatform.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>

Some network drivers do not check whether they're actually running on the
correct platform, causing multi-platform kernels to crash if they are not.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/82596.c     |    7 +++++++
 drivers/net/apne.c      |    3 +++
 drivers/net/mac89x0.c   |    3 +++
 drivers/net/macmace.c   |    3 +++
 drivers/net/sun3lance.c |    3 +++
 5 files changed, 19 insertions(+)

--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1162,6 +1162,7 @@ struct net_device * __init i82596_probe(
 		memcpy(eth_addr, (void *) 0xfffc1f2c, 6);	/* YUCK! Get addr from NOVRAM */
 		dev->base_addr = MVME_I596_BASE;
 		dev->irq = (unsigned) MVME16x_IRQ_I596;
+		goto found;
 	}
 #endif
 #ifdef ENABLE_BVME6000_NET
@@ -1176,6 +1177,7 @@ struct net_device * __init i82596_probe(
 		rtc[3] = msr;
 		dev->base_addr = BVME_I596_BASE;
 		dev->irq = (unsigned) BVME_IRQ_I596;
+		goto found;
 	}
 #endif
 #ifdef ENABLE_APRICOT
@@ -1212,8 +1214,13 @@ struct net_device * __init i82596_probe(
 		}
 
 		dev->irq = 10;
+		goto found;
 	}
 #endif
+	err = -ENODEV;
+	goto out;
+
+found:
 	dev->mem_start = (int)__get_free_pages(GFP_ATOMIC, 0);
 	if (!dev->mem_start) {
 		err = -ENOMEM;
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -127,6 +127,9 @@ struct net_device * __init apne_probe(in
 #endif
 	int err;
 
+	if (!MACH_IS_AMIGA)
+		return ERR_PTR(-ENODEV);
+
 	if (apne_owned)
 		return ERR_PTR(-ENODEV);
 
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -183,6 +183,9 @@ struct net_device * __init mac89x0_probe
 	int err = -ENODEV;
 	DECLARE_MAC_BUF(mac);
 
+	if (!MACH_IS_MAC)
+		return ERR_PTR(-ENODEV);
+
 	dev = alloc_etherdev(sizeof(struct net_local));
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -781,6 +781,9 @@ static int __init mac_mace_init_module(v
 {
 	int err;
 
+	if (!MACH_IS_MAC)
+		return -ENODEV;
+
 	if ((err = platform_driver_register(&mac_mace_driver))) {
 		printk(KERN_ERR "Driver registration failed\n");
 		return err;
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -250,6 +250,9 @@ struct net_device * __init sun3lance_pro
 	static int found;
 	int err = -ENODEV;
 
+	if (!MACH_IS_SUN3 && !MACH_IS_SUN3X)
+		return ERR_PTR(-ENODEV);
+
 	/* check that this machine has an onboard lance */
 	switch(idprom->id_machtype) {
 	case SM_SUN3|SM_3_50:

-- 
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

