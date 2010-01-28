From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] [PATCH] net: Add support for ndo_select_queue() functions to
	cache the queue mapping
Date: Thu, 28 Jan 2010 17:38:37 +0000
Message-ID: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:47670 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831Ab0A1Rik convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 12:38:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFWe think it's worth matching up RX and TX queue selection for =
a socket
when the queues share an interrupt.  Currently the default TX queue
selection is unlikely to match RX queue selection.  TX queue selectionc
can be overridden by the driver to match RX queue selection, but at the
expense of caching.  We found that without caching the cost of
recalculating the the hash in software for each packet outweighed the
benefit of good queue selection.

This adds two simple helper functions: sk_may_set_tx_queue() reports
whether the queue mapping should be cacheable for a socket, and
netif_sk_tx_queue_set() sets it after validating the queue index.  This
will allow drivers to evalulate expensive queue selection functions
(such as Toeplitz hash functions) only once for connected sockets, and
to avoid doing so for other skbs.
---
 include/linux/netdevice.h |    3 +++
 include/net/sock.h        |   11 +++++++++++
 net/core/dev.c            |   19 ++++++++++++++++++-
 3 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..5354765 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1510,6 +1510,9 @@ static inline int netif_is_multiqueue(const struc=
t net_device *dev)
 	return (dev->num_tx_queues > 1);
 }
=20
+extern void netif_sk_tx_queue_set(struct net_device *dev, struct sock =
*sk,
+				  u16 queue_index);
+
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware inter=
rupts
  * disabled.
diff --git a/include/net/sock.h b/include/net/sock.h
index 3f1a480..176fdff 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1105,6 +1105,17 @@ static inline void sock_put(struct sock *sk)
 extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
 			  const int nested);
=20
+/**
+ *	sk_may_set_tx_queue - is socket's TX queue mapping cacheable?
+ *	@sk: socket from skb to be transmitted; may be %NULL
+ *
+ * Report whether a queue mapping should be set for this socket.
+ */
+static inline bool sk_may_set_tx_queue(const struct sock *sk)
+{
+	return sk && sk->sk_dst_cache;
+}
+
 static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
 {
 	sk->sk_tx_queue_mapping =3D tx_queue;
diff --git a/net/core/dev.c b/net/core/dev.c
index be9924f..09ac29e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1931,7 +1931,7 @@ static struct netdev_queue *dev_pick_tx(struct ne=
t_device *dev,
 			if (dev->real_num_tx_queues > 1)
 				queue_index =3D skb_tx_hash(dev, skb);
=20
-			if (sk && sk->sk_dst_cache)
+			if (sk_may_set_tx_queue(sk))
 				sk_tx_queue_set(sk, queue_index);
 		}
 	}
@@ -1940,6 +1940,23 @@ static struct netdev_queue *dev_pick_tx(struct n=
et_device *dev,
 	return netdev_get_tx_queue(dev, queue_index);
 }
=20
+/**
+ *	netif_sk_tx_queue_set - set socket's TX queue mapping
+ *	@dev: network device used for transmission
+ *	@sk: socket from skb to be transmitted
+ *	@queue_index: chosen queue index
+ *
+ * Set the TX queue index to be used for future skbs in the same flow
+ * rather than calling the device's ndo_select_queue function.
+ * sk_may_set_tx_queue(@sk) must be true.
+ */
+void netif_sk_tx_queue_set(struct net_device *dev, struct sock *sk,
+			   u16 queue_index)
+{
+	sk_tx_queue_set(sk, dev_cap_txqueue(dev, queue_index));
+}
+EXPORT_SYMBOL(netif_sk_tx_queue_set);
+
 static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct net_device *dev,
 				 struct netdev_queue *txq)
--=20
1.5.5

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

