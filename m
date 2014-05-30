From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 2/6] net: fec: Enable IP header hardware checksum
Date: Fri, 30 May 2014 10:05:48 +0800
Message-ID: <1401415552-2263-3-git-send-email-b38611@freescale.com>
References: <1401415552-2263-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ezequiel.garcia@free-electrons.com>, <netdev@vger.kernel.org>,
	<shawn.guo@linaro.org>, <bhutchings@solarflare.com>,
	<b38611@freescale.com>, <stephen@networkplumber.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0142.outbound.protection.outlook.com ([207.46.163.142]:10533
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932083AbaE3D11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 23:27:27 -0400
In-Reply-To: <1401415552-2263-1-git-send-email-b38611@freescale.com>
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
index 96c1a07..d7c1998 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -326,6 +326,7 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(skb_cow_head(skb, 0)))
 		return -1;
 
+	ip_hdr(skb)->check = 0;
 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
 
 	return 0;
@@ -407,7 +408,7 @@ static int txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
 			 * are done by the kernel
 			 */
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				ebdp->cbd_esc |= BD_ENET_TX_PINS;
+				ebdp->cbd_esc |= BD_ENET_TX_PINS | BD_ENET_TX_IINS;
 		}
 	}
 
-- 
1.7.8
