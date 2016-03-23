From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 7/9] fou: change to use UDP socket GRO and fast rcv encap
Date: Wed, 23 Mar 2016 15:36:56 -0700
Message-ID: <1458772618-845742-8-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:22555 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830AbcCWWjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:39:35 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMaDqU002940
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:39:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21v01d17ys-19
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:39:33 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 cb652d54f14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:16 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt gue_gro_receive, gue_gro_complete to take a socket argument.
Set the encap_fast flag on fou sockets. Don't set udp_offloads
any more.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 49 ++++++++++++++++++-------------------------------
 1 file changed, 18 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 7804842..a90d179 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -22,7 +22,6 @@ struct fou {
 	u8 flags;
 	__be16 port;
 	u16 type;
-	struct udp_offload udp_offloads;
 	struct list_head list;
 	struct rcu_head rcu;
 };
@@ -177,13 +176,13 @@ drop:
 	return 0;
 }
 
-static struct sk_buff **fou_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb,
-					struct udp_offload *uoff)
+static struct sk_buff **fou_gro_receive(struct sock *sk,
+					struct sk_buff **head,
+					struct sk_buff *skb)
 {
 	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
-	u8 proto = NAPI_GRO_CB(skb)->proto;
+	u8 proto = fou_from_sock(sk)->protocol;
 	const struct net_offload **offloads;
 
 	rcu_read_lock();
@@ -200,11 +199,11 @@ out_unlock:
 	return pp;
 }
 
-static int fou_gro_complete(struct sk_buff *skb, int nhoff,
-			    struct udp_offload *uoff)
+static int fou_gro_complete(struct sock *sk, struct sk_buff *skb,
+			    int nhoff)
 {
 	const struct net_offload *ops;
-	u8 proto = NAPI_GRO_CB(skb)->proto;
+	u8 proto = fou_from_sock(sk)->protocol;
 	int err = -ENOSYS;
 	const struct net_offload **offloads;
 
@@ -247,9 +246,9 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 	return guehdr;
 }
 
-static struct sk_buff **gue_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb,
-					struct udp_offload *uoff)
+static struct sk_buff **gue_gro_receive(struct sock *sk,
+					struct sk_buff **head,
+					struct sk_buff *skb)
 {
 	const struct net_offload **offloads;
 	const struct net_offload *ops;
@@ -260,7 +259,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	void *data;
 	u16 doffset = 0;
 	int flush = 1;
-	struct fou *fou = container_of(uoff, struct fou, udp_offloads);
+	struct fou *fou = fou_from_sock(sk);
 	struct gro_remcsum grc;
 
 	skb_gro_remcsum_init(&grc);
@@ -361,8 +360,7 @@ out:
 	return pp;
 }
 
-static int gue_gro_complete(struct sk_buff *skb, int nhoff,
-			    struct udp_offload *uoff)
+static int gue_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 {
 	const struct net_offload **offloads;
 	struct guehdr *guehdr = (struct guehdr *)(skb->data + nhoff);
@@ -410,10 +408,7 @@ static int fou_add_to_port_list(struct net *net, struct fou *fou)
 static void fou_release(struct fou *fou)
 {
 	struct socket *sock = fou->sock;
-	struct sock *sk = sock->sk;
 
-	if (sk->sk_family == AF_INET)
-		udp_del_offload(&fou->udp_offloads);
 	list_del(&fou->list);
 	udp_tunnel_sock_release(sock);
 
@@ -422,12 +417,10 @@ static void fou_release(struct fou *fou)
 
 static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
 {
-	udp_sk(sk)->encap_rcv = fou_udp_recv;
 	fou->protocol = cfg->protocol;
-	fou->udp_offloads.callbacks.gro_receive = fou_gro_receive;
-	fou->udp_offloads.callbacks.gro_complete = fou_gro_complete;
-	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
-	fou->udp_offloads.ipproto = cfg->protocol;
+	udp_sk(sk)->encap_rcv = fou_udp_recv;
+	udp_sk(sk)->gro_receive = fou_gro_receive;
+	udp_sk(sk)->gro_complete = fou_gro_complete;
 
 	return 0;
 }
@@ -435,9 +428,8 @@ static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
 static int gue_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
 {
 	udp_sk(sk)->encap_rcv = gue_udp_recv;
-	fou->udp_offloads.callbacks.gro_receive = gue_gro_receive;
-	fou->udp_offloads.callbacks.gro_complete = gue_gro_complete;
-	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
+	udp_sk(sk)->gro_receive = gue_gro_receive;
+	udp_sk(sk)->gro_complete = gue_gro_complete;
 
 	return 0;
 }
@@ -487,6 +479,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 	fou->type = cfg->type;
 
 	udp_sk(sk)->encap_type = 1;
+	udp_sk(sk)->encap_fast = 1;
 	udp_encap_enable();
 
 	sk->sk_user_data = fou;
@@ -496,12 +489,6 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk->sk_allocation = GFP_ATOMIC;
 
-	if (cfg->udp_config.family == AF_INET) {
-		err = udp_add_offload(net, &fou->udp_offloads);
-		if (err)
-			goto error;
-	}
-
 	err = fou_add_to_port_list(net, fou);
 	if (err)
 		goto error;
-- 
2.8.0.rc2
