From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: flexcan: fix flexcan driver build for big endian on ARM and little endian on PowerPc
Date: Wed, 29 Jan 2014 22:11:01 +0100
Message-ID: <1391029863-23099-2-git-send-email-mkl@pengutronix.de>
References: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Arnd Bergmann <arnd@arndb.de>,
	Guenter Roeck <linux@roeck-us.net>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49891 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbaA2VLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 16:11:09 -0500
In-Reply-To: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Arnd Bergmann <arnd@arndb.de>

There is no reason to disallow building the driver on big-endian ARM ke=
rnels.
=46urthermore, the current behavior is actually broken on little-endian=
 PowerPC
as well.

The choice of register accessor functions must purely depend on the CPU
architecture, not which endianess the CPU is running on. Note that we n=
owadays
allow both big-endian ARM and little-endian PowerPC kernels.

With this patch applied, we will do the right thing in all four combina=
tions.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/Kconfig   | 2 +-
 drivers/net/can/flexcan.c | 7 +++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index d447b88..9e7d95d 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -104,7 +104,7 @@ config CAN_JANZ_ICAN3
=20
 config CAN_FLEXCAN
 	tristate "Support for Freescale FLEXCAN based chips"
-	depends on (ARM && CPU_LITTLE_ENDIAN) || PPC
+	depends on ARM || PPC
 	---help---
 	  Say Y here if you want to support for Freescale FlexCAN.
=20
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index aaed97b..320bef2 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -235,9 +235,12 @@ static const struct can_bittiming_const flexcan_bi=
ttiming_const =3D {
 };
=20
 /*
- * Abstract off the read/write for arm versus ppc.
+ * Abstract off the read/write for arm versus ppc. This
+ * assumes that PPC uses big-endian registers and everything
+ * else uses little-endian registers, independent of CPU
+ * endianess.
  */
-#if defined(__BIG_ENDIAN)
+#if defined(CONFIG_PPC)
 static inline u32 flexcan_read(void __iomem *addr)
 {
 	return in_be32(addr);
--=20
1.8.5.3
