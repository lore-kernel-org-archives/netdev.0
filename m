From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH bluetooth-next 02/10] 6lowpan: add 802.15.4 short addr slaac
Date: Mon, 18 Apr 2016 12:58:20 +0200
Message-ID: <1460977108-4675-3-git-send-email-aar@pengutronix.de>
References: <1460977108-4675-1-git-send-email-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460977108-4675-1-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the autoconfiguration if a valid 802.15.4 short address
is available for 802.15.4 6LoWPAN interfaces.

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 include/net/addrconf.h |  3 +++
 net/6lowpan/core.c     | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c    |  5 +++--
 3 files changed, 52 insertions(+), 2 deletions(-)

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
index 7a240b3..fbae31e 100644
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
+	if (!ieee802154_is_valid_src_short_addr(wpan_dev->short_addr))
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
index 27aed1a..54e18c2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2948,8 +2948,8 @@ static void init_loopback(struct net_device *dev)
 	}
 }
 
-static void addrconf_add_linklocal(struct inet6_dev *idev,
-				   const struct in6_addr *addr, u32 flags)
+void addrconf_add_linklocal(struct inet6_dev *idev,
+			    const struct in6_addr *addr, u32 flags)
 {
 	struct inet6_ifaddr *ifp;
 	u32 addr_flags = flags | IFA_F_PERMANENT;
@@ -2968,6 +2968,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev,
 		in6_ifa_put(ifp);
 	}
 }
+EXPORT_SYMBOL(addrconf_add_linklocal);
 
 static bool ipv6_reserved_interfaceid(struct in6_addr address)
 {
-- 
2.8.0
