From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v2 iproute2 3/3] ip link: support setting device parameters by group
Date: Tue, 11 Jan 2011 18:35:49 +0200
Message-ID: <1294763749-9997-4-git-send-email-ddvlad@rosedu.org>
References: <1294763749-9997-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60305 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932420Ab1AKQfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 11:35:54 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294763749-9997-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users can now modify basic device parameters with a single call. We use
the devgroup keyword to specify the device group to work on. For
instance, to take down all interfaces in group 1:

	ip link set down devgroup 1

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/utils.h |    3 ++-
 ip/iplink.c     |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 ip/link_veth.c  |    3 ++-
 3 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 3da6998..f9d4931 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -151,5 +151,6 @@ extern int makeargs(char *line, char *argv[], int maxargs);
 
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev);
+		char **name, char **type, char **link, char **dev,
+		int *devgroup);
 #endif /* __UTILS_H__ */
diff --git a/ip/iplink.c b/ip/iplink.c
index c0378e7..70376f9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -245,7 +245,8 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 
 
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev)
+		char **name, char **type, char **link, char **dev,
+		int *devgroup)
 {
 	int ret, len;
 	char abuf[32];
@@ -256,6 +257,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int group = -1;
 
 	ret = argc;
+	*devgroup = -1; /* Not set. */
 
 	while (argc > 0) {
 		if (strcmp(*argv, "up") == 0) {
@@ -395,6 +397,20 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
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
+				if (get_integer(devgroup, *argv, 0))
+					invarg("Invalid \"devgroup\" value\n", *argv);
+				argc--; argv++;
+				continue;
 			}
 			if (matches(*argv, "help") == 0)
 				usage();
@@ -405,6 +421,11 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		argc--; argv++;
 	}
 
+	if (*dev && (*devgroup != -1)) {
+		fprintf(stderr, "dev and devgroup cannot be both be present.\n");
+		exit(-1);
+	}
+
 	return ret - argc;
 }
 
@@ -415,6 +436,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
+	int devgroup;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
 	int ret;
@@ -426,12 +448,32 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
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
+		req.i.ifi_index = -1;
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
 
-- 
1.7.1

