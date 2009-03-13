From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ipv4: add link_filter sysctl
Date: Fri, 13 Mar 2009 16:12:53 -0700
Message-ID: <20090313161253.0f02da26@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54560 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433AbZCMXM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 19:12:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new parameter that controls how kernel responds to packets
when interface is down. This is done to solve the problem of:

Assume topology of:
      A <----------->       Router             X--- down link
 10.1.1.2/24       10.1.1.1/24    10.2.1.1/24 
                     eth0          eth1

If A pings 10.2.1.1 then with normal Linux semantics Router would
respond even if eth1 link on 10.2.1.1 was down. This causes some network
management tools (that work with other router OS's) to falsely
report that link is okay.

The problem is that a Linux router does not respond the way
other systems do. This is the router equivalent of "Strong ES"
model, it is not the same as "Strong ES" as defined in Host
Requirements.

The new parameter adds an additional check on slow input packet
path, and causes route cache flush if enabled and carrier is
lost.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6

 Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
 include/linux/inetdevice.h             |    2 ++
 include/linux/sysctl.h                 |    1 +
 kernel/sysctl_check.c                  |    1 +
 net/ipv4/devinet.c                     |    1 +
 net/ipv4/fib_frontend.c                |    7 +++++++
 net/ipv4/route.c                       |    9 +++++++++
 7 files changed, 34 insertions(+)

--- a/Documentation/networking/ip-sysctl.txt	2009-03-09 08:23:38.519311272 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2009-03-13 15:54:21.135602442 -0700
@@ -720,6 +720,19 @@ rp_filter - INTEGER
 	Default value is 0. Note that some distributions enable it
 	in startup scripts.
 
+link_filter - INTEGER
+        0 - Allow packets to be received for the address on this interface
+	even if interface is disabled or no carrier.
+
+	1 - Ignore packets received if interface associated with the incoming
+	address is down.
+
+	2 - Ignore packets received if interface associated with the incoming
+	address is down or has no carrier.
+
+	Default value is 0. Note that some distributions enable it
+	in startup scripts.
+
 arp_filter - BOOLEAN
 	1 - Allows you to have multiple network interfaces on the same
 	subnet, and have the ARPs for each interface be answered
--- a/include/linux/inetdevice.h	2009-03-09 08:23:44.882309137 -0700
+++ b/include/linux/inetdevice.h	2009-03-13 15:56:36.947352853 -0700
@@ -83,6 +83,7 @@ static inline void ipv4_devconf_setall(s
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
 #define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_ANDCONF((in_dev), RP_FILTER)
+#define IN_DEV_LINKFILTER(in_dev)	IN_DEV_ORCONF((in_dev), LINKFILTER)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
 #define IN_DEV_BOOTP_RELAY(in_dev)	IN_DEV_ANDCONF((in_dev), BOOTP_RELAY)
@@ -110,6 +111,7 @@ static inline void ipv4_devconf_setall(s
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
 
+
 struct in_ifaddr
 {
 	struct in_ifaddr	*ifa_next;
--- a/include/linux/sysctl.h	2009-03-09 08:23:45.108263490 -0700
+++ b/include/linux/sysctl.h	2009-03-13 15:55:22.147602090 -0700
@@ -491,6 +491,7 @@ enum
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
+ 	NET_IPV4_CONF_LINKFILTER=23,
 	__NET_IPV4_CONF_MAX
 };
 
--- a/kernel/sysctl_check.c	2009-03-09 08:23:45.412309606 -0700
+++ b/kernel/sysctl_check.c	2009-03-13 15:57:58.311601844 -0700
@@ -220,6 +220,7 @@ static const struct trans_ctl_table tran
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
 	{ NET_IPV4_CONF_ARP_NOTIFY,		"arp_notify" },
+	{ NET_IPV4_CONF_LINKFILTER,		"link_filter" },
 	{}
 };
 
--- a/net/ipv4/devinet.c	2009-03-09 08:23:45.613100464 -0700
+++ b/net/ipv4/devinet.c	2009-03-13 15:54:21.211601892 -0700
@@ -1456,6 +1456,7 @@ static struct devinet_sysctl_table {
 					      "force_igmp_version"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
 					      "promote_secondaries"),
+		DEVINET_SYSCTL_RW_ENTRY(LINKFILTER, "link_filter"),
 	},
 };
 
--- a/net/ipv4/fib_frontend.c	2009-03-09 08:23:45.613100464 -0700
+++ b/net/ipv4/fib_frontend.c	2009-03-13 15:54:21.219603788 -0700
@@ -914,6 +914,13 @@ static int fib_inetaddr_event(struct not
 #endif
 		rt_cache_flush(dev_net(dev), -1);
 		break;
+	case NETDEV_CHANGE:
+		if (!netif_carrier_ok(dev)) {
+			struct in_device *in_dev = __in_dev_get_rtnl(dev);
+			if (in_dev && IN_DEV_LINKFILTER(in_dev) > 1)
+				rt_cache_flush(dev_net(dev), -1);
+		}
+		break;
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa);
 		if (ifa->ifa_dev->ifa_list == NULL) {
--- a/net/ipv4/route.c	2009-03-09 08:23:46.275309777 -0700
+++ b/net/ipv4/route.c	2009-03-13 15:54:21.223602538 -0700
@@ -2117,6 +2117,15 @@ static int ip_route_input_slow(struct sk
 
 	if (res.type == RTN_LOCAL) {
 		int result;
+		int linkf = IN_DEV_LINKFILTER(in_dev);
+
+		if (linkf) {
+			if (!netif_running(res.fi->fib_dev))
+				goto e_inval;
+			if (linkf > 1 && !netif_carrier_ok(res.fi->fib_dev))
+				goto e_inval;
+		}
+
 		result = fib_validate_source(saddr, daddr, tos,
 					     net->loopback_dev->ifindex,
 					     dev, &spec_dst, &itag);
