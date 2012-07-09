From: Christian Franke <christian.franke@adytonsystems.com>
Subject: [RFC PATCH] net/ipv4/ipip: add support to move between network namespaces
Date: Mon,  9 Jul 2012 17:41:13 +0200
Message-ID: <1341848473-2666-1-git-send-email-christian.franke@adytonsystems.com>
Cc: Christian Franke <christian.franke@adytonsystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35839 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab2GIPld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 11:41:33 -0400
Received: by bkwj10 with SMTP id j10so6114088bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 08:41:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Below there is a first attempt at adding support for IPIP tunnels to be moved
across network namespaces. This allows e.g. for tunnel setups where the inner
network is completely isolated from the outer transport network.

One thing I would especially like comments on is the current approach at
namespace reference counting. Currently, the tunnel will acquire a reference
to its original namespace when it is moved to a different namespace, preventing
the transport namespace from being destroyed until the tunnel is either returned
or deleted.

Best Regards,
Christian Franke
---
 include/net/ipip.h |  1 +
 net/ipv4/ipip.c    | 91 ++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 83 insertions(+), 9 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index a93cf6d..f7ab237 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -18,6 +18,7 @@ struct ip_tunnel_6rd_parm {
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct net_device	*dev;
+	struct net		*target_net;
 
 	int			err_count;	/* Number of arrived ICMP errors */
 	unsigned long		err_time;	/* Time when the last ICMP error arrived */
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 715338a..2321a34 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -99,6 +99,7 @@
 #include <asm/uaccess.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/notifier.h>
 #include <linux/in.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -151,6 +152,13 @@ struct pcpu_tstats {
 	struct u64_stats_sync	syncp;
 };
 
+static inline struct net *target_net(struct net_device *dev)
+{
+	struct ip_tunnel *t = netdev_priv(dev);
+
+	return t->target_net ? t->target_net : dev_net(dev);
+}
+
 static struct rtnl_link_stats64 *ipip_get_stats64(struct net_device *dev,
 						  struct rtnl_link_stats64 *tot)
 {
@@ -314,7 +322,7 @@ failed_free:
 /* called with RTNL */
 static void ipip_tunnel_uninit(struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
+	struct net *net = target_net(dev);
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
 	if (dev == ipn->fb_tunnel_dev)
@@ -481,7 +489,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		dst = rt->rt_gateway;
 	}
 
-	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
+	rt = ip_route_output_ports(target_net(dev), &fl4, NULL,
 				   dst, tiph->saddr,
 				   0, 0,
 				   IPPROTO_IPIP, RT_TOS(tos),
@@ -631,7 +639,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
-	struct net *net = dev_net(dev);
+	struct net *net = target_net(dev);
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
 	switch (cmd) {
@@ -652,6 +660,9 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		break;
 
 	case SIOCADDTUNNEL:
+		/* New Tunnels will be created in the current namespace */
+		net = dev_net(dev);
+		ipn = net_generic(net, ipip_net_id);
 	case SIOCCHGTUNNEL:
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
@@ -701,6 +712,15 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
 				if (t->parms.link != p.link) {
+					if (!net_eq(dev_net(dev),
+						    target_net(dev))) {
+						pr_info_once("%s: rebinding "
+							     "cross ns device "
+							     "is not supported\n",
+							     __func__);
+						err = -ENOTTY;
+						goto done;
+					}
 					t->parms.link = p.link;
 					ipip_tunnel_bind_dev(dev);
 					netdev_state_change(dev);
@@ -759,6 +779,10 @@ static const struct net_device_ops ipip_netdev_ops = {
 
 static void ipip_dev_free(struct net_device *dev)
 {
+	struct ip_tunnel *t = netdev_priv(dev);
+
+	if (t->target_net)
+		put_net(t->target_net);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -774,7 +798,6 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
 	dev->features		|= NETIF_F_LLTX;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
@@ -904,20 +927,69 @@ static struct pernet_operations ipip_net_ops = {
 	.size = sizeof(struct ipip_net),
 };
 
+static bool ipip_device_exists(struct net_device *dev)
+{
+	/* TODO: this is probably not the right check */
+	return dev->netdev_ops == &ipip_netdev_ops;
+}
+
+static int ipip_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct ip_tunnel *t;
+
+	if (!ipip_device_exists(dev))
+		return NOTIFY_DONE;
+
+	t = netdev_priv(dev);
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		/* When the tunnel is moved from its natural
+		 * network namespace, it will keep a reference
+		 * to it. */
+		if (dev->reg_state != NETREG_UNREGISTERING) {
+			if (!t->target_net)
+				t->target_net = get_net(dev_net(dev));
+		}
+		break;
+	case NETDEV_REGISTER:
+		if (net_eq(dev_net(dev), t->target_net)) {
+			put_net(t->target_net);
+			t->target_net = NULL;
+		}
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ipip_notifier_block = {
+	.notifier_call = ipip_device_event,
+};
+
 static int __init ipip_init(void)
 {
 	int err;
 
 	printk(banner);
 
-	err = register_pernet_device(&ipip_net_ops);
+	err = register_netdevice_notifier(&ipip_notifier_block);
 	if (err < 0)
 		return err;
+
+	err = register_pernet_device(&ipip_net_ops);
+	if (err < 0)
+		goto out_pernet;
+
 	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
-	if (err < 0) {
-		unregister_pernet_device(&ipip_net_ops);
-		pr_info("%s: can't register tunnel\n", __func__);
-	}
+	if (err < 0)
+		goto out_xfrm;
+	return err;
+out_xfrm:
+	unregister_pernet_device(&ipip_net_ops);
+out_pernet:
+	unregister_netdevice_notifier(&ipip_notifier_block);
+	pr_info("%s: can't register tunnel\n", __func__);
 	return err;
 }
 
@@ -927,6 +999,7 @@ static void __exit ipip_fini(void)
 		pr_info("%s: can't deregister tunnel\n", __func__);
 
 	unregister_pernet_device(&ipip_net_ops);
+	unregister_netdevice_notifier(&ipip_notifier_block);
 }
 
 module_init(ipip_init);
-- 
1.7.11
