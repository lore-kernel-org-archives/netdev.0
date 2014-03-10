From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC iproute2] bridge: Add 802.1ad vlan support
Date: Mon, 10 Mar 2014 17:11:07 +0900
Message-ID: <1394439067-10477-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:35229 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbaCJILW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 04:11:22 -0400
In-Reply-To: <1394439067-10477-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sample configuration:
  # ip link add br0 type bridge
  # ip link set eth0 master br0
  # ip link set vnet0 master br0
  # bridge vlan set protocol 802.1ad dev br0
  # bridge vlan add vid 10 dev vnet0 pvid untagged
  # bridge vlan add vid 10 dev eth0
  # ip link set br0 up

Now eth0 can communicate with VM behind vnet0 using 802.1ad tag with vid 10.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 bridge/vlan.c             | 156 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_bridge.h |   2 +
 2 files changed, 146 insertions(+), 12 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 83c4088..4b36d8f 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -12,6 +12,7 @@
 #include "libnetlink.h"
 #include "br_common.h"
 #include "utils.h"
+#include "rt_names.h"
 
 int filter_index;
 
@@ -19,7 +20,10 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
-	fprintf(stderr, "       bridge vlan { show } [ dev DEV ]\n");
+	fprintf(stderr, "       bridge vlan set protocol VLANPROTO dev DEV\n");
+	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ protocol ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "VLANPROTO: { 802.1Q / 802.1ad }\n");
 	exit(-1);
 }
 
@@ -101,6 +105,64 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	return 0;
 }
 
+static int vlan_set(int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr		n;
+		struct ifinfomsg	ifm;
+		char			buf[1024];
+	} req;
+	char *d = NULL;
+	struct rtattr *afspec;
+	__u16 proto = 0;
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
+		} else if (strcmp(*argv, "protocol") == 0) {
+			NEXT_ARG();
+			if (ll_proto_a2n(&proto, *argv))
+				invarg("protocol is invalid", *argv);
+		} else {
+			if (matches(*argv, "help") == 0)
+				NEXT_ARG();
+		}
+		argc--; argv++;
+	}
+
+	if (d == NULL || !proto) {
+		fprintf(stderr, "Device and protocol are required arguments.\n");
+		return -1;
+	}
+
+	req.ifm.ifi_index = ll_name_to_index(d);
+	if (req.ifm.ifi_index == 0) {
+		fprintf(stderr, "Cannot find bridge device \"%s\"\n", d);
+		return -1;
+	}
+
+	afspec = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+
+	addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, BRIDGE_FLAGS_SELF);
+
+	addattr16(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_PROTOCOL, proto);
+
+	addattr_nest_end(&req.n, afspec);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
 static int print_vlan(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n,
 		      void *arg)
@@ -109,6 +171,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[IFLA_MAX+1];
+	int found = 0;
 
 	if (n->nlmsg_type != RTM_NEWLINK) {
 		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
@@ -130,21 +193,21 @@ static int print_vlan(const struct sockaddr_nl *who,
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifm), len);
 
-	/* if AF_SPEC isn't there, vlan table is not preset for this port */
-	if (!tb[IFLA_AF_SPEC]) {
-		fprintf(fp, "%s\tNone\n", ll_index_to_name(ifm->ifi_index));
-		return 0;
-	} else {
+	if (tb[IFLA_AF_SPEC]) {
 		struct rtattr *i, *list = tb[IFLA_AF_SPEC];
 		int rem = RTA_PAYLOAD(list);
 
-		fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
 		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 			struct bridge_vlan_info *vinfo;
 
 			if (i->rta_type != IFLA_BRIDGE_VLAN_INFO)
 				continue;
 
+			if (!found) {
+				fprintf(fp, "%s",
+					ll_index_to_name(ifm->ifi_index));
+				found = 1;
+			}
 			vinfo = RTA_DATA(i);
 			fprintf(fp, "\t %hu", vinfo->vid);
 			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
@@ -154,7 +217,63 @@ static int print_vlan(const struct sockaddr_nl *who,
 			fprintf(fp, "\n");
 		}
 	}
-	fprintf(fp, "\n");
+
+	/* if IFLA_BRIDGE_VLAN_INFO isn't there, vlan table is not preset for
+	 * this port.
+	 */
+	if (!found)
+		fprintf(fp, "%s\tNone\n", ll_index_to_name(ifm->ifi_index));
+
+	fflush(fp);
+	return 0;
+}
+
+static int print_vlan_proto(const struct sockaddr_nl *who,
+			    struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	struct ifinfomsg *ifm = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr *tb[IFLA_MAX+1];
+
+	if (n->nlmsg_type != RTM_NEWLINK) {
+		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
+	}
+
+	len -= NLMSG_LENGTH(sizeof(*ifm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (ifm->ifi_family != AF_BRIDGE)
+		return 0;
+
+	if (filter_index && filter_index != ifm->ifi_index)
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifm), len);
+
+	if (tb[IFLA_AF_SPEC]) {
+		struct rtattr *i, *list = tb[IFLA_AF_SPEC];
+		int rem = RTA_PAYLOAD(list);
+
+		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			SPRINT_BUF(b1);
+
+			if (i->rta_type != IFLA_BRIDGE_VLAN_PROTOCOL)
+				continue;
+
+			fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
+			fprintf(fp, "\t%s",
+				ll_proto_n2a(rta_getattr_u16(i), b1, sizeof(b1)));
+			fprintf(fp, "\n");
+			break;
+		}
+	}
+
 	fflush(fp);
 	return 0;
 }
@@ -162,6 +281,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 static int vlan_show(int argc, char **argv)
 {
 	char *filter_dev = NULL;
+	int proto = 0;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -170,6 +290,8 @@ static int vlan_show(int argc, char **argv)
 				duparg("dev", *argv);
 			filter_dev = *argv;
 		}
+		if (strcmp(*argv, "protocol") == 0)
+			proto = 1;
 		argc--; argv++;
 	}
 
@@ -187,10 +309,18 @@ static int vlan_show(int argc, char **argv)
 		exit(1);
 	}
 
-	printf("port\tvlan ids\n");
-	if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
-		fprintf(stderr, "Dump ternminated\n");
-		exit(1);
+	if (proto) {
+		printf("port\tprotocol\n");
+		if (rtnl_dump_filter(&rth, print_vlan_proto, stdout) < 0) {
+			fprintf(stderr, "Dump terminatied\n");
+			exit(1);
+		}
+	} else {
+		printf("port\tvlan ids\n");
+		if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
+			fprintf(stderr, "Dump ternminated\n");
+			exit(1);
+		}
 	}
 
 	return 0;
@@ -206,6 +336,8 @@ int do_vlan(int argc, char **argv)
 			return vlan_modify(RTM_SETLINK, argc-1, argv+1);
 		if (matches(*argv, "delete") == 0)
 			return vlan_modify(RTM_DELLINK, argc-1, argv+1);
+		if (matches(*argv, "set") == 0)
+			return vlan_set(argc-1, argv+1);
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index d2de4e6..44ed163 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -110,12 +110,14 @@ struct __fdb_entry {
  *     [IFLA_BRIDGE_FLAGS]
  *     [IFLA_BRIDGE_MODE]
  *     [IFLA_BRIDGE_VLAN_INFO]
+ *     [IFLA_BRIDGE_VLAN_PROTOCOL]
  * }
  */
 enum {
 	IFLA_BRIDGE_FLAGS,
 	IFLA_BRIDGE_MODE,
 	IFLA_BRIDGE_VLAN_INFO,
+	IFLA_BRIDGE_VLAN_PROTOCOL,
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
-- 
1.8.1.2
