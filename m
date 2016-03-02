From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next] ipv4: properly apply change to ignore_routes_on_linkdown to all interfaces
Date: Wed,  2 Mar 2016 11:43:06 -0500
Message-ID: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36492 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcCBQoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:44:05 -0500
Received: by mail-qg0-f52.google.com with SMTP id u110so44344177qge.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 08:44:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any change to sysctl net.ipv4.conf.all.ignore_routes_with_linkdown does
not result in a change to all interfaces on the system.  This means that
any devices initialized before sysctl settings are applied on boot do
not see a change if the sysctl setting is different than what the stack
has as a default ('0' in this case).

This patch changes the net.ipv4.conf.all.ignore_routes_with_linkdown
setting to match what is done for forwarding for ipv4 and for
ignore_routes_with_linkdown for ipv6.  The current behavior was not
intentional and had I recognized this corner-case before posting I would
have done this with the first series.

Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
Generic infrastructure could be added to do this for all values, but I'm
hesitant to do this since historically users are probably depending on
the exiting behavior (whether intentional or not) for the more widely
used sysctls.

 net/ipv4/devinet.c | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 75 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8c3df2c..d247e41 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2030,6 +2030,36 @@ static void inet_forward_change(struct net *net)
 	}
 }
 
+/* called with RTNL locked */
+static void inet_ignore_routes_change(struct net *net)
+{
+	struct net_device *dev;
+	int on = IPV4_DEVCONF_ALL(net, IGNORE_ROUTES_WITH_LINKDOWN);
+
+	IPV4_DEVCONF_DFLT(net, IGNORE_ROUTES_WITH_LINKDOWN) = on;
+	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+				    NETCONFA_IFINDEX_ALL,
+				    net->ipv4.devconf_all);
+	inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+				    NETCONFA_IFINDEX_DEFAULT,
+				    net->ipv4.devconf_dflt);
+
+	for_each_netdev(net, dev) {
+		struct in_device *in_dev;
+
+		rcu_read_lock();
+		in_dev = __in_dev_get_rcu(dev);
+		if (in_dev) {
+			IN_DEV_CONF_SET(in_dev,
+					IGNORE_ROUTES_WITH_LINKDOWN, on);
+			inet_netconf_notify_devconf(net,
+						    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+						    dev->ifindex, &in_dev->cnf);
+		}
+		rcu_read_unlock();
+	}
+}
+
 static int devinet_conf_ifindex(struct net *net, struct ipv4_devconf *cnf)
 {
 	if (cnf == net->ipv4.devconf_dflt)
@@ -2147,6 +2177,48 @@ static int ipv4_doint_and_flush(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int devinet_sysctl_ignore_routes(struct ctl_table *ctl, int write,
+					void __user *buffer,
+					size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	loff_t pos = *ppos;
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write && *valp != val) {
+		struct net *net = ctl->extra2;
+
+		if (valp != &IPV4_DEVCONF_DFLT(net, IGNORE_ROUTES_WITH_LINKDOWN)) {
+			if (!rtnl_trylock()) {
+				/* Restore the original values before restarting */
+				*valp = val;
+				*ppos = pos;
+				return restart_syscall();
+			}
+			if (valp == &IPV4_DEVCONF_ALL(net, IGNORE_ROUTES_WITH_LINKDOWN)) {
+				inet_ignore_routes_change(net);
+			} else {
+				struct ipv4_devconf *cnf = ctl->extra1;
+				struct in_device *idev =
+					container_of(cnf, struct in_device, cnf);
+				inet_netconf_notify_devconf(net,
+							    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+							    idev->dev->ifindex,
+							    cnf);
+			}
+			rtnl_unlock();
+			rt_cache_flush(net);
+		} else
+			inet_netconf_notify_devconf(net,
+						    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+						    NETCONFA_IFINDEX_DEFAULT,
+						    net->ipv4.devconf_dflt);
+	}
+
+	return ret;
+}
+
 #define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc) \
 	{ \
 		.procname	= name, \
@@ -2205,8 +2277,9 @@ static struct devinet_sysctl_table {
 					"igmpv2_unsolicited_report_interval"),
 		DEVINET_SYSCTL_RW_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
 					"igmpv3_unsolicited_report_interval"),
-		DEVINET_SYSCTL_RW_ENTRY(IGNORE_ROUTES_WITH_LINKDOWN,
-					"ignore_routes_with_linkdown"),
+		DEVINET_SYSCTL_COMPLEX_ENTRY(IGNORE_ROUTES_WITH_LINKDOWN,
+					     "ignore_routes_with_linkdown",
+					     devinet_sysctl_ignore_routes),
 		DEVINET_SYSCTL_RW_ENTRY(DROP_GRATUITOUS_ARP,
 					"drop_gratuitous_arp"),
 
-- 
1.9.3
