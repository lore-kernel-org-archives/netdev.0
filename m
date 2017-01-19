From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Subject: [PATCH v3 net-next 1/2] net/ipv6: allow sysctl to change link-local address generation mode
Date: Fri, 20 Jan 2017 11:46:19 +1300
Message-ID: <20170119224619.18656-1-felix.jia@alliedtelesis.co.nz>
Cc: Felix Jia <felix.jia@alliedtelesis.co.nz>,
        Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:39861 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752152AbdASWr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:47:28 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id ABC74806A8
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 11:46:55 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The address generation mode for IPv6 link-local can only be configured
by netlink messages. This patch adds the ability to change the address
generation mode via sysctl.

v1 -> v2
Removed the rtnl lock and switch to use RCU lock to iterate through
the netdev list.

v2 -> v3
Removed the addrgenmode variable from the idev structure and use the 
systcl storage for the flag.

Simplifed the logic for sysctl handling by removing the supported 
for all operation.

Added support for more types of tunnel interfaces for link-local 
address generation.

Based the patches from net-next.


Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>
---
 include/linux/ipv6.h      |   3 +-
 include/net/if_inet6.h    |   5 +--
 include/uapi/linux/ipv6.h |   5 ++-
 net/ipv6/addrconf.c       | 104 +++++++++++++++++++++++++++++++++++++---------
 4 files changed, 91 insertions(+), 26 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 671d014e6429..74d0e0913211 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -69,6 +69,7 @@ struct ipv6_devconf {
 	__s32		seg6_require_hmac;
 #endif
 	__u32		enhanced_dad;
+	__u32		addr_gen_mode;
 
 	struct ctl_table_header *sysctl_header;
 };
@@ -99,7 +100,7 @@ static inline struct ipv6hdr *ipipv6_hdr(const struct sk_buff *skb)
 	return (struct ipv6hdr *)skb_transport_header(skb);
 }
 
-/* 
+/*
    This structure contains results of exthdrs parsing
    as offsets from skb->nh.
  */
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 0fa4c324b713..48e2a34a6ed3 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -1,9 +1,9 @@
 /*
  *	inet6 interface/address list definitions
- *	Linux INET6 implementation 
+ *	Linux INET6 implementation
  *
  *	Authors:
- *	Pedro Roque		<roque@di.fc.ul.pt>	
+ *	Pedro Roque		<roque@di.fc.ul.pt>
  *
  *
  *	This program is free software; you can redistribute it and/or
@@ -205,7 +205,6 @@ struct inet6_dev {
 	__s32			rs_interval;	/* in jiffies */
 	__u8			rs_probes;
 
