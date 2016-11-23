From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: properly flush delay-freed skbs
Date: Wed, 23 Nov 2016 08:44:56 -0800
Message-ID: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34215 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752700AbcKWQpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:45:03 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so1431634pgc.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 08:44:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Typical NAPI drivers use napi_consume_skb(skb) at TX completion time.
This put skb in a percpu special queue, napi_alloc_cache, to get bulk
frees.

It turns out the queue is not flushed and hits the NAPI_SKB_CACHE_SIZE
limit quite often, with skbs that were queued hundreds of usec earlier.
I measured this can take ~6000 nsec to perform one flush.

__kfree_skb_flush() can be called from two points right now :

1) From net_tx_action(), but only for skbs that were queued to
sd->completion_queue.

 -> Irrelevant for NAPI drivers in normal operation.

2) From net_rx_action(), but only under high stress or if RPS/RFS has a
pending action.

This patch changes net_rx_action() to perform the flush in all cases and
after more urgent operations happened (like kicking remote CPUS for
RPS/RFS).

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f71b34ab57a5132647729d20e21376d362d4e630..048b46b7c92ae10080226ea7050fad3529920baa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5260,7 +5260,7 @@ static __latent_entropy void net_rx_action(struct softirq_action *h)
 
 		if (list_empty(&list)) {
 			if (!sd_has_rps_ipi_waiting(sd) && list_empty(&repoll))
-				return;
+				goto out;
 			break;
 		}
 
@@ -5278,7 +5278,6 @@ static __latent_entropy void net_rx_action(struct softirq_action *h)
 		}
 	}
 
-	__kfree_skb_flush();
 	local_irq_disable();
 
 	list_splice_tail_init(&sd->poll_list, &list);
@@ -5288,6 +5287,8 @@ static __latent_entropy void net_rx_action(struct softirq_action *h)
 		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 
 	net_rps_action_and_irq_enable(sd);
+out:
+	__kfree_skb_flush();
 }
 
 struct netdev_adjacent {
