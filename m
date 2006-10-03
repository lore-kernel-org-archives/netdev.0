From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch 6/6] 2.6.18: sb1250-mac: PHY interrupt polarity fixup
Date: Tue, 3 Oct 2006 16:19:12 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610031605200.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:25359 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964857AbWJCPTN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:19:13 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 This change makes the PHY interrupt actually work as intended on the 
SWARM board, where the CFE firmware leaves the GPIO line at the power-on 
polarity, which is suitable for active-high interrupts, but not quite so 
for this one (the "interrupt force" bit in the PHY works much better for 
stress-testing interrupt handling; use that one instead if needed).

 Please consider.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-mips-2.6.18-20060920-swarm-setup-15
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/arch/mips/sibyte/swarm/setup.c linux-mips-2.6.18-20060920/arch/mips/sibyte/swarm/setup.c
--- linux-mips-2.6.18-20060920.macro/arch/mips/sibyte/swarm/setup.c	2006-07-12 04:59:56.000000000 +0000
+++ linux-mips-2.6.18-20060920/arch/mips/sibyte/swarm/setup.c	2006-09-28 02:37:31.000000000 +0000
@@ -1,6 +1,7 @@
 /*
  * Copyright (C) 2000, 2001, 2002, 2003, 2004 Broadcom Corporation
  * Copyright (C) 2004 by Ralf Baechle (ralf@linux-mips.org)
+ * Copyright (c) 2006  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -106,6 +107,8 @@ int swarm_be_handler(struct pt_regs *reg
 
 void __init plat_mem_setup(void)
 {
+	u64 invert;
+
 #if defined(CONFIG_SIBYTE_BCM1x55) || defined(CONFIG_SIBYTE_BCM1x80)
 	bcm1480_setup();
 #elif defined(CONFIG_SIBYTE_SB1250) || defined(CONFIG_SIBYTE_BCM112X)
@@ -114,6 +117,16 @@ void __init plat_mem_setup(void)
 #error invalid SiByte board configuation
 #endif
 
+	/*
+	 * The PHY interrupt on the SWARM is active low,
+	 * but CFE gets it wrong (or not at all, probably).
+	 */
+#ifdef K_GPIO_PHY
+	invert = __raw_readq(IOADDR(A_GPIO_INPUT_INVERT));
+	invert |= 1 << K_GPIO_PHY;
+	__raw_writeq(invert, IOADDR(A_GPIO_INPUT_INVERT));
+#endif
+
 	panic_timeout = 5;  /* For debug.  */
 
 	board_time_init = swarm_time_init;
