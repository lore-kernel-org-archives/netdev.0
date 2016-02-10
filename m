From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next v2] sxgbe: remove unused code
Date: Tue,  9 Feb 2016 20:47:17 -0700
Message-ID: <1455076037-10485-1-git-send-email-sakiwit@gmail.com>
References: <56B275FA.40608@osg.samsung.com>
Cc: netdev@vger.kernel.org, shuahkh@osg.samsung.com,
	shuahkhan@gmail.com, julia.lawall@lip6.fr,
	Byungho An <bh74.an@samsung.com>,
	Girish K S <ks.giri@samsung.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35213 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317AbcBJDsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 22:48:53 -0500
Received: by mail-pf0-f194.google.com with SMTP id 66so357649pfe.2
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 19:48:53 -0800 (PST)
In-Reply-To: <56B275FA.40608@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

Remove the unused code of sxgbe_xpcs.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Byungho An <bh74.an@samsung.com>
Cc: Girish K S <ks.giri@samsung.com>
Link: http://lkml.kernel.org/r/alpine.DEB.2.10.1601191918470.2531@hadrien
---
v2:
Rewrite the changelog per request by Shuah Khan. Add Suggested-by and
Link tags as well.

v1:
We may use "--ignore FILE_PATH_CHANGES" to suppress checkpatch warning.

 drivers/net/ethernet/samsung/sxgbe/Makefile     |  2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c | 91 -------------------------
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h | 38 -----------
 3 files changed, 1 insertion(+), 130 deletions(-)
 delete mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
 delete mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h

diff --git a/drivers/net/ethernet/samsung/sxgbe/Makefile b/drivers/net/ethernet/samsung/sxgbe/Makefile
index dcc80b9d4370..31e968561d5c 100644
--- a/drivers/net/ethernet/samsung/sxgbe/Makefile
+++ b/drivers/net/ethernet/samsung/sxgbe/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
 samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
 		sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
-		sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
+		sxgbe_ethtool.o $(samsung-sxgbe-y)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
deleted file mode 100644
index 51c32194ba88..000000000000
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
+++ /dev/null
@@ -1,91 +0,0 @@
-/* 10G controller driver for Samsung SoCs
- *
- * Copyright (C) 2013 Samsung Electronics Co., Ltd.
- *		http://www.samsung.com
- *
- * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#include <linux/bitops.h>
-#include <linux/kernel.h>
-#include <linux/netdevice.h>
-#include <linux/phy.h>
-#include "sxgbe_common.h"
-#include "sxgbe_xpcs.h"
-
-static int sxgbe_xpcs_read(struct net_device *ndev, unsigned int reg)
-{
-	u32 value;
-	struct sxgbe_priv_data *priv = netdev_priv(ndev);
-
-	value = readl(priv->ioaddr + XPCS_OFFSET + reg);
-
-	return value;
-}
-
-static int sxgbe_xpcs_write(struct net_device *ndev, int reg, int data)
-{
-	struct sxgbe_priv_data *priv = netdev_priv(ndev);
-
-	writel(data, priv->ioaddr + XPCS_OFFSET + reg);
-
-	return 0;
-}
-
-int sxgbe_xpcs_init(struct net_device *ndev)
-{
-	u32 value;
-
-	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
-	/* 10G XAUI mode */
-	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
-	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
-	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, value | BIT(13));
-	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
-
-	do {
-		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
-	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) == XPCS_QSEQ_STATE_STABLE);
-
-	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
-	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
-
-	do {
-		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
-	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
-
-	return 0;
-}
-
-int sxgbe_xpcs_init_1G(struct net_device *ndev)
-{
-	int value;
-
-	/* 10GBASE-X PCS (1G) mode */
-	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
-	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
-	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
-	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(13));
-
-	value = sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
-	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(6));
-	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value & ~BIT(13));
-	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
-	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
-
-	do {
-		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
-	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
-
-	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
-	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
-
-	/* Auto Negotiation cluase 37 enable */
-	value = sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
-	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(12));
-
-	return 0;
-}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
deleted file mode 100644
index 6b26a50724d3..000000000000
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
+++ /dev/null
@@ -1,38 +0,0 @@
-/* 10G controller driver for Samsung SoCs
- *
- * Copyright (C) 2013 Samsung Electronics Co., Ltd.
- *		http://www.samsung.com
- *
- * Author: Byungho An <bh74.an@samsung.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-#ifndef __SXGBE_XPCS_H__
-#define __SXGBE_XPCS_H__
-
-/* XPCS Registers */
-#define XPCS_OFFSET			0x1A060000
-#define SR_PCS_MMD_CONTROL1		0x030000
-#define SR_PCS_CONTROL2			0x030007
-#define VR_PCS_MMD_XAUI_MODE_CONTROL	0x038004
-#define VR_PCS_MMD_DIGITAL_STATUS	0x038010
-#define SR_MII_MMD_CONTROL		0x1F0000
-#define SR_MII_MMD_AN_ADV		0x1F0004
-#define SR_MII_MMD_AN_LINK_PARTNER_BA	0x1F0005
-#define VR_MII_MMD_AN_CONTROL		0x1F8001
-#define VR_MII_MMD_AN_INT_STATUS	0x1F8002
-
-#define XPCS_QSEQ_STATE_STABLE		0x10
-#define XPCS_QSEQ_STATE_MPLLOFF		0x1c
-#define XPCS_TYPE_SEL_R			0x00
-#define XPCS_TYPE_SEL_X			0x01
-#define XPCS_TYPE_SEL_W			0x02
-#define XPCS_XAUI_MODE			0x00
-#define XPCS_RXAUI_MODE			0x01
-
-int sxgbe_xpcs_init(struct net_device *ndev);
-int sxgbe_xpcs_init_1G(struct net_device *ndev);
-
-#endif /* __SXGBE_XPCS_H__ */
