From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v2] iproute2: bridge: add veb/vepa toggle
Date: Fri, 02 Nov 2012 20:24:36 -0700
Message-ID: <20121103032436.8744.12352.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16056 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858Ab2KCDey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 23:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test bridge commands to set veb, vepa modes to iproute2.

[root@jf-dev1-dcblab iproute2]# ./bridge/bridge bridge show
eth2: mode VEB bridge_flags: self
eth3: mode VEPA bridge_flags: self
eth10: mode VEB bridge_flags: self
eth12: mode VEB bridge_flags: self

[root@jf-dev1-dcblab iproute2]# ./bridge/bridge bridge state mode veb dev eth3 self
bridge_mode_set eth3: type 19 family 7 mode VEB flags 0002

[root@jf-dev1-dcblab iproute2]# ./bridge/bridge bridge show
eth2: mode VEB bridge_flags: self
eth3: mode VEB bridge_flags: self
eth10: mode VEB bridge_flags: self
eth12: mode VEB bridge_flags: self

Maybe the final patch should separate protocol (STP) configuraiton
from the bridge setup (VEB.VEPA). But this is good for testing in
the meantime.

v2: remove a lot of the crazy cruft in the last patch

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 bridge/br_common.h      |    1 
 bridge/bridge.c         |    3 -
 bridge/fdb.c            |  244 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_link.h |   16 +++
 4 files changed, 263 insertions(+), 1 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 718ecb9..3e5dcab 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -5,6 +5,7 @@ extern int print_fdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
 
 extern int do_fdb(int argc, char **argv);
+extern int do_bridge(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 
 extern int preferred_family;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index e2c33b0..b5145c1 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -27,7 +27,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
-"where  OBJECT := { fdb |  monitor }\n"
+"where  OBJECT := { fdb |  monitor | bridge }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails]\n" );
 	exit(-1);
 }
@@ -43,6 +43,7 @@ static const struct cmd {
 	int (*func)(int argc, char **argv);
 } cmds[] = {
 	{ "fdb", 	do_fdb },
+	{ "bridge",	do_bridge },
 	{ "monitor",	do_monitor },
 	{ "help",	do_help },
 	{ 0 }
diff --git a/bridge/fdb.c b/bridge/fdb.c
index 4ca4861..e1c138d 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -34,6 +34,13 @@ static void usage(void)
 	exit(-1);
 }
 
+static void bridge_usage(void)
+{
+	fprintf(stderr, "Usage: br bridge er mode {veb | vepa} dev DEV\n");
+	fprintf(stderr, "	br bridge {show} [ dev DEV] \n");
+	exit(-1);
+}
+
 static const char *state_n2a(unsigned s)
 {
 	static char buf[32];
@@ -269,3 +276,240 @@ int do_fdb(int argc, char **argv)
 	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
 	exit(-1);
 }
