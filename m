From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] ipvlan: use pernet operations and restrict l3s hooks to master netns
Date: Thu, 20 Apr 2017 18:08:15 +0200
Message-ID: <20170420160815.7201-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49208 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S970984AbdDTQIB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:08:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4fbae7d83c98c30efc ("ipvlan: Introduce l3s mode") added
registration of netfilter hooks via nf_register_hooks().

This API provides the illusion of 'global' netfilter hooks by placing the
hooks in all current and future network namespaces.

In case of ipvlan the hook appears to be only needed in the namespace
that contains the ipvlan master device (i.e., usually init_net), so
placing them in all namespaces is not needed.

This switches ipvlan driver to pernet operations, and then only registers
hooks in namespaces where a ipvlan master device is set to l3s mode.

Extra care has to be taken when the master device is moved to another
namespace, as we might have to 'move' the netfilter hooks too.

This is done by storing the namespace the ipvlan port was created in.
On REGISTER event, do (un)register operations in the old/new namespaces.

This will also allow removal of the nf_register_hooks() in a future patch.

Cc: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ipvlan/ipvlan.h      |  2 +
 drivers/net/ipvlan/ipvlan_main.c | 83 ++++++++++++++++++++++++++++++++--------
 2 files changed, 70 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 800a46c8d26c..7919369c0a72 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -26,6 +26,7 @@
 #include <linux/netfilter.h>
 #include <net/ip.h>
 #include <net/ip6_route.h>
