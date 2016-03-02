From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH] net: sh_eth: avoid NULL pointer dereference in ring setup
Date: Wed,  2 Mar 2016 16:26:06 +0100
Message-ID: <1456932370-4143-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Simon Horman <horms@verge.net.au>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:50158 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754309AbcCBP0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:26:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <wsa+renesas@sang-engineering.com>

When allocating an skb fails, rxdesc is still NULL (or the previous ring
index on further iterations of the loop). However, this pointer is
dereferenced after the loop. So, make sure rxdesc is updated immediately
at the beginning of the loop.

Reported-by: coverity (CID 1056464)
Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a2767336b7c545..d5f13d54099734 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1120,6 +1120,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 
 	/* build Rx ring buffer */
 	for (i = 0; i < mdp->num_rx_ring; i++) {
+		rxdesc = &mdp->rx_ring[i];
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
 		skb = netdev_alloc_skb(ndev, skbuff_size);
@@ -1128,7 +1129,6 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		sh_eth_set_receive_align(skb);
 
 		/* RX descriptor */
-		rxdesc = &mdp->rx_ring[i];
 		/* The size of the buffer is a multiple of 32 bytes. */
 		buf_len = ALIGN(mdp->rx_buf_sz, 32);
 		rxdesc->len = cpu_to_le32(buf_len << 16);
-- 
2.7.0
