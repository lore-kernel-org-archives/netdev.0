From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netconf: add proxy-arp support
Date: Thu, 12 Dec 2013 13:06:50 -0800
Message-ID: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:42358 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab3LLVGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:06:53 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so1179371pde.6
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 13:06:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to netconf to show changes to proxy-arp status on a per
interface basis via netlink in a manner similar to forwarding
and reverse path state.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/uapi/linux/netconf.h |    1 +
 net/ipv4/devinet.c           |   43 ++++++++++++++++++++++++++++++------------
 2 files changed, 32 insertions(+), 12 deletions(-)

--- a/include/uapi/linux/netconf.h	2013-10-06 14:48:24.000000000 -0700
+++ b/include/uapi/linux/netconf.h	2013-12-12 11:51:02.511276843 -0800
@@ -14,6 +14,7 @@ enum {
 	NETCONFA_FORWARDING,
 	NETCONFA_RP_FILTER,
 	NETCONFA_MC_FORWARDING,
+	NETCONFA_PROXY_ARP,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
--- a/net/ipv4/devinet.c	2013-12-12 08:46:52.000000000 -0800
+++ b/net/ipv4/devinet.c	2013-12-12 11:53:56.012574736 -0800
@@ -1696,6 +1696,8 @@ static int inet_netconf_msgsize_devconf(
 		size += nla_total_size(4);
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
+	if (type == -1 || type == NETCONFA_PROXY_ARP)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -1732,6 +1734,10 @@ static int inet_netconf_fill_devconf(str
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
 		goto nla_put_failure;
+	if ((type == -1 || type == NETCONFA_PROXY_ARP) &&
+	    nla_put_s32(skb, NETCONFA_PROXY_ARP,
+			IPV4_DEVCONF(*devconf, PROXY_ARP)) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -1769,6 +1775,7 @@ static const struct nla_policy devconf_i
 	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
 	[NETCONFA_RP_FILTER]	= { .len = sizeof(int) },
+	[NETCONFA_PROXY_ARP]	= { .len = sizeof(int) },
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
@@ -1950,6 +1957,19 @@ static void inet_forward_change(struct n
 	}
 }
 
+static int devinet_conf_ifindex(struct net *net, struct ipv4_devconf *cnf)
+{
+	if (cnf == net->ipv4.devconf_dflt)
+		return NETCONFA_IFINDEX_DEFAULT;
+	else if (cnf == net->ipv4.devconf_all)
+		return NETCONFA_IFINDEX_ALL;
+	else {
+		struct in_device *idev
+			= container_of(cnf, struct in_device, cnf);
+		return idev->dev->ifindex;
+	}
+}
+
 static int devinet_conf_proc(struct ctl_table *ctl, int write,
 			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
@@ -1962,6 +1982,7 @@ static int devinet_conf_proc(struct ctl_
 		struct ipv4_devconf *cnf = ctl->extra1;
 		struct net *net = ctl->extra2;
 		int i = (int *)ctl->data - cnf->data;
+		int ifindex;
 
 		set_bit(i, cnf->state);
 
@@ -1971,23 +1992,19 @@ static int devinet_conf_proc(struct ctl_
 		    i == IPV4_DEVCONF_ROUTE_LOCALNET - 1)
 			if ((new_value == 0) && (old_value != 0))
 				rt_cache_flush(net);
+
 		if (i == IPV4_DEVCONF_RP_FILTER - 1 &&
 		    new_value != old_value) {
-			int ifindex;
-
-			if (cnf == net->ipv4.devconf_dflt)
-				ifindex = NETCONFA_IFINDEX_DEFAULT;
-			else if (cnf == net->ipv4.devconf_all)
-				ifindex = NETCONFA_IFINDEX_ALL;
-			else {
-				struct in_device *idev =
-					container_of(cnf, struct in_device,
-						     cnf);
-				ifindex = idev->dev->ifindex;
-			}
+			ifindex = devinet_conf_ifindex(net, cnf);
 			inet_netconf_notify_devconf(net, NETCONFA_RP_FILTER,
 						    ifindex, cnf);
 		}
+		if (i == IPV4_DEVCONF_PROXY_ARP - 1 &&
+		    new_value != old_value) {
+			ifindex = devinet_conf_ifindex(net, cnf);
+			inet_netconf_notify_devconf(net, NETCONFA_PROXY_ARP,
+						    ifindex, cnf);
+		}
 	}
 
 	return ret;