+#include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/addrconf.h>
@@ -91,6 +92,7 @@ struct ipvl_addr {
 
 struct ipvl_port {
 	struct net_device	*dev;
+	possible_net_t		pnet;
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
 	u16			mode;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index aa8575ccbce3..618ed88fad0f 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,7 +9,11 @@
 
 #include "ipvlan.h"
 
-static u32 ipvl_nf_hook_refcnt = 0;
+static unsigned int ipvlan_netid __read_mostly;
+
+struct ipvlan_netns {
+	unsigned int ipvl_nf_hook_refcnt;
+};
 
 static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
 	{
@@ -35,28 +39,34 @@ static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 	ipvlan->dev->mtu = dev->mtu;
 }
 
-static int ipvlan_register_nf_hook(void)
+static int ipvlan_register_nf_hook(struct net *net)
 {
+	struct ipvlan_netns *vnet = net_generic(net, ipvlan_netid);
 	int err = 0;
 
-	if (!ipvl_nf_hook_refcnt) {
-		err = _nf_register_hooks(ipvl_nfops, ARRAY_SIZE(ipvl_nfops));
+	if (!vnet->ipvl_nf_hook_refcnt) {
+		err = nf_register_net_hooks(net, ipvl_nfops,
+					    ARRAY_SIZE(ipvl_nfops));
 		if (!err)
-			ipvl_nf_hook_refcnt = 1;
+			vnet->ipvl_nf_hook_refcnt = 1;
 	} else {
-		ipvl_nf_hook_refcnt++;
+		vnet->ipvl_nf_hook_refcnt++;
 	}
 
 	return err;
 }
 
-static void ipvlan_unregister_nf_hook(void)
+static void ipvlan_unregister_nf_hook(struct net *net)
 {
-	WARN_ON(!ipvl_nf_hook_refcnt);
+	struct ipvlan_netns *vnet = net_generic(net, ipvlan_netid);
+
+	if (WARN_ON(!vnet->ipvl_nf_hook_refcnt))
+		return;
 
-	ipvl_nf_hook_refcnt--;
-	if (!ipvl_nf_hook_refcnt)
-		_nf_unregister_hooks(ipvl_nfops, ARRAY_SIZE(ipvl_nfops));
+	vnet->ipvl_nf_hook_refcnt--;
+	if (!vnet->ipvl_nf_hook_refcnt)
+		nf_unregister_net_hooks(net, ipvl_nfops,
+					ARRAY_SIZE(ipvl_nfops));
 }
 
 static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
@@ -69,7 +79,7 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 	if (port->mode != nval) {
 		if (nval == IPVLAN_MODE_L3S) {
 			/* New mode is L3S */
-			err = ipvlan_register_nf_hook();
+			err = ipvlan_register_nf_hook(read_pnet(&port->pnet));
 			if (!err) {
 				mdev->l3mdev_ops = &ipvl_l3mdev_ops;
 				mdev->priv_flags |= IFF_L3MDEV_MASTER;
@@ -78,7 +88,7 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 		} else if (port->mode == IPVLAN_MODE_L3S) {
 			/* Old mode was L3S */
 			mdev->priv_flags &= ~IFF_L3MDEV_MASTER;
-			ipvlan_unregister_nf_hook();
+			ipvlan_unregister_nf_hook(read_pnet(&port->pnet));
 			mdev->l3mdev_ops = NULL;
 		}
 		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
@@ -111,6 +121,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	if (!port)
 		return -ENOMEM;
 
+	write_pnet(&port->pnet, dev_net(dev));
 	port->dev = dev;
 	port->mode = IPVLAN_MODE_L3;
 	INIT_LIST_HEAD(&port->ipvlans);
@@ -142,7 +153,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
 	if (port->mode == IPVLAN_MODE_L3S) {
 		dev->priv_flags &= ~IFF_L3MDEV_MASTER;
-		ipvlan_unregister_nf_hook();
+		ipvlan_unregister_nf_hook(dev_net(dev));
 		dev->l3mdev_ops = NULL;
 	}
 	netdev_rx_handler_unregister(dev);
@@ -673,6 +684,24 @@ static int ipvlan_device_event(struct notifier_block *unused,
 							 ipvlan->dev);
 		break;
 
+	case NETDEV_REGISTER: {
+		struct net *oldnet, *newnet = dev_net(dev);
+		struct ipvlan_netns *old_vnet;
+
+		oldnet = read_pnet(&port->pnet);
+		if (net_eq(newnet, oldnet))
+			break;
+
+		write_pnet(&port->pnet, newnet);
+
+		old_vnet = net_generic(oldnet, ipvlan_netid);
+		if (!old_vnet->ipvl_nf_hook_refcnt)
+			break;
+
+		ipvlan_register_nf_hook(newnet);
+		ipvlan_unregister_nf_hook(oldnet);
+		break;
+	}
 	case NETDEV_UNREGISTER:
 		if (dev->reg_state != NETREG_UNREGISTERING)
 			break;
@@ -854,6 +883,23 @@ static struct notifier_block ipvlan_addr6_notifier_block __read_mostly = {
 	.notifier_call = ipvlan_addr6_event,
 };
 
+static void ipvlan_ns_exit(struct net *net)
+{
+	struct ipvlan_netns *vnet = net_generic(net, ipvlan_netid);
+
+	if (WARN_ON_ONCE(vnet->ipvl_nf_hook_refcnt)) {
+		vnet->ipvl_nf_hook_refcnt = 0;
+		nf_unregister_net_hooks(net, ipvl_nfops,
+					ARRAY_SIZE(ipvl_nfops));
+	}
+}
+
+static struct pernet_operations ipvlan_net_ops = {
+	.id = &ipvlan_netid,
+	.size = sizeof(struct ipvlan_netns),
+	.exit = ipvlan_ns_exit,
+};
+
 static int __init ipvlan_init_module(void)
 {
 	int err;
@@ -863,10 +909,16 @@ static int __init ipvlan_init_module(void)
 	register_inet6addr_notifier(&ipvlan_addr6_notifier_block);
 	register_inetaddr_notifier(&ipvlan_addr4_notifier_block);
 
-	err = ipvlan_link_register(&ipvlan_link_ops);
+	err = register_pernet_subsys(&ipvlan_net_ops);
 	if (err < 0)
 		goto error;
 
+	err = ipvlan_link_register(&ipvlan_link_ops);
+	if (err < 0) {
+		unregister_pernet_subsys(&ipvlan_net_ops);
+		goto error;
+	}
+
 	return 0;
 error:
 	unregister_inetaddr_notifier(&ipvlan_addr4_notifier_block);
@@ -878,6 +930,7 @@ static int __init ipvlan_init_module(void)
 static void __exit ipvlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&ipvlan_link_ops);
+	unregister_pernet_subsys(&ipvlan_net_ops);
 	unregister_netdevice_notifier(&ipvlan_notifier_block);
 	unregister_inetaddr_notifier(&ipvlan_addr4_notifier_block);
 	unregister_inet6addr_notifier(&ipvlan_addr6_notifier_block);
-- 
2.10.2
