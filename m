From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 03/17] gtp: make GTP sockets in gtp_newlink optional
Date: Mon, 23 Jan 2017 12:56:52 +0100
Message-ID: <20170123115706.4354-4-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:58164 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751080AbdAWMG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:56 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A fixed binding of gtp enabled socket to netdevice does not make
sense (GTP TEID are unique per socket and not per L3 IP device).

To untangle netdevice and gtp sockets without breaking the UAPI,
make per netdevice sockets optional.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 158 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 83 insertions(+), 75 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1df54d6..60946b7 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -276,30 +276,6 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	return ret;
 }
 
-static void gtp_encap_disable(struct gtp_dev *gtp)
-{
-	if (gtp->sock0 && gtp->sock0->sk) {
-		udp_sk(gtp->sock0->sk)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sock0->sk, NULL);
-	}
-	if (gtp->sock1u && gtp->sock1u->sk) {
-		udp_sk(gtp->sock1u->sk)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sock1u->sk, NULL);
-	}
-
-	gtp->sock0 = NULL;
-	gtp->sock1u = NULL;
-}
-
-static void gtp_encap_destroy(struct sock *sk)
-{
-	struct gtp_dev *gtp;
-
-	gtp = rcu_dereference_sk_user_data(sk);
-	if (gtp)
-		gtp_encap_disable(gtp);
-}
-
 /* UDP encapsulation receive handler. See net/ipv4/udp.c.
  * Return codes: 0: success, <0: error, >0: pass up to userspace UDP socket.
  */
@@ -363,6 +339,17 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
+static void gtp_encap_destroy(struct sock *sk)
+{
+	struct gtp_dev *gtp;
+
+	gtp = rcu_dereference_sk_user_data(sk);
+	if (gtp) {
+		udp_sk(sk)->encap_type = 0;
+		rcu_assign_sk_user_data(sk, NULL);
+	}
+}
+
 static int gtp_dev_init(struct net_device *dev)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
@@ -378,9 +365,6 @@ static int gtp_dev_init(struct net_device *dev)
 
 static void gtp_dev_uninit(struct net_device *dev)
 {
-	struct gtp_dev *gtp = netdev_priv(dev);
-
-	gtp_encap_disable(gtp);
 	free_percpu(dev->tstats);
 }
 
@@ -658,35 +642,32 @@ static void gtp_link_setup(struct net_device *dev)
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1, struct net *src_net);
+			    struct net *src_net, struct nlattr *data[]);
+static void gtp_encap_disable(struct gtp_dev *gtp);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	int hashsize, err, fd0, fd1;
+	int hashsize, err;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
 
-	if (!data[IFLA_GTP_FD0] || !data[IFLA_GTP_FD1])
-		return -EINVAL;
-
 	gtp = netdev_priv(dev);
 
-	fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
-	fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
-
-	err = gtp_encap_enable(dev, gtp, fd0, fd1, src_net);
-	if (err < 0)
-		goto out_err;
-
 	if (!data[IFLA_GTP_PDP_HASHSIZE])
 		hashsize = 1024;
 	else
 		hashsize = nla_get_u32(data[IFLA_GTP_PDP_HASHSIZE]);
 
+	if (data[IFLA_GTP_FD0] || data[IFLA_GTP_FD1]) {
+		err = gtp_encap_enable(dev, gtp, src_net, data);
+		if (err < 0)
+			goto out_err;
+	}
+
 	err = gtp_hashtable_new(gtp, hashsize);
 	if (err < 0)
-		goto out_encap;
+		goto out_socket;
 
 	err = register_netdevice(dev);
 	if (err < 0) {
@@ -703,7 +684,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 
 out_hashtable:
 	gtp_hashtable_free(gtp);
-out_encap:
+out_socket:
 	gtp_encap_disable(gtp);
 out_err:
 	return err;
@@ -713,8 +694,11 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
-	gtp_encap_disable(gtp);
 	gtp_hashtable_free(gtp);
+	if (gtp->sock0)
+		sockfd_put(gtp->sock0);
+	if (gtp->sock1u)
+		sockfd_put(gtp->sock1u);
 	list_del_rcu(&gtp->list);
 	unregister_netdevice_queue(dev, head);
 }
