From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/7] net: ipv6: Add support for RTM_DELNETCONF
Date: Tue, 28 Mar 2017 14:28:05 -0700
Message-ID: <1490736487-16020-6-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:34130 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752401AbdC1V2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:43 -0400
Received: by mail-it0-f41.google.com with SMTP id y18so30240021itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:37 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send RTM_DELNETCONF notifications when a device is deleted. The message only
needs the device index, so modify inet6_netconf_fill_devconf to skip devconf
references if it is NULL.

Allows a userspace cache to remove entries as devices are deleted.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b8442be85e1b..67ec87ea5fb6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -549,6 +549,9 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
+	if (!devconf)
+		goto out;
+
 	if ((all || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
@@ -567,6 +570,7 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 			devconf->ignore_routes_with_linkdown) < 0)
 		goto nla_put_failure;
 
+out:
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -6368,7 +6372,8 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	return -ENOBUFS;
 }
 
-static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
+static void __addrconf_sysctl_unregister(struct net *net,
+					 struct ipv6_devconf *p, int ifindex)
 {
 	struct ctl_table *table;
 
@@ -6379,6 +6384,8 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 	unregister_net_sysctl_table(p->sysctl_header);
 	p->sysctl_header = NULL;
 	kfree(table);
+
+	inet6_netconf_notify_devconf(net, RTM_DELNETCONF, 0, ifindex, NULL);
 }
 
 static int addrconf_sysctl_register(struct inet6_dev *idev)
@@ -6402,7 +6409,8 @@ static int addrconf_sysctl_register(struct inet6_dev *idev)
 
 static void addrconf_sysctl_unregister(struct inet6_dev *idev)
 {
-	__addrconf_sysctl_unregister(&idev->cnf);
+	__addrconf_sysctl_unregister(dev_net(idev->dev), &idev->cnf,
+				     idev->dev->ifindex);
 	neigh_sysctl_unregister(idev->nd_parms);
 }
 
@@ -6445,7 +6453,7 @@ static int __net_init addrconf_init_net(struct net *net)
 
 #ifdef CONFIG_SYSCTL
 err_reg_dflt:
-	__addrconf_sysctl_unregister(all);
+	__addrconf_sysctl_unregister(net, all, NETCONFA_IFINDEX_ALL);
 err_reg_all:
 	kfree(dflt);
 #endif
@@ -6458,8 +6466,10 @@ static int __net_init addrconf_init_net(struct net *net)
 static void __net_exit addrconf_exit_net(struct net *net)
 {
 #ifdef CONFIG_SYSCTL
-	__addrconf_sysctl_unregister(net->ipv6.devconf_dflt);
-	__addrconf_sysctl_unregister(net->ipv6.devconf_all);
+	__addrconf_sysctl_unregister(net, net->ipv6.devconf_dflt,
+				     NETCONFA_IFINDEX_DEFAULT);
+	__addrconf_sysctl_unregister(net, net->ipv6.devconf_all,
+				     NETCONFA_IFINDEX_ALL);
 #endif
 	kfree(net->ipv6.devconf_dflt);
 	kfree(net->ipv6.devconf_all);
-- 
2.1.4
