From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/3] gianfar: Enable eTSEC-A002 erratum w/a for all parts
Date: Wed, 9 Oct 2013 20:20:40 +0300
Message-ID: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:53442
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756362Ab3JIRZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:25:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A002 is still in "no plans to fix" state, and applies to all
the current P1/P2 parts as well, so it's resonable to enable
its workaround by default, for all the soc's with etsec.
The impact of not enabling this workaround for affected parts
is that under certain conditons (runt frames or even frames
with RX error detected at PHY level) during controller reset,
the controller might fail to indicate Rx reset (GRS) completion.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index c4eaade..db5fc7b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -947,6 +947,9 @@ static void gfar_detect_errata(struct gfar_private *priv)
 	unsigned int mod = (svr >> 16) & 0xfff6; /* w/o E suffix */
 	unsigned int rev = svr & 0xffff;
 
+	/* no plans to fix */
+	priv->errata |= GFAR_ERRATA_A002;
+
 	/* MPC8313 Rev 2.0 and higher; All MPC837x */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev >= 0x0020) ||
 	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
@@ -957,11 +960,6 @@ static void gfar_detect_errata(struct gfar_private *priv)
 	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_76;
 
-	/* MPC8313 and MPC837x all rev */
-	if ((pvr == 0x80850010 && mod == 0x80b0) ||
-	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
-		priv->errata |= GFAR_ERRATA_A002;
-
 	/* MPC8313 Rev < 2.0, MPC8548 rev 2.0 */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020) ||
 	    (pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
@@ -1599,7 +1597,7 @@ static int __gfar_is_rx_idle(struct gfar_private *priv)
 	/* Normaly TSEC should not hang on GRS commands, so we should
 	 * actually wait for IEVENT_GRSC flag.
 	 */
-	if (likely(!gfar_has_errata(priv, GFAR_ERRATA_A002)))
+	if (!gfar_has_errata(priv, GFAR_ERRATA_A002))
 		return 0;
 
 	/* Read the eTSEC register at offset 0xD1C. If bits 7-14 are
-- 
1.7.11.7
