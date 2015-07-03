From: Erik Kline <ek@google.com>
Subject: [PATCH net-next] ipv6: sysctl to restrict candidate source addresses
Date: Fri,  3 Jul 2015 13:49:01 +0900
Message-ID: <1435898941-9259-1-git-send-email-ek@google.com>
Cc: lorenzo@google.com, netdev@vger.kernel.org, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com, Erik Kline <ek@google.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36629 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbbGCEtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 00:49:14 -0400
Received: by paceq1 with SMTP id eq1so51038209pac.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 21:49:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per RFC 6724, section 4, "Candidate Source Addresses":

    It is RECOMMENDED that the candidate source addresses be the set
    of unicast addresses assigned to the interface that will be used
    to send to the destination (the "outgoing" interface).

Add a sysctl to enable this behaviour.

Signed-off-by: Erik Kline <ek@google.com>
---
 Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
 include/linux/ipv6.h                   |  1 +
 include/uapi/linux/ipv6.h              |  1 +
 net/ipv6/addrconf.c                    | 30 +++++++++++++++++++++++++-----
 4 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..d8f3e60 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1435,6 +1435,18 @@ mtu - INTEGER
 	Default Maximum Transfer Unit
 	Default: 1280 (IPv6 required minimum)
 
+restrict_srcaddr - INTEGER
+	Restrict candidate source addresses (vis. RFC 6724, section 4).
+
+	When set to 1, the candidate source addresses for destinations
+	routed via this interface are restricted to the set of addresses
+	configured on this interface.
+
+	Possible values are:
+		0 : no source address restrictions
+		1 : require matching outgoing interface
+	Default:  0
+
 router_probe_interval - INTEGER
 	Minimum interval (in seconds) between Router Probing described
 	in RFC4191.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 82806c6..6867d1f 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -57,6 +57,7 @@ struct ipv6_devconf {
 		bool initialized;
 		struct in6_addr secret;
 	} stable_secret;
+	__s32		restrict_srcaddr;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 5efa54a..b174758 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -171,6 +171,7 @@ enum {
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_STABLE_SECRET,
+	DEVCONF_RESTRICT_SRCADDR,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..f72c974 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -211,7 +211,8 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_ra_mtu		= 1,
 	.stable_secret		= {
 		.initialized = false,
-	}
+	},
+	.restrict_srcaddr	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -253,6 +254,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.stable_secret		= {
 		.initialized = false,
 	},
+	.restrict_srcaddr	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -1366,7 +1368,8 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 				*score = &scores[0], *hiscore = &scores[1];
 	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
-	int dst_type;
+	struct inet6_dev *idev;
+	int dst_type, restrict_srcaddr = 0;
 
 	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
@@ -1380,9 +1383,12 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 
 	rcu_read_lock();
 
-	for_each_netdev_rcu(net, dev) {
-		struct inet6_dev *idev;
+	if (dst_dev) {
+		idev = __in6_dev_get(dst_dev);
+		restrict_srcaddr = (idev) ? idev->cnf.restrict_srcaddr : 0;
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
+		     restrict_srcaddr) &&
 		    dst.ifindex && dev->ifindex != dst.ifindex)
 			continue;
 
@@ -4586,6 +4597,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
 	/* we omit DEVCONF_STABLE_SECRET for now */
+	array[DEVCONF_RESTRICT_SRCADDR] = cnf->restrict_srcaddr;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5585,6 +5597,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= addrconf_sysctl_stable_secret,
 		},
 		{
+			.procname       = "restrict_srcaddr",
+			.data           = &ipv6_devconf.restrict_srcaddr,
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
