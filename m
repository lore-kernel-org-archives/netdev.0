From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sat, 02 Nov 2013 07:01:37 -0700
Message-ID: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, christoph.paasch@uclouvain.be,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34952 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab3KBOBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 10:01:40 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so4985248pdj.13
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 07:01:39 -0700 (PDT)
In-Reply-To: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")

skb_segment() only deals with a frag_list chain containing MSS sized
fragments. Even if we fix this problem, its better if GRO layer
doesn't build skb with a frag_list in the first place, to let TSO
packets reaching output devices.
 
David Miller and Ben Hutchings suggested we keep track of number of
forwarding users to be able to :

- Disable LRO
- Make sure GRO layer do not use skb frag_list to extend skb capacity

Note that after this patch, LRO is automatically re-enabled if
forwarding is disabled on the device, or if a device is removed
from a bridge.

Tested:

lpq84:~# ethtool -k eth0 | grep "large-receive"
large-receive-offload: on
lpq84:~# echo 1 >/proc/sys/net/ipv4/conf/eth0/forwarding
lpq84:~# ethtool -k eth0 | grep "large-receive"
large-receive-offload: off
lpq84:~# echo 0 >/proc/sys/net/ipv4/conf/eth0/forwarding
lpq84:~# ethtool -k eth0 | grep "large-receive"
large-receive-offload: on

lpq84:~# cat /proc/sys/net/ipv4/ip_forward
0
lpq84:~# echo 1 >/proc/sys/net/ipv4/ip_forward
lpq84:~# ethtool -k eth0 | grep "large-receive"
large-receive-offload: off
lpq84:~# echo 0 >/proc/sys/net/ipv4/ip_forward
lpq84:~# ethtool -k eth0 | grep "large-receive"
large-receive-offload: on


Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Reported-by: Jerry Chu <hkchu@google.com>
Cc: Michael Dalton <mwdalton@google.com>
Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
---
 include/linux/netdevice.h |    3 ++-
 net/bridge/br_if.c        |    4 +++-
 net/core/dev.c            |   30 +++++++++++++++++++-----------
 net/core/skbuff.c         |   11 ++++++++---
 net/ipv4/devinet.c        |   14 ++++++++------
 net/ipv6/addrconf.c       |    5 ++---
 net/ipv6/addrconf_core.c  |    2 ++
 7 files changed, 44 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb1d918ecdf1..6ddd0fa85ae2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1295,6 +1295,7 @@ struct net_device {
 
 	struct netdev_queue __rcu *ingress_queue;
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
+	unsigned int		forwarding_count;
 
 
 /*
@@ -1787,7 +1788,7 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name);
 int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
-void dev_disable_lro(struct net_device *dev);
+void dev_set_forwarding(struct net_device *dev, int inc);
 int dev_loopback_xmit(struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
 int register_netdevice(struct net_device *dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c41d5fbb91d0..959164374ce8 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -150,6 +150,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	netdev_rx_handler_unregister(dev);
 
+	dev_set_forwarding(dev, -1);
+
 	netdev_upper_dev_unlink(dev, br->dev);
 
 	br_multicast_del_port(p);
@@ -377,7 +379,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
-	dev_disable_lro(dev);
+	dev_set_forwarding(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 0054c8c75f50..d1276ea6baf7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1408,29 +1408,37 @@ EXPORT_SYMBOL(dev_close);
 
 
 /**
- *	dev_disable_lro - disable Large Receive Offload on a device
- *	@dev: device
- *
- *	Disable Large Receive Offload (LRO) on a net device.  Must be
- *	called under RTNL.  This is needed if received packets may be
- *	forwarded to another interface.
+ * dev_set_forwarding - Keep count of forwarding users for a device
+ * @dev: device
+ * @inc: +1 or -1
+ *
+ * Add or remove forwarding from a device.
+ * When the count of forwarding users is above 0 :
+ * 1) disable LRO (Large Receive Offload) on this device.
+ * 2) instruct GRO layer to not use frag_list to extend skb capacity.
+ * Must be called under RTNL.
+ * This is needed if received packets may be forwarded to another interface.
  */
-void dev_disable_lro(struct net_device *dev)
+void dev_set_forwarding(struct net_device *dev, int inc)
 {
 	/*
-	 * If we're trying to disable lro on a vlan device
+	 * If we're trying to enable forwarding from a vlan device
 	 * use the underlying physical device instead
 	 */
 	if (is_vlan_dev(dev))
 		dev = vlan_dev_real_dev(dev);
 
-	dev->wanted_features &= ~NETIF_F_LRO;
+	dev->forwarding_count += inc;
+	if (dev->forwarding_count)
+		dev->wanted_features &= ~NETIF_F_LRO;
+	else
+		dev->wanted_features |= NETIF_F_LRO;
 	netdev_update_features(dev);
 
-	if (unlikely(dev->features & NETIF_F_LRO))
+	if (unlikely(dev->forwarding_count && (dev->features & NETIF_F_LRO)))
 		netdev_WARN(dev, "failed to disable LRO!\n");
 }
-EXPORT_SYMBOL(dev_disable_lro);
+EXPORT_SYMBOL(dev_set_forwarding);
 
 static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
 				   struct net_device *dev)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0ab32faa520f..7b1cff884d50 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2944,9 +2944,11 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		int i = skbinfo->nr_frags;
 		int nr_frags = pinfo->nr_frags + i;
 
