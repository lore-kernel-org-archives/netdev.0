From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/2 net-next] ip_tunnel: operstate support and link state
 transfer
Date: Mon, 5 Aug 2013 22:53:59 -0700
Message-ID: <20130805225359.7ba89042@nehalam.linuxnetplumber.net>
References: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:57905 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652Ab3HFFyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 01:54:09 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so4311357pbc.22
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 22:54:08 -0700 (PDT)
In-Reply-To: <20130805225137.6c934d7f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnel devices should reflect the carrier state of the lower device.
I.e if carrier goes down on the lower (ethernet) device, it should
change on the tunnel as well.

This patch also adds full RFC2863 compatible state so that the
tunnel state can be controlled from user space as described in
Documentation/networking/operstats.txt

Example of usage:
ip li add tnl1 mode dormant \
  type gretap remote 172.19.20.21 local 172.16.17.18 dev eth1
ip li set dev tnl1 up
ip li set dev tnl1 state UP

In real life, this would be managed by tunnel broker, not
iproute2 shell commands.


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/net/ip_tunnels.h |    4 ++++
 net/ipv4/ip_gre.c        |   35 +++++++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel.c     |   41 +++++++++++++++++++++++++++++++++++++----
 net/ipv4/ip_vti.c        |   23 +++++++++++++++++++++++
 net/ipv4/ipip.c          |   22 ++++++++++++++++++++++
 5 files changed, 121 insertions(+), 4 deletions(-)

