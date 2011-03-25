From: mathieu.poirier@linaro.org
Subject: [PATCH] net: allow shifted address in smsc911x
Date: Fri, 25 Mar 2011 15:27:17 -0600
Message-ID: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
Cc: netdev@vger.kernel.org, lee.jones@linaro.org, patches@linaro.org,
	linus.walleij@linaro.org, mathieu.poirier@linaro.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54101 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257Ab1CYV1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 17:27:24 -0400
Received: by iyb14 with SMTP id 14so937302iyb.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 14:27:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alessandro Rubini <rubini@gnudd.com>

At least one device I'm using needs address shifting to access
registers in the LAN9221 device (smsc911x driver).  This patch
adds a shift parameter in platform_data. The feature must be
enabled at configuration time, because shifting by a pdata
parameter makes access slower in those devices where no shift is
needed (I tested one, it was 20% slower).

If the platform data requests shifted access but the feature is
unavailable, the probe method complains to the console. Board
config files should set the configuration option when needed.

Signed-off-by: Alessandro Rubini <rubini@gnudd.com>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/Kconfig      |   10 ++++++++++
 drivers/net/smsc911x.c   |   37 +++++++++++++++++++++++++++++--------
 include/linux/smsc911x.h |    1 +
 3 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..70f2a17 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1075,6 +1075,16 @@ config SMSC911X_ARCH_HOOKS
 	  hooks for more comprehensive interrupt control and also to override
 	  the source of the MAC address.
 
+config SMSC911X_ENABLE_SHIFTED_ADDRESS
+	def_bool n
+	depends on SMSC911X
+	help
+	  The option allows device registers to be accessed in a sparse
+	  way. This is needed to allow boards where the address bus is
+          not wired in the usual way.  You'll most like don't need this
+          option, unless your vendor-provided board configuration file
+	  enables it.
+
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
 	depends on ISA
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index d70bde9..67fb5d6 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -69,6 +69,13 @@ static int debug = 3;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+/* Shift value is uncommon and makes things slower: if not selected, force 0 */
+#ifdef CONFIG_SMSC911X_ENABLE_SHIFTED_ADDRESS
+#define __smsc_shift(pdata, reg) ((reg) << ((pdata)->config.shift))
+#else
+#define __smsc_shift(pdata, reg) (reg)
+#endif
+
 struct smsc911x_data {
 	void __iomem *ioaddr;
 
@@ -121,11 +128,13 @@ struct smsc911x_data {
 static inline u32 __smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT)
-		return readl(pdata->ioaddr + reg);
+		return readl(pdata->ioaddr + __smsc_shift(pdata, reg));
 
 	if (pdata->config.flags & SMSC911X_USE_16BIT)
-		return ((readw(pdata->ioaddr + reg) & 0xFFFF) |
-			((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));
+		return ((readw(pdata->ioaddr +
+			       __smsc_shift(pdata, reg)) & 0xFFFF) |
+			((readw(pdata->ioaddr +
+				__smsc_shift(pdata, reg + 2)) & 0xFFFF) << 16));
 
 	BUG();
 	return 0;
@@ -147,13 +156,15 @@ static inline void __smsc911x_reg_write(struct smsc911x_data *pdata, u32 reg,
 					u32 val)
 {
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		writel(val, pdata->ioaddr + reg);
+		writel(val, pdata->ioaddr + __smsc_shift(pdata, reg));
 		return;
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_16BIT) {
-		writew(val & 0xFFFF, pdata->ioaddr + reg);
-		writew((val >> 16) & 0xFFFF, pdata->ioaddr + reg + 2);
+		writew(val & 0xFFFF,
+		       pdata->ioaddr + __smsc_shift(pdata, reg));
+		writew((val >> 16) & 0xFFFF,
+		       pdata->ioaddr + __smsc_shift(pdata, reg + 2));
 		return;
 	}
 
@@ -187,7 +198,8 @@ smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		writesl(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
+		writesl(pdata->ioaddr + __smsc_shift(pdata, TX_DATA_FIFO),
+			buf, wordcount);
 		goto out;
 	}
 
@@ -219,7 +231,8 @@ smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
 	}
 
 	if (pdata->config.flags & SMSC911X_USE_32BIT) {
-		readsl(pdata->ioaddr + RX_DATA_FIFO, buf, wordcount);
+		readsl(pdata->ioaddr + __smsc_shift(pdata, RX_DATA_FIFO),
+		       buf, wordcount);
 		goto out;
 	}
 
@@ -2023,6 +2036,14 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		goto out_free_netdev_2;
 	}
 
+	/* If platform data wants a shifted address bus, we must support it */
+	if (pdata->config.shift && __smsc_shift(pdata, 1) == 1) {
+		pr_err("smsc911x: CONFIG_SMSC911X_ENABLE_SHIFTED_ADDRESS"
+		       " is required but not available\n");
+		retval = -EINVAL;
+		goto out_unmap_io_3;
+	}
+
 	retval = smsc911x_init(dev);
 	if (retval < 0)
 		goto out_unmap_io_3;
diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
index 7144e8a..ea9a8c5 100644
--- a/include/linux/smsc911x.h
+++ b/include/linux/smsc911x.h
@@ -29,6 +29,7 @@ struct smsc911x_platform_config {
 	unsigned int irq_polarity;
 	unsigned int irq_type;
 	unsigned int flags;
+	unsigned int shift; /* used if CONFIG_SMSC911X_ENABLE_SHIFTED_ADDRESS */
 	phy_interface_t phy_interface;
 	unsigned char mac[6];
 };
-- 
1.7.1

