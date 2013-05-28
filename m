From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH iproute2] vxlan: allow specifying multiple default destinations
Date: Tue, 28 May 2013 11:33:04 +0300
Message-ID: <1369729984-9802-1-git-send-email-mike.rapoport@ravellosystems.com>
References: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog110.obsmtp.com ([74.125.245.88]:52882 "HELO
	na3sys010aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933484Ab3E1IdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:33:12 -0400
Received: by mail-ee0-f41.google.com with SMTP id d4so4499005eek.0
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:33:10 -0700 (PDT)
In-Reply-To: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 ip/iplink_vxlan.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 1025326..89ca3c2 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -28,11 +28,57 @@ static void explain(void)
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
+	__u32 vni, ifindex;
+	__u16 port;
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
@@ -54,6 +100,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 age = 0;
 	__u32 maxaddr = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
+	inet_prefix *remote_del = NULL;
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -125,6 +172,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
@@ -183,10 +238,37 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
@@ -277,6 +359,9 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
