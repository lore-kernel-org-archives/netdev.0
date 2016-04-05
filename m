From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/8] fou: change to use UDP socket GRO
Date: Tue, 5 Apr 2016 08:22:54 -0700
Message-ID: <1459869776-2090500-7-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15881 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758977AbcDEPXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:17 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u35FJElv021587
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhcekyw-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:16 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 50bee09afb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:14 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt gue_gro_receive, gue_gro_complete to take a socket argument.
Don't set udp_offloads any more.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 48 +++++++++++++++++-------------------------------
 1 file changed, 17 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5a94aea..5738b97 100644
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
@@ -186,13 +185,13 @@ drop:
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
 
 	/* We can clear the encap_mark for FOU as we are essentially doing
@@ -217,11 +216,11 @@ out_unlock:
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
 
@@ -264,9 +263,9 @@ static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
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
@@ -277,7 +276,7 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 	void *data;
 	u16 doffset = 0;
 	int flush = 1;
-	struct fou *fou = container_of(uoff, struct fou, udp_offloads);
+	struct fou *fou = fou_from_sock(sk);
 	struct gro_remcsum grc;
 
 	skb_gro_remcsum_init(&grc);
@@ -386,8 +385,7 @@ out:
 	return pp;
 }
 
-static int gue_gro_complete(struct sk_buff *skb, int nhoff,
-			    struct udp_offload *uoff)
+static int gue_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 {
 	const struct net_offload **offloads;
 	struct guehdr *guehdr = (struct guehdr *)(skb->data + nhoff);
@@ -435,10 +433,7 @@ static int fou_add_to_port_list(struct net *net, struct fou *fou)
 static void fou_release(struct fou *fou)
 {
 	struct socket *sock = fou->sock;
-	struct sock *sk = sock->sk;
 
-	if (sk->sk_family == AF_INET)
-		udp_del_offload(&fou->udp_offloads);
 	list_del(&fou->list);
 	udp_tunnel_sock_release(sock);
 
@@ -448,11 +443,9 @@ static void fou_release(struct fou *fou)
 static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
 {
 	udp_sk(sk)->encap_rcv = fou_udp_recv;
-	fou->protocol = cfg->protocol;
-	fou->udp_offloads.callbacks.gro_receive = fou_gro_receive;
-	fou->udp_offloads.callbacks.gro_complete = fou_gro_complete;
-	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
-	fou->udp_offloads.ipproto = cfg->protocol;
+	udp_sk(sk)->gro_receive = fou_gro_receive;
+	udp_sk(sk)->gro_complete = fou_gro_complete;
+	fou_from_sock(sk)->protocol = cfg->protocol;
 
 	return 0;
 }
@@ -460,9 +453,8 @@ static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
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
@@ -521,12 +513,6 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
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
