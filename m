From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Fri, 11 Jun 2010 08:48:54 -0700
Message-ID: <20100611084854.0680c014@nehalam>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56287 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754957Ab0FKPtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 11:49:01 -0400
In-Reply-To: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Linux is used as a router, it is undesirable for the kernel to process
incoming packets when the address assigned to the interface is down.
The initial problem report was for a management application that used ICMP
to check link availability.

The default is disabled to maintain compatibility with previous behavior.
This is not recommended for server systems because it makes fail over more
difficult, and does not account for configurations where multiple interfaces
have the same IP address.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 Documentation/networking/ip-sysctl.txt |   10 ++++++++++
 include/linux/inetdevice.h             |    2 ++
 net/ipv4/devinet.c                     |    1 +
 net/ipv4/route.c                       |    7 +++++++
 4 files changed, 20 insertions(+)

--- a/include/linux/inetdevice.h	2010-05-28 08:35:11.000000000 -0700
+++ b/include/linux/inetdevice.h	2010-06-11 08:35:55.237028136 -0700
@@ -37,6 +37,7 @@ enum
 	IPV4_DEVCONF_ACCEPT_LOCAL,
 	IPV4_DEVCONF_SRC_VMARK,
 	IPV4_DEVCONF_PROXY_ARP_PVLAN,
+	IPV4_DEVCONF_LINKFILTER,
 	__IPV4_DEVCONF_MAX
 };
 
@@ -140,6 +141,7 @@ static inline void ipv4_devconf_setall(s
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
+#define IN_DEV_LINKFILTER(in_dev)	IN_DEV_MAXCONF((in_dev), LINKFILTER)
 
 struct in_ifaddr {
 	struct in_ifaddr	*ifa_next;
--- a/net/ipv4/devinet.c	2010-06-01 08:39:12.000000000 -0700
+++ b/net/ipv4/devinet.c	2010-06-11 08:37:03.921248294 -0700
@@ -1416,6 +1416,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
 		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP_PVLAN, "proxy_arp_pvlan"),
+		DEVINET_SYSCTL_RW_ENTRY(LINKFILTER, "link_filter"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
--- a/net/ipv4/route.c	2010-06-11 08:13:13.000000000 -0700
+++ b/net/ipv4/route.c	2010-06-11 08:14:28.486271886 -0700
@@ -2152,6 +2152,13 @@ static int ip_route_input_slow(struct sk
 		goto brd_input;
 
 	if (res.type == RTN_LOCAL) {
+		int linkf = IN_DEV_LINKFILTER(in_dev);
+
+		if (linkf && !netif_running(res.fi->fib_dev))
+			goto no_route;
+		if (linkf > 1 && !netif_carrier_ok(res.fi->fib_dev))
+			goto no_route;
+
 		err = fib_validate_source(saddr, daddr, tos,
 					     net->loopback_dev->ifindex,
 					     dev, &spec_dst, &itag, skb->mark);
--- a/Documentation/networking/ip-sysctl.txt	2010-06-11 08:14:46.889751310 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2010-06-11 08:15:35.508471622 -0700
@@ -832,6 +832,16 @@ rp_filter - INTEGER
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
 arp_filter - BOOLEAN
 	1 - Allows you to have multiple network interfaces on the same
 	subnet, and have the ARPs for each interface be answered
