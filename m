From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v2 2/2] iproute2: add support for tcp_metrics
Date: Sun,  2 Sep 2012 08:36:18 +0300
Message-ID: <1346564178-1794-3-git-send-email-ja@ssi.bg>
References: <1346564178-1794-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59654 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011Ab2IBFd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2012 01:33:56 -0400
In-Reply-To: <1346564178-1794-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	ip tcp_metrics/tcpmetrics

v2:
- On flush we should provide the address in req2
- "flush all" should use single del, just like when "all" is not provided
- Explain printed information in man page

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urpN iproute2-3.5.1/include/linux/tcp_metrics.h iproute2-3.5.1-tcp_metrics/include/linux/tcp_metrics.h
--- iproute2-3.5.1/include/linux/tcp_metrics.h	1970-01-01 02:00:00.000000000 +0200
+++ iproute2-3.5.1-tcp_metrics/include/linux/tcp_metrics.h	2012-08-23 09:50:54.385569009 +0300
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
diff -urpN iproute2-3.5.1/ip/Makefile iproute2-3.5.1-tcp_metrics/ip/Makefile
--- iproute2-3.5.1/ip/Makefile	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-tcp_metrics/ip/Makefile	2012-08-23 10:24:01.561660891 +0300
@@ -3,7 +3,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o ipr
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o iptuntap.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
-    iplink_macvlan.o iplink_macvtap.o ipl2tp.o
+    iplink_macvlan.o iplink_macvtap.o ipl2tp.o tcp_metrics.o
 
 RTMONOBJ=rtmon.o
 
