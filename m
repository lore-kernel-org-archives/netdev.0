From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 3/4] spidernet: spidernet: add support for Celleb
Date: Wed, 14 Feb 2007 17:10:18 +0900 (JST)
Message-ID: <200702140810.l1E8AIqx014680@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jim@jklewis.com, linuxppc-dev@ozlabs.org,
	linas@austin.ibm.com, jens@de.ibm.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:59061 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbXBNILJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 03:11:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds or changes some HW specific settings for spider_net on
Celleb.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Acked-by: Linas Vepstas <linas@austin.ibm.com>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

--- org-linux-powerpc-git/drivers/net/Kconfig	2007-02-14 13:33:09.000000000 +0900
+++ linux-powerpc-git/drivers/net/Kconfig	2007-02-14 13:33:17.000000000 +0900
@@ -2243,7 +2243,7 @@
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && PPC_IBM_CELL_BLADE
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
 	select FW_LOADER
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
--- org-linux-powerpc-git/drivers/net/spider_net.h	2007-02-14 12:13:44.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.h	2007-02-14 13:31:22.000000000 +0900
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -184,7 +185,8 @@
 
 /* pause frames: automatic, no upper retransmission count */
 /* outside loopback mode: ETOMOD signal dont matter, not connected */
-#define SPIDER_NET_OPMODE_VALUE		0x00000063
+/* ETOMOD signal is brought to PHY reset. bit 2 must be 1 in Celleb */
+#define SPIDER_NET_OPMODE_VALUE		0x00000067
 /*#define SPIDER_NET_OPMODE_VALUE		0x001b0062*/
 #define SPIDER_NET_LENLMT_VALUE		0x00000908
 
--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-02-14 12:19:28.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-02-14 13:31:22.000000000 +0900
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -1627,6 +1628,11 @@
 
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
+
+	/* trigger ETOMOD signal */
+	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
+		spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
+
 }
 
 /**
