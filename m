From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ip6_tunnel: ensure to always have a link local address
Date: Tue, 20 Aug 2013 12:16:06 +0200
Message-ID: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48774 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab3HTKQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 06:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an Xin6 tunnel is set up, we check other netdevices to inherit the link-
local address. If none is available, the interface will not have any link-local
address. RFC4862 expects that each interface has a link local address.

Now than this kind of tunnels supports x-netns, it's easy to fall in this case
(by creating the tunnel in a netns where ethernet interfaces stand and then
moving it to a other netns where no ethernet interface is available).

RFC4291, Appendix A suggests two methods: the first is the one currently
implemented, the second is to generate a unique identifier, so that we can
always generate the link-local address. Let's use eth_random_addr() to generate
this interface indentifier.

I remove completly the previous method, hence for the whole life of the
interface, the link-local address remains the same (previously, it depends on
which ethernet interfaces were up when the tunnel interface was set up).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c   | 56 +++++++++++++--------------------------------------
 net/ipv6/ip6_tunnel.c |  4 ++++
 2 files changed, 18 insertions(+), 42 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad12f7c43f25..5125436ca67e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1814,6 +1814,16 @@ static int addrconf_ifid_gre(u8 *eui, struct net_device *dev)
 	return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
 }
 
+static int addrconf_ifid_ip6tnl(u8 *eui, struct net_device *dev)
+{
+	memcpy(eui, dev->perm_addr, 3);
+	memcpy(eui + 5, dev->perm_addr + 3, 3);
+	eui[3] = 0xFF;
+	eui[4] = 0xFE;
+	eui[0] ^= 2;
+	return 0;
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1832,6 +1842,8 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_eui64(eui, dev);
 	case ARPHRD_IEEE1394:
 		return addrconf_ifid_ieee1394(eui, dev);
+	case ARPHRD_TUNNEL6:
+		return addrconf_ifid_ip6tnl(eui, dev);
 	}
 	return -1;
 }
@@ -2709,7 +2721,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_ARCNET) &&
 	    (dev->type != ARPHRD_INFINIBAND) &&
 	    (dev->type != ARPHRD_IEEE802154) &&
-	    (dev->type != ARPHRD_IEEE1394)) {
+	    (dev->type != ARPHRD_IEEE1394) &&
+	    (dev->type != ARPHRD_TUNNEL6)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
@@ -2795,44 +2808,6 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 	return -1;
 }
 
-static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
-{
-	struct net_device *link_dev;
-	struct net *net = dev_net(idev->dev);
-
-	/* first try to inherit the link-local address from the link device */
-	if (idev->dev->iflink &&
-	    (link_dev = __dev_get_by_index(net, idev->dev->iflink))) {
-		if (!ipv6_inherit_linklocal(idev, link_dev))
-			return;
-	}
-	/* then try to inherit it from any device */
-	for_each_netdev(net, link_dev) {
-		if (!ipv6_inherit_linklocal(idev, link_dev))
-			return;
-	}
-	pr_debug("init ip6-ip6: add_linklocal failed\n");
-}
-
-/*
- * Autoconfigure tunnel with a link-local address so routing protocols,
- * DHCPv6, MLD etc. can be run over the virtual link
- */
-
-static void addrconf_ip6_tnl_config(struct net_device *dev)
-{
-	struct inet6_dev *idev;
-
-	ASSERT_RTNL();
-
-	idev = addrconf_add_dev(dev);
-	if (IS_ERR(idev)) {
-		pr_debug("init ip6-ip6: add_dev failed\n");
-		return;
-	}
-	ip6_tnl_add_linklocal(idev);
-}
-
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
@@ -2900,9 +2875,6 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			addrconf_gre_config(dev);
 			break;
 #endif
-		case ARPHRD_TUNNEL6:
-			addrconf_ip6_tnl_config(dev);
-			break;
 		case ARPHRD_LOOPBACK:
 			init_loopback(dev);
 			break;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cc3bb201b8b0..d6e00a39274c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -41,6 +41,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/slab.h>
 #include <linux/hash.h>
+#include <linux/etherdevice.h>
 
 #include <asm/uaccess.h>
 #include <linux/atomic.h>
@@ -1471,6 +1472,9 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	/* This perm addr will be used as interface identifier by IPv6 */
+	dev->addr_assign_type = NET_ADDR_RANDOM;
+	eth_random_addr(dev->perm_addr);
 }
 
 
-- 
1.8.2.1
