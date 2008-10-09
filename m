From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] gre: Move MTU setting out of ipgre_tunnel_bind_dev
Date: Thu, 09 Oct 2008 15:05:26 +0800
Message-ID: <E1KnpaQ-0004PO-L5@gondolin.me.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34535 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755362AbYJIHF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:05:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre: Move MTU setting out of ipgre_tunnel_bind_dev

This patch moves the dev->mtu setting out of ipgre_tunnel_bind_dev.
This is in prepartion of using rtnl_link where we'll need to make
the MTU setting conditional on whether the user has supplied an
MTU.  This also requires the move of the ipgre_tunnel_bind_dev
call out of the dev->init function so that we can access the user
parameters later.

This patch also adds a check to prevent setting the MTU below
the minimum of 68.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ip_gre.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fd192d6..80622dd 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -119,6 +119,7 @@
 
 static int ipgre_tunnel_init(struct net_device *dev);
 static void ipgre_tunnel_setup(struct net_device *dev);
+static int ipgre_tunnel_bind_dev(struct net_device *dev);
 
 /* Fallback tunnel: no source, no destination, no key, no options */
 
@@ -289,6 +290,8 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
 	nt = netdev_priv(dev);
 	nt->parms = *parms;
 
+	dev->mtu = ipgre_tunnel_bind_dev(dev);
+
 	if (register_netdevice(dev) < 0)
 		goto failed_free;
 
@@ -773,7 +776,7 @@ tx_error:
 	return 0;
 }
 
-static void ipgre_tunnel_bind_dev(struct net_device *dev)
+static int ipgre_tunnel_bind_dev(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
@@ -821,9 +824,14 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 			addend += 4;
 	}
 	dev->needed_headroom = addend + hlen;
-	dev->mtu = mtu - dev->hard_header_len - addend;
+	mtu -= dev->hard_header_len - addend;
+
+	if (mtu < 68)
+		mtu = 68;
+
 	tunnel->hlen = addend;
 
+	return mtu;
 }
 
 static int
@@ -917,7 +925,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				t->parms.iph.frag_off = p.iph.frag_off;
 				if (t->parms.link != p.link) {
 					t->parms.link = p.link;
-					ipgre_tunnel_bind_dev(dev);
+					dev->mtu = ipgre_tunnel_bind_dev(dev);
 					netdev_state_change(dev);
 				}
 			}
@@ -1108,8 +1116,6 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	ipgre_tunnel_bind_dev(dev);
-
 	if (iph->daddr) {
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (ipv4_is_multicast(iph->daddr)) {
