From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] Disable forwarding of LRO skbs
Date: Wed, 30 Apr 2008 22:54:18 +0100
Message-ID: <20080430215417.GE14219@solarflare.com>
References: <20080430214845.GC14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:36658 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757068AbYD3VyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:54:24 -0400
Content-Disposition: inline
In-Reply-To: <20080430214845.GC14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dev_disable_lro() function.

Change br_add_if() and all functions that enable IPv4 and IPv6 forwarding
to call dev_disable_lro() on the affected devices.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7c1d446..d7e8f1f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -866,6 +866,7 @@ extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
+extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index e1df1ab..62cca32 100644
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
@@ -1108,6 +1109,29 @@ int dev_close(struct net_device *dev)
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
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 298e0f4..1bd6631 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -387,6 +387,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
+	dev_disable_lro(dev);
 	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 6848e47..f88d395 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -171,6 +171,8 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	in_dev->dev = dev;
 	if ((in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl)) == NULL)
 		goto out_kfree;
+	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
+		dev_disable_lro(dev);
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
@@ -1250,6 +1252,8 @@ static void inet_forward_change(struct net *net)
 	read_lock(&dev_base_lock);
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
+		if (on)
+			dev_disable_lro(dev);
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev)
@@ -1257,8 +1261,6 @@ static void inet_forward_change(struct net *net)
 		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
-
-	rt_cache_flush(0);
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
@@ -1344,10 +1346,19 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
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
index 8a0fd40..5be6874 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -344,6 +344,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 		kfree(ndev);
 		return NULL;
 	}
+	if (ndev->cnf.forwarding)
+		dev_disable_lro(dev);
 	/* We refer to the device */
 	dev_hold(dev);
 
@@ -438,6 +440,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (!idev)
 		return;
 	dev = idev->dev;
+	if (idev->cnf.forwarding)
+		dev_disable_lro(dev);
 	if (dev && (dev->flags & IFF_MULTICAST)) {
 		if (idev->cnf.forwarding)
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
@@ -483,12 +487,14 @@ static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
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
