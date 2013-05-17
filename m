From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ipnetconf: by default dump all entries
Date: Fri, 17 May 2013 10:47:29 +0200
Message-ID: <1368780449-5388-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54213 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab3EQIrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:47:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is now possible, because the dump function has been added in kernel.
Note that IPv4 and IPv6 entries are displayed.

Before this patch, only all entries were displayed.

Example:
$ ip netconf
ipv4 dev lo forwarding on rp_filter off mc_forwarding 0
ipv4 dev eth0 forwarding on rp_filter off mc_forwarding 1
ipv4 all forwarding on rp_filter off mc_forwarding 1
ipv4 default forwarding on rp_filter off mc_forwarding 0
ipv6 dev lo forwarding on mc_forwarding 0
ipv6 dev eth0 forwarding on mc_forwarding 0
ipv6 all forwarding on mc_forwarding 0
ipv6 default forwarding on mc_forwarding 0

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipnetconf.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 8ceadfe..9a77ecb 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -136,7 +136,6 @@ static int do_show(int argc, char **argv)
 	filter.family = preferred_family;
 	if (filter.family == AF_UNSPEC)
 		filter.family = AF_INET;
-	filter.ifindex = NETCONFA_IFINDEX_ALL;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -152,17 +151,34 @@ static int do_show(int argc, char **argv)
 	}
 
 	ll_init_map(&rth);
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct netconfmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
-	req.n.nlmsg_type = RTM_GETNETCONF;
-	req.ncm.ncm_family = filter.family;
-	addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX, &filter.ifindex,
-		  sizeof(filter.ifindex));
-
-	rtnl_send(&rth, &req.n, req.n.nlmsg_len);
-	rtnl_listen(&rth, print_netconf, stdout);
-
+	if (filter.ifindex) {
+		memset(&req, 0, sizeof(req));
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct netconfmsg));
+		req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
+		req.n.nlmsg_type = RTM_GETNETCONF;
+		req.ncm.ncm_family = filter.family;
+		if (filter.ifindex)
+			addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX,
+				  &filter.ifindex, sizeof(filter.ifindex));
+
+		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
+		rtnl_listen(&rth, print_netconf, stdout);
+	} else {
+dump:
+		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETNETCONF) < 0) {
+			perror("Cannot send dump request");
+			exit(1);
+		}
+		if (rtnl_dump_filter(&rth, print_netconf, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+		if (preferred_family == AF_UNSPEC) {
+			preferred_family = AF_INET6;
+			filter.family = AF_INET6;
+			goto dump;
+		}
+	}
 	return 0;
 }
 
-- 
1.8.2.1
