From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] ip_tunnel: follow lower device state
Date: Tue, 6 Aug 2013 16:44:22 -0700
Message-ID: <20130806164422.4bc7b79b@nehalam.linuxnetplumber.net>
References: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
	<20130805225359.7ba89042@nehalam.linuxnetplumber.net>
	<CALnjE+qQWampgB5OOR54XkbuBe+Hb6p9d15aPvSEAvjxgXqhwQ@mail.gmail.com>
	<20130806104942.25bdcfa1@nehalam.linuxnetplumber.net>
	<CALnjE+p_rSYZSgrT=P2B5XJebJ4_i6UKKo_8gyD1EoNG_1ve7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:56882 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab3HFXo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 19:44:27 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so770026pde.37
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 16:44:26 -0700 (PDT)
In-Reply-To: <CALnjE+p_rSYZSgrT=P2B5XJebJ4_i6UKKo_8gyD1EoNG_1ve7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is merge of Pravin's earlier patch and mine..

IP tunnels like other layered devices should propogate
carrier and state from lower device to tunnel.
Following patch would propogate link status to IPIP and
GRE devices.


---
v2 - embed link_map in per-net struct.
     no need for RCU on link map
     handle carrier (NETDEV_CHANGE) as well   

 include/net/ip_tunnels.h |    1 
 net/ipv4/ip_tunnel.c     |  108 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 107 insertions(+), 2 deletions(-)

--- a/net/ipv4/ip_tunnel.c	2013-08-06 16:28:14.000000000 -0700
+++ b/net/ipv4/ip_tunnel.c	2013-08-06 16:40:36.498464820 -0700
@@ -61,6 +61,11 @@
 #include <net/ip6_route.h>
 #endif
 
+static int tunnels_net_id;
+struct tunnels_net {
+	struct hlist_head link_map[IP_TNL_HASH_SIZE];
+};
+
 static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
 				   __be32 key, __be32 remote)
 {
@@ -248,8 +253,62 @@ static void ip_tunnel_add(struct ip_tunn
 static void ip_tunnel_del(struct ip_tunnel *t)
 {
 	hlist_del_init_rcu(&t->hash_node);
+	hlist_del_init(&t->link_node);
+}
+
+static void ip_tunnel_add_link(struct net *net, struct ip_tunnel *t, int iflink)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+	int hash = hash_32(iflink, IP_TNL_HASH_BITS);
+
+	hlist_add_head(&t->link_node, &tn->link_map[hash]);
 }
 
+static int ip_tunnel_notify(struct notifier_block *unused,
+			    unsigned long event, void *ptr)
+{
+	struct net_device *rootdev = netdev_notifier_info_to_dev(ptr);
+	struct tunnels_net *tn = net_generic(dev_net(rootdev), tunnels_net_id);
+	int hash = hash_32(rootdev->iflink, IP_TNL_HASH_BITS);
+	struct hlist_node *n;
+	struct ip_tunnel *t;
+
+	hlist_for_each_entry_safe(t, n, &tn->link_map[hash], link_node) {
+		int flags;
+
+		if (rootdev->ifindex != t->dev->iflink)
+			continue;
+
+		switch (event) {
+		case NETDEV_CHANGE:
+			break;
+
+		case NETDEV_DOWN:
+			flags = t->dev->flags;
+			if (!(flags & IFF_UP))
+				break;
+			dev_change_flags(t->dev, flags & ~IFF_UP);
+			break;
+
+		case NETDEV_UP:
+			flags = t->dev->flags;
+			if (flags & IFF_UP)
+				break;
+			dev_change_flags(t->dev, flags | IFF_UP);
+			break;
+
+		default:
+			continue;
+		}
+		netif_stacked_transfer_operstate(rootdev, t->dev);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ip_tunnel_notifier = {
+	.notifier_call = ip_tunnel_notify,
+};
+
 static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 					struct ip_tunnel_parm *parms,
 					int type)
@@ -370,8 +429,12 @@ static int ip_tunnel_bind_dev(struct net
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
+		netif_stacked_transfer_operstate(tdev, dev);
+		ip_tunnel_add_link(dev_net(dev), tunnel, tdev->ifindex);
+		dev->iflink = tdev->ifindex;
+	} else {
+		dev->iflink = tunnel->parms.link;
 	}
-	dev->iflink = tunnel->parms.link;
 
 	dev->needed_headroom = t_hlen + hlen;
 	mtu -= (dev->hard_header_len + t_hlen);
@@ -919,7 +982,7 @@ int ip_tunnel_newlink(struct net_device
 		dev->mtu = mtu;
 
 	ip_tunnel_add(itn, nt);
-
+	linkwatch_fire_event(dev);
 out:
 	return err;
 }
@@ -1012,4 +1075,45 @@ void ip_tunnel_setup(struct net_device *
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_setup);
 
+static int __net_init tunnels_init_net(struct net *net)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+	unsigned i;
+
+	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&tn->link_map[i]);
+
+	return 0;
+}
+
+static struct pernet_operations tunnels_net_ops = {
+	.init = tunnels_init_net,
+	.id   = &tunnels_net_id,
+	.size = sizeof(struct tunnels_net),
+};
+
+static int __init ip_tunnel_mod_init(void)
+{
+	int err;
+
+	pr_info("IP_Tunnel init\n");
+	err = register_pernet_device(&tunnels_net_ops);
+	if (err < 0)
+		return err;
+
+	err = register_netdevice_notifier(&ip_tunnel_notifier);
+	if (err < 0)
+		unregister_pernet_device(&tunnels_net_ops);
+
+	return err;
+}
+
+static void __exit ip_tunnel_mod_fini(void)
+{
+	unregister_netdevice_notifier(&ip_tunnel_notifier);
+	unregister_pernet_device(&tunnels_net_ops);
+}
+
+module_init(ip_tunnel_mod_init);
+module_exit(ip_tunnel_mod_fini);
 MODULE_LICENSE("GPL");
--- a/include/net/ip_tunnels.h	2013-08-06 16:28:14.358362477 -0700
+++ b/include/net/ip_tunnels.h	2013-08-06 16:39:35.719423506 -0700
@@ -41,6 +41,7 @@ struct ip_tunnel_prl_entry {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
+	struct hlist_node link_node;
 	struct net_device	*dev;
 	struct net		*net;	/* netns for packet i/o */
 
