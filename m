From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 06/11] net: bcmgenet: add Wake-on-LAN support code
Date: Thu, 10 Jul 2014 15:46:19 -0700
Message-ID: <1405032384-24006-7-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:61190 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbaGJWqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:34 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so3638065igq.7
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:33 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add all the required code to program the GENET hardware to enter
Wake-on-LAN mode and wake using MagicPackets with or without SecureOn
password.

This code is hooked to the build system, but is not yet referenced from
ethtool or the main bcmgenet driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h     |   9 +
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 206 +++++++++++++++++++++
 3 files changed, 216 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c

diff --git a/drivers/net/ethernet/broadcom/genet/Makefile b/drivers/net/ethernet/broadcom/genet/Makefile
index 31f55a90a197..9b6885efa9e7 100644
--- a/drivers/net/ethernet/broadcom/genet/Makefile
+++ b/drivers/net/ethernet/broadcom/genet/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_BCMGENET) += genet.o
-genet-objs := bcmgenet.o bcmmii.o
+genet-objs := bcmgenet.o bcmmii.o bcmgenet_wol.o
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 00a5e27ce0e5..e78707b5bcf9 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -456,6 +456,7 @@ struct enet_cb {
 enum bcmgenet_power_mode {
 	GENET_POWER_CABLE_SENSE = 0,
 	GENET_POWER_PASSIVE,
+	GENET_POWER_WOL_MAGIC,
 };
 
 struct bcmgenet_priv;
@@ -626,4 +627,12 @@ int bcmgenet_mii_config(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_mii_reset(struct net_device *dev);
 
+/* Wake-on-LAN routines */
+void bcmgenet_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol);
+int bcmgenet_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol);
+int bcmgenet_wol_power_down_cfg(struct bcmgenet_priv *priv,
+				enum bcmgenet_power_mode mode);
+void bcmgenet_wol_power_up_cfg(struct bcmgenet_priv *priv,
+			       enum bcmgenet_power_mode mode);
+
 #endif /* __BCMGENET_H__ */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
