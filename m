From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 2/4] gianfar: Don't enable the Filer w/o the Parser
Date: Fri, 23 Oct 2015 11:41:59 +0300
Message-ID: <1445589721-26206-3-git-send-email-claudiu.manoil@freescale.com>
References: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:24500
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751959AbbJWImT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 04:42:19 -0400
In-Reply-To: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under one unusual circumstance it's possible to wrongly set
FILREN without enabling PRSDEP as well in the RCTRL register,
against the hardware specifications.  With the default config
this does not happen because the default Rx offloads (Rx csum
and Rx VLAN) properly enable PRSDEP.  But if anyone disables
all these offloads (via ethtool), we get a wrong configuration
were the Rx flow classification and hashing, and other Filer
based features (e.g. wake-on-filer interrupt) won't work.
This patch fixes the issue.
Also, account for Rx FCB insertion which happens every time
PRSDEP is set.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 710715f..939ed8f 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -341,7 +341,7 @@ static void gfar_rx_offload_en(struct gfar_private *priv)
 	if (priv->ndev->features & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX))
 		priv->uses_rxfcb = 1;
 
-	if (priv->hwts_rx_en)
+	if (priv->hwts_rx_en || priv->rx_filer_enable)
 		priv->uses_rxfcb = 1;
 }
 
@@ -351,7 +351,7 @@ static void gfar_mac_rx_config(struct gfar_private *priv)
 	u32 rctrl = 0;
 
 	if (priv->rx_filer_enable) {
-		rctrl |= RCTRL_FILREN;
+		rctrl |= RCTRL_FILREN | RCTRL_PRSDEP_INIT;
 		/* Program the RIR0 reg with the required distribution */
 		if (priv->poll_mode == GFAR_SQ_POLLING)
 			gfar_write(&regs->rir0, DEFAULT_2RXQ_RIR0);
-- 
1.7.11.7
