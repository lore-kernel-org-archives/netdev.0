From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v2 2/6] net: fec: Enable IP header hardware checksum
Date: Wed, 4 Jun 2014 15:39:27 +0800
Message-ID: <1401867571-11684-3-git-send-email-b38611@freescale.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>, <R49496@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0183.outbound.protection.outlook.com ([207.46.163.183]:7342
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751682AbaFDJC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 05:02:57 -0400
In-Reply-To: <1401867571-11684-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP header checksum is calcalated by network layer in default.
To support software TSO, it is better to use HW calculate the
IP header checksum.

FEC hw checksum feature request the checksum field in frame
is zero, otherwise the calculative CRC is not correct.

For segmentated TCP packet, HW calculate the IP header checksum again,
it doesn't bring any impact. For SW TSO, HW calculated checksum bring
better performance.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 32c2276..299f7f5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -327,6 +327,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(skb_cow_head(skb, 0)))
 		return -1;
 
+	ip_hdr(skb)->check = 0;
 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
 
 	return 0;
@@ -408,7 +409,7 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 			 * are done by the kernel
 			 */
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				ebdp->cbd_esc |= BD_ENET_TX_PINS;
+				ebdp->cbd_esc |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		}
 	}
 
-- 
1.7.8
