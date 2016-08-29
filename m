From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] netconf: add a notif  when settings are created
Date: Mon, 29 Aug 2016 12:05:49 +0200
Message-ID: <1472465149-1163-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:56066 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756130AbcH2KLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 06:11:23 -0400
In-Reply-To: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All changes are notified, but the initial state was missing.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c  | 11 +++++++----
 net/ipv6/addrconf.c |  9 ++++++++-
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 415e117967c7..062a67ca9a21 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2232,7 +2232,7 @@ static struct devinet_sysctl_table {
 };
 
 static int __devinet_sysctl_register(struct net *net, char *dev_name,
-					struct ipv4_devconf *p)
+				     int ifindex, struct ipv4_devconf *p)
 {
 	int i;
 	struct devinet_sysctl_table *t;
@@ -2255,6 +2255,8 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		goto free;
 
 	p->sysctl = t;
+
+	inet_netconf_notify_devconf(net, NETCONFA_ALL, ifindex, p);
 	return 0;
 
 free:
@@ -2286,7 +2288,7 @@ static int devinet_sysctl_register(struct in_device *idev)
 	if (err)
 		return err;
 	err = __devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
-					&idev->cnf);
+					idev->dev->ifindex, &idev->cnf);
 	if (err)
 		neigh_sysctl_unregister(idev->arp_parms);
 	return err;
@@ -2347,11 +2349,12 @@ static __net_init int devinet_init_net(struct net *net)
 	}
 
 #ifdef CONFIG_SYSCTL
-	err = __devinet_sysctl_register(net, "all", all);
+	err = __devinet_sysctl_register(net, "all", NETCONFA_IFINDEX_ALL, all);
 	if (err < 0)
 		goto err_reg_all;
 
-	err = __devinet_sysctl_register(net, "default", dflt);
+	err = __devinet_sysctl_register(net, "default",
+					NETCONFA_IFINDEX_DEFAULT, dflt);
 	if (err < 0)
 		goto err_reg_dflt;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 299f0656e87f..bb3874d2f248 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6032,7 +6032,7 @@ static const struct ctl_table addrconf_sysctl[] = {
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
-	int i;
+	int i, ifindex;
 	struct ctl_table *table;
 	char path[sizeof("net/ipv6/conf/") + IFNAMSIZ];
 
@@ -6052,6 +6052,13 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	if (!p->sysctl_header)
 		goto free;
 
+	if (!strcmp(dev_name, "all"))
+		ifindex = NETCONFA_IFINDEX_ALL;
+	else if (!strcmp(dev_name, "default"))
+		ifindex = NETCONFA_IFINDEX_DEFAULT;
+	else
+		ifindex = idev->dev->ifindex;
+	inet6_netconf_notify_devconf(net, NETCONFA_ALL, ifindex, p);
 	return 0;
 
 free:
-- 
2.8.1
