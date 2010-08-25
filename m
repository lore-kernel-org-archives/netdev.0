From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] ipv6:  Enable netlink notification for tentative addresses.
Date: Wed, 25 Aug 2010 11:26:17 -0700
Message-ID: <1282760777-15381-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37059 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab0HYS0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 14:26:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, netlink messages are not sent when an IPv6 address
is added if it is in tentative state.  This makes it harder
for user-space applications to know the current state of the
IPv6 addresses.  This patch adds an ipv6 sysctl that will
allow tentative address notifications to be sent.  The sysctl
is off by default.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 f350c69... 3f223d2... M	Documentation/networking/ip-sysctl.txt
:100644 100644 e62683b... 7912172... M	include/linux/ipv6.h
:100644 100644 ab70a3f... ec8b66a... M	net/ipv6/addrconf.c
 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 include/linux/ipv6.h                   |    6 ++++++
 net/ipv6/addrconf.c                    |   19 +++++++++++++++++++
 3 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f350c69..3f223d2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1005,6 +1005,18 @@ conf/all/forwarding - BOOLEAN
 proxy_ndp - BOOLEAN
 	Do proxy ndp.
 
+nlnotify_on_addr_add - BOOLEAN
+        By default, netlink messages are not sent when an IPv6 address
+	is added if it is in tentative state.  This makes it harder
+	for some user-space applications to function properly.  To
+	ensure that a netlink message is always sent when an IPv6 addr
+	is added, regardless of the state of the address, set this value
+	to 1.  For the old (default) behaviour, set this value to 0.
+
+	If only certain interfaces should have this behaviour, leave the
+	'all' config set to 0 and set the individual interface's value
+	to 1.
+
 conf/interface/*:
 	Change special settings per interface.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e62683b..7912172 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -163,6 +163,11 @@ struct ipv6_devconf {
 #endif
 	__s32		proxy_ndp;
 	__s32		accept_source_route;
+	__s32		nlnotify_on_addr_add; /* Always notify netlink on addr add, even if it is tentative.
+					       * As currently implemented, this will often cause multiple netlink
+					       * RTM_NEWADDR messages, as a new notification will be sent when
+					       * the address becomes un-tentative.
+					       */
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	__s32		optimistic_dad;
 #endif
@@ -213,6 +218,7 @@ enum {
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
 	DEVCONF_FORCE_TLLAO,
+	DEVCONF_NLNOTIFY_ON_ADDR_ADD,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab70a3f..ec8b66a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -125,6 +125,7 @@ static void ipv6_regen_rndid(unsigned long data);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
+static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
 /*
  *	Configured unicast address hash table
@@ -192,6 +193,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.nlnotify_on_addr_add	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -226,6 +228,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
+	.nlnotify_on_addr_add   = 0,  /* by default, only notify when it becomes un-tentative */
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -704,6 +707,13 @@ out2:
 		ifa = ERR_PTR(err);
 	}
 
+	/* Allow netlink notification of all addresses, regardless of flags. */
+	if (ipv6_devconf.nlnotify_on_addr_add || idev->cnf.nlnotify_on_addr_add) {
+		if (!IS_ERR(ifa)) {
+			inet6_ifa_notify(RTM_NEWADDR, ifa);
+		}
+	}
+	
 	return ifa;
 out:
 	spin_unlock(&addrconf_hash_lock);
@@ -3833,6 +3843,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
+	array[DEVCONF_NLNOTIFY_ON_ADDR_ADD] = cnf->nlnotify_on_addr_add;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4412,6 +4423,14 @@ static struct addrconf_sysctl_table
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
+		{
+			.procname       =       "nlnotify_on_addr_add",
+			.data           =       &ipv6_devconf.nlnotify_on_addr_add,
+			.maxlen         =       sizeof(int),
+			.mode           =       0644,
+			.proc_handler   =       &proc_dointvec,
+
+		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
 			.procname       = "optimistic_dad",
-- 
1.6.2.5

