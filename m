From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] r6040: Fix multicast filter some more
Date: Fri, 15 Oct 2010 04:17:16 +0100
Message-ID: <1287112636.20865.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33120 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755523Ab0JODR1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 23:17:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code has been broken forever, but in several different and
creative ways.

So far as I can work out, the R6040 MAC filter has 4 exact-match
entries, the first of which the driver uses for its assigned unicast
address, plus a 64-entry hash-based filter for multicast addresses
(maybe unicast as well?).

The original version of this code would write the first 4 multicast
addresses as exact-match entries from offset 1 (bug #1: there is no
entry 4 so this could write to some PHY registers).  It would fill the
remainder of the exact-match entries with the broadcast address (bug
addresses were configured, it would set up the hash table, write some
random crap to the MAC control register (bug #3) and finally walk off
the end of the list when filling the exact-match entries (bug #4).

All of this seems to be pointless, since it sets the promiscuous bit
when the interface is made promiscuous or if >4 multicast addresses
are enabled, and never clears it (bug #5, masking bug #2).

The recent(ish) changes to the multicast list fixed bug #4, but
completely removed the limit on iteration over the exact-match entries
(bug #6).

Bug #4 was reported as
<https://bugzilla.kernel.org/show_bug.cgi?id=15355> and more recently
as <http://bugs.debian.org/600155>.  Florian Fainelli attempted to fix
these in commit 3bcf8229a8c49769e48d3e0bd1e20d8e003f8106, but that
actually dealt with bugs #1-3, bug #4 having been fixed in mainline at
that point.

That commit fixes the most important current bug #6.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Cc: stable@kernel.org [2.6.35 only]
---
Compile-tested only.

Ben.

 drivers/net/r6040.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 142c381..80666f0 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -893,16 +893,18 @@ static void r6040_multicast_list(struct net_device *dev)
 	/* Multicast Address 1~4 case */
 	i = 0;
 	netdev_for_each_mc_addr(ha, dev) {
-		if (i < MCAST_MAX) {
-			adrp = (u16 *) ha->addr;
-			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
-			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
-			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
-		} else {
-			iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
-			iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
-		}
+		if (i >= MCAST_MAX)
+			break;
+		adrp = (u16 *) ha->addr;
+		iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
+		iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
+		iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
+		i++;
+	}
+	while (i < MCAST_MAX) {
+		iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
+		iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
+		iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
 		i++;
 	}
 }
-- 
1.7.1


