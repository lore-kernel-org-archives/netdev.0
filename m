From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH iproute2 v2] add support for brief output for link and addresses
Date: Mon, 24 Aug 2015 21:16:15 -0400
Message-ID: <1440465375-24493-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemming@brocade.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33376 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbbHYB05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 21:26:57 -0400
Received: by pdrh1 with SMTP id h1so60925251pdr.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 18:26:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for slightly less output than is normally provided by
'ip link show' and 'ip addr show'.  This is a bit better when you have =
a
host with lots of interfaces.  Sample output:

$ ip -br link show
lo               UNKNOWN  00:00:00:00:00:00  <LOOPBACK,UP,LOWER_UP>
p7p1             UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LO=
WER_UP>
p8p1             DOWN     08:00:27:dc:d8:ca  <NO-CARRIER,BROADCAST,MULT=
ICAST,UP>
p9p1             UP       08:00:27:76:d9:75  <BROADCAST,MULTICAST,UP,LO=
WER_UP>
p7p1.100@p7p1    UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LO=
WER_UP>

$ ip -br -4 addr show
lo               UNKNOWN  127.0.0.1/8
p7p1             UP       70.0.0.1/24
p8p1             DOWN     80.0.0.1/24
p7p1.100@p7p1    UP       200.0.0.1/24

$ ip -br -6 addr show
lo               UNKNOWN  ::1/128
p7p1             UP       7000::1/8 fe80::a00:27ff:fe9d:629f/64
p8p1             DOWN     8000::1/8
p9p1             UP       fe80::a00:27ff:fe76:d975/64
p7p1.100@p7p1    UP       fe80::a00:27ff:fe9d:629f/64

$ ip -br  addr show p7p1
p7p1             UP       70.0.0.1/24 7000::1/8 fe80::a00:27ff:fe9d:629=
f/64

v2: Now with color support!

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 include/utils.h       |   1 +
 ip/ip.c               |   5 +-
 ip/ip_common.h        |   3 +
 ip/ipaddress.c        | 155 ++++++++++++++++++++++++++++++++++++++++++=
+-------
 ip/iplink.c           |   5 +-
 man/man8/ip-link.8.in |   3 +-
 6 files changed, 147 insertions(+), 25 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 0c57ccd..f77edeb 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -19,6 +19,7 @@ extern int show_details;
 extern int show_raw;
 extern int resolve_hosts;
 extern int oneline;
+extern int brief;
 extern int timestamp;
 extern int timestamp_short;
 extern const char * _SL_;
diff --git a/ip/ip.c b/ip/ip.c
index e75447e..eea00b8 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -32,6 +32,7 @@ int show_stats;
 int show_details;
 int resolve_hosts;
 int oneline;
+int brief;
 int timestamp;
 const char *_SL_;
 int force;
@@ -55,7 +56,7 @@ static void usage(void)
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | br=
idge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
-"                    -l[oops] { maximum-addr-flush-attempts } |\n"
+"                    -l[oops] { maximum-addr-flush-attempts } | -br[ie=
f] |\n"
 "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] =
[filename] |\n"
 "                    -rc[vbuf] [size] | -n[etns] name | -a[ll] |=C2=A0=
-c[olor]}\n");
 	exit(-1);
@@ -250,6 +251,8 @@ int main(int argc, char **argv)
 			if (argc <=3D 1)
 				usage();
 			batch_file =3D argv[1];
+		} else if (matches(opt, "-brief") =3D=3D 0) {
+			++brief;
 		} else if (matches(opt, "-rcvbuf") =3D=3D 0) {
 			unsigned int size;
=20
diff --git a/ip/ip_common.h b/ip/ip_common.h
index f120f5b..f74face 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -2,6 +2,9 @@ extern int get_operstate(const char *name);
 extern int print_linkinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
+extern int print_linkinfo_brief(const struct sockaddr_nl *who,
+				struct nlmsghdr *n,
+				void *arg);
 extern int print_addrinfo(const struct sockaddr_nl *who,
 			  struct nlmsghdr *n,
 			  void *arg);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 13d9c46..bb44a55 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -125,7 +125,10 @@ static void print_link_flags(FILE *fp, unsigned fl=
ags, unsigned mdown)
 		fprintf(fp, "%x", flags);
 	if (mdown)
 		fprintf(fp, ",M-DOWN");
-	fprintf(fp, "> ");
+	if (brief)
+		fprintf(fp, ">");
+	else
+		fprintf(fp, "> ");
 }
