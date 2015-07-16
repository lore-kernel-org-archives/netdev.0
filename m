From: Erik Kline <ek@google.com>
Subject: [PATCH net-next v3] ipv6: sysctl to restrict candidate source addresses
Date: Thu, 16 Jul 2015 17:10:36 +0900
Message-ID: <1437034236-11305-1-git-send-email-ek@google.com>
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Erik Kline <ek@google.com>
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36454 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbGPIK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:10:59 -0400
Received: by pachj5 with SMTP id hj5so38897587pac.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:10:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per RFC 6724, section 4, "Candidate Source Addresses":

    It is RECOMMENDED that the candidate source addresses be the set
    of unicast addresses assigned to the interface that will be used
    to send to the destination (the "outgoing" interface).

Add a sysctl to enable this behaviour.

Signed-off-by: Erik Kline <ek@google.com>
---
 Documentation/networking/ip-sysctl.txt |  7 +++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 22 +++++++++++++++++++---
 4 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f63aeef..27007c5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1460,6 +1460,13 @@ router_solicitations - INTEGER
 	routers are present.
 	Default: 3
 
+use_oif_addr - BOOLEAN
+	When enabled, the candidate source addresses for destinations
+	routed via this interface are restricted to the set of addresses
+	configured on this interface (vis. RFC 6724, section 4).
+
+	Default: false
+
 use_tempaddr - INTEGER
 	Preference for Privacy Extensions (RFC3041).
 	  <= 0 : disable Privacy Extensions
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 1319a6b..190b22b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -57,6 +57,7 @@ struct ipv6_devconf {
 		bool initialized;
 		struct in6_addr secret;
 	} stable_secret;
+	__s32		use_oif_addr;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5efa54a..cf9d65a 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,7 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	DEVCONF_USE_OIF_ADDR,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4c9a024..a7c49bb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -211,7 +211,8 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_ra_mtu		= 1,
 	.stable_secret		= {
 		.initialized = false,
-	}
+	},
+	.use_oif_addr		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -253,6 +254,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.stable_secret		= {
 		.initialized = false,
 	},
+	.use_oif_addr		= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -1474,11 +1476,16 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	 *    include addresses assigned to interfaces
 	 *    belonging to the same site as the outgoing
 	 *    interface.)
+	 *  - "It is RECOMMENDED that the candidate source addresses
+	 *    be the set of unicast addresses assigned to the
+	 *    interface that will be used to send to the destination
+	 *    (the 'outgoing' interface)." (RFC 6724)
 	 */
 	if (dst_dev) {
+		idev = __in6_dev_get(dst_dev);
 		if ((dst_type & IPV6_ADDR_MULTICAST) ||
-		    dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) {
-			idev = __in6_dev_get(dst_dev);
+		    dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL ||
+		    (idev && idev->cnf.use_oif_addr)) {
 			use_oif_addr = true;
 		}
 	}
@@ -4609,6 +4616,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 	/* we omit DEVCONF_STABLE_SECRET for now */
+	array[DEVCONF_USE_OIF_ADDR] = cnf->use_oif_addr;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5608,6 +5616,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= addrconf_sysctl_stable_secret,
 		},
 		{
+			.procname       = "use_oif_addr",
+			.data           = &ipv6_devconf.use_oif_addr,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec,
+
+		},
+		{
 			/* sentinel */
 		}
 	},
-- 
2.4.3.573.g4eafbef