+
+int print_bridge(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	struct ifinfomsg *ifm = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[IFLA_MAX+1];
+       
+	len -= NLMSG_LENGTH(sizeof(*ifm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (ifm->ifi_family != AF_BRIDGE) {
+		fprintf(stderr, "hmm: Not PF_BRIDGE is %i\n", ifm->ifi_family);
+	}
+
+	if (filter_index && filter_index != ifm->ifi_index)
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifm), len);
+
+	if (!tb[IFLA_IFNAME]) {
+		fprintf(stderr, "%s: missing ifname using ifi_index %u name %s\n",
+			__func__, ifm->ifi_index,
+			ll_index_to_name(ifm->ifi_index));
+	}
+	if (tb[IFLA_AF_SPEC]) {
+		struct rtattr *bridge[IFLA_BRIDGE_MAX+1];
+		__u16 mode = 0, flags = 0;
+
+		parse_rtattr_nested(bridge, IFLA_BRIDGE_MAX, tb[IFLA_AF_SPEC]);
+		if (bridge[IFLA_BRIDGE_MODE])
+			mode =*(__u16*)RTA_DATA(bridge[IFLA_BRIDGE_MODE]);
+		if (bridge[IFLA_BRIDGE_FLAGS])
+			flags =*(__u16*)RTA_DATA(bridge[IFLA_BRIDGE_FLAGS]);
+
+		fprintf(stderr, "%s: mode %s bridge_flags: %s %s\n",
+			ll_index_to_name(ifm->ifi_index),
+			mode ? "VEPA" : "VEB",
+			flags & BRIDGE_FLAGS_SELF ? "self" : "",
+			flags & BRIDGE_FLAGS_MASTER ? "master" : "");
+	}
+
+	if (tb[IFLA_PROTINFO]) {
+		__u8 state = *(__u8*)RTA_DATA(tb[IFLA_PROTINFO]);
+		char *sstate;
+
+		switch (state) {
+		case 0:
+			sstate = "DISABLED";
+			break;
+		case 1:
+			sstate = "LISTENING";
+			break;
+		case 2:
+			sstate = "LEARNING";
+			break;
+		case 3:
+			sstate = "FORWARDING";
+			break;
+		case 4:
+			sstate = "BLOCKING";
+			break;
+		default:
+			sstate = "UNKNOWN";
+			break;
+		}
+	
+
+		fprintf(stderr, "%s: %s: ifla_protinfo: %s\n",
+			ll_index_to_name(ifm->ifi_index),
+			__func__, sstate);
+	}
+
+	fflush(fp);
+	return 0;
+}
+
+static int bridge_show(int argc, char **argv)
+{
+	char *filter_dev = NULL;
+
+       
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (filter_dev)
+				duparg("dev", *argv);
+                       
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
+	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&rth, print_bridge, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+
+	return 0;
+}
+
+static int bridge_state_set(int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr		n;
+		struct ifinfomsg	ifm;
+		char			buf[1024];
+	} req;
+	struct {
+		struct nlmsghdr		hdr;
+		struct nlmsgerr		err;
+		struct nlmsghdr		rhdr;
+		struct ifinfomsg	ifm;
+		char			buf[1024];
+	} reply;
+	char *d = NULL;
+	__u8 state = 0;
+	__u16 mode = -1, flags = 0;
+	
+	memset(&req, 0, sizeof(req));
+	memset(&reply, 0, sizeof(reply));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST | NLM_F_REPLACE | NLM_F_ACK;
+	req.n.nlmsg_type = RTM_SETLINK;
+	req.ifm.ifi_family = PF_BRIDGE;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			d = *argv;	
+		} else if (matches(*argv, "state") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "DISABLED") == 0)
+				state = 0;
+			else if (matches(*argv, "LISTENING") == 0)
+				 state = 1;
+			else if (matches(*argv, "LEARNING") == 0)
+				 state = 2;
+			else if (matches(*argv, "FORWARDING") == 0)
+				 state = 3;
+			else if (matches(*argv, "BLOCKING") == 0)
+				 state = 4;
+			else
+				invarg("Invalid state value\n", *argv);
+
+		} else if (matches(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (matches(*argv, "veb") == 0)
+				mode = BRIDGE_MODE_VEB;
+			else if (matches(*argv, "vepa") == 0)
+				 mode = BRIDGE_MODE_VEPA;
+			else
+				invarg("Invalid mode value\n", *argv);
+
+		} else if (matches(*argv, "master") == 0) {
+			flags |= BRIDGE_FLAGS_MASTER;
+		} else if (matches(*argv, "self") == 0) {
+			flags |= BRIDGE_FLAGS_SELF;
+		}
+
+		argc--; argv++;
+	}
+
+	if (!d) {
+		fprintf(stderr, "Device required.\n");
+		exit(-1);
+	}
+
+       req.ifm.ifi_index = ll_name_to_index(d);
+       if (req.ifm.ifi_index == 0) {
+               fprintf(stderr, "Cannot find device \"%s\"\n", d);
+               return -1;
+       }
+
+	if (state < 4)
+		addattr8(&req.n, sizeof(req.buf), IFLA_PROTINFO, state);
+       
+	printf("%s %s(%u): type %i family %i state 0x%x ", __func__, d, req.ifm.ifi_index,
+		req.n.nlmsg_type, req.ifm.ifi_family, state);
+
+	if (mode < 3 || flags) {
+		struct rtattr *binfo;
+		int err = 0;
+
+		binfo = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+		if (flags)
+			err = addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
+		if (mode < 3)
+			err = addattr16(&req.n, sizeof(req), IFLA_BRIDGE_MODE, mode);
+		if (err < 0)
+			fprintf(stderr, "addattr16 failes\n");
+		addattr_nest_end(&req.n, binfo);
+       
+		printf("mode %s\n", mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+	}
+
+	printf("%s: %s(%u): rtnl_talk length %u\n", __func__, d, req.ifm.ifi_index, req.n.nlmsg_len);
+	if (rtnl_talk(&rth, &req.n, 0, 0, &reply.hdr) < 0) {
+		printf("\nREPLY: error %i\n", reply.err.error);
+		print_bridge(NULL, &reply.err.msg, stderr);
+		exit(2);
+	}
+
+	return 0;
+}
+
+int do_bridge(int argc, char **argv)
+{
+	ll_init_map(&rth);
+
+	if (argc > 0) {
+		if (matches(*argv, "show") == 0)
+			return bridge_show(argc-1, argv+1);
+		else if (matches(*argv, "state") == 0)
+			return bridge_state_set(argc-1, argv+1);
+		else if (matches(*argv, "help") == 0)
+			bridge_usage();
+	}
+
+	exit(0);
+}
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 012d95a..1a6c2f1 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -142,6 +142,7 @@ enum {
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
+	IFLA_BRIDGE,
 	__IFLA_MAX
 };
 
@@ -375,6 +376,21 @@ enum {
 #define PORT_UUID_MAX		16
 #define PORT_SELF_VF		-1
 
+/* Bridge Flags */
+#define BRIDGE_FLAGS_MASTER	1	/* Bridge command to/from master */
+#define BRIDGE_FLAGS_SELF	2	/* Bridge command to/from lowerdev */
+
+#define BRIDGE_MODE_VEB		0	/* Default loopback mode */
+#define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
+
+/* Bridge management nested attributes */
+enum {
+	IFLA_BRIDGE_FLAGS,
+	IFLA_BRIDGE_MODE,
+	__IFLA_BRIDGE_MAX,
+};
+#define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
+
 enum {
 	PORT_REQUEST_PREASSOCIATE = 0,
 	PORT_REQUEST_PREASSOCIATE_RR,
