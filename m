From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 8/9] geneve: Move device hash table to geneve socket.
Date: Mon, 17 Aug 2015 14:11:44 -0700
Message-ID: <1439845905-31666-9-git-send-email-pshelar@nicira.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36493 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbHQVMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:12:07 -0400
Received: by pawq9 with SMTP id q9so18607029paw.3
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:12:07 -0700 (PDT)
In-Reply-To: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change simplifies Geneve Tunnel hash table management.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c | 76 ++++++++++++++++++++++++++++------------------------
 1 file changed, 41 insertions(+), 35 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index eb298ff..e47cdd9 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -40,7 +40,6 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 /* per-network namespace private data for this module */
 struct geneve_net {
 	struct list_head	geneve_list;
-	struct hlist_head	vni_list[VNI_HASH_SIZE];
 	struct list_head	sock_list;
 };
 
@@ -63,12 +62,12 @@ struct geneve_dev {
 
 struct geneve_sock {
 	bool			collect_md;
-	struct geneve_net	*gn;
 	struct list_head	list;
 	struct socket		*sock;
 	struct rcu_head		rcu;
 	int			refcnt;
 	struct udp_offload	udp_offloads;
+	struct hlist_head	vni_list[VNI_HASH_SIZE];
 };
 
 static inline __u32 geneve_net_vni_hash(u8 vni[3])
@@ -90,7 +89,7 @@ static __be64 vni_to_tunnel_id(const __u8 *vni)
 #endif
 }
 
-static struct geneve_dev *geneve_lookup(struct geneve_net *gn, __be16 port,
+static struct geneve_dev *geneve_lookup(struct geneve_sock *gs,
 					__be32 addr, u8 vni[])
 {
 	struct hlist_head *vni_list_head;
@@ -99,13 +98,11 @@ static struct geneve_dev *geneve_lookup(struct geneve_net *gn, __be16 port,
 
 	/* Find the device for this VNI */
 	hash = geneve_net_vni_hash(vni);
-	vni_list_head = &gn->vni_list[hash];
+	vni_list_head = &gs->vni_list[hash];
 	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
 		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
-		    addr == geneve->remote.sin_addr.s_addr &&
-		    port == geneve->dst_port) {
+		    addr == geneve->remote.sin_addr.s_addr)
 			return geneve;
-		}
 	}
 	return NULL;
 }
@@ -118,9 +115,7 @@ static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 /* geneve receive/decap routine */
 static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 {
-	struct inet_sock *sk = inet_sk(gs->sock->sk);
 	struct genevehdr *gnvh = geneve_hdr(skb);
-	struct geneve_net *gn = gs->gn;
 	struct metadata_dst *tun_dst = NULL;
 	struct geneve_dev *geneve = NULL;
 	struct pcpu_sw_netstats *stats;
@@ -130,8 +125,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	bool xnet;
 	int err;
 
-	iph = ip_hdr(skb); /* Still outer IP header... */
-
 	if (gs->collect_md) {
 		static u8 zero_vni[3];
 
@@ -139,10 +132,11 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 		addr = 0;
 	} else {
 		vni = gnvh->vni;
+		iph = ip_hdr(skb); /* Still outer IP header... */
 		addr = iph->saddr;
 	}
 
-	geneve = geneve_lookup(gn, sk->inet_sport, addr, vni);
+	geneve = geneve_lookup(gs, addr, vni);
 	if (!geneve)
 		goto drop;
 
@@ -419,6 +413,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	struct geneve_sock *gs;
 	struct socket *sock;
 	struct udp_tunnel_sock_cfg tunnel_cfg;
+	int h;
 
 	gs = kzalloc(sizeof(*gs), GFP_KERNEL);
 	if (!gs)
@@ -432,7 +427,8 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
 	gs->sock = sock;
 	gs->refcnt = 1;
-	gs->gn = gn;
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&gs->vni_list[h]);
 
 	/* Initialize the geneve udp offloads structure */
 	gs->udp_offloads.port = port;
@@ -446,7 +442,6 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
 	tunnel_cfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
-
 	list_add(&gs->list, &gn->sock_list);
 	return gs;
 }
@@ -471,19 +466,32 @@ static void geneve_sock_release(struct geneve_sock *gs)
 	kfree_rcu(gs, rcu);
 }
 
+static struct geneve_sock *geneve_find_sock(struct geneve_net *gn,
+					    __be16 dst_port)
+{
+	struct geneve_sock *gs;
+
+	list_for_each_entry(gs, &gn->sock_list, list) {
+		if (inet_sk(gs->sock->sk)->inet_sport == dst_port &&
+		    inet_sk(gs->sock->sk)->sk.sk_family == AF_INET) {
+			return gs;
+		}
+	}
+	return NULL;
+}
+
 static int geneve_open(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct net *net = geneve->net;
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
+	__u32 hash;
 
-	list_for_each_entry(gs, &gn->sock_list, list) {
-		if (inet_sk(gs->sock->sk)->inet_sport == geneve->dst_port &&
-		    inet_sk(gs->sock->sk)->sk.sk_family == AF_INET) {
-			gs->refcnt++;
-			goto out;
-		}
+	gs = geneve_find_sock(gn, geneve->dst_port);
+	if (gs) {
+		gs->refcnt++;
+		goto out;
 	}
 
 	gs = geneve_socket_create(net, geneve->dst_port, false);
@@ -494,6 +502,9 @@ out:
 	if (geneve->collect_md)
 		gs->collect_md = true;
 	geneve->sock = gs;
+
+	hash = geneve_net_vni_hash(geneve->vni);
+	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
 	return 0;
 }
 
@@ -505,6 +516,8 @@ static int geneve_stop(struct net_device *dev)
 	if (geneve->collect_md)
 		gs->collect_md = false;
 
+	if (!hlist_unhashed(&geneve->hlist))
+		hlist_del_rcu(&geneve->hlist);
 	geneve_sock_release(gs);
 	return 0;
 }
@@ -792,8 +805,8 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 			    __u16 dst_port, bool metadata)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	struct geneve_dev *t, *geneve = netdev_priv(dev);
-	__u32 hash;
+	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_dev *t;
 	int err;
 
 	geneve->net = net;
@@ -807,9 +820,12 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	if (IN_MULTICAST(ntohl(geneve->remote.sin_addr.s_addr)))
 		return -EINVAL;
 
-	t = geneve_lookup(gn, htons(dst_port), rem_addr, geneve->vni);
-	if (t)
-		return -EBUSY;
+	list_for_each_entry(t, &gn->geneve_list, next) {
+		if (!memcmp(geneve->vni, t->vni, sizeof(t->vni)) &&
+		    rem_addr == t->remote.sin_addr.s_addr &&
+		    htons(dst_port) == geneve->dst_port)
+			return -EBUSY;
+	}
 
 	geneve->ttl = ttl;
 	geneve->tos = tos;
@@ -821,8 +837,6 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 		return err;
 
 	list_add(&geneve->next, &gn->geneve_list);
-	hash = geneve_net_vni_hash(geneve->vni);
-	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
 	return 0;
 }
 
@@ -861,9 +875,6 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
-	if (!hlist_unhashed(&geneve->hlist))
-		hlist_del_rcu(&geneve->hlist);
-
 	list_del(&geneve->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -948,14 +959,9 @@ EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
 static __net_init int geneve_init_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
-	unsigned int h;
 
 	INIT_LIST_HEAD(&gn->geneve_list);
-
 	INIT_LIST_HEAD(&gn->sock_list);
-	for (h = 0; h < VNI_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&gn->vni_list[h]);
-
 	return 0;
 }
 
-- 
1.8.3.1
