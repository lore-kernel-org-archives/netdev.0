From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip link: Allow to filter devices by master dev
Date: Sun, 19 Oct 2014 17:04:48 +0300
Message-ID: <1413727488-18032-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:38984 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbaJSONo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 10:13:44 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so2709633lam.32
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 07:13:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added 'master' option to 'ip link show' command
to filter devices by master dev.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipaddress.c        | 16 ++++++++++++++++
 ip/iplink.c           |  2 +-
 man/man8/ip-link.8.in |  9 ++++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

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
index 383917a..279fe39 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -144,7 +144,9 @@ ip-link \- network device configuration
 .B ip link show
 .RI "[ " DEVICE " | "
 .B group
-.IR GROUP " ]"
+.IR GROUP " | "
+.B master
+.IR DEVICE " ]"
 
 .SH "DESCRIPTION"
 .SS ip link add - add virtual link
@@ -658,6 +660,11 @@ specifies what group of devices to show.
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
