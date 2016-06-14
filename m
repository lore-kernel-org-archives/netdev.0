From: Alexander Aring <aar@pengutronix.de>
Subject: [PATCHv3 net-next 02/12] 6lowpan: add 802.15.4 short addr slaac
Date: Tue, 14 Jun 2016 13:52:29 +0200
Message-ID: <20160614115239.17788-3-aar@pengutronix.de>
References: <20160614115239.17788-1-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58255 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752004AbcFNLxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 07:53:17 -0400
In-Reply-To: <20160614115239.17788-1-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the autoconfiguration if a valid 802.15.4 short address
is available for 802.15.4 6LoWPAN interfaces.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 include/net/6lowpan.h  |  6 ++++++
 include/net/addrconf.h |  3 +++
 net/6lowpan/core.c     | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c    |  5 +++--
 4 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
index 2d9b9d3..5ab4c99 100644
--- a/include/net/6lowpan.h
+++ b/include/net/6lowpan.h
@@ -254,6 +254,12 @@ static inline bool lowpan_fetch_skb(struct sk_buff *skb, void *data,
 	return false;
 }
 
+static inline bool lowpan_802154_is_valid_src_short_addr(__le16 addr)
+{
+	/* First bit of addr is multicast, reserved or 802.15.4 specific */
+	return !(addr & cpu_to_le16(0x8000));
+}
+
 static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
 				       const size_t len)
 {
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 730d856..b1774eb 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -94,6 +94,9 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 
+void addrconf_add_linklocal(struct inet6_dev *idev,
+			    const struct in6_addr *addr, u32 flags);
+
 static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != ETH_ALEN)
diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index 7a240b3..801404c 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 
 #include <net/6lowpan.h>
+#include <net/addrconf.h>
 
 #include "6lowpan_i.h"
 
@@ -72,16 +73,61 @@ void lowpan_unregister_netdev(struct net_device *dev)
 }
 EXPORT_SYMBOL(lowpan_unregister_netdev);
 
+static int addrconf_ifid_802154_6lowpan(u8 *eui, struct net_device *dev)
+{
+	struct wpan_dev *wpan_dev = lowpan_802154_dev(dev)->wdev->ieee802154_ptr;
+
+	/* Set short_addr autoconfiguration if short_addr is present only */
+	if (!lowpan_802154_is_valid_src_short_addr(wpan_dev->short_addr))
+		return -1;
+
+	/* For either address format, all zero addresses MUST NOT be used */
+	if (wpan_dev->pan_id == cpu_to_le16(0x0000) &&
+	    wpan_dev->short_addr == cpu_to_le16(0x0000))
+		return -1;
+
+	/* Alternatively, if no PAN ID is known, 16 zero bits may be used */
+	if (wpan_dev->pan_id == cpu_to_le16(IEEE802154_PAN_ID_BROADCAST))
+		memset(eui, 0, 2);
+	else
+		ieee802154_le16_to_be16(eui, &wpan_dev->pan_id);
+
+	/* The "Universal/Local" (U/L) bit shall be set to zero */
+	eui[0] &= ~2;
+	eui[2] = 0;
+	eui[3] = 0xFF;
+	eui[4] = 0xFE;
+	eui[5] = 0;
+	ieee802154_le16_to_be16(&eui[6], &wpan_dev->short_addr);
+	return 0;
+}
+
 static int lowpan_event(struct notifier_block *unused,
 			unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct inet6_dev *idev;
+	struct in6_addr addr;
 	int i;
 
 	if (dev->type != ARPHRD_6LOWPAN)
 		return NOTIFY_DONE;
 
+	idev = __in6_dev_get(dev);
+	if (!idev)
+		return NOTIFY_DONE;
+
 	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_CHANGE:
+		/* (802.15.4 6LoWPAN short address slaac handling */
+		if (lowpan_is_ll(dev, LOWPAN_LLTYPE_IEEE802154) &&
+		    addrconf_ifid_802154_6lowpan(addr.s6_addr + 8, dev) == 0) {
+			__ipv6_addr_set_half(&addr.s6_addr32[0],
+					     htonl(0xFE800000), 0);
+			addrconf_add_linklocal(idev, &addr, 0);
+		}
+		break;
 	case NETDEV_DOWN:
 		for (i = 0; i < LOWPAN_IPHC_CTX_TABLE_SIZE; i++)
 			clear_bit(LOWPAN_IPHC_CTX_FLAG_ACTIVE,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a..beaad49 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2947,8 +2947,8 @@ static void init_loopback(struct net_device *dev)
 	}
 }
 
-static void addrconf_add_linklocal(struct inet6_dev *idev,
-				   const struct in6_addr *addr, u32 flags)
+void addrconf_add_linklocal(struct inet6_dev *idev,
+			    const struct in6_addr *addr, u32 flags)
 {
 	struct inet6_ifaddr *ifp;
 	u32 addr_flags = flags | IFA_F_PERMANENT;
@@ -2967,6 +2967,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev,
 		in6_ifa_put(ifp);
 	}
 }
+EXPORT_SYMBOL_GPL(addrconf_add_linklocal);
 
 static bool ipv6_reserved_interfaceid(struct in6_addr address)
 {
-- 
2.8.3
