From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iproute PATCH v2 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Thu, 17 Dec 2015 22:22:18 +0900
Message-ID: <1450358538-134898-2-git-send-email-lorenzo@google.com>
References: <1450358538-134898-1-git-send-email-lorenzo@google.com>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36254 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934753AbbLQNW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 08:22:56 -0500
Received: by mail-pa0-f44.google.com with SMTP id q3so22445906pav.3
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 05:22:56 -0800 (PST)
In-Reply-To: <1450358538-134898-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a -K / --kill option to ss that attempts to
forcibly close matching sockets using SOCK_DESTROY.

This is implemented by adding a new "struct action" to struct
filter. If necessary, this can be extended later on to support
further actions on sockets.

Because ss typically prints sockets instead of acting on them,
and because the kernel only suppors forcibly closing some types
of sockets, the output of -K is as follows:

- If closing the socket succeeds, the socket is printed.
- If the kernel does not support forcibly closing this type of
  socket (e.g., if it's a UDP socket, or a TIME_WAIT socket),
  the socket is silently skipped.
- If an error occurs (e.g., permission denied), the error is
  reported and ss exits.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/sock_diag.h |  1 +
 misc/ss.c                 | 52 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 51 insertions(+), 2 deletions(-)

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
index 0dab32c..be70c41 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -160,6 +160,9 @@ struct filter
 	int states;
 	int families;
 	struct ssfilter *f;
+	struct {
+		__u8 kill:1;
+	} action;
 };
 
 static const struct filter default_dbs[MAX_DB] = {
@@ -2194,8 +2197,27 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 struct inet_diag_arg {
 	struct filter *f;
 	int protocol;
+	struct rtnl_handle *rth;
 };
 
+static int kill_inet_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *h, void *arg)
+{
+	struct inet_diag_msg *d = NLMSG_DATA(h);
+	struct inet_diag_arg *diag_arg = arg;
+	struct rtnl_handle *rth = diag_arg->rth;
+	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
+
+	req.nlh.nlmsg_type = SOCK_DESTROY;
+	req.nlh.nlmsg_flags = NLM_F_REQUEST;
+	req.nlh.nlmsg_seq = ++rth->seq;
+	req.r.sdiag_family = d->idiag_family;
+	req.r.sdiag_protocol = diag_arg->protocol;
+	req.r.id = d->id;
+
+	return rtnl_send_check_ack(rth, &req.nlh, req.nlh.nlmsg_len, 1);
+}
+
 static int show_one_inet_sock(const struct sockaddr_nl *addr,
 		struct nlmsghdr *h, void *arg)
 {
@@ -2205,6 +2227,15 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
+	if (diag_arg->f->action.kill && kill_inet_sock(addr, h, arg) != 0) {
+		if (errno == EOPNOTSUPP) {
+			/* This socket can't be closed. Silently skip it. */
+			return 0;
+		} else {
+			perror("SOCK_DESTROY answers");
+			return -1;
+		}
+	}
 	if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
 		return err;
 
@@ -2214,12 +2245,21 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 {
 	int err = 0;
-	struct rtnl_handle rth;
+	struct rtnl_handle rth, rth2;
 	int family = PF_INET;
 	struct inet_diag_arg arg = { .f = f, .protocol = protocol };
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_SOCK_DIAG))
 		return -1;
+
+	if (f->action.kill) {
+		if (rtnl_open_byproto(&rth2, 0, NETLINK_SOCK_DIAG)) {
+			rtnl_close(&rth);
+			return -1;
+		}
+		arg.rth = &rth2;
+	}
+
 	rth.dump = MAGIC_SEQ;
 	rth.dump_fp = dump_fp;
 	if (preferred_family == PF_INET6)
@@ -2243,6 +2283,8 @@ again:
 
 Exit:
 	rtnl_close(&rth);
+	if (arg.rth)
+		rtnl_close(arg.rth);
 	return err;
 }
 
@@ -3489,6 +3531,8 @@ static void _usage(FILE *dest)
 "   -x, --unix          display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
+"   -K, --kill          forcibly close sockets, display what was closed\n"
+"\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
 "\n"
@@ -3579,6 +3623,7 @@ static const struct option long_opts[] = {
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
 	{ "net", 1, 0, 'N' },
+	{ "kill", 0, 0, 'K' },
 	{ 0 }
 
 };
@@ -3593,7 +3638,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:K",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3774,6 +3819,9 @@ int main(int argc, char *argv[])
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
