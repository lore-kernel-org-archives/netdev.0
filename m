From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 1/6] gtp: make GTP sockets in gtp_newlink optional
Date: Mon, 30 Jan 2017 17:31:55 +0100
Message-ID: <20170130163200.17070-2-aschultz@tpip.net>
References: <20170130163200.17070-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:40176 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751517AbdA3QmK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:42:10 -0500
In-Reply-To: <20170130163200.17070-1-aschultz@tpip.net>
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
 drivers/net/gtp.c | 142 +++++++++++++++++++++++++++++-------------------------
 1 file changed, 76 insertions(+), 66 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index bda0c64..18944f4 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -259,28 +259,30 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	return iptunnel_pull_header(skb, hdrlen, skb->protocol, xnet);
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
 static void gtp_encap_destroy(struct sock *sk)
 {
 	struct gtp_dev *gtp;
 
 	gtp = rcu_dereference_sk_user_data(sk);
-	if (gtp)
-		gtp_encap_disable(gtp);
+	if (gtp) {
+		udp_sk(sk)->encap_type = 0;
+		rcu_assign_sk_user_data(sk, NULL);
+	}
+}
+
+static void gtp_encap_disable_sock(struct socket *sock)
+{
+	if (!sock || !sock->sk)
+		return;
+
+	gtp_encap_destroy(sock->sk);
+	sockfd_put(sock);
+}
+
+static void gtp_encap_disable(struct gtp_dev *gtp)
+{
+	gtp_encap_disable_sock(gtp->sock0);
+	gtp_encap_disable_sock(gtp->sock1u);
 }
 
 /* UDP encapsulation receive handler. See net/ipv4/udp.c.
@@ -640,27 +642,24 @@ static void gtp_link_setup(struct net_device *dev)
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
-static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1);
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
+static void gtp_encap_disable(struct gtp_dev *gtp);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	int hashsize, err, fd0, fd1;
+	int hashsize, err;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
 
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
@@ -688,7 +687,6 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	gtp_hashtable_free(gtp);
 out_encap:
 	gtp_encap_disable(gtp);
-out_err:
 	return err;
 }
 
@@ -803,61 +801,73 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 	kfree(gtp->tid_hash);
 }
 
-static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1)
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
+	if (rcu_dereference_sk_user_data(sock->sk)) {
+		err = -EBUSY;
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
-	gtp->sock0 = sock0;
-	gtp->sock1u = sock1u;
-
 	tuncfg.sk_user_data = gtp;
+	tuncfg.encap_type = type;
 	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
 
-	tuncfg.encap_type = UDP_ENCAP_GTP0;
-	setup_udp_tunnel_sock(sock_net(gtp->sock0->sk), gtp->sock0, &tuncfg);
-
-	tuncfg.encap_type = UDP_ENCAP_GTP1U;
-	setup_udp_tunnel_sock(sock_net(gtp->sock1u->sk), gtp->sock1u, &tuncfg);
-
-	err = 0;
-err2:
-	sockfd_put(sock1u);
-err1:
-	sockfd_put(sock0);
-	return err;
+	setup_udp_tunnel_sock(sock_net(sock->sk), sock, &tuncfg);
+	return sock;
+
+out_sock:
+	sockfd_put(sock);
+	return ERR_PTR(err);
+}
+
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
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
+	}
+
+	if (data[IFLA_GTP_FD1]) {
+		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
+
+		sock1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		if (IS_ERR(sock1u)) {
+			if (sock0)
+				sockfd_put(sock0);
+			return PTR_ERR(sock1u);
+		}
+	}
+
+	gtp->sock0 = sock0;
+	gtp->sock1u = sock1u;
+
+	return 0;
 }
 
 static struct net_device *gtp_find_dev(struct net *net, int ifindex)
-- 
2.10.2
