From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/15] drivers/net: delete old parallel port de600/de620 drivers
Date: Mon, 21 Jan 2013 20:46:11 -0500
Message-ID: <1358819182-28032-5-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45329 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab3AVBqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:37 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The parallel port is largely replaced by USB, and even in the
day where these drivers were current, the documented speed was
less than 100kB/s.  Let us not pretend that anyone cares about
these drivers anymore, or worse - pretend that anyone is using
them on a modern kernel.

As a side bonus, this is the end of legacy parallel port ethernet,
so we get to drop the whole chunk relating to that in the legacy
Space.c file containing the non-PCI unified probe dispatch.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 Documentation/networking/DLINK.txt  | 203 --------
 drivers/net/Space.c                 |  13 +-
 drivers/net/ethernet/dlink/Kconfig  |  32 +-
 drivers/net/ethernet/dlink/Makefile |   2 -
 drivers/net/ethernet/dlink/de600.c  | 529 -------------------
 drivers/net/ethernet/dlink/de600.h  | 168 ------
 drivers/net/ethernet/dlink/de620.c  | 987 ------------------------------------
 drivers/net/ethernet/dlink/de620.h  | 117 -----
 8 files changed, 2 insertions(+), 2049 deletions(-)
 delete mode 100644 Documentation/networking/DLINK.txt
 delete mode 100644 drivers/net/ethernet/dlink/de600.c
 delete mode 100644 drivers/net/ethernet/dlink/de600.h
 delete mode 100644 drivers/net/ethernet/dlink/de620.c
 delete mode 100644 drivers/net/ethernet/dlink/de620.h

diff --git a/Documentation/networking/DLINK.txt b/Documentation/networking/DLINK.txt
deleted file mode 100644
index 55d2443..0000000
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 64cd86e..d487127 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -73,9 +73,6 @@ extern struct net_device *mac89x0_probe(int unit);
 extern struct net_device *cops_probe(int unit);
 extern struct net_device *ltpc_probe(void);
 
-/* Detachable devices ("pocket adaptors") */
-extern struct net_device *de620_probe(int unit);
-
 /* Fibre Channel adapters */
 extern int iph5526_probe(struct net_device *dev);
 
@@ -185,13 +182,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 	{NULL, 0},
 };
 
-static struct devprobe2 parport_probes[] __initdata = {
-#ifdef CONFIG_DE620		/* D-Link DE-620 adapter */
-	{de620_probe, 0},
-#endif
-	{NULL, 0},
-};
-
 static struct devprobe2 m68k_probes[] __initdata = {
 #ifdef CONFIG_ATARILANCE	/* Lance-based Atari ethernet boards */
 	{atarilance_probe, 0},
@@ -230,8 +220,7 @@ static void __init ethif_probe2(int unit)
 		return;
 
 	(void)(	probe_list2(unit, m68k_probes, base_addr == 0) &&
-		probe_list2(unit, isa_probes, base_addr == 0) &&
-		probe_list2(unit, parport_probes, base_addr == 0));
+		probe_list2(unit, isa_probes, base_addr == 0));
 }
 
 /*  Statically configured drivers -- order matters here. */
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlink/Kconfig
index b5afe21..ee26ce7 100644
--- a/drivers/net/ethernet/dlink/Kconfig
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_DLINK
 	bool "D-Link devices"
 	default y
-	depends on PCI || PARPORT
+	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -18,36 +18,6 @@ config NET_VENDOR_DLINK
 
 if NET_VENDOR_DLINK
 
-config DE600
-	tristate "D-Link DE600 pocket adapter support"
-	depends on PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de600.
-
-config DE620
-	tristate "D-Link DE620 pocket adapter support"
-	depends on PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de620.
-
 config DL2K
 	tristate "DL2000/TC902x-based Gigabit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/ethernet/dlink/Makefile b/drivers/net/ethernet/dlink/Makefile
index c705eaa..40085f6 100644
--- a/drivers/net/ethernet/dlink/Makefile
+++ b/drivers/net/ethernet/dlink/Makefile
@@ -2,7 +2,5 @@
 # Makefile for the D-Link network device drivers.
 #
 
-obj-$(CONFIG_DE600) += de600.o
-obj-$(CONFIG_DE620) += de620.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_SUNDANCE) += sundance.o
diff --git a/drivers/net/ethernet/dlink/de600.c b/drivers/net/ethernet/dlink/de600.c
deleted file mode 100644
index 414f0ee..0000000
diff --git a/drivers/net/ethernet/dlink/de600.h b/drivers/net/ethernet/dlink/de600.h
deleted file mode 100644
index e80ecba..0000000
diff --git a/drivers/net/ethernet/dlink/de620.c b/drivers/net/ethernet/dlink/de620.c
deleted file mode 100644
index 2e2bc60..0000000
diff --git a/drivers/net/ethernet/dlink/de620.h b/drivers/net/ethernet/dlink/de620.h
deleted file mode 100644
index e8d9a88..0000000
-- 
1.8.1
