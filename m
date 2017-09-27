From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 12/12] gtp: Allow configuring GTP interface as standalone
Date: Tue, 26 Sep 2017 21:58:03 -0700
Message-ID: <20170927045803.2477-13-tom@quantonium.net>
References: <20170927045803.2477-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:56423 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033421AbdI0E7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:59:10 -0400
Received: by mail-pf0-f180.google.com with SMTP id g65so6656866pfe.13
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:59:09 -0700 (PDT)
In-Reply-To: <20170927045803.2477-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new configuration of GTP interfaces that allow specifying a port to
listen on (as opposed to having to get sockets from a userspace control
plane). This allows GTP interfaces to be configured and the data path
tested without requiring a GTP-C daemon.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c        | 215 ++++++++++++++++++++++++++++++++++++-----------
 include/uapi/linux/gtp.h |   5 ++
 2 files changed, 169 insertions(+), 51 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1c580df4cfc5..dc1fcd3034af 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -93,6 +93,9 @@ struct gtp_dev {
 	struct sock		*sk0;
 	struct sock		*sk1u;
 
+	struct socket		*sock0;
+	struct socket		*sock1u;
+
 	struct net_device	*dev;
 
 	unsigned int		role;
@@ -451,26 +454,33 @@ static void gtp_encap_destroy(struct sock *sk)
 	}
 }
 
-static void gtp_encap_disable_sock(struct sock *sk)
+static void gtp_encap_release(struct gtp_dev *gtp)
 {
-	if (!sk)
-		return;
+	if (gtp->sk0) {
+		if (gtp->sock0) {
+			udp_tunnel_sock_release(gtp->sock0);
+			gtp->sock0 = NULL;
+		} else {
+			gtp_encap_destroy(gtp->sk0);
+		}
 
-	gtp_encap_destroy(sk);
-}
+		gtp->sk0 = NULL;
+	}
 
-static void gtp_encap_disable(struct gtp_dev *gtp)
-{
-	gtp_encap_disable_sock(gtp->sk0);
-	gtp_encap_disable_sock(gtp->sk1u);
+	if (gtp->sk1u) {
+		if (gtp->sock1u) {
+			udp_tunnel_sock_release(gtp->sock1u);
+			gtp->sock1u = NULL;
+		} else {
+			gtp_encap_destroy(gtp->sk1u);
+		}
+
+		gtp->sk1u = NULL;
+	}
 }
 
 static int gtp_dev_init(struct net_device *dev)
 {
-	struct gtp_dev *gtp = netdev_priv(dev);
-
-	gtp->dev = dev;
-
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
@@ -482,7 +492,8 @@ static void gtp_dev_uninit(struct net_device *dev)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
-	gtp_encap_disable(gtp);
+	gtp_encap_release(gtp);
+
 	free_percpu(dev->tstats);
 }
 
@@ -751,6 +762,8 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct udphdr) +
 				  sizeof(struct gtp0_header);
 
+	gtp->dev = dev;
+
 	gro_cells_init(&gtp->gro_cells, dev);
 }
 
@@ -764,13 +777,19 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		       struct netlink_ext_ack *extack)
 {
 	unsigned int role = GTP_ROLE_GGSN;
+	bool have_fd, have_ports;
 	bool is_ipv6 = false;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
 	int hashsize, err;
 
-	if (!data[IFLA_GTP_FD0] && !data[IFLA_GTP_FD1])
+	have_fd = !!data[IFLA_GTP_FD0] || !!data[IFLA_GTP_FD1];
+	have_ports = !!data[IFLA_GTP_PORT0] || !!data[IFLA_GTP_PORT1];
+
+	if (!(have_fd ^ have_ports)) {
+		/* Either got fd(s) or port(s) */
 		return -EINVAL;
+	}
 
 	if (data[IFLA_GTP_ROLE]) {
 		role = nla_get_u32(data[IFLA_GTP_ROLE]);
@@ -831,7 +850,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 out_hashtable:
 	gtp_hashtable_free(gtp);
 out_encap:
-	gtp_encap_disable(gtp);
+	gtp_encap_release(gtp);
 	return err;
 }
 
@@ -840,7 +859,7 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 	struct gtp_dev *gtp = netdev_priv(dev);
 
 	gro_cells_destroy(&gtp->gro_cells);
-	gtp_encap_disable(gtp);
+	gtp_encap_release(gtp);
 	gtp_hashtable_free(gtp);
 	list_del_rcu(&gtp->list);
 	unregister_netdevice_queue(dev, head);
@@ -851,6 +870,8 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_FD1]			= { .type = NLA_U32 },
 	[IFLA_GTP_PDP_HASHSIZE]		= { .type = NLA_U32 },
 	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
