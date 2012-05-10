From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next] 6lowpan: IPv6 link local address
Date: Thu, 10 May 2012 17:25:52 +0400
Message-ID: <1336656352-19518-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50611 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758509Ab2EJN0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 09:26:23 -0400
Received: by bkcji2 with SMTP id ji2so1283698bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 06:26:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the RFC4944 (Transmission of IPv6 Packets over
IEEE 802.15.4 Networks), chapter 7:

The IPv6 link-local address [RFC4291] for an IEEE 802.15.4 interface
is formed by appending the Interface Identifier, as defined above, to
the prefix FE80::/64.

  10 bits            54 bits                  64 bits
+----------+-----------------------+----------------------------+
|1111111010|         (zeros)       |    Interface Identifier    |
+----------+-----------------------+----------------------------+

This patch adds IPv6 address generation support for the 6lowpan
interfaces.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ipv6/addrconf.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e3b3421..8b7f100 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -66,6 +66,7 @@
 #include <net/sock.h>
 #include <net/snmp.h>
 
+#include <net/af_ieee802154.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
 #include <net/ndisc.h>
@@ -1514,6 +1515,14 @@ static int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 	return 0;
 }
 
+static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
+{
+	if (dev->addr_len != IEEE802154_ADDR_LEN)
+		return -1;
+	memcpy(eui, dev->dev_addr, 8);
+	return 0;
+}
+
 static int addrconf_ifid_arcnet(u8 *eui, struct net_device *dev)
 {
 	/* XXX: inherit EUI-64 from other interface -- yoshfuji */
@@ -1577,6 +1586,8 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_sit(eui, dev);
 	case ARPHRD_IPGRE:
 		return addrconf_ifid_gre(eui, dev);
+	case ARPHRD_IEEE802154:
+		return addrconf_ifid_eui64(eui, dev);
 	}
 	return -1;
 }
@@ -2438,7 +2449,8 @@ static void addrconf_dev_config(struct net_device *dev)
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_IEEE802_TR) &&
 	    (dev->type != ARPHRD_ARCNET) &&
-	    (dev->type != ARPHRD_INFINIBAND)) {
+	    (dev->type != ARPHRD_INFINIBAND) &&
+	    (dev->type != ARPHRD_IEEE802154)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
-- 
1.7.2.3
