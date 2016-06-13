From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 01/15] net: Combine GENEVE and VXLAN port offload
 notifiers into single functions
Date: Mon, 13 Jun 2016 10:47:54 -0700
Message-ID: <20160613174754.15186.37885.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34364 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161277AbcFMRsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:03 -0400
Received: by mail-pa0-f48.google.com with SMTP id bz2so47751727pad.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:02 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch merges the GENEVE and VXLAN code so that both functions pass
through a shared code path.  This way we can start the effort of using a
single function on the network device drivers to handle both of these
tunnel offload types.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c     |   48 ++++-------------------------
 drivers/net/vxlan.c      |   46 ++++-----------------------
 include/net/udp_tunnel.h |   12 +++++++
 net/ipv4/udp_tunnel.c    |   77 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 103 insertions(+), 80 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index cadefe4fdaa2..f5ce41532cf4 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -399,19 +399,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 
 static void geneve_notify_add_rx_port(struct geneve_sock *gs)
 {
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
+	udp_tunnel_notify_add_rx_port(gs->sock, UDP_ENC_OFFLOAD_TYPE_GENEVE);
 }
 
 static int geneve_hlen(struct genevehdr *gh)
@@ -550,20 +538,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
 static void geneve_notify_del_rx_port(struct geneve_sock *gs)
 {
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
+	udp_tunnel_notify_add_rx_port(gs->sock, UDP_ENC_OFFLOAD_TYPE_GENEVE);
 }
 
 static void __geneve_sock_release(struct geneve_sock *gs)
@@ -1165,29 +1140,20 @@ static struct device_type geneve_type = {
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
+					UDP_ENC_OFFLOAD_TYPE_GENEVE);
 	rcu_read_unlock();
 }
 
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f999db2f97b4..43f634282726 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -622,37 +622,13 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 /* Notify netdevs that UDP port started listening */
 static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
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
+	udp_tunnel_notify_add_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
 }
 
 /* Notify netdevs that UDP port is no more listening */
 static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
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
+	udp_tunnel_notify_del_rx_port(vs->sock, UDP_ENC_OFFLOAD_TYPE_VXLAN);
 }
 
 /* Add new entry to forwarding table -- assumes lock held */
@@ -2525,30 +2501,22 @@ static struct device_type vxlan_type = {
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
+						UDP_ENC_OFFLOAD_TYPE_VXLAN);
 	}
 	spin_unlock(&vn->sock_lock);
 }
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 9d14f707e534..704f931fd9ad 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -84,6 +84,18 @@ struct udp_tunnel_sock_cfg {
 void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 			   struct udp_tunnel_sock_cfg *sock_cfg);
 
+/* List of offloadable UDP tunnel types */
+enum udp_enc_offloads {
+	UDP_ENC_OFFLOAD_TYPE_VXLAN,	/* RFC 7348 */
+	UDP_ENC_OFFLOAD_TYPE_GENEVE,	/* draft-ietf-nvo3-geneve */
+};
+
+/* Notify network devices of offloadable types */
+void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned int type);
+void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned int type);
+void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned int type);
+
 /* Transmit the skb using UDP encapsulation. */
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 47f12c73d959..d575b70644e3 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -76,6 +76,83 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 
+void udp_tunnel_push_rx_port(struct net_device *dev, struct socket *sock,
+			     unsigned int type)
+{
+	struct sock *sk = sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
+
+	switch (type) {
+	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
+		if (!dev->netdev_ops->ndo_add_vxlan_port)
+			break;
+
+		dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family, port);
+		break;
+	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
+		if (!dev->netdev_ops->ndo_add_geneve_port)
+			break;
+
+		dev->netdev_ops->ndo_add_geneve_port(dev, sa_family, port);
+		break;
+	default:
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_push_rx_port);
+
+/* Notify netdevs that UDP port started listening */
+void udp_tunnel_notify_add_rx_port(struct socket *sock, unsigned int type)
+{
+	struct net *net = sock_net(sock->sk);
+	struct net_device *dev;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
+		udp_tunnel_push_rx_port(dev, sock, type);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_notify_add_rx_port);
+
+static void udp_tunnel_pull_rx_port(struct net_device *dev,
+				    struct socket *sock, unsigned int type)
+{
+	struct sock *sk = sock->sk;
+	sa_family_t sa_family = sk->sk_family;
+	__be16 port = inet_sk(sk)->inet_sport;
+
+	switch (type) {
+	case UDP_ENC_OFFLOAD_TYPE_VXLAN:
+		if (!dev->netdev_ops->ndo_del_vxlan_port)
+			break;
+
+		dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family, port);
+		break;
+	case UDP_ENC_OFFLOAD_TYPE_GENEVE:
+		if (!dev->netdev_ops->ndo_del_geneve_port)
+			break;
+
+		dev->netdev_ops->ndo_del_geneve_port(dev, sa_family, port);
+		break;
+	default:
+		break;
+	}
+}
+
+/* Notify netdevs that UDP port is no more listening */
+void udp_tunnel_notify_del_rx_port(struct socket *sock, unsigned int type)
+{
+	struct net_device *dev;
+	struct net *net = sock_net(sock->sk);
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
+		udp_tunnel_pull_rx_port(dev, sock, type);
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_notify_del_rx_port);
+
 void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
 			 __be16 df, __be16 src_port, __be16 dst_port,
