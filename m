From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net] net: fec: Call swap_buffer() prior to IP header alignment
Date: Fri, 21 Oct 2016 09:34:29 -0200
Message-ID: <1477049669-25101-1-git-send-email-festevam@gmail.com>
Cc: fugang.duan@nxp.com, henri.roosen@ginzinger.com, eric@nelint.com,
        kernel@pengutronix.de, rmk@armlinux.org.uk, netdev@vger.kernel.org,
        Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35405 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753088AbcJULey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 07:34:54 -0400
Received: by mail-qk0-f196.google.com with SMTP id v138so6852262qka.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 04:34:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

Commit 3ac72b7b63d5 ("net: fec: align IP header in hardware") breaks
networking on mx28.

There is an erratum on mx28 (ENGR121613 - ENET big endian mode
not compatible with ARM little endian) that requires an additional
byte-swap operation to workaround this problem.

So call swap_buffer() prior to performing the IP header alignment
to restore network functionality on mx28. 

Fixes: 3ac72b7b63d5 ("net: fec: align IP header in hardware")
Reported-and-tested-by: Henri Roosen <henri.roosen@ginzinger.com>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4ce8179..3c888be 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1430,14 +1430,14 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 		skb_put(skb, pkt_len - 4);
 		data = skb->data;
 
+		if (!is_copybreak && need_swap)
+			swap_buffer(data, pkt_len);
+
 #if !defined(CONFIG_M5272)
 		if (fep->quirks & FEC_QUIRK_HAS_RACC)
 			data = skb_pull_inline(skb, 2);
 #endif
 
-		if (!is_copybreak && need_swap)
-			swap_buffer(data, pkt_len);
-
 		/* Extract the enhanced buffer descriptor */
 		ebdp = NULL;
 		if (fep->bufdesc_ex)
-- 
2.7.4
