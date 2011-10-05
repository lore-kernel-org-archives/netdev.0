From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 5/7] bridge: allow creating/deleting fdb entries via
 netlink
Date: Wed, 5 Oct 2011 12:13:05 -0700
Message-ID: <20111005121305.26ac48bf@nehalam.linuxnetplumber.net>
References: <20110405000326.714524584@vyatta.com>
	<20110405000537.372602366@vyatta.com>
	<CAGXs5wXc0RLE9KbTVVYRa0xuLEKh8mTM7AR7hMBe86HNfDX0HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45889 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934718Ab1JETNL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 15:13:11 -0400
In-Reply-To: <CAGXs5wXc0RLE9KbTVVYRa0xuLEKh8mTM7AR7hMBe86HNfDX0HQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Oct 2011 21:06:54 +0200
Kevin Wilson <wkevils@gmail.com> wrote:

> Hello all,
> I would appreciate if someone can elaborate about "bridge extensions
> to iproute2" mentioned here.
> I downloaded latest iproute2 git tree and did not find it there.
> googling for it did not gave much info about it.
> I will appreciate if someone can tell  who develop it, what is the
> status, site, repository tree, etc.
> 
> rgs,
> Kevin

The patch to handle this was posted, but is not committed to the tree yet.

--
>From 8e3d00d0602420dadc3d23877a4995ea3d7496c2 Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 4 Oct 2011 09:31:58 -0700
Subject: [PATCH] Add support for bridging control.

This adds a new 'bridge' command which is the bridging equivalent of
the ip command.
---
 Makefile          |    2 +-
 br/.gitignore     |    1 +
 br/Makefile       |   14 +++
 br/br_common.h    |   13 +++
 br/bridge.c       |  104 ++++++++++++++++++++++
 br/fdb.c          |  245 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 br/link.c         |  142 +++++++++++++++++++++++++++++++
 br/monitor.c      |  138 ++++++++++++++++++++++++++++++
 man/man8/bridge.8 |  177 ++++++++++++++++++++++++++++++++++++++
 9 files changed, 835 insertions(+), 1 deletions(-)
 create mode 100644 br/.gitignore
 create mode 100644 br/Makefile
 create mode 100644 br/br_common.h
 create mode 100644 br/bridge.c
 create mode 100644 br/fdb.c
 create mode 100644 br/link.c
 create mode 100644 br/monitor.c
 create mode 100644 man/man8/bridge.8

diff --git a/Makefile b/Makefile
index d1ace1f..f1d360a 100644
--- a/Makefile
+++ b/Makefile
@@ -33,7 +33,7 @@ CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
 CFLAGS = $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc misc netem genl