diff -urpN iproute2-3.5.1/ip/ip.c iproute2-3.5.1-tcp_metrics/ip/ip.c
--- iproute2-3.5.1/ip/ip.c	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-tcp_metrics/ip/ip.c	2012-08-23 10:21:20.917653464 +0300
@@ -45,7 +45,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp }\n"
+"                   netns | l2tp | tcp_metrics }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
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
diff -urpN iproute2-3.5.1/ip/ip_common.h iproute2-3.5.1-tcp_metrics/ip/ip_common.h
--- iproute2-3.5.1/ip/ip_common.h	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-tcp_metrics/ip/ip_common.h	2012-08-23 10:19:11.005647457 +0300
@@ -42,6 +42,7 @@ extern int do_multirule(int argc, char *
 extern int do_netns(int argc, char **argv);
 extern int do_xfrm(int argc, char **argv);
 extern int do_ipl2tp(int argc, char **argv);
+extern int do_tcp_metrics(int argc, char **argv);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff -urpN iproute2-3.5.1/ip/tcp_metrics.c iproute2-3.5.1-tcp_metrics/ip/tcp_metrics.c
--- iproute2-3.5.1/ip/tcp_metrics.c	1970-01-01 02:00:00.000000000 +0200
+++ iproute2-3.5.1-tcp_metrics/ip/tcp_metrics.c	2012-08-25 15:18:31.695944914 +0300
@@ -0,0 +1,504 @@
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
+
+#define GENL_DEFINE_REQUEST(req, hdrsize, bufsiz)			\
+struct {								\
+	struct nlmsghdr		n;					\
+	struct genlmsghdr	g;					\
+	char			buf[NLMSG_ALIGN(hdrsize) + bufsiz];	\
+} req
+
+#define GENL_INIT_REQUEST(req, family, hdrsize, ver, cmd_, flags)	\
+	do {								\
+		memset(&req, 0, sizeof(req));				\
+		req.n.nlmsg_type = family;				\
+		req.n.nlmsg_flags = flags;				\
+		req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + hdrsize);	\
+		req.g.cmd = cmd_;					\
+		req.g.version = ver;					\
+	} while (0)
+
+#define INIT_GENL_ACTION(req, cmd, ack)					\
+	GENL_INIT_REQUEST(req, genl_family, 0,				\
+			  TCP_METRICS_GENL_VERSION, cmd,		\
+			  NLM_F_REQUEST | ((ack) ? NLM_F_ACK : 0))
+
+#define INIT_GENL_DUMP(req)						\
+	GENL_INIT_REQUEST(req, genl_family, 0,				\
+			  TCP_METRICS_GENL_VERSION,			\
+			  TCP_METRICS_CMD_GET,				\
+			  NLM_F_DUMP | NLM_F_REQUEST)
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
+		GENL_DEFINE_REQUEST(req2, 0, 128);
+
+		INIT_GENL_ACTION(req2, TCP_METRICS_CMD_DEL, 0);
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
+static int genl_parse_getfamily(struct nlmsghdr *nlh)
+{
+	struct rtattr *tb[CTRL_ATTR_MAX + 1];
+	struct genlmsghdr *ghdr = NLMSG_DATA(nlh);
+	int len = nlh->nlmsg_len;
+	struct rtattr *attrs;
+
+	if (nlh->nlmsg_type != GENL_ID_CTRL) {
+		fprintf(stderr, "Not a controller message, nlmsg_len=%d "
+			"nlmsg_type=0x%x\n", nlh->nlmsg_len, nlh->nlmsg_type);
+		return -1;
+	}
+
+	if (ghdr->cmd != CTRL_CMD_NEWFAMILY) {
+		fprintf(stderr, "Unknown controller command %d\n", ghdr->cmd);
+		return -1;
+	}
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+
+	if (len < 0) {
+		fprintf(stderr, "wrong controller message len %d\n", len);
+		return -1;
+	}
+
+	attrs = (struct rtattr *) ((char *) ghdr + GENL_HDRLEN);
+	parse_rtattr(tb, CTRL_ATTR_MAX, attrs, len);
+
+	if (tb[CTRL_ATTR_FAMILY_ID] == NULL) {
+		fprintf(stderr, "Missing family id TLV\n");
+		return -1;
+	}
+
+	return rta_getattr_u16(tb[CTRL_ATTR_FAMILY_ID]);
+}
+
+static int genl_ctrl_resolve_family(const char *family)
+{
+	GENL_DEFINE_REQUEST(req, 0, 1024);
+
+	GENL_INIT_REQUEST(req, GENL_ID_CTRL, 0, 0, CTRL_CMD_GETFAMILY,
+			  NLM_F_REQUEST);
+
+	addattr_l(&req.n, 1024, CTRL_ATTR_FAMILY_NAME,
+		  family, strlen(family) + 1);
+
+	if (rtnl_talk(&grth, &req.n, 0, 0, &req.n) < 0) {
+		fprintf(stderr, "Error talking to the kernel\n");
+		return -2;
+	}
+
+	return genl_parse_getfamily(&req.n);
+}
+
+static int tcpm_do_cmd(int cmd, int argc, char **argv)
+{
+	GENL_DEFINE_REQUEST(req, 0, 1024);
+	int atype = -1;
+	int code, ack;
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
+	/* flush for all addresses ? Single del without address */
+	if (cmd == CMD_FLUSH && f.addr.bitlen <= 0 &&
+	    preferred_family == AF_UNSPEC) {
+		cmd = CMD_DEL;
+		code = TCP_METRICS_CMD_DEL;
+		ack = 1;
+	} else if (cmd == CMD_DEL) {
+		code = TCP_METRICS_CMD_DEL;
+		ack = 1;
+	} else {	/* CMD_FLUSH, CMD_LIST */
+		code = TCP_METRICS_CMD_GET;
+		ack = 0;
+	}
+
+	if (genl_family < 0) {
+		if (rtnl_open_byproto(&grth, 0, NETLINK_GENERIC) < 0) {
+			fprintf(stderr, "Cannot open generic netlink socket\n");
+			exit(1);
+		}
+		genl_family = genl_ctrl_resolve_family(TCP_METRICS_GENL_NAME);
+		if (genl_family < 0)
+			exit(1);
+	}
+
+	if (!(cmd & CMD_FLUSH) && (atype >= 0 || (cmd & CMD_DEL))) {
+		INIT_GENL_ACTION(req, code, ack);
+		if (atype >= 0)
+			addattr_l(&req.n, sizeof(req), atype, &f.addr.data,
+				  f.addr.bytelen);
+	} else {
+		INIT_GENL_DUMP(req);
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
+	req.n.nlmsg_seq = ++grth.seq;
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
+		grth.dump = grth.seq;
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
diff -urpN iproute2-3.5.1/man/man8/Makefile iproute2-3.5.1-tcp_metrics/man/man8/Makefile
--- iproute2-3.5.1/man/man8/Makefile	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-tcp_metrics/man/man8/Makefile	2012-08-23 14:45:12.506385476 +0300
@@ -7,7 +7,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnsta
 	bridge.8 rtstat.8 ctstat.8 nstat.8 routef.8 \
 	ip-tunnel.8 ip-rule.8 ip-ntable.8 \
 	ip-monitor.8 tc-stab.8 tc-hfsc.8 ip-xfrm.8 ip-netns.8 \
-	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8 
+	ip-neighbour.8 ip-mroute.8 ip-maddress.8 ip-addrlabel.8 \
+	ip-tcp_metrics.8
 
 
 all: $(TARGETS)
diff -urpN iproute2-3.5.1/man/man8/ip-tcp_metrics.8 iproute2-3.5.1-tcp_metrics/man/man8/ip-tcp_metrics.8
--- iproute2-3.5.1/man/man8/ip-tcp_metrics.8	1970-01-01 02:00:00.000000000 +0200
+++ iproute2-3.5.1-tcp_metrics/man/man8/ip-tcp_metrics.8	2012-08-25 17:37:30.868321617 +0300
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
diff -urpN iproute2-3.5.1/man/man8/ip.8 iproute2-3.5.1-tcp_metrics/man/man8/ip.8
--- iproute2-3.5.1/man/man8/ip.8	2012-08-13 18:13:58.000000000 +0300
+++ iproute2-3.5.1-tcp_metrics/man/man8/ip.8	2012-08-23 10:28:12.541672495 +0300
@@ -15,7 +15,7 @@ ip \- show / manipulate routing, devices
 .IR OBJECT " := { "
 .BR link " | " addr " | " addrlabel " | " route " | " rule " | " neigh " | "\
  ntable " | " tunnel " | " tuntap " | " maddr " | "  mroute " | " mrule " | "\
- monitor " | " xfrm " | " netns " | "  l2tp " }"
+ monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " }"
 .sp
 
 .ti -8
@@ -156,6 +156,10 @@ host addresses.
 - rule in routing policy database.
 
 .TP
+.B tcp_metrics/tcpmetrics
+- manage TCP Metrics
+
+.TP
 .B tunnel
 - tunnel over IP.
 
@@ -215,6 +219,7 @@ was written by Alexey N. Kuznetsov and a
 .BR ip-ntable (8),
 .BR ip-route (8),
 .BR ip-rule (8),
+.BR ip-tcp_metrics (8),
 .BR ip-tunnel (8),
 .BR ip-xfrm (8)
 .br
