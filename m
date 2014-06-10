From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v4 2/6] net: fec: Enable IP header hardware checksum
Date: Tue, 10 Jun 2014 17:32:20 +0800
Message-ID: <1402392744-24368-3-git-send-email-b38611@freescale.com>
References: <1402392744-24368-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>,
	<ezequiel.garcia@free-electrons.com>, <b20596@freescale.com>,
	<David.Laight@ACULAB.COM>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0205.outbound.protection.outlook.com ([207.46.163.205]:23729
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751146AbaFJK5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 06:57:55 -0400
In-Reply-To: <1402392744-24368-1-git-send-email-b38611@freescale.com>
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
index ee8e547..55b55d2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -314,6 +314,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(skb_cow_head(skb, 0)))
 		return -1;
 
+	ip_hdr(skb)->check = 0;
 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
 
 	return 0;
@@ -395,7 +396,7 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 			 * are done by the kernel
 			 */
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				ebdp->cbd_esc |= BD_ENET_TX_PINS;
+				ebdp->cbd_esc |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		}
 	}
 
-- 
1.7.8
