From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 02/17] net: Combine GENEVE and VXLAN port
 notifiers into single functions
Date: Thu, 16 Jun 2016 12:20:52 -0700
Message-ID: <20160616192052.20872.92437.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33425 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcFPTU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:20:56 -0400
Received: by mail-pa0-f50.google.com with SMTP id b13so20772236pat.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:20:56 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch merges the GENEVE and VXLAN code so that both functions pass
through a shared code path.  This way we can start the effort of using a
single function on the network device drivers to handle both of these
tunnel types.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c     |   58 +++-----------------------
 drivers/net/vxlan.c      |   60 ++++-----------------------
 include/net/udp_tunnel.h |   33 +++++++++++++++
 net/ipv4/udp_tunnel.c    |  102 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 151 insertions(+), 102 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index e5e33cd01082..af6f676ca444 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -396,23 +396,6 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 	return sock;
 }
 
-static void geneve_notify_add_rx_port(struct geneve_sock *gs)
-{
-	struct net_device *dev;
-	struct sock *sk = gs->sock->sk;
-	struct net *net = sock_net(sk);
-	sa_family_t sa_family = geneve_get_sk_family(gs);
-	__be16 port = inet_sk(sk)->inet_sport;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_add_geneve_port)
-			dev->netdev_ops->ndo_add_geneve_port(dev, sa_family,
-							     port);
-	}
-	rcu_read_unlock();
-}
-
 static int geneve_hlen(struct genevehdr *gh)
 {
 	return sizeof(*gh) + gh->opt_len * 4;
@@ -532,7 +515,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 		INIT_HLIST_HEAD(&gs->vni_list[h]);
 
 	/* Initialize the geneve udp offloads structure */
-	geneve_notify_add_rx_port(gs);
+	udp_tunnel_notify_add_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
 
 	/* Mark socket as an encapsulation socket */
 	memset(&tunnel_cfg, 0, sizeof(tunnel_cfg));
@@ -547,31 +530,13 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 	return gs;
 }
 
-static void geneve_notify_del_rx_port(struct geneve_sock *gs)
-{
-	struct net_device *dev;
-	struct sock *sk = gs->sock->sk;
-	struct net *net = sock_net(sk);
-	sa_family_t sa_family = geneve_get_sk_family(gs);
-	__be16 port = inet_sk(sk)->inet_sport;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_del_geneve_port)
-			dev->netdev_ops->ndo_del_geneve_port(dev, sa_family,
-							     port);
-	}
-
-	rcu_read_unlock();
-}
-
 static void __geneve_sock_release(struct geneve_sock *gs)
 {
 	if (!gs || --gs->refcnt)
 		return;
 
 	list_del(&gs->list);
-	geneve_notify_del_rx_port(gs);
+	udp_tunnel_notify_del_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
 	udp_tunnel_sock_release(gs->sock);
 	kfree_rcu(gs, rcu);
 }
@@ -1164,29 +1129,20 @@ static struct device_type geneve_type = {
 	.name = "geneve",
 };
 
-/* Calls the ndo_add_geneve_port of the caller in order to
+/* Calls the ndo_add_udp_enc_port of the caller in order to
  * supply the listening GENEVE udp ports. Callers are expected
- * to implement the ndo_add_geneve_port.
+ * to implement the ndo_add_udp_enc_port.
  */
 static void geneve_push_rx_ports(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
-	sa_family_t sa_family;
-	struct sock *sk;
-	__be16 port;
-
-	if (!dev->netdev_ops->ndo_add_geneve_port)
-		return;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(gs, &gn->sock_list, list) {
-		sk = gs->sock->sk;
-		sa_family = sk->sk_family;
-		port = inet_sk(sk)->inet_sport;
-		dev->netdev_ops->ndo_add_geneve_port(dev, sa_family, port);
-	}
+	list_for_each_entry_rcu(gs, &gn->sock_list, list)
+		udp_tunnel_push_rx_port(dev, gs->sock,
+					UDP_TUNNEL_TYPE_GENEVE);
 	rcu_read_unlock();
 }
 
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 10ad41d60652..adbd979da22d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -602,42 +602,6 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 	return eth_gro_complete(skb, nhoff + sizeof(struct vxlanhdr));
 }
 
-/* Notify netdevs that UDP port started listening */
-static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
-{
-	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
-	struct net *net = sock_net(sk);
-	sa_family_t sa_family = vxlan_get_sk_family(vs);
-	__be16 port = inet_sk(sk)->inet_sport;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_add_vxlan_port)
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
-	}
-	rcu_read_unlock();
-}
-
-/* Notify netdevs that UDP port is no more listening */
-static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
-{
-	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
-	struct net *net = sock_net(sk);
-	sa_family_t sa_family = vxlan_get_sk_family(vs);
-	__be16 port = inet_sk(sk)->inet_sport;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		if (dev->netdev_ops->ndo_del_vxlan_port)
-			dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
-							    port);
-	}
-	rcu_read_unlock();
-}
-
 /* Add new entry to forwarding table -- assumes lock held */
 static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 			    const u8 *mac, union vxlan_addr *ip,
@@ -1033,7 +997,8 @@ static bool __vxlan_sock_release_prep(struct vxlan_sock *vs)
 	vn = net_generic(sock_net(vs->sock->sk), vxlan_net_id);
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
-	vxlan_notify_del_rx_port(vs);
+	udp_tunnel_notify_del_rx_port(vs->sock,
+				      UDP_TUNNEL_TYPE_VXLAN);
 	spin_unlock(&vn->sock_lock);
 
 	return true;
