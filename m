From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 2/7] gtp: make GTP sockets in gtp_newlink optional
Date: Thu,  9 Mar 2017 17:42:57 +0100
Message-ID: <20170309164302.13550-3-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:41448 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932721AbdCIQn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:29 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having both GTPv0-U and GTPv1-U is not always desirable.
Fallback from GTPv1-U to GTPv0-U was depreciated from 3GPP
Rel-8 onwards. Post Rel-8 implementation are discuraged
from listening on the v0 port (see 3GPP TS 29.281, Sect. 1).

A future change will completely decouple the sockets from the
network device. Till then, at least one of the sockets needs to
be specified (either v0 or v1), the other is optional.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 148 ++++++++++++++++++++++++++++--------------------------
 1 file changed, 78 insertions(+), 70 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index e1b5af3..9aa2b35 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -259,30 +259,30 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
 }
 
-static void gtp_encap_disable(struct gtp_dev *gtp)
-{
-	if (gtp->sk0) {
-		udp_sk(gtp->sk0)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sk0, NULL);
-		sock_put(gtp->sk0);
-	}
-	if (gtp->sk1u) {
-		udp_sk(gtp->sk1u)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sk1u, NULL);
-		sock_put(gtp->sk1u);
-	}
-
-	gtp->sk0 = NULL;
-	gtp->sk1u = NULL;
-}
-
 static void gtp_encap_destroy(struct sock *sk)
 {
 	struct gtp_dev *gtp;
 
 	gtp = rcu_dereference_sk_user_data(sk);
-	if (gtp)
-		gtp_encap_disable(gtp);
+	if (gtp) {
+		udp_sk(sk)->encap_type = 0;
+		rcu_assign_sk_user_data(sk, NULL);
+		sock_put(sk);
+	}
+}
+
+static void gtp_encap_disable_sock(struct sock *sk)
+{
+	if (!sk)
+		return;
+
+	gtp_encap_destroy(sk);
+}
+
+static void gtp_encap_disable(struct gtp_dev *gtp)
+{
+	gtp_encap_disable_sock(gtp->sk0);
+	gtp_encap_disable_sock(gtp->sk1u);
 }
 
 /* UDP encapsulation receive handler. See net/ipv4/udp.c.
@@ -642,27 +642,23 @@ static void gtp_link_setup(struct net_device *dev)
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
-static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1);
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	int hashsize, err, fd0, fd1;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
+	int hashsize, err;
 
-	if (!data[IFLA_GTP_FD0] || !data[IFLA_GTP_FD1])
+	if (!data[IFLA_GTP_FD0] && !data[IFLA_GTP_FD1])
 		return -EINVAL;
 
 	gtp = netdev_priv(dev);
 
-	fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
-	fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
-
-	err = gtp_encap_enable(dev, gtp, fd0, fd1);
+	err = gtp_encap_enable(gtp, data);
 	if (err < 0)
-		goto out_err;
+		return err;
 
 	if (!data[IFLA_GTP_PDP_HASHSIZE])
 		hashsize = 1024;
@@ -690,7 +686,6 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	gtp_hashtable_free(gtp);
 out_encap:
 	gtp_encap_disable(gtp);
-out_err:
 	return err;
 }
 
@@ -805,63 +800,76 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	kfree(gtp->tid_hash);
 }
 
-static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1)
+static struct sock *gtp_encap_enable_socket(int fd, int type,
+					    struct gtp_dev *gtp)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
-	struct socket *sock0, *sock1u;
+	struct socket *sock;
+	struct sock *sk;
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
-		err = -EINVAL;
-		goto err1;
+	if (sock->sk->sk_protocol != IPPROTO_UDP) {
+		pr_debug("socket fd=%d not UDP\n", fd);
+		sk = ERR_PTR(-EINVAL);
+		goto out_sock;
 	}
 
-	sock1u = sockfd_lookup(fd_gtp1, &err);
-	if (sock1u == NULL) {
-		netdev_dbg(dev, "socket fd=%d not found (gtp1u)\n", fd_gtp1);
-		err = -ENOENT;
-		goto err1;
+	if (rcu_dereference_sk_user_data(sock->sk)) {
+		sk = ERR_PTR(-EBUSY);
+		goto out_sock;
 	}
 
-	if (sock1u->sk->sk_protocol != IPPROTO_UDP) {
-		netdev_dbg(dev, "socket fd=%d not UDP\n", fd_gtp1);
-		err = -EINVAL;
-		goto err2;
-	}
-
-	netdev_dbg(dev, "enable gtp on %p, %p\n", sock0, sock1u);
-
-	sock_hold(sock0->sk);
-	gtp->sk0 = sock0->sk;
-	sock_hold(sock1u->sk);
-	gtp->sk1u = sock1u->sk;
+	sk = sock->sk;
+	sock_hold(sk);
 
 	tuncfg.sk_user_data = gtp;
+	tuncfg.encap_type = type;
 	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
 
-	tuncfg.encap_type = UDP_ENCAP_GTP0;
-	setup_udp_tunnel_sock(sock_net(gtp->sk0), sock0, &tuncfg);
-
-	tuncfg.encap_type = UDP_ENCAP_GTP1U;
-	setup_udp_tunnel_sock(sock_net(gtp->sk1u), sock1u, &tuncfg);
-
-	err = 0;
-err2:
-	sockfd_put(sock1u);
-err1:
-	sockfd_put(sock0);
-	return err;
+	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
+
+out_sock:
+	sockfd_put(sock);
+	return sk;
+}
+
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
+{
+	struct sock *sk1u = NULL;
+	struct sock *sk0 = NULL;
+
+	if (data[IFLA_GTP_FD0]) {
+		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
+
+		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp);
+		if (IS_ERR(sk0))
+			return PTR_ERR(sk0);
+	}
+
+	if (data[IFLA_GTP_FD1]) {
+		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
+
+		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		if (IS_ERR(sk1u)) {
+			if (sk0)
+				gtp_encap_disable_sock(sk0);
+			return PTR_ERR(sk1u);
+		}
+	}
+
+	gtp->sk0 = sk0;
+	gtp->sk1u = sk1u;
+
+	return 0;
 }
 
 static struct net_device *gtp_find_dev(struct net *net, int ifindex)
-- 
2.10.2
