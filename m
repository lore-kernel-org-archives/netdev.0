From: mschmidt@redhat.com
Subject: [patch 2/2] ipv6/sit: Rebinding of SIT tunnels to other interfaces
Date: Thu, 13 Dec 2007 14:37:50 +0100
Message-ID: <20071213133922.468540197@redhat.com>
References: <20071213133748.862042979@redhat.com>
Cc: davem@davemloft.net, kaber@trash.net, mmaslano@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbXLMNj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 08:39:28 -0500
Content-Disposition: inline; filename=ipv6-sit-chgtunnel.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is similar to the change already done for IPIP tunnels.

Once created, a SIT tunnel can't be bound to another device.
To reproduce:

# create a tunnel:
ip tunnel add tunneltest0 mode sit remote 10.0.0.1 dev eth0
# try to change the bounding device from eth0 to eth1:
ip tunnel change tunneltest0 dev eth1
# show the result:
ip tunnel show tunneltest0

tunneltest0: ipv6/ip  remote 10.0.0.1  local any  dev eth0  ttl inherit

Notice the bound device has not changed from eth0 to eth1.

This patch fixes it. When changing the binding, it also recalculates the
MTU according to the new bound device's MTU.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Index: linus-kernel.git/net/ipv6/sit.c
===================================================================
--- linus-kernel.git.orig/net/ipv6/sit.c
+++ linus-kernel.git/net/ipv6/sit.c
@@ -669,6 +669,42 @@ tx_error:
 	return 0;
 }
 
+static void ipip6_tunnel_bind_dev(struct net_device *dev)
+{
+	struct net_device *tdev = NULL;
+	struct ip_tunnel *tunnel;
+	struct iphdr *iph;
+
+	tunnel = netdev_priv(dev);
+	iph = &tunnel->parms.iph;
+
+	if (iph->daddr) {
+		struct flowi fl = { .nl_u = { .ip4_u =
+					      { .daddr = iph->daddr,
+						.saddr = iph->saddr,
+						.tos = RT_TOS(iph->tos) } },
+				    .oif = tunnel->parms.link,
+				    .proto = IPPROTO_IPV6 };
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
+		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
+		dev->mtu = tdev->mtu - sizeof(struct iphdr);
+		if (dev->mtu < IPV6_MIN_MTU)
+			dev->mtu = IPV6_MIN_MTU;
+	}
+	dev->iflink = tunnel->parms.link;
+}
+
 static int
 ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -740,6 +776,11 @@ ipip6_tunnel_ioctl (struct net_device *d
 			if (cmd == SIOCCHGTUNNEL) {
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
+				if (t->parms.link != p.link) {
+					t->parms.link = p.link;
+					ipip6_tunnel_bind_dev(dev);
+					netdev_state_change(dev);
+				}
 			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;
@@ -808,12 +849,9 @@ static void ipip6_tunnel_setup(struct ne
 
 static int ipip6_tunnel_init(struct net_device *dev)
 {
-	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
 
 	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -821,31 +859,7 @@ static int ipip6_tunnel_init(struct net_
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	if (iph->daddr) {
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .oif = tunnel->parms.link,
-				    .proto = IPPROTO_IPV6 };
-		struct rtable *rt;
-		if (!ip_route_output_key(&rt, &fl)) {
-			tdev = rt->u.dst.dev;
-			ip_rt_put(rt);
-		}
-		dev->flags |= IFF_POINTOPOINT;
-	}
-
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(&init_net, tunnel->parms.link);
-
-	if (tdev) {
-		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
-		dev->mtu = tdev->mtu - sizeof(struct iphdr);
-		if (dev->mtu < IPV6_MIN_MTU)
-			dev->mtu = IPV6_MIN_MTU;
-	}
-	dev->iflink = tunnel->parms.link;
+	ipip6_tunnel_bind_dev(dev);
 
 	return 0;
 }

-- 
