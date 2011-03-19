From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 2/4] ipv4: fix route deletion for IPs on many subnets
Date: Sun, 20 Mar 2011 00:13:49 +0200
Message-ID: <201103192213.p2JMDnvB003074@ja.ssi.bg>
Mime-Version: 1.0
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42155 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757620Ab1CSWId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2011 18:08:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Alex Sidorenko reported for problems with local
routes left after IP addresses are deleted. It happens
when same IPs are used in more than one subnet for the
device.

	Fix fib_del_ifaddr to restrict the checks for duplicate
local and broadcast addresses only to the IFAs that use
our primary IFA or another primary IFA with same address.
And we expect the prefsrc to be matched when the routes
are deleted because it is possible they to differ only by
prefsrc. This patch prevents local and broadcast routes
to be leaked until their primary IP is deleted finally
from the box.

	As the secondary address promotion needs to delete
the routes for all secondaries that used the old primary IFA,
add option to ignore these secondaries from the checks and
to assume they are already deleted, so that we can safely
delete the route while these IFAs are still on the device list.

Reported-by: Alex Sidorenko <alexandre.sidorenko@hp.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/route.h     |    1 
 net/ipv4/fib_frontend.c |  101 ++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 89 insertions(+), 13 deletions(-)

diff -urp net-next-2.6-bef55ae/linux/include/net/route.h linux/include/net/route.h
--- net-next-2.6-bef55ae/linux/include/net/route.h	2011-03-13 01:08:55.000000000 +0200
+++ linux/include/net/route.h	2011-03-16 03:08:36.135967550 +0200
@@ -207,6 +207,7 @@ extern int		ip_rt_dump(struct sk_buff *s
 
 struct in_ifaddr;
 extern void fib_add_ifaddr(struct in_ifaddr *);
+extern void fib_del_ifaddr(struct in_ifaddr *, struct in_ifaddr *);
 
 static inline void ip_rt_put(struct rtable * rt)
 {
diff -urp net-next-2.6-bef55ae/linux/net/ipv4/fib_frontend.c linux/net/ipv4/fib_frontend.c
--- net-next-2.6-bef55ae/linux/net/ipv4/fib_frontend.c	2011-03-13 01:08:55.000000000 +0200
+++ linux/net/ipv4/fib_frontend.c	2011-03-16 03:32:13.816970273 +0200
@@ -722,12 +722,17 @@ void fib_add_ifaddr(struct in_ifaddr *if
 	}
 }
 
-static void fib_del_ifaddr(struct in_ifaddr *ifa)
+/* Delete primary or secondary address.
+ * Optionally, on secondary address promotion consider the addresses
+ * from subnet iprim as deleted, even if they are in device list.
+ * In this case the secondary ifa can be in device list.
+ */
+void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 {
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct net_device *dev = in_dev->dev;
 	struct in_ifaddr *ifa1;
-	struct in_ifaddr *prim = ifa;
+	struct in_ifaddr *prim = ifa, *prim1 = NULL;
 	__be32 brd = ifa->ifa_address | ~ifa->ifa_mask;
 	__be32 any = ifa->ifa_address & ifa->ifa_mask;
 #define LOCAL_OK	1
@@ -735,17 +740,26 @@ static void fib_del_ifaddr(struct in_ifa
 #define BRD0_OK		4
 #define BRD1_OK		8
 	unsigned ok = 0;
+	int subnet = 0;		/* Primary network */
+	int gone = 1;		/* Address is missing */
+	int same_prefsrc = 0;	/* Another primary with same IP */
 
-	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
-		fib_magic(RTM_DELROUTE,
-			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
-			  any, ifa->ifa_prefixlen, prim);
-	else {
+	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
 		if (prim == NULL) {
 			printk(KERN_WARNING "fib_del_ifaddr: bug: prim == NULL\n");
 			return;
 		}
+		if (iprim && iprim != prim) {
+			printk(KERN_WARNING "fib_del_ifaddr: bug: iprim != prim\n");
+			return;
+		}
+	} else if (!ipv4_is_zeronet(any) &&
+		   (any != ifa->ifa_local || ifa->ifa_prefixlen < 32)) {
+		fib_magic(RTM_DELROUTE,
+			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
+			  any, ifa->ifa_prefixlen, prim);
+		subnet = 1;
 	}
 
 	/* Deletion is more complicated than add.
@@ -755,6 +769,49 @@ static void fib_del_ifaddr(struct in_ifa
 	 */
 
 	for (ifa1 = in_dev->ifa_list; ifa1; ifa1 = ifa1->ifa_next) {
+		if (ifa1 == ifa) {
+			/* promotion, keep the IP */
+			gone = 0;
+			continue;
+		}
+		/* Ignore IFAs from our subnet */
+		if (iprim && ifa1->ifa_mask == iprim->ifa_mask &&
+		    inet_ifa_match(ifa1->ifa_address, iprim))
+			continue;
+
+		/* Ignore ifa1 if it uses different primary IP (prefsrc) */
+		if (ifa1->ifa_flags & IFA_F_SECONDARY) {
+			/* Another address from our subnet? */
+			if (ifa1->ifa_mask == prim->ifa_mask &&
+			    inet_ifa_match(ifa1->ifa_address, prim))
+				prim1 = prim;
+			else {
+				/* We reached the secondaries, so
+				 * same_prefsrc should be determined.
+				 */
+				if (!same_prefsrc)
+					continue;
+				/* Search new prim1 if ifa1 is not
+				 * using the current prim1
+				 */
+				if (!prim1 ||
+				    ifa1->ifa_mask != prim1->ifa_mask ||
+				    !inet_ifa_match(ifa1->ifa_address, prim1))
+					prim1 = inet_ifa_byprefix(in_dev,
+							ifa1->ifa_address,
+							ifa1->ifa_mask);
+				if (!prim1)
+					continue;
+				if (prim1->ifa_local != prim->ifa_local)
+					continue;
+			}
+		} else {
+			if (prim->ifa_local != ifa1->ifa_local)
+				continue;
+			prim1 = ifa1;
+			if (prim != prim1)
+				same_prefsrc = 1;
+		}
 		if (ifa->ifa_local == ifa1->ifa_local)
 			ok |= LOCAL_OK;
 		if (ifa->ifa_broadcast == ifa1->ifa_broadcast)
@@ -763,19 +820,37 @@ static void fib_del_ifaddr(struct in_ifa
 			ok |= BRD1_OK;
 		if (any == ifa1->ifa_broadcast)
 			ok |= BRD0_OK;
+		/* primary has network specific broadcasts */
+		if (prim1 == ifa1 && ifa1->ifa_prefixlen < 31) {
+			__be32 brd1 = ifa1->ifa_address | ~ifa1->ifa_mask;
+			__be32 any1 = ifa1->ifa_address & ifa1->ifa_mask;
+
+			if (!ipv4_is_zeronet(any1)) {
+				if (ifa->ifa_broadcast == brd1 ||
+				    ifa->ifa_broadcast == any1)
+					ok |= BRD_OK;
+				if (brd == brd1 || brd == any1)
+					ok |= BRD1_OK;
+				if (any == brd1 || any == any1)
+					ok |= BRD0_OK;
+			}
+		}
 	}
 
 	if (!(ok & BRD_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
-	if (!(ok & BRD1_OK))
-		fib_magic(RTM_DELROUTE, RTN_BROADCAST, brd, 32, prim);
-	if (!(ok & BRD0_OK))
-		fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
+	if (subnet && ifa->ifa_prefixlen < 31) {
+		if (!(ok & BRD1_OK))
+			fib_magic(RTM_DELROUTE, RTN_BROADCAST, brd, 32, prim);
+		if (!(ok & BRD0_OK))
+			fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
+	}
 	if (!(ok & LOCAL_OK)) {
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
-		if (inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
+		if (gone &&
+		    inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			 * We must flush stray FIB entries.
 			 *
@@ -896,7 +971,7 @@ static int fib_inetaddr_event(struct not
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
-		fib_del_ifaddr(ifa);
+		fib_del_ifaddr(ifa, NULL);
 		fib_update_nh_saddrs(dev);
 		if (ifa->ifa_dev->ifa_list == NULL) {
 			/* Last address was deleted from this interface.
