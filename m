From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 2/2 v2] GRETH: avoid overwrite IP-stack's IP-frags checksum
Date: Fri,  9 Sep 2011 17:17:54 +0200
Message-ID: <1315581474-4430-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:45809 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750958Ab1IIPSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 11:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GRETH GBIT core does not do checksum offloading for IP
segmentation. This patch adds a check in the xmit function to
determine if the stack has calculated the checksum for us.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 22e24a3..6775c24 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -489,7 +489,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 	if (nr_frags != 0)
 		status = GRETH_TXBD_MORE;
 
-	status |= GRETH_TXBD_CSALL;
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		status |= GRETH_TXBD_CSALL;
 	status |= skb_headlen(skb) & GRETH_BD_LEN;
 	if (greth->tx_next == GRETH_TXBD_NUM_MASK)
 		status |= GRETH_BD_WR;
@@ -512,7 +513,9 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
 		greth->tx_skbuff[curr_tx] = NULL;
 		bdp = greth->tx_bd_base + curr_tx;
 
-		status = GRETH_TXBD_CSALL | GRETH_BD_EN;
+		status = GRETH_BD_EN;
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			status |= GRETH_TXBD_CSALL;
 		status |= frag->size & GRETH_BD_LEN;
 
 		/* Wrap around descriptor ring */
-- 
1.5.4
