From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH iproute2 2/2] vxlan: allow specifying multiple default destinations
Date: Sun, 23 Jun 2013 19:24:03 +0300
Message-ID: <1372004643-24718-2-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372004643-24718-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:41094 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751764Ab3FWQYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:24:15 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so5526994eek.24
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:24:13 -0700 (PDT)
In-Reply-To: <1372004643-24718-1-git-send-email-mike.rapoport@ravellosystems.com>
In-Reply-To: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 ip/iplink_vxlan.c | 167 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 166 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 92ddfb4..ba9a5d8 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -35,6 +35,130 @@ static void explain(void)
 	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
 }
 
+static void explain_change(void)
+{
+	fprintf(stderr, "Usage: ... vxlan id VNI\n");
+	fprintf(stderr, "                 [ dstadd DST ]\n");
+	fprintf(stderr, "                 [ dstdel ADDR ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: VNI := 0-16777215\n");
++	fprintf(stderr, "       DST  := [ ADDR [port PORT] [vni VNI] [via DEV]]\n");
+}
+
+static int vxlan_parse_dstadd(int *argcp, char ***argvp, struct nlmsghdr *n)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	__u32 vni, ifindex;
+	__u16 port;
+	struct rtattr *nest;
+	int addr_set = 0;
+
+	nest = addattr_nest(n, 1024, IFLA_VXLAN_REMOTE_NEW);
+
+	while (argc > 0) {
+		if (!matches(*argv, "vni")) {
+			NEXT_ARG();
+			if (get_u32(&vni, *argv, 0) ||
+			    vni >= 1u << 24)
+				invarg("invalid id", *argv);
+			addattr32(n, 1024, IFLA_VXLAN_REMOTE_VNI, vni);
+		} else if (!matches(*argv, "port")) {
+			NEXT_ARG();
+			if (get_u16(&port, *argv, 0))
+				invarg("port", *argv);
+			addattr32(n, 1024, IFLA_VXLAN_REMOTE_PORT, htons(port));
+		} else if (!matches(*argv, "via")) {
+			NEXT_ARG();
+			ifindex = if_nametoindex(*argv);
+			addattr32(n, 1024, IFLA_VXLAN_REMOTE_IFINDEX, ifindex);
+		} else {
+			inet_prefix addr;
+			get_prefix(&addr, *argv, AF_UNSPEC);
+			addattr_l(n, 1024, IFLA_VXLAN_REMOTE_ADDR,
+				  &addr.data, addr.bytelen);
+			addr_set = 1;
+		}
+		argc--, argv++;
+	}
+
+	if (!addr_set)
+		incomplete_command();
+
+	addattr_nest_end(n, nest);
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
+static int vxlan_parse_dstdel(int *argcp, char ***argvp, struct nlmsghdr *n)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	struct rtattr *nest;
+
+	nest = addattr_nest(n, 1024, IFLA_VXLAN_REMOTE_DEL);
+
+	while (argc > 0) {
+		inet_prefix addr;
+		get_prefix(&addr, *argv, AF_UNSPEC);
+		addattr_l(n, 1024, IFLA_VXLAN_REMOTE_ADDR,
+			  &addr.data, addr.bytelen);
+		argc--, argv++;
+	}
+
+	if (argc == *argcp)
+		incomplete_command();
+
+	addattr_nest_end(n, nest);
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
+}
+
+static int vxlan_parse_opt_change(struct link_util *lu, int argc, char **argv,
+				  struct nlmsghdr *n)
+{
+	__u32 vni = 0;
+	int vni_set = 0;
+	struct rtattr *remotes;
+
+	while (argc > 0) {
+		if (!matches(*argv, "id") ||
+		    !matches(*argv, "vni")) {
+			NEXT_ARG();
+			if (get_u32(&vni, *argv, 0) ||
+			    vni >= 1u << 24)
+				invarg("invalid id", *argv);
+			vni_set = 1;
+		} else if (!matches(*argv, "dstadd")) {
+			NEXT_ARG();
+			remotes = addattr_nest(n, 1024, IFLA_VXLAN_REMOTES);
+			vxlan_parse_dstadd(&argc, &argv, n);
+			addattr_nest_end(n, remotes);
+		} else if (!matches(*argv, "dstdel")) {
+			NEXT_ARG();
+			remotes = addattr_nest(n, 1024, IFLA_VXLAN_REMOTES);
+			vxlan_parse_dstdel(&argc, &argv, n);
+			addattr_nest_end(n, remotes);
+		} else {
+			fprintf(stderr, "vxlan: unknown command \"%s\"?\n", *argv);
+			explain_change();
+			return -1;
+		}
+		argc--, argv++;
+	}
+
+	if (!vni_set) {
+		fprintf(stderr, "vxlan: missing virtual network identifier\n");
+		return -1;
+	}
+
+	return 0;
+}
+
 static int vxlan_parse_opt_create(struct link_util *lu, int argc, char **argv,
 				  struct nlmsghdr *n)
 {
@@ -190,7 +314,45 @@ static int vxlan_parse_opt_create(struct link_util *lu, int argc, char **argv,
 static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
-	return vxlan_parse_opt_create(lu, argc, argv, n);
+	if (n->nlmsg_flags & NLM_F_CREATE)
+		return vxlan_parse_opt_create(lu, argc, argv, n);
+
+	return vxlan_parse_opt_change(lu, argc, argv, n);
+}
+
+static void vxlan_print_remote(FILE *f, struct rtattr *attr)
+{
+	struct rtattr *tb[IFLA_VXLAN_REMOTE_MAX];
+	char s1[1024];
+
+	parse_rtattr_nested(tb, IFLA_VXLAN_REMOTE_MAX, attr);
+
+	if (tb[IFLA_VXLAN_REMOTE_ADDR]) {
+		struct rtattr *i = tb[IFLA_VXLAN_REMOTE_ADDR];
+		if (RTA_PAYLOAD(i) >= sizeof(struct in6_addr)) {
+			struct in6_addr addr;
+			memcpy(&addr, RTA_DATA(i), sizeof(struct in6_addr));
+			fprintf(f, "        %s\n",
+				format_host(AF_INET6, sizeof(struct in6_addr),
+					    &addr, s1, sizeof(s1)));
+		} else if (RTA_PAYLOAD(i) >= sizeof(__be32)) {
+			__be32 addr = rta_getattr_u32(i);
+			fprintf(f, "        %s\n",
+				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+		}
+	}
+}
+
+static void vxlan_print_remotes(FILE *f, struct rtattr *attr)
+{
+	struct rtattr *i;
+	int rem, n = 0;
+
+	fprintf(f, "\n      default destinations :\n");
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem), n++)
+		vxlan_print_remote(f, i);
 }
 
 static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
@@ -283,6 +445,9 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_LIMIT] &&
 	    (maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]) != 0))
 		    fprintf(f, "maxaddr %u ", maxaddr);
+
+	if (tb[IFLA_VXLAN_REMOTES])
+		vxlan_print_remotes(f, tb[IFLA_VXLAN_REMOTES]);
 }
 
 struct link_util vxlan_link_util = {
-- 
1.8.1.5
