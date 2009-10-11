From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6 1/3] ipv6 sit: Ensure to initialize 6rd parameters.
Date: Sun, 11 Oct 2009 22:31:34 +0900
Message-ID: <4AD1DE36.8070500@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42676 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757165AbZJKNcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 09:32:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 sit: Ensure to initialize 6rd parameters.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/sit.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6955654..8594451 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -161,9 +161,11 @@ static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 	write_unlock_bh(&ipip6_lock);
 }
 
-static void ipip6_tunnel_clone_6rd(struct ip_tunnel *t, struct sit_net *sitn)
+static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 {
 #ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel *t = netdev_priv(dev);
+
 	if (t->dev == sitn->fb_tunnel_dev) {
 		ipv6_addr_set(&t->ip6rd.prefix, htonl(0x20020000), 0, 0, 0);
 		t->ip6rd.relay_prefix = 0;
@@ -219,6 +221,7 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 
 	nt->parms = *parms;
 	ipip6_tunnel_init(dev);
+	ipip6_tunnel_clone_6rd(dev, sitn);
 
 	if (parms->i_flags & SIT_ISATAP)
 		dev->priv_flags |= IFF_ISATAP;
@@ -228,8 +231,6 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 
 	dev_hold(dev);
 
-	ipip6_tunnel_clone_6rd(t, sitn);
-
 	ipip6_tunnel_link(sitn, nt);
 	return nt;
 
@@ -1024,7 +1025,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			t->ip6rd.prefixlen = ip6rd.prefixlen;
 			t->ip6rd.relay_prefixlen = ip6rd.relay_prefixlen;
 		} else
-			ipip6_tunnel_clone_6rd(t, sitn);
+			ipip6_tunnel_clone_6rd(dev, sitn);
 
 		err = 0;
 		break;
@@ -1148,6 +1149,7 @@ static int sit_init_net(struct net *net)
 	dev_net_set(sitn->fb_tunnel_dev, net);
 
 	ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
+	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
 
 	if ((err = register_netdev(sitn->fb_tunnel_dev)))
 		goto err_reg_dev;
