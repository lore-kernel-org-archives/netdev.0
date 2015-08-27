From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v5 net-next 8/8] geneve: Move device hash table to geneve socket.
Date: Wed, 26 Aug 2015 23:46:55 -0700
Message-ID: <1440658015-13028-9-git-send-email-pshelar@nicira.com>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36180 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbbH0GrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:47:11 -0400
Received: by padfo6 with SMTP id fo6so72709pad.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:47:11 -0700 (PDT)
In-Reply-To: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change simplifies Geneve Tunnel hash table management.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
Reviewed-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c |   43 +++++++++++++++++--------------------------
 1 files changed, 17 insertions(+), 26 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 90d4d43..4357bae 100644
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
@@ -129,8 +124,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	__be32 addr;
 	int err;
 
-	iph = ip_hdr(skb); /* Still outer IP header... */
-
 	if (gs->collect_md) {
 		static u8 zero_vni[3];
 
@@ -138,10 +131,11 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
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
 
@@ -410,6 +404,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	struct geneve_sock *gs;
 	struct socket *sock;
 	struct udp_tunnel_sock_cfg tunnel_cfg;
+	int h;
 
 	gs = kzalloc(sizeof(*gs), GFP_KERNEL);
 	if (!gs)
@@ -423,7 +418,8 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
 	gs->sock = sock;
 	gs->refcnt = 1;
-	gs->gn = gn;
+	for (h = 0; h < VNI_HASH_SIZE; ++h)
+		INIT_HLIST_HEAD(&gs->vni_list[h]);
 
 	/* Initialize the geneve udp offloads structure */
 	gs->udp_offloads.port = port;
@@ -437,7 +433,6 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	tunnel_cfg.encap_rcv = geneve_udp_encap_recv;
 	tunnel_cfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
-
 	list_add(&gs->list, &gn->sock_list);
 	return gs;
 }
@@ -482,6 +477,7 @@ static int geneve_open(struct net_device *dev)
 	struct net *net = geneve->net;
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
+	__u32 hash;
 
 	gs = geneve_find_sock(gn, geneve->dst_port);
 	if (gs) {
@@ -496,14 +492,20 @@ static int geneve_open(struct net_device *dev)
 out:
 	gs->collect_md = geneve->collect_md;
 	geneve->sock = gs;
+
+	hash = geneve_net_vni_hash(geneve->vni);
+	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
 	return 0;
 }
 
 static int geneve_stop(struct net_device *dev)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
+	struct geneve_sock *gs = geneve->sock;
 
-	geneve_sock_release(geneve->sock);
+	if (!hlist_unhashed(&geneve->hlist))
+		hlist_del_rcu(&geneve->hlist);
+	geneve_sock_release(gs);
 	return 0;
 }
 
@@ -808,7 +810,6 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *t, *geneve = netdev_priv(dev);
 	bool tun_collect_md, tun_on_same_port;
-	__u32 hash;
 	int err;
 
 	if (metadata) {
@@ -850,8 +851,6 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 		return err;
 
 	list_add(&geneve->next, &gn->geneve_list);
-	hash = geneve_net_vni_hash(geneve->vni);
-	hlist_add_head_rcu(&geneve->hlist, &gn->vni_list[hash]);
 	return 0;
 }
 
@@ -890,9 +889,6 @@ static void geneve_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 
-	if (!hlist_unhashed(&geneve->hlist))
-		hlist_del_rcu(&geneve->hlist);
-
 	list_del(&geneve->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -977,14 +973,9 @@ EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
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
1.7.1
