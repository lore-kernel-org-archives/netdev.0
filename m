From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] gianfar: rx parser
Date: Fri, 15 Jul 2011 13:09:01 +0200
Message-ID: <1310728141.28792.10.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sandeep.kumar@freescale.com
To: Linux Netdev <netdev@vger.kernel.org>, jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:44987 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab1GOLJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 07:09:05 -0400
Received: by fxd18 with SMTP id 18so2701479fxd.11
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 04:09:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only let the rx parser be enabled if it is necessary (if VLAN extracrtion, IP or TCP checksumming or the rx queue filer are enabled). Otherwise disable it.

The new routine gfar_check_rx_parser_mode should be runt after every change on this features and will enable/disable the parser as necessary.

I will send a patch for the rx queue filer the next days.



Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 drivers/net/gianfar.c |   25 ++++++++++++++++++++-----
 drivers/net/gianfar.h |    3 ++-
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3321d71..6da3712 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2287,6 +2287,23 @@ static int gfar_set_mac_address(struct net_device *dev)
 	return 0;
 }
 
+/* Check if rx parser should be activated */
+void gfar_check_rx_parser_mode(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs = NULL;
+	u32 tempval = 0;
+	
+	regs = priv->gfargrp[0].regs;
+	
+	tempval = gfar_read(&regs->rctrl);
+	/* If parse is no longer required, then disable parser */
+	if (tempval & RCTRL_REQ_PARSER)
+		tempval |= RCTRL_PRSDEP_INIT;
+	else
+		tempval &= ~RCTRL_PRSDEP_INIT;
+	gfar_write(&regs->rctrl, tempval);
+}
+
 
 /* Enables and disables VLAN insertion/extraction */
 static void gfar_vlan_rx_register(struct net_device *dev,
@@ -2323,12 +2340,10 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 		/* Disable VLAN tag extraction */
 		tempval = gfar_read(&regs->rctrl);
 		tempval &= ~RCTRL_VLEX;
-		/* If parse is no longer required, then disable parser */
-		if (tempval & RCTRL_REQ_PARSER)
-			tempval |= RCTRL_PRSDEP_INIT;
-		else
-			tempval &= ~RCTRL_PRSDEP_INIT;
 		gfar_write(&regs->rctrl, tempval);
+
+		gfar_check_rx_parser_mode(priv);
+		
 	}
 
 	gfar_change_mtu(dev, dev->mtu);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 27499c6..87c1d86 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -286,7 +286,7 @@ extern const char gfar_driver_version[];
 #define RCTRL_PROM		0x00000008
 #define RCTRL_EMEN		0x00000002
 #define RCTRL_REQ_PARSER	(RCTRL_VLEX | RCTRL_IPCSEN | \
-				 RCTRL_TUCSEN)
+				 RCTRL_TUCSEN | RCTRL_FILREN)
 #define RCTRL_CHECKSUMMING	(RCTRL_IPCSEN | RCTRL_TUCSEN | \
 				RCTRL_PRSDEP_INIT)
 #define RCTRL_EXTHASH		(RCTRL_GHTX)
@@ -1182,6 +1182,7 @@ extern void gfar_configure_coalescing(struct gfar_private *priv,
 		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, u32 features);
+extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
 
 extern const struct ethtool_ops gfar_ethtool_ops;
 

 


