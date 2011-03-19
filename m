From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 3/4] ipv4: remove the routes on secondary promotion
Date: Sun, 20 Mar 2011 00:13:52 +0200
Message-ID: <201103192213.p2JMDq9n003083@ja.ssi.bg>
Mime-Version: 1.0
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42158 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757674Ab1CSWIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2011 18:08:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The secondary address promotion relies on fib_sync_down_addr
to remove all routes created for the secondary addresses when
the old primary address is deleted. It does not happen for cases
when the primary address is also in another subnet. Fix that
by deleting local and broadcast routes for all secondaries while
they are on device list and by faking that all addresses from
this subnet are to be deleted. It relies on fib_del_ifaddr being
able to ignore the IPs from the concerned subnet while checking
for duplication.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/devinet.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff -urp net-next-2.6-bef55ae/linux/net/ipv4/devinet.c linux/net/ipv4/devinet.c
--- net-next-2.6-bef55ae/linux/net/ipv4/devinet.c	2011-03-13 01:08:55.000000000 +0200
+++ linux/net/ipv4/devinet.c	2011-03-16 10:54:42.669192601 +0200
@@ -345,6 +345,17 @@ static void __inet_del_ifa(struct in_dev
 		}
 	}
 
+	/* On promotion all secondaries from subnet are changing
+	 * the primary IP, we must remove all their routes silently
+	 * and later to add them back with new prefsrc. Do this
+	 * while all addresses are on the device list.
+	 */
+	for (ifa = promote; ifa; ifa = ifa->ifa_next) {
+		if (ifa1->ifa_mask == ifa->ifa_mask &&
+		    inet_ifa_match(ifa1->ifa_address, ifa))
+			fib_del_ifaddr(ifa, ifa1);
+	}
+
 	/* 2. Unlink it */
 
 	*ifap = ifa1->ifa_next;