@@ -820,38 +804,63 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	kfree(gtp->tid_hash);
 }
 
-static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1, struct net *src_net)
+static struct socket *gtp_encap_enable_socket(int fd, int type,
+					      struct gtp_dev *gtp)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
-	struct socket *sock0, *sock1u;
+	struct socket *sock;
 	int err;
 
-	netdev_dbg(dev, "enable gtp on %d, %d\n", fd_gtp0, fd_gtp1);
+	pr_debug("enable gtp on %d, %d\n", fd, type);
 
-	sock0 = sockfd_lookup(fd_gtp0, &err);
-	if (sock0 == NULL) {
-		netdev_dbg(dev, "socket fd=%d not found (gtp0)\n", fd_gtp0);
-		return -ENOENT;
+	sock = sockfd_lookup(fd, &err);
+	if (!sock) {
+		pr_debug("gtp socket fd=%d not found\n", fd);
+		return NULL;
 	}
 
-	if (sock0->sk->sk_protocol != IPPROTO_UDP) {
-		netdev_dbg(dev, "socket fd=%d not UDP\n", fd_gtp0);
+	if (sock->sk->sk_protocol != IPPROTO_UDP) {
+		pr_debug("socket fd=%d not UDP\n", fd);
 		err = -EINVAL;
-		goto err1;
+		goto out_sock;
 	}
 
-	sock1u = sockfd_lookup(fd_gtp1, &err);
-	if (sock1u == NULL) {
-		netdev_dbg(dev, "socket fd=%d not found (gtp1u)\n", fd_gtp1);
-		err = -ENOENT;
-		goto err1;
+	tuncfg.sk_user_data = gtp;
+	tuncfg.encap_type = type;
+	tuncfg.encap_rcv = gtp_encap_recv;
+	tuncfg.encap_destroy = gtp_encap_destroy;
+
+	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
+	return sock;
+
+out_sock:
+	sockfd_put(sock);
+	return ERR_PTR(err);
+}
+
+static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
+			    struct net *src_net, struct nlattr *data[])
+{
+	struct socket *sock0 = NULL;
+	struct socket *sock1u = NULL;
+
+	if (data[IFLA_GTP_FD0]) {
+		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
+
+		sock0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp);
+		if (IS_ERR(sock0))
+			return PTR_ERR(sock0);
 	}
 
-	if (sock1u->sk->sk_protocol != IPPROTO_UDP) {
-		netdev_dbg(dev, "socket fd=%d not UDP\n", fd_gtp1);
-		err = -EINVAL;
-		goto err2;
+	if (data[IFLA_GTP_FD1]) {
+		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
+
+		sock1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		if (IS_ERR(sock1u)) {
+			if (sock0)
+				sockfd_put(sock0);
+			return PTR_ERR(sock1u);
+		}
 	}
 
 	netdev_dbg(dev, "enable gtp on %p, %p\n", sock0, sock1u);
@@ -860,22 +869,21 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 	gtp->sock1u = sock1u;
 	gtp->net = src_net;
 
-	tuncfg.sk_user_data = gtp;
-	tuncfg.encap_rcv = gtp_encap_recv;
-	tuncfg.encap_destroy = gtp_encap_destroy;
+	return 0;
+}
 
-	tuncfg.encap_type = UDP_ENCAP_GTP0;
-	setup_udp_tunnel_sock(sock_net(gtp->sock0->sk), gtp->sock0, &tuncfg);
+static void gtp_encap_disable_sock(struct socket *sock)
+{
+	if (!sock || !sock->sk)
+		return;
 
-	tuncfg.encap_type = UDP_ENCAP_GTP1U;
-	setup_udp_tunnel_sock(sock_net(gtp->sock1u->sk), gtp->sock1u, &tuncfg);
+	gtp_encap_destroy(sock->sk);
+}
 
-	err = 0;
-err2:
-	sockfd_put(sock1u);
-err1:
-	sockfd_put(sock0);
-	return err;
+static void gtp_encap_disable(struct gtp_dev *gtp)
+{
+	gtp_encap_disable_sock(gtp->sock0);
+	gtp_encap_disable_sock(gtp->sock1u);
 }
 
 static struct net_device *gtp_find_dev(struct net *net, int ifindex)
-- 
2.10.2
