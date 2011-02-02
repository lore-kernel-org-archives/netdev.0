From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v4 2/2] iproute2: support device group semantics
Date: Wed,  2 Feb 2011 20:23:41 +0200
Message-ID: <1296671021-24421-3-git-send-email-ddvlad@rosedu.org>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:48702 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754861Ab1BBSXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 13:23:45 -0500
In-Reply-To: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the group keyword to ip link set, which has the following meaning:
If both a group and a device name are pressent, we change the device's
group to the specified one. If only a group is present, then the
operation specified by the rest of the command should apply on an entire
group, not a single device.

So, to set eth0 to the default group, one would use
	ip link set dev eth0 group default

Conversely, to set all the devices in the default group down, use
	ip link set group default down

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/utils.h |    3 ++-
 ip/iplink.c     |   40 +++++++++++++++++++++++++++++++++++++---
 ip/link_veth.c  |    3 ++-
 man/man8/ip.8   |   19 +++++++++++++++++--
 4 files changed, 58 insertions(+), 7 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 3da6998..595a7d6 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -151,5 +151,6 @@ extern int makeargs(char *line, char *argv[], int maxargs);
 
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev);
+		char **name, char **type, char **link, char **dev,
+		int *group);
 #endif /* __UTILS_H__ */
diff --git a/ip/iplink.c b/ip/iplink.c
index 97a960b..8160855 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -51,7 +51,7 @@ void iplink_usage(void)
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
 		fprintf(stderr, "       ip link delete DEV type TYPE [ ARGS ]\n");
 		fprintf(stderr, "\n");
-		fprintf(stderr, "       ip link set DEVICE [ { up | down } ]\n");
+		fprintf(stderr, "       ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]\n");
 	} else
 		fprintf(stderr, "Usage: ip link set DEVICE [ { up | down } ]\n");
 
@@ -244,7 +244,7 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 
 
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev)
+		char **name, char **type, char **link, char **dev, int *group)
 {
 	int ret, len;
 	char abuf[32];
@@ -253,6 +253,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int netns = -1;
 	int vf = -1;
 
+	*group = -1;
 	ret = argc;
 
 	while (argc > 0) {
@@ -383,6 +384,12 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				  *argv, strlen(*argv));
 			argc--; argv++;
 			break;
+		} else if (strcmp(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (*group != -1)
+				duparg("group", *argv);
+			if (rtnl_group_a2n(group, *argv))
+				invarg("Invalid \"group\" value\n", *argv);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
@@ -406,6 +413,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
+	int group;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
 	int ret;
@@ -417,12 +425,38 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	req.n.nlmsg_type = cmd;
 	req.i.ifi_family = preferred_family;
 
-	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev);
+	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev, &group);
 	if (ret < 0)
 		return ret;
 
 	argc -= ret;
 	argv += ret;
+
+	if (group != -1) {
+		if (dev)
+			addattr_l(&req.n, sizeof(req), IFLA_GROUP,
+					&group, sizeof(group));
+		else {
+			if (argc) {
+				fprintf(stderr, "Garbage instead of arguments "
+						"\"%s ...\". Try \"ip link "
+						"help\".\n", *argv);
+				return -1;
+			}
+			if (flags & NLM_F_CREATE) {
+				fprintf(stderr, "group cannot be used when "
+						"creating devices.\n");
+				return -1;
+			}
+
+			req.i.ifi_index = 0;
+			addattr32(&req.n, sizeof(req), IFLA_GROUP, group);
+			if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+				exit(2);
+			return 0;
+		}
+	}
+
 	ll_init_map(&rth);
 
 	if (type) {
diff --git a/ip/link_veth.c b/ip/link_veth.c
index 9f5e871..3d19b01 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -30,6 +30,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	char *name, *type, *link, *dev;
 	int err, len;
 	struct rtattr * data;
+	int group;
 
 	if (strcmp(argv[0], "peer") != 0) {
 		usage();
@@ -42,7 +43,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	hdr->nlmsg_len += sizeof(struct ifinfomsg);
 
 	err = iplink_parse(argc - 1, argv + 1, (struct iplink_req *)hdr,
-			   &name, &type, &link, &dev);
+			   &name, &type, &link, &dev, &group);
 	if (err < 0)
 		return err;
 
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 730788a..8f82842 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -55,8 +55,10 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .RI "[ " ARGS " ]"
 
 .ti -8
-.BI "ip link set " DEVICE
-.RB "{ " up " | " down " | " arp " { " on " | " off " } |"
+.BR "ip link set " {
+.IR DEVICE " | "
+.BI "group " GROUP
+.RB "} { " up " | " down " | " arp " { " on " | " off " } |"
 .br
 .BR promisc " { " on " | " off " } |"
 .br
@@ -930,6 +932,13 @@ specifies network device to operate on. When configuring SR-IOV Virtual Fuction
 device.
 
 .TP
+.BI group " GROUP "
+.I GROUP
+has a dual role: If both group and dev are present, then move the device to the
+specified group.  If only a group is specified, then the command operates on
+all devices in that group.
+
+.TP
 .BR up " and " down
 change the state of the device to
 .B UP
@@ -996,6 +1005,12 @@ move the device to the network namespace associated with the process
 give the device a symbolic name for easy reference.
 
 .TP
+.BI group " GROUP"
+specify the group the device belongs to.
+The available groups are listed in file
+.BR "/etc/iproute2/group" .
+
+.TP
 .BI vf " NUM"
 specify a Virtual Function device to be configured. The associated PF device
 must be specified using the
-- 
1.7.1

