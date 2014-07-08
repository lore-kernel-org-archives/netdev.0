From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH C 5/7] net: fec: add support for dumping transmit ring on
 timeout
Date: Tue, 08 Jul 2014 13:01:59 +0100
Message-ID: <E1X4U5v-0005uE-BB@rmk-PC.arm.linux.org.uk>
References: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58743 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754499AbaGHMCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 08:02:01 -0400
In-Reply-To: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we timeout on transmit, it would be useful to dump the transmit
ring, so we can see the ring state.  This can be helpful to diagnose
the cause of transmit timeouts.

Acked-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index c6b1bf797a39..09fcdc768931 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -320,6 +320,27 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
 
+static void fec_dump(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct bufdesc *bdp = fep->tx_bd_base;
+	unsigned int index = 0;
+
+	netdev_info(ndev, "TX ring dump\n");
+	pr_info("Nr     SC     addr       len  SKB\n");
+
+	do {
+		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
+			index,
+			bdp == fep->cur_tx ? 'S' : ' ',
+			bdp == fep->dirty_tx ? 'H' : ' ',
+			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
+			fep->tx_skbuff[index]);
+		bdp = fec_enet_get_nextdesc(bdp, fep);
+		index++;
+	} while (bdp != fep->tx_bd_base);
+}
+
 static inline bool is_ipv4_pkt(struct sk_buff *skb)
 {
 	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
@@ -1018,6 +1039,8 @@ fec_timeout(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	fec_dump(ndev);
+
 	ndev->stats.tx_errors++;
 
 	schedule_work(&fep->tx_timeout_work);
-- 
1.8.3.1
