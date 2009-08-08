From: Yong Zhang <yong.zhang0@gmail.com>
Subject: [RESEND PATCH] gianfar: keep vlan related state when restart
Date: Sat,  8 Aug 2009 10:36:52 +0800
Message-ID: <1249699012-26379-1-git-send-email-yong.zhang0@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, afleming@freescale.com,
	dai.haruki@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:29464 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbZHHChB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 22:37:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vlan has been enabled. ifdown followed by ifup will lost hardware
related state.

Also remove duplicated operation in gfar_vlan_rx_register().

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
---
 drivers/net/gianfar.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f8ffcbf..e212f2c 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -936,6 +936,7 @@ int startup_gfar(struct net_device *dev)
 	struct gfar __iomem *regs = priv->regs;
 	int err = 0;
 	u32 rctrl = 0;
+	u32 tctrl = 0;
 	u32 attrs = 0;
 
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
@@ -1111,11 +1112,19 @@ int startup_gfar(struct net_device *dev)
 		rctrl |= RCTRL_PADDING(priv->padding);
 	}
 
+	/* keep vlan related bits if it's enabled */
+	if (priv->vlgrp) {
+		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
+		tctrl |= TCTRL_VLINS;
+	}
+
 	/* Init rctrl based on our settings */
 	gfar_write(&priv->regs->rctrl, rctrl);
 
 	if (dev->features & NETIF_F_IP_CSUM)
-		gfar_write(&priv->regs->tctrl, TCTRL_INIT_CSUM);
+		tctrl |= TCTRL_INIT_CSUM;
+
+	gfar_write(&priv->regs->tctrl, tctrl);
 
 	/* Set the extraction length and index */
 	attrs = ATTRELI_EL(priv->rx_stash_size) |
@@ -1450,7 +1459,6 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 
 		/* Enable VLAN tag extraction */
 		tempval = gfar_read(&priv->regs->rctrl);
-		tempval |= RCTRL_VLEX;
 		tempval |= (RCTRL_VLEX | RCTRL_PRSDEP_INIT);
 		gfar_write(&priv->regs->rctrl, tempval);
 	} else {
-- 
1.6.0.4

