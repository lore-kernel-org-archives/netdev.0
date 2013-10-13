From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC] ipv6: always join solicited-node address
Date: Sun, 13 Oct 2013 19:24:24 +0200
Message-ID: <1381685064-24805-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60404 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754493Ab3JMRYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 13:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4861 section 7.2.1 "Interface Initialization" says:

   When a multicast-capable interface becomes enabled, the node MUST
   join the all-nodes multicast address on that interface, as well as
   the solicited-node multicast address corresponding to each of the IP
   addresses assigned to the interface.

The current dependency on IFF_NOARP seems unwarranted. We need to
listen on the solicited-node address whether or not we intend to
initiate Neigbour Discovery ourselves.

This fixes a bug where Linux fails to respond to received Neigbour
Solicitations on multicast capable links when IFF_NOARP is set.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I am not at all sure about this... Comments are appreciated.

The observed problem is a MBIM mobile broadband modem sending NS
to the host.  MBIM is a point-to-point USB protocol which does not
have any L2 headers at all.  It can only transport IPv4 or IPv6
packets.  So for IPv4 there is no question at all:  ARP just
cannot be transported. The driver emulates an ethernet interface,
setting IFF_NOARP to make sure the upper layers doesn't attempt
to resolve the neighbours non-existing L2 addresses.

But then there is this modem which sends IPv6 Neigbour
Solicitations to the host over the MBIM transport. The link
layer addresses are meaningless, but it seems the modem still
expects an answer.  Which we will not currently provide, because
the NS is addressed to a solicited-node address we don't listen
to.

So this patch seems like a quick-fix to that problem.  But it does
change the semantics of IFF_NOARP, making us reply to NS even if
this flag is set.  Which probably is wrong?


Bj=C3=B8rn

 net/ipv6/addrconf.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cd3fb30..aa2df3b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1658,7 +1658,7 @@ void addrconf_join_solict(struct net_device *dev,=
 const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
=20
-	if (dev->flags&(IFF_LOOPBACK|IFF_NOARP))
+	if (!(dev->flags & IFF_MULTICAST))
 		return;
=20
 	addrconf_addr_solict_mult(addr, &maddr);
@@ -1669,7 +1669,7 @@ void addrconf_leave_solict(struct inet6_dev *idev=
, const struct in6_addr *addr)
 {
 	struct in6_addr maddr;
=20
-	if (idev->dev->flags&(IFF_LOOPBACK|IFF_NOARP))
+	if (!(idev->dev->flags & IFF_MULTICAST))
 		return;
=20
 	addrconf_addr_solict_mult(addr, &maddr);
--=20
1.7.10.4
