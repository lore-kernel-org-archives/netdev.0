From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2] Generic netlink interface
Date: Sun, 02 Jul 2006 16:54:17 -0400
Message-ID: <1151873657.5093.270.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uyadWekLJMSmTJ74bACi"
Cc: Shailabh Nagar <nagar@watson.ibm.com>, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:7656 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750794AbWGBUyY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 16:54:24 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fx8xY-00017p-LD
	for netdev@vger.kernel.org; Sun, 02 Jul 2006 16:54:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uyadWekLJMSmTJ74bACi
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


very quiet today ..

Stephen,
I've been sitting on this for a while now; just tested against latest
kernels. 

Another one on top of the other i.e against iproute2-git.

Shailabh, if you have time can you try just listing things, monitoring
etc; I dont think your tool fits here - but if you could try and use the
framework (cutnpaste from ctrl.c) and provide feedback i would
appreciate it.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

--=-uyadWekLJMSmTJ74bACi
Content-Disposition: attachment; filename=gnl-ctrl-p
Content-Type: text/plain; name=gnl-ctrl-p; charset=UTF-8
Content-Transfer-Encoding: 7bit

This patch adds a generic netlink controller interface.
The controller is the only module using this at the moment.
Thomas has a sample user of genetlink that would fit here; bug him
for it.

---
commit 9cd6ca6d2a2b1b27fc3c98ecb8e081b19aa64019
tree ff513f5484e1dbe27ef8fbb6f2e31d82ffbdcb3b
parent 00f2ad46f0040769f0d4e4541fe0731f20164664
author Jamal Hadi Salim <hadi@jzny2.(none)> Sun, 02 Jul 2006 16:40:18 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Sun, 02 Jul 2006 16:40:18 -0400

 Makefile          |    2 
 genl/Makefile     |   22 ++++
 genl/ctrl.c       |  284 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 genl/genl.c       |  162 ++++++++++++++++++++++++++++++
 genl/genl_utils.h |   22 ++++
 5 files changed, 491 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index ac58cd9..3fc3a15 100644
--- a/Makefile
+++ b/Makefile
@@ -27,7 +27,7 @@ YACCFLAGS = -d -t -v
 
 LDLIBS += -L../lib -lnetlink -lutil
 
