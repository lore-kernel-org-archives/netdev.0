From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193 addresses
Date: Wed, 25 Jul 2007 19:49:09 -0400
Message-ID: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	"Srinivas Akkipeddi" <sakkiped@starentnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.38.223.190] ([12.38.223.190]:28445 "EHLO
	mail.sw.starentnetworks.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751399AbXGZAS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.

SCTP uses this function and will fail bind() and connect() calls that
use RFC4193 addresses, SCTP will also ignore inbound connections from
RFC4193 addresses if listening on IPV6_ADDR_ANY.

There may be other users of ipv6_addr_type() that could also have
problems.

Signed-off-by: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Cc: Srinivas Akkipeddi <sakkiped@starentnetworks.com>

===== net/ipv6/addrconf_core.c 1.2 vs edited =====
--- 1.2/net/ipv6/addrconf_core.c	2007-02-26 14:42:57 -05:00
+++ edited/net/ipv6/addrconf_core.c	2007-07-25 15:21:41 -04:00
@@ -50,6 +50,9 @@
 	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
 		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
 			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
+	if ((st & htonl(0xFE000000)) == htonl(0xFC000000))
+		return (IPV6_ADDR_UNICAST |
+			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));			/* RFC 4193 */
 
 	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
 		if (addr->s6_addr32[2] == 0) {

