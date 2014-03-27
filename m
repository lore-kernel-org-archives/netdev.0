From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2 6/6] netpoll: Respect NETIF_F_LLTX
Date: Thu, 27 Mar 2014 15:42:20 -0700
Message-ID: <87siq3p8kz.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:44335 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaC0Wmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:42:31 -0400
In-Reply-To: <87vbuzqnh3.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 27 Mar 2014 15:35:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stop taking the transmit lock when a network device has specified
NETIF_F_LLTX.

If no locks needed to trasnmit a packet this is the ideal scenario for
netpoll as all packets can be trasnmitted immediately.

Even if some locks are needed in ndo_start_xmit skipping any unnecessary
serialization is desirable for netpoll as it makes it more likely a
debugging packet may be trasnmitted immediately instead of being
deferred until later.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h |    5 +++++
 net/core/netpoll.c        |   10 +++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 77142a78c4d9..aa06633fc966 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2908,6 +2908,11 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 	}						\
 }
 
+#define HARD_TX_TRYLOCK(dev, txq)			\
+	(((dev->features & NETIF_F_LLTX) == 0) ?	\
+		__netif_tx_trylock(txq) :		\
+		true )
+
 #define HARD_TX_UNLOCK(dev, txq) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		__netif_tx_unlock(txq);			\
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2136c9aacdbf..af8dc13d69d6 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -119,17 +119,17 @@ static void queue_process(struct work_struct *work)
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 		local_irq_save(flags);
-		__netif_tx_lock(txq, smp_processor_id());
+		HARD_TX_LOCK(dev, txq, smp_processor_id());
 		if (netif_xmit_frozen_or_stopped(txq) ||
 		    netpoll_start_xmit(skb, dev, txq) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
-			__netif_tx_unlock(txq);
+			HARD_TX_UNLOCK(dev, txq);
 			local_irq_restore(flags);
 
 			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
-		__netif_tx_unlock(txq);
+		HARD_TX_UNLOCK(dev, txq);
 		local_irq_restore(flags);
 	}
 }
@@ -345,11 +345,11 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
-			if (__netif_tx_trylock(txq)) {
+			if (HARD_TX_TRYLOCK(dev, txq)) {
 				if (!netif_xmit_stopped(txq))
 					status = netpoll_start_xmit(skb, dev, txq);
 
-				__netif_tx_unlock(txq);
+				HARD_TX_UNLOCK(dev, txq);
 
 				if (status == NETDEV_TX_OK)
 					break;
-- 
1.7.10.4
