From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next] net: add support for linkdown sysctl to netconf
Date: Mon,  6 Jul 2015 14:21:59 -0400
Message-ID: <1436206919-973-1-git-send-email-gospo@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34960 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbGFSWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 14:22:12 -0400
Received: by qkbp125 with SMTP id p125so123153030qkb.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 11:22:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kernel patch exports the value of the new
ignore_routes_with_linkdown via netconf.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/netconf.h | 1 +
 net/ipv4/devinet.c           | 7 +++++++
 2 files changed, 8 insertions(+)

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
index 7498716..de2c563 100644
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
-- 
1.9.3
