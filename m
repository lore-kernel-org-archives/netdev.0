From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.30 3/3] gianfar: Fix stashing support
Date: Tue,  3 Feb 2009 19:17:03 -0600
Message-ID: <1233710223-17808-5-git-send-email-afleming@freescale.com>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
 <1233710223-17808-2-git-send-email-afleming@freescale.com>
 <1233710223-17808-3-git-send-email-afleming@freescale.com>
 <1233710223-17808-4-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57450 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbZBDBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:17:22 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n141H5re004712
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:17:05 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n141H4VH021699
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 19:17:04 -0600 (CST)
In-Reply-To: <1233710223-17808-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stashing is only supported on the 85xx (e500-based) SoCs.  The 83xx and 86xx
chips don't have a proper cache for this.  U-Boot has been updated to add
stashing properties to the device tree nodes of gianfar devices on 85xx.  So
now we modify Linux to keep stashing off unless those properties are there.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 Documentation/powerpc/dts-bindings/fsl/tsec.txt |    6 ++++++
 drivers/net/gianfar.c                           |   23 +++++++++++++++++++++++
 drivers/net/gianfar_sysfs.c                     |   12 +++++++++---
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
index 7fa4b27..edb7ae1 100644
--- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
@@ -56,6 +56,12 @@ Properties:
     hardware.
   - fsl,magic-packet : If present, indicates that the hardware supports
     waking up via magic packet.
+  - bd-stash : If present, indicates that the hardware supports stashing
+    buffer descriptors in the L2.
+  - rx-stash-len : Denotes the number of bytes of a received buffer to stash
+    in the L2.
+  - rx-stash-idx : Denotes the index of the first byte from the received
+    buffer to stash in the L2.
 
 Example:
 	ethernet@24000 {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index e822701..08843b4 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -166,6 +166,9 @@ static int gfar_of_init(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct device_node *np = priv->node;
 	char bus_name[MII_BUS_ID_SIZE];
+	const u32 *stash;
+	const u32 *stash_len;
+	const u32 *stash_idx;
 
 	if (!np || !of_device_is_available(np))
 		return -ENODEV;
@@ -195,6 +198,26 @@ static int gfar_of_init(struct net_device *dev)
 		}
 	}
 
+	stash = of_get_property(np, "bd-stash", NULL);
+
+	if(stash) {
+		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BD_STASHING;
+		priv->bd_stash_en = 1;
+	}
+
+	stash_len = of_get_property(np, "rx-stash-len", NULL);
+
+	if (stash_len)
+		priv->rx_stash_size = *stash_len;
+
+	stash_idx = of_get_property(np, "rx-stash-idx", NULL);
+
+	if (stash_idx)
+		priv->rx_stash_index = *stash_idx;
+
+	if (stash_len || stash_idx)
+		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BUF_STASHING;
+
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
 		memcpy(dev->dev_addr, mac_addr, MAC_ADDR_LEN);
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 782c201..248ecc5 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -53,6 +53,9 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	u32 temp;
 	unsigned long flags;
 
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BD_STASHING))
+		return count;
+
 	/* Find out the new setting */
 	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
 		new_setting = 1;
@@ -100,6 +103,9 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 	u32 temp;
 	unsigned long flags;
 
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BUF_STASHING))
+		return count;
+
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (length > priv->rx_buffer_size)
 		goto out;
@@ -152,6 +158,9 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	u32 temp;
 	unsigned long flags;
 
+	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_BUF_STASHING))
+		return count;
+
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (index > priv->rx_stash_size)
 		goto out;
@@ -293,12 +302,9 @@ void gfar_init_sysfs(struct net_device *dev)
 	int rc;
 
 	/* Initialize the default values */
-	priv->rx_stash_size = DEFAULT_STASH_LENGTH;
-	priv->rx_stash_index = DEFAULT_STASH_INDEX;
 	priv->fifo_threshold = DEFAULT_FIFO_TX_THR;
 	priv->fifo_starve = DEFAULT_FIFO_TX_STARVE;
 	priv->fifo_starve_off = DEFAULT_FIFO_TX_STARVE_OFF;
-	priv->bd_stash_en = DEFAULT_BD_STASH;
 
 	/* Create our sysfs files */
 	rc = device_create_file(&dev->dev, &dev_attr_bd_stash);
-- 
1.5.4.GIT

