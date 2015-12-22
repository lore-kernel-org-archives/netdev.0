From: Lorenzo Colitti <lorenzo@google.com>
Subject: [iproute PATCH v3 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Tue, 22 Dec 2015 17:31:34 +0900
Message-ID: <1450773094-7978-3-git-send-email-lorenzo@google.com>
References: <20151221214222.5ee87383@xeon-e3>
 <1450773094-7978-1-git-send-email-lorenzo@google.com>
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	zenczykowski@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33013 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbbLVIcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 03:32:21 -0500
Received: by mail-pf0-f178.google.com with SMTP id n128so86332656pfn.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 00:32:21 -0800 (PST)
In-Reply-To: <1450773094-7978-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a -K / --kill option to ss that attempts to
forcibly close matching sockets using SOCK_DESTROY.

Because ss typically prints sockets instead of acting on them,
and because the kernel only supports forcibly closing some types
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
 misc/ss.c                 | 50 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 49 insertions(+), 2 deletions(-)

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
index 0dab32c..4d60f14 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -160,6 +160,7 @@ struct filter
 	int states;
 	int families;
 	struct ssfilter *f;
+	bool kill;
 };
 
 static const struct filter default_dbs[MAX_DB] = {
@@ -2194,8 +2195,27 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
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
+	req.nlh.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
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
@@ -2205,6 +2225,15 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
+	if (diag_arg->f->kill && kill_inet_sock(addr, h, arg) != 0) {
+		if (errno == EOPNOTSUPP || errno == ENOENT) {
+			/* Socket can't be closed, or is already closed. */
+			return 0;
+		} else {
+			perror("SOCK_DESTROY answers");
+			return -1;
+		}
+	}
 	if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
 		return err;
 
@@ -2214,12 +2243,21 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
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
+	if (f->kill) {
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
@@ -2243,6 +2281,8 @@ again:
 
 Exit:
 	rtnl_close(&rth);
+	if (arg.rth)
+		rtnl_close(arg.rth);
 	return err;
 }
 
@@ -3489,6 +3529,8 @@ static void _usage(FILE *dest)
 "   -x, --unix          display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
+"   -K, --kill          forcibly close sockets, display what was closed\n"
+"\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
 "       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
 "\n"
@@ -3579,6 +3621,7 @@ static const struct option long_opts[] = {
 	{ "context", 0, 0, 'Z' },
 	{ "contexts", 0, 0, 'z' },
 	{ "net", 1, 0, 'N' },
+	{ "kill", 0, 0, 'K' },
 	{ 0 }
 
 };
@@ -3593,7 +3636,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:K",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3774,6 +3817,9 @@ int main(int argc, char *argv[])
 			if (netns_switch(optarg))
 				exit(1);
 			break;
+		case 'K':
+			current_filter.kill = 1;
+			break;
 		case 'h':
 			help();
 		case '?':
-- 
2.6.0.rc2.230.g3dd15c0
