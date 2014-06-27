From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 28/30] net: fec: add support for dumping transmit ring on
 timeout
Date: Fri, 27 Jun 2014 16:21:16 +0100
Message-ID: <E1X0Xxk-0001P1-BS@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45265 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754375AbaF0PVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:21:18 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we timeout on transmit, it would be useful to dump the transmit
ring, so we can see the ring state.  This can be helpful to diagnose
the cause of transmit timeouts.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9af9350565be..1e0eeb43ff6a 100644
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
