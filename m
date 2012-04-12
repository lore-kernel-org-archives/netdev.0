From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] ipgre: follow state of lower device
Date: Thu, 12 Apr 2012 09:31:17 -0700
Message-ID: <20120412163142.544953001@vyatta.com>
References: <20120412163115.076119065@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:40221 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1761969Ab2DLQmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:42:02 -0400
Content-Disposition: inline; filename=ipgre-lowerup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE tunnels like other layered devices should propogate
carrier and RFC2863 state from lower device to tunnel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ip_gre.c	2012-04-12 08:07:39.508107847 -0700
+++ b/net/ipv4/ip_gre.c	2012-04-12 08:10:14.177499183 -0700
@@ -991,6 +991,7 @@ static int ipgre_tunnel_bind_dev(struct
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
+		netif_stacked_transfer_operstate(tdev, dev);
 	}
 	dev->iflink = tunnel->parms.link;
 
@@ -1575,6 +1576,7 @@ static int ipgre_newlink(struct net *src
 
 	dev_hold(dev);
 	ipgre_tunnel_link(ign, nt);
+	linkwatch_fire_event(dev);
 
 out:
 	return err;
@@ -1732,6 +1734,36 @@ static struct rtnl_link_ops ipgre_tap_op
 	.fill_info	= ipgre_fill_info,
 };
 
+/* If lower device changes state, reflect that to the tunnel. */
+static int ipgre_notify(struct notifier_block *unused,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	unsigned int prio, h;
+	struct ip_tunnel *t;
+
+	if (event == NETDEV_CHANGE)
+		return NOTIFY_DONE;
+
+	for (prio = 0; prio < 4; prio++)
+		for (h = 0; h < HASH_SIZE; h++) {
+			for (t = rtnl_dereference(ign->tunnels[prio][h]);
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
+static struct notifier_block ipgre_notifier = {
+	.notifier_call = ipgre_notify,
+};
+
 /*
  *	And now the modules code and kernel interface.
  */
@@ -1760,9 +1792,15 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
+	err = register_netdevice_notifier(&ipgre_notifier);
+	if (err < 0)
+		goto notify_failed;
+
 out:
 	return err;
 
+notify_failed:
+	rtnl_link_unregister(&ipgre_tap_ops);
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
@@ -1774,6 +1812,7 @@ add_proto_failed:
 
 static void __exit ipgre_fini(void)
 {
+	unregister_netdevice_notifier(&ipgre_notifier);
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
