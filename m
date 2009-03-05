From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 23:19:11 -0800 (PST)
Message-ID: <20090304.231911.213286076.davem@davemloft.net>
References: <49AF79A6.6030002@trash.net>
	<20090304.231120.86999183.davem@davemloft.net>
	<49AF7B72.2020905@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750711AbZCEHT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:19:26 -0500
In-Reply-To: <49AF7B72.2020905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 08:12:50 +0100

> David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Thu, 05 Mar 2009 08:05:10 +0100
> > 
> >> David Miller wrote:
> >>> I think this will fix it.
> >> Good catch, that looks like a likely cause. Will test in a minute ...
> > We probably need both fixes to cover everything.
> > 
> 
> Yes, just the second one still crashes. I'm about to retry using both.

Here is the updated version just for the record:

vlan: Fix vlan-in-vlan crashes.

As analyzed by Patrick McHardy, vlan needs to reset it's
netdev_ops pointer in it's ->init() function but this
leaves the compat method pointers stale.

Add a netdev_resync_ops() and call it from the vlan code.

Any other driver which changes ->netdev_ops after register_netdevice()
will need to call this new function after doing so too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 +
 net/8021q/vlan_dev.c      |    1 +
 net/core/dev.c            |   56 +++++++++++++++++++++++++++-----------------
 3 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec54785..6593667 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1079,6 +1079,7 @@ extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
 extern int		init_dummy_netdev(struct net_device *dev);
+extern void		netdev_resync_ops(struct net_device *dev);
 
 extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4a19acd..b6e1f9e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -639,6 +639,7 @@ static int vlan_dev_init(struct net_device *dev)
 		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
 		dev->netdev_ops         = &vlan_netdev_ops;
 	}
+	netdev_resync_ops(dev);
 
 	if (is_vlan_dev(real_dev))
 		subclass = 1;
diff --git a/net/core/dev.c b/net/core/dev.c
index 2dd484e..f112970 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4282,6 +4282,39 @@ unsigned long netdev_fix_features(unsigned long features, const char *name)
 }
 EXPORT_SYMBOL(netdev_fix_features);
 
+/* Some devices need to (re-)set their netdev_ops inside
+ * ->init() or similar.  If that happens, we have to setup
+ * the compat pointers again.
+ */
+void netdev_resync_ops(struct net_device *dev)
+{
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	dev->init = ops->ndo_init;
+	dev->uninit = ops->ndo_uninit;
+	dev->open = ops->ndo_open;
+	dev->change_rx_flags = ops->ndo_change_rx_flags;
+	dev->set_rx_mode = ops->ndo_set_rx_mode;
+	dev->set_multicast_list = ops->ndo_set_multicast_list;
+	dev->set_mac_address = ops->ndo_set_mac_address;
+	dev->validate_addr = ops->ndo_validate_addr;
+	dev->do_ioctl = ops->ndo_do_ioctl;
+	dev->set_config = ops->ndo_set_config;
+	dev->change_mtu = ops->ndo_change_mtu;
+	dev->neigh_setup = ops->ndo_neigh_setup;
+	dev->tx_timeout = ops->ndo_tx_timeout;
+	dev->get_stats = ops->ndo_get_stats;
+	dev->vlan_rx_register = ops->ndo_vlan_rx_register;
+	dev->vlan_rx_add_vid = ops->ndo_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid = ops->ndo_vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ops->ndo_poll_controller;
+#endif
+#endif
+}
+EXPORT_SYMBOL(netdev_resync_ops);
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -4326,28 +4359,7 @@ int register_netdevice(struct net_device *dev)
 	 * This is temporary until all network devices are converted.
 	 */
 	if (dev->netdev_ops) {
-		const struct net_device_ops *ops = dev->netdev_ops;
-
-		dev->init = ops->ndo_init;
-		dev->uninit = ops->ndo_uninit;
-		dev->open = ops->ndo_open;
-		dev->change_rx_flags = ops->ndo_change_rx_flags;
-		dev->set_rx_mode = ops->ndo_set_rx_mode;
-		dev->set_multicast_list = ops->ndo_set_multicast_list;
-		dev->set_mac_address = ops->ndo_set_mac_address;
-		dev->validate_addr = ops->ndo_validate_addr;
-		dev->do_ioctl = ops->ndo_do_ioctl;
-		dev->set_config = ops->ndo_set_config;
-		dev->change_mtu = ops->ndo_change_mtu;
-		dev->neigh_setup = ops->ndo_neigh_setup;
-		dev->tx_timeout = ops->ndo_tx_timeout;
-		dev->get_stats = ops->ndo_get_stats;
-		dev->vlan_rx_register = ops->ndo_vlan_rx_register;
-		dev->vlan_rx_add_vid = ops->ndo_vlan_rx_add_vid;
-		dev->vlan_rx_kill_vid = ops->ndo_vlan_rx_kill_vid;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-		dev->poll_controller = ops->ndo_poll_controller;
-#endif
+		netdev_resync_ops(dev);
 	} else {
 		char drivername[64];
 		pr_info("%s (%s): not using net_device_ops yet\n",
-- 
1.6.2

