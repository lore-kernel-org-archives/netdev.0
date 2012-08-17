From: Eric Leblond <eric@regit.org>
Subject: [PATCH v1.1] af_packet: don't emit packet on orig fanout group
Date: Fri, 17 Aug 2012 10:02:58 +0200
Message-ID: <1345190578-28722-1-git-send-email-eric@regit.org>
References: <20120816.145253.939105041613744695.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Eric Leblond <eric@regit.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:41653 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab2HQIEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 04:04:22 -0400
In-Reply-To: <20120816.145253.939105041613744695.davem@davemloft.net>
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

Reported-by: Aleksandr Kotov <a1k@mail.ru>
Signed-off-by: Eric Leblond <eric@regit.org>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   16 ++++++++++++++--
 net/packet/af_packet.c    |    9 +++++++++
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1d6ab69..a6060b2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1521,6 +1521,8 @@ struct packet_type {
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
+	bool			(*id_match)(struct packet_type *ptype,
+					    struct sock *sk);
 	void			*af_packet_priv;
 	struct list_head	list;
 };
diff --git a/net/core/dev.c b/net/core/dev.c
index ce1bccb..05eafb2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1651,6 +1651,19 @@ static inline int deliver_skb(struct sk_buff *skb,
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
+static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
+{
+	if (ptype->af_packet_priv == NULL)
+		return false;
+
+	if (ptype->id_match)
+		return ptype->id_match(ptype, skb->sk);
+	else if ((struct sock *)ptype->af_packet_priv == skb->sk)
+		return true;
+
+	return false;
+}
+
 /*
  *	Support routine. Sends outgoing frames to any network
  *	taps currently in use.
@@ -1668,8 +1681,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
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
index 8a1605a..7a34ace 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1178,6 +1178,14 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 	spin_unlock(&f->lock);
 }
 
+bool match_fanout_group(struct packet_type *ptype, struct sock * sk)
+{
+	if (ptype->af_packet_priv == (void*)((struct packet_sock *)sk)->fanout)
+		return true;
+
+	return false;
+}
+
 static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 {
 	struct packet_sock *po = pkt_sk(sk);
@@ -1230,6 +1238,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->prot_hook.dev = po->prot_hook.dev;
 		match->prot_hook.func = packet_rcv_fanout;
 		match->prot_hook.af_packet_priv = match;
+		match->prot_hook.id_match = match_fanout_group;
 		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
 	}
-- 
1.7.10.4
