From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Mon, 2 Jun 2008 16:53:47 -0700
Message-ID: <20080602165347.5662f602@extreme>
References: <20080602165249.52a467dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49274 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbYFBXx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 19:53:56 -0400
In-Reply-To: <20080602165249.52a467dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to previous change for IPV4. Allow configuration option to remove
addresses from FIB when carrier is lost.

This patch also makes IPV6 ignore changes to carrier state when device
is admin down state. This prevents address configuration from starting
up on a buggy device driver that signals carrier changes when offline.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/Documentation/networking/ip-sysctl.txt	2008-06-02 15:30:03.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-06-02 16:32:00.000000000 -0700
@@ -966,6 +966,10 @@ hop_limit - INTEGER
 	Default Hop Limit to set.
 	Default: 64
 
+link_detect - BOOLEAN
+	Remove addresses when link (carrier) is lost on interface.
+	Default: FALSE
+
 mtu - INTEGER
 	Default Maximum Transfer Unit
 	Default: 1280 (IPv6 required minimum)
--- a/include/linux/ipv6.h	2008-06-02 15:30:03.000000000 -0700
+++ b/include/linux/ipv6.h	2008-06-02 16:32:00.000000000 -0700
@@ -134,6 +134,7 @@ struct ipv6_devconf {
 	__s32		accept_redirects;
 	__s32		autoconf;
 	__s32		dad_transmits;
+	__s32		link_detect;
 	__s32		rtr_solicits;
 	__s32		rtr_solicit_interval;
 	__s32		rtr_solicit_delay;
@@ -194,6 +195,7 @@ enum {
 	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
+	DEVCONF_LINK_DETECT,
 	DEVCONF_MAX
 };
 
--- a/include/linux/sysctl.h	2008-06-02 15:30:03.000000000 -0700
+++ b/include/linux/sysctl.h	2008-06-02 16:32:00.000000000 -0700
@@ -579,6 +579,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
+	NET_IPV6_LINK_DETECT=26,
 	__NET_IPV6_MAX
 };
 
--- a/kernel/sysctl_check.c	2008-06-02 16:31:31.000000000 -0700
+++ b/kernel/sysctl_check.c	2008-06-02 16:32:00.000000000 -0700
@@ -495,6 +495,7 @@ static const struct trans_ctl_table tran
 	{ NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN,	"accept_ra_rt_info_max_plen" },
 	{ NET_IPV6_PROXY_NDP,			"proxy_ndp" },
 	{ NET_IPV6_ACCEPT_SOURCE_ROUTE,		"accept_source_route" },
+	{ NET_IPV6_LINK_DETECT,			"link_detect" },
 	{}
 };
 
--- a/net/ipv6/addrconf.c	2008-06-02 15:30:03.000000000 -0700
+++ b/net/ipv6/addrconf.c	2008-06-02 16:32:00.000000000 -0700
@@ -185,6 +185,7 @@ struct ipv6_devconf ipv6_devconf __read_
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.link_detect		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -217,6 +218,7 @@ static struct ipv6_devconf ipv6_devconf_
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.link_detect		= 0,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -2413,8 +2415,11 @@ static int addrconf_notify(struct notifi
 				return notifier_from_errno(-ENOMEM);
 		}
 		break;
-	case NETDEV_UP:
+
 	case NETDEV_CHANGE:
+		if (!netif_running(dev))
+			break;
+	case NETDEV_UP:
 		if (dev->flags & IFF_SLAVE)
 			break;
 
@@ -2433,12 +2438,15 @@ static int addrconf_notify(struct notifi
 
 			if (idev)
 				idev->if_flags |= IF_READY;
+		} else if (!netif_carrier_ok(dev)) {
+			/* device is offline */
+			if (idev && idev->cnf.link_detect)
+				addrconf_ifdown(dev, 1);
+			break;
+		} else if (!addrconf_qdisc_ok(dev)) {
+			/* device is still not ready. */
+			break;
 		} else {
-			if (!addrconf_qdisc_ok(dev)) {
-				/* device is still not ready. */
-				break;
-			}
-
 			if (idev) {
 				if (idev->if_flags & IF_READY) {
 					/* device is already configured. */
@@ -3629,6 +3637,7 @@ static inline void ipv6_store_devconf(st
 #ifdef CONFIG_IPV6_MROUTE
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
+	array[DEVCONF_LINK_DETECT] = cnf->link_detect;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4098,6 +4107,14 @@ static struct addrconf_sysctl_table
 		},
 #endif
 		{
+			.ctl_name	=	NET_IPV6_LINK_DETECT,
+			.procname	=	"link_detect",
+			.data		=	&ipv6_devconf.link_detect,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	NET_IPV6_MAX_ADDRESSES,
 			.procname	=	"max_addresses",
 			.data		=	&ipv6_devconf.max_addresses,
