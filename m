From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 5/5] IP_TUNNEL: follow state of lower device
Date: Mon,  7 Jan 2013 18:31:53 -0800
Message-ID: <1357612313-1847-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, shemminger@vyatta.com,
	Pravin Shelar <pshelar@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:35319 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754229Ab3AHCbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 21:31:34 -0500
Received: by mail-yh0-f71.google.com with SMTP id 22so15330930yhr.6
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 18:31:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>

I reference patch posted for IPGRE:
http://permalink.gmane.org/gmane.linux.network/226946

--8<--------------------------cut here-------------------------->8--

IP tunnels like other layered devices should propogate
carrier and state from lower device to tunnel.
Following patch would propogate link status to IPIP and
GRE devices.

Suggested-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnel.h |    1 +
 net/ipv4/ip_tunnel.c    |  112 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 111 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_tunnel.h b/include/net/ip_tunnel.h
index 7328871..5490a7d 100644
--- a/include/net/ip_tunnel.h
+++ b/include/net/ip_tunnel.h
@@ -21,6 +21,7 @@ struct ip_tunnel_6rd_parm {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
+	struct hlist_node link_node;
 	struct net_device	*dev;
 
 	int			err_count;	/* Number of arrived ICMP errors */
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 5e0e46e..f47345c 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -51,6 +51,11 @@
 #include <net/ip6_route.h>
 #endif
 
+struct tunnels_net {
+	struct hlist_head *link_map;
+};
+static int tunnels_net_id;
+
 static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
 				   __be32 key, __be32 remote)
 {
@@ -235,8 +240,58 @@ static void ip_tunnel_add(struct ip_tunnel_net *itn, struct ip_tunnel *t)
 static void ip_tunnel_del(struct ip_tunnel_net *itn, struct ip_tunnel *t)
 {
 	hlist_del_init_rcu(&t->hash_node);
+	hlist_del_init_rcu(&t->link_node);
+}
+
+static void ip_tunnel_add_link(struct net *net, struct ip_tunnel *t, int iflink)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+	int hash = hash_32(iflink, IP_TNL_HASH_BITS);
+	struct hlist_head *head = &tn->link_map[hash];
+
+	hlist_add_head_rcu(&t->link_node, head);
+}
+
+static int ip_tunnel_notify(struct notifier_block *unused,
+		unsigned long event, void *ptr)
+{
+	struct net_device *rootdev = ptr;
+	struct tunnels_net *tn = net_generic(dev_net(rootdev), tunnels_net_id);
+	int hash = hash_32(rootdev->iflink, IP_TNL_HASH_BITS);
+	struct hlist_head *head = &tn->link_map[hash];
+	struct hlist_node *node, *n;
+	struct ip_tunnel *t;
+
+	hlist_for_each_entry_safe(t, node, n, head, link_node) {
+		int flags;
+
+		if (rootdev->ifindex != t->dev->iflink)
+			continue;
+		switch (event) {
+		case NETDEV_DOWN:
+			flags = t->dev->flags;
+			if (!(flags & IFF_UP))
+				break;
+			dev_change_flags(t->dev, flags & ~IFF_UP);
+			netif_stacked_transfer_operstate(rootdev, t->dev);
+			break;
+		case NETDEV_UP:
+			flags = t->dev->flags;
+			if (flags & IFF_UP)
+				break;
+			dev_change_flags(t->dev, flags | IFF_UP);
+			netif_stacked_transfer_operstate(rootdev, t->dev);
+			break;
+		}
+
+	}
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block ip_tunnel_notifier = {
+	.notifier_call = ip_tunnel_notify,
+};
+
 static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 				 struct ip_tunnel_parm *parms,
 				 int type)
@@ -356,8 +411,12 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
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
@@ -935,7 +994,7 @@ int ip_tunnel_newlink(struct net *src_net, struct net_device *dev,
 		dev->mtu = mtu;
 
 	ip_tunnel_add(itn, nt);
-
+	linkwatch_fire_event(dev);
 out:
 	return err;
 }
@@ -1060,4 +1119,53 @@ void ip_tunnel_setup(struct net_device *dev, int net_id)
 }
 EXPORT_SYMBOL(ip_tunnel_setup);
 
+static int __net_init tunnels_init_net(struct net *net)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+
+	tn->link_map = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
+	if (!tn->link_map)
+		return -ENOMEM;
+	return 0;
+}
+
+static void __net_exit tunnels_exit_net(struct net *net)
+{
+	struct tunnels_net *tn = net_generic(net, tunnels_net_id);
+	kfree(tn->link_map);
+}
+
+static struct pernet_operations tunnels_net_ops = {
+	.init = tunnels_init_net,
+	.exit = tunnels_exit_net,
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
+	if (err < 0) {
+		unregister_pernet_device(&tunnels_net_ops);
+		return err;
+	}
+
+	return 0;
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
-- 
1.7.1
