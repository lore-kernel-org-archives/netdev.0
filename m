From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 1/6] net: make packet_type->ak_packet_priv generic
Date: Wed, 26 Mar 2014 17:31:07 +0100
Message-ID: <1395851472-10524-2-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:36839 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470AbaCZQbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:31:22 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so1853985eek.17
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:31:21 -0700 (PDT)
In-Reply-To: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
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
index 4b6d12c..6b70e6f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1777,7 +1777,7 @@ struct packet_type {
 					 struct net_device *);
 	bool			(*id_match)(struct packet_type *ptype,
 					    struct sock *sk);
-	void			*af_packet_priv;
+	void			*priv;
 	struct list_head	list;
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 55f8e64..61ce72d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1719,13 +1719,11 @@ static inline int deliver_skb(struct sk_buff *skb,
 
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
index 2923044..a36ac08 100644
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
@@ -1425,7 +1425,7 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 
 static bool match_fanout_group(struct packet_type *ptype, struct sock *sk)
 {
-	if (ptype->af_packet_priv == (void *)((struct packet_sock *)sk)->fanout)
+	if (ptype->priv == (void *)((struct packet_sock *)sk)->fanout)
 		return true;
 
 	return false;
@@ -1487,7 +1487,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->prot_hook.type = po->prot_hook.type;
 		match->prot_hook.dev = po->prot_hook.dev;
 		match->prot_hook.func = packet_rcv_fanout;
-		match->prot_hook.af_packet_priv = match;
+		match->prot_hook.priv = match;
 		match->prot_hook.id_match = match_fanout_group;
 		dev_add_pack(&match->prot_hook);
 		list_add(&match->list, &fanout_list);
@@ -1545,7 +1545,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,
 	 *	field for just this event.
 	 */
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 
 	/*
 	 *	Yank back the headers [hope the device set this
@@ -1768,7 +1768,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 	po = pkt_sk(sk);
 
 	if (!net_eq(dev_net(dev), sock_net(sk)))
@@ -1893,7 +1893,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
 
-	sk = pt->af_packet_priv;
+	sk = pt->priv;
 	po = pkt_sk(sk);
 
 	if (!net_eq(dev_net(dev), sock_net(sk)))
@@ -2768,6 +2768,13 @@ static struct proto packet_proto = {
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
@@ -2824,7 +2831,8 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	if (sock->type == SOCK_PACKET)
 		po->prot_hook.func = packet_rcv_spkt;
 
-	po->prot_hook.af_packet_priv = sk;
+	po->prot_hook.id_match = packet_id_match,
+	po->prot_hook.priv = sk;
 
 	if (proto) {
 		po->prot_hook.type = proto;
-- 
1.8.5.3
