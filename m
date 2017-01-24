From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 3/5] gtp: fix cross netns recv on gtp socket
Date: Tue, 24 Jan 2017 18:24:00 +0100
Message-ID: <20170124172402.12096-4-aschultz@tpip.net>
References: <20170124172402.12096-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:44642 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdAXRYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 12:24:09 -0500
In-Reply-To: <20170124172402.12096-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of the passed through netlink src_net to check for a
cross netns operation was wrong. Using the GTP socket and the
GTP netdevice is always correct (even if the netdev has been
moved to new netns after link creation).

Remove the now obsolete net field from gtp_dev.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 1df54d6..72dd1ba 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -69,7 +69,6 @@ struct gtp_dev {
 	struct socket		*sock0;
 	struct socket		*sock1u;
 
-	struct net		*net;
 	struct net_device	*dev;
 
 	unsigned int		hash_size;
@@ -316,7 +315,7 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	netdev_dbg(gtp->dev, "encap_recv sk=%p\n", sk);
 
-	xnet = !net_eq(gtp->net, dev_net(gtp->dev));
+	xnet = !net_eq(sock_net(sk), dev_net(gtp->dev));
 
 	switch (udp_sk(sk)->encap_type) {
 	case UDP_ENCAP_GTP0:
@@ -658,7 +657,7 @@ static void gtp_link_setup(struct net_device *dev)
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
-			    int fd_gtp0, int fd_gtp1, struct net *src_net);
+			    int fd_gtp0, int fd_gtp1);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
@@ -858,7 +857,6 @@ static int gtp_encap_enable(struct net_device *dev, struct gtp_dev *gtp,
 
 	gtp->sock0 = sock0;
 	gtp->sock1u = sock1u;
-	gtp->net = src_net;
 
 	tuncfg.sk_user_data = gtp;
 	tuncfg.encap_rcv = gtp_encap_recv;
-- 
2.10.2
