From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] gianfar: rx parser
Date: Fri, 15 Jul 2011 21:51:34 +0200
Message-ID: <20110715195133.GA3499@minipsycho.orion>
References: <1310728141.28792.10.camel@DENEC1DT0191>
 <20110715.080610.256697325487445331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.belden@googlemail.com, netdev@vger.kernel.org,
	sandeep.kumar@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157Ab1GOTvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 15:51:42 -0400
Content-Disposition: inline
In-Reply-To: <20110715.080610.256697325487445331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Jul 15, 2011 at 05:06:10PM CEST, davem@davemloft.net wrote:
>From: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
>Date: Fri, 15 Jul 2011 13:09:01 +0200
>
>> +	struct gfar __iomem *regs =3D NULL;
>> +	u32 tempval =3D 0;
>> +=09
>> +	regs =3D priv->gfargrp[0].regs;
>
>There is no reason to initialize the variable 'regs' to NULL only to
>initialize it to something else 2 lines later.
>
>The initial 'tempval' initialization is also redundant, for the same
>reason.


fixed:

=46rom: Sebastian P=F6hn <sebastian.belden@googlemail.com>
Subject: [patch net-next-2.6] gianfar: rx parser

Only let the rx parser be enabled if it is necessary (if VLAN extractio=
n,
IP or TCP checksumming or the rx queue filer are enabled). Otherwise
disable it.

The new routine gfar_check_rx_parser_mode should be run after every
change on this features and will enable/disable the parser as necessary=
=2E

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---
 drivers/net/gianfar.c |   24 +++++++++++++++++++-----
 drivers/net/gianfar.h |    3 ++-
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3321d71..d265c6e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2287,6 +2287,23 @@ static int gfar_set_mac_address(struct net_devic=
e *dev)
 	return 0;
 }
=20
+/* Check if rx parser should be activated */
+void gfar_check_rx_parser_mode(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs;
+	u32 tempval;
+
+	regs =3D priv->gfargrp[0].regs;
+
+	tempval =3D gfar_read(&regs->rctrl);
+	/* If parse is no longer required, then disable parser */
+	if (tempval & RCTRL_REQ_PARSER)
+		tempval |=3D RCTRL_PRSDEP_INIT;
+	else
+		tempval &=3D ~RCTRL_PRSDEP_INIT;
+	gfar_write(&regs->rctrl, tempval);
+}
+
=20
 /* Enables and disables VLAN insertion/extraction */
 static void gfar_vlan_rx_register(struct net_device *dev,
@@ -2323,12 +2340,9 @@ static void gfar_vlan_rx_register(struct net_dev=
ice *dev,
 		/* Disable VLAN tag extraction */
 		tempval =3D gfar_read(&regs->rctrl);
 		tempval &=3D ~RCTRL_VLEX;
-		/* If parse is no longer required, then disable parser */
-		if (tempval & RCTRL_REQ_PARSER)
-			tempval |=3D RCTRL_PRSDEP_INIT;
-		else
-			tempval &=3D ~RCTRL_PRSDEP_INIT;
 		gfar_write(&regs->rctrl, tempval);
+
+		gfar_check_rx_parser_mode(priv);
 	}
=20
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
@@ -1182,6 +1182,7 @@ extern void gfar_configure_coalescing(struct gfar=
_private *priv,
 		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
 int gfar_set_features(struct net_device *dev, u32 features);
+extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
=20
 extern const struct ethtool_ops gfar_ethtool_ops;
=20
--=20
1.7.6

