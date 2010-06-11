From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Subject: [PATCH] gianfar: Fix setup of RX time stamping
Date: Fri, 11 Jun 2010 13:49:05 +0200
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3F03D8C46@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'Anton Vorontsov'" <avorontsov@mvista.com>,
	Richard Cochran <richard.cochran@omicron.at>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@ozlabs.org'" <linuxppc-dev@ozlabs.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:57508 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760230Ab0FKMdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:33:43 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously the RCTRL_TS_ENABLE bit was set unconditionally. However, if
the RCTRL_TS_ENABLE is set without TMR_CTRL[TE], the driver does not work
properly on some boards (Anton had problems with the MPC8313ERDB and
MPC8568EMDS).

With this patch the bit will only be set if requested from user space
with the SIOCSHWTSTAMP ioctl command, meaning that time stamping is
disabled during normal operation. Users who are not interested in time
stamps will not experience problems with buggy CPU revisions or
performance drops any more.

The setting of TMR_CTRL[TE] is still up to the user. This is considered
safe because users wanting HW timestamps must initialize the eTSEC clock
first anyway, e.g. with the recently submitted PTP clock driver.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/gianfar.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 46c69cd..227b628 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -381,10 +381,14 @@ static void gfar_init_mac(struct net_device *ndev)
 	/* Insert receive time stamps into padding alignment bytes */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER) {
 		rctrl &= ~RCTRL_PAL_MASK;
-		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE | RCTRL_PADDING(8);
+		rctrl |= RCTRL_PADDING(8);
 		priv->padding = 8;
 	}
 
+	/* Enable HW time stamping if requested from user space */
+	if (priv->hwts_rx_en)
+		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
+
 	/* keep vlan related bits if it's enabled */
 	if (priv->vlgrp) {
 		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
@@ -747,7 +751,8 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 			FSL_GIANFAR_DEV_HAS_CSUM |
 			FSL_GIANFAR_DEV_HAS_VLAN |
 			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
-			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
+			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
+			FSL_GIANFAR_DEV_HAS_TIMER;
 
 	ctype = of_get_property(np, "phy-connection-type", NULL);
 
@@ -805,12 +810,20 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
-		priv->hwts_rx_en = 0;
+		if (priv->hwts_rx_en) {
+			stop_gfar(netdev);
+			priv->hwts_rx_en = 0;
+			startup_gfar(netdev);
+		}
 		break;
 	default:
 		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
 			return -ERANGE;
-		priv->hwts_rx_en = 1;
+		if (!priv->hwts_rx_en) {
+			stop_gfar(netdev);
+			priv->hwts_rx_en = 1;
+			startup_gfar(netdev);
+		}
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
 	}
-- 
1.6.3.3
