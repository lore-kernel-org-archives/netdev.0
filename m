From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 02/17] net: Combine GENEVE and VXLAN port
 notifiers into single functions
Date: Wed, 15 Jun 2016 15:07:28 -0700
Message-ID: <20160615220728.15575.62132.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
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
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33268 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819AbcFOWHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:07:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id b13so11262843pat.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:07:30 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch merges the GENEVE and VXLAN code so that both functions pass
through a shared code path.  This way we can start the effort of using a
single function on the network device drivers to handle both of these
tunnel types.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c     |   48 +++-------------------
 drivers/net/vxlan.c      |   46 +++------------------
 include/net/udp_tunnel.h |   33 +++++++++++++++
 net/ipv4/udp_tunnel.c    |  102 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 149 insertions(+), 80 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index e5e33cd01082..d12ee3a92fb5 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -398,19 +398,7 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
 
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
+	udp_tunnel_notify_add_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
 }
 
 static int geneve_hlen(struct genevehdr *gh)
@@ -549,20 +537,7 @@ static struct geneve_sock *geneve_socket_create(struct net *net, __be16 port,
 
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
+	udp_tunnel_notify_add_rx_port(gs->sock, UDP_TUNNEL_TYPE_GENEVE);
 }
 
 static void __geneve_sock_release(struct geneve_sock *gs)
@@ -1164,29 +1139,20 @@ static struct device_type geneve_type = {
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
index 10ad41d60652..fa30e0238794 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -605,37 +605,13 @@ static int vxlan_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
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
+	udp_tunnel_notify_add_rx_port(vs->sock, UDP_TUNNEL_TYPE_VXLAN);
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
+	udp_tunnel_notify_del_rx_port(vs->sock, UDP_TUNNEL_TYPE_VXLAN);
 }
 
 /* Add new entry to forwarding table -- assumes lock held */
@@ -2508,30 +2484,22 @@ static struct device_type vxlan_type = {
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
