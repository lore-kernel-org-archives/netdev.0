From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 6/6] xfrmmonitor: allows to monitor in several netns
Date: Wed, 20 May 2015 16:20:01 +0200
Message-ID: <1432131601-4641-7-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44046 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbbETOUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:11 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch, it's now possible to listen in all netns that have an nsid
assigned into the netns where is socket is opened.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/xfrm_monitor.c  | 14 +++++++++++++-
 man/man8/ip-xfrm.8 | 21 ++++++++++++++++++++-
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 2119c51d92ac..ebccb71c688e 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -35,10 +35,11 @@
 #include "ip_common.h"
 
 static void usage(void) __attribute__((noreturn));
+int listen_all_nsid;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm monitor [ all | OBJECTS | help ]\n");
+	fprintf(stderr, "Usage: ip xfrm monitor [all-nsid] [ all | OBJECTS | help ]\n");
 	fprintf(stderr, "OBJECTS := { acquire | expire | SA | aevent | policy | report }\n");
 	exit(-1);
 }
@@ -298,6 +299,13 @@ static int xfrm_accept_msg(const struct sockaddr_nl *who,
 	if (timestamp)
 		print_timestamp(fp);
 
+	if (listen_all_nsid) {
+		if (ctrl == NULL || ctrl->nsid < 0)
+			fprintf(fp, "[nsid current]");
+		else
+			fprintf(fp, "[nsid %d]", ctrl->nsid);
+	}
+
 	switch (n->nlmsg_type) {
 	case XFRM_MSG_NEWSA:
 	case XFRM_MSG_DELSA:
@@ -360,6 +368,8 @@ int do_xfrm_monitor(int argc, char **argv)
 		if (matches(*argv, "file") == 0) {
 			NEXT_ARG();
 			file = *argv;
+		} else if (matches(*argv, "all-nsid") == 0) {
+			listen_all_nsid = 1;
 		} else if (matches(*argv, "acquire") == 0) {
 			lacquire=1;
 			groups = 0;
@@ -412,6 +422,8 @@ int do_xfrm_monitor(int argc, char **argv)
 
 	if (rtnl_open_byproto(&rth, groups, NETLINK_XFRM) < 0)
 		exit(1);
+	if (listen_all_nsid && rtnl_listen_all_nsid(&rth) < 0)
+		exit(1);
 
 	if (rtnl_listen(&rth, xfrm_accept_msg, (void*)stdout) < 0)
 		exit(2);
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 29b397f35959..489ab6ed4964 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -364,7 +364,11 @@ ip-xfrm \- transform configuration
 .BR required " | " use
 
 .ti -8
-.BR "ip xfrm monitor" " [ " all " |"
+.BR "ip xfrm monitor" " ["
+.BI all-nsid
+] [
+.BI all
+ |
 .IR LISTofXFRM-OBJECTS " ]"
 
 .ti -8
@@ -669,7 +673,22 @@ ip xfrm monitor 	state monitoring for xfrm objects
 .PP
 The xfrm objects to monitor can be optionally specified.
 
+.P
+If the
+.BI all-nsid
+option is set, the program listens to all network namespaces that have a
+nsid assigned into the network namespace were the program is running.
+A prefix is displayed to show the network namespace where the message
+originates. Example:
+.sp
+.in +2
+[nsid 1]Flushed state proto 0
+.in -2
+.sp
+
 .SH AUTHOR
 Manpage revised by David Ward <david.ward@ll.mit.edu>
 .br
 Manpage revised by Christophe Gouault <christophe.gouault@6wind.com>
+.br
+Manpage revised by Nicolas Dichtel <nicolas.dichtel@6wind.com>
-- 
2.2.2
