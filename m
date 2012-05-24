From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 19/21] datapath: Simplify vport lookup
Date: Thu, 24 May 2012 18:09:12 +0900
Message-ID: <1337850554-10339-20-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46675 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab2EXJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:29 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lookup is now only based on the net and tunnel type.
It should be possible to either get rid of the lookup alltogether
or push it into the GRE and CAPWAP implementations, but this
change is simpler for now

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/tunnel.c       | 110 +++---------------------------------------------
 datapath/tunnel.h       |  18 ++------
 datapath/vport-capwap.c |   7 +--
 datapath/vport-gre.c    |  10 ++---
 4 files changed, 16 insertions(+), 129 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index 39aa2af..a303d8d 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -56,18 +56,6 @@
 
 static struct hlist_head *port_table __read_mostly;
 
-/*
- * These are just used as an optimization: they don't require any kind of
- * synchronization because we could have just as easily read the value before
- * the port change happened.
- */
-static unsigned int key_local_remote_ports __read_mostly;
-static unsigned int key_remote_ports __read_mostly;
-static unsigned int key_multicast_ports __read_mostly;
-static unsigned int local_remote_ports __read_mostly;
-static unsigned int remote_ports __read_mostly;
-static unsigned int multicast_ports __read_mostly;
-
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36)
 #define rt_dst(rt) (rt->dst)
 #else
@@ -97,27 +85,6 @@ static void assign_config_rcu(struct vport *vport,
 	call_rcu(&old_config->rcu, free_config_rcu);
 }
 
-static unsigned int *find_port_pool(const struct tnl_mutable_config *mutable)
-{
-	bool is_multicast = ipv4_is_multicast(mutable->key.daddr);
-
-	if (mutable->flags & TNL_F_IN_KEY_MATCH) {
-		if (mutable->key.saddr)
-			return &local_remote_ports;
-		else if (is_multicast)
-			return &multicast_ports;
-		else
-			return &remote_ports;
-	} else {
-		if (mutable->key.saddr)
-			return &key_local_remote_ports;
-		else if (is_multicast)
-			return &key_multicast_ports;
-		else
-			return &key_remote_ports;
-	}
-}
-
 static u32 port_hash(const struct port_lookup_key *key)
 {
 	return jhash2((u32 *)key, (PORT_KEY_LEN / sizeof(u32)), 0);
@@ -137,8 +104,6 @@ static void port_table_add_port(struct vport *vport)
 	mutable = rtnl_dereference(tnl_vport->mutable);
 	hash = port_hash(&mutable->key);
 	hlist_add_head_rcu(&tnl_vport->hash_node, find_bucket(hash));
-
-	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))++;
 }
 
 static void port_table_remove_port(struct vport *vport)
@@ -146,12 +111,9 @@ static void port_table_remove_port(struct vport *vport)
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
 
 	hlist_del_init_rcu(&tnl_vport->hash_node);
-
-	(*find_port_pool(rtnl_dereference(tnl_vport->mutable)))--;
 }
 
-static struct vport *port_table_lookup(struct port_lookup_key *key,
-				       const struct tnl_mutable_config **pmutable)
+static struct vport *port_table_lookup(struct port_lookup_key *key)
 {
 	struct hlist_node *n;
 	struct hlist_head *bucket;
@@ -164,79 +126,21 @@ static struct vport *port_table_lookup(struct port_lookup_key *key,
 		struct tnl_mutable_config *mutable;
 
 		mutable = rcu_dereference_rtnl(tnl_vport->mutable);
-		if (!memcmp(&mutable->key, key, PORT_KEY_LEN)) {
-			*pmutable = mutable;
+		if (!memcmp(&mutable->key, key, PORT_KEY_LEN))
 			return tnl_vport_to_vport(tnl_vport);
-		}
 	}
 
 	return NULL;
 }
 
