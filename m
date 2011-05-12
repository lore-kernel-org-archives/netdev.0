From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH v2] net: fold dev_disable_lro() into netdev_fix_features()
Date: Thu, 12 May 2011 18:06:40 +0200 (CEST)
Message-ID: <20110512160640.2A0B713A6B@rere.qmqm.pl>
References: <20110507114803.0D80A13A6B@rere.qmqm.pl>
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
Received: from rere.qmqm.pl ([89.167.52.164]:49460 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757918Ab1ELQGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:06:41 -0400
In-Reply-To: <20110507114803.0D80A13A6B@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements checks for forwarding mode in netdev_fix_features() usi=
ng
dev->priv_flags bits. As a side effect, after device is no longer
forwarding it gets LRO back. This also means that user is not allowed t=
o
enable LRO after device is put to forwarding mode.

This patch depends on removal of discrete offload setting ethtool ops.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
v2: remove protocol-specific checks from core code

 include/linux/if.h        |    5 +++++
 include/linux/netdevice.h |    1 -
 net/bridge/br_if.c        |    6 +++---
 net/core/dev.c            |   25 +++++--------------------
 net/ipv4/devinet.c        |   30 +++++++++++++++++++-----------
 net/ipv6/addrconf.c       |   17 +++++++++++++----
 6 files changed, 45 insertions(+), 39 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 3bc63e6..1aef6a7 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -76,6 +76,11 @@
 #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
 #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
 					 * datapath port */
+#define IFF_FORWARDING_IPV4	0x10000	/* IPv4 router port */
+#define IFF_FORWARDING_IPV6	0x20000	/* IPv6 router port */
+
+#define IFF_LRO_FORBIDDEN (IFF_BRIDGE_PORT | \
+		IFF_FORWARDING_IPV4 | IFF_FORWARDING_IPV6)
=20
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 41972b9..f698730 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1628,7 +1628,6 @@ extern struct net_device	*__dev_get_by_name(struc=
t net *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
-extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice_queue(struct net_device *dev,
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 5dbdfdf..568a9dd 100644
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
+	netdev_change_features(dev);
=20
 	spin_lock_bh(&br->lock);
 	changed_addr =3D br_stp_recalculate_bridge_id(br);
diff --git a/net/core/dev.c b/net/core/dev.c
index 491b8eb..b70b6c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1296,26 +1296,6 @@ int dev_close(struct net_device *dev)
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
@@ -5241,6 +5221,11 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 		}
 	}
=20
+	if (features & NETIF_F_LRO && dev->priv_flags & IFF_LRO_FORBIDDEN) {
+		netdev_info(dev, "Disabling LRO for forwarding interface.\n");
+		features &=3D NETIF_F_LRO;
+	}
+
 	return features;
 }
 EXPORT_SYMBOL(netdev_fix_features);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0d4a184..9552c68 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -221,6 +221,7 @@ void in_dev_finish_destroy(struct in_device *idev)
 	printk(KERN_DEBUG "in_dev_finish_destroy: %p=3D%s\n",
 	       idev, dev ? dev->name : "NIL");
 #endif
+	dev->priv_flags &=3D ~IFF_FORWARDING_IPV4;
 	dev_put(dev);
 	if (!idev->dead)
 		pr_err("Freeing alive in_device %p\n", idev);
@@ -229,6 +230,16 @@ void in_dev_finish_destroy(struct in_device *idev)
 }
 EXPORT_SYMBOL(in_dev_finish_destroy);
=20
+static void mark_ipv4_forwarding(struct net_device *dev, bool on)
+{
+	if (on)
+		dev->priv_flags |=3D IFF_FORWARDING_IPV4;
+	else
+		dev->priv_flags &=3D ~IFF_FORWARDING_IPV4;
+
+	netdev_update_features(dev);
+}
+
 static struct in_device *inetdev_init(struct net_device *dev)
 {
 	struct in_device *in_dev;
@@ -245,8 +256,7 @@ static struct in_device *inetdev_init(struct net_de=
vice *dev)
 	in_dev->arp_parms =3D neigh_parms_alloc(dev, &arp_tbl);
 	if (!in_dev->arp_parms)
 		goto out_kfree;
-	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
-		dev_disable_lro(dev);
+	mark_ipv4_forwarding(dev, IPV4_DEVCONF(in_dev->cnf, FORWARDING));
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
@@ -1475,14 +1485,12 @@ static void inet_forward_change(struct net *net=
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
+			mark_ipv4_forwarding(in_dev->dev, on);
+		}
 	}
 }
=20
@@ -1527,11 +1535,11 @@ static int devinet_sysctl_forward(ctl_table *ct=
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
+				mark_ipv4_forwarding(idev->dev, *valp);
 			}
 			rtnl_unlock();
 			rt_cache_flush(net, 0);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2f9b2e..7e0e8fa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -333,6 +333,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 #ifdef NET_REFCNT_DEBUG
 	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name : "=
NIL");
 #endif
+	dev->priv_flags &=3D ~IFF_FORWARDING_IPV6;
 	dev_put(dev);
 	if (!idev->dead) {
 		pr_warning("Freeing alive inet6 device %p\n", idev);
@@ -344,6 +345,16 @@ void in6_dev_finish_destroy(struct inet6_dev *idev=
)
=20
 EXPORT_SYMBOL(in6_dev_finish_destroy);
=20
+static void mark_ipv6_forwarding(struct net_device *dev, bool on)
+{
+	if (on)
+		dev->priv_flags |=3D IFF_FORWARDING_IPV6;
+	else
+		dev->priv_flags &=3D ~IFF_FORWARDING_IPV6;
+
+	netdev_update_features(dev);
+}
+
 static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 {
 	struct inet6_dev *ndev;
@@ -370,8 +381,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_d=
evice *dev)
 		kfree(ndev);
 		return NULL;
 	}
-	if (ndev->cnf.forwarding)
-		dev_disable_lro(dev);
+	mark_ipv6_forwarding(dev, ndev->cnf.forwarding);
 	/* We refer to the device */
 	dev_hold(dev);
=20
@@ -469,8 +479,7 @@ static void dev_forward_change(struct inet6_dev *id=
ev)
 	if (!idev)
 		return;
 	dev =3D idev->dev;
-	if (idev->cnf.forwarding)
-		dev_disable_lro(dev);
+	mark_ipv6_forwarding(dev, idev->cnf.forwarding);
 	if (dev && (dev->flags & IFF_MULTICAST)) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
--=20
1.7.2.5

