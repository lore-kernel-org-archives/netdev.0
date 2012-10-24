From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next v2 2/5] rtnl/ipv6: use netconf msg to advertise forwarding status
Date: Wed, 24 Oct 2012 18:02:56 +0200
Message-ID: <1351094579-3911-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20121023.132940.1732325493436273627.davem@davemloft.net>
 <1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35371 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757599Ab2JXPys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 11:54:48 -0400
In-Reply-To: <1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h |  2 ++
 net/ipv6/addrconf.c            | 77 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 0043b41..a4d75ea 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -592,6 +592,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
 	RTNLGRP_DCB,
 #define RTNLGRP_DCB		RTNLGRP_DCB
+	RTNLGRP_IPV6_NETCONF,
+#define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..9bf4d1b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -81,6 +81,7 @@
 #include <net/pkt_sched.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
+#include <linux/netconf.h>
 
 #ifdef CONFIG_IPV6_PRIVACY
 #include <linux/random.h>
@@ -460,6 +461,72 @@ static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
 	return idev;
 }
 
+static inline int inet6_netconf_msgsize_devconf(int type)
+{
+	int size =  NLMSG_ALIGN(sizeof(struct netconfmsg))
+		    + nla_total_size(4);	/* NETCONFA_IFINDEX */
+
+	if (type == NETCONFA_FORWARDING)
+		size += nla_total_size(4);
+
+	return size;
+}
+
+static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
+				      struct ipv6_devconf *devconf, u32 portid,
+				      u32 seq, int event, unsigned int flags,
+				      int type)
+{
+	struct nlmsghdr  *nlh;
+	struct netconfmsg *ncm;
+
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
+			flags);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	ncm = nlmsg_data(nlh);
+	ncm->ncm_family = AF_INET6;
+
+	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
+		goto nla_put_failure;
+
+	if (type == NETCONFA_FORWARDING &&
+	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
+					 struct ipv6_devconf *devconf)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
+					 RTM_NEWNETCONF, 0, type);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_NETCONF, NULL, GFP_ATOMIC);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_NETCONF, err);
+}
+
 #ifdef CONFIG_SYSCTL
 static void dev_forward_change(struct inet6_dev *idev)
 {
@@ -486,6 +553,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 		else
 			addrconf_leave_anycast(ifa);
 	}
+	inet6_netconf_notify_devconf(dev_net(dev), NETCONFA_FORWARDING,
+				     dev->ifindex, &idev->cnf);
 }
 
 
@@ -518,6 +587,10 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	*p = newf;
 
 	if (p == &net->ipv6.devconf_dflt->forwarding) {
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
 		rtnl_unlock();
 		return 0;
 	}
@@ -525,6 +598,10 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		net->ipv6.devconf_dflt->forwarding = newf;
 		addrconf_forward_change(net, newf);
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						     NETCONFA_IFINDEX_ALL,
+						     net->ipv6.devconf_all);
 	} else if ((!newf) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
 	rtnl_unlock();
-- 
1.7.12
