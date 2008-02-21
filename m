From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Subject: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
	addresses
Date: Thu, 21 Feb 2008 12:08:42 +0200
Message-ID: <20080221100842.GA24905@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from refraktori.verkkotelakka.net ([79.171.233.68]:56554 "EHLO
	refraktori.verkkotelakka.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758222AbYBUKiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:38:06 -0500
Received: from jmtapio sender auth=jmtapio
	by refraktori.verkkotelakka.net with local (Exim 4.63) id 1JS8M6-0006ok-L9
	for netdev@vger.kernel.org; Thu, 21 Feb 2008 12:08:43 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip the prefix length matching in source address selection for
orchid -> non-orchid addresses.

Overlay Routable Cryptographic Hash IDentifiers (RFC 4843,
2001:10::/28) are currenty not globally reachable. Without this
check a host with an ORCHID address can end up preferring those over
regular addresses when talking to other regular hosts in the 2001::/16
range thus breaking non-orchid connections.

Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
---
 include/net/ipv6.h  |   10 ++++++++++
 net/ipv6/addrconf.c |    5 +++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c0c019f..67e024a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -384,6 +384,16 @@ static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
 }
 
 /*
+ * Check for a RFC 4843 ORCHID address 
+ * (Overlay Routable Cryptographic Hash Identifiers)
+ */
+static inline int ipv6_addr_orchid(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] & htonl(0xfffffff0))
+		== htonl(0x20010010));
+}
+
+/*
  * find the first different bit between two addresses
  * length of address must be a multiple of 32bits
  */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e40213d..2474d20 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1125,6 +1125,11 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			if (hiscore.rule < 7)
 				hiscore.rule++;
 #endif
+
+			/* Skip rule 8 for orchid -> non-orchid address pairs. */
+			if (ipv6_addr_orchid(&ifa->addr) && !ipv6_addr_orchid(daddr))
+				continue;
+
 			/* Rule 8: Use longest matching prefix */
 			if (hiscore.rule < 8) {
 				hiscore.matchlen = ipv6_addr_diff(&ifa_result->addr, daddr);
-- 
1.5.3.8