-	__u8			addr_gen_mode;
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
 	struct rcu_head		rcu;
 };
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index eaf65dc82e22..7207b9275c28 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -33,7 +33,7 @@ struct ip6_mtuinfo {
 struct in6_ifreq {
 	struct in6_addr	ifr6_addr;
 	__u32		ifr6_prefixlen;
-	int		ifr6_ifindex; 
+	int		ifr6_ifindex;
 };
 
 #define IPV6_SRCRT_STRICT	0x01	/* Deprecated; will be removed */
@@ -60,7 +60,7 @@ struct ipv6_rt_hdr {
 struct ipv6_opt_hdr {
 	__u8 		nexthdr;
 	__u8 		hdrlen;
-	/* 
+	/*
 	 * TLV encoded option data follows.
 	 */
 } __attribute__((packed));	/* required for some archs */
@@ -182,6 +182,7 @@ enum {
 	DEVCONF_SEG6_ENABLED,
 	DEVCONF_SEG6_REQUIRE_HMAC,
 	DEVCONF_ENHANCED_DAD,
+	DEVCONF_ADDR_GEN_MODE,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ac9bd5620f81..e35259dd17ba 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -243,6 +243,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.seg6_require_hmac	= 0,
 #endif
 	.enhanced_dad           = 1,
+	.addr_gen_mode		= IN6_ADDR_GEN_MODE_EUI64,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -294,6 +295,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.seg6_require_hmac	= 0,
 #endif
 	.enhanced_dad           = 1,
+	.addr_gen_mode		= IN6_ADDR_GEN_MODE_EUI64,
 };
 
 /* Check if a valid qdisc is available */
@@ -386,9 +388,9 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
 
 	if (ndev->cnf.stable_secret.initialized)
-		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+		ndev->cnf.addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	else
-		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_EUI64;
+		ndev->cnf.addr_gen_mode = ipv6_devconf_dflt.addr_gen_mode;
 
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
@@ -2387,8 +2389,8 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 
 static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
 {
-	return idev->addr_gen_mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
-	       idev->addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
+	return idev->cnf.addr_gen_mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
+	       idev->cnf.addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
 }
 
 int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
@@ -3152,7 +3154,7 @@ static void addrconf_addr_gen(struct inet6_dev *idev, bool prefix_route)
 
 	ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
 
-	switch (idev->addr_gen_mode) {
+	switch (idev->cnf.addr_gen_mode) {
 	case IN6_ADDR_GEN_MODE_RANDOM:
 		ipv6_gen_mode_random_init(idev);
 		/* fallthrough */
@@ -3204,8 +3206,8 @@ static void addrconf_dev_config(struct net_device *dev)
 
 	/* this device type has no EUI support */
 	if (dev->type == ARPHRD_NONE &&
-	    idev->addr_gen_mode == IN6_ADDR_GEN_MODE_EUI64)
-		idev->addr_gen_mode = IN6_ADDR_GEN_MODE_RANDOM;
+	    idev->cnf.addr_gen_mode == IN6_ADDR_GEN_MODE_EUI64)
+		idev->cnf.addr_gen_mode = IN6_ADDR_GEN_MODE_RANDOM;
 
 	addrconf_addr_gen(idev, false);
 }
@@ -4982,6 +4984,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_SEG6_REQUIRE_HMAC] = cnf->seg6_require_hmac;
 #endif
 	array[DEVCONF_ENHANCED_DAD] = cnf->enhanced_dad;
+	array[DEVCONF_ADDR_GEN_MODE] = cnf->addr_gen_mode;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5093,7 +5096,7 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev,
 	if (!nla)
 		goto nla_put_failure;
 
-	if (nla_put_u8(skb, IFLA_INET6_ADDR_GEN_MODE, idev->addr_gen_mode))
+	if (nla_put_u8(skb, IFLA_INET6_ADDR_GEN_MODE, idev->cnf.addr_gen_mode))
 		goto nla_put_failure;
 
 	read_lock_bh(&idev->lock);
@@ -5211,6 +5214,26 @@ static int inet6_validate_link_af(const struct net_device *dev,
 	return nla_parse_nested(tb, IFLA_INET6_MAX, nla, inet6_af_policy);
 }
 
+static int check_addr_gen_mode(int mode)
+{
+	if (mode != IN6_ADDR_GEN_MODE_EUI64 &&
+	    mode != IN6_ADDR_GEN_MODE_NONE &&
+	    mode != IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+	    mode != IN6_ADDR_GEN_MODE_RANDOM)
+		return -EINVAL;
+	return 1;
+}
+
+static int check_stable_privacy(struct inet6_dev *idev, struct net *net,
+				int mode)
+{
+	if (mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
+	    !idev->cnf.stable_secret.initialized &&
+	    !net->ipv6.devconf_dflt->stable_secret.initialized)
+		return -EINVAL;
+	return 1;
+}
+
 static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
 {
 	int err = -EINVAL;
@@ -5232,18 +5255,11 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
 		u8 mode = nla_get_u8(tb[IFLA_INET6_ADDR_GEN_MODE]);
 
-		if (mode != IN6_ADDR_GEN_MODE_EUI64 &&
-		    mode != IN6_ADDR_GEN_MODE_NONE &&
-		    mode != IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
-		    mode != IN6_ADDR_GEN_MODE_RANDOM)
-			return -EINVAL;
-
-		if (mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY &&
-		    !idev->cnf.stable_secret.initialized &&
-		    !dev_net(dev)->ipv6.devconf_dflt->stable_secret.initialized)
+		if (check_addr_gen_mode(mode) < 0 ||
+		    check_stable_privacy(idev, dev_net(dev), mode) < 0)
 			return -EINVAL;
 
-		idev->addr_gen_mode = mode;
+		idev->cnf.addr_gen_mode = mode;
 		err = 0;
 	}
 
@@ -5652,6 +5668,47 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int addrconf_sysctl_addr_gen_mode(struct ctl_table *ctl, int write,
+					 void __user *buffer, size_t *lenp,
+					 loff_t *ppos)
+{
+	int ret = 0;
+	int new_val;
+	struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
+	struct net *net = (struct net *)ctl->extra2;
+
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write) {
+		new_val = *((int *)ctl->data);
+
+		if (check_addr_gen_mode(new_val) < 0)
+			return -EINVAL;
+
+		/* request for default */
+		if (&net->ipv6.devconf_dflt->addr_gen_mode == ctl->data) {
+			ipv6_devconf_dflt.addr_gen_mode = new_val;
+
+		/* request for individual net device */
+		} else {
+			if (!idev)
+				return ret;
+
+			if (check_stable_privacy(idev, net, new_val) < 0)
+				return -EINVAL;
+
+			if (idev->cnf.addr_gen_mode != new_val) {
+				idev->cnf.addr_gen_mode = new_val;
+				rtnl_lock();
+				addrconf_dev_config(idev->dev);
+				rtnl_unlock();
+			}
+		}
+	}
+
+	return ret;
+}
+
 static int addrconf_sysctl_stable_secret(struct ctl_table *ctl, int write,
 					 void __user *buffer, size_t *lenp,
 					 loff_t *ppos)
@@ -5702,14 +5759,14 @@ static int addrconf_sysctl_stable_secret(struct ctl_table *ctl, int write,
 			struct inet6_dev *idev = __in6_dev_get(dev);
 
 			if (idev) {
-				idev->addr_gen_mode =
+				idev->cnf.addr_gen_mode =
 					IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 			}
 		}
 	} else {
 		struct inet6_dev *idev = ctl->extra1;
 
-		idev->addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
+		idev->cnf.addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	}
 
 out:
@@ -6097,6 +6154,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler   = proc_dointvec,
 	},
 	{
+		.procname		= "addr_gen_mode",
+		.data			= &ipv6_devconf.addr_gen_mode,
+		.maxlen			= sizeof(int),
+		.mode			= 0644,
+		.proc_handler	= addrconf_sysctl_addr_gen_mode,
+	},
+	{
 		/* sentinel */
 	}
 };
-- 
2.11.0
