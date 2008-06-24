From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 05/10] smc91x: prepare for SMC_IO_SHIFT to be a platform configurable variable
Date: Tue, 24 Jun 2008 17:47:42 +0800
Message-ID: <1214300867-15495-6-git-send-email-eric.y.miao@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:44711 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753593AbYFXJrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 05:47:41 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.miao@marvell.com>

Now one can use the following code

  #define SMC_IO_SHIFT	smc_io_shift

to make SMC_IO_SHIFT a variable. This, however, will slightly increase
the CPU overhead and have negative impact on the network performance.
The tradeoff is, this can be specified in the smc91x platform data so
that multiple boards support can be built in a single zImage.

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 drivers/net/smc91x.c   |    7 +++++--
 include/linux/smc91x.h |    7 +++++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index caa0308..3a319f2 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -105,6 +105,8 @@ MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:smc91x");
 
+static int smc_io_shift __maybe_unused;
+
 /*
  * The internal workings of the driver.  If you are changing anything
  * here with the SMC stuff, you should have the datasheet and know
@@ -2136,9 +2138,10 @@ static int smc_drv_probe(struct platform_device *pdev)
 
 	lp = netdev_priv(ndev);
 
-	if (pd)
+	if (pd) {
 		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
-	else {
+		smc_io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
+	} else {
 		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
 		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index 90434db..0dea945 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -7,6 +7,13 @@
 
 #define SMC91X_NOWAIT		(1 << 3)
 
+/* two bits for IO_SHIFT, let's hope later designs will keep this sane */
+#define SMC91X_IO_SHIFT_0	(0 << 4)
+#define SMC91X_IO_SHIFT_1	(1 << 4)
+#define SMC91X_IO_SHIFT_2	(2 << 4)
+#define SMC91X_IO_SHIFT_3	(3 << 4)
+#define SMC91X_IO_SHIFT(x)	(((x) >> 4) & 0x3)
+
 struct smc91x_platdata {
 	unsigned long flags;
 };
-- 
1.5.4.3

