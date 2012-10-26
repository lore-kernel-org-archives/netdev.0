From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 4/5] rtnl/ipv4: use netconf msg to advertise forwarding status
Date: Fri, 26 Oct 2012 10:28:52 +0200
Message-ID: <1351240133-4427-5-git-send-email-nicolas.dichtel@6wind.com>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
 <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38320 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab2JZITx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:19:53 -0400
In-Reply-To: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/rtnetlink.h |  2 +
 net/ipv4/devinet.c             | 93 ++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 91 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index a4d75ea..3dee071 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -592,6 +592,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
 	RTNLGRP_DCB,
 #define RTNLGRP_DCB		RTNLGRP_DCB
+	RTNLGRP_IPV4_NETCONF,
+#define RTNLGRP_IPV4_NETCONF	RTNLGRP_IPV4_NETCONF
 	RTNLGRP_IPV6_NETCONF,
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	__RTNLGRP_MAX
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2a6abc1..020fdd2 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -55,6 +55,7 @@
 #include <linux/sysctl.h>
 #endif
 #include <linux/kmod.h>
+#include <linux/netconf.h>
 
 #include <net/arp.h>
 #include <net/ip.h>
@@ -1442,6 +1443,73 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	return 0;
 }
 
+static int inet_netconf_msgsize_devconf(int type)
+{
+	int size = NLMSG_ALIGN(sizeof(struct netconfmsg))
+		   + nla_total_size(4);	/* NETCONFA_IFINDEX */
+
+	if (type == NETCONFA_FORWARDING)
+		size += nla_total_size(4);
+
+	return size;
+}
+
+static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
+				     struct ipv4_devconf *devconf, u32 portid,
+				     u32 seq, int event, unsigned int flags,
+				     int type)
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
+	ncm->ncm_family = AF_INET;
+
+	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
+		goto nla_put_failure;
+
+	if (type == NETCONFA_FORWARDING &&
+	    nla_put_s32(skb, NETCONFA_FORWARDING,
+			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
+					struct ipv4_devconf *devconf)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
+					RTM_NEWNETCONF, 0, type);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV4_NETCONF, NULL, GFP_ATOMIC);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_IPV4_NETCONF, err);
+}
+
 #ifdef CONFIG_SYSCTL
 
 static void devinet_copy_dflt_conf(struct net *net, int i)
@@ -1467,6 +1535,12 @@ static void inet_forward_change(struct net *net)
 
 	IPV4_DEVCONF_ALL(net, ACCEPT_REDIRECTS) = !on;
 	IPV4_DEVCONF_DFLT(net, FORWARDING) = on;
+	inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+				    NETCONFA_IFINDEX_ALL,
+				    net->ipv4.devconf_all);
+	inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+				    NETCONFA_IFINDEX_DEFAULT,
+				    net->ipv4.devconf_dflt);
 
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
@@ -1474,8 +1548,11 @@ static void inet_forward_change(struct net *net)
 			dev_disable_lro(dev);
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
-		if (in_dev)
+		if (in_dev) {
 			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
+			inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						    dev->ifindex, &in_dev->cnf);
+		}
 		rcu_read_unlock();
 	}
 }
@@ -1527,15 +1604,23 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 			}
 			if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING)) {
 				inet_forward_change(net);
-			} else if (*valp) {
+			} else {
 				struct ipv4_devconf *cnf = ctl->extra1;
 				struct in_device *idev =
 					container_of(cnf, struct in_device, cnf);
-				dev_disable_lro(idev->dev);
+				if (*valp)
+					dev_disable_lro(idev->dev);
+				inet_netconf_notify_devconf(net,
+							    NETCONFA_FORWARDING,
+							    idev->dev->ifindex,
+							    cnf);
 			}
 			rtnl_unlock();
 			rt_cache_flush(net);
-		}
+		} else
+			inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+						    NETCONFA_IFINDEX_DEFAULT,
+						    net->ipv4.devconf_dflt);
 	}
 
 	return ret;
-- 
1.7.12
