From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 6/9] vxlan: change vxlan to use UDP socket GRO
Date: Wed, 23 Mar 2016 15:36:55 -0700
Message-ID: <1458772618-845742-7-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34063 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbcCWWhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:37:17 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMVnrv019807
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21v021h22b-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:37:16 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 cacd128af14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:15 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt vxlan_gro_receive, vxlan_gro_complete to take a socket argument.
Set these functions in tunnel_config.  Don't set udp_offloads any more.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/vxlan.c | 31 +++++++++----------------------
 include/net/vxlan.h |  1 -
 2 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 800106a7..d27aceb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -551,16 +551,15 @@ static struct vxlanhdr *vxlan_gro_remcsum(struct sk_buff *skb,
 	return vh;
 }
 
-static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
-					  struct sk_buff *skb,
-					  struct udp_offload *uoff)
+static struct sk_buff **vxlan_gro_receive(struct sock *sk,
+					  struct sk_buff **head,
+					  struct sk_buff *skb)
 {
 	struct sk_buff *p, **pp = NULL;
 	struct vxlanhdr *vh, *vh2;
 	unsigned int hlen, off_vx;
 	int flush = 1;
-	struct vxlan_sock *vs = container_of(uoff, struct vxlan_sock,
-					     udp_offloads);
+	struct vxlan_sock *vs = rcu_dereference_sk_user_data(sk);
 	__be32 flags;
 	struct gro_remcsum grc;
 
@@ -613,8 +612,7 @@ out:
 	return pp;
 }
 
-static int vxlan_gro_complete(struct sk_buff *skb, int nhoff,
-			      struct udp_offload *uoff)
+static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 {
 	udp_tunnel_gro_complete(skb, nhoff);
 
@@ -629,13 +627,6 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = vxlan_get_sk_family(vs);
 	__be16 port = inet_sk(sk)->inet_sport;
-	int err;
-
-	if (sa_family == AF_INET) {
-		err = udp_add_offload(net, &vs->udp_offloads);
-		if (err)
-			pr_warn("vxlan: udp_add_offload failed with status %d\n", err);
-	}
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
@@ -662,9 +653,6 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 							    port);
 	}
 	rcu_read_unlock();
-
-	if (sa_family == AF_INET)
-		udp_del_offload(&vs->udp_offloads);
 }
 
 /* Add new entry to forwarding table -- assumes lock held */
@@ -2643,21 +2631,20 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	atomic_set(&vs->refcnt, 1);
 	vs->flags = (flags & VXLAN_F_RCV_FLAGS);
 
-	/* Initialize the vxlan udp offloads structure */
-	vs->udp_offloads.port = port;
-	vs->udp_offloads.callbacks.gro_receive  = vxlan_gro_receive;
-	vs->udp_offloads.callbacks.gro_complete = vxlan_gro_complete;
-
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	vxlan_notify_add_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
+	memset(&tunnel_cfg, 0, sizeof(tunnel_cfg));
 	tunnel_cfg.sk_user_data = vs;
 	tunnel_cfg.encap_type = 1;
 	tunnel_cfg.encap_rcv = vxlan_rcv;
 	tunnel_cfg.encap_destroy = NULL;
+	tunnel_cfg.encap_fast = 0;
+	tunnel_cfg.gro_receive = vxlan_gro_receive;
+	tunnel_cfg.gro_complete = vxlan_gro_complete;
 
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index a763c96..b4ba1d73 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -131,7 +131,6 @@ struct vxlan_sock {
 	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
-	struct udp_offload udp_offloads;
 	u32		  flags;
 };
 
-- 
2.8.0.rc2
