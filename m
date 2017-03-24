From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next v2 3/3] ip netconf: show all families on dev request
Date: Thu, 23 Mar 2017 19:51:22 -0700
Message-ID: <1490323882-11609-4-git-send-email-dsa@cumulusnetworks.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36709 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934882AbdCXCvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 22:51:32 -0400
Received: by mail-pf0-f172.google.com with SMTP id o126so1186603pfb.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 19:51:31 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently specifying a device to ip netconf and it dumps only values
for IPv4. Change this to dump data for all families unless a specific
family is given.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipnetconf.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index dc0851025223..696e3dd51a1c 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -56,6 +56,7 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	struct netconfmsg *ncm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NETCONFA_MAX+1];
+	int ifindex = 0;
 
 	if (n->nlmsg_type == NLMSG_ERROR)
 		return -1;
@@ -77,6 +78,12 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	parse_rtattr(tb, NETCONFA_MAX, netconf_rta(ncm),
 		     NLMSG_PAYLOAD(n, sizeof(*ncm)));
 
+	if (tb[NETCONFA_IFINDEX])
+		ifindex = rta_getattr_u32(tb[NETCONFA_IFINDEX]);
+
+	if (filter.ifindex && filter.ifindex != ifindex)
+		return 0;
+
 	switch (ncm->ncm_family) {
 	case AF_INET:
 		fprintf(fp, "ipv4 ");
@@ -93,9 +100,7 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	}
 
 	if (tb[NETCONFA_IFINDEX]) {
-		int *ifindex = (int *)rta_getattr_str(tb[NETCONFA_IFINDEX]);
-
-		switch (*ifindex) {
+		switch (ifindex) {
 		case NETCONFA_IFINDEX_ALL:
 			fprintf(fp, "all ");
 			break;
@@ -103,7 +108,7 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 			fprintf(fp, "default ");
 			break;
 		default:
-			fprintf(fp, "dev %s ", ll_index_to_name(*ifindex));
+			fprintf(fp, "dev %s ", ll_index_to_name(ifindex));
 			break;
 		}
 	}
@@ -169,8 +174,6 @@ static int do_show(int argc, char **argv)
 
 	ipnetconf_reset_filter(0);
 	filter.family = preferred_family;
-	if (filter.family == AF_UNSPEC)
-		filter.family = AF_INET;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -186,11 +189,11 @@ static int do_show(int argc, char **argv)
 	}
 
 	ll_init_map(&rth);
-	if (filter.ifindex) {
+
+	if (filter.ifindex && filter.family != AF_UNSPEC) {
 		req.ncm.ncm_family = filter.family;
-		if (filter.ifindex)
-			addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX,
-				  &filter.ifindex, sizeof(filter.ifindex));
+		addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX,
+			  &filter.ifindex, sizeof(filter.ifindex));
 
 		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
 			perror("Can not send request");
-- 
2.1.4