=20
 static const char *oper_states[] =3D {
@@ -138,13 +141,22 @@ static void print_operstate(FILE *f, __u8 state)
 	if (state >=3D sizeof(oper_states)/sizeof(oper_states[0]))
 		fprintf(f, "state %#x ", state);
 	else {
-		fprintf(f, "state ");
-		if (strcmp(oper_states[state], "UP") =3D=3D 0)
-			color_fprintf(f, COLOR_OPERSTATE_UP, "%s ", oper_states[state]);
-		else if (strcmp(oper_states[state], "DOWN") =3D=3D 0)
-			color_fprintf(f, COLOR_OPERSTATE_DOWN, "%s ", oper_states[state]);
-		else
-			fprintf(f, "%s ", oper_states[state]);
+		if (brief) {
+			if (strcmp(oper_states[state], "UP") =3D=3D 0)
+				color_fprintf(f, COLOR_OPERSTATE_UP, "%-7s  ", oper_states[state])=
;
+			else if (strcmp(oper_states[state], "DOWN") =3D=3D 0)
+				color_fprintf(f, COLOR_OPERSTATE_DOWN, "%-7s  ", oper_states[state=
]);
+			else
+				fprintf(f, "%-7s  ", oper_states[state]);
+		} else {
+			fprintf(f, "state ");
+			if (strcmp(oper_states[state], "UP") =3D=3D 0)
+				color_fprintf(f, COLOR_OPERSTATE_UP, "%s ", oper_states[state]);
+			else if (strcmp(oper_states[state], "DOWN") =3D=3D 0)
+				color_fprintf(f, COLOR_OPERSTATE_DOWN, "%s ", oper_states[state]);
+			else
+				fprintf(f, "%s ", oper_states[state]);
+		}
 	}
 }
=20
@@ -590,6 +602,88 @@ static void print_link_stats(FILE *fp, struct nlms=
ghdr *n)
 	fprintf(fp, "%s", _SL_);
 }