@@ -2508,30 +2473,22 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-/* Calls the ndo_add_vxlan_port of the caller in order to
+/* Calls the ndo_add_udp_enc_port of the caller in order to
  * supply the listening VXLAN udp ports. Callers are expected
- * to implement the ndo_add_vxlan_port.
+ * to implement the ndo_add_udp_enc_port.
  */
 static void vxlan_push_rx_ports(struct net_device *dev)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	sa_family_t sa_family;
-	__be16 port;
 	unsigned int i;
 
-	if (!dev->netdev_ops->ndo_add_vxlan_port)
-		return;
-
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
-		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
-			port = inet_sk(vs->sock->sk)->inet_sport;
-			sa_family = vxlan_get_sk_family(vs);
-			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
-							    port);
-		}
+		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist)
+			udp_tunnel_push_rx_port(dev, vs->sock,
+						UDP_TUNNEL_TYPE_VXLAN);
 	}
 	spin_unlock(&vn->sock_lock);
 }
@@ -2733,7 +2690,8 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 
 	spin_lock(&vn->sock_lock);
 	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
-	vxlan_notify_add_rx_port(vs);
+	udp_tunnel_notify_add_rx_port(sock,
+				      UDP_TUNNEL_TYPE_VXLAN);
 	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 59019562d14c..71afbea873a0 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -84,6 +84,39 @@ struct udp_tunnel_sock_cfg {
 void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 			   struct udp_tunnel_sock_cfg *sock_cfg);
 
+/* -- List of parsable UDP tunnel types --
+ *
+ * Adding to this list will result in serious debate.  The main issue is
+ * that this list is essentially a list of workarounds for either poorly
+ * designed tunnels, or poorly designed device offloads.
+ *
+ * The parsing supported via these types should really be used for Rx
+ * traffic only as the network stack will have already inserted offsets for
+ * the location of the headers in the skb.  In addition any ports that are
+ * pushed should be kept within the namespace without leaking to other
+ * devices such as VFs or other ports on the same device.
+ *
+ * It is strongly encouraged to use CHECKSUM_COMPLETE for Rx to avoid the
+ * need to use this for Rx checksum offload.  It should not be necessary to
+ * call this function to perform Tx offloads on outgoing traffic.
+ */
+enum udp_parsable_tunnel_type {
+	UDP_TUNNEL_TYPE_VXLAN,		/* RFC 7348 */
+	UDP_TUNNEL_TYPE_GENEVE,		/* draft-ietf-nvo3-geneve */
+};
+
+struct udp_tunnel_info {
+	unsigned short type;
+	sa_family_t sa_family;
+	__be16 port;
+};
+
+/* Notify network devices of offloadable types */
+void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned short type);
+void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type);
+void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type);
+
 /* Transmit the skb using UDP encapsulation. */
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 47f12c73d959..8174753e6494 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -76,6 +76,108 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 
+static void __udp_tunnel_push_rx_port(struct net_device *dev,
+				      struct udp_tunnel_info *ti)
+{
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (!dev->netdev_ops->ndo_add_vxlan_port)
+			break;
+
+		dev->netdev_ops->ndo_add_vxlan_port(dev,
+						    ti->sa_family,
+						    ti->port);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (!dev->netdev_ops->ndo_add_geneve_port)
+			break;
+
+		dev->netdev_ops->ndo_add_geneve_port(dev,
+						     ti->sa_family,
+						     ti->port);
+		break;
+	default:
+		break;
+	}
+}
+
+void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned short type)
+{
+	struct sock *sk = sock->sk;
+	struct udp_tunnel_info ti;
+
+	ti.type = type;
+	ti.sa_family = sk->sk_family;
+	ti.port = inet_sk(sk)->inet_sport;
+
+	__udp_tunnel_push_rx_port(dev, &ti);
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_push_rx_port);
+
+/* Notify netdevs that UDP port started listening */
+void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned short type)
+{
+	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
+	struct udp_tunnel_info ti;
+	struct net_device *dev;
+
+	ti.type = type;
+	ti.sa_family = sk->sk_family;
+	ti.port = inet_sk(sk)->inet_sport;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
+		__udp_tunnel_push_rx_port(dev, &ti);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_notify_add_rx_port);
+
+static void __udp_tunnel_pull_rx_port(struct net_device *dev,
+				      struct udp_tunnel_info *ti)
+{
+	switch (ti->type) {
+	case UDP_TUNNEL_TYPE_VXLAN:
+		if (!dev->netdev_ops->ndo_del_vxlan_port)
+			break;
+
+		dev->netdev_ops->ndo_del_vxlan_port(dev,
+						    ti->sa_family,
+						    ti->port);
+		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		if (!dev->netdev_ops->ndo_del_geneve_port)
+			break;
+
+		dev->netdev_ops->ndo_del_geneve_port(dev,
+						     ti->sa_family,
+						     ti->port);
+		break;
+	default:
+		break;
+	}
+}
+
+/* Notify netdevs that UDP port is no more listening */
+void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned short type)
+{
+	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
+	struct udp_tunnel_info ti;
+	struct net_device *dev;
+
+	ti.type = type;
+	ti.sa_family = sk->sk_family;
+	ti.port = inet_sk(sk)->inet_sport;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
+		__udp_tunnel_pull_rx_port(dev, &ti);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_notify_del_rx_port);
+
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
 			 __be16 df, __be16 src_port, __be16 dst_port,
