From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: fec: use CONFIG_ARM instead of CONFIG_ARCH_MXC/SOC_IMX28
Date: Mon, 25 Jan 2016 11:40:14 +0100
Message-ID: <1453718414-7173-1-git-send-email-johannes@sipsolutions.net>
Cc: Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawnguo@kernel.org>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59634 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932338AbcAYKkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 05:40:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

As Arnd Bergmann points out, using CONFIG_ARCH_MXC and/or SOC_IMX28
is wrong if some other ARM platform uses this device - the operation
of the driver would depend on an unrelated ARM platform that might
or might not be set for multi-platform kernels.

Prior to my previous patch, any other platforms using it would have
been broken already due to having the cbd_datlen/cbd_sc fields in
the wrong order, but byte ordering correctly, so no such platforms
can exist and work today.

In any case, it seems likely that only Freescale SoCs use this part,
and those are little-endian on ARM, so CONFIG_ARM is safe for them.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/ethernet/freescale/fec.h      | 8 +++-----
 drivers/net/ethernet/freescale/fec_main.c | 3 +--
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 7dd47a0b8cfb..2106d72c91dc 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -19,8 +19,7 @@
 #include <linux/timecounter.h>
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
-    defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
 /*
  *	Just figures, Motorola would have to change the offsets for
  *	registers in the same peripheral device on different models
@@ -192,10 +191,9 @@
  *	Define the buffer descriptor structure.
  *
  *	Evidently, ARM SoCs have the FEC block generated in a
- *	little endian mode; or at least ARCH_MXC/SOC_IMX28 do,
- *	so adjust endianness accordingly.
+ *	little endian mode so adjust endianness accordingly.
  */
-#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+#if defined(CONFIG_ARM)
 #define fec32_to_cpu le32_to_cpu
 #define fec16_to_cpu le16_to_cpu
 #define cpu_to_fec32 cpu_to_le32
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a055fbad1253..dffb452b245f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2170,8 +2170,7 @@ static int fec_enet_get_regs_len(struct net_device *ndev)
 
 /* List of registers that can be safety be read to dump them with ethtool */
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-	defined(CONFIG_M520x) || defined(CONFIG_M532x) ||		\
-	defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
+	defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARM)
 static u32 fec_enet_register_offset[] = {
 	FEC_IEVENT, FEC_IMASK, FEC_R_DES_ACTIVE_0, FEC_X_DES_ACTIVE_0,
 	FEC_ECNTRL, FEC_MII_DATA, FEC_MII_SPEED, FEC_MIB_CTRLSTAT, FEC_R_CNTRL,
-- 
2.6.2
