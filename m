From: David Ahern <dsahern@gmail.com>
Subject: [PATCH iproute2 4/4] ip vrf: Add show command
Date: Sat, 27 May 2017 17:34:50 -0600
Message-ID: <20170527233450.58015-5-dsahern@gmail.com>
References: <20170527233450.58015-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36681 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdE0XfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:35:02 -0400
Received: by mail-pg0-f67.google.com with SMTP id h64so2561506pge.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 16:35:01 -0700 (PDT)
In-Reply-To: <20170527233450.58015-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add show command to list all configured VRF and their table ids.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 ip/ipvrf.c        | 153 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 man/man8/ip-vrf.8 |  11 ++++
 2 files changed, 159 insertions(+), 5 deletions(-)

diff --git a/ip/ipvrf.c b/ip/ipvrf.c
index 0f611b44b78a..0094cf8557cd 100644
--- a/ip/ipvrf.c
+++ b/ip/ipvrf.c
@@ -32,9 +32,12 @@
 
 #define CGRP_PROC_FILE  "/cgroup.procs"
 
+static struct link_filter vrf_filter;
+
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip vrf exec [NAME] cmd ...\n");
+	fprintf(stderr, "Usage: ip vrf show [NAME] ...\n");
+	fprintf(stderr, "       ip vrf exec [NAME] cmd ...\n");
 	fprintf(stderr, "       ip vrf identify [PID]\n");
 	fprintf(stderr, "       ip vrf pids [NAME]\n");
 
@@ -467,13 +470,148 @@ void vrf_reset(void)
 	vrf_switch("default");
 }
 
