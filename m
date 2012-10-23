From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 2/3] rtnl/ipv6: use netconf msg to advertise forwarding status
Date: Tue, 23 Oct 2012 11:49:48 +0200
Message-ID: <1350985789-24966-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60967 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab2JWJmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 05:42:07 -0400
In-Reply-To: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h |  2 ++
 net/ipv6/addrconf.c            | 70 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 8372514..20cfaa3 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -590,6 +590,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
 	RTNLGRP_DCB,
 #define RTNLGRP_DCB		RTNLGRP_DCB
+	RTNLGRP_IPV6_NETCONF,
+#define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..f741e99 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -81,6 +81,7 @@
 #include <net/pkt_sched.h>
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
+#include <linux/netconf.h>
 
 #ifdef CONFIG_IPV6_PRIVACY
 #include <linux/random.h>
@@ -460,6 +461,65 @@ static struct inet6_dev *ipv6_find_idev(struct net_device *dev)
 	return idev;
 }
 
+static inline int inet6_netconf_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct netconfmsg))
+	       + nla_total_size(4)	/* NETCONFA_IFINDEX */
+	       + nla_total_size(4);	/* NETCONFA_FORWARDING */
+}
+
+static int inet6_fill_netconf_devconf(struct sk_buff *skb, int ifindex,
+				      struct ipv6_devconf *devconf, u32 portid,
+				      u32 seq, int event, unsigned int flags)
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
+	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
+	if (nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0) {
+		nlmsg_cancel(skb, nlh);
+		return -EMSGSIZE;
+	}
+
+	return nlmsg_end(skb, nlh);
+}
+
+static void inet6_netconf_notify_devconf(struct net *net, int event,
+					 int ifindex,
+					 struct ipv6_devconf *devconf)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(inet6_netconf_msgsize(), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet6_fill_netconf_devconf(skb, ifindex, devconf, 0, 0, event, 0);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize() */
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
@@ -486,6 +546,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 		else
 			addrconf_leave_anycast(ifa);
 	}
+	inet6_netconf_notify_devconf(dev_net(dev), RTM_NEWNETCONF,
+				     dev->ifindex, &idev->cnf);
 }
 
 
@@ -518,6 +580,10 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	*p = newf;
 
 	if (p == &net->ipv6.devconf_dflt->forwarding) {
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
 		rtnl_unlock();
 		return 0;
 	}
@@ -525,6 +591,10 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	if (p == &net->ipv6.devconf_all->forwarding) {
 		net->ipv6.devconf_dflt->forwarding = newf;
 		addrconf_forward_change(net, newf);
+		if ((!newf) ^ (!old))
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_IFINDEX_ALL,
+						     net->ipv6.devconf_all);
 	} else if ((!newf) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
 	rtnl_unlock();
-- 
1.7.12
