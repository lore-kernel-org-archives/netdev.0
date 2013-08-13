From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 3/4] ipip: add x-netns support
Date: Tue, 13 Aug 2013 17:51:11 +0200
Message-ID: <1376409072-6414-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20130704.145621.2060744817757546493.davem@davemloft.net>
 <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35969 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758383Ab3HMPvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 11:51:38 -0400
In-Reply-To: <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
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
 include/net/ip_tunnels.h |  2 +-
 net/ipv4/ip_gre.c        |  4 ++--
 net/ipv4/ip_tunnel.c     | 43 ++++++++++++++++++++++++++++---------------
 net/ipv4/ip_vti.c        |  2 +-
 net/ipv4/ipip.c          |  3 +--
 5 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index c6acd9f8f877..5a76f2bef822 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -102,7 +102,7 @@ void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
-void ip_tunnel_delete_net(struct ip_tunnel_net *itn);
+void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
 
 void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		    const struct iphdr *tnl_params, const u8 protocol);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 1f6eab66f7ce..bc3a76521deb 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -534,7 +534,7 @@ static int __net_init ipgre_init_net(struct net *net)
 static void __net_exit ipgre_exit_net(struct net *net)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ipgre_net_id);
-	ip_tunnel_delete_net(itn);
+	ip_tunnel_delete_net(itn, &ipgre_link_ops);
 }
 
 static struct pernet_operations ipgre_net_ops = {
@@ -767,7 +767,7 @@ static int __net_init ipgre_tap_init_net(struct net *net)
 static void __net_exit ipgre_tap_exit_net(struct net *net)
 {
 	struct ip_tunnel_net *itn = net_generic(net, gre_tap_net_id);
-	ip_tunnel_delete_net(itn);
+	ip_tunnel_delete_net(itn, &ipgre_tap_ops);
 }
 
 static struct pernet_operations ipgre_tap_net_ops = {
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index a351a003ee6b..a4d9126c7b51 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -350,7 +350,7 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 		struct flowi4 fl4;
 		struct rtable *rt;
 
-		rt = ip_route_output_tunnel(dev_net(dev), &fl4,
+		rt = ip_route_output_tunnel(tunnel->net, &fl4,
 					    tunnel->parms.iph.protocol,
 					    iph->daddr, iph->saddr,
 					    tunnel->parms.o_key,
@@ -365,7 +365,7 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 	}
 
 	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
+		tdev = __dev_get_by_index(tunnel->net, tunnel->parms.link);
 
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
@@ -654,7 +654,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	err = iptunnel_xmit(dev_net(dev), rt, skb,
+	err = iptunnel_xmit(tunnel->net, rt, skb,
 			    fl4.saddr, fl4.daddr, protocol,
 			    ip_tunnel_ecn_encap(tos, inner_iph, skb), ttl, df);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
@@ -821,11 +821,10 @@ static void ip_tunnel_dev_free(struct net_device *dev)
 
 void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 {
-	struct net *net = dev_net(dev);
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct ip_tunnel_net *itn;
 
-	itn = net_generic(net, tunnel->ip_tnl_net_id);
+	itn = net_generic(tunnel->net, tunnel->ip_tnl_net_id);
 
 	if (itn->fb_tunnel_dev != dev) {
 		ip_tunnel_del(netdev_priv(dev));
@@ -855,6 +854,10 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 
 	rtnl_lock();
 	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
+	/* FB netdevice is special: we have one, and only one per netns.
+	 * Allowing to move it to another netns is clearly unsafe.
+	 */
+	itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
 	rtnl_unlock();
 
 	if (IS_ERR(itn->fb_tunnel_dev))
@@ -864,28 +867,39 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init_net);
 
-static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head)
+static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head,
+			      struct rtnl_link_ops *ops)
 {
+	struct net *net = dev_net(itn->fb_tunnel_dev);
+	struct net_device *dev, *aux;
 	int h;
 
+	for_each_netdev_safe(net, dev, aux)
+		if (dev->rtnl_link_ops == ops)
+			unregister_netdevice_queue(dev, head);
+
 	for (h = 0; h < IP_TNL_HASH_SIZE; h++) {
 		struct ip_tunnel *t;
 		struct hlist_node *n;
 		struct hlist_head *thead = &itn->tunnels[h];
 
 		hlist_for_each_entry_safe(t, n, thead, hash_node)
-			unregister_netdevice_queue(t->dev, head);
+			/* If dev is in the same netns, it has already
+			 * been added to the list by the previous loop.
+			 */
+			if (!net_eq(dev_net(t->dev), net))
+				unregister_netdevice_queue(t->dev, head);
 	}
 	if (itn->fb_tunnel_dev)
 		unregister_netdevice_queue(itn->fb_tunnel_dev, head);
 }
 
-void ip_tunnel_delete_net(struct ip_tunnel_net *itn)
+void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops)
 {
 	LIST_HEAD(list);
 
 	rtnl_lock();
-	ip_tunnel_destroy(itn, &list);
+	ip_tunnel_destroy(itn, &list, ops);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
@@ -929,23 +943,21 @@ EXPORT_SYMBOL_GPL(ip_tunnel_newlink);
 int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 			 struct ip_tunnel_parm *p)
 {
-	struct ip_tunnel *t, *nt;
-	struct net *net = dev_net(dev);
+	struct ip_tunnel *t;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct net *net = tunnel->net;
 	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
 
 	if (dev == itn->fb_tunnel_dev)
 		return -EINVAL;
 
-	nt = netdev_priv(dev);
-
 	t = ip_tunnel_find(itn, p, dev->type);
 
 	if (t) {
 		if (t->dev != dev)
 			return -EEXIST;
 	} else {
-		t = nt;
+		t = tunnel;
 
 		if (dev->type != ARPHRD_ETHER) {
 			unsigned int nflags = 0;
@@ -984,6 +996,7 @@ int ip_tunnel_init(struct net_device *dev)
 	}
 
 	tunnel->dev = dev;
+	tunnel->net = dev_net(dev);
 	strcpy(tunnel->parms.name, dev->name);
 	iph->version		= 4;
 	iph->ihl		= 5;
@@ -994,8 +1007,8 @@ EXPORT_SYMBOL_GPL(ip_tunnel_init);
 
 void ip_tunnel_uninit(struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct net *net = tunnel->net;
 	struct ip_tunnel_net *itn;
 
 	itn = net_generic(net, tunnel->ip_tnl_net_id);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 79b263da4168..e805e7b3030e 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -318,7 +318,7 @@ static int __net_init vti_init_net(struct net *net)
 static void __net_exit vti_exit_net(struct net *net)
 {
 	struct ip_tunnel_net *itn = net_generic(net, vti_net_id);
-	ip_tunnel_delete_net(itn);
+	ip_tunnel_delete_net(itn, &vti_link_ops);
 }
 
 static struct pernet_operations vti_net_ops = {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 51fc2a1dcdd3..87bd2952c733 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -286,7 +286,6 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
 	dev->features		|= NETIF_F_LLTX;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
@@ -437,7 +436,7 @@ static int __net_init ipip_init_net(struct net *net)
 static void __net_exit ipip_exit_net(struct net *net)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
-	ip_tunnel_delete_net(itn);
+	ip_tunnel_delete_net(itn, &ipip_link_ops);
 }
 
 static struct pernet_operations ipip_net_ops = {
-- 
1.8.2.1
