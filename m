From: Erik Kline <ek@google.com>
Subject: [PATCH net-next v2] ipv6: sysctl to restrict candidate source addresses
Date: Mon,  6 Jul 2015 12:05:44 +0900
Message-ID: <1436151944-21072-1-git-send-email-ek@google.com>
Cc: hannes@stressinduktion.org, lorenzo@google.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Erik Kline <ek@google.com>
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32927 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbGFDF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 23:05:58 -0400
Received: by pacws9 with SMTP id ws9so88923134pac.0
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 20:05:57 -0700 (PDT)
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
 net/ipv6/addrconf.c                    | 30 +++++++++++++++++++++++++-----
 4 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..c3bf04d 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1455,6 +1455,13 @@ router_solicitations - INTEGER
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
index 82806c6..4633c88 100644
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
index 21c2c81..a43687d 100644
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
@@ -1366,7 +1368,8 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 				*score = &scores[0], *hiscore = &scores[1];
 	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
-	int dst_type;
+	struct inet6_dev *idev;
+	int dst_type, use_oif_addr = 0;
 
 	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
@@ -1380,9 +1383,12 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 
 	rcu_read_lock();
 
-	for_each_netdev_rcu(net, dev) {
-		struct inet6_dev *idev;
+	if (dst_dev) {
+		idev = __in6_dev_get(dst_dev);
+		use_oif_addr = (idev) ? idev->cnf.use_oif_addr : 0;
+	}
 
+	for_each_netdev_rcu(net, dev) {
 		/* Candidate Source Address (section 4)
 		 *  - multicast and link-local destination address,
 		 *    the set of candidate source address MUST only
@@ -1394,9 +1400,14 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		 *    include addresses assigned to interfaces
 		 *    belonging to the same site as the outgoing
 		 *    interface.)
+		 *  - "It is RECOMMENDED that the candidate source addresses
+		 *    be the set of unicast addresses assigned to the
+		 *    interface that will be used to send to the destination
+		 *    (the 'outgoing' interface)." (RFC 6724)
 		 */
 		if (((dst_type & IPV6_ADDR_MULTICAST) ||
-		     dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
+		     dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL ||
+		     use_oif_addr) &&
 		    dst.ifindex && dev->ifindex != dst.ifindex)
 			continue;
 
@@ -4586,6 +4597,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 	/* we omit DEVCONF_STABLE_SECRET for now */
+	array[DEVCONF_USE_OIF_ADDR] = cnf->use_oif_addr;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5585,6 +5597,14 @@ static struct addrconf_sysctl_table
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
