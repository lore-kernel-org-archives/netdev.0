From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 2/2] sit: add support of x-netns
Date: Mon, 24 Jun 2013 16:13:59 +0200
Message-ID: <1372083239-9451-3-git-send-email-nicolas.dichtel@6wind.com>
References: <87y5ijd98e.fsf@xmission.com>
 <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37613 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990Ab3FXOOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 10:14:20 -0400
In-Reply-To: <1372083239-9451-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to switch the netns when packet is encapsulated or
decapsulated. In other word, the encapsulated packet is received in a netns,
where the lookup is done to find the tunnel. Once the tunnel is found, the
packet is decapsulated and injecting into the corresponding interface which
stands to another netns.

When one of the two netns is removed, the tunnel is destroyed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_tunnel.c     |  7 ++++++-
 net/ipv6/sit.c           | 49 ++++++++++++++++++++++++------------------------
 3 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index b0d9824..781b3cf 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -42,6 +42,7 @@ struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
 	struct net_device	*dev;
+	struct net		*net;	/* netns for packet i/o */
 
 	int		err_count;	/* Number of arrived ICMP errors */
 	unsigned long	err_time;	/* Time when the last ICMP error
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index bd227e5..b6a7704 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -304,6 +304,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 
 	tunnel = netdev_priv(dev);
 	tunnel->parms = *parms;
+	tunnel->net = net;
 
 	err = register_netdevice(dev);
 	if (err)
@@ -453,6 +454,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	tstats->rx_bytes += skb->len;
 	u64_stats_update_end(&tstats->syncp);
 
+	if (tunnel->net != dev_net(tunnel->dev))
+		dev_cleanup_skb(skb);
+
 	if (tunnel->dev->type == ARPHRD_ETHER) {
 		skb->protocol = eth_type_trans(skb, tunnel->dev);
 		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
@@ -541,7 +545,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
 	}
 
-	rt = ip_route_output_tunnel(dev_net(dev), &fl4,
+	rt = ip_route_output_tunnel(tunnel->net, &fl4,
 				    tunnel->parms.iph.protocol,
 				    dst, tnl_params->saddr,
 				    tunnel->parms.o_key,
@@ -888,6 +892,7 @@ int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 	if (ip_tunnel_find(itn, p, dev->type))
 		return -EEXIST;
 
+	nt->net = net;
 	nt->parms = *p;
 	err = register_netdevice(dev);
 	if (err)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f639866..4e03904 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -466,14 +466,14 @@ isatap_chksrc(struct sk_buff *skb, const struct iphdr *iph, struct ip_tunnel *t)
 
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
-	struct sit_net *sitn = net_generic(net, sit_net_id);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct sit_net *sitn = net_generic(tunnel->net, sit_net_id);
 
 	if (dev == sitn->fb_tunnel_dev) {
 		RCU_INIT_POINTER(sitn->tunnels_wc[0], NULL);
 	} else {
-		ipip6_tunnel_unlink(sitn, netdev_priv(dev));
-		ipip6_tunnel_del_prl(netdev_priv(dev), NULL);
+		ipip6_tunnel_unlink(sitn, tunnel);
+		ipip6_tunnel_del_prl(tunnel, NULL);
 	}
 	dev_put(dev);
 }
@@ -621,6 +621,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
+		if (tunnel->net != dev_net(tunnel->dev))
+			dev_cleanup_skb(skb);
 		netif_rx(skb);
 
 		return 0;
@@ -803,7 +805,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			goto tx_error;
 	}
 
-	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
+	rt = ip_route_output_ports(tunnel->net, &fl4, NULL,
 				   dst, tiph->saddr,
 				   0, 0,
 				   IPPROTO_IPV6, RT_TOS(tos),
@@ -858,6 +860,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			tunnel->err_count = 0;
 	}
 
+	if (tunnel->net != dev_net(dev))
+		dev_cleanup_skb(skb);
+
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -944,7 +949,8 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct rtable *rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
+		struct rtable *rt = ip_route_output_ports(tunnel->net, &fl4,
+							  NULL,
 							  iph->daddr, iph->saddr,
 							  0, 0,
 							  IPPROTO_IPV6,
@@ -959,7 +965,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	}
 
 	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
+		tdev = __dev_get_by_index(tunnel->net, tunnel->parms.link);
 
 	if (tdev) {
 		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
@@ -972,7 +978,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 
 static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 {
-	struct net *net = dev_net(t->dev);
+	struct net *net = t->net;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	ipip6_tunnel_unlink(sitn, t);
@@ -1248,7 +1254,6 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
 	dev->features		|= NETIF_F_LLTX;
 }
 
@@ -1257,6 +1262,7 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
@@ -1277,6 +1283,7 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 
 	iph->version		= 4;
@@ -1562,22 +1569,15 @@ static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.priority	=	2,
 };
 
-static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
+static void __net_exit sit_destroy_tunnels(struct net *net,
+					   struct list_head *head)
 {
-	int prio;
+	struct net_device *dev, *aux;
 
-	for (prio = 1; prio < 4; prio++) {
-		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-
-			t = rtnl_dereference(sitn->tunnels[prio][h]);
-			while (t != NULL) {
-				unregister_netdevice_queue(t->dev, head);
-				t = rtnl_dereference(t->next);
-			}
-		}
-	}
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops &&
+		    !strcmp(dev->rtnl_link_ops->kind, "sit"))
+			unregister_netdevice_queue(dev, head);
 }
 
 static int __net_init sit_init_net(struct net *net)
@@ -1598,6 +1598,7 @@ static int __net_init sit_init_net(struct net *net)
 		goto err_alloc_dev;
 	}
 	dev_net_set(sitn->fb_tunnel_dev, net);
+	sitn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 
 	err = ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
 	if (err)
@@ -1627,7 +1628,7 @@ static void __net_exit sit_exit_net(struct net *net)
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	sit_destroy_tunnels(sitn, &list);
+	sit_destroy_tunnels(net, &list);
 	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
-- 
1.8.2.1
