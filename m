From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 01/47] gianfar: rx parser
Date: Wed, 20 Jul 2011 17:01:11 +0200
Message-ID: <20110720150110.GA2250@minipsycho.brq.redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab1GTPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 11:01:14 -0400
Content-Disposition: inline
In-Reply-To: <1311173689-17419-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ugh this was already applied on net-2.6. Dave please sync and ignore
this. Sorry.

Thanks.

Jirka

Wed, Jul 20, 2011 at 04:54:03PM CEST, jpirko@redhat.com wrote:
>Only let the rx parser be enabled if it is necessary (if VLAN extraction,
>IP or TCP checksumming or the rx queue filer are enabled). Otherwise
>disable it.
>
>The new routine gfar_check_rx_parser_mode should be run after every
>change on this features and will enable/disable the parser as necessary.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
>---
> drivers/net/gianfar.c |   24 +++++++++++++++++++-----
> drivers/net/gianfar.h |    3 ++-
> 2 files changed, 21 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
>index 3321d71..d265c6e 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -2287,6 +2287,23 @@ static int gfar_set_mac_address(struct net_device *dev)
> 	return 0;
> }
> 
>+/* Check if rx parser should be activated */
>+void gfar_check_rx_parser_mode(struct gfar_private *priv)
>+{
>+	struct gfar __iomem *regs;
>+	u32 tempval;
>+
>+	regs = priv->gfargrp[0].regs;
>+
>+	tempval = gfar_read(&regs->rctrl);
>+	/* If parse is no longer required, then disable parser */
>+	if (tempval & RCTRL_REQ_PARSER)
>+		tempval |= RCTRL_PRSDEP_INIT;
>+	else
>+		tempval &= ~RCTRL_PRSDEP_INIT;
>+	gfar_write(&regs->rctrl, tempval);
>+}
>+
> 
> /* Enables and disables VLAN insertion/extraction */
> static void gfar_vlan_rx_register(struct net_device *dev,
>@@ -2323,12 +2340,9 @@ static void gfar_vlan_rx_register(struct net_device *dev,
> 		/* Disable VLAN tag extraction */
> 		tempval = gfar_read(&regs->rctrl);
> 		tempval &= ~RCTRL_VLEX;
>-		/* If parse is no longer required, then disable parser */
>-		if (tempval & RCTRL_REQ_PARSER)
>-			tempval |= RCTRL_PRSDEP_INIT;
>-		else
>-			tempval &= ~RCTRL_PRSDEP_INIT;
> 		gfar_write(&regs->rctrl, tempval);
>+
>+		gfar_check_rx_parser_mode(priv);
> 	}
> 
> 	gfar_change_mtu(dev, dev->mtu);
>diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
>index 27499c6..87c1d86 100644
>--- a/drivers/net/gianfar.h
>+++ b/drivers/net/gianfar.h
>@@ -286,7 +286,7 @@ extern const char gfar_driver_version[];
> #define RCTRL_PROM		0x00000008
> #define RCTRL_EMEN		0x00000002
> #define RCTRL_REQ_PARSER	(RCTRL_VLEX | RCTRL_IPCSEN | \
>-				 RCTRL_TUCSEN)
>+				 RCTRL_TUCSEN | RCTRL_FILREN)
> #define RCTRL_CHECKSUMMING	(RCTRL_IPCSEN | RCTRL_TUCSEN | \
> 				RCTRL_PRSDEP_INIT)
> #define RCTRL_EXTHASH		(RCTRL_GHTX)
>@@ -1182,6 +1182,7 @@ extern void gfar_configure_coalescing(struct gfar_private *priv,
> 		unsigned long tx_mask, unsigned long rx_mask);
> void gfar_init_sysfs(struct net_device *dev);
> int gfar_set_features(struct net_device *dev, u32 features);
>+extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
> 
> extern const struct ethtool_ops gfar_ethtool_ops;
> 
>-- 
>1.7.6
>
