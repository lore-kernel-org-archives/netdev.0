From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] sch_teql: should not dereference skb after ndo_start_xmit
Date: Mon, 18 May 2009 12:31:57 +0200
Message-ID: <4A11391D.8060503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51010 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbZERKcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 06:32:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

I found following by code inspection, not a crash analysis, but I believe it is
a 2.6.30 candidate, and stable (2.6.27 and up) as well.

Thank you

[PATCH] sch_teql: should not dereference skb after ndo_start_xmit()

It is illegal to dereference a skb after a successful ndo_start_xmit()
call. We must store skb length in a local variable instead.

Bug was introduced in 2.6.27 by commit 0abf77e55a2459aa9905be4b226e4729d5b4f0cb
(net_sched: Add accessor function for packet length for qdiscs)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index ec697ce..3b64182 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -303,6 +303,8 @@ restart:
 		switch (teql_resolve(skb, skb_res, slave)) {
 		case 0:
 			if (__netif_tx_trylock(slave_txq)) {
+				unsigned int length = qdisc_pkt_len(skb);
+
 				if (!netif_tx_queue_stopped(slave_txq) &&
 				    !netif_tx_queue_frozen(slave_txq) &&
 				    slave_ops->ndo_start_xmit(skb, slave) == 0) {
@@ -310,8 +312,7 @@ restart:
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
 					master->stats.tx_packets++;
-					master->stats.tx_bytes +=
-						qdisc_pkt_len(skb);
+					master->stats.tx_bytes += length;
 					return 0;
 				}
 				__netif_tx_unlock(slave_txq);
