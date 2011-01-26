From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 3/3] iproute2: support setting device parameters by group
Date: Wed, 26 Jan 2011 18:41:26 +0200
Message-ID: <1296060086-18777-4-git-send-email-ddvlad@rosedu.org>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:43650 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753108Ab1AZQla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 11:41:30 -0500
In-Reply-To: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users can now modify basic device parameters with a single call. We use
the devgroup keyword to specify the device group to work on. For
instance, to take down all interfaces in group `default':

	ip link set down devgroup default

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/utils.h |    3 ++-
 ip/iplink.c     |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 ip/link_veth.c  |    3 ++-
 man/man8/ip.8   |   11 +++++++++--
 4 files changed, 58 insertions(+), 7 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 327373e..c708b74 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -151,7 +151,8 @@ extern int makeargs(char *line, char *argv[], int maxargs);
 
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev);
+		char **name, char **type, char **link, char **dev,
+		int *devgroup);
 
 int lookup_map_id(const char *kind, int *dst, const char *file);
 #endif /* __UTILS_H__ */
diff --git a/ip/iplink.c b/ip/iplink.c
index a781848..85d2efa 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -51,7 +51,7 @@ void iplink_usage(void)
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
 		fprintf(stderr, "       ip link delete DEV type TYPE [ ARGS ]\n");
 		fprintf(stderr, "\n");
-		fprintf(stderr, "       ip link set DEVICE [ { up | down } ]\n");
+		fprintf(stderr, "       ip link set { dev DEVICE | devgroup DEVGROUP } [ { up | down } ]\n");
 	} else
 		fprintf(stderr, "Usage: ip link set DEVICE [ { up | down } ]\n");
 
@@ -246,7 +246,8 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 
 
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev)
+		char **name, char **type, char **link, char **dev,
+		int *devgroup)
 {
 	int ret, len;
 	char abuf[32];
@@ -257,6 +258,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int group = -1;
 
 	ret = argc;
+	*devgroup = -1; /* Not set. */
 
 	while (argc > 0) {
 		if (strcmp(*argv, "up") == 0) {
@@ -396,6 +398,20 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
+				if (*dev)
+					duparg2("dev", *argv);
+				*dev = *argv;
+				argc--; argv++;
+				continue;
+			}
+			if (matches(*argv, "devgroup") == 0) {
+				NEXT_ARG();
+				if (*devgroup != -1)
+					duparg("devgroup", *argv);
+				if (lookup_map_id(*argv, devgroup, GROUP_MAP))
+					invarg("Invalid \"devgroup\" value\n", *argv);
+				argc--; argv++;
+				continue;
 			}
 			if (matches(*argv, "help") == 0)
 				usage();
@@ -406,6 +422,11 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		argc--; argv++;
 	}
 
+	if (*dev && (*devgroup != -1)) {
+		fprintf(stderr, "dev and devgroup cannot be both be present.\n");
+		exit(-1);
+	}
+
 	return ret - argc;
 }
 
@@ -416,6 +437,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
+	int devgroup;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
 	int ret;
@@ -427,12 +449,32 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	req.n.nlmsg_type = cmd;
 	req.i.ifi_family = preferred_family;
 
-	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev);
+	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev, &devgroup);
 	if (ret < 0)
 		return ret;
 
 	argc -= ret;
 	argv += ret;
+
+	if (devgroup != -1) {
+		if (argc) {
+			fprintf(stderr, "Garbage instead of arguments \"%s ...\". "
+					"Try \"ip link help\".\n", *argv);
+			return -1;
+		}
+		if (flags & NLM_F_CREATE) {
+			fprintf(stderr, "devgroup cannot be used when "
+					"creating devices.\n");
+			return -1;
+		}
+
+		req.i.ifi_index = 0;
+		addattr32(&req.n, sizeof(req), IFLA_GROUP, devgroup);
+		if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+			exit(2);
+		return 0;
+	}
+
 	ll_init_map(&rth);
 
 	if (type) {
diff --git a/ip/link_veth.c b/ip/link_veth.c
index 9f5e871..06974e7 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -30,6 +30,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	char *name, *type, *link, *dev;
 	int err, len;
 	struct rtattr * data;
+	int devgroup;
 
 	if (strcmp(argv[0], "peer") != 0) {
 		usage();
@@ -42,7 +43,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	hdr->nlmsg_len += sizeof(struct ifinfomsg);
 
 	err = iplink_parse(argc - 1, argv + 1, (struct iplink_req *)hdr,
-			   &name, &type, &link, &dev);
+			   &name, &type, &link, &dev, &devgroup);
 	if (err < 0)
 		return err;
 
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 5c42156..302523a 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -55,8 +55,10 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .RI "[ " ARGS " ]"
 
 .ti -8
-.BI "ip link set " DEVICE
-.RB "{ " up " | " down " | " arp " { " on " | " off " } |"
+.BR "ip link set " {
+.IR DEVICE " | "
+.BI "devgroup " DEVGROUP
+.RB "} { " up " | " down " | " arp " { " on " | " off " } |"
 .br
 .BR promisc " { " on " | " off " } |"
 .br
@@ -933,6 +935,11 @@ specifies network device to operate on. When configuring SR-IOV Virtual Fuction
 device.
 
 .TP
+.BI devgroup " DEVGROUP "
+.I DEVGROUP
+specifies network device group to operate on.
+
+.TP
 .BR up " and " down
 change the state of the device to
 .B UP
-- 
1.7.1

