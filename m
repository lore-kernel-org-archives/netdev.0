From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ifb: RCU locking avoids touching dev refcount
Date: Mon, 02 Nov 2009 06:45:16 +0100
Message-ID: <4AEE71EC.7040208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41726 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbZKBFpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 00:45:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoids touching dev refcount in hotpath

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ifb.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 030913f..69c2566 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -98,13 +98,15 @@ static void ri_tasklet(unsigned long dev)
 		stats->tx_packets++;
 		stats->tx_bytes +=skb->len;
 
-		skb->dev = dev_get_by_index(&init_net, skb->iif);
+		rcu_read_lock();
+		skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
 		if (!skb->dev) {
+			rcu_read_unlock();
 			dev_kfree_skb(skb);
 			stats->tx_dropped++;
 			break;
 		}
-		dev_put(skb->dev);
+		rcu_read_unlock();
 		skb->iif = _dev->ifindex;
 
 		if (from & AT_EGRESS) {
