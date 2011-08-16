From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 3/3] net: remove ndo_set_multicast_list callback
Date: Tue, 16 Aug 2011 18:29:02 +0200
Message-ID: <1313512142-3355-4-git-send-email-jpirko@redhat.com>
References: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, kaber@trash.net, yoshfuji@linux-ipv6.org,
	rdunlap@xenotime.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	mirqus@gmail.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296Ab1HPSCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 14:02:10 -0400
In-Reply-To: <1313512142-3355-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove no longer used operation.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 Documentation/networking/netdevices.txt |    4 ++--
 include/linux/netdevice.h               |    4 ----
 net/core/dev.c                          |    6 ++----
 net/core/dev_addr_lists.c               |    4 ++--
 net/ipv4/igmp.c                         |    2 +-
 5 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index 87b3d15..8935834 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -73,7 +73,7 @@ dev->hard_start_xmit:
 	has to lock by itself when needed. It is recommended to use a try lock
 	for this and return NETDEV_TX_LOCKED when the spin lock fails.
 	The locking there should also properly protect against 
-	set_multicast_list. Note that the use of NETIF_F_LLTX is deprecated.
+	set_rx_mode. Note that the use of NETIF_F_LLTX is deprecated.
 	Don't use it for new drivers.
 
 	Context: Process with BHs disabled or BH (timer),
@@ -92,7 +92,7 @@ dev->tx_timeout:
 	Context: BHs disabled
 	Notes: netif_queue_stopped() is guaranteed true
 
-dev->set_multicast_list:
+dev->set_rx_mode:
 	Synchronization: netif_tx_lock spinlock.
 	Context: BHs disabled
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 96e4f7e..125f9fb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -726,9 +726,6 @@ struct netdev_tc_txq {
  *	If driver handles unicast address filtering, it should set
  *	IFF_UNICAST_FLT to its priv_flags.
  *
- * void (*ndo_set_multicast_list)(struct net_device *dev);
- *	This function is called when the multicast address list changes.
- *
  * int (*ndo_set_mac_address)(struct net_device *dev, void *addr);
  *	This function  is called when the Media Access Control address
  *	needs to be changed. If this interface is not defined, the
@@ -870,7 +867,6 @@ struct net_device_ops {
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
 	void			(*ndo_set_rx_mode)(struct net_device *dev);
-	void			(*ndo_set_multicast_list)(struct net_device *dev);
 	int			(*ndo_set_mac_address)(struct net_device *dev,
 						       void *addr);
 	int			(*ndo_validate_addr)(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 018c15c..f667dd3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4504,8 +4504,6 @@ void __dev_set_rx_mode(struct net_device *dev)
 
 	if (ops->ndo_set_rx_mode)
 		ops->ndo_set_rx_mode(dev);
-	else if (ops->ndo_set_multicast_list)
-		ops->ndo_set_multicast_list(dev);
 }
 
 void dev_set_rx_mode(struct net_device *dev)
@@ -4855,7 +4853,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		return -EOPNOTSUPP;
 
 	case SIOCADDMULTI:
-		if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
+		if (!ops->ndo_set_rx_mode ||
 		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 			return -EINVAL;
 		if (!netif_device_present(dev))
@@ -4863,7 +4861,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		return dev_mc_add_global(dev, ifr->ifr_hwaddr.sa_data);
 
 	case SIOCDELMULTI:
-		if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
+		if (!ops->ndo_set_rx_mode ||
 		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 			return -EINVAL;
 		if (!netif_device_present(dev))
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index e2e6693..283d1b8 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -591,8 +591,8 @@ EXPORT_SYMBOL(dev_mc_del_global);
  *	addresses that have no users left. The source device must be
  *	locked by netif_tx_lock_bh.
  *
- *	This function is intended to be called from the dev->set_multicast_list
- *	or dev->set_rx_mode function of layered software devices.
+ *	This function is intended to be called from the ndo_set_rx_mode
+ *	function of layered software devices.
  */
 int dev_mc_sync(struct net_device *to, struct net_device *from)
 {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7069522..ce57bde 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1009,7 +1009,7 @@ static void ip_mc_filter_add(struct in_device *in_dev, __be32 addr)
 
 	/* Checking for IFF_MULTICAST here is WRONG-WRONG-WRONG.
 	   We will get multicast token leakage, when IFF_MULTICAST
-	   is changed. This check should be done in dev->set_multicast_list
+	   is changed. This check should be done in ndo_set_rx_mode
 	   routine. Something sort of:
 	   if (dev->mc_list && dev->flags&IFF_MULTICAST) { do it; }
 	   --ANK
-- 
1.7.6

