From: arno@natisbad.org (Arnaud Ebalard)
Subject: [Patch] Make ULA flagged unicast global
Date: Fri, 20 Jul 2007 10:54:32 +0200
Message-ID: <87ir8f8ng7.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51454 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbXGTJAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 05:00:09 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1IBoLC-0001H3-QM
	for netdev@vger.kernel.org; Fri, 20 Jul 2007 11:00:02 +0200
Received: from moog.chdir.org ([88.191.42.160])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 11:00:02 +0200
Received: from arno by moog.chdir.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2007 11:00:02 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Find attached a patch to get IPv6 Unique Local Addresses (FC00::/7)
flagged unicast global in __ipv6_addr_type(), as expected by RFC 4193.


One easy way to see the current difference of handling with a more
common unicast global address is by trying to insert a default route
using a unique local address for the gateway: 

$ sudo ip -6 addr add fd00::1/64 dev eth0
$ sudo ip -6 route add default via fd00::2 dev eth0
RTNETLINK answers: Invalid argument

where sth like 2001:db8::1 (in fact, where first 3 bits are different of
000 or 111) does work.


The patch is against Linus git tree but the code in the modified file is
pretty stable so it should apply without problems.

One remark: as ULA get flagged as unicast global by that change, there
might be a difference in address selection mechanism. Anyway, the
longest prefix match rule should do his job if something better is
available, i.e. a unique local address will not be selected as src or
dst for something in 2000::/3, for instance. 

Regards,

a+

ps : i'm aware LL addresses should be used for expressing gw, not global
ones.


diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index faaefb6..93b17d5 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -29,11 +29,13 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 
 	st = addr->s6_addr32[0];
 
-	/* Consider all addresses with the first three bits different of
-	   000 and 111 as unicasts.
+	/* - Consider all addresses with the first three bits different of
+	     000 and 111 as unicasts.
+	   - Unique Local Addresses (FC00::/7, RFC 4193) are unicast global.
 	 */
-	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
-	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
+	if (((st & htonl(0xE0000000)) != htonl(0x00000000) &&
+	     (st & htonl(0xE0000000)) != htonl(0xE0000000)) ||
+	    ((st & htonl(0xFE000000)) == htonl(0xFC000000)))
 		return (IPV6_ADDR_UNICAST |
 			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));

