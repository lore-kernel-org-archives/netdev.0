From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] ip-address: Support filtering by slave type, too
Date: Tue, 28 Jun 2016 15:07:16 +0200
Message-ID: <1467119237-12544-2-git-send-email-phil@nwl.cc>
References: <1467119237-12544-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57714 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbcF1NHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 09:07:31 -0400
In-Reply-To: <1467119237-12544-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to query all interfaces enslaved to a bridge or bond
using the following syntax:

| ip addr show type bridge_slave

Filtering has to be done in userspace since the kernel does not support
filtering on IFLA_INFO_SLAVE_KIND.

Functionality introduced in this patch is not fully complete since it
does not allow to match on type and slave type at the same time, but it
doesn't prevent implementing a dedicated slave_type match, either.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 52 ++++++++++++++++++++++++++++++----------------------
 1 file changed, 30 insertions(+), 22 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 8766530f7fa7c..56f68eb21c0fc 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -61,6 +61,7 @@ static struct
 	int group;
 	int master;
 	char *kind;
+	char *slave_kind;
 } filter;
 
 static int do_link;
@@ -206,18 +207,27 @@ static void print_linkmode(FILE *f, struct rtattr *tb)
 		fprintf(f, "mode %s ", link_modes[mode]);
 }
 
-static char *parse_link_kind(struct rtattr *tb)
+static char *parse_link_kind(struct rtattr *tb, bool slave)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	int attr = slave ? IFLA_INFO_SLAVE_KIND : IFLA_INFO_KIND;
 
 	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
 
-	if (linkinfo[IFLA_INFO_KIND])
-		return RTA_DATA(linkinfo[IFLA_INFO_KIND]);
+	if (linkinfo[attr])
+		return RTA_DATA(linkinfo[attr]);
 
 	return "";
 }
 
+static int match_link_kind(struct rtattr **tb, char *kind, bool slave)
+{
+	if (!tb[IFLA_LINKINFO])
+		return -1;
+
+	return strcmp(parse_link_kind(tb[IFLA_LINKINFO], slave), kind);
+}
+
 static void print_linktype(FILE *fp, struct rtattr *tb)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
@@ -680,16 +690,11 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	} else if (filter.master > 0)
 		return -1;
 
-	if (filter.kind) {
-		if (tb[IFLA_LINKINFO]) {
-			char *kind = parse_link_kind(tb[IFLA_LINKINFO]);
+	if (filter.kind && match_link_kind(tb, filter.kind, 0))
+		return -1;
 
-			if (strcmp(kind, filter.kind))
-				return -1;
-		} else {
-			return -1;
-		}
-	}
+	if (filter.slave_kind && match_link_kind(tb, filter.slave_kind, 1))
+		return -1;
 
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
@@ -781,16 +786,11 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	} else if (filter.master > 0)
 		return -1;
 
-	if (filter.kind) {
-		if (tb[IFLA_LINKINFO]) {
-			char *kind = parse_link_kind(tb[IFLA_LINKINFO]);
+	if (filter.kind && match_link_kind(tb, filter.kind, 0))
+		return -1;
 
-			if (strcmp(kind, filter.kind))
-				return -1;
-		} else {
-			return -1;
-		}
-	}
+	if (filter.slave_kind && match_link_kind(tb, filter.slave_kind, 1))
+		return -1;
 
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
@@ -1621,8 +1621,16 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 				invarg("Device does not exist\n", *argv);
 			filter.master = ifindex;
 		} else if (strcmp(*argv, "type") == 0) {
+			int soff;
+
 			NEXT_ARG();
-			filter.kind = *argv;
+			soff = strlen(*argv) - strlen("_slave");
+			if (!strcmp(*argv + soff, "_slave")) {
+				(*argv)[soff] = '\0';
+				filter.slave_kind = *argv;
+			} else {
+				filter.kind = *argv;
+			}
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-- 
2.8.2