=20
+int print_linkinfo_brief(const struct sockaddr_nl *who,
+				struct nlmsghdr *n, void *arg)
+{
+	FILE *fp =3D (FILE*)arg;
+	struct ifinfomsg *ifi =3D NLMSG_DATA(n);
+	struct rtattr * tb[IFLA_MAX+1];
+	int len =3D n->nlmsg_len;
+	char *name;
+	char buf[32] =3D { 0, };
+	unsigned m_flag =3D 0;
+
+	if (n->nlmsg_type !=3D RTM_NEWLINK && n->nlmsg_type !=3D RTM_DELLINK)
+		return -1;
+
+	len -=3D NLMSG_LENGTH(sizeof(*ifi));
+	if (len < 0)
+		return -1;
+
+	if (filter.ifindex && ifi->ifi_index !=3D filter.ifindex)
+		return -1;
+	if (filter.up && !(ifi->ifi_flags&IFF_UP))
+		return -1;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+	if (tb[IFLA_IFNAME] =3D=3D NULL) {
+		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n", ifi-=
>ifi_index);
+	}
+	if (filter.label &&
+	    (!filter.family || filter.family =3D=3D AF_PACKET) &&
+	    fnmatch(filter.label, RTA_DATA(tb[IFLA_IFNAME]), 0))
+		return -1;
+
+	if (tb[IFLA_GROUP]) {
+		int group =3D *(int*)RTA_DATA(tb[IFLA_GROUP]);
+		if (filter.group !=3D -1 && group !=3D filter.group)
+			return -1;
+	}
+
+	if (n->nlmsg_type =3D=3D RTM_DELLINK)
+		fprintf(fp, "Deleted ");
+
+	name =3D (char *)(tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) =
: "<nil>");
+
+	if (tb[IFLA_LINK]) {
+		SPRINT_BUF(b1);
+		int iflink =3D *(int*)RTA_DATA(tb[IFLA_LINK]);
+		if (iflink =3D=3D 0)
+			snprintf(buf, sizeof(buf), "%s@NONE", name);
+		else {
+			snprintf(buf, sizeof(buf),
+				 "%s@%s", name, ll_idx_n2a(iflink, b1));
+			m_flag =3D ll_index_to_flags(iflink);
+			m_flag =3D !(m_flag & IFF_UP);
+		}
+	} else
+		snprintf(buf, sizeof(buf), "%s", name);
+
+	fprintf(fp, "%-16s ", buf);
+
+	if (tb[IFLA_OPERSTATE])
+		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
+
+	if (filter.family =3D=3D AF_PACKET) {
+		SPRINT_BUF(b1);
+		if (tb[IFLA_ADDRESS]) {
+			color_fprintf(fp, COLOR_MAC, "%s",
+					ll_addr_n2a(RTA_DATA(tb[IFLA_ADDRESS]),
+						RTA_PAYLOAD(tb[IFLA_ADDRESS]),
+						ifi->ifi_type,
+						b1, sizeof(b1)));
+		}
+	}
+
+	if (filter.family =3D=3D AF_PACKET)
+		print_link_flags(fp, ifi->ifi_flags, m_flag);
+
+	if (filter.family =3D=3D AF_PACKET)
+		fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -892,18 +986,20 @@ int print_addrinfo(const struct sockaddr_nl *who,=
 struct nlmsghdr *n,
 	if (n->nlmsg_type =3D=3D RTM_DELADDR)
 		fprintf(fp, "Deleted ");
=20
-	if (filter.oneline || filter.flushb)
-		fprintf(fp, "%u: %s", ifa->ifa_index, ll_index_to_name(ifa->ifa_inde=
x));
-	if (ifa->ifa_family =3D=3D AF_INET)
-		fprintf(fp, "    inet ");
-	else if (ifa->ifa_family =3D=3D AF_INET6)
-		fprintf(fp, "    inet6 ");
-	else if (ifa->ifa_family =3D=3D AF_DECnet)
-		fprintf(fp, "    dnet ");
-	else if (ifa->ifa_family =3D=3D AF_IPX)
-		fprintf(fp, "     ipx ");
-	else
-		fprintf(fp, "    family %d ", ifa->ifa_family);
+	if (!brief) {
+		if (filter.oneline || filter.flushb)
+			fprintf(fp, "%u: %s", ifa->ifa_index, ll_index_to_name(ifa->ifa_ind=
ex));
+		if (ifa->ifa_family =3D=3D AF_INET)
+			fprintf(fp, "    inet ");
+		else if (ifa->ifa_family =3D=3D AF_INET6)
+			fprintf(fp, "    inet6 ");
+		else if (ifa->ifa_family =3D=3D AF_DECnet)
+			fprintf(fp, "    dnet ");
+		else if (ifa->ifa_family =3D=3D AF_IPX)
+			fprintf(fp, "     ipx ");
+		else
+			fprintf(fp, "    family %d ", ifa->ifa_family);
+	}
=20
 	if (rta_tb[IFA_LOCAL]) {
 		if (ifa->ifa_family =3D=3D AF_INET)
@@ -936,6 +1032,9 @@ int print_addrinfo(const struct sockaddr_nl *who, =
struct nlmsghdr *n,
 		}
 	}
=20
+	if (brief)
+		goto brief_exit;
+
 	if (rta_tb[IFA_BROADCAST]) {
 		fprintf(fp, "brd %s ",
 			format_host(ifa->ifa_family,
@@ -1018,6 +1117,7 @@ int print_addrinfo(const struct sockaddr_nl *who,=
 struct nlmsghdr *n,
 		}
 	}
 	fprintf(fp, "\n");
+brief_exit:
 	fflush(fp);
 	return 0;
 }
@@ -1078,6 +1178,10 @@ static int print_selected_addrinfo(struct ifinfo=
msg *ifi,
=20
 		print_addrinfo(NULL, n, fp);
 	}
+	if (brief) {
+		fprintf(fp, "\n");
+		fflush(fp);
+	}
 	return 0;
 }
=20
@@ -1539,9 +1643,16 @@ static int ipaddr_list_flush_or_save(int argc, c=
har **argv, int action)
=20
 	for (l =3D linfo.head; l; l =3D l->next) {
 		int res =3D 0;
+		struct ifinfomsg *ifi =3D NLMSG_DATA(&l->h);
=20
-		if (no_link || (res =3D print_linkinfo(NULL, &l->h, stdout)) >=3D 0)=
 {
-			struct ifinfomsg *ifi =3D NLMSG_DATA(&l->h);
+		if (brief) {
+			if (print_linkinfo_brief(NULL, &l->h, stdout) =3D=3D 0)
+				if (filter.family !=3D AF_PACKET)
+					print_selected_addrinfo(ifi,
+								ainfo.head,
+								stdout);
+		} else if (no_link ||
+			 (res =3D print_linkinfo(NULL, &l->h, stdout)) >=3D 0) {
 			if (filter.family !=3D AF_PACKET)
 				print_selected_addrinfo(ifi,
 							ainfo.head, stdout);
diff --git a/ip/iplink.c b/ip/iplink.c
index 8bc9f49..633b067 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -823,7 +823,10 @@ int iplink_get(unsigned int flags, char *name, __u=
32 filt_mask)
 	if (rtnl_talk(&rth, &req.n, &answer.n, sizeof(answer)) < 0)
 		return -2;
=20
-	print_linkinfo(NULL, &answer.n, stdout);
+	if (brief)
+		print_linkinfo_brief(NULL, &answer.n, stdout);
+	else
+		print_linkinfo(NULL, &answer.n, stdout);
=20
 	return 0;
 }
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 2f689ed..8732ea7 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -21,7 +21,8 @@ ip-link \- network device configuration
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-f\fR[\fIamily\fR] {
 .BR inet " | " inet6 " | " ipx " | " dnet " | " link " } | "
-\fB\-o\fR[\fIneline\fR] }
+\fB\-o\fR[\fIneline\fR] |
+\fB\-br\fR[\fIief\fR] }
=20
 .ti -8
 .BI "ip link add"
--=20
1.9.3
