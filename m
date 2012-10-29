From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/1] rtnl/ipv4: use netconf msg to advertise rp_filter status
Date: Mon, 29 Oct 2012 15:53:27 +0100
Message-ID: <1351522407-3953-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41645 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754029Ab2J2OoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 10:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/netconf.h |  1 +
 net/ipv4/devinet.c           | 24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
index d051372..75dcbc5 100644
--- a/include/uapi/linux/netconf.h
+++ b/include/uapi/linux/netconf.h
@@ -12,6 +12,7 @@ enum {
 	NETCONFA_UNSPEC,
 	NETCONFA_IFINDEX,
 	NETCONFA_FORWARDING,
+	NETCONFA_RP_FILTER,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f8b1e04..f6db227 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1451,6 +1451,8 @@ static int inet_netconf_msgsize_devconf(int type)
 	/* type -1 is used for ALL */
 	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
+	if (type == -1 || type == NETCONFA_RP_FILTER)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -1479,6 +1481,10 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	    nla_put_s32(skb, NETCONFA_FORWARDING,
 			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
 		goto nla_put_failure;
+	if ((type == -1 || type == NETCONFA_RP_FILTER) &&
+	    nla_put_s32(skb, NETCONFA_RP_FILTER,
+			IPV4_DEVCONF(*devconf, RP_FILTER)) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -1515,6 +1521,7 @@ errout:
 static const struct nla_policy devconf_ipv4_policy[NETCONFA_MAX+1] = {
 	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
+	[NETCONFA_RP_FILTER]	= { .len = sizeof(int) },
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
@@ -1647,6 +1654,23 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 		    i == IPV4_DEVCONF_ROUTE_LOCALNET - 1)
 			if ((new_value == 0) && (old_value != 0))
 				rt_cache_flush(net);
+		if (i == IPV4_DEVCONF_RP_FILTER - 1 &&
+		    new_value != old_value) {
+			int ifindex;
+
+			if (cnf == net->ipv4.devconf_dflt)
+				ifindex = NETCONFA_IFINDEX_DEFAULT;
+			else if (cnf == net->ipv4.devconf_all)
+				ifindex = NETCONFA_IFINDEX_ALL;
+			else {
+				struct in_device *idev =
+					container_of(cnf, struct in_device,
+						     cnf);
+				ifindex = idev->dev->ifindex;
+			}
+			inet_netconf_notify_devconf(net, NETCONFA_RP_FILTER,
+						    ifindex, cnf);
+		}
 	}
 
 	return ret;
-- 
1.7.12
