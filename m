From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-next 4/4] ipv6: AF_INET6 link address family
Date: Tue, 16 Nov 2010 09:33:57 -0500
Message-ID: <20101116143357.GD26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:47496 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933174Ab0KPOd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 09:33:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 already exposes some address family data via netlink in the
IFLA_PROTINFO attribute if RTM_GETLINK request is sent with the
address family set to AF_INET6. We take over this format and
reuse all the code.

Signed-off-by: Thomas Graf <tgraf@infradead.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: net-next-2.6/net/ipv6/addrconf.c
===================================================================
--- net-next-2.6.orig/net/ipv6/addrconf.c
+++ net-next-2.6/net/ipv6/addrconf.c
@@ -3831,6 +3831,15 @@ static inline void ipv6_store_devconf(st
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
 }
 
+static inline size_t inet6_ifla6_size(void)
+{
+	return nla_total_size(4) /* IFLA_INET6_FLAGS */
+	     + nla_total_size(sizeof(struct ifla_cacheinfo))
+	     + nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
+	     + nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
+	     + nla_total_size(ICMP6_MIB_MAX * 8); /* IFLA_INET6_ICMP6STATS */
+}
+
 static inline size_t inet6_if_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -3838,13 +3847,7 @@ static inline size_t inet6_if_nlmsg_size
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
-	       + nla_total_size( /* IFLA_PROTINFO */
-			nla_total_size(4) /* IFLA_INET6_FLAGS */
-			+ nla_total_size(sizeof(struct ifla_cacheinfo))
-			+ nla_total_size(DEVCONF_MAX * 4) /* IFLA_INET6_CONF */
-			+ nla_total_size(IPSTATS_MIB_MAX * 8) /* IFLA_INET6_STATS */
-			+ nla_total_size(ICMP6_MIB_MAX * 8) /* IFLA_INET6_ICMP6STATS */
-		 );
+	       + nla_total_size(inet6_ifla6_size()); /* IFLA_PROTINFO */
 }
 
 static inline void __snmp6_fill_stats(u64 *stats, void __percpu **mib,
@@ -3891,15 +3894,76 @@ static void snmp6_fill_stats(u64 *stats,
 	}
 }
 
+static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
+{
+	struct nlattr *nla;
+	struct ifla_cacheinfo ci;
+
+	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
+
+	ci.max_reasm_len = IPV6_MAXPLEN;
+	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
+		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
+	ci.reachable_time = idev->nd_parms->reachable_time;
+	ci.retrans_time = idev->nd_parms->retrans_time;
+	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
+
+	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
+	if (nla == NULL)
+		goto nla_put_failure;
+	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
+
+	/* XXX - MC not implemented */
+
+	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
+	if (nla == NULL)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
+
+	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
+	if (nla == NULL)
+		goto nla_put_failure;
+	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static size_t inet6_get_link_af_size(const struct net_device *dev)
+{
+	if (!__in6_dev_get(dev))
+		return 0;
+
+	return inet6_ifla6_size();
+}
+
+static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct inet6_dev *idev = __in6_dev_get(dev);
+
+	if (!idev)
+		return -ENODATA;
+
+	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int inet6_parse_link_af(struct net_device *dev, const struct nlattr *nla)
+{
+	return -EOPNOTSUPP;
+}
+
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 			     u32 pid, u32 seq, int event, unsigned int flags)
 {
 	struct net_device *dev = idev->dev;
-	struct nlattr *nla;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
 	void *protoinfo;
-	struct ifla_cacheinfo ci;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
 	if (nlh == NULL)
@@ -3926,31 +3990,8 @@ static int inet6_fill_ifinfo(struct sk_b
 	if (protoinfo == NULL)
 		goto nla_put_failure;
 
-	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
-
-	ci.max_reasm_len = IPV6_MAXPLEN;
-	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
-		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	ci.reachable_time = idev->nd_parms->reachable_time;
-	ci.retrans_time = idev->nd_parms->retrans_time;
-	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
-
-	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
-	if (nla == NULL)
+	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
 		goto nla_put_failure;
-	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
-
-	/* XXX - MC not implemented */
-
-	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
-	if (nla == NULL)
-		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
-
-	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
-	if (nla == NULL)
-		goto nla_put_failure;
-	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
 	nla_nest_end(skb, protoinfo);
 	return nlmsg_end(skb, nlh);
@@ -4621,6 +4662,13 @@ int unregister_inet6addr_notifier(struct
 }
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
+static struct rtnl_af_ops inet6_ops = {
+	.family		  = AF_INET6,
+	.fill_link_af	  = inet6_fill_link_af,
+	.get_link_af_size = inet6_get_link_af_size,
+	.parse_link_af	  = inet6_parse_link_af,
+};
+
 /*
  *	Init / cleanup code
  */
@@ -4672,6 +4720,10 @@ int __init addrconf_init(void)
 
 	addrconf_verify(0);
 
+	err = rtnl_af_register(&inet6_ops);
+	if (err < 0)
+		goto errout_af;
+
 	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo);
 	if (err < 0)
 		goto errout;
@@ -4687,6 +4739,8 @@ int __init addrconf_init(void)
 
 	return 0;
 errout:
+	rtnl_af_unregister(&inet6_ops);
+errout_af:
 	unregister_netdevice_notifier(&ipv6_dev_notf);
 errlo:
 	unregister_pernet_subsys(&addrconf_ops);
@@ -4707,6 +4761,8 @@ void addrconf_cleanup(void)
 
 	rtnl_lock();
 
+	__rtnl_af_unregister(&inet6_ops);
+
 	/* clean dev list */
 	for_each_netdev(&init_net, dev) {
 		if (__in6_dev_get(dev) == NULL)
