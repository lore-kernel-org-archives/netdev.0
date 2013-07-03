From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/3] ip6tnl: add x-netns support
Date: Wed,  3 Jul 2013 17:00:36 +0200
Message-ID: <1372863636-8866-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20130627.223621.1852663736303796496.davem@davemloft.net>
 <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60415 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756291Ab3GCPDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:03:19 -0400
In-Reply-To: <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
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
 include/net/ip6_tunnel.h |  1 +
 net/ipv6/ip6_gre.c       |  5 +++++
 net/ipv6/ip6_tunnel.c    | 41 +++++++++++++++++++++++++++++++----------
 3 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 4da5de1..2265b0b 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -36,6 +36,7 @@ struct __ip6_tnl_parm {
 struct ip6_tnl {
 	struct ip6_tnl __rcu *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
+	struct net *net;	/* netns for packet i/o */
 	struct __ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
 	struct dst_entry *dst_cache;    /* cached dst */
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index ecd6073..f2d0a42 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -335,6 +335,7 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	dev->rtnl_link_ops = &ip6gre_link_ops;
 
 	nt->dev = dev;
+	nt->net = dev_net(dev);
 	ip6gre_tnl_link_config(nt, 1);
 
 	if (register_netdevice(dev) < 0)
@@ -1255,6 +1256,7 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 
 	memcpy(dev->dev_addr, &tunnel->parms.laddr, sizeof(struct in6_addr));
@@ -1275,6 +1277,7 @@ static void ip6gre_fb_tunnel_init(struct net_device *dev)
 	struct ip6_tnl *tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 
 	tunnel->hlen		= sizeof(struct ipv6hdr) + 4;
@@ -1450,6 +1453,7 @@ static int ip6gre_tap_init(struct net_device *dev)
 	tunnel = netdev_priv(dev);
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 
 	ip6gre_tnl_link_config(tunnel, 1);
@@ -1501,6 +1505,7 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 		eth_hw_addr_random(dev);
 
 	nt->dev = dev;
+	nt->net = dev_net(dev);
 	ip6gre_tnl_link_config(nt, !tb[IFLA_MTU]);
 
 	/* Can use a lockless transmit, unless we generate output sequences */
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 1e55866..d773a3c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -315,6 +315,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 
 	t = netdev_priv(dev);
 	t->parms = *p;
+	t->net = dev_net(dev);
 	err = ip6_tnl_create2(dev);
 	if (err < 0)
 		goto failed_free;
@@ -374,7 +375,7 @@ static void
 ip6_tnl_dev_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct net *net = dev_net(dev);
+	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (dev == ip6n->fb_tnl_dev)
@@ -741,7 +742,7 @@ int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
 {
 	struct __ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
-	struct net *net = dev_net(t->dev);
+	struct net *net = t->net;
 
 	if ((p->flags & IP6_TNL_F_CAP_RCV) ||
 	    ((p->flags & IP6_TNL_F_CAP_PER_PACKET) &&
@@ -827,6 +828,9 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
+		if (t->net != dev_net(t->dev))
+			skb_scrub_packet(skb);
+
 		netif_rx(skb);
 
 		rcu_read_unlock();
@@ -895,7 +899,7 @@ int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 {
 	struct __ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
-	struct net *net = dev_net(t->dev);
+	struct net *net = t->net;
 
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		struct net_device *ldev = NULL;
@@ -945,8 +949,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 			 int encap_limit,
 			 __u32 *pmtu)
 {
-	struct net *net = dev_net(dev);
 	struct ip6_tnl *t = netdev_priv(dev);
+	struct net *net = t->net;
 	struct net_device_stats *stats = &t->dev->stats;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct ipv6_tel_txoption opt;
@@ -996,6 +1000,9 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		goto tx_err_dst_release;
 	}
 
+	if (t->net != dev_net(dev))
+		skb_scrub_packet(skb);
+
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -1202,7 +1209,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
 
-		struct rt6_info *rt = rt6_lookup(dev_net(dev),
+		struct rt6_info *rt = rt6_lookup(t->net,
 						 &p->raddr, &p->laddr,
 						 p->link, strict);
 
@@ -1251,7 +1258,7 @@ ip6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 
 static int ip6_tnl_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
 {
-	struct net *net = dev_net(t->dev);
+	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	int err;
 
@@ -1463,7 +1470,6 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 		dev->mtu-=8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
@@ -1479,6 +1485,7 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	struct ip6_tnl *t = netdev_priv(dev);
 
 	t->dev = dev;
+	t->net = dev_net(dev);
 	dev->tstats = alloc_percpu(struct pcpu_tstats);
 	if (!dev->tstats)
 		return -ENOMEM;
@@ -1596,9 +1603,9 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
 			      struct nlattr *data[])
 {
-	struct ip6_tnl *t;
+	struct ip6_tnl *t = netdev_priv(dev);
 	struct __ip6_tnl_parm p;
-	struct net *net = dev_net(dev);
+	struct net *net = t->net;
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (dev == ip6n->fb_tnl_dev)
@@ -1699,14 +1706,24 @@ static struct xfrm6_tunnel ip6ip6_handler __read_mostly = {
 
 static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 {
+	struct net *net = dev_net(ip6n->fb_tnl_dev);
+	struct net_device *dev, *aux;
 	int h;
 	struct ip6_tnl *t;
 	LIST_HEAD(list);
 
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops == &ip6_link_ops)
+			unregister_netdevice_queue(dev, &list);
+
 	for (h = 0; h < HASH_SIZE; h++) {
 		t = rtnl_dereference(ip6n->tnls_r_l[h]);
 		while (t != NULL) {
-			unregister_netdevice_queue(t->dev, &list);
+			/* If dev is in the same netns, it has already
+			 * been added to the list by the previous loop.
+			 */
+			if (dev_net(t->dev) != net)
+				unregister_netdevice_queue(t->dev, &list);
 			t = rtnl_dereference(t->next);
 		}
 	}
@@ -1732,6 +1749,10 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 	if (!ip6n->fb_tnl_dev)
 		goto err_alloc_dev;
 	dev_net_set(ip6n->fb_tnl_dev, net);
+	/* FB netdevice is special: we have one, and only one per netns.
+	 * Allowing to move it to another netns is clearly unsafe.
+	 */
+	ip6n->fb_tnl_dev->features |= NETIF_F_NETNS_LOCAL;
 
 	err = ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
 	if (err < 0)
-- 
1.8.2.1
