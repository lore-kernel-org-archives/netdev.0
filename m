From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2] ip link: Show devices by type
Date: Wed,  3 Dec 2014 16:56:38 +0200
Message-ID: <1417618598-23605-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:48486 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaLCPGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 10:06:21 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so31693243wiv.12
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 07:06:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added new option 'type' to 'ip link show'
command which allows to filter devices by type:

    ip link show type bridge
    ip link show type vlan

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipaddress.c        | 26 ++++++++++++++++++++++++++
 ip/iplink.c           |  2 +-
 man/man8/ip-link.8.in | 20 +++++++++++++++++++-
 3 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d99324..4ffac81 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -57,6 +57,7 @@ static struct
 	int flushe;
 	int group;
 	int master;
+	char *kind;
 } filter;
 
 static int do_link;
@@ -189,6 +190,18 @@ static void print_linkmode(FILE *f, struct rtattr *tb)
 		fprintf(f, "mode %s ", link_modes[mode]);
 }
 
+static char *parse_link_kind(struct rtattr *tb)
+{
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+
+	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
+
+	if (linkinfo[IFLA_INFO_KIND])
+		return RTA_DATA(linkinfo[IFLA_INFO_KIND]);
+
+	return "";
+}
+
 static void print_linktype(FILE *fp, struct rtattr *tb)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
@@ -551,6 +564,16 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	else if (filter.master > 0)
 		return -1;
 
+	if (filter.kind) {
+		if (tb[IFLA_LINKINFO]) {
+			char *kind = parse_link_kind(tb[IFLA_LINKINFO]);
+			if (strcmp(kind, filter.kind))
+				return -1;
+		} else {
+			return -1;
+		}
+	}
+
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
 
@@ -1293,6 +1316,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			if (!ifindex)
 				invarg("Device does not exist\n", *argv);
 			filter.master = ifindex;
+		} else if (do_link && strcmp(*argv, "type") == 0) {
+			NEXT_ARG();
+			filter.kind = *argv;
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index ce6eb3e..f9a75d5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -82,7 +82,7 @@ void iplink_usage(void)
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
-	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "       ip link help [ TYPE ]\n");
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 9d4e3da..7678065 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -148,7 +148,9 @@ ip-link \- network device configuration
 .IR GROUP " | "
 .BR up " | "
 .B master
-.IR DEVICE " ]"
+.IR DEVICE " | "
+.B type
+.IR TYPE " ]"
 
 .ti -8
 .B ip link help
@@ -688,6 +690,12 @@ only display running interfaces.
 .I DEVICE
 specifies the master device which enslaves devices to show.
 
+.TP
+.BI type " TYPE "
+.I TYPE
+specifies the type of devices to show.
+
+.TP
 The show command has additional formatting options:
 
 .TP
@@ -719,6 +727,16 @@ ip link show
 Shows the state of all network interfaces on the system.
 .RE
 .PP
+ip link show type bridge
+.RS 4
+Shows the bridge devices.
+.RE
+.PP
+ip link show type vlan
+.RS 4
+Shows the vlan devices.
+.RE
+.PP
 ip link set dev ppp0 mtu 1400
 .RS 4
 Change the MTU the ppp0 device.
-- 
2.1.3
