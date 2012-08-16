From: Eric Leblond <eric@regit.org>
Subject: [RFC PATCH v1.0] af_packet: don't emit packet on orig fanout group
Date: Thu, 16 Aug 2012 17:44:50 +0200
Message-ID: <1345131890-15991-1-git-send-email-eric@regit.org>
References: <1344262918.8024.41.camel@tiger.regit.org>
Cc: netdev@vger.kernel.org, Eric Leblond <eric@regit.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:37195 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab2HPPqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 11:46:18 -0400
In-Reply-To: <1344262918.8024.41.camel@tiger.regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a packet is emitted on one socket in one group of fanout sockets,
it is transmitted again. It is thus read again on one of the sockets
of the fanout group. This result in a loop for software which
generate packets when receiving one.
This retransmission is not the intended behavior: a fanout group
must behave like a single socket. The packet should not be
transmitted on a socket if it originates from a socket belonging
to the same fanout group.

This patch fixes the issue by changing the transmission check to
take fanout group info account.
---
 include/linux/if_packet.h |    2 ++
 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |   23 +++++++++++++++++++++--
 net/packet/af_packet.c    |    7 +++++++
 4 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index f379929..388519e 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -269,4 +269,6 @@ struct packet_mreq {
 #define PACKET_MR_ALLMULTI	2
 #define PACKET_MR_UNICAST	3
 
+void *pkt_sk_get_fanout(struct sock *sk);
+
 #endif
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1d6ab69..7785730 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1508,6 +1508,8 @@ struct napi_gro_cb {
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
 
+#define NETDEV_TYPE_AF_PACKET_FANOUT	1 << 0
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
@@ -1522,6 +1524,7 @@ struct packet_type {
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
 	void			*af_packet_priv;
+	unsigned char		flags;
 	struct list_head	list;
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ce1bccb..b9498ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -89,6 +89,7 @@
 #include <linux/errno.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
+#include <linux/if_packet.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -1651,6 +1652,25 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
+static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
+{
+	if (ptype->af_packet_priv == NULL)
+		return false;
+
+#ifdef CONFIG_PACKET
+	if (ptype->flags & NETDEV_TYPE_AF_PACKET_FANOUT) {
+		if (ptype->af_packet_priv == pkt_sk_get_fanout(skb->sk))
+			return true;
+	} else
+		if ((struct sock *)ptype->af_packet_priv == skb->sk)
+			return true;
+#else
+	if ((struct sock *)ptype->af_packet_priv == skb->sk)
+		return true;
+#endif
+	return false;
+}
+
 /*
  *	Support routine. Sends outgoing frames to any network
  *	taps currently in use.
@@ -1668,8 +1688,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
 		if ((ptype->dev == dev || !ptype->dev) &&
-		    (ptype->af_packet_priv == NULL ||
-		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
+		    (!skb_loop_sk(ptype, skb))) {
 			if (pt_prev) {
 				deliver_skb(skb2, pt_prev, skb->dev);
 				pt_prev = ptype;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8a1605a..b57aeca 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -247,6 +247,12 @@ struct packet_skb_cb {
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
 
+void *pkt_sk_get_fanout(struct sock *sk)
+{
+	return (void*)((struct packet_sock *)sk)->fanout;
+}
+EXPORT_SYMBOL(pkt_sk_get_fanout);
+
 /* register_prot_hook must be invoked with the po->bind_lock held,
  * or from a context in which asynchronous accesses to the packet
  * socket is not possible (packet_create()).
@@ -1230,6 +1236,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->prot_hook.dev = po->prot_hook.dev;
 		match->prot_hook.func = packet_rcv_fanout;
 		match->prot_hook.af_packet_priv = match;
+		match->prot_hook.flags |= NETDEV_TYPE_AF_PACKET_FANOUT;
 		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
 	}
-- 
1.7.10.4