--- a/include/net/ip_tunnels.h	2013-08-05 16:49:31.965828932 -0700
+++ b/include/net/ip_tunnels.h	2013-08-05 16:49:34.001797670 -0700
@@ -41,6 +41,7 @@ struct ip_tunnel_prl_entry {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
+	struct hlist_node hash_dev;
 	struct net_device	*dev;
 	struct net		*net;	/* netns for packet i/o */
 
@@ -92,6 +93,7 @@ struct tnl_ptk_info {
 struct ip_tunnel_net {
 	struct net_device *fb_tunnel_dev;
 	struct hlist_head tunnels[IP_TNL_HASH_SIZE];
+	struct hlist_head lower_dev[NETDEV_HASHENTRIES];
 };
 
 #ifdef CONFIG_INET
@@ -101,6 +103,8 @@ void ip_tunnel_uninit(struct net_device
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
+void ip_tunnel_stacked_transfer(struct ip_tunnel_net *itn,
+				struct net_device *dev);
 
 void ip_tunnel_delete_net(struct ip_tunnel_net *itn);
 
--- a/net/ipv4/ip_gre.c	2013-08-05 07:58:55.521573667 -0700
+++ b/net/ipv4/ip_gre.c	2013-08-05 22:41:10.879993567 -0700
@@ -777,6 +777,32 @@ static struct pernet_operations ipgre_ta
 	.size = sizeof(struct ip_tunnel_net),
 };
 
+/* If lower device changes state, reflect that to the tunnel. */
+static int ipgre_notify(struct notifier_block *unused,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct net *net = dev_net(dev);
+	struct ip_tunnel_net *itn;
+
+	if (event != NETDEV_CHANGE)
+		return NOTIFY_DONE;
+
+	if (dev->type == ARPHRD_IPGRE)
+		itn = net_generic(net, ipgre_net_id);
+	else if (dev->type == ARPHRD_ETHER)
+		itn = net_generic(net, gre_tap_net_id);
+	else
+		return NOTIFY_DONE;
+
+	ip_tunnel_stacked_transfer(itn, dev);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ipgre_notifier = {
+	.notifier_call = ipgre_notify,
+};
+
 static int __init ipgre_init(void)
 {
 	int err;
@@ -805,8 +831,14 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
+	err = register_netdevice_notifier(&ipgre_notifier);
+	if (err < 0)
+		goto notify_failed;
+
 	return 0;
 
+notify_failed:
+	rtnl_link_unregister(&ipgre_tap_ops);
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
@@ -820,6 +852,7 @@ pnet_tap_faied:
 
 static void __exit ipgre_fini(void)
 {
+	unregister_netdevice_notifier(&ipgre_notifier);
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	gre_cisco_unregister(&ipgre_protocol);
--- a/net/ipv4/ip_tunnel.c	2013-08-05 16:49:31.965828932 -0700
+++ b/net/ipv4/ip_tunnel.c	2013-08-05 22:46:06.578307707 -0700
@@ -243,12 +243,32 @@ static void ip_tunnel_add(struct ip_tunn
 	struct hlist_head *head = ip_bucket(itn, &t->parms);
 
 	hlist_add_head_rcu(&t->hash_node, head);
+	if (t->parms.link) {
+		unsigned hash = t->parms.link & (NETDEV_HASHENTRIES - 1);
+		hlist_add_head(&t->hash_dev, &itn->lower_dev[hash]);
+	}
 }
 
 static void ip_tunnel_del(struct ip_tunnel *t)
 {
 	hlist_del_init_rcu(&t->hash_node);
+	hlist_del_init(&t->hash_dev);
+}
+
+void ip_tunnel_stacked_transfer(struct ip_tunnel_net *itn,
+				struct net_device *dev)
+{
+	struct ip_tunnel *t;
+	unsigned devhash = dev->ifindex & (NETDEV_HASHENTRIES - 1);
+
+	ASSERT_RTNL();
+
+	hlist_for_each_entry(t, &itn->lower_dev[devhash], hash_dev) {
+		if (t->parms.link == dev->ifindex)
+			netif_stacked_transfer_operstate(dev, t->dev);
+	}
 }
+EXPORT_SYMBOL(ip_tunnel_stacked_transfer);
 
 static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
 					struct ip_tunnel_parm *parms,
@@ -310,6 +330,7 @@ static struct net_device *__ip_tunnel_cr
 	if (err)
 		goto failed_free;
 
+	linkwatch_fire_event(dev);	/* call rfc2863_policy */
 	return dev;
 
 failed_free:
@@ -334,7 +355,7 @@ static inline struct rtable *ip_route_ou
 	return ip_route_output_key(net, fl4);
 }
 
-static int ip_tunnel_bind_dev(struct net_device *dev)
+static int ip_tunnel_bind_dev(struct ip_tunnel_net *itn, struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -370,6 +391,9 @@ static int ip_tunnel_bind_dev(struct net
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
+
+		netif_stacked_transfer_operstate(tdev, dev);
+		linkwatch_fire_event(dev); /* call rfc2863_policy() */
 	}
 	dev->iflink = tunnel->parms.link;
 
@@ -395,7 +419,7 @@ static struct ip_tunnel *ip_tunnel_creat
 	if (IS_ERR(dev))
 		return NULL;
 
-	dev->mtu = ip_tunnel_bind_dev(dev);
+	dev->mtu = ip_tunnel_bind_dev(itn, dev);
 
 	nt = netdev_priv(dev);
 	ip_tunnel_add(itn, nt);
@@ -695,7 +719,7 @@ static void ip_tunnel_update(struct ip_t
 		int mtu;
 
 		t->parms.link = p->link;
-		mtu = ip_tunnel_bind_dev(dev);
+		mtu = ip_tunnel_bind_dev(itn, dev);
 		if (set_mtu)
 			dev->mtu = mtu;
 	}
@@ -914,7 +938,7 @@ int ip_tunnel_newlink(struct net_device
 	if (dev->type == ARPHRD_ETHER && !tb[IFLA_ADDRESS])
 		eth_hw_addr_random(dev);
 
-	mtu = ip_tunnel_bind_dev(dev);
+	mtu = ip_tunnel_bind_dev(itn, dev);
 	if (!tb[IFLA_MTU])
 		dev->mtu = mtu;
 
--- a/net/ipv4/ip_vti.c	2013-08-05 07:58:55.521573667 -0700
+++ b/net/ipv4/ip_vti.c	2013-08-05 22:39:39.068790171 -0700
@@ -429,6 +429,22 @@ static struct rtnl_link_ops vti_link_ops
 	.fill_info	= vti_fill_info,
 };
 
+static int vti_notify(struct notifier_block *unused,
+		      unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct ip_tunnel_net *itn = net_generic(dev_net(dev), vti_net_id);
+
+	if (event == NETDEV_CHANGE)
+		ip_tunnel_stacked_transfer(itn, dev);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block vti_notifier = {
+	.notifier_call = vti_notify,
+};
+
 static int __init vti_init(void)
 {
 	int err;
@@ -448,8 +464,14 @@ static int __init vti_init(void)
 	if (err < 0)
 		goto rtnl_link_failed;
 
+	err = register_netdevice_notifier(&vti_notifier);
+	if (err < 0)
+		goto notify_failed;
+
 	return err;
 
+notify_failed:
+	rtnl_link_unregister(&vti_link_ops);
 rtnl_link_failed:
 	xfrm4_mode_tunnel_input_deregister(&vti_handler);
 	unregister_pernet_device(&vti_net_ops);
@@ -458,6 +480,7 @@ rtnl_link_failed:
 
 static void __exit vti_fini(void)
 {
+	unregister_netdevice_notifier(&vti_notifier);
 	rtnl_link_unregister(&vti_link_ops);
 	if (xfrm4_mode_tunnel_input_deregister(&vti_handler))
 		pr_info("vti close: can't deregister tunnel\n");
--- a/net/ipv4/ipip.c	2013-08-05 07:58:55.521573667 -0700
+++ b/net/ipv4/ipip.c	2013-08-05 22:39:05.253137638 -0700
@@ -447,6 +447,22 @@ static struct pernet_operations ipip_net
 	.size = sizeof(struct ip_tunnel_net),
 };
 
+static int ipip_notify(struct notifier_block *unused,
+		      unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct ip_tunnel_net *itn = net_generic(dev_net(dev), ipip_net_id);
+
+	if (event == NETDEV_CHANGE)
+		ip_tunnel_stacked_transfer(itn, dev);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ipip_notifier = {
+	.notifier_call = ipip_notify,
+};
+
 static int __init ipip_init(void)
 {
 	int err;
@@ -465,9 +481,14 @@ static int __init ipip_init(void)
 	if (err < 0)
 		goto rtnl_link_failed;
 
+	err = register_netdevice_notifier(&ipip_notifier);
+	if (err < 0)
+		goto notify_failed;
 out:
 	return err;
 
+notify_failed:
+	rtnl_link_unregister(&ipip_link_ops);
 rtnl_link_failed:
 	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 xfrm_tunnel_failed:
@@ -477,6 +498,7 @@ xfrm_tunnel_failed:
 
 static void __exit ipip_fini(void)
 {
+	unregister_netdevice_notifier(&ipip_notifier);
 	rtnl_link_unregister(&ipip_link_ops);
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		pr_info("%s: can't deregister tunnel\n", __func__);
