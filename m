From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: mvneta: fix race condition in mvneta_tx()
Date: Tue, 02 Dec 2014 04:30:59 -0800
Message-ID: <1417523459.5303.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141202071304.GA22512@1wt.eu>
	 <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:53857 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbaLBMbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 07:31:01 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so10716070igd.1
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 04:31:00 -0800 (PST)
In-Reply-To: <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mvneta_tx() dereferences skb to get skb->len too late,
as hardware might have completed the transmit and TX completion
could have freed the skb from another cpu.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/marvell/mvneta.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ccc3ce2e8c8c7c8d929b2ff5e271bf62948c7012..34f58150d693b4215b58285c1dcbb4b16cc03697 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1721,6 +1721,7 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
 	u16 txq_id = skb_get_queue_mapping(skb);
 	struct mvneta_tx_queue *txq = &pp->txqs[txq_id];
 	struct mvneta_tx_desc *tx_desc;
+	int len = skb->len;
 	int frags = 0;
 	u32 tx_cmd;
 
@@ -1788,7 +1789,7 @@ out:
 
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
-		stats->tx_bytes  += skb->len;
+		stats->tx_bytes  += len;
 		u64_stats_update_end(&stats->syncp);
 	} else {
 		dev->stats.tx_dropped++;
