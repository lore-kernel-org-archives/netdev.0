From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 06/17] gtp: fix cross netns recv on gtp socket
Date: Mon, 23 Jan 2017 12:56:55 +0100
Message-ID: <20170123115706.4354-7-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:42640 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750739AbdAWMGx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:53 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the paassed through netlink src_net to check for a
cross netns operation was wrong. Using the GTP socket and the
GTP netdevice is always correct (even if the netdev has been
moved to new netns after link creation).

Remove the now obsolete net field from gtp_dev.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 7a3c5f6..bc8734b7 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -69,7 +69,6 @@ struct gtp_dev {
 	struct socket		*sock0;
 	struct socket		*sock1u;
 
-	struct net		*net;
 	struct net_device	*dev;
 
 	unsigned int		hash_size;
@@ -292,7 +291,7 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
 
-	xnet = !net_eq(gtp->net, dev_net(gtp->dev));
+	xnet = !net_eq(sock_net(sk), dev_net(gtp->dev));
 
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
@@ -642,7 +641,7 @@ static void gtp_link_setup(struct net_device *dev)
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    struct net *src_net, struct nlattr *data[]);
+			    struct nlattr *data[]);
 static void gtp_encap_disable(struct gtp_dev *gtp);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
@@ -660,7 +659,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		hashsize = nla_get_u32(data[IFLA_GTP_PDP_HASHSIZE]);
 
 	if (data[IFLA_GTP_FD0] || data[IFLA_GTP_FD1]) {
-		err = gtp_encap_enable(dev, gtp, src_net, data);
+		err = gtp_encap_enable(dev, gtp, data);
 		if (err < 0)
 			goto out_err;
 	}
@@ -839,7 +838,7 @@ static struct socket *gtp_encap_enable_socket(int fd, int type,
 }
 
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    struct net *src_net, struct nlattr *data[])
+			    struct nlattr *data[])
 {
 	struct socket *sock0 = NULL;
 	struct socket *sock1u = NULL;
@@ -867,7 +866,6 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 
 	gtp->sock0 = sock0;
 	gtp->sock1u = sock1u;
-	gtp->net = src_net;
 
 	return 0;
 }
-- 
2.10.2