-struct vport *ovs_tnl_find_port(struct net *net, __be32 saddr, __be32 daddr,
-				__be64 key, int tunnel_type,
-				const struct tnl_mutable_config **mutable)
+struct vport *ovs_tnl_find_port(struct net *net, u32 tunnel_type)
 {
 	struct port_lookup_key lookup;
-	struct vport *vport;
-	bool is_multicast = ipv4_is_multicast(saddr);
 
 	port_key_set_net(&lookup, net);
-	lookup.saddr = saddr;
-	lookup.daddr = daddr;
-
-	/* First try for exact match on in_key. */
-	lookup.in_key = key;
-	lookup.tunnel_type = tunnel_type | TNL_T_KEY_EXACT;
-	if (!is_multicast && key_local_remote_ports) {
-		vport = port_table_lookup(&lookup, mutable);
-		if (vport)
-			return vport;
-	}
-	if (key_remote_ports) {
-		lookup.saddr = 0;
-		vport = port_table_lookup(&lookup, mutable);
-		if (vport)
-			return vport;
-
-		lookup.saddr = saddr;
-	}
-
-	/* Then try matches that wildcard in_key. */
-	lookup.in_key = 0;
-	lookup.tunnel_type = tunnel_type | TNL_T_KEY_MATCH;
-	if (!is_multicast && local_remote_ports) {
-		vport = port_table_lookup(&lookup, mutable);
-		if (vport)
-			return vport;
-	}
-	if (remote_ports) {
-		lookup.saddr = 0;
-		vport = port_table_lookup(&lookup, mutable);
-		if (vport)
-			return vport;
-	}
+	lookup.tunnel_type = tunnel_type;
 
-	if (is_multicast) {
-		lookup.saddr = 0;
-		lookup.daddr = saddr;
-		if (key_multicast_ports) {
-			lookup.tunnel_type = tunnel_type | TNL_T_KEY_EXACT;
-			lookup.in_key = key;
-			vport = port_table_lookup(&lookup, mutable);
-			if (vport)
-				return vport;
-		}
-		if (multicast_ports) {
-			lookup.tunnel_type = tunnel_type | TNL_T_KEY_MATCH;
-			lookup.in_key = 0;
-			vport = port_table_lookup(&lookup, mutable);
-			if (vport)
-				return vport;
-		}
-	}
-
-	return NULL;
+	return port_table_lookup(&lookup);
 }
 
 static void ecn_decapsulate(struct sk_buff *skb)
