From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 iproute2 2/3] bridge: Add vlan configuration support
Date: Thu, 28 Feb 2013 15:04:05 -0500
Message-ID: <1362081846-25268-3-git-send-email-vyasevic@redhat.com>
References: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906Ab3B1UEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 15:04:12 -0500
In-Reply-To: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent kernel patches added support for VLAN filtering on the bridge.
This functionality allows one to turn a basic bridge into a VLAN bridge,
where VLANs dicatate packet forwarding and header transformation.

To configure the VLANs on the bridge and its ports a new command is
added to the 'bridge' utility.

   # bridge vlan add dev eth0 vid 10 pvid untagged brdev
   # bridge vlan add
   # bridge vlan delete dev eth0 vid 10
   # bridge vlan show

This command supports the following flags:
   master - peform the operation on the software bridge device.  This is
	    the default behavior.
   self  -  perform the operation on the hardware associated with the port.
            This flag is required when the device is the bridge device and
	    the configuration is desired on the bridge device itself (not
	    one of the ports).
   pvid  -  Set the PVID (port vlan id) for a given port.  Any untagged
            frames arriving on the port will be assigned to this vlan.
   untagged - Sets the egress policy of for a given vlan.  Default port
            egress policy is tagged.  Set this flag if you wish traffic
            associated with this VLAN to exit the port untagged.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 bridge/Makefile      |    2 +-
 bridge/br_common.h   |    1 +
 bridge/bridge.c      |    3 +-
 bridge/vlan.c        |  220 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/libnetlink.h |    2 +
 lib/libnetlink.c     |    8 ++-
 6 files changed, 233 insertions(+), 3 deletions(-)
 create mode 100644 bridge/vlan.c

diff --git a/bridge/Makefile b/bridge/Makefile
index 67aceb4..1fb8320 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -1,4 +1,4 @@
-BROBJ = bridge.o fdb.o monitor.o link.o mdb.o
+BROBJ = bridge.o fdb.o monitor.o link.o mdb.o vlan.o
 
 include ../Config
 
diff --git a/bridge/br_common.h b/bridge/br_common.h
index 10f6ce9..8764563 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -9,6 +9,7 @@ extern int print_mdb(const struct sockaddr_nl *who,
 extern int do_fdb(int argc, char **argv);
 extern int do_mdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
+extern int do_vlan(int argc, char **argv);
 
 extern int preferred_family;
 extern int show_stats;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index 1d59a1e..06b7a54 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -27,7 +27,7 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
-"where  OBJECT := { fdb |  mdb | monitor }\n"
+"where  OBJECT := { fdb | mdb | vlan | monitor }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails]\n" );
 	exit(-1);
 }