-		if (nr_frags > MAX_SKB_FRAGS)
+		if (nr_frags > MAX_SKB_FRAGS) {
+			if (skb->dev->forwarding_count)
+				return -E2BIG;
 			goto merge;
-
+		}
 		offset -= headlen;
 		pinfo->nr_frags = nr_frags;
 		skbinfo->nr_frags = 0;
@@ -2977,8 +2979,11 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		unsigned int first_size = headlen - offset;
 		unsigned int first_offset;
 
-		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS)
+		if (nr_frags + 1 + skbinfo->nr_frags > MAX_SKB_FRAGS) {
+			if (skb->dev->forwarding_count)
+				return -E2BIG;
 			goto merge;
+		}
 
 		first_offset = skb->data -
 			       (unsigned char *)page_address(page) +
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcbd04ae..cf01e6fb77c5 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -223,6 +223,8 @@ void in_dev_finish_destroy(struct in_device *idev)
 #ifdef NET_REFCNT_DEBUG
 	pr_debug("%s: %p=%s\n", __func__, idev, dev ? dev->name : "NIL");
 #endif
+	if (IPV4_DEVCONF(idev->cnf, FORWARDING))
+		dev_set_forwarding(dev, -1);
 	dev_put(dev);
 	if (!idev->dead)
 		pr_err("Freeing alive in_device %p\n", idev);
@@ -248,7 +250,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	if (!in_dev->arp_parms)
 		goto out_kfree;
 	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
-		dev_disable_lro(dev);
+		dev_set_forwarding(dev, 1);
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 	/* Account for reference dev->ip_ptr (below) */
@@ -1932,8 +1934,8 @@ static void inet_forward_change(struct net *net)
 
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
-		if (on)
-			dev_disable_lro(dev);
+
+		dev_set_forwarding(dev, on ? 1 : -1);
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev) {
@@ -1997,7 +1999,7 @@ static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 	loff_t pos = *ppos;
 	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
-	if (write && *valp != val) {
+	if (write && (!(*valp) != !val)) {
 		struct net *net = ctl->extra2;
 
 		if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING)) {
@@ -2013,8 +2015,8 @@ static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 				struct ipv4_devconf *cnf = ctl->extra1;
 				struct in_device *idev =
 					container_of(cnf, struct in_device, cnf);
-				if (*valp)
-					dev_disable_lro(idev->dev);
+
+				dev_set_forwarding(idev->dev, *valp ? 1 : -1);
 				inet_netconf_notify_devconf(net,
 							    NETCONFA_FORWARDING,
 							    idev->dev->ifindex,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 542d09561ed6..5b8406c6c868 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -322,7 +322,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		return NULL;
 	}
 	if (ndev->cnf.forwarding)
-		dev_disable_lro(dev);
+		dev_set_forwarding(dev, 1);
 	/* We refer to the device */
 	dev_hold(dev);
 
@@ -638,8 +638,7 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (!idev)
 		return;
 	dev = idev->dev;
-	if (idev->cnf.forwarding)
-		dev_disable_lro(dev);
+	dev_set_forwarding(dev, idev->cnf.forwarding ? 1 : -1);
 	if (dev->flags & IFF_MULTICAST) {
 		if (idev->cnf.forwarding) {
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 4c11cbcf8308..b7620ad8366f 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -139,6 +139,8 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 #ifdef NET_REFCNT_DEBUG
 	pr_debug("%s: %s\n", __func__, dev ? dev->name : "NIL");
 #endif
+	if (idev->cnf.forwarding)
+		dev_set_forwarding(dev, -1);
 	dev_put(dev);
 	if (!idev->dead) {
 		pr_warn("Freeing alive inet6 device %p\n", idev);
