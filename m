From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH] net: fold dev_disable_lro() into netdev_fix_features()
Date: Sat,  7 May 2011 13:48:02 +0200 (CEST)
Message-ID: <20110507114803.0D80A13A6B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55067 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585Ab1EGLsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 07:48:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves checks that device is forwarding from bridge, IPv4 and IPv6
code into netdev_fix_features(). As a side effect, after device is no l=
onger
forwarding it gets LRO back. This also means that user is not allowed t=
o
enable LRO after device is put to forwarding mode.

This patch depends on removal of discrete offload setting ethtool ops.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    1 -
 net/bridge/br_if.c        |    6 +++---
 net/core/dev.c            |   41 +++++++++++++++++++++----------------=
----
 net/ipv4/devinet.c        |   20 +++++++++-----------
 net/ipv6/addrconf.c       |    7 +++----
 5 files changed, 36 insertions(+), 39 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7be3ca2..3a8c21d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1627,7 +1627,6 @@ extern struct net_device	*__dev_get_by_name(struc=
t net *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
-extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice_queue(struct net_device *dev,
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 5dbdfdf..62aab1e 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -158,6 +158,8 @@ static void del_nbp(struct net_bridge_port *p)
 	br_netpoll_disable(p);
=20
 	call_rcu(&p->rcu, destroy_nbp_rcu);
+
+	netdev_update_features(dev);
 }
=20
 /* called with RTNL */
@@ -368,11 +370,9 @@ int br_add_if(struct net_bridge *br, struct net_de=
vice *dev)
=20
 	dev->priv_flags |=3D IFF_BRIDGE_PORT;
=20
-	dev_disable_lro(dev);
-
 	list_add_rcu(&p->list, &br->port_list);
=20
-	netdev_update_features(br->dev);
+	netdev_update_features(dev);
=20
 	spin_lock_bh(&br->lock);
 	changed_addr =3D br_stp_recalculate_bridge_id(br);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7193499..3d646c9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <trace/events/skb.h>
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
+#include <net/addrconf.h>
 #include <linux/cpu_rmap.h>
=20
 #include "net-sysfs.h"
@@ -1294,26 +1295,6 @@ int dev_close(struct net_device *dev)
 EXPORT_SYMBOL(dev_close);
=20
=20
-/**
- *	dev_disable_lro - disable Large Receive Offload on a device
- *	@dev: device
- *
- *	Disable Large Receive Offload (LRO) on a net device.  Must be
- *	called under RTNL.  This is needed if received packets may be
- *	forwarded to another interface.
- */
-void dev_disable_lro(struct net_device *dev)
-{
-	dev->wanted_features &=3D ~NETIF_F_LRO;
-	netdev_update_features(dev);
-
-	if (unlikely(dev->features & NETIF_F_LRO))
-		netdev_WARN(dev, "failed to disable LRO!\n");
-
-}
-EXPORT_SYMBOL(dev_disable_lro);
-
-
 static int dev_boot_phase =3D 1;
=20
 /**
@@ -5239,6 +5220,26 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 		}
 	}
=20
+	if (features & NETIF_F_LRO) {
+		struct in_device *in4_dev;
+		struct inet6_dev *in6_dev;
+
+		/* disable LRO for bridge ports */
+		if (dev->priv_flags & IFF_BRIDGE_PORT) {
+			netdev_info(dev, "Disabling LRO for bridge port.\n");
+			features &=3D NETIF_F_LRO;
+		} else /* ... or when forwarding IPv4 */
+		if (((in4_dev =3D __in_dev_get_rtnl(dev))) &&
+		    IN_DEV_CONF_GET(in4_dev, FORWARDING)) {
+			netdev_info(dev, "Disabling LRO for IPv4 router port.\n");
+			features &=3D NETIF_F_LRO;
+		} else /* ... or when forwarding IPv6 */
+		if (((in6_dev =3D __in6_dev_get(dev))) && in6_dev->cnf.forwarding) {
+			netdev_info(dev, "Disabling LRO for IPv6 router port.\n");
+			features &=3D NETIF_F_LRO;
+		}
+	}
+
 	return features;
 }
 EXPORT_SYMBOL(netdev_fix_features);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd9ca08..e9c0557 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -245,8 +245,6 @@ static struct in_device *inetdev_init(struct net_de=
vice *dev)
 	in_dev->arp_parms =3D neigh_parms_alloc(dev, &arp_tbl);
 	if (!in_dev->arp_parms)
 		goto out_kfree;
-	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
-		dev_disable_lro(dev);
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
@@ -259,6 +257,8 @@ static struct in_device *inetdev_init(struct net_de=
vice *dev)
=20
 	/* we can receive as soon as ip_ptr is set -- do this last */
 	rcu_assign_pointer(dev->ip_ptr, in_dev);
+
+	netdev_update_features(dev);
 out:
 	return in_dev;
 out_kfree:
@@ -1475,14 +1475,12 @@ static void inet_forward_change(struct net *net=
)
 	IPV4_DEVCONF_DFLT(net, FORWARDING) =3D on;
=20
 	for_each_netdev(net, dev) {
-		struct in_device *in_dev;
-		if (on)
-			dev_disable_lro(dev);
-		rcu_read_lock();
-		in_dev =3D __in_dev_get_rcu(dev);
-		if (in_dev)
+		struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
+
+		if (in_dev) {
 			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
-		rcu_read_unlock();
+			netdev_update_features(in_dev->dev);
+		}
 	}
 }
=20
@@ -1527,11 +1525,11 @@ static int devinet_sysctl_forward(ctl_table *ct=
l, int write,
 			}
 			if (valp =3D=3D &IPV4_DEVCONF_ALL(net, FORWARDING)) {
 				inet_forward_change(net);
-			} else if (*valp) {
+			} else {
 				struct ipv4_devconf *cnf =3D ctl->extra1;
 				struct in_device *idev =3D
 					container_of(cnf, struct in_device, cnf);
-				dev_disable_lro(idev->dev);
+				netdev_update_features(idev->dev);
 			}
 			rtnl_unlock();
 			rt_cache_flush(net, 0);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2f9b2e..d1344ac 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -370,8 +370,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_d=
evice *dev)
 		kfree(ndev);
 		return NULL;
 	}
-	if (ndev->cnf.forwarding)
-		dev_disable_lro(dev);
 	/* We refer to the device */
 	dev_hold(dev);
=20
@@ -435,6 +433,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_d=
evice *dev)
 	addrconf_sysctl_register(ndev);
 	/* protected by rtnl_lock */
 	rcu_assign_pointer(dev->ip6_ptr, ndev);
+	netdev_update_features(dev);
=20
 	/* Join all-node multicast group */
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
@@ -469,8 +468,6 @@ static void dev_forward_change(struct inet6_dev *id=
ev)
 	if (!idev)
 		return;
 	dev =3D idev->dev;
-	if (idev->cnf.forwarding)
-		dev_disable_lro(dev);
 	if (dev && (dev->flags & IFF_MULTICAST)) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
@@ -486,6 +483,8 @@ static void dev_forward_change(struct inet6_dev *id=
ev)
 		else
 			addrconf_leave_anycast(ifa);
 	}
+
+	netdev_update_features(dev);
 }
=20
=20
--=20
1.7.2.5

