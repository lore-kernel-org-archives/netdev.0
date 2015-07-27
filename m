From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next] bridge: mdb: add support for router add/del notifications monitoring
Date: Mon, 27 Jul 2015 13:44:05 +0200
Message-ID: <1437997445-29541-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36992 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbG0Lpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 07:45:53 -0400
Received: by wibud3 with SMTP id ud3so111835280wib.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 04:45:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch adds support for ADDMDB/DELMDB notifications about router ports
which have been added or deleted/expired respectively.

Example output:
$ bridge -s monitor mdb
Deleted router port dev eth3 master br0
router port dev eth3 master br0

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 bridge/mdb.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index ea169b9c2e4d..dd1f942af53c 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -84,7 +84,7 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	FILE *fp = arg;
 	struct br_port_msg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	struct rtattr * tb[MDBA_MAX+1];
+	struct rtattr *tb[MDBA_MAX+1], *i;
 
 	if (n->nlmsg_type != RTM_GETMDB && n->nlmsg_type != RTM_NEWMDB && n->nlmsg_type != RTM_DELMDB) {
 		fprintf(stderr, "Not RTM_GETMDB, RTM_NEWMDB or RTM_DELMDB: %08x %08x %08x\n",
@@ -105,7 +105,6 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	parse_rtattr(tb, MDBA_MAX, MDBA_RTA(r), n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[MDBA_MDB]) {
-		struct rtattr *i;
 		int rem = RTA_PAYLOAD(tb[MDBA_MDB]);
 
 		for (i = RTA_DATA(tb[MDBA_MDB]); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
@@ -113,9 +112,22 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 
 	if (tb[MDBA_ROUTER]) {
-		if (show_details) {
-			fprintf(fp, "router ports on %s: ", ll_index_to_name(r->ifindex));
-			br_print_router_ports(fp, tb[MDBA_ROUTER]);
+		if (n->nlmsg_type == RTM_GETMDB) {
+			if (show_details) {
+				fprintf(fp, "router ports on %s: ",
+					ll_index_to_name(r->ifindex));
+				br_print_router_ports(fp, tb[MDBA_ROUTER]);
+			}
+		} else {
+			uint32_t *port_ifindex;
+
+			i = RTA_DATA(tb[MDBA_ROUTER]);
+			port_ifindex = RTA_DATA(i);
+			if (n->nlmsg_type == RTM_DELMDB)
+				fprintf(fp, "Deleted ");
+			fprintf(fp, "router port dev %s master %s\n",
+				ll_index_to_name(*port_ifindex),
+				ll_index_to_name(r->ifindex));
 		}
 	}
 
-- 
2.4.3
