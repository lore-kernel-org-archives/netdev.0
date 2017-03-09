From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 1/7] gtp: switch from struct socket to struct sock for the GTP sockets
Date: Thu,  9 Mar 2017 17:42:56 +0100
Message-ID: <20170309164302.13550-2-aschultz@tpip.net>
References: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:47461 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932722AbdCIQni (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:38 -0500
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After enabling the UDP encapsulation, only the sk member is used.

Holding the socket would prevent user space from closing the socket,
but holding a reference to the sk member does not have the same
effect.

This change will make it simpler to later detach the sockets from
the netdevice.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 42 +++++++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8969874..e1b5af3 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -66,8 +66,8 @@ struct pdp_ctx {
 struct gtp_dev {
 	struct list_head	list;
 
-	struct socket		*sock0;
-	struct socket		*sock1u;
+	struct sock		*sk0;
+	struct sock		*sk1u;
 
 	struct net_device	*dev;
 
@@ -261,17 +261,19 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 
 static void gtp_encap_disable(struct gtp_dev *gtp)
 {
-	if (gtp->sock0 && gtp->sock0->sk) {
-		udp_sk(gtp->sock0->sk)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sock0->sk, NULL);
+	if (gtp->sk0) {
+		udp_sk(gtp->sk0)->encap_type = 0;
+		rcu_assign_sk_user_data(gtp->sk0, NULL);
+		sock_put(gtp->sk0);
 	}
-	if (gtp->sock1u && gtp->sock1u->sk) {
-		udp_sk(gtp->sock1u->sk)->encap_type = 0;
-		rcu_assign_sk_user_data(gtp->sock1u->sk, NULL);
+	if (gtp->sk1u) {
+		udp_sk(gtp->sk1u)->encap_type = 0;
+		rcu_assign_sk_user_data(gtp->sk1u, NULL);
+		sock_put(gtp->sk1u);
 	}
 
-	gtp->sock0 = NULL;
-	gtp->sock1u = NULL;
+	gtp->sk0 = NULL;
+	gtp->sk1u = NULL;
 }
 
 static void gtp_encap_destroy(struct sock *sk)
@@ -484,14 +486,14 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 
 	switch (pctx->gtp_version) {
 	case GTP_V0:
-		if (gtp->sock0)
-			sk = gtp->sock0->sk;
+		if (gtp->sk0)
+			sk = gtp->sk0;
 		else
 			sk = NULL;
 		break;
 	case GTP_V1:
-		if (gtp->sock1u)
-			sk = gtp->sock1u->sk;
+		if (gtp->sk1u)
+			sk = gtp->sk1u;
 		else
 			sk = NULL;
 		break;
@@ -504,7 +506,7 @@ static int gtp_build_skb_ip4(struct sk_buff *skb, struct net_device *dev,
 		return -ENOENT;
 	}
 
-	rt = ip4_route_output_gtp(sock_net(sk), &fl4, gtp->sock0->sk,
+	rt = ip4_route_output_gtp(sock_net(sk), &fl4, gtp->sk0,
 				  pctx->sgsn_addr_ip4.s_addr);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to SSGN %pI4\n",
@@ -839,18 +841,20 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 
 	netdev_dbg(dev, "enable gtp on %p, %p\n", sock0, sock1u);
 
-	gtp->sock0 = sock0;
-	gtp->sock1u = sock1u;
+	sock_hold(sock0->sk);
+	gtp->sk0 = sock0->sk;
+	sock_hold(sock1u->sk);
+	gtp->sk1u = sock1u->sk;
 
 	tuncfg.sk_user_data = gtp;
 	tuncfg.encap_rcv = gtp_encap_recv;
 	tuncfg.encap_destroy = gtp_encap_destroy;
 
 	tuncfg.encap_type = UDP_ENCAP_GTP0;
-	setup_udp_tunnel_sock(sock_net(gtp->sock0->sk), gtp->sock0, &tuncfg);
+	setup_udp_tunnel_sock(sock_net(gtp->sk0), sock0, &tuncfg);
 
 	tuncfg.encap_type = UDP_ENCAP_GTP1U;
-	setup_udp_tunnel_sock(sock_net(gtp->sock1u->sk), gtp->sock1u, &tuncfg);
+	setup_udp_tunnel_sock(sock_net(gtp->sk1u), sock1u, &tuncfg);
 
 	err = 0;
 err2:
-- 
2.10.2
