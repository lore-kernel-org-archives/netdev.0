From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Sat, 9 Feb 2013 13:10:05 +0100
Message-ID: <20130209121005.GB23281@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53881 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3BIMKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 07:10:07 -0500
Content-Disposition: inline
In-Reply-To: <20130206165415.GB19537@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 05:54:15PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Feb 07, 2013 at 12:24:14AM +0900, YOSHIFUJI Hideaki wrote:
> > NAK.  I think we should select routes via loopback device here.
> 
> Will try your idea, thanks.

Does this patch look reasonable? Btw. i am pleased to see this kind of
things work out as expected most of the time (addrtype checking etc. all
in place). :)

I have a few questions:

a) Do we have a way to lock down routes in the kernel that they are
untouchable from userspace?

b) We don't set IFF_MULTICAST in the loopback interface driver by default.
Is there a reason we couldn't do so? This patch tries to also bind the
interface local all router multicast address on lo, but will only do so
if multicast is enabled on lo before changing the sysctl.

c) I will send a patch as soon as the errata thing is resolved to drop
ff00::/15 from entering the host from the wire. In case of outgoing
traffic to ff00::/16, should this be stopped with a net-unreachable route?

Btw, I saw that the errata on RFC 4291 is already submitted:
http://www.rfc-editor.org/errata_search.php?rfc=4291
Thanks, Erik!

[PATCH net-next RFC] ipv6: let loopback join ff01::{1,2} and create a loopback route to ff00::/16

This patch ensures that traffic to ff01::/16 is directed to the loopback
interface by default and does not leave the host. The interface-local
all nodes and all routers (in case forwarding is enabled) are now joined
by default, too.

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Cc: Erik Hugne <erik.hugne@ericsson.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/in6.h |  6 ++++++
 net/ipv6/addrconf.c | 37 +++++++++++++++++++++++++++++++++++--
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index a16e193..fd0e86d 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -36,4 +36,10 @@ extern const struct in6_addr in6addr_linklocal_allnodes;
 extern const struct in6_addr in6addr_linklocal_allrouters;
 #define IN6ADDR_LINKLOCAL_ALLROUTERS_INIT \
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+extern const struct in6_addr in6addr_interfacelocal_allnodes;
+#define IN6ADR_INTERFACELOCAL_ALLNODES_INIT \
+		{ { { 0xff,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
+extern const struct in6_addr in6addr_interfacelocal_allrouters;
+#define IN6ADR_INTERFACELOCAL_ALLROUTERS_INIT \
+		{ { { 0xff,1,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
 #endif
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index bd9f936..c15b98f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -244,6 +244,8 @@ const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 const struct in6_addr in6addr_linklocal_allnodes = IN6ADDR_LINKLOCAL_ALLNODES_INIT;
 const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTERS_INIT;
+const struct in6_addr in6addr_interfacelocal_allnodes = IN6ADR_INTERFACELOCAL_ALLNODES_INIT;
+const struct in6_addr in6addr_interfacelocal_allrouters = IN6ADR_INTERFACELOCAL_ALLROUTERS_INIT;
 
 /* Check if a valid qdisc is available */
 static inline bool addrconf_qdisc_ok(const struct net_device *dev)
@@ -611,10 +613,17 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (idev->cnf.forwarding)
 		dev_disable_lro(dev);
 	if (dev->flags & IFF_MULTICAST) {
-		if (idev->cnf.forwarding)
+		if (idev->cnf.forwarding) {
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
-		else
+			if (dev->flags & IFF_LOOPBACK)
+				ipv6_dev_mc_inc(dev,
+						&in6addr_interfacelocal_allrouters);
+		} else {
 			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
+			if (dev->flags & IFF_LOOPBACK)
+				ipv6_dev_mc_dec(dev,
+						&in6addr_interfacelocal_allrouters);
+		}
 	}
 
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
@@ -2518,6 +2527,29 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 }
 #endif
 
+static void init_loopback_mc(struct net_device *dev)
+{
+	struct fib6_config cfg = {
+		.fc_table = RT6_TABLE_LOCAL,
+		.fc_metric = IP6_RT_PRIO_ADDRCONF,
+		.fc_dst_len = 16,
+		.fc_ifindex = dev->ifindex,
+		.fc_flags = RTF_UP,
+		.fc_protocol = RTPROT_KERNEL,
+		.fc_type = RTN_MULTICAST,
+		.fc_nlinfo.nl_net = dev_net(dev),
+	};
+
+	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF010000), 0, 0, 0);
+	if (ip6_route_add(&cfg))
+		pr_debug("%s: ip6_route_add failed for node local multicast\n",
+			 __func__);
+
+	if (ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allnodes))
+		pr_debug("%s: failed to join interface-local all nodes mc\n",
+			 __func__);
+}
+
 static void init_loopback(struct net_device *dev)
 {
 	struct inet6_dev  *idev;
@@ -2532,6 +2564,7 @@ static void init_loopback(struct net_device *dev)
 	}
 
 	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
+	init_loopback_mc(dev);
 }
 
 static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
-- 
1.8.1.2
