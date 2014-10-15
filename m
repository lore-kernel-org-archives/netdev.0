From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net] gianfar: Add FCS to rx buffer size (fix)
Date: Wed, 15 Oct 2014 19:11:46 +0300
Message-ID: <1413389506-19172-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kristian Otnes <kotnes@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0109.outbound.protection.outlook.com ([157.56.111.109]:10297
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751392AbaJOQMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 12:12:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For each Rx frame the eTSEC writes its FCS (Frame Check Sequence)
to the Rx buffer.

The eTSEC h/w manual states in the "Receive Buffer Descriptor Field
Descriptions" table:
"Data length is the number of octets written by the eTSEC into this BD's
data buffer if L is cleared (the value is equal to MRBLR), or, if L is
set, the length of the frame including *CRC*, FCB (if RCTRL[PRSDEP > 00),
preamble (if MACCFG2[PreAmRxEn]=1), time stamp (if RCTRL[TS] = 1) and
any padding (RCTRL[PAL])."

Though the FCS bytes are removed by the driver before passing the skb
to the net stack, the Rx buffer size computation does not currently
take into account the FCS bytes (4 bytes).
Because the Rx buffer size is multiple of 512 bytes, leaving out the
FCS is not a problem for the default MTU of 1500, as the Rx buffer size
is 1536 in this case.  However, for custom MTUs, where the difference
between the MTU size and the Rx buffer size is less, this can be a
problem as the computed Rx buffer size won't be enough to accomodate
the FCS for a received frame that is big enough (close to MTU size).
In such case the received frame is considered to be incomplete (L flag
not set in the RxBD status) and silently dropped.

Note that the driver does not currently support S/G on Rx, so it has to
compute its Rx buffer size based on the MTU of the device.

Reported-by: Kristian Otnes <kotnes@cisco.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 379b1a5..4fdf0aa 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -338,7 +338,7 @@ static void gfar_init_tx_rx_base(struct gfar_private *priv)
 
 static void gfar_rx_buff_size_config(struct gfar_private *priv)
 {
-	int frame_size = priv->ndev->mtu + ETH_HLEN;
+	int frame_size = priv->ndev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* set this when rx hw offload (TOE) functions are being used */
 	priv->uses_rxfcb = 0;
-- 
1.7.11.7