@@ -44,6 +44,7 @@ static const struct cmd {
 } cmds[] = {
 	{ "fdb", 	do_fdb },
 	{ "mdb", 	do_mdb },
+	{ "vlan",	do_vlan },
 	{ "monitor",	do_monitor },
 	{ "help",	do_help },
 	{ 0 }
diff --git a/bridge/vlan.c b/bridge/vlan.c
new file mode 100644
index 0000000..83c4088
--- /dev/null
+++ b/bridge/vlan.c
@@ -0,0 +1,220 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/if_bridge.h>
+#include <linux/if_ether.h>
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
+	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
+	fprintf(stderr, "                                                     [ self ] [ master ]\n");
+	fprintf(stderr, "       bridge vlan { show } [ dev DEV ]\n");
+	exit(-1);
+}
+
+static int vlan_modify(int cmd, int argc, char **argv)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct ifinfomsg 	ifm;
+		char   			buf[1024];
+	} req;
+	char *d = NULL;
+	short vid = -1;
+	struct rtattr *afspec;
+	struct bridge_vlan_info vinfo;
+	unsigned short flags = 0;
+
+	memset(&vinfo, 0, sizeof(vinfo));
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = cmd;
+	req.ifm.ifi_family = PF_BRIDGE;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			d = *argv;
+		} else if (strcmp(*argv, "vid") == 0) {
+			NEXT_ARG();
+			vid = atoi(*argv);
+		} else if (strcmp(*argv, "self") == 0) {
+			flags |= BRIDGE_FLAGS_SELF;
+		} else if (strcmp(*argv, "master") == 0) {
+			flags |= BRIDGE_FLAGS_MASTER;
+		} else if (strcmp(*argv, "pvid") == 0) {
+			vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+		} else if (strcmp(*argv, "untagged") == 0) {
+			vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		} else {
+			if (matches(*argv, "help") == 0) {
+				NEXT_ARG();
+			}
+		}
+		argc--; argv++;
+	}
+
+	if (d == NULL || vid == -1) {
+		fprintf(stderr, "Device and VLAN ID are required arguments.\n");
+		exit(-1);
+	}
+
+	req.ifm.ifi_index = ll_name_to_index(d);
+	if (req.ifm.ifi_index == 0) {
+		fprintf(stderr, "Cannot find bridge device \"%s\"\n", d);
+		return -1;
+	}
+
+	if (vid >= 4096) {
+		fprintf(stderr, "Invalid VLAN ID \"%hu\"\n", vid);
+		return -1;
+	}
+
+	vinfo.vid = vid;
+
+	afspec = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
+
+	if (flags)
+		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
+
+	addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
+		  sizeof(vinfo));
+
+	addattr_nest_end(&req.n, afspec);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
+static int print_vlan(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n,
+		      void *arg)
+{
+	FILE *fp = arg;
+	struct ifinfomsg *ifm = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[IFLA_MAX+1];
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
+	/* if AF_SPEC isn't there, vlan table is not preset for this port */
+	if (!tb[IFLA_AF_SPEC]) {
+		fprintf(fp, "%s\tNone\n", ll_index_to_name(ifm->ifi_index));
+		return 0;
+	} else {
+		struct rtattr *i, *list = tb[IFLA_AF_SPEC];
+		int rem = RTA_PAYLOAD(list);
+
+		fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
+		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			struct bridge_vlan_info *vinfo;
+
+			if (i->rta_type != IFLA_BRIDGE_VLAN_INFO)
+				continue;
+
+			vinfo = RTA_DATA(i);
+			fprintf(fp, "\t %hu", vinfo->vid);
+			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
+				fprintf(fp, " PVID");
+			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
+				fprintf(fp, " Egress Untagged");
+			fprintf(fp, "\n");
+		}
+	}
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
+static int vlan_show(int argc, char **argv)
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
+			fprintf(stderr, "Cannot find device \"%s\"\n",
+			       filter_dev);
+			return -1;
+		}
+	}
+
+	if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
+				     RTEXT_FILTER_BRVLAN) < 0) {
+		perror("Cannont send dump request");
+		exit(1);
+	}
+
+	printf("port\tvlan ids\n");
+	if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
+		fprintf(stderr, "Dump ternminated\n");
+		exit(1);
+	}
+
+	return 0;
+}
+
+
+int do_vlan(int argc, char **argv)
+{
+	ll_init_map(&rth);
+
+	if (argc > 0) {
+		if (matches(*argv, "add") == 0)
+			return vlan_modify(RTM_SETLINK, argc-1, argv+1);
+		if (matches(*argv, "delete") == 0)
+			return vlan_modify(RTM_DELLINK, argc-1, argv+1);
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
+			return vlan_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return vlan_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
+	exit(-1);
+}
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 41e6ed1..8d15ee5 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -26,6 +26,8 @@ extern int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions);
 extern int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions, int protocol);
 extern void rtnl_close(struct rtnl_handle *rth);
 extern int rtnl_wilddump_request(struct rtnl_handle *rth, int fam, int type);
+extern int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int fam, int type,
+				    __u32 filt_mask);
 extern int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len);
 
 typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 09b4277..67f046f 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -91,6 +91,12 @@ int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions)
 
 int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 {
+	return rtnl_wilddump_req_filter(rth, family, type, RTEXT_FILTER_VF);
+}
+
+int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
+			    __u32 filt_mask)
+{
 	struct {
 		struct nlmsghdr nlh;
 		struct rtgenmsg g;
@@ -109,7 +115,7 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 
 	req.ext_req.rta_type = IFLA_EXT_MASK;
 	req.ext_req.rta_len = RTA_LENGTH(sizeof(__u32));
-	req.ext_filter_mask = RTEXT_FILTER_VF;
+	req.ext_filter_mask = filt_mask;
 
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
-- 
1.7.7.6
