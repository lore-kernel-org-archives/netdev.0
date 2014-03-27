From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: set RBUF_SKIP_FCS based on UniMAC CRC forwarding
Date: Wed, 26 Mar 2014 21:18:39 -0700
Message-ID: <1395893919-29393-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35514 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbaC0ESm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 00:18:42 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2797792pdj.36
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 21:18:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the UniMAC block is configured to forward the CRC as part of the
Ethernet frame (priv->crc_fwd_en, set by default), enabling the hardware
RX checksum block unveiled that the dma_rxchk_bit was never set in the
per-packet status bits (dma_flag in bcmgenet_desc_rx). This would make
the chksum_ok variable to be never set to 1, and the networking stack
would have to compute the packet checksums, which takes a substantial
amount of time.

In order for the RXCHK block to properly compute the packet checksum in
hardware, we also need to set the RBUF_SKIP_FCS bit accordingly.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 8f87fe0..adf8acb 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -416,6 +416,15 @@ static int bcmgenet_set_rx_csum(struct net_device *dev,
 	else
 		rbuf_chk_ctrl &= ~RBUF_RXCHK_EN;
 	priv->desc_rxchk_en = rx_csum_en;
+
+	/* If UniMAC forwards CRC, we need to skip over it to get
+	 * a valid CHK bit to be set in the per-packet status word
+	*/
+	if (rx_csum_en && priv->crc_fwd_en)
+		rbuf_chk_ctrl |= RBUF_SKIP_FCS;
+	else
+		rbuf_chk_ctrl &= ~RBUF_SKIP_FCS;
+
 	bcmgenet_rbuf_writel(priv, rbuf_chk_ctrl, RBUF_CHK_CTRL);
 
 	return 0;
-- 
1.8.3.2
