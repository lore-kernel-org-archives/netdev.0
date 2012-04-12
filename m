From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/4] sit: follow state of lower device
Date: Thu, 12 Apr 2012 09:31:18 -0700
Message-ID: <20120412163142.659412516@vyatta.com>
References: <20120412163115.076119065@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:40222 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757816Ab2DLQmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:42:02 -0400
Content-Disposition: inline; filename=sit-lowerup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIT tunnels like other layered devices should propogate
carrier and RFC2863 state from lower device to tunnel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/sit.c	2012-04-12 08:31:05.249059443 -0700
+++ b/net/ipv6/sit.c	2012-04-12 08:34:44.093009537 -0700
@@ -284,6 +284,7 @@ static struct ip_tunnel *ipip6_tunnel_lo
 	dev_hold(dev);
 
 	ipip6_tunnel_link(sitn, nt);
+	linkwatch_fire_event(dev);
 	return nt;
 
 failed_free:
@@ -901,6 +902,7 @@ static void ipip6_tunnel_bind_dev(struct
 		dev->mtu = tdev->mtu - sizeof(struct iphdr);
 		if (dev->mtu < IPV6_MIN_MTU)
 			dev->mtu = IPV6_MIN_MTU;
+		netif_stacked_transfer_operstate(tdev, dev);
 	}
 	dev->iflink = tunnel->parms.link;
 }
@@ -1231,6 +1233,36 @@ static void __net_exit sit_destroy_tunne
 	}
 }
 
+/* If lower device changes state, reflect that to the tunnel. */
+static int sit_notify(struct notifier_block *unused,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+	unsigned int prio, h;
+	struct ip_tunnel *t;
+
+	if (event == NETDEV_CHANGE)
+		return NOTIFY_DONE;
+
+	for (prio = 0; prio < 4; prio++)
+		for (h = 0; h < HASH_SIZE; h++) {
+			for (t = rtnl_dereference(sitn->tunnels[prio][h]);
+			     t; t = rtnl_dereference(t->next)) {
+				if (dev->ifindex != t->dev->iflink)
+					continue;
+				netif_stacked_transfer_operstate(dev, t->dev);
+			}
+		}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block sit_notifier = {
+	.notifier_call = sit_notify,
+};
+
 static int __net_init sit_init_net(struct net *net)
 {
 	struct sit_net *sitn = net_generic(net, sit_net_id);
@@ -1293,6 +1325,7 @@ static struct pernet_operations sit_net_
 
 static void __exit sit_cleanup(void)
 {
+	unregister_netdevice_notifier(&sit_notifier);
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
 	unregister_pernet_device(&sit_net_ops);
@@ -1309,11 +1342,21 @@ static int __init sit_init(void)
 	if (err < 0)
 		return err;
 	err = xfrm4_tunnel_register(&sit_handler, AF_INET6);
-	if (err < 0) {
-		unregister_pernet_device(&sit_net_ops);
-		printk(KERN_INFO "sit init: Can't add protocol\n");
-	}
+	if (err < 0)
+		goto xfrm4_failed;
+
+	err = register_netdevice_notifier(&sit_notifier);
+	if (err < 0)
+		goto notify_failed;
+
+out:
 	return err;
+
+notify_failed:
+	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
+xfrm4_failed:
+	unregister_pernet_device(&sit_net_ops);
+	goto out;
 }
 
 module_init(sit_init);
