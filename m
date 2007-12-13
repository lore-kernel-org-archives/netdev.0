From: mschmidt@redhat.com
Subject: [patch 1/2] ip_gre: Rebinding of GRE tunnels to other interfaces
Date: Thu, 13 Dec 2007 14:37:49 +0100
Message-ID: <20071213133922.223489455@redhat.com>
References: <20071213133748.862042979@redhat.com>
Cc: davem@davemloft.net, kaber@trash.net, mmaslano@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbXLMNj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 08:39:27 -0500
Content-Disposition: inline; filename=ip_gre-chgtunnel.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is similar to the change already done for IPIP tunnels.

Once created, a GRE tunnel can't be bound to another device.
To reproduce:

# create a tunnel:
ip tunnel add tunneltest0 mode gre remote 10.0.0.1 dev eth0
# try to change the bounding device from eth0 to eth1:
ip tunnel change tunneltest0 dev eth1
# show the result:
ip tunnel show tunneltest0

tunneltest0: gre/ip  remote 10.0.0.1  local any  dev eth0  ttl inherit

Notice the bound device has not changed from eth0 to eth1.

This patch fixes it. When changing the binding, it also recalculates the
MTU according to the new bound device's MTU.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Index: linus-kernel.git/net/ipv4/ip_gre.c
===================================================================
--- linus-kernel.git.orig/net/ipv4/ip_gre.c
+++ linus-kernel.git/net/ipv4/ip_gre.c
@@ -896,6 +896,59 @@ tx_error:
 	return 0;
 }
 
+static void ipgre_tunnel_bind_dev(struct net_device *dev)
+{
+	struct net_device *tdev = NULL;
+	struct ip_tunnel *tunnel;
+	struct iphdr *iph;
+	int hlen = LL_MAX_HEADER;
+	int mtu = ETH_DATA_LEN;
+	int addend = sizeof(struct iphdr) + 4;
+
+	tunnel = netdev_priv(dev);
+	iph = &tunnel->parms.iph;
+
+	/* Guess output device to choose reasonable mtu and hard_header_len */
+
+	if (iph->daddr) {
+		struct flowi fl = { .oif = tunnel->parms.link,
+				    .nl_u = { .ip4_u =
+					      { .daddr = iph->daddr,
+						.saddr = iph->saddr,
+						.tos = RT_TOS(iph->tos) } },
+				    .proto = IPPROTO_GRE };
+		struct rtable *rt;
+		if (!ip_route_output_key(&rt, &fl)) {
+			tdev = rt->u.dst.dev;
+			ip_rt_put(rt);
+		}
+		dev->flags |= IFF_POINTOPOINT;
+	}
+
+	if (!tdev && tunnel->parms.link)
+		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
+
+	if (tdev) {
+		hlen = tdev->hard_header_len;
+		mtu = tdev->mtu;
+	}
+	dev->iflink = tunnel->parms.link;
+
+	/* Precalculate GRE options length */
+	if (tunnel->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
+		if (tunnel->parms.o_flags&GRE_CSUM)
+			addend += 4;
+		if (tunnel->parms.o_flags&GRE_KEY)
+			addend += 4;
+		if (tunnel->parms.o_flags&GRE_SEQ)
+			addend += 4;
+	}
+	dev->hard_header_len = hlen + addend;
+	dev->mtu = mtu - addend;
+	tunnel->hlen = addend;
+
+}
+
 static int
 ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -983,6 +1036,11 @@ ipgre_tunnel_ioctl (struct net_device *d
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
+				if (t->parms.link != p.link) {
+					t->parms.link = p.link;
+					ipgre_tunnel_bind_dev(dev);
+					netdev_state_change(dev);
+				}
 			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;
@@ -1162,12 +1220,8 @@ static void ipgre_tunnel_setup(struct ne
 
 static int ipgre_tunnel_init(struct net_device *dev)
 {
-	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
 	struct iphdr *iph;
-	int hlen = LL_MAX_HEADER;
-	int mtu = ETH_DATA_LEN;
-	int addend = sizeof(struct iphdr) + 4;
 
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
@@ -1178,23 +1232,9 @@ static int ipgre_tunnel_init(struct net_
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	/* Guess output device to choose reasonable mtu and hard_header_len */
+	ipgre_tunnel_bind_dev(dev);
 
 	if (iph->daddr) {
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_GRE };
-		struct rtable *rt;
-		if (!ip_route_output_key(&rt, &fl)) {
-			tdev = rt->u.dst.dev;
-			ip_rt_put(rt);
-		}
-
-		dev->flags |= IFF_POINTOPOINT;
-
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (MULTICAST(iph->daddr)) {
 			if (!iph->saddr)
@@ -1205,31 +1245,9 @@ static int ipgre_tunnel_init(struct net_
 			dev->stop = ipgre_close;
 		}
 #endif
-	} else {
+	} else
 		dev->header_ops = &ipgre_header_ops;
-	}
-
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
-
-	if (tdev) {
-		hlen = tdev->hard_header_len;
-		mtu = tdev->mtu;
-	}
-	dev->iflink = tunnel->parms.link;
 
-	/* Precalculate GRE options length */
-	if (tunnel->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
-		if (tunnel->parms.o_flags&GRE_CSUM)
-			addend += 4;
-		if (tunnel->parms.o_flags&GRE_KEY)
-			addend += 4;
-		if (tunnel->parms.o_flags&GRE_SEQ)
-			addend += 4;
-	}
-	dev->hard_header_len = hlen + addend;
-	dev->mtu = mtu - addend;
-	tunnel->hlen = addend;
 	return 0;
 }
 

-- 
