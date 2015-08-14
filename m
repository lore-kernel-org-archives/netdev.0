From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: [PATCH] iproute2: Extend bridge command to configure ageing
 interval on bridge devices.
Date: Fri, 14 Aug 2015 09:50:02 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1FA4@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:45548 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbbHNJuF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 05:50:05 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend bridge command to configure and retrieve ageing interval for bridge
devices.  Netlink messaging is used to configure and retrieve the ageing
interval.

Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>

---

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 169a162..85cca68 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -5,12 +5,15 @@ extern int print_fdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
 extern int print_mdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
+extern int print_ageinfo(const struct sockaddr_nl *who,
+			 struct nlmsghdr *n, void *arg);
 
 extern int do_fdb(int argc, char **argv);
 extern int do_mdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 extern int do_vlan(int argc, char **argv);
 extern int do_link(int argc, char **argv);
+extern int do_ageing(int argc, char **argv);
 
 extern int preferred_family;
 extern int show_stats;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index eaf09c8..cf193d5 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -31,7 +31,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
-"where	OBJECT := { link | fdb | mdb | vlan | monitor }\n"
+"where	OBJECT := { link | fdb | mdb | vlan | monitor | ageing }\n"
 "	OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
 "		     -o[neline] | -t[imestamp] | -n[etns] name |\n"
 "		     -c[ompressvlans] }\n");
@@ -53,6 +53,7 @@ static const struct cmd {
 	{ "mdb",	do_mdb },
 	{ "vlan",	do_vlan },
 	{ "monitor",	do_monitor },
+	{ "ageing",      do_ageing },
 	{ "help",	do_help },
 	{ 0 }
 };
diff --git a/bridge/fdb.c b/bridge/fdb.c
index bd7e4f9..55c96f7 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -21,6 +21,7 @@
 #include <linux/neighbour.h>
 #include <string.h>
 #include <limits.h>
+#include <errno.h>
 
 #include "libnetlink.h"
 #include "br_common.h"
@@ -371,6 +372,161 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	return 0;
 }
 
+static void ageing_usage(void)
+{
+	fprintf(stderr, "Usage: bridge ageing interval { show | SECONDS | default } dev DEV\n");
+	exit(-1);
+}
+
+int print_ageinfo(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	struct admsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+
+	len -= NLMSG_LENGTH(sizeof(*r));
+
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len%d\n", len);
+		return -1;
+	}
+
+	if (r->adm_family != AF_BRIDGE)
+		return 0;
+	fprintf(fp, "dev %s, ageing %d secs\n",
+		ll_index_to_name(r->adm_ifindex), r->adm_ageing_interval);
+	return 0;
+}
+
+static int do_ageing_show(char *dev)
+{
+	struct {
+		struct nlmsghdr n;
+		struct admsg adm;
+		char buf[256];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct admsg));
+	req.n.nlmsg_type = RTM_GETAGEING;
+
+	int br_ifindex = ll_name_to_index(dev);
+
+	if (br_ifindex == 0) {
+		fprintf(stderr, "Cannot find bridge device \"%s\"\n", dev);
+		return -1;
+	}
+
+	req.adm.adm_family = PF_BRIDGE;
+	req.adm.adm_ifindex = br_ifindex;
+
+	if (rtnl_dump_request(&rth, RTM_GETAGEING, &req.adm,
+			      sizeof(struct admsg)) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&rth, print_ageinfo, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+	return 0;
+}
+
+static int do_ageing_modify(int default_ageing, int interval, char *dev)
+{
+	struct {
+		struct nlmsghdr n;
+		struct admsg adm;
+		char buf[256];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct admsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+
+	if (default_ageing) {
+		req.n.nlmsg_type = RTM_SETDEFAULTAGEING;
+		req.adm.adm_ageing_interval = 0; /* Don't care */
+	} else {
+		req.n.nlmsg_type = RTM_SETAGEING;
+		req.adm.adm_ageing_interval = interval;
+	}
+
+	req.adm.adm_family = PF_BRIDGE;
+	req.adm.adm_ifindex = ll_name_to_index(dev);
+
+	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+		return -1;
+
+	return 0;
+}
+
+int do_ageing(int argc, char **argv)
+{
+	int interval = -1;
+	int default_ageing = 0;
+	char *dev = NULL;
+	int show = 0;
+
+	ll_init_map(&rth);
+
+	if (argc > 0) {
+		if (matches(*argv, "interval") == 0) {
+			argv++;
+			argc--;
+		} else {
+			ageing_usage();
+			exit(-1);
+		}
+	}
+
+	if (argc > 0) {
+		if (matches(*argv, "show") == 0) {
+			show = 1;
+		} else if (matches(*argv, "default") == 0) {
+			default_ageing = 1;
+			interval = 0;
+		} else if (matches(*argv, "help") == 0) {
+			ageing_usage();
+			exit(-1);
+		} else {
+			errno = 0;
+			interval = atoi(*argv);
+			if (errno) {
+				ageing_usage();
+				exit(-1);
+			}
+		}
+		argv++;
+		argc--;
+	} else {
+		ageing_usage();
+		exit(-1);
+	}
+
+	if (argc > 0) {
+		NEXT_ARG();
+		dev = *argv;
+	} else {
+		ageing_usage();
+		exit(-1);
+	}
+
+	if (show) {
+		do_ageing_show(dev);
+		return 0;
+	} else if (default_ageing || (interval > 0)) {
+		do_ageing_modify(default_ageing, interval, dev);
+		return 0;
+	}
+
+	fprintf(stderr, "Command unknown, try \'bridge interval help\'");
+	exit(-1);
+}
+
 int do_fdb(int argc, char **argv)
 {
 	ll_init_map(&rth);
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 968034b..9e3f092 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -161,6 +161,14 @@ extern int rtnl_from_file(FILE *, rtnl_listen_filter_t handler,
 #define NDA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
 #endif
 
+#ifndef ADA_RTA
+#define ADA_RTA(r) \
+	((struct rtattr *)(((char *)(r)) + NLMSG_ALIGN(sizeof(struct admsg))))
+#endif
+#ifndef ADA_PAYLOAD
+#define ADA_PAYLOAD(n)	NLMSG_PAYLOAD(n, sizeof(struct admsg))
+#endif
+
 #ifndef NDTA_RTA
 #define NDTA_RTA(r) \
 	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndtmsg))))
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 913bd8e..dac6452 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -198,4 +198,11 @@ enum {
 };
 #define MDBA_SET_ENTRY_MAX (__MDBA_SET_ENTRY_MAX - 1)
 
+struct admsg {
+	__u8 adm_family;
+	__u8 adm_pad1;
+	__u16	adm_pad2;
+	__s32 adm_ifindex;
+	__u16 adm_ageing_interval;
+};
 #endif /* _LINUX_IF_BRIDGE_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index a78f0b3..abc9617 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -139,6 +139,13 @@ enum {
 	RTM_GETNSID = 90,
 #define RTM_GETNSID RTM_GETNSID
 
+	RTM_SETAGEING = 92,
+#define RTM_SETAGEING RTM_SETAGEING
+	RTM_SETDEFAULTAGEING = 93,
+#define RTM_SETDEFAULTAGEING RTM_SETDEFAULTAGEING
+	RTM_GETAGEING = 94,
+#define RTM_GETAGEING RTM_GETAGEING
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
