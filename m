From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] IPIP: Allow rebinding the tunnel to another interface
Date: Wed, 12 Dec 2007 17:29:33 +0100
Message-ID: <20071212172933.178cf78e@brian.englab.brq.redhat.com>
References: <20071212163451.498b5726@brian.englab.brq.redhat.com>
	<4760058E.5080403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcela Maslanova <mmaslano@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757401AbXLLQ3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 11:29:42 -0500
In-Reply-To: <4760058E.5080403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 17:00:14 +0100
Patrick McHardy <kaber@trash.net> wrote:

> If you change dev->iflink this should trigger a rtnetlink
> notification.

OK, I've added netdev_state_change(dev). Here's the new patch.



Once created, an IP tunnel can't be bound to another device.
(reported as https://bugzilla.redhat.com/show_bug.cgi?id=419671)

To reproduce:

# create a tunnel:
ip tunnel add tunneltest0 mode ipip remote 10.0.0.1 dev eth0
# try to change the bounding device from eth0 to eth1:
ip tunnel change tunneltest0 dev eth1
# show the result:
ip tunnel show tunneltest0

tunneltest0: ip/ip  remote 10.0.0.1  local any  dev eth0  ttl inherit

Notice the bound device has not changed from eth0 to eth1.

This patch fixes it. When changing the binding, it also recalculates the
MTU according to the new bound device's MTU.

If the change is acceptable, I'll do the same for GRE and SIT tunnels.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 8c2b2b0..160535b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -651,6 +651,40 @@ tx_error:
 	return 0;
 }
 
+static void ipip_tunnel_bind_dev(struct net_device *dev)
+{
+	struct net_device *tdev = NULL;
+	struct ip_tunnel *tunnel;
+	struct iphdr *iph;
+
+	tunnel = netdev_priv(dev);
+	iph = &tunnel->parms.iph;
+
+	if (iph->daddr) {
+		struct flowi fl = { .oif = tunnel->parms.link,
+				    .nl_u = { .ip4_u =
+					      { .daddr = iph->daddr,
+						.saddr = iph->saddr,
+						.tos = RT_TOS(iph->tos) } },
+				    .proto = IPPROTO_IPIP };
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
+	}
+	dev->iflink = tunnel->parms.link;
+}
+
 static int
 ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -723,6 +757,11 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
+				if (t->parms.link != p.link) {
+					t->parms.link = p.link;
+					ipip_tunnel_bind_dev(dev);
+					netdev_state_change(dev);
+				}
 			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;
@@ -791,12 +830,9 @@ static void ipip_tunnel_setup(struct net_device *dev)
 
 static int ipip_tunnel_init(struct net_device *dev)
 {
-	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
 
 	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
 
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);
@@ -804,29 +840,7 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	if (iph->daddr) {
-		struct flowi fl = { .oif = tunnel->parms.link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_IPIP };
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
-	}
-	dev->iflink = tunnel->parms.link;
+	ipip_tunnel_bind_dev(dev);
 
 	return 0;
 }