+	[IFLA_GTP_PORT0]		= { .type = NLA_U16 },
+	[IFLA_GTP_PORT1]		= { .type = NLA_U16 },
 };
 
 static int gtp_validate(struct nlattr *tb[], struct nlattr *data[],
@@ -949,11 +970,35 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	kfree(gtp->tid_hash);
 }
 
-static struct sock *gtp_encap_enable_socket(int fd, int type,
-					    struct gtp_dev *gtp,
-					    bool is_ipv6)
+static int gtp_encap_enable_sock(struct socket *sock, int type,
+				 struct gtp_dev *gtp)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
+
+	switch (type) {
+	case UDP_ENCAP_GTP0:
+		tuncfg.encap_rcv = gtp0_udp_encap_recv;
+		break;
+	case UDP_ENCAP_GTP1U:
+		tuncfg.encap_rcv = gtp1u_udp_encap_recv;
+		break;
+	default:
+		pr_debug("Unknown encap type %u\n", type);
+		return -EINVAL;
+	}
+
+	tuncfg.sk_user_data = gtp;
+	tuncfg.encap_type = type;
+	tuncfg.encap_destroy = gtp_encap_destroy;
+
+	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
+
+	return 0;
+}
+
+static struct sock *gtp_encap_enable_fd(int fd, int type, struct gtp_dev *gtp,
+					bool is_ipv6)
+{
 	struct socket *sock;
 	struct sock *sk;
 	int err;
@@ -986,60 +1031,128 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 	sk = sock->sk;
 	sock_hold(sk);
 
-	switch (type) {
-	case UDP_ENCAP_GTP0:
-		tuncfg.encap_rcv = gtp0_udp_encap_recv;
-		break;
-	case UDP_ENCAP_GTP1U:
-		tuncfg.encap_rcv = gtp1u_udp_encap_recv;
-		break;
-	default:
-		pr_debug("Unknown encap type %u\n", type);
-		sk = ERR_PTR(-EINVAL);
-		goto out_sock;
-	}
-
-	tuncfg.sk_user_data = gtp;
-	tuncfg.encap_type = type;
-	tuncfg.encap_destroy = gtp_encap_destroy;
-
-	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
+	err = gtp_encap_enable_sock(sock, type, gtp);
+	if (err < 0)
+		sk = ERR_PTR(err);
 
 out_sock:
 	sockfd_put(sock);
 	return sk;
 }
 
