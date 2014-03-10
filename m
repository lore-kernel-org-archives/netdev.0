From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH net] eth: fec: Fix lost promiscuous mode after reconnecting
 cable
Date: Mon, 10 Mar 2014 19:18:56 +0100
Message-ID: <531E0210.1090009@i2se.com>
References: <5318400C.8060508@i2se.com>	<CAOMZO5B-1koJdQRdE7SQU07K9McZZaiPAa+rookdxVL5vvPJvA@mail.gmail.com> <CAHrpEqQewTSAWveoGdRvUF-R-uYAC7ZDAAYDH8DKg8EgmYpM0w@mail.gmail.com> <f7c8b4dab2114552b919310c2a5bb444@BLUPR03MB373.namprd03.prod.outlook.com> <5319ED04.9070003@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.arm.linux.org.uk"
	<linux-arm-kernel@lists.arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Sascha Hauer <kernel@pengutronix.de>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Frank Li <lznuaa@gmail.com>, Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.130]:49171 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbaCJSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 14:19:34 -0400
In-Reply-To: <5319ED04.9070003@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the Freescale i.MX28 fec is in promiscuous mode and network cable is
reconnected then the promiscuous mode get lost. The problem is caused
by a too soon call of set_multicast_list to re-enable promisc mode.
The FEC_R_CNTRL register changes are overwritten by fec_restart.

This patch fixes this by moving the call behind the init of FEC_R_CNTRL
register in fec_restart.

Successful tested on a i.MX28 board.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 479a7cb..03a3513 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -528,13 +528,6 @@ fec_restart(struct net_device *ndev, int duplex)
     /* Clear any outstanding interrupt. */
     writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
-    /* Setup multicast filter. */
-    set_multicast_list(ndev);
-#ifndef CONFIG_M5272
-    writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
-    writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-#endif
-
     /* Set maximum receive buffer size. */
     writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
 
@@ -655,6 +648,13 @@ fec_restart(struct net_device *ndev, int duplex)
 
     writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
+    /* Setup multicast filter. */
+    set_multicast_list(ndev);
+#ifndef CONFIG_M5272
+    writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+    writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
+#endif
+
     if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
         /* enable ENET endian swap */
         ecntl |= (1 << 8);
-- 
1.7.10.4