-int do_ipvrf(int argc, char **argv)
+static int ipvrf_filter_req(struct nlmsghdr *nlh, int reqlen)
+{
+	struct rtattr *linkinfo;
+	int err;
+
+	if (vrf_filter.kind) {
+		linkinfo = addattr_nest(nlh, reqlen, IFLA_LINKINFO);
+
+		err = addattr_l(nlh, reqlen, IFLA_INFO_KIND, vrf_filter.kind,
+				strlen(vrf_filter.kind));
+		if (err)
+			return err;
+
+		addattr_nest_end(nlh, linkinfo);
+	}
+
+	return 0;
+}
+
+/* input arg is linkinfo */
+static __u32 vrf_table_linkinfo(struct rtattr *li[])
+{
+	struct rtattr *attr[IFLA_VRF_MAX + 1];
+
+	if (li[IFLA_INFO_DATA]) {
+		parse_rtattr_nested(attr, IFLA_VRF_MAX, li[IFLA_INFO_DATA]);
+
+		if (attr[IFLA_VRF_TABLE])
+			return rta_getattr_u32(attr[IFLA_VRF_TABLE]);
+	}
+
+	return 0;
+}
+
+static int ipvrf_print(struct nlmsghdr *n)
+{
+	struct ifinfomsg *ifi = NLMSG_DATA(n);
+	struct rtattr *tb[IFLA_MAX+1];
+	struct rtattr *li[IFLA_INFO_MAX+1];
+	int len = n->nlmsg_len;
+	const char *name;
+	__u32 tb_id;
+
+	len -= NLMSG_LENGTH(sizeof(*ifi));
+	if (len < 0)
+		return 0;
+
+	if (vrf_filter.ifindex && vrf_filter.ifindex != ifi->ifi_index)
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+
+	/* kernel does not support filter by master device */
+	if (tb[IFLA_MASTER]) {
+		int master = *(int *)RTA_DATA(tb[IFLA_MASTER]);
+
+		if (vrf_filter.master && master != vrf_filter.master)
+			return 0;
+	}
+
+	if (!tb[IFLA_IFNAME]) {
+		fprintf(stderr,
+			"BUG: device with ifindex %d has nil ifname\n",
+			ifi->ifi_index);
+		return 0;
+	}
+	name = rta_getattr_str(tb[IFLA_IFNAME]);
+
+	/* missing LINKINFO means not VRF. e.g., kernel does not
+	 * support filtering on kind, so userspace needs to handle
+	 */
+	if (!tb[IFLA_LINKINFO])
+		return 0;
+
+	parse_rtattr_nested(li, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
+
+	if (!li[IFLA_INFO_KIND])
+		return 0;
+
+	if (strcmp(RTA_DATA(li[IFLA_INFO_KIND]), "vrf"))
+		return 0;
+
+	tb_id = vrf_table_linkinfo(li);
+	if (!tb_id) {
+		fprintf(stderr,
+			"BUG: VRF %s is missing table id\n", name);
+		return 0;
+	}
+
+	printf("%-16s %5u", name, tb_id);
+
+	printf("\n");
+	return 1;
+}
+
+static int ipvrf_show(int argc, char **argv)
 {
-	if (argc == 0) {
-		fprintf(stderr, "No command given. Try \"ip vrf help\".\n");
-		exit(-1);
+	struct nlmsg_chain linfo = { NULL, NULL};
+	int rc = 0;
+
+	vrf_filter.kind = "vrf";
+
+	if (argc > 1)
+		usage();
+
+	if (argc == 1) {
+		__u32 tb_id;
+
+		tb_id = ipvrf_get_table(argv[0]);
+		if (!tb_id) {
+			fprintf(stderr, "Invalid VRF\n");
+			return 1;
+		}
+		printf("%s %u\n", argv[0], tb_id);
+		return 0;
 	}
 
+	if (ip_linkaddr_list(0, ipvrf_filter_req, &linfo, NULL) == 0) {
+		struct nlmsg_list *l;
+		unsigned nvrf = 0;
+		int n;
+
+		n = printf("%-16s  %5s\n", "Name", "Table");
+		printf("%.*s\n", n-1, "-----------------------");
+		for (l = linfo.head; l; l = l->next)
+			nvrf += ipvrf_print(&l->h);
+
+		if (!nvrf)
+			printf("No VRF has been configured\n");
+	} else
+		rc = 1;
+
+	free_nlmsg_chain(&linfo);
+
+	return rc;
+}
+
+int do_ipvrf(int argc, char **argv)
+{
+	if (argc == 0)
+		return ipvrf_show(0, NULL);
+
 	if (matches(*argv, "identify") == 0)
 		return ipvrf_identify(argc-1, argv+1);
 
@@ -483,6 +621,11 @@ int do_ipvrf(int argc, char **argv)
 	if (matches(*argv, "exec") == 0)
 		return ipvrf_exec(argc-1, argv+1);
 
+	if (matches(*argv, "show") == 0 ||
+	    matches(*argv, "lst") == 0 ||
+	    matches(*argv, "list") == 0)
+		return ipvrf_show(argc-1, argv+1);
+
 	if (matches(*argv, "help") == 0)
 		usage();
 
diff --git a/man/man8/ip-vrf.8 b/man/man8/ip-vrf.8
index 57a7c7692ce8..187893393be2 100644
--- a/man/man8/ip-vrf.8
+++ b/man/man8/ip-vrf.8
@@ -13,6 +13,10 @@ ip-vrf \- run a command against a vrf
 .sp
 
 .ti -8
+.BR "ip vrf show"
+.RI "[ " NAME " ]"
+
+.ti -8
 .BR "ip vrf identify"
 .RI "[ " PID " ]"
 
@@ -45,6 +49,13 @@ is a helper to run a command against a specific VRF with the VRF association
 inherited parent to child.
 
 .TP
+.B ip vrf show [ NAME ] - Show all configured VRF
+.sp
+This command lists all VRF and their corresponding table ids. If NAME is
+given, then only that VRF and table id is shown. The latter command is
+useful for scripting where the table id for a VRF is needed.
+
+.TP
 .B ip vrf exec [ NAME ] cmd ... - Run cmd against the named VRF
 .sp
 This command allows applications that are VRF unaware to be run against
-- 
2.11.0 (Apple Git-81)
