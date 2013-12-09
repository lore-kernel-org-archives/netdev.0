From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [patch net-next] ipv6: log autoconfiguration failures
Date: Mon,  9 Dec 2013 17:26:48 +0100
Message-ID: <1386606408-21552-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, davem@davemloft.net,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, jpirko@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If ipv6 auto-configuration does not work, currently it's hard
to track what's going on. This change adds log messages
(at debug level) on every code path where ipv6 autoconf fails.

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
---
 net/ipv6/addrconf.c | 45 ++++++++++++++++++++++++++++++++++++---------
 1 file changed, 36 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5087cc5..e75428f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1692,8 +1692,11 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 
 static int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 {
-	if (dev->addr_len != ETH_ALEN)
+	if (dev->addr_len != ETH_ALEN) {
+		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
+				dev->name, dev->addr_len, "ETH_ALEN");
 		return -1;
+	}
 	memcpy(eui, dev->dev_addr, 3);
 	memcpy(eui + 5, dev->dev_addr + 3, 3);
 
@@ -1723,8 +1726,11 @@ static int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 
 static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 {
-	if (dev->addr_len != IEEE802154_ADDR_LEN)
+	if (dev->addr_len != IEEE802154_ADDR_LEN) {
+		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
+			dev->name, dev->addr_len, "IEEE802154_ADDR_LEN");
 		return -1;
+	}
 	memcpy(eui, dev->dev_addr, 8);
 	eui[0] ^= 2;
 	return 0;
@@ -1734,8 +1740,11 @@ static int addrconf_ifid_ieee1394(u8 *eui, struct net_device *dev)
 {
 	union fwnet_hwaddr *ha;
 
-	if (dev->addr_len != FWNET_ALEN)
+	if (dev->addr_len != FWNET_ALEN) {
+		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
+			dev->name, dev->addr_len, "FWNET_ALEN");
 		return -1;
+	}
 
 	ha = (union fwnet_hwaddr *)dev->dev_addr;
 
@@ -1747,8 +1756,11 @@ static int addrconf_ifid_ieee1394(u8 *eui, struct net_device *dev)
 static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 {
 	/* XXX: inherit EUI-64 from other interface -- yoshfuji */
-	if (dev->addr_len != ARCNET_ALEN)
+	if (dev->addr_len != ARCNET_ALEN) {
+		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
+			dev->name, dev->addr_len, "ARCNET_ALEN");
 		return -1;
+	}
 	memset(eui, 0, 7);
 	eui[7] = *(u8 *)dev->dev_addr;
 	return 0;
@@ -1756,17 +1768,25 @@ static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 
 static int addrconf_ifid_infiniband(u8 *eui, struct net_device *dev)
 {
-	if (dev->addr_len != INFINIBAND_ALEN)
+	if (dev->addr_len != INFINIBAND_ALEN) {
+		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
+			dev->name, dev->addr_len, "INFINIBAND_ALEN");
 		return -1;
+	}
 	memcpy(eui, dev->dev_addr + 12, 8);
 	eui[0] |= 2;
 	return 0;
 }
 
-static int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
+static int __ipv6_isatap_ifid(u8 *eui, struct net_device *dev)
 {
-	if (addr == 0)
+	__be32 addr = *(__be32 *)dev->dev_addr;
+
+	if (addr == 0) {
+		pr_debug("IPv6 addrconf: %s: bad dev_addr %pM\n",
+				dev->name, dev->dev_addr);
 		return -1;
+	}
 	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
 		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
 		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
@@ -1783,13 +1803,14 @@ static int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 static int addrconf_ifid_sit(u8 *eui, struct net_device *dev)
 {
 	if (dev->priv_flags & IFF_ISATAP)
-		return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
+		return __ipv6_isatap_ifid(eui, dev);
+	pr_debug("IPv6 addrconf: %s: IFF_ISATAP is unset\n", dev->name);
 	return -1;
 }
 
 static int addrconf_ifid_gre(u8 *eui, struct net_device *dev)
 {
-	return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
+	return __ipv6_isatap_ifid(eui, dev);
 }
 
 static int addrconf_ifid_ip6tnl(u8 *eui, struct net_device *dev)
@@ -1823,6 +1844,8 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_TUNNEL6:
 		return addrconf_ifid_ip6tnl(eui, dev);
 	}
+	pr_debug("IPv6 addrconf: %s: dev->type %d is not supported\n",
+			dev->name, dev->type);
 	return -1;
 }
 
@@ -1840,6 +1863,10 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 		}
 	}
 	read_unlock_bh(&idev->lock);
+	if (err)
+		pr_debug("IPv6 addrconf: "
+			"%s: no link-local address to inherit\n",
+			idev->dev->name);
 	return err;
 }
 
-- 
1.8.1.4
