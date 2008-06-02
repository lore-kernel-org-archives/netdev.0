From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Mon, 2 Jun 2008 16:52:49 -0700
Message-ID: <20080602165249.52a467dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49272 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753876AbYFBXxz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 19:53:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new configuration sysctl that causes link loss to clear
FIB state in the same way as admin down. This allows for routing daemons
like Quagga which have option to remove routes when carrier is lost.

This has been a long standing problem with Quagga on Linux with complaints
on the developers list going back to 2004. Fixing it properly, so the routing 
daemon manages the RIB, and the kernel manages the FIB, requires changes to
both parts.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch is against net-next-2.6, so it can be integrated in 2.6.27.

--- a/Documentation/networking/ip-sysctl.txt	2008-06-02 14:35:36.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-06-02 15:30:03.000000000 -0700
@@ -788,7 +788,10 @@ disable_policy - BOOLEAN
 disable_xfrm - BOOLEAN
 	Disable IPSEC encryption on this interface, whatever the policy
 
-
+link_detect - BOOLEAN
+	Causes loss of carrier remove interface addresses the same as
+	setting device down. When carrier is restored, the addresses
+	are restored.
 
 tag - INTEGER
 	Allows you to write a number, which can be used as required.
--- a/include/linux/inetdevice.h	2008-06-02 14:35:43.000000000 -0700
+++ b/include/linux/inetdevice.h	2008-06-02 14:36:54.000000000 -0700
@@ -97,6 +97,7 @@ static inline void ipv4_devconf_setall(s
 #define IN_DEV_PROMOTE_SECONDARIES(in_dev) \
 					IN_DEV_ORCONF((in_dev), \
 						      PROMOTE_SECONDARIES)
+#define IN_DEV_LINK_DETECT(in_dev)	IN_DEV_ORCONF((in_dev), LINK_DETECT)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
--- a/include/linux/sysctl.h	2008-06-02 14:35:44.000000000 -0700
+++ b/include/linux/sysctl.h	2008-06-02 15:30:03.000000000 -0700
@@ -490,6 +490,7 @@ enum
 	NET_IPV4_CONF_ARP_IGNORE=19,
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
+	NET_IPV4_CONF_LINK_DETECT=22,
 	__NET_IPV4_CONF_MAX
 };
 
--- a/net/ipv4/devinet.c	2008-06-02 14:35:45.000000000 -0700
+++ b/net/ipv4/devinet.c	2008-06-02 14:36:54.000000000 -0700
@@ -1443,6 +1443,7 @@ static struct devinet_sysctl_table {
 					      "force_igmp_version"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
 					      "promote_secondaries"),
+		DEVINET_SYSCTL_RW_ENTRY(LINK_DETECT, "link_detect"),
 	},
 };
 
--- a/net/ipv4/fib_frontend.c	2008-06-02 14:35:45.000000000 -0700
+++ b/net/ipv4/fib_frontend.c	2008-06-02 14:36:54.000000000 -0700
@@ -944,6 +944,11 @@ static int fib_netdev_event(struct notif
 	if (!in_dev)
 		return NOTIFY_DONE;
 
+	/* Link detect causes changes in carrier to add/remove addresses from FIB */
+	if (event == NETDEV_CHANGE && netif_running(dev)
+	    && IN_DEV_LINK_DETECT(in_dev))
+		event = netif_carrier_ok(dev) ? NETDEV_UP : NETDEV_DOWN;
+
 	switch (event) {
 	case NETDEV_UP:
 		for_ifa(in_dev) {
--- a/kernel/sysctl_check.c	2008-06-02 16:31:09.000000000 -0700
+++ b/kernel/sysctl_check.c	2008-06-02 16:31:31.000000000 -0700
@@ -219,6 +219,7 @@ static const struct trans_ctl_table tran
 	{ NET_IPV4_CONF_ARP_IGNORE,		"arp_ignore" },
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
+	{ NET_IPV4_CONF_LINK_DETECT,		"link_detect" },
 	{}
 };
 
