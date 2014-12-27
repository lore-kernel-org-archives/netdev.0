From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net] tunnel: support propagating lower device state
Date: Sat, 27 Dec 2014 09:59:50 -0800
Message-ID: <20141227095950.20a062d2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:16077 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751567AbaL0SS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:18:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows propagating the carrier state from lower device
to the upper tunnel device. This is similar to how stacked transfer
works for VLAN devices.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/net/ip_tunnels.h |    2 
 net/ipv4/ip_tunnel.c     |  123 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 122 insertions(+), 3 deletions(-)

--- a/include/net/ip_tunnels.h	2014-12-27 09:51:00.584435221 -0800
+++ b/include/net/ip_tunnels.h	2014-12-27 09:51:00.580435199 -0800
@@ -54,6 +54,7 @@ struct ip_tunnel_dst {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
+	struct hlist_node link_node;
 	struct net_device	*dev;
 	struct net		*net;	/* netns for packet i/o */
 
@@ -115,6 +116,7 @@ struct tnl_ptk_info {
 struct ip_tunnel_net {
 	struct net_device *fb_tunnel_dev;
 	struct hlist_head tunnels[IP_TNL_HASH_SIZE];
+	struct hlist_head *lower_dev;
 };
 
 struct ip_tunnel_encap_ops {
--- a/net/ipv4/ip_tunnel.c	2014-12-27 09:51:00.584435221 -0800
+++ b/net/ipv4/ip_tunnel.c	2014-12-27 09:57:57.250907676 -0800
@@ -63,6 +63,11 @@
 #include <net/ip6_route.h>
 #endif
 
+static int tunnels_net_id;
+struct tunnels_net {
+	struct hlist_head link_map[IP_TNL_HASH_SIZE];
+};
+
 static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
 {
 	return hash_32((__force u32)key ^ (__force u32)remote,
@@ -267,8 +272,61 @@ static void ip_tunnel_add(struct ip_tunn
 static void ip_tunnel_del(struct ip_tunnel *t)
 {
 	hlist_del_init_rcu(&t->hash_node);
+	hlist_del_init(&t->link_node);
 }
 
+static void ip_tunnel_add_link(struct net *net, struct ip_tunnel *t, int iflink)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+	int hash = hash_32(iflink, IP_TNL_HASH_BITS);
+
+	hlist_add_head(&t->link_node, &tn->link_map[hash]);
+}
+
+static int ip_tunnel_notify(struct notifier_block *unused,
+			    unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct tunnels_net *tn = net_generic(dev_net(dev), tunnels_net_id);
+	int hash = hash_32(dev->ifindex, IP_TNL_HASH_BITS);
+	struct hlist_head *head = &tn->link_map[hash];
+	struct ip_tunnel *t;
+
+	hlist_for_each_entry(t, head, link_node) {
+		unsigned int flags = t->dev->flags;
+
+		if (dev->ifindex != t->dev->iflink)
+			continue;
+
+		switch (event) {
+		case NETDEV_CHANGE:
+			break;
+
+		case NETDEV_DOWN:
+			if (!(flags & IFF_UP))
+				break;
+			dev_change_flags(t->dev, flags & ~IFF_UP);
+			break;
+
+		case NETDEV_UP:
+			if (flags & IFF_UP)
+				break;
+			dev_change_flags(t->dev, flags | IFF_UP);
+			break;
+
+		default:
+			continue;
+		}
+		netif_stacked_transfer_operstate(dev, t->dev);
+	}
+
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
@@ -330,6 +388,7 @@ static struct net_device *__ip_tunnel_cr
 	if (err)
 		goto failed_free;
 
+	linkwatch_fire_event(dev); /* _MUST_ call rfc2863_policy() */
 	return dev;
 
 failed_free:
@@ -388,8 +447,12 @@ static int ip_tunnel_bind_dev(struct net
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
@@ -982,8 +1045,17 @@ int ip_tunnel_init_net(struct net *net,
 	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&itn->tunnels[i]);
 
+	itn->lower_dev = kcalloc(NETDEV_HASHENTRIES, sizeof(struct hlist_head),
+				 GFP_KERNEL);
+	if (!itn->lower_dev) {
+		kfree(itn->tunnels);
+		return -ENOMEM;
+	}
+
 	if (!ops) {
 		itn->fb_tunnel_dev = NULL;
+		kfree(itn->tunnels);
+		kfree(itn->lower_dev);
 		return 0;
 	}
 
@@ -1003,7 +1075,12 @@ int ip_tunnel_init_net(struct net *net,
 	}
 	rtnl_unlock();
 
-	return PTR_ERR_OR_ZERO(itn->fb_tunnel_dev);
+	if (IS_ERR(itn->fb_tunnel_dev)) {
+		kfree(itn->tunnels);
+		return PTR_ERR(itn->fb_tunnel_dev);
+	}
+	return 0;
+
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init_net);
 
@@ -1072,7 +1149,7 @@ int ip_tunnel_newlink(struct net_device
 		dev->mtu = mtu;
 
 	ip_tunnel_add(itn, nt);
-
+	linkwatch_fire_event(dev);
 out:
 	return err;
 }
@@ -1173,4 +1250,44 @@ void ip_tunnel_setup(struct net_device *
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
