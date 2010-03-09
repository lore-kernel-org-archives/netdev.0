From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH] net: add ColdFire support to the smc91x driver
Date: Tue, 9 Mar 2010 17:03:51 +1000
Message-ID: <201003090703.o2973pbP013668@goober.internal.moreton.com.au>
Cc: <gerg@uclinux.org>, <netdev@vger.kernel.org>
To: <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:53062 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751873Ab0CIG7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:59:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: add ColdFire support to the smc91x driver

Some embedded ColdFire based boards use the SMC 91x family of ethernet
devices. (For example the Freescale M5249C3 and MoretonBay NETtel).

Add IO access support to the SMC91x driver, and allow this driver to
be configured for ColdFire platforms.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---


diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 5479954..5af3dcd 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -330,6 +330,34 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
 
 #include <unit/smc91111.h>
 
+#elif defined(CONFIG_COLDFIRE)
+
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_NOWAIT		1
+
+static inline void mcf_insw(void *a, unsigned char *p, int l)
+{
+	u16 *wp = (u16 *) p;
+	while (l-- > 0)
+		*wp++ = readw(a);
+}
+
+static inline void mcf_outsw(void *a, unsigned char *p, int l)
+{
+	u16 *wp = (u16 *) p;
+	while (l-- > 0)
+		writew(*wp++, a);
+}
+
+#define SMC_inw(a, r)		_swapw(readw((a) + (r)))
+#define SMC_outw(v, a, r)	writew(_swapw(v), (a) + (r))
+#define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
+#define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
+
+#define SMC_IRQ_FLAGS		(IRQF_DISABLED)
+
 #else
 
 /*
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..44142d8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -895,7 +895,7 @@ config SMC91X
 	select CRC32
 	select MII
 	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || \
-		MIPS || BLACKFIN || MN10300
+		MIPS || BLACKFIN || MN10300 || COLDFIRE
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
