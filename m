From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH iproute2] vxlan: allow specifying multiple default destinations
Date: Thu, 25 Apr 2013 14:04:40 +0300
Message-ID: <1366887880-4045-1-git-send-email-mike.rapoport@ravellosystems.com>
References: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:56793 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755522Ab3DYLEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 07:04:48 -0400
Received: by mail-lb0-f200.google.com with SMTP id t12so4076847lbi.7
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 04:04:46 -0700 (PDT)
In-Reply-To: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
This patch depends on the pending changes to ip/iplink_vxlan.c as as
well as on IPv6 support in vxlan. I'll rebase and resend it once all
the changes to vxlan are merged.

 ip/iplink_vxlan.c | 84 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 661ab9e..9ba5a1d 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -28,11 +28,56 @@ static void explain(void)
 	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
 	fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
+	fprintf(stderr, "                 [ dstadd DST ]\n");
+	fprintf(stderr, "                 [ dstdel ADDR ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: VNI := 0-16777215\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
 	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
 	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(stderr, "       DST  := [ ADDR [port PORT] [vni VNI] [via DEV]]\n");
+}
+
+static int vxlan_parse_dst(int *argcp, char ***argvp, struct nlmsghdr *n)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	__u32 vni, port, ifindex;
+	struct rtattr *tail;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, 1024, IFLA_VXLAN_REMOTE_ADD, NULL, 0);
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
+			if (get_u32(&port, *argv, 0))
+				invarg("port", *argv);
+			addattr32(n, 1024, IFLA_VXLAN_REMOTE_PORT, port);
+		} else if (!matches(*argv, "via")) {
+			NEXT_ARG();
+			ifindex = if_nametoindex(*argv);
+			addattr32(n, 1024, IFLA_VXLAN_REMOTE_IFINDEX, ifindex);
+		} else {
+			inet_prefix addr;
+			get_prefix(&addr, *argv, AF_UNSPEC);
+			addattr_l(n, 1024, IFLA_VXLAN_REMOTE_ADDR,
+				  &addr.data, addr.bytelen);
+		}
+		argc--, argv++;
+	}
+
+	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *)tail;
+
+	*argcp = argc;
+	*argvp = argv;
+	return 0;
 }
 
 static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
@@ -56,6 +101,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 age = 0;
 	__u32 maxaddr = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
+	inet_prefix *remote_del = NULL;
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -138,6 +184,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("max port", *argv);
 			range.low = htons(minport);
 			range.high = htons(maxport);
+		} else if (!matches(*argv, "dstadd")) {
+			NEXT_ARG();
+			vxlan_parse_dst(&argc, &argv, n);
+		} else if (!matches(*argv, "dstdel")) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_prefix(&addr, *argv, AF_UNSPEC);
+			remote_del = &addr;
 		} else if (!matches(*argv, "nolearning")) {
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
@@ -202,10 +256,37 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (range.low || range.high)
 		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
 			  &range, sizeof(range));
+	if (remote_del)
+		addattr_l(n, 1024, IFLA_VXLAN_REMOTE_DEL, remote_del->data,
+			  remote_del->bytelen);
 
 	return 0;
 }
 
+static void vxlan_print_remotes(FILE *f, struct rtattr *attr)
+{
+	struct rtattr *i;
+	char s1[1024];
+	int rem, n = 0;
+
+	fprintf(f, "\n      default destinations :\n");
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem), n++) {
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
 static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	__u32 vni;
@@ -308,6 +389,9 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_LIMIT] &&
 	    (maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]) != 0))
 		    fprintf(f, "maxaddr %u ", maxaddr);
+
+	if (tb[IFLA_VXLAN_REMOTE_LST])
+		vxlan_print_remotes(f, tb[IFLA_VXLAN_REMOTE_LST]);
 }
 
 struct link_util vxlan_link_util = {
-- 
1.8.1.5