new file mode 100644
index 000000000000..3aa3cc5c31c7
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
@@ -0,0 +1,206 @@
+/*
+ * Broadcom GENET (Gigabit Ethernet) Wake-on-LAN support
+ *
+ * Copyright (c) 2014 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt)				"bcmgenet_wol: " fmt
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/delay.h>
+#include <linux/pm.h>
+#include <linux/clk.h>
+#include <linux/version.h>
+#include <linux/platform_device.h>
+#include <net/arp.h>
+
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/phy.h>
+
+#include "bcmgenet.h"
+
+/* ethtool function - get WOL (Wake on LAN) settings, Only Magic Packet
+ * Detection is supported through ethtool
+ */
+void bcmgenet_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	u32 reg;
+
+	wol->supported = WAKE_MAGIC | WAKE_MAGICSECURE;
+	wol->wolopts = priv->wolopts;
+	memset(wol->sopass, 0, sizeof(wol->sopass));
+
+	if (wol->wolopts & WAKE_MAGICSECURE) {
+		reg = bcmgenet_umac_readl(priv, UMAC_MPD_PW_MS);
+		put_unaligned_be16(reg, &wol->sopass[0]);
+		reg = bcmgenet_umac_readl(priv, UMAC_MPD_PW_LS);
+		put_unaligned_be32(reg, &wol->sopass[2]);
+	}
+}
+
+/* ethtool function - set WOL (Wake on LAN) settings.
+ * Only for magic packet detection mode.
+ */
+int bcmgenet_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct device *kdev = &priv->pdev->dev;
+	u32 reg;
+
+	if (!device_can_wakeup(kdev))
+		return -ENOTSUPP;
+
+	if (wol->wolopts & ~(WAKE_MAGIC | WAKE_MAGICSECURE))
+		return -EINVAL;
+
+	if (wol->wolopts & WAKE_MAGICSECURE) {
+		bcmgenet_umac_writel(priv, get_unaligned_be16(&wol->sopass[0]),
+				     UMAC_MPD_PW_MS);
+		bcmgenet_umac_writel(priv, get_unaligned_be32(&wol->sopass[2]),
+				     UMAC_MPD_PW_LS);
+		reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
+		reg |= MPD_PW_EN;
+		bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
+	}
+
+	/* Flag the device and relevant IRQ as wakeup capable */
+	if (wol->wolopts) {
+		device_set_wakeup_enable(kdev, 1);
+		enable_irq_wake(priv->wol_irq);
+		priv->wol_irq_disabled = 0;
+	} else {
+		device_set_wakeup_enable(kdev, 0);
+		/* Avoid unbalanced disable_irq_wake calls */
+		if (!priv->wol_irq_disabled)
+			disable_irq_wake(priv->wol_irq);
+		priv->wol_irq_disabled = 1;
+	}
+
+	priv->wolopts = wol->wolopts;
+
+	return 0;
+}
+
+static int bcmgenet_poll_wol_status(struct bcmgenet_priv *priv)
+{
+	struct net_device *dev = priv->dev;
+	int retries = 0;
+
+	while (!(bcmgenet_rbuf_readl(priv, RBUF_STATUS)
+		& RBUF_STATUS_WOL)) {
+		retries++;
+		if (retries > 5) {
+			netdev_crit(dev, "polling wol mode timeout\n");
+			return -ETIMEDOUT;
+		}
+		mdelay(1);
+	}
+
+	return retries;
+}
+
+int bcmgenet_wol_power_down_cfg(struct bcmgenet_priv *priv,
+				enum bcmgenet_power_mode mode)
+{
+	struct net_device *dev = priv->dev;
+	u32 cpu_mask_clear;
+	int retries = 0;
+	u32 reg;
+
+	if (mode != GENET_POWER_WOL_MAGIC) {
+		netif_err(priv, wol, dev, "unsupported mode: %d\n", mode);
+		return -EINVAL;
+	}
+
+	/* disable RX */
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
+	reg &= ~CMD_RX_EN;
+	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	mdelay(10);
+
+	reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
+	reg |= MPD_EN;
+	bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
+
+	/* Do not leave UniMAC in MPD mode only */
+	retries = bcmgenet_poll_wol_status(priv);
+	if (retries < 0) {
+		reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
+		reg &= ~MPD_EN;
+		bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
+		return retries;
+	}
+
+	netif_dbg(priv, wol, dev, "MPD WOL-ready status set after %d msec\n",
+		  retries);
+
+	/* Enable CRC forward */
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
+	priv->crc_fwd_en = 1;
+	reg |= CMD_CRC_FWD;
+
+	/* Receiver must be enabled for WOL MP detection */
+	reg |= CMD_RX_EN;
+	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+
+	if (priv->hw_params->flags & GENET_HAS_EXT) {
+		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
+		reg &= ~EXT_ENERGY_DET_MASK;
+		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	}
+
+	/* Enable the MPD interrupt */
+	cpu_mask_clear = UMAC_IRQ_MPD_R;
+
+	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear, INTRL2_CPU_MASK_CLEAR);
+
+	return 0;
+}
+
+void bcmgenet_wol_power_up_cfg(struct bcmgenet_priv *priv,
+			       enum bcmgenet_power_mode mode)
+{
+	u32 cpu_mask_set;
+	u32 reg;
+
+	if (mode != GENET_POWER_WOL_MAGIC) {
+		netif_err(priv, wol, priv->dev, "invalid mode: %d\n", mode);
+		return;
+	}
+
+	reg = bcmgenet_umac_readl(priv, UMAC_MPD_CTRL);
+	reg &= ~MPD_EN;
+	bcmgenet_umac_writel(priv, reg, UMAC_MPD_CTRL);
+
+	/* Disable CRC Forward */
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
+	reg &= ~CMD_CRC_FWD;
+	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	priv->crc_fwd_en = 0;
+
+	/* Stop monitoring magic packet IRQ */
+	cpu_mask_set = UMAC_IRQ_MPD_R;
+
+	/* Stop monitoring magic packet IRQ */
+	bcmgenet_intrl2_0_writel(priv, cpu_mask_set, INTRL2_CPU_MASK_SET);
+}
-- 
1.9.1
