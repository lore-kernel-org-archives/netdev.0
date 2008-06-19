From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] net: Disable LRO on devices that are forwarding
Date: Thu, 19 Jun 2008 19:07:36 +0100
Message-ID: <20080619180735.GT5350@solarflare.com>
References: <cover.1213898165.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:58663 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752376AbYFSSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:07:39 -0400
Content-Disposition: inline
In-Reply-To: <cover.1213898165.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large Receive Offload (LRO) is only appropriate for packets that are
destined for the host, and should be disabled if received packets may be
forwarded.  It can also confuse the GSO on output.

Add dev_disable_lro() function which uses the appropriate ethtool ops to
disable LRO if enabled.

Add calls to dev_disable_lro() in br_add_if() and functions that enable
IPv4 and IPv6 forwarding.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    1 +
 net/bridge/br_if.c        |    1 +
 net/core/dev.c            |   24 ++++++++++++++++++++++++
 net/ipv4/devinet.c        |   21 ++++++++++++++++-----
 net/ipv6/addrconf.c       |    6 ++++++
 5 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 45dce2b..1304ad2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -886,6 +886,7 @@ extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
+extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 143c954..832a561 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -387,6 +387,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
+	dev_disable_lro(dev);
 	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
diff --git a/net/core/dev.c b/net/core/dev.c
index a495f71..f6944ec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -90,6 +90,7 @@
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
 #include <net/net_namespace.h>
@@ -1123,6 +1124,29 @@ int dev_close(struct net_device *dev)
 }
 
 
+/**
+ *	dev_disable_lro - disable Large Receive Offload on a device
+ *	@dev: device
+ *
+ *	Disable Large Receive Offload (LRO) on a net device.  Must be
+ *	called under RTNL.  This is needed if received packets may be
+ *	forwarded to another interface.
+ */
+void dev_disable_lro(struct net_device *dev)
+{
+	if (dev->ethtool_ops && dev->ethtool_ops->get_flags &&
+	    dev->ethtool_ops->set_flags) {
+		u32 flags = dev->ethtool_ops->get_flags(dev);
+		if (flags & ETH_FLAG_LRO) {
+			flags &= ~ETH_FLAG_LRO;
+			dev->ethtool_ops->set_flags(dev, flags);
+		}
+	}
+	WARN_ON(dev->features & NETIF_F_LRO);
+}
+EXPORT_SYMBOL(dev_disable_lro);
+
+
 static int dev_boot_phase = 1;
 
 /*
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f8c0b0a..9de2514 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -168,6 +168,8 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	in_dev->dev = dev;
 	if ((in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl)) == NULL)
 		goto out_kfree;
+	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
+		dev_disable_lro(dev);
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
@@ -1241,6 +1243,8 @@ static void inet_forward_change(struct net *net)
 	read_lock(&dev_base_lock);
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
+		if (on)
+			dev_disable_lro(dev);
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev)
@@ -1248,8 +1252,6 @@ static void inet_forward_change(struct net *net)
 		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
-
-	rt_cache_flush(0);
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
@@ -1335,10 +1337,19 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 	if (write && *valp != val) {
 		struct net *net = ctl->extra2;
 
-		if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING))
-			inet_forward_change(net);
-		else if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING))
+		if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING)) {
+			rtnl_lock();
+			if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING)) {
+				inet_forward_change(net);
+			} else if (*valp) {
+				struct ipv4_devconf *cnf = ctl->extra1;
+				struct in_device *idev =
+					container_of(cnf, struct in_device, cnf);
+				dev_disable_lro(idev->dev);
+			}
+			rtnl_unlock();
 			rt_cache_flush(0);
+		}
 	}
 
 	return ret;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9be6be3..84127d8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -348,6 +348,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 		kfree(ndev);
 		return NULL;
 	}
+	if (ndev->cnf.forwarding)
+		dev_disable_lro(dev);
 	/* We refer to the device */
 	dev_hold(dev);
 
@@ -442,6 +444,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (!idev)
 		return;
 	dev = idev->dev;
+	if (idev->cnf.forwarding)
+		dev_disable_lro(dev);
 	if (dev && (dev->flags & IFF_MULTICAST)) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
@@ -487,12 +491,14 @@ static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 	if (p == &net->ipv6.devconf_dflt->forwarding)
 		return;
 
+	rtnl_lock();
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		__s32 newf = net->ipv6.devconf_all->forwarding;
 		net->ipv6.devconf_dflt->forwarding = newf;
 		addrconf_forward_change(net, newf);
 	} else if ((!*p) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
+	rtnl_unlock();
 
 	if (*p)
 		rt6_purge_dflt_routers(net);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
