From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v6 4/6] ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
Date: Thu,  2 Mar 2017 15:23:33 +0200
Message-ID: <20170302132335.21192-5-luiz.dentz@gmail.com>
References: <20170302132335.21192-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, aar@pengutronix.de,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35576 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753138AbdCBNcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 08:32:51 -0500
In-Reply-To: <20170302132335.21192-1-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <aar@pengutronix.de>

This patch adds support for 48 bit 6LoWPAN address length
autoconfiguration which is the case for BTLE 6LoWPAN.

Signed-off-by: Alexander Aring <aar@pengutronix.de>
Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Acked-by: David S. Miller <davem@davemloft.net>
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
