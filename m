From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v5 4/6] ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
Date: Fri, 24 Feb 2017 14:14:38 +0200
Message-ID: <20170224121440.32269-5-luiz.dentz@gmail.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224121440.32269-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

This patch adds support for 48 bit 6LoWPAN address length
autoconfiguration which is the case for BTLE 6LoWPAN.

Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 net/ipv6/addrconf.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a2025f..7756640 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2052,12 +2052,19 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 	__ipv6_dev_ac_dec(ifp->idev, &addr);
 }
 
-static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
+static int addrconf_ifid_6lowpan(u8 *eui, struct net_device *dev)
 {
-	if (dev->addr_len != EUI64_ADDR_LEN)
+	switch (dev->addr_len) {
+	case ETH_ALEN:
+		return addrconf_ifid_eui48(eui, dev);
+	case EUI64_ADDR_LEN:
+		memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
+		eui[0] ^= 2;
+		break;
+	default:
 		return -1;
-	memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
-	eui[0] ^= 2;
+	}
+
 	return 0;
 }
 
@@ -2149,7 +2156,7 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	case ARPHRD_TUNNEL:
 		return addrconf_ifid_gre(eui, dev);
 	case ARPHRD_6LOWPAN:
-		return addrconf_ifid_eui64(eui, dev);
+		return addrconf_ifid_6lowpan(eui, dev);
 	case ARPHRD_IEEE1394:
 		return addrconf_ifid_ieee1394(eui, dev);
 	case ARPHRD_TUNNEL6:
-- 
2.9.3
