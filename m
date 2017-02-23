From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] iproute2: hide devices starting with period by default
Date: Thu, 23 Feb 2017 11:50:28 -0800
Message-ID: <20170223195028.16388-1-stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34994 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBWTud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 14:50:33 -0500
Received: by mail-pf0-f177.google.com with SMTP id 68so83189pfx.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 11:50:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some use cases create Linux networking devices which are not intended for use
by normal networking. This is an enhancement to ip command to hide network
devices starting with period (like files in normal directory).  Interfaces whose
name start with "." are not shown by default, and the -a (or -all) flag must
be used to show these devices.

Example:
$ ip -brief link show
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             00:25:90:86:b3:6b <BROADCAST,MULTICAST,UP,LOWER_UP>
eth1             DOWN           00:25:90:86:b3:6a <NO-CARRIER,BROADCAST,MULTICAST,UP>
$ ip -all -brief link show
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             00:25:90:86:b3:6b <BROADCAST,MULTICAST,UP,LOWER_UP>
eth1             DOWN           00:25:90:86:b3:6a <NO-CARRIER,BROADCAST,MULTICAST,UP>
.eth2            DOWN           00:1b:21:a0:e7:06 <BROADCAST,MULTICAST>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 include/utils.h |  1 +
 ip/ip.c         |  5 ++++-
 ip/ipaddress.c  | 31 ++++++++++++++++++++++++-------
 man/man8/ip.8   |  5 +++++
 4 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 22369e0b4e03..50712d27f112 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -16,6 +16,7 @@ extern int human_readable;
 extern int use_iec;
 extern int show_stats;
 extern int show_details;
+extern int show_all;
 extern int show_raw;
 extern int resolve_hosts;
 extern int oneline;
diff --git a/ip/ip.c b/ip/ip.c
index 07050b07592a..ed637b065b58 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -30,6 +30,7 @@ int human_readable;
 int use_iec;
 int show_stats;
 int show_details;
+int show_all;
 int resolve_hosts;
 int oneline;
 int brief;
@@ -54,7 +55,7 @@ static void usage(void)
 "                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |\n"
 "                   vrf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
-"                    -h[uman-readable] | -iec |\n"
+"                    -h[uman-readable] | -iec | -all |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } | -br[ief] |\n"
@@ -231,6 +232,8 @@ int main(int argc, char **argv)
 			++show_stats;
 		} else if (matches(opt, "-details") == 0) {
 			++show_details;
+		} else if (matches(opt, "-all") == 0) {
+			++show_all;
 		} else if (matches(opt, "-resolve") == 0) {
 			++resolve_hosts;
 		} else if (matches(opt, "-oneline") == 0) {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 400ebb4de563..029aae100549 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -660,6 +660,7 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
 	struct rtattr *tb[IFLA_MAX+1];
 	int len = n->nlmsg_len;
+	const char *ifname;
 	char *name;
 	char buf[32] = { 0, };
 	unsigned int m_flag = 0;
@@ -677,14 +678,22 @@ int print_linkinfo_brief(const struct sockaddr_nl *who,
 		return -1;
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
-	if (tb[IFLA_IFNAME] == NULL)
-		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n", ifi->ifi_index);
+	if (tb[IFLA_IFNAME])
+		ifname = rta_getattr_str(tb[IFLA_IFNAME]);
+	else {
+		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n",
+			ifi->ifi_index);
+		ifname = "<nil>";
+	}
 
 	if (filter.label &&
 	    (!filter.family || filter.family == AF_PACKET) &&
 	    fnmatch(filter.label, RTA_DATA(tb[IFLA_IFNAME]), 0))
 		return -1;
 
+	if (!filter.ifindex && *ifname == '.' && !show_all)
+		return 0;
+
 	if (tb[IFLA_GROUP]) {
 		int group = *(int *)RTA_DATA(tb[IFLA_GROUP]);
 
@@ -758,6 +767,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifi = NLMSG_DATA(n);
 	struct rtattr *tb[IFLA_MAX+1];
 	int len = n->nlmsg_len;
+	const char *ifname;
 	unsigned int m_flag = 0;
 
 	if (n->nlmsg_type != RTM_NEWLINK && n->nlmsg_type != RTM_DELLINK)
@@ -773,12 +783,20 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		return 0;
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
-	if (tb[IFLA_IFNAME] == NULL)
-		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n", ifi->ifi_index);
+	if (tb[IFLA_IFNAME])
+		ifname = rta_getattr_str(tb[IFLA_IFNAME]);
+	else {
+		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n",
+			ifi->ifi_index);
+		ifname = "<nil>";
+	}
 
 	if (filter.label &&
 	    (!filter.family || filter.family == AF_PACKET) &&
-	    fnmatch(filter.label, RTA_DATA(tb[IFLA_IFNAME]), 0))
+	    fnmatch(filter.label, ifname, 0))
+		return 0;
+
+	if (!filter.ifindex && *ifname == '.' && !show_all)
 		return 0;
 
 	if (tb[IFLA_GROUP]) {
@@ -806,8 +824,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "Deleted ");
 
 	fprintf(fp, "%d: ", ifi->ifi_index);
-	color_fprintf(fp, COLOR_IFNAME, "%s",
-		      tb[IFLA_IFNAME] ? rta_getattr_str(tb[IFLA_IFNAME]) : "<nil>");
+	color_fprintf(fp, COLOR_IFNAME, "%s", ifname);
 
 	if (tb[IFLA_LINK]) {
 		SPRINT_BUF(b1);
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8ecb1996da92..813dbec2a6f2 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -31,6 +31,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 \fB\-h\fR[\fIuman-readable\fR] |
 \fB\-s\fR[\fItatistics\fR] |
 \fB\-d\fR[\fIetails\fR] |
+\fB\-a\fR[\fll\fR] |
 \fB\-r\fR[\fIesolve\fR] |
 \fB\-iec\fR |
 \fB\-f\fR[\fIamily\fR] {
@@ -84,6 +85,10 @@ As a rule, the information is statistics or some time values.
 Output more detailed information.
 
 .TP
+.BR "\-a" , " \-all"
+Show all devices, do not ignore entries starting with period.
+
+.TP
 .BR "\-l" , " \-loops " <COUNT>
 Specify maximum number of loops the 'ip address flush' logic
 will attempt before giving up. The default is 10.
-- 
2.11.0
