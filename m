From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v5] bridge: mdb: add support for extended router port information
Date: Mon, 14 Mar 2016 11:04:46 +0100
Message-ID: <1457949886-19733-1-git-send-email-nikolay@cumulusnetworks.com>
References: <20160313233708.57005031@xeon-e3>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35935 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933617AbcCNKEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 06:04:54 -0400
Received: by mail-wm0-f49.google.com with SMTP id n186so99508538wmn.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 03:04:53 -0700 (PDT)
In-Reply-To: <20160313233708.57005031@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently a new temp router port mode was added and with it the dumped
information was extended similar to how mdb entries were done. This
patch adds support to dump the new information by using the "-s" switch.
Example:
$ bridge -d -s mdb show
dev br0 port eth1 grp ff02::1:ffbf:5716 temp 234.39
dev br0 port eth1 grp 239.0.0.2 temp  97.17
dev br0 port eth1 grp 239.0.0.3 temp 105.36
router ports on br0: eth1    0.00 permanent
router ports on br0: eth2  254.87 temp

It also updates the bridge man page.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v5: pull router port stats in their own function, rebase and retest
v4: minor optimization, parse new attributes only when show_stats has been
specified
v3: make is_temp_mcast_rtr bool and return the result directly as per
Stephen's comment
v2: print the values only if they were provided by the kernel, otherwise
we might print "permanent" for a temporary entry on an older kernel.

 bridge/br_common.h |  3 +++
 bridge/mdb.c       | 53 ++++++++++++++++++++++++++++++++++++++++++++---------
 man/man8/bridge.8  |  6 +++++-
 3 files changed, 52 insertions(+), 10 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 41eb0dc38293..5ea45c9e654d 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -1,6 +1,9 @@
 #define MDB_RTA(r) \
 		((struct rtattr *)(((char *)(r)) + RTA_ALIGN(sizeof(struct br_mdb_entry))))
 
+#define MDB_RTR_RTA(r) \
+		((struct rtattr *)(((char *)(r)) + RTA_ALIGN(sizeof(__u32))))
+
 extern int print_linkinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 600596c94969..97da4dc98f23 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -33,19 +33,56 @@ static void usage(void)
 	exit(-1);
 }
 
-static void br_print_router_ports(FILE *f, struct rtattr *attr)
+static bool is_temp_mcast_rtr(__u8 type)
+{
+	return type == MDB_RTR_TYPE_TEMP_QUERY || type == MDB_RTR_TYPE_TEMP;
+}
+
+static void __print_router_port_stats(FILE *f, struct rtattr *pattr)
+{
+	struct rtattr *tb[MDBA_ROUTER_PATTR_MAX + 1];
+	struct timeval tv;
+	__u8 type;
+
+	parse_rtattr(tb, MDBA_ROUTER_PATTR_MAX, MDB_RTR_RTA(RTA_DATA(pattr)),
+		     RTA_PAYLOAD(pattr) - RTA_ALIGN(sizeof(uint32_t)));
+	if (tb[MDBA_ROUTER_PATTR_TIMER]) {
+		__jiffies_to_tv(&tv,
+				rta_getattr_u32(tb[MDBA_ROUTER_PATTR_TIMER]));
+		fprintf(f, " %4i.%.2i",
+			(int)tv.tv_sec, (int)tv.tv_usec/10000);
+	}
+	if (tb[MDBA_ROUTER_PATTR_TYPE]) {
+		type = rta_getattr_u8(tb[MDBA_ROUTER_PATTR_TYPE]);
+		fprintf(f, " %s",
+			is_temp_mcast_rtr(type) ? "temp" : "permanent");
+	}
+}
+
+static void br_print_router_ports(FILE *f, struct rtattr *attr, __u32 brifidx)
 {
 	uint32_t *port_ifindex;
 	struct rtattr *i;
 	int rem;
 
+	if (!show_stats)
+		fprintf(f, "router ports on %s: ", ll_index_to_name(brifidx));
+
 	rem = RTA_PAYLOAD(attr);
 	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 		port_ifindex = RTA_DATA(i);
-		fprintf(f, "%s ", ll_index_to_name(*port_ifindex));
+		if (show_stats) {
+			fprintf(f, "router ports on %s: %s",
+				ll_index_to_name(brifidx),
+				ll_index_to_name(*port_ifindex));
+			__print_router_port_stats(f, i);
+			fprintf(f, "\n");
+		} else {
+			fprintf(f, "%s ", ll_index_to_name(*port_ifindex));
+		}
 	}
-
-	fprintf(f, "\n");
+	if (!show_stats)
+		fprintf(f, "\n");
 }
 
 static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
@@ -127,11 +164,9 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[MDBA_ROUTER]) {
 		if (n->nlmsg_type == RTM_GETMDB) {
-			if (show_details) {
-				fprintf(fp, "router ports on %s: ",
-					ll_index_to_name(r->ifindex));
-				br_print_router_ports(fp, tb[MDBA_ROUTER]);
-			}
+			if (show_details)
+				br_print_router_ports(fp, tb[MDBA_ROUTER],
+						      r->ifindex);
 		} else {
 			uint32_t *port_ifindex;
 
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index 0e98edf4762f..08e8a5bf5a08 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -119,6 +119,10 @@ is given multiple times, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
 .TP
+.BR "\-d" , " \-details"
+print detailed information about MDB router ports.
+
+.TP
 .BR "\-n" , " \-net" , " \-netns " <NETNS>
 switches
 .B bridge
@@ -506,7 +510,7 @@ a connected router.
 .PP
 With the
 .B -statistics
-option, the command displays timer values for mdb entries.
+option, the command displays timer values for mdb and router port entries.
 
 .SH bridge vlan - VLAN filter list
 
-- 
2.4.3
