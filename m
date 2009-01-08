From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 8 Jan 2009 12:12:20 -0800
Message-ID: <20090108121220.789325a6@extreme>
References: <20090108093430.0f966738@extreme>
	<20090108.112420.102641584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59806 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbZAHUMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 15:12:22 -0500
In-Reply-To: <20090108.112420.102641584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What about this?

If it works (still testing), I'll submit it.

---
 Documentation/networking/ip-sysctl.txt |    8 ++++++
 include/linux/ipv6.h                   |    2 +
 net/ipv6/addrconf.c                    |   38 +++++++++++++++++++++-----------
 3 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index e2b2894..fa05b06 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -937,6 +937,14 @@ dad_transmits - INTEGER
 	The amount of Duplicate Address Detection probes to send.
 	Default: 1
 	
+delete_address_ifdown - BOOLEAN
+	Delete all addresses on device down
+	Default: TRUE
+
+	When network device is disabled: 
+	  FALSE - only delete temporary addresses (similar to IPV4)
+	  TRUE  - delete all addresses
+
 forwarding - BOOLEAN
 	Configure interface-specific Host/Router behaviour.  
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 641e026..b2d219a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -166,6 +166,7 @@ struct ipv6_devconf {
 #endif
 	__s32		disable_ipv6;
 	__s32		accept_dad;
+	__s32		delete_address_ifdown;
 	void		*sysctl;
 };
 #endif
@@ -200,6 +201,7 @@ enum {
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
+	DEVCONF_DELETE_ADDRESS_IFDOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2635fa2..9133c20 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -186,6 +186,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.delete_address_ifdown  = 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -220,6 +221,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.delete_address_ifdown  = 1,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -2673,19 +2675,20 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	while ((ifa = idev->addr_list) != NULL) {
-		idev->addr_list = ifa->if_next;
-		ifa->if_next = NULL;
-		ifa->dead = 1;
-		addrconf_del_timer(ifa);
-		write_unlock_bh(&idev->lock);
-
-		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-		in6_ifa_put(ifa);
-
-		write_lock_bh(&idev->lock);
-	}
+	if (idev->cnf.delete_address_ifdown)
+		while ((ifa = idev->addr_list) != NULL) {
+			idev->addr_list = ifa->if_next;
+			ifa->if_next = NULL;
+			ifa->dead = 1;
+			addrconf_del_timer(ifa);
+			write_unlock_bh(&idev->lock);
+
+			__ipv6_ifa_notify(RTM_DELADDR, ifa);
+			atomic_notifier_call_chain(&inet6addr_chain,
+						   NETDEV_DOWN, ifa);
+			in6_ifa_put(ifa);
+			write_lock_bh(&idev->lock);
+		}
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
@@ -3693,6 +3696,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
+	array[DEVCONF_DELETE_ADDRESS_IFDOWN] = cnf->delete_address_ifdown;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4268,6 +4272,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	&proc_dointvec,
 		},
 		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"delete_address_ifdown",
+			.data		=	&ipv6_devconf.delete_address_ifdown,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},
-- 
1.5.6.3

