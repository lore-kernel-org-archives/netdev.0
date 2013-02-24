From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net] gianfar: fix compile fail for NET_POLL=y due to struct packing
Date: Sun, 24 Feb 2013 10:38:31 -0500
Message-ID: <1361720311-13267-1-git-send-email-paul.gortmaker@windriver.com>
References: <1361717023.16950.12.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Jianhua Xie <jianhua.xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63014 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757294Ab3BXPkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 10:40:15 -0500
In-Reply-To: <1361717023.16950.12.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ee873fda3bec7c668407b837fc5519eb961fcd37 ("gianfar: Pack struct
gfar_priv_grp into three cachelines") moved the irq number and names
off into a separate struct and created accessors for them.  However
it was never tested with NET_POLL enabled, and so some conversions
that were simply overlooked went undetected until now.

Make the netpoll ones also use the gfar_irq() accessors.

Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Cc: Jianhua Xie <jianhua.xie@freescale.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[compile tested for sbc8548 with NET_POLL=y]

 drivers/net/ethernet/freescale/gianfar.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4b5e8a6..d2c5441 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2906,21 +2906,23 @@ static void gfar_netpoll(struct net_device *dev)
 	/* If the device has multiple interrupts, run tx/rx */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		for (i = 0; i < priv->num_grps; i++) {
-			disable_irq(priv->gfargrp[i].interruptTransmit);
-			disable_irq(priv->gfargrp[i].interruptReceive);
-			disable_irq(priv->gfargrp[i].interruptError);
-			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-				       &priv->gfargrp[i]);
-			enable_irq(priv->gfargrp[i].interruptError);
-			enable_irq(priv->gfargrp[i].interruptReceive);
-			enable_irq(priv->gfargrp[i].interruptTransmit);
+			struct gfar_priv_grp *grp = &priv->gfargrp[i];
+
+			disable_irq(gfar_irq(grp, TX)->irq);
+			disable_irq(gfar_irq(grp, RX)->irq);
+			disable_irq(gfar_irq(grp, ER)->irq);
+			gfar_interrupt(gfar_irq(grp, TX)->irq, grp);
+			enable_irq(gfar_irq(grp, ER)->irq);
+			enable_irq(gfar_irq(grp, RX)->irq);
+			enable_irq(gfar_irq(grp, TX)->irq);
 		}
 	} else {
 		for (i = 0; i < priv->num_grps; i++) {
-			disable_irq(priv->gfargrp[i].interruptTransmit);
-			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-				       &priv->gfargrp[i]);
-			enable_irq(priv->gfargrp[i].interruptTransmit);
+			struct gfar_priv_grp *grp = &priv->gfargrp[i];
+
+			disable_irq(gfar_irq(grp, TX)->irq);
+			gfar_interrupt(gfar_irq(grp, TX)->irq, grp);
+			enable_irq(gfar_irq(grp, TX)->irq);
 		}
 	}
 }
-- 
1.8.1.2
