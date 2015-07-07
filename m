From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next v2] ipv4: add support for linkdown sysctl to netconf
Date: Tue,  7 Jul 2015 13:56:57 -0400
Message-ID: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36309 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932393AbbGGR5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 13:57:45 -0400
Received: by qgeg89 with SMTP id g89so88063978qge.3
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 10:57:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kernel patch exports the value of the new
ignore_routes_with_linkdown via netconf.

v2: changes to notify userspace via netlink when sysctl values change
and proposed for 'net' since this could be considered a bugfix

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
I realize two of these changes result in lines >80 chars, but this is to
keep the coding-style used by the surrounding code.

There are multiple ways to resolve this, but one would be to shorten the
defines used for this feature as "IGNORE_ROUTES_WITH_LINKDOWN" is a
mouthful.  I would propose dropping "_WITH_" from all the defines and
have only "IGNORE_ROUTES_LINKDOWN" everywhere.  Doing this now in 'net'
would be ideal before a release happens and it cannot be changed.

 include/uapi/linux/netconf.h |  1 +
 net/ipv4/devinet.c           | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
index 669a1f0..23cbd34 100644
--- a/include/uapi/linux/netconf.h
+++ b/include/uapi/linux/netconf.h
@@ -15,6 +15,7 @@ enum {
 	NETCONFA_RP_FILTER,
 	NETCONFA_MC_FORWARDING,
 	NETCONFA_PROXY_NEIGH,
+	NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7498716..e813196 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1740,6 +1740,8 @@ static int inet_netconf_msgsize_devconf(int type)
 		size += nla_total_size(4);
 	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
 		size += nla_total_size(4);
+	if (type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -1780,6 +1782,10 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH,
 			IPV4_DEVCONF(*devconf, PROXY_ARP)) < 0)
 		goto nla_put_failure;
+	if ((type == -1 || type == NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN) &&
+	    nla_put_s32(skb, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+			IPV4_DEVCONF(*devconf, IGNORE_ROUTES_WITH_LINKDOWN)) < 0)
+		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -1819,6 +1825,7 @@ static const struct nla_policy devconf_ipv4_policy[NETCONFA_MAX+1] = {
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
 	[NETCONFA_RP_FILTER]	= { .len = sizeof(int) },
 	[NETCONFA_PROXY_NEIGH]	= { .len = sizeof(int) },
+	[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN]	= { .len = sizeof(int) },
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
@@ -2048,6 +2055,12 @@ static int devinet_conf_proc(struct ctl_table *ctl, int write,
 			inet_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						    ifindex, cnf);
 		}
+		if (i == IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN - 1 &&
+		    new_value != old_value) {
+			ifindex = devinet_conf_ifindex(net, cnf);
+			inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+						    ifindex, cnf);
+		}
 	}
 
 	return ret;
-- 
1.9.3
