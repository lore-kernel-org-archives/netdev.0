From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/33] netdev: expose ethernet address primitives
Date: Mon, 17 Nov 2008 15:42:10 -0800
Message-ID: <20081117234355.032625967@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55040 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbYKQX75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 18:59:57 -0500
Content-Disposition: inline; filename=eth-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ethernet devices are converted, the function pointer setup
by eth_setup() need to be done during intialization.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/etherdevice.h |    4 ++++
 net/ethernet/eth.c          |   13 ++++++++-----
 2 files changed, 12 insertions(+), 5 deletions(-)

--- a/include/linux/etherdevice.h	2008-11-17 14:53:08.000000000 -0800
+++ b/include/linux/etherdevice.h	2008-11-17 15:06:23.000000000 -0800
@@ -41,6 +41,10 @@ extern int eth_header_cache(const struct
 extern void eth_header_cache_update(struct hh_cache *hh,
 				    const struct net_device *dev,
 				    const unsigned char *haddr);
+extern int eth_mac_addr(struct net_device *dev, void *p);
+extern int eth_change_mtu(struct net_device *dev, int new_mtu);
+extern int eth_validate_addr(struct net_device *dev);
+
 
 
 extern struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count);
--- a/net/ethernet/eth.c	2008-11-17 14:53:08.000000000 -0800
+++ b/net/ethernet/eth.c	2008-11-17 15:06:23.000000000 -0800
@@ -282,7 +282,7 @@ EXPORT_SYMBOL(eth_header_cache_update);
  * This doesn't change hardware matching, so needs to be overridden
  * for most real devices.
  */
-static int eth_mac_addr(struct net_device *dev, void *p)
+int eth_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
@@ -293,6 +293,7 @@ static int eth_mac_addr(struct net_devic
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	return 0;
 }
+EXPORT_SYMBOL(eth_mac_addr);
 
 /**
  * eth_change_mtu - set new MTU size
@@ -302,21 +303,23 @@ static int eth_mac_addr(struct net_devic
  * Allow changing MTU size. Needs to be overridden for devices
  * supporting jumbo frames.
  */
-static int eth_change_mtu(struct net_device *dev, int new_mtu)
+int eth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu < 68 || new_mtu > ETH_DATA_LEN)
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
+EXPORT_SYMBOL(eth_change_mtu);
 
-static int eth_validate_addr(struct net_device *dev)
+int eth_validate_addr(struct net_device *dev)
 {
 	if (!is_valid_ether_addr(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
 	return 0;
 }
+EXPORT_SYMBOL(eth_validate_addr);
 
 const struct header_ops eth_header_ops ____cacheline_aligned = {
 	.create		= eth_header,
@@ -334,11 +337,11 @@ const struct header_ops eth_header_ops _
 void ether_setup(struct net_device *dev)
 {
 	dev->header_ops		= &eth_header_ops;
-
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	dev->change_mtu		= eth_change_mtu;
 	dev->set_mac_address 	= eth_mac_addr;
 	dev->validate_addr	= eth_validate_addr;
-
+#endif
 	dev->type		= ARPHRD_ETHER;
 	dev->hard_header_len 	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;

-- 

