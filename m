From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] gre: propagate state of link back go to tunnel
Date: Mon, 19 Mar 2012 16:58:43 -0700
Message-ID: <20120319165843.7b18412a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57413 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab2CSX6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 19:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE tunnels like other layered devices should propagate
carrier and RFC2863 state from lower device to tunnel.
Based on similar code in vlan device driver.
By using operstate it is possible for user mode to create tunnel
and use stepped outlined in Documentation/networking/operstate.txt
to control carrier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Not urgent, can wait if the release window is already over the
queue limit

--- a/net/ipv4/ip_gre.c	2012-03-19 16:09:46.662376422 -0700
+++ b/net/ipv4/ip_gre.c	2012-03-19 16:13:49.845108466 -0700
@@ -961,6 +961,7 @@ static int ipgre_tunnel_bind_dev(struct
 	if (tdev) {
 		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
+		netif_stacked_transfer_operstate(tdev, dev);
 	}
 	dev->iflink = tunnel->parms.link;
 
@@ -1545,6 +1546,7 @@ static int ipgre_newlink(struct net *src
 
 	dev_hold(dev);
 	ipgre_tunnel_link(ign, nt);
+	linkwatch_fire_event(dev); /* _MUST_ call rfc2863_policy() */
 
 out:
 	return err;
@@ -1701,6 +1703,34 @@ static struct rtnl_link_ops ipgre_tap_op
 	.fill_info	= ipgre_fill_info,
 };
 
+/* If lower device changes state, reflect that to the tunnel. */
+static int ipgre_notify(struct notifier_block *unused,
+			unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	unsigned int i, h;
+	struct ip_tunnel *t;
+
+	if (event == NETDEV_CHANGE)
+		return NOTIFY_DONE;
+
+	for (i = 0; i < 4; i++)
+		for (h = 0; h < HASH_SIZE; h++)
+			for(t = ign->tunnels[i][h]; t; t = t->next) {
+				if (dev->ifindex != t->dev->iflink)
+					continue;
+				netif_stacked_transfer_operstate(dev, t->dev);
+			}
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
@@ -1729,9 +1759,15 @@ static int __init ipgre_init(void)
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
@@ -1743,6 +1779,7 @@ add_proto_failed:
 
 static void __exit ipgre_fini(void)
 {
+	unregister_netdevice_notifier(&ipgre_notifier);
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
