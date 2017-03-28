From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/7] net: devinet: Add support for RTM_DELNETCONF
Date: Tue, 28 Mar 2017 14:28:03 -0700
Message-ID: <1490736487-16020-4-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35251 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753422AbdC1V2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:16 -0400
Received: by mail-it0-f54.google.com with SMTP id y18so130330431itc.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:15 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send RTM_DELNETCONF notifications when a device is deleted. The message only
needs the device index, so modify inet_netconf_fill_devconf to skip devconf
references if it is NULL.

Allows a userspace cache to remove entries as devices are deleted.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/devinet.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index fd3218cd1870..6d3602ec640c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1802,6 +1802,9 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
+	if (!devconf)
+		goto out;
+
 	if ((all || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING,
 			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
@@ -1823,6 +1826,7 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 			IPV4_DEVCONF(*devconf, IGNORE_ROUTES_WITH_LINKDOWN)) < 0)
 		goto nla_put_failure;
 
+out:
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -2276,16 +2280,18 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 	return -ENOBUFS;
 }
 
-static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
+static void __devinet_sysctl_unregister(struct net *net,
+					struct ipv4_devconf *cnf, int ifindex)
 {
 	struct devinet_sysctl_table *t = cnf->sysctl;
 
-	if (!t)
-		return;
+	if (t) {
+		cnf->sysctl = NULL;
+		unregister_net_sysctl_table(t->sysctl_header);
+		kfree(t);
+	}
 
-	cnf->sysctl = NULL;
-	unregister_net_sysctl_table(t->sysctl_header);
-	kfree(t);
+	inet_netconf_notify_devconf(net, RTM_DELNETCONF, 0, ifindex, NULL);
 }
 
 static int devinet_sysctl_register(struct in_device *idev)
@@ -2307,7 +2313,9 @@ static int devinet_sysctl_register(struct in_device *idev)
 
 static void devinet_sysctl_unregister(struct in_device *idev)
 {
-	__devinet_sysctl_unregister(&idev->cnf);
+	struct net *net = dev_net(idev->dev);
+
+	__devinet_sysctl_unregister(net, &idev->cnf, idev->dev->ifindex);
 	neigh_sysctl_unregister(idev->arp_parms);
 }
 
@@ -2382,9 +2390,9 @@ static __net_init int devinet_init_net(struct net *net)
 
 #ifdef CONFIG_SYSCTL
 err_reg_ctl:
-	__devinet_sysctl_unregister(dflt);
+	__devinet_sysctl_unregister(net, dflt, NETCONFA_IFINDEX_DEFAULT);
 err_reg_dflt:
-	__devinet_sysctl_unregister(all);
+	__devinet_sysctl_unregister(net, all, NETCONFA_IFINDEX_ALL);
 err_reg_all:
 	if (tbl != ctl_forward_entry)
 		kfree(tbl);
@@ -2406,8 +2414,10 @@ static __net_exit void devinet_exit_net(struct net *net)
 
 	tbl = net->ipv4.forw_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.forw_hdr);
-	__devinet_sysctl_unregister(net->ipv4.devconf_dflt);
-	__devinet_sysctl_unregister(net->ipv4.devconf_all);
+	__devinet_sysctl_unregister(net, net->ipv4.devconf_dflt,
+				    NETCONFA_IFINDEX_DEFAULT);
+	__devinet_sysctl_unregister(net, net->ipv4.devconf_all,
+				    NETCONFA_IFINDEX_ALL);
 	kfree(tbl);
 #endif
 	kfree(net->ipv4.devconf_dflt);
-- 
2.1.4
