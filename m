From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: Add support for Freescale MX27
Date: Thu, 29 Jan 2009 10:03:10 +0100
Message-ID: <1233219791-18691-9-git-send-email-s.hauer@pengutronix.de>
References: <1233219791-18691-1-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-2-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-3-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-4-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-5-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-6-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-7-git-send-email-s.hauer@pengutronix.de>
 <1233219791-18691-8-git-send-email-s.hauer@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48090 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbZA2JEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 04:04:30 -0500
In-Reply-To: <1233219791-18691-8-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
Acked-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/Kconfig |    6 +++---
 drivers/net/fec.c   |   15 +++++++++++++--
 drivers/net/fec.h   |   11 +++++++++--
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9fe8cb7..2d7cd61 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1828,11 +1828,11 @@ config 68360_ENET
 	  the Motorola 68360 processor.
 
 config FEC
-	bool "FEC ethernet controller (of ColdFire CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x
+	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	depends on M523x || M527x || M5272 || M528x || M520x || MACH_MX27
 	help
 	  Say Y here if you want to use the built-in 10/100 Fast ethernet
-	  controller on some Motorola ColdFire processors.
+	  controller on some Motorola ColdFire and Freescale i.MX processors.
 
 config FEC2
 	bool "Second FEC ethernet controller (on some ColdFire CPUs)"
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index a17dc6a..7631062 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -38,10 +38,14 @@
 #include <linux/bitops.h>
 #include <linux/io.h>
 #include <linux/irq.h>
+#include <linux/clk.h>
 
 #include <asm/cacheflush.h>
+
+#ifndef CONFIG_ARCH_MXC
 #include <asm/coldfire.h>
 #include <asm/mcfsim.h>
+#endif
 
 #include "fec.h"
 
@@ -51,6 +55,13 @@
 #define	FEC_MAX_PORTS	1
 #endif
 
+#ifdef CONFIG_ARCH_MXC
+#include <mach/hardware.h>
+#define FEC_ALIGNMENT	0xf
+#else
+#define FEC_ALIGNMENT	0x3
+#endif
+
 #if defined(CONFIG_M5272)
 #define HAVE_mii_link_interrupt
 #endif
@@ -158,7 +169,7 @@ typedef struct {
  * account when setting it.
  */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
 #define	OPT_FRAME_SIZE	(PKT_MAXBUF_SIZE << 16)
 #else
 #define	OPT_FRAME_SIZE	0
@@ -339,7 +350,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *	4-byte boundaries. Use bounce buffers to copy data
 	 *	and get it aligned. Ugh.
 	 */
-	if (bdp->cbd_bufaddr & 0x3) {
+	if (bdp->cbd_bufaddr & FEC_ALIGNMENT) {
 		unsigned int index;
 		index = bdp - fep->tx_bd_base;
 		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 292719d..76c64c9 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -14,7 +14,7 @@
 /****************************************************************************/
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
 /*
  *	Just figures, Motorola would have to change the offsets for
  *	registers in the same peripheral device on different models
@@ -103,12 +103,19 @@ typedef struct fec {
 /*
  *	Define the buffer descriptor structure.
  */
+#ifdef CONFIG_ARCH_MXC
+typedef struct bufdesc {
+	unsigned short cbd_datlen;	/* Data length */
+	unsigned short cbd_sc;	/* Control and status info */
+	unsigned long cbd_bufaddr;	/* Buffer address */
+} cbd_t;
+#else
 typedef struct bufdesc {
 	unsigned short	cbd_sc;			/* Control and status info */
 	unsigned short	cbd_datlen;		/* Data length */
 	unsigned long	cbd_bufaddr;		/* Buffer address */
 } cbd_t;
-
+#endif
 
 /*
  *	The following definitions courtesy of commproc.h, which where
-- 
1.5.6.5

