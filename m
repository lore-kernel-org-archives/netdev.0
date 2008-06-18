From: Ben Greear <greearb@candelatech.com>
Subject: Patch to guarantee netlink msg when ipv6 addr is added.
Date: Wed, 18 Jun 2008 15:29:18 -0700
Message-ID: <48598C3E.8010305@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040305050702040609040808"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:56107 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbYFRW3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 18:29:21 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5IMTI3K025402
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 15:29:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040305050702040609040808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Current 2.6.25.4 IPv6 code will not send netlink RTM_NEWADDR
messages when an IPv6 addr is added if the state is Tentative.

This makes it harder for user-space apps to keep up with what IPv6
addrs are configured on the system at any given time.

Attached is a patch to enable a sysctl to force the NEWADDR message
when an IPv6 addr is added, regardless of it's state.  A new message
will be sent later if the state changes from tentative.

This patch is against 2.6.25.4   If the IPv6 maintainers of this code
want to accept the patch, I'll be happy to diff it against whatever
tree is requested.

Comments are welcome.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------040305050702040609040808
Content-Type: text/x-patch;
 name="ipv6_nlnewlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6_nlnewlink.patch"

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 17a6e46..f128106 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -866,6 +866,18 @@ conf/all/forwarding - BOOLEAN
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
index 134c8e5..3d0136a 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -157,6 +157,11 @@ struct ipv6_devconf {
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
@@ -190,6 +195,7 @@ enum {
 	DEVCONF_PROXY_NDP,
 	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
+	DEVCONF_NLNOTIFY_ON_ADDR_ADD,
 	DEVCONF_MAX
 };
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 5f1d1c8..8dbe468 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -579,6 +579,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
+	NET_IPV6_NLNOTIFY_ON_ADDR_ADD=26,
 	__NET_IPV6_MAX
 };
 
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index cb5fd21..37c8fab 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -495,6 +495,7 @@ static const struct trans_ctl_table trans_net_ipv6_conf_var_table[] = {
 	{ NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN,	"accept_ra_rt_info_max_plen" },
 	{ NET_IPV6_PROXY_NDP,			"proxy_ndp" },
 	{ NET_IPV6_ACCEPT_SOURCE_ROUTE,		"accept_source_route" },
+	{ NET_IPV6_NLNOTIFY_ON_ADDR_ADD,	"nlnotify_on_addr_add" },
 	{}
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e08955b..594496b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -185,6 +185,7 @@ struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.nlnotify_on_addr_add   = 0,  /* by default, only notify when it becomes un-tentative */
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -217,6 +218,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.nlnotify_on_addr_add   = 0,  /* by default, only notify when it becomes un-tentative */
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -641,6 +643,13 @@ out2:
 		ifa = ERR_PTR(err);
 	}
 
+	/* Allow netlink notification of all addresses, regardless of flags. */
+	if (ipv6_devconf.nlnotify_on_addr_add || idev->cnf.nlnotify_on_addr_add) {
+		if (!IS_ERR(ifa)) {
+			ipv6_ifa_notify(RTM_NEWADDR, ifa);
+		}
+	}
+	
 	return ifa;
 out:
 	write_unlock(&addrconf_hash_lock);
@@ -3556,6 +3565,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
 #endif
+	array[DEVCONF_NLNOTIFY_ON_ADDR_ADD] = cnf->nlnotify_on_addr_add;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4094,6 +4104,15 @@ static struct addrconf_sysctl_table
 			.mode		=	0644,
 			.proc_handler	=	&proc_dointvec,
 		},
+		{
+			.ctl_name	=	NET_IPV6_NLNOTIFY_ON_ADDR_ADD,
+			.procname       =       "nlnotify_on_addr_add",
+			.data           =       &ipv6_devconf.nlnotify_on_addr_add,
+			.maxlen         =       sizeof(int),
+			.mode           =       0644,
+			.proc_handler   =       &proc_dointvec,
+
+		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
 			.ctl_name	=	CTL_UNNUMBERED,

--------------040305050702040609040808--