+static struct socket *gtp_create_sock(struct net *net, bool ipv6,
+				      __be16 port, u32 flags)
+{
+	struct socket *sock;
+	struct udp_port_cfg udp_conf;
+	int err;
+
+	memset(&udp_conf, 0, sizeof(udp_conf));
+
+#if GTP_IPV6
+	if (ipv6) {
+		udp_conf.family = AF_INET6;
+		udp_conf.ipv6_v6only = 1;
+	} else {
+		udp_conf.family = AF_INET;
+	}
+#else
+	udp_conf.family = AF_INET;
+#endif
+
+	udp_conf.local_udp_port = port;
+
+	/* Open UDP socket */
+	err = udp_sock_create(net, &udp_conf, &sock);
+	if (err)
+		return ERR_PTR(err);
+
+	return sock;
+}
+
 static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[],
 			    bool is_ipv6)
 {
+	int err;
+
+	struct socket *sock0 = NULL, *sock1u = NULL;
 	struct sock *sk0 = NULL, *sk1u = NULL;
 
 	if (data[IFLA_GTP_FD0]) {
 		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 
-		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp,
-					      is_ipv6);
-		if (IS_ERR(sk0))
-			return PTR_ERR(sk0);
+		sk0 = gtp_encap_enable_fd(fd0, UDP_ENCAP_GTP0, gtp, is_ipv6);
+		if (IS_ERR(sk0)) {
+			err = PTR_ERR(sk0);
+			sk0 = NULL;
+			goto out_err;
+		}
+	} else if (data[IFLA_GTP_PORT0]) {
+		__be16 port = nla_get_u16(data[IFLA_GTP_PORT0]);
+
+		sock0 = gtp_create_sock(dev_net(gtp->dev), is_ipv6, port, 0);
+		if (IS_ERR(sock0)) {
+			err = PTR_ERR(sock0);
+			sock0 = NULL;
+			goto out_err;
+		}
+
+		err = gtp_encap_enable_sock(sock0, UDP_ENCAP_GTP0, gtp);
+		if (err)
+			goto out_err;
 	}
 
 	if (data[IFLA_GTP_FD1]) {
 		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
-		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp,
-					       is_ipv6);
+		sk1u = gtp_encap_enable_fd(fd1, UDP_ENCAP_GTP1U, gtp, is_ipv6);
 		if (IS_ERR(sk1u)) {
-			if (sk0)
-				gtp_encap_disable_sock(sk0);
-			return PTR_ERR(sk1u);
+			err = PTR_ERR(sk1u);
+			sk1u = NULL;
+			goto out_err;
+		}
+	} else if (data[IFLA_GTP_PORT1]) {
+		__be16 port = nla_get_u16(data[IFLA_GTP_PORT1]);
+
+		sock1u = gtp_create_sock(dev_net(gtp->dev), is_ipv6, port, 0);
+		if (IS_ERR(sock1u)) {
+			err = PTR_ERR(sock1u);
+			sock1u = NULL;
+			goto out_err;
 		}
+
+		err = gtp_encap_enable_sock(sock1u, UDP_ENCAP_GTP1U, gtp);
+		if (err)
+			goto out_err;
+	}
+
+	if (sock0) {
+		gtp->sock0 = sock0;
+		gtp->sk0 = sock0->sk;
+	} else {
+		gtp->sk0 = sk0;
 	}
 
-	gtp->sk0 = sk0;
-	gtp->sk1u = sk1u;
+	if (sock1u) {
+		gtp->sock1u = sock1u;
+		gtp->sk1u = sock1u->sk;
+	} else {
+		gtp->sk1u = sk1u;
+	}
 
 	return 0;
+
+out_err:
+	if (sk0)
+		gtp_encap_destroy(sk0);
+	if (sk1u)
+		gtp_encap_destroy(sk1u);
+	if (sock0)
+		udp_tunnel_sock_release(sock0);
+	if (sock1u)
+		udp_tunnel_sock_release(sock1u);
+
+	return err;
 }
 
 static struct gtp_dev *gtp_find_dev(struct net *src_net, struct nlattr *nla[])
@@ -1624,8 +1737,8 @@ static const struct genl_ops gtp_genl_ops[] = {
 };
 
 static struct genl_family gtp_genl_family __ro_after_init = {
-	.name		= "gtp",
-	.version	= 0,
+	.name		= GTP_GENL_NAME,
+	.version	= GTP_GENL_VERSION,
 	.hdrsize	= 0,
 	.maxattr	= GTPA_MAX,
 	.netnsok	= true,
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index 8eec519fa754..0da18aa88be8 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -9,6 +9,11 @@ enum gtp_genl_cmds {
 	GTP_CMD_MAX,
 };
 
+/* NETLINK_GENERIC related info
+ */
+#define GTP_GENL_NAME		"gtp"
+#define GTP_GENL_VERSION	0
+
 enum gtp_version {
 	GTP_V0 = 0,
 	GTP_V1,
-- 
2.11.0
