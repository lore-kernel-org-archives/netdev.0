From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipv6: generate link local address for GRE tunnel
Date: Wed, 8 Jun 2011 13:44:30 -0700
Message-ID: <20110608134430.112c2591@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34882 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab1FHUof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 16:44:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use same logic as SIT tunnel to handle link local address
for GRE tunnel. OSPFv3 requires link-local address to function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2011-05-23 16:56:36.000000000 -0700
+++ b/net/ipv6/addrconf.c	2011-06-08 13:41:36.447300763 -0700
@@ -1559,6 +1559,11 @@ static int addrconf_ifid_sit(u8 *eui, st
 	return -1;
 }
 
+static int addrconf_ifid_gre(u8 *eui, struct net_device *dev)
+{
+	return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1572,6 +1577,8 @@ static int ipv6_generate_eui64(u8 *eui, 
 		return addrconf_ifid_infiniband(eui, dev);
 	case ARPHRD_SIT:
 		return addrconf_ifid_sit(eui, dev);
+	case ARPHRD_IPGRE:
+		return addrconf_ifid_gre(eui, dev);
 	}
 	return -1;
 }
@@ -2423,6 +2430,29 @@ static void addrconf_sit_config(struct n
 }
 #endif
 
+#if defined(CONFIG_NET_IPGRE) || defined(CONFIG_NET_IPGRE_MODULE)
+static void addrconf_gre_config(struct net_device *dev)
+{
+	struct inet6_dev *idev;
+	struct in6_addr addr;
+
+	pr_info("ipv6: addrconf_gre_config(%s)\n", dev->name);
+
+	ASSERT_RTNL();
+
+	if ((idev = ipv6_find_idev(dev)) == NULL) {
+		printk(KERN_DEBUG "init gre: add_dev failed\n");
+		return;
+	}
+
+	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+	addrconf_prefix_route(&addr, 64, dev, 0, 0);
+
+	if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
+		addrconf_add_linklocal(idev, &addr);
+}
+#endif
+
 static inline int
 ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 {
@@ -2539,6 +2569,11 @@ static int addrconf_notify(struct notifi
 			addrconf_sit_config(dev);
 			break;
 #endif
+#if defined(CONFIG_NET_IPGRE) || defined(CONFIG_NET_IPGRE_MODULE)
+		case ARPHRD_IPGRE:
+			addrconf_gre_config(dev);
+			break;
+#endif
 		case ARPHRD_TUNNEL6:
 			addrconf_ip6_tnl_config(dev);
 			break;
