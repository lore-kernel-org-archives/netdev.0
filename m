From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] netconf: add support for IPv6 proxy_ndp
Date: Tue, 17 Dec 2013 22:37:14 -0800
Message-ID: <20131217223714.325c0e78@nehalam.linuxnetplumber.net>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:46769 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRGjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:39:15 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so7778278pdj.17
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 22:39:14 -0800 (PST)
In-Reply-To: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to be able to see changes to proxy NDP status on a per
interface basis via netlink (analog to proxy_arp).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/ipv6/addrconf.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 48 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c	2013-12-16 10:53:01.394635074 -0800
+++ b/net/ipv6/addrconf.c	2013-12-16 11:24:50.937221182 -0800
@@ -442,6 +442,8 @@ static int inet6_netconf_msgsize_devconf
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
 #endif
+	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -475,6 +477,10 @@ static int inet6_netconf_fill_devconf(st
 			devconf->mc_forwarding) < 0)
 		goto nla_put_failure;
 #endif
+	if ((type == -1 || type == NETCONFA_PROXY_NEIGH) &&
+	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH, devconf->proxy_ndp) < 0)
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -509,6 +515,7 @@ errout:
 static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
 	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
+	[NETCONFA_PROXY_NEIGH]	= { .len = sizeof(int) },
 };
 
 static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
@@ -4728,6 +4735,46 @@ int addrconf_sysctl_disable(struct ctl_t
 	return ret;
 }
 
+static
+int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
+			      void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int ret;
+	int old, new;
+
+	old = *valp;
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	new = *valp;
+
+	if (write && old != new) {
+		struct net *net = ctl->extra2;
+
+		if (!rtnl_trylock())
+			return restart_syscall();
+
+		if (valp == &net->ipv6.devconf_dflt->proxy_ndp)
+			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+						     NETCONFA_IFINDEX_DEFAULT,
+						     net->ipv6.devconf_dflt);
+		else if (valp == &net->ipv6.devconf_all->proxy_ndp)
+			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+						     NETCONFA_IFINDEX_ALL,
+						     net->ipv6.devconf_all);
+		else {
+			struct inet6_dev *idev = ctl->extra1;
+
+			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+						     idev->dev->ifindex,
+						     &idev->cnf);
+		}
+		rtnl_unlock();
+	}
+
+	return ret;
+}
+
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -4914,7 +4961,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.proxy_ndp,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_sysctl_proxy_ndp,
 		},
 		{
 			.procname	= "accept_source_route",
