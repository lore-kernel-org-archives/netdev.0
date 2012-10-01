From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] iproute2: add support for tcp_metrics
Date: Mon,  1 Oct 2012 22:48:22 +0300
Message-ID: <1349120902-2353-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46357 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062Ab2JAToO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 15:44:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	ip tcp_metrics/tcpmetrics

	We support get/del for single entry and dump for
show/flush.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/tcp_metrics.h |   54 ++++++
 ip/Makefile                 |    2 +-
 ip/ip.c                     |    4 +-
 ip/ip_common.h              |    1 +
 ip/tcp_metrics.c            |  426 +++++++++++++++++++++++++++++++++++++++++++
 man/man8/Makefile           |    3 +-
 man/man8/ip-tcp_metrics.8   |  143 +++++++++++++++
 man/man8/ip.8               |    7 +-
 8 files changed, 636 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/tcp_metrics.h
 create mode 100644 ip/tcp_metrics.c
 create mode 100644 man/man8/ip-tcp_metrics.8

diff --git a/include/linux/tcp_metrics.h b/include/linux/tcp_metrics.h
new file mode 100644
index 0000000..cb5157b
--- /dev/null
+++ b/include/linux/tcp_metrics.h
@@ -0,0 +1,54 @@
+/* tcp_metrics.h - TCP Metrics Interface */
+
+#ifndef _LINUX_TCP_METRICS_H
+#define _LINUX_TCP_METRICS_H
+
+#include <linux/types.h>
+
+/* NETLINK_GENERIC related info
+ */
+#define TCP_METRICS_GENL_NAME		"tcp_metrics"
+#define TCP_METRICS_GENL_VERSION	0x1
+
+enum tcp_metric_index {
+	TCP_METRIC_RTT,
+	TCP_METRIC_RTTVAR,
+	TCP_METRIC_SSTHRESH,
+	TCP_METRIC_CWND,
+	TCP_METRIC_REORDERING,
+
+	/* Always last.  */
+	__TCP_METRIC_MAX,
+};
+
+#define TCP_METRIC_MAX	(__TCP_METRIC_MAX - 1)
+
+enum {
+	TCP_METRICS_ATTR_UNSPEC,
+	TCP_METRICS_ATTR_ADDR_IPV4,		/* u32 */
+	TCP_METRICS_ATTR_ADDR_IPV6,		/* binary */
+	TCP_METRICS_ATTR_AGE,			/* msecs */
+	TCP_METRICS_ATTR_TW_TSVAL,		/* u32, raw, rcv tsval */
+	TCP_METRICS_ATTR_TW_TS_STAMP,		/* s32, sec age */
+	TCP_METRICS_ATTR_VALS,			/* nested +1, u32 */
+	TCP_METRICS_ATTR_FOPEN_MSS,		/* u16 */
+	TCP_METRICS_ATTR_FOPEN_SYN_DROPS,	/* u16, count of drops */
+	TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS,	/* msecs age */
+	TCP_METRICS_ATTR_FOPEN_COOKIE,		/* binary */
+
+	__TCP_METRICS_ATTR_MAX,
+};
+
+#define TCP_METRICS_ATTR_MAX	(__TCP_METRICS_ATTR_MAX - 1)
+
+enum {
+	TCP_METRICS_CMD_UNSPEC,
+	TCP_METRICS_CMD_GET,
+	TCP_METRICS_CMD_DEL,
+
+	__TCP_METRICS_CMD_MAX,
+};
+
+#define TCP_METRICS_CMD_MAX	(__TCP_METRICS_CMD_MAX - 1)
+
+#endif /* _LINUX_TCP_METRICS_H */
diff --git a/ip/Makefile b/ip/Makefile
index 6a518f8..e3c991f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o
+    iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o tcp_metrics.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index df06d3e..e0f7e60 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -45,7 +45,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp }\n"
+"                   netns | l2tp | tcp_metrics }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
@@ -78,6 +78,8 @@ static const struct cmd {
 	{ "tunl",	do_iptunnel },
 	{ "tuntap",	do_iptuntap },
 	{ "tap",	do_iptuntap },
+	{ "tcpmetrics",	do_tcp_metrics },
+	{ "tcp_metrics",do_tcp_metrics },
 	{ "monitor",	do_ipmonitor },
 	{ "xfrm",	do_xfrm },
 	{ "mroute",	do_multiroute },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 5fa2cc0..2fd66b7 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -42,6 +42,7 @@ extern int do_multirule(int argc, char **argv);
 extern int do_netns(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
+extern int do_tcp_metrics(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
new file mode 100644
index 0000000..cd6d60c
--- /dev/null
+++ b/ip/tcp_metrics.c
@@ -0,0 +1,426 @@
+/*
+ * tcp_metrics.c	"ip tcp_metrics/tcpmetrics"
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		version 2 as published by the Free Software Foundation;
+ *
+ * Authors:	Julian Anastasov <ja@ssi.bg>, August 2012
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <sys/ioctl.h>
+#include <linux/if.h>
+
+#include <linux/genetlink.h>
+#include <linux/tcp_metrics.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "libgenl.h"
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip tcp_metrics/tcpmetrics { COMMAND | help }\n");
+	fprintf(stderr, "       ip tcp_metrics { show | flush } SELECTOR\n");
+	fprintf(stderr, "       ip tcp_metrics delete [ address ] ADDRESS\n");
+	fprintf(stderr, "SELECTOR := [ [ address ] PREFIX ]\n");
+	exit(-1);
+}
+
+/* netlink socket */
+static struct rtnl_handle grth = { .fd = -1 };
+static int genl_family = -1;
+
+#define TCPM_REQUEST(_req, _bufsiz, _cmd, _flags) \
+	GENL_REQUEST(_req, _bufsiz, genl_family, 0, \
+		     TCP_METRICS_GENL_VERSION, _cmd, _flags)
+
+#define CMD_LIST	0x0001	/* list, lst, show		*/
+#define CMD_DEL		0x0002	/* delete, remove		*/
+#define CMD_FLUSH	0x0004	/* flush			*/
+
+static struct {
+	char	*name;
+	int	code;
+} cmds[] = {
+	{	"list",		CMD_LIST	},
+	{	"lst",		CMD_LIST	},
+	{	"show",		CMD_LIST	},
+	{	"delete",	CMD_DEL		},
+	{	"remove",	CMD_DEL		},
+	{	"flush",	CMD_FLUSH	},
+};
+
+static char *metric_name[TCP_METRIC_MAX + 1] = {
+	[TCP_METRIC_RTT]		= "rtt",
+	[TCP_METRIC_RTTVAR]		= "rttvar",
+	[TCP_METRIC_SSTHRESH]		= "ssthresh",
+	[TCP_METRIC_CWND]		= "cwnd",
+	[TCP_METRIC_REORDERING]		= "reordering",
+};
+
+static struct
+{
+	int flushed;
+	char *flushb;
+	int flushp;
+	int flushe;
+	int cmd;
+	inet_prefix addr;
+} f;
+
+static int flush_update(void)
+{
+	if (rtnl_send_check(&grth, f.flushb, f.flushp) < 0) {
+		perror("Failed to send flush request\n");
+		return -1;
+	}
+	f.flushp = 0;
+	return 0;
+}
+
+static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		       void *arg)
+{
+	FILE *fp = (FILE *) arg;
+	struct genlmsghdr *ghdr;
+	struct rtattr *attrs[TCP_METRICS_ATTR_MAX + 1], *a;
+	int len = n->nlmsg_len;
+	char abuf[256];
+	inet_prefix addr;
+	int family, i, atype;
+
+	if (n->nlmsg_type != genl_family)
+		return -1;
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+	if (len < 0)
+		return -1;
+
+	ghdr = NLMSG_DATA(n);
+	if (ghdr->cmd != TCP_METRICS_CMD_GET)
+		return 0;
+
+	parse_rtattr(attrs, TCP_METRICS_ATTR_MAX, (void *) ghdr + GENL_HDRLEN,
+		     len);
+
+	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
+	if (a) {
+		if (f.addr.family && f.addr.family != AF_INET)
+			return 0;
+		memcpy(&addr.data, RTA_DATA(a), 4);
+		addr.bytelen = 4;
+		family = AF_INET;
+		atype = TCP_METRICS_ATTR_ADDR_IPV4;
+	} else {
+		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
+		if (a) {
+			if (f.addr.family && f.addr.family != AF_INET6)
+				return 0;
+			memcpy(&addr.data, RTA_DATA(a), 16);
+			addr.bytelen = 16;
+			family = AF_INET6;
+			atype = TCP_METRICS_ATTR_ADDR_IPV6;
+		} else
+			return 0;
+	}
+
+	if (f.addr.family && f.addr.bitlen >= 0 &&
+	    inet_addr_match(&addr, &f.addr, f.addr.bitlen))
+		return 0;
+
+	if (f.flushb) {
+		struct nlmsghdr *fn;
+		TCPM_REQUEST(req2, 128, TCP_METRICS_CMD_DEL, NLM_F_REQUEST);
+
+		addattr_l(&req2.n, sizeof(req2), atype, &addr.data,
+			  addr.bytelen);
+
+		if (NLMSG_ALIGN(f.flushp) + req2.n.nlmsg_len > f.flushe) {
+			if (flush_update())
+				return -1;
+		}
+		fn = (struct nlmsghdr *) (f.flushb + NLMSG_ALIGN(f.flushp));
+		memcpy(fn, &req2.n, req2.n.nlmsg_len);
+		fn->nlmsg_seq = ++grth.seq;
+		f.flushp = (((char *) fn) + req2.n.nlmsg_len) - f.flushb;
+		f.flushed++;
+		if (show_stats < 2)
+			return 0;
+	}
+
+	if (f.cmd & (CMD_DEL | CMD_FLUSH))
+		fprintf(fp, "Deleted ");
+
+	fprintf(fp, "%s",
+		format_host(family, RTA_PAYLOAD(a), &addr.data,
+			    abuf, sizeof(abuf)));
+
+	a = attrs[TCP_METRICS_ATTR_AGE];
+	if (a) {
+		__u64 val = rta_getattr_u64(a);
+
+		fprintf(fp, " age %llu.%03llusec",
+			val / 1000, val % 1000);
+	}
+
+	a = attrs[TCP_METRICS_ATTR_TW_TS_STAMP];
+	if (a) {
+		__s32 val = (__s32) rta_getattr_u32(a);
+		__u32 tsval;
+
+		a = attrs[TCP_METRICS_ATTR_TW_TSVAL];
+		tsval = a ? rta_getattr_u32(a) : 0;
+		fprintf(fp, " tw_ts %u/%dsec ago", tsval, val);
+	}
+
+	a = attrs[TCP_METRICS_ATTR_VALS];
+	if (a) {
+		struct rtattr *m[TCP_METRIC_MAX + 1 + 1];
+
+		parse_rtattr_nested(m, TCP_METRIC_MAX + 1, a);
+
+		for (i = 0; i < TCP_METRIC_MAX + 1; i++) {
+			__u32 val;
+
+			a = m[i + 1];
+			if (!a)
+				continue;
+			if (metric_name[i])
+				fprintf(fp, " %s ", metric_name[i]);
+			else
+				fprintf(fp, " metric_%d ", i);
+			val = rta_getattr_u32(a);
+			switch (i) {
+			case TCP_METRIC_RTT:
+			case TCP_METRIC_RTTVAR:
+				fprintf(fp, "%ums", val);
+				break;
+			case TCP_METRIC_SSTHRESH:
+			case TCP_METRIC_CWND:
+			case TCP_METRIC_REORDERING:
+			default:
+				fprintf(fp, "%u", val);
+				break;
+			}
+		}
+	}
+
+	a = attrs[TCP_METRICS_ATTR_FOPEN_MSS];
+	if (a)
+		fprintf(fp, " fo_mss %u", rta_getattr_u16(a));
+
+	a = attrs[TCP_METRICS_ATTR_FOPEN_SYN_DROPS];
+	if (a) {
+		__u16 syn_loss = rta_getattr_u16(a);
+		__u64 ts;
+
+		a = attrs[TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS];
+		ts = a ? rta_getattr_u64(a) : 0;
+
+		fprintf(fp, " fo_syn_drops %u/%llu.%03llusec ago",
+			syn_loss, ts / 1000, ts % 1000);
+	}
+
+	a = attrs[TCP_METRICS_ATTR_FOPEN_COOKIE];
+	if (a) {
+		char cookie[32 + 1];
+		unsigned char *ptr = RTA_DATA(a);
+		int i, max = RTA_PAYLOAD(a);
+
+		if (max > 16)
+			max = 16;
+		cookie[0] = 0;
+		for (i = 0; i < max; i++)
+			sprintf(cookie + i + i, "%02x", ptr[i]);
+		fprintf(fp, " fo_cookie %s", cookie);
+	}
+
+	fprintf(fp, "\n");
+
+	fflush(fp);
+	return 0;
+}
+
+static int tcpm_do_cmd(int cmd, int argc, char **argv)
+{
+	TCPM_REQUEST(req, 1024, TCP_METRICS_CMD_GET, NLM_F_REQUEST);
+	int atype = -1;
+	int ack;
+
+	memset(&f, 0, sizeof(f));
+	f.addr.bitlen = -1;
+	f.addr.family = preferred_family;
+
+	switch (preferred_family) {
+	case AF_UNSPEC:
+	case AF_INET:
+	case AF_INET6:
+		break;
+	default:
+		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		return -1;
+	}
+
+	for (; argc > 0; argc--, argv++) {
+		char *who = "address";
+
+		if (strcmp(*argv, "addr") == 0 ||
+		    strcmp(*argv, "address") == 0) {
+			who = *argv;
+			NEXT_ARG();
+		}
+		if (matches(*argv, "help") == 0)
+			usage();
+		if (f.addr.bitlen >= 0)
+			duparg2(who, *argv);
+
+		get_prefix(&f.addr, *argv, preferred_family);
+		if (f.addr.bytelen && f.addr.bytelen * 8 == f.addr.bitlen) {
+			if (f.addr.family == AF_INET)
+				atype = TCP_METRICS_ATTR_ADDR_IPV4;
+			else if (f.addr.family == AF_INET6)
+				atype = TCP_METRICS_ATTR_ADDR_IPV6;
+		}
+		if ((CMD_DEL & cmd) && atype < 0) {
+			fprintf(stderr, "Error: a specific IP address is expected rather than \"%s\"\n",
+				*argv);
+			return -1;
+		}
+
+		argc--; argv++;
+	}
+
+	if (cmd == CMD_DEL && atype < 0)
+		missarg("address");
+
+	/* flush for exact address ? Single del */
+	if (cmd == CMD_FLUSH && atype >= 0)
+		cmd = CMD_DEL;
+
+	/* flush for all addresses ? Single del without address */
+	if (cmd == CMD_FLUSH && f.addr.bitlen <= 0 &&
+	    preferred_family == AF_UNSPEC) {
+		cmd = CMD_DEL;
+		req.g.cmd = TCP_METRICS_CMD_DEL;
+		ack = 1;
+	} else if (cmd == CMD_DEL) {
+		req.g.cmd = TCP_METRICS_CMD_DEL;
+		ack = 1;
+	} else {	/* CMD_FLUSH, CMD_LIST */
+		ack = 0;
+	}
+
+	if (genl_family < 0) {
+		if (rtnl_open_byproto(&grth, 0, NETLINK_GENERIC) < 0) {
+			fprintf(stderr, "Cannot open generic netlink socket\n");
+			exit(1);
+		}
+		genl_family = genl_resolve_family(&grth,
+						  TCP_METRICS_GENL_NAME);
+		if (genl_family < 0)
+			exit(1);
+	}
+
+	if (!(cmd & CMD_FLUSH) && (atype >= 0 || (cmd & CMD_DEL))) {
+		if (ack)
+			req.n.nlmsg_flags |= NLM_F_ACK;
+		if (atype >= 0)
+			addattr_l(&req.n, sizeof(req), atype, &f.addr.data,
+				  f.addr.bytelen);
+	} else {
+		req.n.nlmsg_flags |= NLM_F_DUMP;
+	}
+
+	f.cmd = cmd;
+	if (cmd & CMD_FLUSH) {
+		int round = 0;
+		char flushb[4096-512];
+
+		f.flushb = flushb;
+		f.flushp = 0;
+		f.flushe = sizeof(flushb);
+
+		for (;;) {
+			req.n.nlmsg_seq = grth.dump = ++grth.seq;
+			if (rtnl_send(&grth, &req, req.n.nlmsg_len) < 0) {
+				perror("Failed to send flush request");
+				exit(1);
+			}
+			f.flushed = 0;
+			if (rtnl_dump_filter(&grth, process_msg, stdout) < 0) {
+				fprintf(stderr, "Flush terminated\n");
+				exit(1);
+			}
+			if (f.flushed == 0) {
+				if (round == 0) {
+					fprintf(stderr, "Nothing to flush.\n");
+				} else if (show_stats)
+					printf("*** Flush is complete after %d round%s ***\n",
+					       round, round > 1 ? "s" : "");
+				fflush(stdout);
+				return 0;
+			}
+			round++;
+			if (flush_update() < 0)
+				exit(1);
+			if (show_stats) {
+				printf("\n*** Round %d, deleting %d entries ***\n",
+				       round, f.flushed);
+				fflush(stdout);
+			}
+		}
+		return 0;
+	}
+
+	if (ack) {
+		if (rtnl_talk(&grth, &req.n, 0, 0, NULL) < 0)
+			return -2;
+	} else if (atype >= 0) {
+		if (rtnl_talk(&grth, &req.n, 0, 0, &req.n) < 0)
+			return -2;
+		if (process_msg(NULL, &req.n, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+	} else {
+		req.n.nlmsg_seq = grth.dump = ++grth.seq;
+		if (rtnl_send(&grth, &req, req.n.nlmsg_len) < 0) {
+			perror("Failed to send dump request");
+			exit(1);
+		}
+
+		if (rtnl_dump_filter(&grth, process_msg, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			exit(1);
+		}
+	}
+	return 0;
+}
+
+int do_tcp_metrics(int argc, char **argv)
+{
+	int i;
+
+	if (argc < 1)
+		return tcpm_do_cmd(CMD_LIST, 0, NULL);
+	for (i = 0; i < ARRAY_SIZE(cmds); i++) {
+		if (matches(argv[0], cmds[i].name) == 0)
+			return tcpm_do_cmd(cmds[i].code, argc-1, argv+1);
+	}
+	if (matches(argv[0], "help") == 0)
+		usage();
+
+	fprintf(stderr, "Command \"%s\" is unknown, "
+			"try \"ip tcp_metrics help\".\n", *argv);
+	exit(-1);
+}
+
diff --git a/man/man8/Makefile b/man/man8/Makefile
index 4ed3eab..aaf1729 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -8,7 +8,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 ss.8 \
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-address.8 ip-addrlabel.8 ip-l2tp.8 ip-link.8 \
 	ip-maddress.8 ip-monitor.8 ip-mroute.8 ip-neighbour.8 \
-	ip-netns.8 ip-ntable.8 ip-route.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8
+	ip-netns.8 ip-ntable.8 ip-route.8 ip-rule.8 ip-tunnel.8 ip-xfrm.8 \
+	ip-tcp_metrics.8
 
 all: $(TARGETS)
 
diff --git a/man/man8/ip-tcp_metrics.8 b/man/man8/ip-tcp_metrics.8
new file mode 100644
index 0000000..1aa4d45
--- /dev/null
+++ b/man/man8/ip-tcp_metrics.8
@@ -0,0 +1,143 @@
+.TH "IP\-TCP_METRICS" 8 "23 Aug 2012" "iproute2" "Linux"
+.SH "NAME"
+ip-tcp_metrics \- management for TCP Metrics
+.SH "SYNOPSIS"
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip
+.RI "[ " OPTIONS " ]"
+.B tcp_metrics
+.RI "{ " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.BR "ip tcp_metrics" " { " show " | " flush " }
+.IR SELECTOR
+
+.ti -8
+.BR "ip tcp_metrics delete " [ " address " ]
+.IR ADDRESS
+
+.ti -8
+.IR SELECTOR " := "
+.RB "[ [ " address " ] "
+.IR PREFIX " ]"
+
+.SH "DESCRIPTION"
+.B ip tcp_metrics
+is used to manipulate entries in the kernel that keep TCP information
+for IPv4 and IPv6 destinations. The entries are created when
+TCP sockets want to share information for destinations and are
+stored in a cache keyed by the destination address. The saved
+information may include values for metrics (initially obtained from
+routes), recent TSVAL for TIME-WAIT recycling purposes, state for the
+Fast Open feature, etc.
+For performance reasons the cache can not grow above configured limit
+and the older entries are replaced with fresh information, sometimes
+reclaimed and used for new destinations. The kernel never removes
+entries, they can be flushed only with this tool.
+
+.SS ip tcp_metrics show - show cached entries
+
+.TP
+.BI address " PREFIX " (default)
+IPv4/IPv6 prefix or address. If no prefix is provided all entries are shown.
+
+.LP
+The output may contain the following information:
+
+.BI age " <S.MMM>" sec
+- time after the entry was created, reset or updated with metrics
+from sockets. The entry is reset and refreshed on use with metrics from
+route if the metrics are not updated in last hour. Not all cached values
+reset the age on update.
+
+.BI cwnd " <N>"
+- CWND metric value
+
+.BI fo_cookie " <HEX-STRING>"
+- Cookie value received in SYN-ACK to be used by Fast Open for next SYNs
+
+.BI fo_mss " <N>"
+- MSS value received in SYN-ACK to be used by Fast Open for next SYNs
+
+.BI fo_syn_drops " <N>/<S.MMM>" "sec ago"
+- Number of drops of initial outgoing Fast Open SYNs with data
+detected by monitoring the received SYN-ACK after SYN retransmission.
+The seconds show the time after last SYN drop and together with
+the drop count can be used to disable Fast Open for some time.
+
+.BI reordering " <N>"
+- Reordering metric value
+
+.BI rtt " <N>" ms
+- RTT metric value
+
+.BI rttvar " <N>" ms
+- RTTVAR metric value
+
+.BI ssthresh " <SSTHRESH>"
+- SSTHRESH metric value
+
+.BI tw_ts " <TSVAL>/<SEC>" "sec ago"
+- recent TSVAL and the seconds after saving it into TIME-WAIT socket
+
+.SS ip tcp_metrics delete - delete single entry
+
+.TP
+.BI address " ADDRESS " (default)
+IPv4/IPv6 address. The address is a required argument.
+
+.SS ip tcp_metrics flush - flush entries
+This command flushes the entries selected by some criteria.
+
+.PP
+This command has the same arguments as
+.B show.
+
+.SH "EXAMPLES"
+.PP
+ip tcp_metrics show address 192.168.0.0/24
+.RS 4
+Shows the entries for destinations from subnet
+.RE
+.PP
+ip tcp_metrics show 192.168.0.0/24
+.RS 4
+The same but address keyword is optional
+.RE
+.PP
+ip tcp_metrics
+.RS 4
+Show all is the default action
+.RE
+.PP
+ip tcp_metrics delete 192.168.0.1
+.RS 4
+Removes the entry for 192.168.0.1 from cache.
+.RE
+.PP
+ip tcp_metrics flush 192.168.0.0/24
+.RS 4
+Removes entries for destinations from subnet
+.RE
+.PP
+ip tcp_metrics flush all
+.RS 4
+Removes all entries from cache
+.RE
+.PP
+ip -6 tcp_metrics flush all
+.RS 4
+Removes all IPv6 entries from cache keeping the IPv4 entries.
+.RE
+
+.SH SEE ALSO
+.br
+.BR ip (8)
+
+.SH AUTHOR
+Original Manpage by Julian Anastasov <ja@ssi.bg>
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 4db8a67..9063049 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -15,7 +15,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .IR OBJECT " := { "
 .BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
  ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrule " | "\
- monitor " | " xfrm " | " netns " | "  l2tp " }"
+ monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " }"
 .sp
 
 .ti -8
@@ -161,6 +161,10 @@ host addresses.
 - rule in routing policy database.
 
 .TP
+.B tcp_metrics/tcpmetrics
+- manage TCP Metrics
+
+.TP
 .B tunnel
 - tunnel over IP.
 
@@ -220,6 +224,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR ip-ntable (8),
 .BR ip-route (8),
 .BR ip-rule (8),
+.BR ip-tcp_metrics (8),
 .BR ip-tunnel (8),
 .BR ip-xfrm (8)
 .br
-- 
1.7.3.4
