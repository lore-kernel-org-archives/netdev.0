From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 13:28:29 +1100
Message-ID: <1162780109.28571.273.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36537 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1422875AbWKFC2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 21:28:55 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The s2io driver is redefining it's own readq/writeq based on
readl/writel when the platform doesn't provide native ones. However, it
currently does so by testing #ifndef readq. While that works for now, we
are about to change ppc64 to use inline functions rather that macros for
all those IO accessors which will break that test. This fixes it. I
don't have anything less ugly at hand unfortunately.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

The patch changing ppc64 own definition is scheduled to go in 2.6.20 when
the merge window opens, so it would be nice if this patch could go in a
similar timeframe, provided that you agree with it of course. It can go
earlier as it won't break current ppc64.

Index: linux-cell/drivers/net/s2io.h
===================================================================
--- linux-cell.orig/drivers/net/s2io.h	2006-10-13 17:23:49.000000000 +1000
+++ linux-cell/drivers/net/s2io.h	2006-11-06 13:19:32.000000000 +1100
@@ -862,8 +862,10 @@ struct s2io_nic {
 #define RESET_ERROR 1;
 #define CMD_ERROR   2;
 
-/*  OS related system calls */
-#ifndef readq
+/* OS related system calls. Note that ppc64 has readq defined as
+ * an inline, not a macro
+ */
+#if !defined(CONFIG_PPC64) && !defined(readq)
 static inline u64 readq(void __iomem *addr)
 {
 	u64 ret = 0;
@@ -875,7 +877,7 @@ static inline u64 readq(void __iomem *ad
 }
 #endif
 
-#ifndef writeq
+#if !defined(CONFIG_PPC64) && !defined(writeq)
 static inline void writeq(u64 val, void __iomem *addr)
 {
 	writel((u32) (val), addr);



