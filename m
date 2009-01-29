From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH] net: add ARP notify option for devices
Date: Thu, 29 Jan 2009 10:49:26 -0800
Message-ID: <4981FA36.2000301@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Xen-devel <xen-devel@lists.xensource.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:53996 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbZA2St3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 13:49:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>

This adds another inet device option to enable gratuitous ARP
when device is brought up or address change. This is handy for
clusters or virtualization.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/linux/inetdevice.h             |    1 +
 include/linux/sysctl.h                 |    1 +
 kernel/sysctl_check.c                  |    1 +
 net/ipv4/devinet.c                     |    9 +++++++++
 5 files changed, 18 insertions(+)

===================================================================
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -782,6 +782,12 @@
 	The max value from conf/{all,interface}/arp_ignore is used
 	when ARP request is received on the {interface}
 
+arp_notify - BOOLEAN
+	Define mode for notification of address and device changes.
+	0 - (default): do nothing
+	1 - Generate gratuitous arp replies when device is brought up
+	    or hardware address changes.
+
 arp_accept - BOOLEAN
 	Define behavior when gratuitous arp replies are received:
 	0 - drop gratuitous arp frames
===================================================================
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -108,6 +108,7 @@
 #define IN_DEV_ARPFILTER(in_dev)	IN_DEV_ORCONF((in_dev), ARPFILTER)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
+#define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
 
 struct in_ifaddr
 {
===================================================================
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -490,6 +490,7 @@
 	NET_IPV4_CONF_ARP_IGNORE=19,
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
+	NET_IPV4_CONF_ARP_NOTIFY=22,
 	__NET_IPV4_CONF_MAX
 };
 
===================================================================
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -219,6 +219,7 @@
 	{ NET_IPV4_CONF_ARP_IGNORE,		"arp_ignore" },
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
+	{ NET_IPV4_CONF_ARP_NOTIFY,		"arp_notify" },
 	{}
 };
 
===================================================================
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1075,6 +1075,14 @@
 			}
 		}
 		ip_mc_up(in_dev);
+		/* fall through */
+	case NETDEV_CHANGEADDR:
+		if (IN_DEV_ARP_NOTIFY(in_dev))
+			arp_send(ARPOP_REQUEST, ETH_P_ARP,
+				 in_dev->ifa_list->ifa_address,
+				 dev,
+				 in_dev->ifa_list->ifa_address,
+				 NULL, dev->dev_addr, NULL);
 		break;
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
@@ -1439,6 +1447,7 @@
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ANNOUNCE, "arp_announce"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
+		DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),


