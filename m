From: Craig Gallek <kraig@google.com>
Subject: [PATCH iproute2 v2] ss: Include -E option for socket destroy events
Date: Wed, 17 Jun 2015 11:14:48 -0400
Message-ID: <1434554088-10200-1-git-send-email-kraig@google.com>
Cc: stephen@networkplumber.org, edumazet@google.com,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36772 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbbFQPPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:15:04 -0400
Received: by ykdr198 with SMTP id r198so42597162ykd.3
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 08:15:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the IPv4/IPv6/TCP/UDP multicast groups of NETLINK_SOCK_DIAG
to filter and display socket statistics as they are destroyed.

Kernel support patch series: 24029a3603cfa633e8bc2b3fb3e48e76c497831d

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/inet_diag.h |  3 +-
 include/linux/sock_diag.h | 10 +++++++
 misc/ss.c                 | 74 +++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 84 insertions(+), 3 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 0fb76bb..e83340b 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -111,9 +111,10 @@ enum {
 	INET_DIAG_SKMEMINFO,
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
+	INET_DIAG_PROTOCOL,  /* response attribute only */
 };
 
-#define INET_DIAG_MAX INET_DIAG_DCTCPINFO
+#define INET_DIAG_MAX INET_DIAG_PROTOCOL
 
 /* INET_DIAG_MEM */
 
diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 78996e2..024e1f4 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -23,4 +23,14 @@ enum {
 	SK_MEMINFO_VARS,
 };
 
+enum sknetlink_groups {
+	SKNLGRP_NONE,
+	SKNLGRP_INET_TCP_DESTROY,
+	SKNLGRP_INET_UDP_DESTROY,
+	SKNLGRP_INET6_TCP_DESTROY,
+	SKNLGRP_INET6_UDP_DESTROY,
+	__SKNLGRP_MAX,
+};
+#define SKNLGRP_MAX	(__SKNLGRP_MAX - 1)
+
 #endif /* __SOCK_DIAG_H__ */
diff --git a/misc/ss.c b/misc/ss.c
index dba0901..759795c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -99,6 +99,7 @@ int show_proc_ctx = 0;
 int show_sock_ctx = 0;
 /* If show_users & show_proc_ctx only do user_ent_hash_build() once */
 int user_ent_hash_build_init = 0;
+int follow_events = 0;
 
 int netid_width;
 int state_width;
@@ -2030,6 +2031,9 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 	if (f && f->f && run_ssfilter(f->f, &s) == 0)
 		return 0;
 
+	if (tb[INET_DIAG_PROTOCOL])
+		protocol = *(__u8 *)RTA_DATA(tb[INET_DIAG_PROTOCOL]);
+
 	inet_stats_print(&s, protocol);
 
 	if (show_options) {
@@ -2201,7 +2205,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
-	if ((err = inet_show_sock(h, NULL, diag_arg->protocol)) < 0)
+	if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
 		return err;
 
 	return 0;
@@ -3217,6 +3221,64 @@ static int netlink_show(struct filter *f)
 	return 0;
 }
 
+struct sock_diag_msg {
+	__u8 sdiag_family;
+};
+
+static int generic_show_sock(const struct sockaddr_nl *addr,
+		struct nlmsghdr *nlh, void *arg)
+{
+	struct sock_diag_msg *r = NLMSG_DATA(nlh);
+	struct inet_diag_arg inet_arg = { .f = arg, .protocol = IPPROTO_MAX };
+
+	switch (r->sdiag_family) {
+	case AF_INET:
+	case AF_INET6:
+		return show_one_inet_sock(addr, nlh, &inet_arg);
+	case AF_UNIX:
+		return unix_show_sock(addr, nlh, arg);
+	case AF_PACKET:
+		return packet_show_sock(addr, nlh, arg);
+	case AF_NETLINK:
+		return netlink_show_sock(addr, nlh, arg);
+	default:
+		return -1;
+	}
+}
+
+static int handle_follow_request(struct filter *f)
+{
+	int ret = -1;
+	int groups = 0;
+	struct rtnl_handle rth;
+
+	if (f->families & (1 << AF_INET) && f->dbs & (1 << TCP_DB))
+		groups |= 1 << (SKNLGRP_INET_TCP_DESTROY - 1);
+	if (f->families & (1 << AF_INET) && f->dbs & (1 << UDP_DB))
+		groups |= 1 << (SKNLGRP_INET_UDP_DESTROY - 1);
+	if (f->families & (1 << AF_INET6) && f->dbs & (1 << TCP_DB))
+		groups |= 1 << (SKNLGRP_INET6_TCP_DESTROY - 1);
+	if (f->families & (1 << AF_INET6) && f->dbs & (1 << UDP_DB))
+		groups |= 1 << (SKNLGRP_INET6_UDP_DESTROY - 1);
+
+	if (groups == 0)
+		return -1;
+
+	if (rtnl_open_byproto(&rth, groups, NETLINK_SOCK_DIAG))
+		return -1;
+
+	rth.dump = 0;
+	rth.local.nl_pid = 0;
+
+	if (rtnl_dump_filter(&rth, generic_show_sock, f))
+		goto Exit;
+
+	ret = 0;
+Exit:
+	rtnl_close(&rth);
+	return ret;
+}
+
 struct snmpstat
 {
 	int tcp_estab;
@@ -3399,6 +3461,7 @@ static void _usage(FILE *dest)
 "   -i, --info          show internal TCP information\n"
 "   -s, --summary       show socket usage summary\n"
 "   -b, --bpf           show bpf filter socket information\n"
+"   -E, --events        continually display sockets as they are destroyed\n"
 "   -Z, --context       display process SELinux security contexts\n"
 "   -z, --contexts      display process and socket SELinux security contexts\n"
 "   -N, --net           switch to the specified network namespace name\n"
@@ -3481,6 +3544,7 @@ static const struct option long_opts[] = {
 	{ "info", 0, 0, 'i' },
 	{ "processes", 0, 0, 'p' },
 	{ "bpf", 0, 0, 'b' },
+	{ "events", 0, 0, 'E' },
 	{ "dccp", 0, 0, 'd' },
 	{ "tcp", 0, 0, 't' },
 	{ "udp", 0, 0, 'u' },
@@ -3516,7 +3580,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int state_filter = 0;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vVzZN:",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -3546,6 +3610,9 @@ int main(int argc, char *argv[])
 			show_options = 1;
 			show_bpf++;
 			break;
+		case 'E':
+			follow_events = 1;
+			break;
 		case 'd':
 			filter_db_set(&current_filter, DCCP_DB);
 			break;
@@ -3838,6 +3905,9 @@ int main(int argc, char *argv[])
 
 	fflush(stdout);
 
+	if (follow_events)
+		exit(handle_follow_request(&current_filter));
+
 	if (current_filter.dbs & (1<<NETLINK_DB))
 		netlink_show(&current_filter);
 	if (current_filter.dbs & PACKET_DBM)
-- 
2.2.0.rc0.207.ga3a616c
