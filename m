From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip monitor: Fix issue when timestamp is printed w/o msg
Date: Fri,  5 Dec 2014 02:18:59 +0200
Message-ID: <1417738739-4645-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:37829 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbaLEA2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:28:44 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so14742674lab.9
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 16:28:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was observed when IPv6 router broadcasted NDUSEROPT
messages which are not handled by monitor and caused printing
'Timestamps' w/o message because such kind of rtnl messages is not
handled by monitor.

As 'ip monitor' by default subscribes to the all mcast rtnl groups except
RTGRP_TC then all messages of these rtnl groups which are not handled by
monitor may cause such issues.

Fixed by subscribing by default to rtnl mcast groups which are
supported by 'ip monitor'.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4cc75f4..4708e54 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -134,14 +134,6 @@ static int accept_msg(const struct sockaddr_nl *who,
 		fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
 		return 0;
 	}
-	if (n->nlmsg_type == RTM_NEWQDISC ||
-	    n->nlmsg_type == RTM_DELQDISC ||
-	    n->nlmsg_type == RTM_NEWTCLASS ||
-	    n->nlmsg_type == RTM_DELTCLASS ||
-	    n->nlmsg_type == RTM_NEWTFILTER ||
-	    n->nlmsg_type == RTM_DELTFILTER ||
-	    n->nlmsg_type == RTM_NEWNDUSEROPT)
-		return 0;
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
@@ -155,7 +147,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 int do_ipmonitor(int argc, char **argv)
 {
 	char *file = NULL;
-	unsigned groups = ~RTMGRP_TC;
+	unsigned groups = 0;
 	int llink=0;
 	int laddr=0;
 	int lroute=0;
@@ -165,6 +157,18 @@ int do_ipmonitor(int argc, char **argv)
 	int lnetconf=0;
 	int ifindex=0;
 
+	groups |= nl_mgrp(RTNLGRP_LINK);
+	groups |= nl_mgrp(RTNLGRP_IPV4_IFADDR);
+	groups |= nl_mgrp(RTNLGRP_IPV6_IFADDR);
+	groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
+	groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
+	groups |= nl_mgrp(RTNLGRP_IPV4_MROUTE);
+	groups |= nl_mgrp(RTNLGRP_IPV6_MROUTE);
+	groups |= nl_mgrp(RTNLGRP_IPV6_PREFIX);
+	groups |= nl_mgrp(RTNLGRP_NEIGH);
+	groups |= nl_mgrp(RTNLGRP_IPV4_NETCONF);
+	groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
+
 	rtnl_close(&rth);
 
 	while (argc > 0) {
@@ -195,7 +199,6 @@ int do_ipmonitor(int argc, char **argv)
 			lnetconf = 1;
 			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
-			groups = ~RTMGRP_TC;
 			prefix_banner=1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
-- 
2.1.3