+SUBDIRS=lib ip tc br misc netem genl
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
diff --git a/br/.gitignore b/br/.gitignore
new file mode 100644
index 0000000..7096907
--- /dev/null
+++ b/br/.gitignore
@@ -0,0 +1 @@
+bridge
diff --git a/br/Makefile b/br/Makefile
new file mode 100644
index 0000000..9a6743e
--- /dev/null
+++ b/br/Makefile
@@ -0,0 +1,14 @@
+BROBJ = bridge.o fdb.o monitor.o link.o
+
+include ../Config
+
+all: bridge
+
+bridge: $(BROBJ) $(LIBNETLINK) 
+
+install: all
+	install -m 0755 bridge $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(BROBJ) bridge
+
diff --git a/br/br_common.h b/br/br_common.h
new file mode 100644
index 0000000..ec1671d
--- /dev/null
+++ b/br/br_common.h
@@ -0,0 +1,13 @@
+extern int print_linkinfo(const struct sockaddr_nl *who,
+			  struct nlmsghdr *n,
+			  void *arg);
+extern int print_fdb(const struct sockaddr_nl *who,
+		     struct nlmsghdr *n, void *arg);
+
+extern int do_fdb(int argc, char **argv);
+extern int do_monitor(int argc, char **argv);
+
+extern int show_stats;
+extern int show_detail;
+extern int timestamp;
+extern struct rtnl_handle rth;
diff --git a/br/bridge.c b/br/bridge.c
new file mode 100644
index 0000000..9e5f69c
--- /dev/null
+++ b/br/bridge.c
@@ -0,0 +1,104 @@
+/*
+ * Get/set/delete bridge with netlink
+ *
+ * Authors:	Stephen Hemminger <shemminger@vyatta.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <sys/socket.h>
+#include <string.h>
+
+#include "SNAPSHOT.h"
+#include "utils.h"
+#include "br_common.h"
+
+struct rtnl_handle rth = { .fd = -1 };
+int resolve_hosts;
+int show_stats;
+int show_details;
+int timestamp;
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr,
+"Usage: br [ OPTIONS ] OBJECT { COMMAND | help }\n"
+"where  OBJECT := { fdb |  monitor }\n"
+"       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails]\n" );
+	exit(-1);
+}
+
+static int do_help(int argc, char **argv)
+{
+	usage();
+}
+
+
+static const struct cmd {
+	const char *cmd;
+	int (*func)(int argc, char **argv);
+} cmds[] = {
+	{ "fdb", 	do_fdb },
+	{ "monitor",	do_monitor },
+	{ "help",	do_help },
+	{ 0 }
+};
+
+static int do_cmd(const char *argv0, int argc, char **argv)
+{
+	const struct cmd *c;
+
+	for (c = cmds; c->cmd; ++c) {
+		if (matches(argv0, c->cmd) == 0)
+			return c->func(argc-1, argv+1);
+	}
+
+	fprintf(stderr, "Object \"%s\" is unknown, try \"br help\".\n", argv0);
+	return -1;
+}
+
+int
+main(int argc, char **argv)
+{
+	while (argc > 1) {
+		char *opt = argv[1];
+		if (strcmp(opt,"--") == 0) {
+			argc--; argv++;
+			break;
+		}
+		if (opt[0] != '-')
+			break;
+		if (opt[1] == '-')
+			opt++;
+
+		if (matches(opt, "-help") == 0) {
+			usage();
+		} else if (matches(opt, "-Version") == 0) {
+			printf("br utility, 0.0\n");
+			exit(0);
+		} else if (matches(opt, "-stats") == 0 ||
+			   matches(opt, "-statistics") == 0) {
+			++show_stats;
+		} else if (matches(opt, "-details") == 0) {
+			++show_details;
+		} else if (matches(opt, "-timestamp") == 0) {
+			++timestamp;
+		} else {
+			fprintf(stderr, "Option \"%s\" is unknown, try \"br -help\".\n", opt);
+			exit(-1);
+		}
+		argc--;	argv++;
+	}
+
+	if (rtnl_open(&rth, 0) < 0)
+		exit(1);
+
+	if (argc > 1)
+		return do_cmd(argv[1], argc-1, argv+1);
+
+	rtnl_close(&rth);
+	usage();
+}
diff --git a/br/fdb.c b/br/fdb.c
new file mode 100644
index 0000000..d849f97
--- /dev/null
+++ b/br/fdb.c
@@ -0,0 +1,245 @@
+/*
+ * Get/set/delete fdb table with netlink
+ *
+ * Authors:	Stephen Hemminger <shemminger@vyatta.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <time.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/if_bridge.h>
+#include <linux/if_ether.h>
+#include <linux/neighbour.h>
+#include <string.h>
+
+#include "libnetlink.h"
+#include "br_common.h"
+#include "utils.h"
+
+int filter_index;
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: br fdb { add | del | replace } ADDR dev DEV\n");
+	fprintf(stderr, "       br fdb {show} [ dev DEV ]\n");
+	exit(-1);
+}
+
+static const char *state_n2a(unsigned s)
+{
+	static char buf[32];
+
+	if (s & NUD_PERMANENT) 
+		return "local";
+
+	if (s & NUD_NOARP)
+		return "static";
+
+	if (s & NUD_STALE)
+		return "stale";
+	
+	if (s & NUD_REACHABLE)
+		return "";
+
+	sprintf(buf, "state=%#x", s);
+	return buf;
+}
+
+static char *fmt_time(char *b, size_t l, unsigned long tick)
+{
+	static int hz;
+	
+	if (hz == 0)
+		hz = __get_user_hz();
+
+	snprintf(b, l, "%lu.%02lu", tick / hz, ((tick % hz) * hz) / 100);
+	return b;
+}
+
+int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	struct ndmsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[NDA_MAX+1];
+	const __u8 *addr = NULL;
+	char b1[32];
+
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (r->ndm_family != AF_BRIDGE)
+		return 0;
+
+	if (filter_index && filter_index != r->ndm_ifindex)
+		return 0;
+
+	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
+		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	if (n->nlmsg_type == RTM_DELNEIGH)
+		fprintf(fp, "Deleted ");
+
+	if (tb[NDA_LLADDR])
+		addr = RTA_DATA(tb[NDA_LLADDR]);
+	else {
+		fprintf(stderr, "missing lladdr\n");
+		return -1;
+	}
+
+	fprintf(fp, "%s\t%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\t%s",
+		ll_index_to_name(r->ndm_ifindex),
+		addr[0], addr[1], addr[2],
+		addr[3], addr[4], addr[5],
+		state_n2a(r->ndm_state));
+
+	if (show_stats && tb[NDA_CACHEINFO]) {
+		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
+
+		fprintf(fp, "\t%8s", fmt_time(b1, sizeof(b1), ci->ndm_updated));
+		fprintf(fp, " %8s", fmt_time(b1, sizeof(b1), ci->ndm_used));
+	}
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
+static int fdb_show(int argc, char **argv)
+{
+	char *filter_dev = NULL;
+	
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (filter_dev)
+				duparg("dev", *argv);
+			filter_dev = *argv;
+		}
+		argc--; argv++;
+	}
+
+	if (filter_dev) {
+		if ((filter_index = if_nametoindex(filter_dev)) == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", filter_dev);
+			return -1;
+		}
+	}
+
+	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETNEIGH) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+	
+	printf("port\tmac addr\t\tflags%s\n",
+	       show_stats ? "\t updated     used" : "");
+
+	if (rtnl_dump_filter(&rth, print_fdb, stdout, NULL, NULL) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+
+	return 0;
+}
+
+static int fdb_modify(int cmd, int flags, int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct ndmsg 		ndm;
+		char   			buf[256];
+	} req;
+	char *addr = NULL;
+	char *d = NULL;
+	char abuf[ETH_ALEN];
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
+	req.n.nlmsg_type = cmd;
+	req.ndm.ndm_family = PF_BRIDGE;
+	req.ndm.ndm_state = NUD_NOARP;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			d = *argv;
+		} else if (strcmp(*argv, "local") == 0) {
+			req.ndm.ndm_state = NUD_PERMANENT;
+		} else if (strcmp(*argv, "temp") == 0) {
+			req.ndm.ndm_state = NUD_REACHABLE;
+		} else {
+			if (strcmp(*argv, "to") == 0) {
+				NEXT_ARG();
+			}
+			if (matches(*argv, "help") == 0) {
+				NEXT_ARG();
+			}
+			if (addr)
+				duparg2("to", *argv);
+			addr = *argv;
+		}
+		argc--; argv++;
+	}
+
+	if (d == NULL || addr == NULL) {
+		fprintf(stderr, "Device and address are required arguments.\n");
+		exit(-1);
+	}
+
+	if (sscanf(addr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", 
+		   abuf, abuf+1, abuf+2,
+		   abuf+3, abuf+4, abuf+5) != 6) {
+		fprintf(stderr, "Invalid mac address %s\n", addr);
+		exit(-1);
+	}
+
+	addattr_l(&req.n, sizeof(req), NDA_LLADDR, abuf, ETH_ALEN);
+
+	req.ndm.ndm_ifindex = ll_name_to_index(d);
+	if (req.ndm.ndm_ifindex == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", d);
+		return -1;
+	}
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
+int do_fdb(int argc, char **argv)
+{
+	ll_init_map(&rth);
+
+	if (argc > 0) {
+		if (matches(*argv, "add") == 0)
+			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_EXCL, argc-1, argv+1);
+		if (matches(*argv, "change") == 0)
+			return fdb_modify(RTM_NEWNEIGH, NLM_F_REPLACE, argc-1, argv+1);
+
+		if (matches(*argv, "replace") == 0)
+			return fdb_modify(RTM_NEWNEIGH, NLM_F_CREATE|NLM_F_REPLACE, argc-1, argv+1);
+		if (matches(*argv, "delete") == 0)
+			return fdb_modify(RTM_DELNEIGH, 0, argc-1, argv+1);
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
+			return fdb_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return fdb_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip neigh help\".\n", *argv);
+	exit(-1);
+}
diff --git a/br/link.c b/br/link.c
new file mode 100644
index 0000000..1b9541d
--- /dev/null
+++ b/br/link.c
@@ -0,0 +1,142 @@
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <time.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <netinet/in.h>
+#include <linux/if.h>
+#include <linux/if_bridge.h>
+#include <string.h>
+
+#include "utils.h"
+#include "br_common.h"
+
+static const char *port_states[] = {
+	[BR_STATE_DISABLED] = "disabled",
+	[BR_STATE_LISTENING] = "listening",
+	[BR_STATE_LEARNING] = "learning",
+	[BR_STATE_FORWARDING] = "forwarding",
+	[BR_STATE_BLOCKING] = "blocking",
+};
+
+extern char *if_indextoname (unsigned int __ifindex, char *__ifname);
+
+static void print_link_flags(FILE *fp, unsigned flags)
+{
+	fprintf(fp, "<");
+	if (flags & IFF_UP && !(flags & IFF_RUNNING))
+		fprintf(fp, "NO-CARRIER%s", flags ? "," : "");
+	flags &= ~IFF_RUNNING;
+#define _PF(f) if (flags&IFF_##f) { \
+                  flags &= ~IFF_##f ; \
+                  fprintf(fp, #f "%s", flags ? "," : ""); }
+	_PF(LOOPBACK);
+	_PF(BROADCAST);
+	_PF(POINTOPOINT);
+	_PF(MULTICAST);
+	_PF(NOARP);
+	_PF(ALLMULTI);
+	_PF(PROMISC);
+	_PF(MASTER);
+	_PF(SLAVE);
+	_PF(DEBUG);
+	_PF(DYNAMIC);
+	_PF(AUTOMEDIA);
+	_PF(PORTSEL);
+	_PF(NOTRAILERS);
+	_PF(UP);
+	_PF(LOWER_UP);
+	_PF(DORMANT);
+	_PF(ECHO);
+#undef _PF
+        if (flags)
+		fprintf(fp, "%x", flags);
+	fprintf(fp, "> ");
+}
+
+static const char *oper_states[] = {
+	"UNKNOWN", "NOTPRESENT", "DOWN", "LOWERLAYERDOWN", 
+	"TESTING", "DORMANT",	 "UP"
+};
+
+static void print_operstate(FILE *f, __u8 state)
+{
+	if (state >= sizeof(oper_states)/sizeof(oper_states[0]))
+		fprintf(f, "state %#x ", state);
+	else
+		fprintf(f, "state %s ", oper_states[state]);
+}
+
+int print_linkinfo(const struct sockaddr_nl *who,
+		   struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	int len = n->nlmsg_len;
+	struct ifinfomsg *ifi = NLMSG_DATA(n);
+	struct rtattr * tb[IFLA_MAX+1];
+	char b1[IFNAMSIZ];
+
+	len -= NLMSG_LENGTH(sizeof(*ifi));
+	if (len < 0) {
+		fprintf(stderr, "Message too short!\n");
+		return -1;
+        }
+
+	if (!(ifi->ifi_family == AF_BRIDGE || ifi->ifi_family == AF_UNSPEC))
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
+
+	if (tb[IFLA_IFNAME] == NULL) {
+		fprintf(stderr, "BUG: nil ifname\n");
+		return -1;
+	}
+
+	if (n->nlmsg_type == RTM_DELLINK)
+		fprintf(fp, "Deleted ");
+
+	fprintf(fp, "%d: %s ", ifi->ifi_index,
+		tb[IFLA_IFNAME] ? (char*)RTA_DATA(tb[IFLA_IFNAME]) : "<nil>");
+
+	if (tb[IFLA_OPERSTATE]) 
+		print_operstate(fp, *(__u8 *)RTA_DATA(tb[IFLA_OPERSTATE]));
+	
+	if (tb[IFLA_LINK]) {
+		SPRINT_BUF(b1);
+		int iflink = *(int*)RTA_DATA(tb[IFLA_LINK]);
+		
+		if (iflink == 0)
+			fprintf(fp, "@NONE: ");
+		else {
+			fprintf(fp, "@%s: ", 
+				if_indextoname(iflink, b1));
+		}
+	} else {
+		fprintf(fp, ": ");
+	}
+
+	print_link_flags(fp, ifi->ifi_flags);
+
+	if (tb[IFLA_MTU])
+		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
+
+	if (tb[IFLA_MASTER]) {
+		fprintf(fp, "master %s ", 
+			if_indextoname(*(int*)RTA_DATA(tb[IFLA_MASTER]), b1));
+	}
+
+	if (tb[IFLA_PROTINFO]) {
+		uint8_t state = *(uint8_t *)RTA_DATA(tb[IFLA_PROTINFO]);
+		if (state <= BR_STATE_BLOCKING)
+			fprintf(fp, "state %s", port_states[state]);
+		else
+			fprintf(fp, "state (%d)", state);
+	}
+
+
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
diff --git a/br/monitor.c b/br/monitor.c
new file mode 100644
index 0000000..37468e6
--- /dev/null
+++ b/br/monitor.c
@@ -0,0 +1,138 @@
+/*
+ * brmonitor.c		"br monitor"
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@vyatta.com>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <time.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/if_bridge.h>
+#include <linux/neighbour.h>
+#include <string.h>
+
+#include "utils.h"
+#include "br_common.h"
+
+
+static void usage(void) __attribute__((noreturn));
+int prefix_banner;
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: br monitor\n");
+	exit(-1);
+}
+
+static int show_mark(FILE *fp, const struct nlmsghdr *n)
+{
+	char *tstr;
+	time_t secs = ((__u32*)NLMSG_DATA(n))[0];
+	long usecs = ((__u32*)NLMSG_DATA(n))[1];
+	tstr = asctime(localtime(&secs));
+	tstr[strlen(tstr)-1] = 0;
+	fprintf(fp, "Timestamp: %s %lu us\n", tstr, usecs);
+	return 0;
+}
+
+int accept_msg(const struct sockaddr_nl *who,
+	       struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+
+	if (timestamp)
+		print_timestamp(fp);
+
+	switch (n->nlmsg_type) {
+	case RTM_NEWLINK:
+	case RTM_DELLINK:
+		if (prefix_banner)
+			fprintf(fp, "[LINK]");
+
+		return print_linkinfo(who, n, arg);
+
+	case RTM_NEWNEIGH:
+	case RTM_DELNEIGH:
+		if (prefix_banner)
+			fprintf(fp, "[NEIGH]");
+		return print_fdb(who, n, arg);
+
+	case 15:
+		return show_mark(fp, n);
+
+	default:
+		return 0;
+	}
+	
+
+}
+
+int do_monitor(int argc, char **argv)
+{
+	char *file = NULL;
+	unsigned groups = ~RTMGRP_TC;
+	int llink=0;
+	int lneigh=0;
+
+	rtnl_close(&rth);
+
+	while (argc > 0) {
+		if (matches(*argv, "file") == 0) {
+			NEXT_ARG();
+			file = *argv;
+		} else if (matches(*argv, "link") == 0) {
+			llink=1;
+			groups = 0;
+		} else if (matches(*argv, "fdb") == 0) {
+			lneigh = 1;
+			groups = 0;
+		} else if (strcmp(*argv, "all") == 0) {
+			groups = ~RTMGRP_TC;
+			prefix_banner=1;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			fprintf(stderr, "Argument \"%s\" is unknown, try \"br monitor help\".\n", *argv);
+			exit(-1);
+		}
+		argc--;	argv++;
+	}
+
+	if (llink)
+		groups |= nl_mgrp(RTNLGRP_LINK);
+
+	if (lneigh) {
+		groups |= nl_mgrp(RTNLGRP_NEIGH);
+	}
+
+	if (file) {
+		FILE *fp;
+		fp = fopen(file, "r");
+		if (fp == NULL) {
+			perror("Cannot fopen");
+			exit(-1);
+		}
+		return rtnl_from_file(fp, accept_msg, stdout);
+	}
+
+	if (rtnl_open(&rth, groups) < 0)
+		exit(1);
+	ll_init_map(&rth);
+
+	if (rtnl_listen(&rth, accept_msg, stdout) < 0)
+		exit(2);
+
+	return 0;
+}
+
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
new file mode 100644
index 0000000..8a5d21e
--- /dev/null
+++ b/man/man8/bridge.8
@@ -0,0 +1,177 @@
+.TH BRIDGE 8 "4 October 2011" "iproute2" "Linux"
+.SH NAME
+bridge \- show / manipulate bridge addresses and devices
+.SH SYNOPSIS
+
+.ad l
+.in +8
+.ti -8
+.B bridge
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OBJECT " := { "
+.BR fdb " | " monitor " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+\fB\-s\fR[\fItatistics\fR]
+
+.ti -8
+.BR "bridge fdb" " { " add " | " del " | " change " | " replace " } "
+.I LLADDR
+.B  dev
+.IR DEV " { "
+.BR local " | " temp " }"
+
+.ti -8
+.BR "bridge fdb" " [ " show " ] [ "
+.B  dev
+.IR DEV " ]"
+
+.ti -8
+.BR "bridge monitor" " [ " all " | " neigh " | " link " ]"
+
+.SH OPTIONS
+
+.TP
+.BR "\-V" , " -Version"
+print the version of the
+.B ip
+utility and exit.
+
+.TP
+.BR "\-s" , " \-stats", " \-statistics"
+output more information.  If the option
+appears twice or more, the amount of information increases.
+As a rule, the information is statistics or some time values.
+
+
+.SH BRIDGE - COMMAND SYNTAX
+
+.SS
+.I OBJECT
+
+.TP
+.B fdb
+- Forwarding Database entry.
+
+.SS
+.I COMMAND
+
+Specifies the action to perform on the object.
+The set of possible actions depends on the object type.
+As a rule, it is possible to
+.BR "add" , " delete"
+and
+.B show
+(or
+.B list
+) objects, but some objects do not allow all of these operations
+or have some additional commands.  The
+.B help
+command is available for all objects.  It prints
+out a list of available commands and argument syntax conventions.
+.sp
+If no command is given, some default command is assumed.
+Usually it is
+.B list
+or, if the objects of this class cannot be listed,
+.BR "help" .
+
+.SH bridge fdb - forwarding database management
+
+.B fdb
+objects contain known ethernet addresses fona  link.
+
+.P
+The corresponding commands display fdb entries, add new entries,
+and delete old ones.
+
+.SS bridge fdb add - add a new neighbour entry
+.SS bridge fdb change - change an existing entry
+.SS bridge fdb replace - add a new entry or change an existing one
+
+These commands create new neighbour records or update existing ones.
+
+.TP
+.BI "ADDRESS"
+the Ethernet MAC address.
+
+.TP
+.BI dev " NAME"
+the interface to which this address is associated.
+
+.TP
+.in +8
+.B local
+- the address is associated with a local interface on the system
+and is never forwarded.
+.sp
+
+.B temp
+- the address is a dynamic entry, and will be removed if not used.
+.sp
+
+.in -8
+
+.SS bridge fdb delete - delete a forwarding database entry
+This command removes an existing fdb entry.
+
+.PP
+The arguments are the same as with
+.BR "bridge fdb add" ,
+
+.SS bridge fdb show - list forwarding entries.
+
+This commands displays current forwarding table.
+
+.PP
+With the
+.B -statistics
+option, the command becomes verbose.  It prints out the last updated
+and last used time for each entry.
+
+.SH bridge monitor - state monitoring
+
+The
+.B bridge
+utility can monitor the state of devices and  addresses
+continuously.  This option has a slightly different format.
+Namely, the
+.B monitor
+command is the first in the command line and then the object list follows:
+
+.BR "bridge monitor" " [ " all " |"
+.IR LISTofOBJECTS " ]"
+
+.I OBJECT-LIST
+is the list of object types that we want to monitor.
+It may contain
+.BR link ",  and " fdb "."
+If no
+.B file
+argument is given,
+.B ip
+opens RTNETLINK, listens on it and dumps state changes in the format
+described in previous sections.
+
+.P
+If a file name is given, it does not listen on RTNETLINK,
+but opens the file containing RTNETLINK messages saved in binary format
+and dumps them.  Such a history file can be generated with the
+
+.SH HISTORY
+.B bridge
+was written by Stephen Hemminger and uses kernel facilities added in Linux 3.0
+.SH SEE ALSO
+.BR ip (8)
+.br
+.RB "Please direct bugreports and patches to: " <netdev@vger.kernel.org>
+
+.SH AUTHOR
+Original Manpage by Stephen Hemminger
-- 
1.7.6.3
