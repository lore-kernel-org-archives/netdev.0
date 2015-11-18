From: Lorenzo Colitti <lorenzo@google.com>
Subject: [ss PATCH 2/2] ss: support closing inet sockets via SOCK_DIAG.
Date: Wed, 18 Nov 2015 10:52:10 +0900
Message-ID: <1447811530-10756-3-git-send-email-lorenzo@google.com>
References: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35234 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077AbbKRBwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:52:33 -0500
Received: by pacej9 with SMTP id ej9so27026530pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:52:33 -0800 (PST)
In-Reply-To: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Invoking ss with -K or --kill attempts to forcibly close matching
inet sockets using SOCK_DESTROY.

This is implemented by adding a new "struct action" to struct
filter. If necessary, this can be extended later on to support
further actions on sockets.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/sock_diag.h |  1 +
 misc/ss.c                 | 38 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 024e1f4..dafcb89 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 
 #define SOCK_DIAG_BY_FAMILY 20
+#define SOCK_DESTROY 21
 
 struct sock_diag_req {
 	__u8	sdiag_family;
diff --git a/misc/ss.c b/misc/ss.c
index a9ae85e..d62f741 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -154,12 +154,18 @@ enum {
 
 #include "ssfilter.h"
 
+struct action
+{
+	int kill;
+};
+
 struct filter
 {
 	int dbs;
 	int states;
 	int families;
 	struct ssfilter *f;
+	struct action action;
 };
 
 static const struct filter default_dbs[MAX_DB] = {
@@ -2197,6 +2203,27 @@ struct inet_diag_arg {
 	int protocol;
 };
 
+static int kill_inet_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *h, void *arg)
+{
+	struct rtnl_handle rth;
+	if (rtnl_open_byproto(&rth, 0, NETLINK_SOCK_DIAG))
+		return -1;
+
+	struct inet_diag_arg *diag_arg = arg;
+	struct inet_diag_msg *d = NLMSG_DATA(h);
+	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
+	req.nlh.nlmsg_type = SOCK_DESTROY;
+	req.nlh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	req.r.sdiag_family = d->idiag_family;
+	req.r.sdiag_protocol = diag_arg->protocol;
+	req.r.id = d->id;
+
+	int err = rtnl_talk(&rth, &req.nlh, NULL, 0);
+	rtnl_close(&rth);
+	return err;
+}
+
 static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *h, void *arg)
 {
@@ -2208,7 +2235,8 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		return 0;
 	if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
 		return err;
-
+	if (diag_arg->f->action.kill && (err = kill_inet_sock(addr, h, arg)))
+		return err;
 	return 0;
 }
 
@@ -3484,6 +3512,8 @@ static void _usage(FILE *dest)
 "   -x, --unix          display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
+"   -K, --kill          forcibly close sockets instead of displaying them\n"
+"\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
 "\n"
@@ -3574,6 +3604,7 @@ static const struct option long_opts[] = {
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
 	{ "net", 1, 0, 'N' },
+	{ "kill", 0, 0, 'K' },
 	{ 0 }
 
 };
@@ -3588,7 +3619,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:K",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3769,6 +3800,9 @@ int main(int argc, char *argv[])
 			if (netns_switch(optarg))
 				exit(1);
 			break;
+		case 'K':
+			current_filter.action.kill = 1;
+			break;
 		case 'h':
 			help();
 		case '?':
-- 
2.6.0.rc2.230.g3dd15c0
