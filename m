From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 iproute2 1/3] bridge: Add support for setting bridge port attributes
Date: Fri, 15 Mar 2013 12:46:39 -0400
Message-ID: <1363366001-27622-2-git-send-email-vyasevic@redhat.com>
References: <1363366001-27622-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489Ab3COQqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 12:46:46 -0400
In-Reply-To: <1363366001-27622-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink support bridge port attributes such as cost, priority, state
and flags.  This also adds support for HW mode such as VEPA or VEB.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 bridge/br_common.h |    1 +
 bridge/bridge.c    |    3 +-
 bridge/link.c      |  217 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 220 insertions(+), 1 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 8764563..12fce3e 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -10,6 +10,7 @@ extern int do_fdb(int argc, char **argv);
 extern int do_mdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 extern int do_vlan(int argc, char **argv);
+extern int do_link(int argc, char **argv);
 
 extern int preferred_family;
 extern int show_stats;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index 06b7a54..77e260f 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -27,7 +27,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
-"where  OBJECT := { fdb | mdb | vlan | monitor }\n"
+"where  OBJECT := { link | fdb | mdb | vlan | monitor }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails]\n" );
 	exit(-1);
 }
@@ -42,6 +42,7 @@ static const struct cmd {
 	const char *cmd;
 	int (*func)(int argc, char **argv);
 } cmds[] = {
+	{ "link", 	do_link },
 	{ "fdb", 	do_fdb },
 	{ "mdb", 	do_mdb },
 	{ "vlan",	do_vlan },
diff --git a/bridge/link.c b/bridge/link.c
index edb6fbf..5811ee9 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -9,10 +9,14 @@
 #include <linux/if.h>
 #include <linux/if_bridge.h>
 #include <string.h>
+#include <stdbool.h>
 
+#include "libnetlink.h"
 #include "utils.h"
 #include "br_common.h"
 
+unsigned int filter_index;
+
 static const char *port_states[] = {
 	[BR_STATE_DISABLED] = "disabled",
 	[BR_STATE_LISTENING] = "listening",
@@ -87,6 +91,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (!(ifi->ifi_family == AF_BRIDGE || ifi->ifi_family == AF_UNSPEC))
 		return 0;
 
+	if (filter_index && filter_index != ifi->ifi_index)
+		return 0;
+
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
 
 	if (tb[IFLA_IFNAME] == NULL) {
@@ -136,3 +143,213 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	fflush(fp);
 	return 0;
 }
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: bridge link set dev DEV [ cost COST ] [ priority PRIO ] [ state STATE ]\n");
+	fprintf(stderr, "                               [ guard {on | off} ]\n");
+	fprintf(stderr, "                               [ hairpin {on | off} ] \n");
+	fprintf(stderr, "                               [ fastleave {on | off} ]\n");
+	fprintf(stderr,	"                               [ root_block {on | off} ]\n");
+	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
+	fprintf(stderr, "       bridge link show [dev DEV]\n");
+	exit(-1);
+}
+
+static bool on_off(char *arg, __s8 *attr, char *val)
+{
+	if (strcmp(val, "on") == 0)
+		*attr = 1;
+	else if (strcmp(val, "off") == 0)
+		*attr = 0;
+	else {
+		fprintf(stderr,
+			"Error: argument of \"%s\" must be \"on\" or \"off\"\n",
+			arg);
+		return false;
+	}
+
+	return true;
+}
+
+static int brlink_modify(int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr  n;
+		struct ifinfomsg ifm;
+		char             buf[512];
+	} req;
+	char *d = NULL;
+	__s8 hairpin = -1;
+	__s8 bpdu_guard = -1;
+	__s8 fast_leave = -1;
+	__u32 cost = 0;
+	__s16 priority = -1;
+	__s8 state = -1;
+	__s16 mode = -1;
+	__u16 flags = BRIDGE_FLAGS_MASTER;
+	struct rtattr *nest;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_SETLINK;
+	req.ifm.ifi_family = PF_BRIDGE;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			d = *argv;
+		} else if (strcmp(*argv, "guard") == 0) {
+			NEXT_ARG();
+			if (!on_off("guard", &bpdu_guard, *argv))
+				exit(-1);
+		} else if (strcmp(*argv, "hairpin") == 0) {
+			NEXT_ARG();
+			if (!on_off("hairping", &hairpin, *argv))
+				exit(-1);
+		} else if (strcmp(*argv, "fastleave") == 0) {
+			NEXT_ARG();
+			if (!on_off("fastleave", &fast_leave, *argv))
+				exit(-1);
+		} else if (strcmp(*argv, "cost")) {
+			NEXT_ARG();
+			cost = atoi(*argv);
+		} else if (strcmp(*argv, "priority")) {
+			NEXT_ARG();
+			priority = atoi(*argv);
+		} else if (strcmp(*argv, "state")) {
+			NEXT_ARG();
+			state = atoi(*argv);
+		} else if (strcmp(*argv, "mode")) {
+			NEXT_ARG();
+			flags |= BRIDGE_FLAGS_SELF;
+			if (strcmp(*argv, "vepa") == 0)
+				mode = BRIDGE_MODE_VEPA;
+			else if (strcmp(*argv, "veb") == 0)
+				mode = BRIDGE_MODE_VEB;
+			else {
+				fprintf(stderr,
+					"Mode argument must be \"vepa\" or "
+					"\"veb\".\n");
+				exit(-1);
+			}
+		} else {
+			usage();
+		}
+		argc--; argv++;
+	}
+	if (d == NULL) {
+		fprintf(stderr, "Device is a required argument.\n");
+		exit(-1);
+	}
+
+
+	req.ifm.ifi_index = ll_name_to_index(d);
+	if (req.ifm.ifi_index == 0) {
+		fprintf(stderr, "Cannot find bridge device \"%s\"\n", d);
+		exit(-1);
+	}
+
+	/* Nested PROTINFO attribute.  Contains: port flags, cost, priority and
+	 * state.
+	 */
+	nest = addattr_nest(&req.n, sizeof(req),
+			    IFLA_PROTINFO | NLA_F_NESTED);
+	/* Flags first */
+	if (bpdu_guard >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_GUARD, bpdu_guard);
+	if (hairpin >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_MODE, hairpin);
+	if (fast_leave >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_FAST_LEAVE,
+			 fast_leave);
+
+	if (cost > 0)
+		addattr32(&req.n, sizeof(req), IFLA_BRPORT_COST, cost);
+
+	if (priority >= 0)
+		addattr16(&req.n, sizeof(req), IFLA_BRPORT_PRIORITY, priority);
+
+	if (state >= 0)
+		addattr8(&req.n, sizeof(req), IFLA_BRPORT_STATE, state);
+
+	addattr_nest_end(&req.n, nest);
+
+	/* IFLA_AF_SPEC nested attribute.  Contains IFLA_BRIDGE_FLAGS that
+	 * designates master or self operation as well as 'vepa' or 'veb'
+	 * operation modes.  These are only valid in 'self' mode on some
+	 * devices so far.  Thus we only need to include the flags attribute
+	 * if we are setting the hw mode.
+	 */
+	if (mode >= 0) {
+		nest = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+
+		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
+
+		if (mode >= 0)
+			addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
+
+		addattr_nest_end(&req.n, nest);
+	}
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
+static int brlink_show(int argc, char **argv)
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
+		if ((filter_index = ll_name_to_index(filter_dev)) == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n",
+				filter_dev);
+			return -1;
+		}
+	}
+
+	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
+		perror("Cannon send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&rth, print_linkinfo, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+	return 0;
+}
+
+int do_link(int argc, char **argv)
+{
+	ll_init_map(&rth);
+	if (argc > 0) {
+		if (matches(*argv, "set") == 0 ||
+		    matches(*argv, "change") == 0)
+			return brlink_modify(argc-1, argv+1);
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
+			return brlink_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return brlink_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge link help\".\n", *argv);
+	exit(-1);
+}
-- 
1.7.7.6
