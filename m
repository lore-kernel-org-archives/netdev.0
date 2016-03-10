From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] netconf: add macro to represent all attributes
Date: Thu, 10 Mar 2016 08:55:50 +0000
Message-ID: <1457600150-2903-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:4520 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935184AbcCJIwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 03:52:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds macro NETCONFA_ALL to represent all type of netconf
attributes for IPv4 and IPv6.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 include/uapi/linux/netconf.h |  1 +
 net/ipv4/devinet.c           | 40 +++++++++++++++++++++++-----------------
 net/ipv6/addrconf.c          | 36 +++++++++++++++++++++---------------
 3 files changed, 45 insertions(+), 32 deletions(-)

diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
index 23cbd34..45dfad5 100644
--- a/include/uapi/linux/netconf.h
+++ b/include/uapi/linux/netconf.h
@@ -19,6 +19,7 @@ enum {
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
+#define NETCONFA_ALL	-1
 
 #define NETCONFA_IFINDEX_ALL		-1
 #define NETCONFA_IFINDEX_DEFAULT	-2
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8c3df2c..65e76a4 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1753,17 +1753,20 @@ static int inet_netconf_msgsize_devconf(int type)
 {
 	int size = NLMSG_ALIGN(sizeof(struct netconfmsg))
 		   + nla_total_size(4);	/* NETCONFA_IFINDEX */
+	bool all = false;
 
-	/* type -1 is used for ALL */
-	if (type == -1 || type == NETCONFA_FORWARDING)
+	if (type == NETCONFA_ALL)
+		all = true;
+
+	if (all || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
-	if (type == -1 || type == NETCONFA_RP_FILTER)
+	if (all || type == NETCONFA_RP_FILTER)
 		size += nla_total_size(4);
-	if (type == -1 || type == NETCONFA_MC_FORWARDING)
+	if (all || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
-	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
+	if (all || type == NETCONFA_PROXY_NEIGH)
 		size += nla_total_size(4);
-	if (type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
+	if (all || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
 		size += nla_total_size(4);
 
 	return size;
@@ -1776,36 +1779,39 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 {
 	struct nlmsghdr  *nlh;
 	struct netconfmsg *ncm;
+	bool all = false;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
 			flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
+	if (type == NETCONFA_ALL)
+		all = true;
+
 	ncm = nlmsg_data(nlh);
 	ncm->ncm_family = AF_INET;
 
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
-	/* type -1 is used for ALL */
-	if ((type == -1 || type == NETCONFA_FORWARDING) &&
+	if ((all || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING,
 			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_RP_FILTER) &&
+	if ((all || type == NETCONFA_RP_FILTER) &&
 	    nla_put_s32(skb, NETCONFA_RP_FILTER,
 			IPV4_DEVCONF(*devconf, RP_FILTER)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	if ((all || type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_PROXY_NEIGH) &&
+	if ((all || type == NETCONFA_PROXY_NEIGH) &&
 	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH,
 			IPV4_DEVCONF(*devconf, PROXY_ARP)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
+	if ((all || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
 	    nla_put_s32(skb, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 			IPV4_DEVCONF(*devconf, IGNORE_ROUTES_WITH_LINKDOWN)) < 0)
 		goto nla_put_failure;
@@ -1893,14 +1899,14 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 	}
 
 	err = -ENOBUFS;
-	skb = nlmsg_new(inet_netconf_msgsize_devconf(-1), GFP_ATOMIC);
+	skb = nlmsg_new(inet_netconf_msgsize_devconf(NETCONFA_ALL), GFP_ATOMIC);
 	if (!skb)
 		goto errout;
 
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf,
 					NETLINK_CB(in_skb).portid,
 					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
-					-1);
+					NETCONFA_ALL);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -1944,7 +1950,7 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 						      cb->nlh->nlmsg_seq,
 						      RTM_NEWNETCONF,
 						      NLM_F_MULTI,
-						      -1) < 0) {
+						      NETCONFA_ALL) < 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -1960,7 +1966,7 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) < 0)
+					      NETCONFA_ALL) < 0)
 			goto done;
 		else
 			h++;
@@ -1971,7 +1977,7 @@ cont:
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWNETCONF, NLM_F_MULTI,
-					      -1) < 0)
+					      NETCONFA_ALL) < 0)
 			goto done;
 		else
 			h++;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c0dab2..27aed1a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -473,18 +473,21 @@ static int inet6_netconf_msgsize_devconf(int type)
 {
 	int size =  NLMSG_ALIGN(sizeof(struct netconfmsg))
 		    + nla_total_size(4);	/* NETCONFA_IFINDEX */
+	bool all = false;
 
-	/* type -1 is used for ALL */
-	if (type == -1 || type == NETCONFA_FORWARDING)
+	if (type == NETCONFA_ALL)
+		all = true;
+
+	if (all || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
 #ifdef CONFIG_IPV6_MROUTE
-	if (type == -1 || type == NETCONFA_MC_FORWARDING)
+	if (all || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
 #endif
-	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
+	if (all || type == NETCONFA_PROXY_NEIGH)
 		size += nla_total_size(4);
 
-	if (type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
+	if (all || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
 		size += nla_total_size(4);
 
 	return size;
@@ -497,33 +500,36 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 {
 	struct nlmsghdr  *nlh;
 	struct netconfmsg *ncm;
+	bool all = false;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
 			flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
+	if (type == NETCONFA_ALL)
+		all = true;
+
 	ncm = nlmsg_data(nlh);
 	ncm->ncm_family = AF_INET6;
 
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
-	/* type -1 is used for ALL */
-	if ((type == -1 || type == NETCONFA_FORWARDING) &&
+	if ((all || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_IPV6_MROUTE
-	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	if ((all || type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			devconf->mc_forwarding) < 0)
 		goto nla_put_failure;
 #endif
-	if ((type == -1 || type == NETCONFA_PROXY_NEIGH) &&
+	if ((all || type == NETCONFA_PROXY_NEIGH) &&
 	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH, devconf->proxy_ndp) < 0)
 		goto nla_put_failure;
 
-	if ((type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
+	if ((all || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
 	    nla_put_s32(skb, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 			devconf->ignore_routes_with_linkdown) < 0)
 		goto nla_put_failure;
@@ -609,14 +615,14 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	}
 
 	err = -ENOBUFS;
-	skb = nlmsg_new(inet6_netconf_msgsize_devconf(-1), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_netconf_msgsize_devconf(NETCONFA_ALL), GFP_ATOMIC);
 	if (!skb)
 		goto errout;
 
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf,
 					 NETLINK_CB(in_skb).portid,
 					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
-					 -1);
+					 NETCONFA_ALL);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -660,7 +666,7 @@ static int inet6_netconf_dump_devconf(struct sk_buff *skb,
 						       cb->nlh->nlmsg_seq,
 						       RTM_NEWNETCONF,
 						       NLM_F_MULTI,
-						       -1) < 0) {
+						       NETCONFA_ALL) < 0) {
 				rcu_read_unlock();
 				goto done;
 			}
@@ -676,7 +682,7 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) < 0)
+					       NETCONFA_ALL) < 0)
 			goto done;
 		else
 			h++;
@@ -687,7 +693,7 @@ cont:
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq,
 					       RTM_NEWNETCONF, NLM_F_MULTI,
-					       -1) < 0)
+					       NETCONFA_ALL) < 0)
 			goto done;
 		else
 			h++;
-- 
1.8.3.1
