From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2] ip link: Allow to filter devices by master dev
Date: Thu, 30 Oct 2014 11:02:55 +0200
Message-ID: <1414659775-30280-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:51327 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbaJ3JMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 05:12:03 -0400
Received: by mail-wi0-f179.google.com with SMTP id h11so6736743wiw.12
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 02:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 'master' option to 'ip link show' command
to filter devices by master dev.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipaddress.c        | 16 ++++++++++++++++
 ip/iplink.c           |  2 +-
 man/man8/ip-link.8.in | 12 +++++++++---
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 45729d8..8a0e2ab 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -56,6 +56,7 @@ static struct
 	int flushp;
 	int flushe;
 	int group;
+	int master;
 } filter;
 
 static int do_link;
@@ -480,6 +481,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			return -1;
 	}
 
+	if (tb[IFLA_MASTER]) {
+		int master = *(int*)RTA_DATA(tb[IFLA_MASTER]);
+		if (filter.master > 0 && master != filter.master)
+			return -1;
+	}
+	else if (filter.master > 0)
+		return -1;
+
 	if (n->nlmsg_type == RTM_DELLINK)
 		fprintf(fp, "Deleted ");
 
@@ -1215,6 +1224,13 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 			NEXT_ARG();
 			if (rtnl_group_a2n(&filter.group, *argv))
 				invarg("Invalid \"group\" value\n", *argv);
+		} else if (strcmp(*argv, "master") == 0) {
+			int ifindex;
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Device does not exist\n", *argv);
+			filter.master = ifindex;
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index 43b26f4..ce6eb3e 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -82,7 +82,7 @@ void iplink_usage(void)
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
 	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
-	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
+	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "       ip link help [ TYPE ]\n");
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 464009d..ce00119 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -144,9 +144,10 @@ ip-link \- network device configuration
 .B ip link show
 .RI "[ " DEVICE " | "
 .B group
-.IR GROUP " |"
-.B up
-]
+.IR GROUP " | "
+.BR up " | "
+.B master
+.IR DEVICE " ]"
 
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
@@ -660,6 +661,11 @@ specifies what group of devices to show.
 .B up
 only display running interfaces.
 
+.TP
+.BI master " DEVICE "
+.I DEVICE
+specifies the master device which enslaves devices to show.
+
 .SH "EXAMPLES"
 .PP
 ip link show
-- 
2.1.0
