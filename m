From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH net resend] eth: fec: Fix lost promiscuous mode after reconnecting cable
Date: Wed, 12 Mar 2014 11:28:19 +0100
Message-ID: <1394620099-4509-1-git-send-email-stefan.wahren@i2se.com>
References: <20140311.224834.40412164133780234.davem@davemloft.net>
Cc: fugang.duan@freescale.com, lznuaa@gmail.com, festevam@gmail.com,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	Fabio.Estevam@freescale.com, Frank.Li@freescale.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.130]:57371 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbaCLK3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 06:29:19 -0400
In-Reply-To: <20140311.224834.40412164133780234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the Freescale fec is in promiscuous mode and network cable is
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

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 479a7cb..03a3513 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -528,13 +528,6 @@ fec_restart(struct net_device *ndev, int duplex)
 	/* Clear any outstanding interrupt. */
 	writel(0xffc00000, fep->hwp + FEC_IEVENT);
 
-	/* Setup multicast filter. */
-	set_multicast_list(ndev);
-#ifndef CONFIG_M5272
-	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-#endif
-
 	/* Set maximum receive buffer size. */
 	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
 
@@ -655,6 +648,13 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
+	/* Setup multicast filter. */
+	set_multicast_list(ndev);
+#ifndef CONFIG_M5272
+	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
+#endif
+
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
 		/* enable ENET endian swap */
 		ecntl |= (1 << 8);
-- 
1.7.10.4
