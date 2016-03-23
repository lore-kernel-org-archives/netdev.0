From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 8/9] geneve: change to use UDP socket GRO
Date: Wed, 23 Mar 2016 15:36:57 -0700
Message-ID: <1458772618-845742-9-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:13449 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751945AbcCWWhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:37:19 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMahE3000539
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21uwsq9pjn-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:18 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 cc01fbfcf14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:17 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt geneve_gro_receive, geneve_gro_complete to take a socket argument.
Set these functions in tunnel_config.  Don't set udp_offloads any more.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/geneve.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 192631a..6caf9ed 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -87,7 +87,6 @@ struct geneve_sock {
 	struct socket		*sock;
 	struct rcu_head		rcu;
 	int			refcnt;
-	struct udp_offload	udp_offloads;
 	struct hlist_head	vni_list[VNI_HASH_SIZE];
 	u32			flags;
 };
@@ -409,14 +408,6 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = geneve_get_sk_family(gs);
 	__be16 port = inet_sk(sk)->inet_sport;
-	int err;
-
-	if (sa_family == AF_INET) {
-		err = udp_add_offload(sock_net(sk), &gs->udp_offloads);
-		if (err)
-			pr_warn("geneve: udp_add_offload failed with status %d\n",
-				err);
-	}
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -432,9 +423,9 @@ static int geneve_hlen(struct genevehdr *gh)
 	return sizeof(*gh) + gh->opt_len * 4;
 }
 
-static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
-					   struct sk_buff *skb,
-					   struct udp_offload *uoff)
+static struct sk_buff **geneve_gro_receive(struct sock *sk,
+					   struct sk_buff **head,
+					   struct sk_buff *skb)
 {
 	struct sk_buff *p, **pp = NULL;
 	struct genevehdr *gh, *gh2;
@@ -495,8 +486,8 @@ out:
 	return pp;
 }
 
-static int geneve_gro_complete(struct sk_buff *skb, int nhoff,
-			       struct udp_offload *uoff)
+static int geneve_gro_complete(struct sock *sk, struct sk_buff *skb,
+			       int nhoff)
 {
 	struct genevehdr *gh;
 	struct packet_offload *ptype;
@@ -545,14 +536,15 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 		INIT_HLIST_HEAD(&gs->vni_list[h]);
 
 	/* Initialize the geneve udp offloads structure */
-	gs->udp_offloads.port = port;
-	gs->udp_offloads.callbacks.gro_receive  = geneve_gro_receive;
-	gs->udp_offloads.callbacks.gro_complete = geneve_gro_complete;
 	geneve_notify_add_rx_port(gs);
 
 	/* Mark socket as an encapsulation socket */
+	memset(&tunnel_cfg, 0, sizeof(tunnel_cfg));
 	tunnel_cfg.sk_user_data = gs;
 	tunnel_cfg.encap_type = 1;
+	tunnel_cfg.encap_fast = 0;
+	tunnel_cfg.gro_receive = geneve_gro_receive;
+	tunnel_cfg.gro_complete = geneve_gro_complete;
 	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
 	tunnel_cfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
@@ -576,9 +568,6 @@ static void geneve_notify_del_rx_port(struct geneve_sock *gs)
 	}
 
 	rcu_read_unlock();
-
-	if (sa_family == AF_INET)
-		udp_del_offload(&gs->udp_offloads);
 }
 
 static void __geneve_sock_release(struct geneve_sock *gs)
-- 
2.8.0.rc2