-SUBDIRS=lib ip tc misc netem
+SUBDIRS=lib ip tc misc netem genl
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 
diff --git a/genl/Makefile b/genl/Makefile
new file mode 100644
index 0000000..4436508
--- /dev/null
+++ b/genl/Makefile
@@ -0,0 +1,22 @@
+GENLOBJ=genl.o
+
+include ../Config
+
+GENLMODULES :=
+GENLMODULES += ctrl.o
+
+GENLOBJ += $(GENLMODULES)
+
+GENLLIB :=
+
+LDFLAGS += -Wl,-export-dynamic -lm -ldl
+
+all: genl
+
+genl: $(GENLOBJ) $(LIBNETLINK) $(LIBUTIL) $(GENLLIB)
+
+install: all
+	install -m 0755 -s genl $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(GENLOBJ) $(GENLLIB) genl
diff --git a/genl/ctrl.c b/genl/ctrl.c
new file mode 100644
index 0000000..0d4750d
--- /dev/null
+++ b/genl/ctrl.c
@@ -0,0 +1,284 @@
+/*
+ * ctrl.c	generic netlink controller
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  J Hadi Salim (hadi@cyberus.ca)
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+
+#include "utils.h"
+#include "genl_utils.h"
+
+static int usage(void)
+{
+	fprintf(stderr,"Usage: ctrl <CMD>\n" \
+		       "CMD   := get <PARMS> | list | monitor\n" \
+		       "PARMS := name <name> | id <id>\n" \
+		       "Examples:\n" \
+		       "\tctrl ls\n" \
+		       "\tctrl monitor\n" \
+		       "\tctrl get name foobar\n" \
+		       "\tctrl get id 0xF\n");
+	return -1;
+}
+
+int genl_ctrl_resolve_family(const char *family)
+{
+	struct rtnl_handle rth;
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *ghdr;
+	int ret = 0;
+	struct {
+		struct nlmsghdr         n;
+		char                    buf[4096];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	nlh = &req.n;
+	nlh->nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	nlh->nlmsg_type = GENL_ID_CTRL;
+
+	ghdr = NLMSG_DATA(&req.n);
+	ghdr->cmd = CTRL_CMD_GETFAMILY;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
+		fprintf(stderr, "Cannot open generic netlink socket\n");
+		exit(1);
+	}
+
+	addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME, family, strlen(family) + 1);
+
+	if (rtnl_talk(&rth, nlh, 0, 0, nlh, NULL, NULL) < 0) {
+		fprintf(stderr, "Error talking to the kernel\n");
+		goto errout;
+	}
+
+	{
+		struct rtattr *tb[CTRL_ATTR_MAX + 1];
+		struct genlmsghdr *ghdr = NLMSG_DATA(nlh);
+		int len = nlh->nlmsg_len;
+		struct rtattr *attrs;
+
+		if (nlh->nlmsg_type !=  GENL_ID_CTRL) {
+			fprintf(stderr, "Not a controller message, nlmsg_len=%d "
+				"nlmsg_type=0x%x\n", nlh->nlmsg_len, nlh->nlmsg_type);
+			goto errout;
+		}
+
+		if (ghdr->cmd != CTRL_CMD_NEWFAMILY) {
+			fprintf(stderr, "Unkown controller command %d\n", ghdr->cmd);
+			goto errout;
+		}
+
+		len -= NLMSG_LENGTH(GENL_HDRLEN);
+
+		if (len < 0) {
+			fprintf(stderr, "wrong controller message len %d\n", len);
+			return -1;
+		}
+
+		attrs = (struct rtattr *) ((char *) ghdr + GENL_HDRLEN);
+		parse_rtattr(tb, CTRL_ATTR_MAX, attrs, len);
+
+		if (tb[CTRL_ATTR_FAMILY_ID] == NULL) {
+			fprintf(stderr, "Missing family id TLV\n");
+			goto errout;
+		}
+
+		ret = *(__u16 *) RTA_DATA(tb[CTRL_ATTR_FAMILY_ID]);
+	}
+
+errout:
+	rtnl_close(&rth);
+	return ret;
+}
+
+static int print_ctrl(const struct sockaddr_nl *who, struct nlmsghdr *n,
+		      void *arg)
+{
+	struct rtattr *tb[CTRL_ATTR_MAX + 1];
+	struct genlmsghdr *ghdr = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr *attrs;
+	FILE *fp = (FILE *) arg;
+
+	if (n->nlmsg_type !=  GENL_ID_CTRL) {
+		fprintf(stderr, "Not a controller message, nlmsg_len=%d "
+			"nlmsg_type=0x%x\n", n->nlmsg_len, n->nlmsg_type);
+		return 0;
+	}
+
+	if (ghdr->cmd != CTRL_CMD_GETFAMILY &&
+	    ghdr->cmd != CTRL_CMD_DELFAMILY &&
+	    ghdr->cmd != CTRL_CMD_NEWFAMILY) {
+		fprintf(stderr, "Unkown controller command %d\n", ghdr->cmd);
+		return 0;
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
+	if (tb[CTRL_ATTR_FAMILY_NAME]) {
+		char *name = RTA_DATA(tb[CTRL_ATTR_FAMILY_NAME]);
+		fprintf(fp, "Name: %s\n",name);
+	}
+	if (tb[CTRL_ATTR_FAMILY_ID]) {
+		__u16 *id = RTA_DATA(tb[CTRL_ATTR_FAMILY_ID]);
+		fprintf(fp, "ID: 0x%x\n",*id);
+	}
+
+	fflush(fp);
+	return 0;
+}
+
+static int ctrl_list(int cmd, int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *ghdr;
+	int ret = -1;
+	char d[GENL_NAMSIZ];
+	struct {
+		struct nlmsghdr         n;
+		char                    buf[4096];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	nlh = &req.n;
+	nlh->nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
+	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
+	nlh->nlmsg_type = GENL_ID_CTRL;
+
+	ghdr = NLMSG_DATA(&req.n);
+	ghdr->cmd = CTRL_CMD_GETFAMILY;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
+		fprintf(stderr, "Cannot open generic netlink socket\n");
+		exit(1);
+	}
+
+	if (cmd == CTRL_CMD_GETFAMILY) {
+		if (argc != 2) {
+			fprintf(stderr, "Wrong number of params\n");
+			return -1;
+		}
+
+		if (matches(*argv, "name") == 0) {
+			NEXT_ARG();
+			strncpy(d, *argv, sizeof (d) - 1);
+			addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME,
+				  d, strlen(d) + 1);
+		} else if (matches(*argv, "id") == 0) {
+			__u16 id;
+			NEXT_ARG();
+			if (get_u16(&id, *argv, 0)) {
+				fprintf(stderr, "Illegal \"id\"\n");
+				goto ctrl_done;
+			}
+
+			addattr_l(nlh, 128, CTRL_ATTR_FAMILY_ID, &id, 2);
+
+		} else {
+			fprintf(stderr, "Wrong params\n");
+			goto ctrl_done;
+		}
+
+		if (rtnl_talk(&rth, nlh, 0, 0, nlh, NULL, NULL) < 0) {
+			fprintf(stderr, "Error talking to the kernel\n");
+			goto ctrl_done;
+		}
+
+		if (print_ctrl(NULL, nlh, (void *) stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			goto ctrl_done;
+		}
+
+	}
+
+	if (cmd == CTRL_CMD_UNSPEC) {
+		nlh->nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+		nlh->nlmsg_seq = rth.dump = ++rth.seq;
+
+		if (rtnl_send(&rth, (const char *) nlh, nlh->nlmsg_len) < 0) {
+			perror("Failed to send dump request\n");
+			goto ctrl_done;
+		}
+
+		rtnl_dump_filter(&rth, print_ctrl, stdout, NULL, NULL);
+
+        }
+
+	ret = 0;
+ctrl_done:
+	rtnl_close(&rth);
+	return ret;
+}
+
+static int ctrl_listen(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+
+	if (rtnl_open_byproto(&rth, nl_mgrp(GENL_ID_CTRL), NETLINK_GENERIC) < 0) {
+		fprintf(stderr, "Canot open generic netlink socket\n");
+		return -1;
+	}
+
+	if (rtnl_listen(&rth, print_ctrl, (void *) stdout) < 0)
+		return -1;
+
+	return 0;
+}
+
+static int parse_ctrl(struct genl_util *a, int argc, char **argv)
+{
+	argv++;
+	if (--argc <= 0) {
+		fprintf(stderr, "wrong controller params\n");
+		return -1;
+	}
+
+	if (matches(*argv, "monitor") == 0)
+		return ctrl_listen(argc-1, argv+1);
+	if (matches(*argv, "get") == 0)
+		return ctrl_list(CTRL_CMD_GETFAMILY, argc-1, argv+1);
+	if (matches(*argv, "list") == 0 ||
+	    matches(*argv, "show") == 0 ||
+	    matches(*argv, "lst") == 0)
+		return ctrl_list(CTRL_CMD_UNSPEC, argc-1, argv+1);
+	if (matches(*argv, "help") == 0)
+		return usage();
+
+	fprintf(stderr, "ctrl command \"%s\" is unknown, try \"ctrl -help\".\n",
+		*argv);
+
+	return -1;
+}
+
+struct genl_util ctrl_genl_util = {
+	.name = "ctrl",
+	.parse_genlopt = parse_ctrl,
+	.print_genlopt = print_ctrl,
+};
diff --git a/genl/genl.c b/genl/genl.c
new file mode 100644
index 0000000..3ae75ae
--- /dev/null
+++ b/genl/genl.c
@@ -0,0 +1,162 @@
+/*
+ * genl.c		"genl" utility frontend.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jamal Hadi Salim
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <dlfcn.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include <errno.h>
+#include <linux/netlink.h>
+#include <linux/rtnetlink.h> /* until we put our own header */
+#include "SNAPSHOT.h"
+#include "utils.h"
+#include "genl_utils.h"
+
+int show_stats = 0;
+int show_details = 0;
+int show_raw = 0;
+int resolve_hosts = 0;
+
+static void *BODY;
+static struct genl_util * genl_list;
+
+
+static int print_nofopt(const struct sockaddr_nl *who, struct nlmsghdr *n,
+			void *arg)
+{
+	fprintf((FILE *) arg, "unknown genl type ..\n");
+	return 0;
+}
+
+static int parse_nofopt(struct genl_util *f, int argc, char **argv)
+{
+	if (argc) {
+		fprintf(stderr, "Unknown genl \"%s\", hence option \"%s\" "
+			"is unparsable\n", f->name, *argv);
+		return -1;
+	}
+
+	return 0;
+}
+
+static struct genl_util *get_genl_kind(char *str)
+{
+	void *dlh;
+	char buf[256];
+	struct genl_util *f;
+
+	for (f = genl_list; f; f = f->next)
+		if (strcmp(f->name, str) == 0)
+			return f;
+
+	snprintf(buf, sizeof(buf), "%s.so", str);
+	dlh = dlopen(buf, RTLD_LAZY);
+	if (dlh == NULL) {
+		dlh = BODY;
+		if (dlh == NULL) {
+			dlh = BODY = dlopen(NULL, RTLD_LAZY);
+			if (dlh == NULL)
+				goto noexist;
+		}
+	}
+
+	snprintf(buf, sizeof(buf), "%s_genl_util", str);
+
+	f = dlsym(dlh, buf);
+	if (f == NULL)
+		goto noexist;
+reg:
+	f->next = genl_list;
+	genl_list = f;
+	return f;
+
+noexist:
+	f = malloc(sizeof(*f));
+	if (f) {
+		memset(f, 0, sizeof(*f));
+		strncpy(f->name, str, 15);
+		f->parse_genlopt = parse_nofopt;
+		f->print_genlopt = print_nofopt;
+		goto reg;
+	}
+	return f;
+}
+
+static void usage(void) __attribute__((noreturn));
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: genl [ OPTIONS ] OBJECT | help }\n"
+	                "where  OBJECT := { ctrl etc }\n"
+	                "       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] }\n");
+	exit(-1);
+}
+
+int main(int argc, char **argv)
+{
+	char *basename;
+
+	basename = strrchr(argv[0], '/');
+	if (basename == NULL)
+		basename = argv[0];
+	else
+		basename++;
+
+	while (argc > 1) {
+		if (argv[1][0] != '-')
+			break;
+		if (matches(argv[1], "-stats") == 0 ||
+		    matches(argv[1], "-statistics") == 0) {
+			++show_stats;
+		} else if (matches(argv[1], "-details") == 0) {
+			++show_details;
+		} else if (matches(argv[1], "-raw") == 0) {
+			++show_raw;
+		} else if (matches(argv[1], "-Version") == 0) {
+			printf("genl utility, iproute2-ss%s\n", SNAPSHOT);
+			exit(0);
+		} else if (matches(argv[1], "-help") == 0) {
+			usage();
+		} else {
+			fprintf(stderr, "Option \"%s\" is unknown, try "
+				"\"genl -help\".\n", argv[1]);
+			exit(-1);
+		}
+		argc--;	argv++;
+	}
+
+	if (argc > 1) {
+		int ret;
+		struct genl_util *a = NULL;
+		a = get_genl_kind(argv[1]);
+		if (NULL == a) {
+			fprintf(stderr,"bad genl %s\n",argv[1]);
+		}
+
+		ret = a->parse_genlopt(a, argc-1, argv+1);
+		return ret;
+
+		if (matches(argv[1], "help") == 0)
+			usage();
+		fprintf(stderr, "Object \"%s\" is unknown, try \"genl "
+			"-help\".\n", argv[1]);
+		exit(-1);
+	}
+
+	usage();
+}
diff --git a/genl/genl_utils.h b/genl/genl_utils.h
new file mode 100644
index 0000000..2f2314b
--- /dev/null
+++ b/genl/genl_utils.h
@@ -0,0 +1,22 @@
+#ifndef _TC_UTIL_H_
+#define _TC_UTIL_H_ 1
+
+#include "linux/genetlink.h"
+
+struct genl_util
+{
+	struct  genl_util *next;
+	char	name[16];
+	int	(*parse_genlopt)(struct genl_util *fu, int argc, char **argv);
+	int	(*print_genlopt)(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
+};
+
+extern int genl_ctrl_resolve_family(const char *family);
+
+/* seems to have dissapeared from netlink.h */
+static inline __u32 nl_mgrp(__u32 group)
+{
+	return group ? 1 << group : 0;
+}
+
+#endif

--=-uyadWekLJMSmTJ74bACi--

