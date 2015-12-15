From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 2/2] udp: restrict offloads to one namespace
Date: Tue, 15 Dec 2015 21:01:54 +0100
Message-ID: <1450209714-26037-2-git-send-email-hannes@stressinduktion.org>
References: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59503 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932290AbbLOUCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 15:02:07 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id EBD6C21F45
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:02:06 -0500 (EST)
In-Reply-To: <1450209714-26037-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp tunnel offloads tend to aggregate datagrams based on inner
headers. gro engine gets notified by tunnel implementations about
possible offloads. The match is solely based on the port number.

Imagine a tunnel bound to port 53, the offloading will look into all
DNS packets and tries to aggregate them based on the inner data found
within. This could lead to data corruption and malformed DNS packets.

While this patch minimizes the problem and helps an administrator to find
the issue by querying ip tunnel/fou, a better way would be to match on
the specific destination ip address so if a user space socket is bound
to the same address it will conflict.

Cc: Tom Herbert <tom@herbertland.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c   |  2 +-
 drivers/net/vxlan.c    |  2 +-
 include/net/protocol.h |  2 +-
 net/ipv4/fou.c         |  2 +-
 net/ipv4/udp_offload.c | 10 +++++++---
 5 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index c2b79f5d1c89b6..b70ce46a5e7040 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -376,7 +376,7 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 	int err;
 
 	if (sa_family == AF_INET) {
-		err = udp_add_offload(&gs->udp_offloads);
+		err = udp_add_offload(sock_net(sk), &gs->udp_offloads);
 		if (err)
 			pr_warn("geneve: udp_add_offload failed with status %d\n",
 				err);
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ba363cedef8082..2428175c4dd4bb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -621,7 +621,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 	int err;
 
 	if (sa_family == AF_INET) {
-		err = udp_add_offload(&vs->udp_offloads);
+		err = udp_add_offload(net, &vs->udp_offloads);
 		if (err)
 			pr_warn("vxlan: udp_add_offload failed with status %d\n", err);
 	}
diff --git a/include/net/protocol.h b/include/net/protocol.h
index d6fcc1fcdb5b09..da689f5432dee2 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -107,7 +107,7 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
 void inet_register_protosw(struct inet_protosw *p);
 void inet_unregister_protosw(struct inet_protosw *p);
 
-int  udp_add_offload(struct udp_offload *prot);
+int  udp_add_offload(struct net *net, struct udp_offload *prot);
 void udp_del_offload(struct udp_offload *prot);
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index bd903fe0f7508d..976f0dcf699197 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -498,7 +498,7 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 	sk->sk_allocation = GFP_ATOMIC;
 
 	if (cfg->udp_config.family == AF_INET) {
-		err = udp_add_offload(&fou->udp_offloads);
+		err = udp_add_offload(net, &fou->udp_offloads);
 		if (err)
 			goto error;
 	}
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f9386160cbee02..5d396b96ae8bb9 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -21,6 +21,7 @@ static struct udp_offload_priv __rcu *udp_offload_base __read_mostly;
 
 struct udp_offload_priv {
 	struct udp_offload	*offload;
+	possible_net_t	net;
 	struct rcu_head		rcu;
 	struct udp_offload_priv __rcu *next;
 };
@@ -241,13 +242,14 @@ out:
 	return segs;
 }
 
-int udp_add_offload(struct udp_offload *uo)
+int udp_add_offload(struct net *net, struct udp_offload *uo)
 {
 	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
 
 	if (!new_offload)
 		return -ENOMEM;
 
+	write_pnet(&new_offload->net, net);
 	new_offload->offload = uo;
 
 	spin_lock(&udp_offload_lock);
@@ -311,7 +313,8 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	rcu_read_lock();
 	uo_priv = rcu_dereference(udp_offload_base);
 	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-		if (uo_priv->offload->port == uh->dest &&
+		if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
+		    uo_priv->offload->port == uh->dest &&
 		    uo_priv->offload->callbacks.gro_receive)
 			goto unflush;
 	}
@@ -389,7 +392,8 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 
 	uo_priv = rcu_dereference(udp_offload_base);
 	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-		if (uo_priv->offload->port == uh->dest &&
+		if (net_eq(read_pnet(&uo_priv->net), dev_net(skb->dev)) &&
+		    uo_priv->offload->port == uh->dest &&
 		    uo_priv->offload->callbacks.gro_complete)
 			break;
 	}
-- 
2.5.0
