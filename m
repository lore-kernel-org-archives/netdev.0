From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri,  4 Apr 2014 14:20:38 +0200
Message-ID: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hkchu@google.com, dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:62150 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbaDDMUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 08:20:43 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so3298411wgg.18
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 05:20:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The priv is used now by af_packet. Rename it to make it useable for
others as well. Also, introduce packet_id_match to move the sk matching
from skb_loop_sk to af_packet code where it belongs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            |  4 +---
 net/packet/af_packet.c    | 22 +++++++++++++++-------
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..04a9375 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1773,7 +1773,7 @@ struct packet_type {
 					 struct net_device *);
 	bool			(*id_match)(struct packet_type *ptype,
 					    struct sock *sk);
-	void			*af_packet_priv;
+	void			*priv;
 	struct list_head	list;
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 48d81e4..36e562e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1714,13 +1714,11 @@ static inline int deliver_skb(struct sk_buff *skb,
 
 static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_buff *skb)
 {
-	if (!ptype->af_packet_priv || !skb->sk)
+	if (!ptype->priv || !skb->sk)
 		return false;
 
 	if (ptype->id_match)
 		return ptype->id_match(ptype, skb->sk);
-	else if ((struct sock *)ptype->af_packet_priv == skb->sk)
-		return true;
 
 	return false;
 }
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 01039d2..1c99be3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1343,7 +1343,7 @@ static bool fanout_has_flag(struct packet_fanout *f, u16 flag)
 static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 			     struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct packet_fanout *f = pt->af_packet_priv;
+	struct packet_fanout *f = pt->priv;
 	unsigned int num = f->num_members;
 	struct packet_sock *po;
 	unsigned int idx;
@@ -1424,7 +1424,7 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 
 static bool match_fanout_group(struct packet_type *ptype, struct sock *sk)
 {
-	if (ptype->af_packet_priv == (void *)((struct packet_sock *)sk)->fanout)
+	if (ptype->priv == (void *)((struct packet_sock *)sk)->fanout)
 		return true;
 
 	return false;
@@ -1486,7 +1486,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->prot_hook.type = po->prot_hook.type;
 		match->prot_hook.dev = po->prot_hook.dev;
 		match->prot_hook.func = packet_rcv_fanout;
-		match->prot_hook.af_packet_priv = match;
+		match->prot_hook.priv = match;
 		match->prot_hook.id_match = match_fanout_group;
 		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
@@ -1544,7 +1544,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,
 	 *	field for just this event.
 	 */
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 
 	/*
 	 *	Yank back the headers [hope the device set this
@@ -1767,7 +1767,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 	po = pkt_sk(sk);
 
 	if (!net_eq(dev_net(dev), sock_net(sk)))
@@ -1892,7 +1892,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 	po = pkt_sk(sk);
 
 	if (!net_eq(dev_net(dev), sock_net(sk)))
@@ -2767,6 +2767,13 @@ static struct proto packet_proto = {
 	.obj_size = sizeof(struct packet_sock),
 };
 
+static bool packet_id_match(struct packet_type *ptype, struct sock *sk)
+{
+	if ((struct sock *) ptype->priv == sk)
+		return true;
+	return false;
+}
+
 /*
  *	Create a packet of type SOCK_PACKET.
  */
@@ -2823,7 +2830,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type == SOCK_PACKET)
 		po->prot_hook.func = packet_rcv_spkt;
 
-	po->prot_hook.af_packet_priv = sk;
+	po->prot_hook.id_match = packet_id_match,
+	po->prot_hook.priv = sk;
 
 	if (proto) {
 		po->prot_hook.type = proto;
-- 
1.9.0
