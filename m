From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/4] ipip: follow state of lower device
Date: Thu, 12 Apr 2012 09:31:19 -0700
Message-ID: <20120412163142.758141831@vyatta.com>
References: <20120412163115.076119065@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:40225 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762035Ab2DLQmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:42:03 -0400
Content-Disposition: inline; filename=ipip-lowerup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as other tunnels propogate
carrier and RFC2863 state from lower device to tunnel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ipip.c	2012-04-12 08:07:39.000000000 -0700
+++ b/net/ipv4/ipip.c	2012-04-12 08:14:37.776589029 -0700
@@ -304,6 +304,8 @@ static struct ip_tunnel * ipip_tunnel_lo
 
 	dev_hold(dev);
 	ipip_tunnel_link(ipn, nt);
+	linkwatch_fire_event(dev);
+
 	return nt;
 
 failed_free:
@@ -614,6 +616,7 @@ static void ipip_tunnel_bind_dev(struct
 	if (tdev) {
 		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
 		dev->mtu = tdev->mtu - sizeof(struct iphdr);
+		netif_stacked_transfer_operstate(tdev, dev);
 	}
 	dev->iflink = tunnel->parms.link;
 }
@@ -897,6 +900,36 @@ static struct pernet_operations ipip_net
 	.size = sizeof(struct ipip_net),
 };
 
+/* If lower device changes state, reflect that to the tunnel. */
+static int ipip_notify(struct notifier_block *unused,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
+	struct ip_tunnel *t;
+	unsigned int prio, h;
+
+	if (event == NETDEV_CHANGE)
+		return NOTIFY_DONE;
+
+	for (prio = 0; prio < 4; prio++)
+		for (h = 0; h < HASH_SIZE; h++) {
+			for (t = rtnl_dereference(ipn->tunnels[prio][h]); t;
+			     t = rtnl_dereference(t->next)) {
+				if (dev->ifindex != t->dev->iflink)
+					continue;
+				netif_stacked_transfer_operstate(dev, t->dev);
+			}
+		}
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
@@ -906,12 +939,24 @@ static int __init ipip_init(void)
 	err = register_pernet_device(&ipip_net_ops);
 	if (err < 0)
 		return err;
+
+	err = register_netdevice_notifier(&ipip_notifier);
+	if (err < 0)
+		goto notify_failed;
+
 	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
-	if (err < 0) {
-		unregister_pernet_device(&ipip_net_ops);
-		pr_info("%s: can't register tunnel\n", __func__);
-	}
+	if (err < 0)
+		goto xfrm4_tunnel_failed;
+out:
 	return err;
+
+xfrm4_tunnel_failed:
+	pr_info("%s: can't register tunnel\n", __func__);
+	unregister_netdevice_notifier(&ipip_notifier);
+
+notify_failed:
+	unregister_pernet_device(&ipip_net_ops);
+	goto out;
 }
 
 static void __exit ipip_fini(void)
