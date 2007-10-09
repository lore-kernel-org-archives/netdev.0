From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] [IPV6] Defer IPv6 device initialization until a valid qdisc
 is specified
Date: Tue, 9 Oct 2007 16:21:58 +0900
Message-ID: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37872 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbXJIHWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 03:22:19 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l997MJdS024670
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 03:22:19 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l997MIIr340742
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 01:22:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l997MIIk017439
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 01:22:18 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To judge the timing for DAD, netif_carrier_ok() is used. However,
there is a possibility that dev->qdisc stays noop_qdisc even if
netif_carrier_ok() returns true. In that case, DAD NS is not sent out.
We need to defer the IPv6 device initialization until a valid qdisc
is specified.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6d5c3c2..da8c79c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -74,6 +74,7 @@
 #include <net/tcp.h>
 #include <net/ip.h>
 #include <net/netlink.h>
+#include <net/pkt_sched.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
 
@@ -213,6 +214,12 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 
+/* Check if a valid qdisc is available */
+static inline int addrconf_qdisc_ok(struct net_device *dev)
+{
+	return (dev->qdisc != &noop_qdisc);
+}
+
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
 {
 	if (del_timer(&ifp->timer))
@@ -384,7 +391,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	}
 #endif
 
-	if (netif_running(dev) && netif_carrier_ok(dev))
+	if (netif_running(dev) && addrconf_qdisc_ok(dev))
 		ndev->if_flags |= IF_READY;
 
 	ipv6_mc_init_dev(ndev);
@@ -2283,7 +2290,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			break;
 
 		if (event == NETDEV_UP) {
-			if (!netif_carrier_ok(dev)) {
+			if (!addrconf_qdisc_ok(dev)) {
 				/* device is not ready yet. */
 				printk(KERN_INFO
 					"ADDRCONF(NETDEV_UP): %s: "
@@ -2295,7 +2302,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			if (idev)
 				idev->if_flags |= IF_READY;
 		} else {
-			if (!netif_carrier_ok(dev)) {
+			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */
 				break;
 			}
-- 
1.5.2.2

