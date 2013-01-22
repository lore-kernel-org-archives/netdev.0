From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/15] drivers/net: delete the really obsolete 8390 based 10Mbit ISA drivers
Date: Mon, 21 Jan 2013 20:46:19 -0500
Message-ID: <1358819182-28032-13-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45368 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976Ab3AVBql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:41 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an area I know all too well, after being author of several 8390
drivers, and maintainer of all 8390 drivers during a large part of their
active lifecycle.

To that end, I can say this with a reasonable degree of confidence.
The drivers deleted here represent the earliest (as in early 1990)
hardware and/or rare hardware.  The remaining hardware not deleted
here is the more modern/sane of the lot, with ISA-PnP and jumperless
"soft configuration" like the wd and smc cards had.

The original ne2000 driver (ne.c) gets a pass at this time since
AT/LANTIC based cards that could be both ne2000 or wd-like (with
shared memory) and with jumperless configuration were made in the
mid to late 1990's, and performed reasonably well for their era.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                 |  16 -
 drivers/net/ethernet/8390/3c503.c   | 778 ------------------------------------
 drivers/net/ethernet/8390/3c503.h   |  91 -----
 drivers/net/ethernet/8390/Kconfig   |  48 ---
 drivers/net/ethernet/8390/Makefile  |   4 -
 drivers/net/ethernet/8390/e2100.c   | 489 ----------------------
 drivers/net/ethernet/8390/hp-plus.c | 505 -----------------------
 drivers/net/ethernet/8390/hp.c      | 438 --------------------
 8 files changed, 2369 deletions(-)
 delete mode 100644 drivers/net/ethernet/8390/3c503.c
 delete mode 100644 drivers/net/ethernet/8390/3c503.h
 delete mode 100644 drivers/net/ethernet/8390/e2100.c
 delete mode 100644 drivers/net/ethernet/8390/hp-plus.c
 delete mode 100644 drivers/net/ethernet/8390/hp.c

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 15de20b..393b017 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -40,14 +40,10 @@
 extern struct net_device *hp100_probe(int unit);
 extern struct net_device *ultra_probe(int unit);
 extern struct net_device *wd_probe(int unit);
-extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
-extern struct net_device *hp_probe(int unit);
-extern struct net_device *hp_plus_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
-extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
 extern struct net_device *seeq8005_probe(int unit);
@@ -108,18 +104,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #ifdef CONFIG_WD80x3
 	{wd_probe, 0},
 #endif
-#ifdef CONFIG_EL2 		/* 3c503 */
-	{el2_probe, 0},
-#endif
-#ifdef CONFIG_HPLAN
-	{hp_probe, 0},
-#endif
-#ifdef CONFIG_HPLAN_PLUS
-	{hp_plus_probe, 0},
-#endif
-#ifdef CONFIG_E2100		/* Cabletron E21xx series. */
-	{e2100_probe, 0},
-#endif
 #if defined(CONFIG_NE2000) || \
     defined(CONFIG_NE_H8300)  /* ISA (use ne2k-pci for PCI cards) */
 	{ne_probe, 0},
diff --git a/drivers/net/ethernet/8390/3c503.c b/drivers/net/ethernet/8390/3c503.c
deleted file mode 100644
index 0e9afe7..0000000
diff --git a/drivers/net/ethernet/8390/3c503.h b/drivers/net/ethernet/8390/3c503.h
deleted file mode 100644
index e2367b8..0000000
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index e49a442..1b78ca7 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -21,18 +21,6 @@ config NET_VENDOR_8390
 
 if NET_VENDOR_8390
 
-config EL2
-	tristate "3c503 \"EtherLink II\" support"
-	depends on ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c503.
-
 config PCMCIA_AXNET
 	tristate "Asix AX88190 PCMCIA support"
 	depends on PCMCIA
@@ -62,42 +50,6 @@ config AX88796_93CX6
 	---help---
 	  Select this if your platform comes with an external 93CX6 eeprom.
 
-config E2100
-	tristate "Cabletron E21xx support"
-	depends on ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e2100.
-
-config HPLAN_PLUS
-	tristate "HP PCLAN+ (27247B and 27252A) support"
-	depends on ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called hp-plus.
-
-config HPLAN
-	tristate "HP PCLAN (27245 and other 27xxx series) support"
-	depends on ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called hp.
-
 config HYDRA
 	tristate "Hydra support"
 	depends on ZORRO
diff --git a/drivers/net/ethernet/8390/Makefile b/drivers/net/ethernet/8390/Makefile
index e8bb97c..588954a 100644
--- a/drivers/net/ethernet/8390/Makefile
+++ b/drivers/net/ethernet/8390/Makefile
@@ -6,10 +6,6 @@ obj-$(CONFIG_MAC8390) += mac8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_ARM_ETHERH) += etherh.o
 obj-$(CONFIG_AX88796) += ax88796.o
-obj-$(CONFIG_E2100) += e2100.o 8390.o
-obj-$(CONFIG_EL2) += 3c503.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
-obj-$(CONFIG_HPLAN) += hp.o 8390p.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
 obj-$(CONFIG_MCF8390) += mcf8390.o 8390.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
diff --git a/drivers/net/ethernet/8390/e2100.c b/drivers/net/ethernet/8390/e2100.c
deleted file mode 100644
index ed55ce8..0000000
diff --git a/drivers/net/ethernet/8390/hp-plus.c b/drivers/net/ethernet/8390/hp-plus.c
deleted file mode 100644
index 52f70f9..0000000
diff --git a/drivers/net/ethernet/8390/hp.c b/drivers/net/ethernet/8390/hp.c
deleted file mode 100644
index 37fa89a..0000000
-- 
1.8.1
