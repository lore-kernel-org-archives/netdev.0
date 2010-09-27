From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH -next 1/4] tunnels: prepare percpu accounting
Date: Mon, 27 Sep 2010 12:33:35 +0200
Message-ID: <1285583615.23938.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49815 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658Ab0I0Kdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:33:39 -0400
Received: by fxm3 with SMTP id 3so1675498fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:33:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnels are going to use percpu for their accounting.

They are going to use a new tstats field in net_device.

skb_tunnel_rx() is changed to be a wrapper around __skb_tunnel_rx()

IPTUNNEL_XMIT() is changed to be a wrapper around __IPTUNNEL_XMIT()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    1 +
 include/net/dst.h         |   24 +++++++++++++++++++-----
 include/net/ipip.h        |   12 +++++++-----
 3 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 01bd4c8..83de0eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1053,6 +1053,7 @@ struct net_device {
 	union {
 		void				*ml_priv;
 		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
+		struct pcpu_tstats __percpu	*tstats; /* tunnel stats */
 	};
 	/* GARP */
 	struct garp_port	*garp_port;
diff --git a/include/net/dst.h b/include/net/dst.h
index 0238650..2916852 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -228,23 +228,37 @@ static inline void skb_dst_force(struct sk_buff *skb)
 
 
 /**
+ *	__skb_tunnel_rx - prepare skb for rx reinsert
+ *	@skb: buffer
+ *	@dev: tunnel device
+ *
+ *	After decapsulation, packet is going to re-enter (netif_rx()) our stack,
+ *	so make some cleanups. (no accounting done)
+ */
+static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev = dev;
+	skb->rxhash = 0;
+	skb_set_queue_mapping(skb, 0);
+	skb_dst_drop(skb);
+	nf_reset(skb);
+}
+
+/**
  *	skb_tunnel_rx - prepare skb for rx reinsert
  *	@skb: buffer
  *	@dev: tunnel device
  *
  *	After decapsulation, packet is going to re-enter (netif_rx()) our stack,
  *	so make some cleanups, and perform accounting.
+ *	Note: this accounting is not SMP safe.
  */
 static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 {
-	skb->dev = dev;
 	/* TODO : stats should be SMP safe */
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
-	skb->rxhash = 0;
-	skb_set_queue_mapping(skb, 0);
-	skb_dst_drop(skb);
-	nf_reset(skb);
+ 	__skb_tunnel_rx(skb, dev);
 }
 
 /* Children define the path of the packet through the
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 65caea8..58abbf9 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -45,7 +45,7 @@ struct ip_tunnel_prl_entry {
 	struct rcu_head			rcu_head;
 };
 
-#define IPTUNNEL_XMIT() do {						\
+#define __IPTUNNEL_XMIT(stats1, stats2) do {				\
 	int err;							\
 	int pkt_len = skb->len - skb_transport_offset(skb);		\
 									\
@@ -54,12 +54,14 @@ struct ip_tunnel_prl_entry {
 									\
 	err = ip_local_out(skb);					\
 	if (likely(net_xmit_eval(err) == 0)) {				\
-		txq->tx_bytes += pkt_len;				\
-		txq->tx_packets++;					\
+		(stats1)->tx_bytes += pkt_len;				\
+		(stats1)->tx_packets++;					\
 	} else {							\
-		stats->tx_errors++;					\
-		stats->tx_aborted_errors++;				\
+		(stats2)->tx_errors++;					\
+		(stats2)->tx_aborted_errors++;				\
 	}								\
 } while (0)
 
+#define IPTUNNEL_XMIT() __IPTUNNEL_XMIT(txq, stats)
+
 #endif