@@ -1008,11 +912,9 @@ static int tnl_set_config(struct net *net,
 			  struct tnl_mutable_config *mutable)
 {
 	const struct vport *old_vport;
-	const struct tnl_mutable_config *old_mutable;
 
 	mutable->flags = 0;
 	port_key_set_net(&mutable->key, net);
-	mutable->key.daddr = htonl(0);
 	mutable->key.tunnel_type = tnl_ops->tunnel_type;
 
 	mutable->tunnel_hlen = tnl_ops->hdr_len(mutable);
@@ -1021,7 +923,7 @@ static int tnl_set_config(struct net *net,
 
 	mutable->tunnel_hlen += sizeof(struct iphdr);
 
-	old_vport = port_table_lookup(&mutable->key, &old_mutable);
+	old_vport = port_table_lookup(&mutable->key);
 	if (old_vport && old_vport != cur_vport)
 		return -EEXIST;
 
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index 330df27..cddb88e 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -35,16 +35,9 @@
 
 /*
  * One of these goes in struct tnl_ops and in tnl_find_port().
- * These values are in the same namespace as other TNL_T_* values, so
- * only the least significant 10 bits are available to define protocol
- * identifiers.
  */
-#define TNL_T_PROTO_GRE		0
-#define TNL_T_PROTO_CAPWAP	1
-
-/* These flags are only needed when calling tnl_find_port(). */
-#define TNL_T_KEY_EXACT		(1 << 10)
-#define TNL_T_KEY_MATCH		(1 << 11)
+#define TNL_T_PROTO_GRE			0
+#define TNL_T_PROTO_CAPWAP		1
 
 /* Private flags not exposed to userspace in this form. */
 #define TNL_F_IN_KEY_MATCH	(1 << 16) /* Store the key in tun_id to
@@ -66,12 +59,9 @@
  * @tunnel_type: Set of TNL_T_* flags that define lookup.
  */
 struct port_lookup_key {
-	__be64 in_key;
 #ifdef CONFIG_NET_NS
 	struct net *net;
 #endif
-	__be32 saddr;
-	__be32 daddr;
 	u32    tunnel_type;
 };
 
@@ -212,9 +202,7 @@ const unsigned char *ovs_tnl_get_addr(const struct vport *vport);
 int ovs_tnl_send(struct vport *vport, struct sk_buff *skb);
 void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb);
 
-struct vport *ovs_tnl_find_port(struct net *net, __be32 saddr, __be32 daddr,
-				__be64 key, int tunnel_type,
-				const struct tnl_mutable_config **mutable);
+struct vport *ovs_tnl_find_port(struct net *net, u32 tunnel_type);
 bool ovs_tnl_frag_needed(struct vport *vport,
 			 const struct tnl_mutable_config *mutable,
 			 struct sk_buff *skb, unsigned int mtu,
diff --git a/datapath/vport-capwap.c b/datapath/vport-capwap.c
index f26a7d2..a180b87 100644
--- a/datapath/vport-capwap.c
+++ b/datapath/vport-capwap.c
@@ -314,7 +314,6 @@ error:
 static int capwap_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct vport *vport;
-	const struct tnl_mutable_config *mutable;
 	struct iphdr *iph;
 	struct ovs_key_ipv4_tunnel tun_key;
 	__be64 key = 0;
@@ -327,15 +326,13 @@ static int capwap_rcv(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	iph = ip_hdr(skb);
-	vport = ovs_tnl_find_port(sock_net(sk), iph->daddr, iph->saddr, key,
-				  TNL_T_PROTO_CAPWAP, &mutable);
+	vport = ovs_tnl_find_port(dev_net(skb->dev), TNL_T_PROTO_CAPWAP);
 	if (unlikely(!vport)) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 		goto error;
 	}
 
-	tun_key_init(&tun_key, iph,
-		     mutable->flags & TNL_F_IN_KEY_MATCH ? key : 0);
+	tun_key_init(&tun_key, iph, key);
 	OVS_CB(skb)->tun_key = &tun_key;
 
 	ovs_tnl_rcv(vport, skb);
diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
index f610097..8fab193 100644
--- a/datapath/vport-gre.c
+++ b/datapath/vport-gre.c
@@ -170,6 +170,8 @@ static int parse_header(struct iphdr *iph, __be16 *flags, __be64 *key)
 /* Called with rcu_read_lock and BH disabled. */
 static void gre_err(struct sk_buff *skb, u32 info)
 {
+#warning fix gre_err
+#if 0
 	struct vport *vport;
 	const struct tnl_mutable_config *mutable;
 	const int type = icmp_hdr(skb)->type;
@@ -292,6 +294,7 @@ out:
 	skb_set_mac_header(skb, orig_mac_header);
 	skb_set_network_header(skb, orig_nw_header);
 	skb->protocol = htons(ETH_P_IP);
+#endif
 }
 
 static bool check_checksum(struct sk_buff *skb)
@@ -324,7 +327,6 @@ static bool check_checksum(struct sk_buff *skb)
 static int gre_rcv(struct sk_buff *skb)
 {
 	struct vport *vport;
-	const struct tnl_mutable_config *mutable;
 	int hdr_len;
 	struct iphdr *iph;
 	struct ovs_key_ipv4_tunnel tun_key;
@@ -345,16 +347,14 @@ static int gre_rcv(struct sk_buff *skb)
 		goto error;
 
 	iph = ip_hdr(skb);
-	vport = ovs_tnl_find_port(dev_net(skb->dev), iph->daddr, iph->saddr, key,
-				  TNL_T_PROTO_GRE, &mutable);
+	vport = ovs_tnl_find_port(dev_net(skb->dev), TNL_T_PROTO_GRE);
 	if (unlikely(!vport)) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 		goto error;
 	}
 
 
-	tun_key_init(&tun_key, iph,
-		     mutable->flags & TNL_F_IN_KEY_MATCH ? key : 0);
+	tun_key_init(&tun_key, iph, key);
 	OVS_CB(skb)->tun_key = &tun_key;
 
 	__skb_pull(skb, hdr_len);
-- 
1.7.10.2.484.gcd07cc5
