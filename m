From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Make it possible to specify index on link creation
Date: Thu, 26 Dec 2013 23:15:20 +0400
Message-ID: <52BC8048.4080205@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:57334 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611Ab3LZTPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 14:15:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RTM_NEWLINK message accepts ifi_index non-zero value and lets
creation of links with given index (if it's free, or course). This
functionality is available since linux-v3.5.

This patch makes this API available via ip tool.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/utils.h b/include/utils.h
index a3e310e..a4b5b4c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -156,5 +156,5 @@ extern int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6);
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev,
-		int *group);
+		int *group, int *index);
 #endif /* __UTILS_H__ */
diff --git a/ip/iplink.c b/ip/iplink.c
index e0c14e6..343b29f 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -47,7 +47,7 @@ void iplink_usage(void)
 		fprintf(stderr, "                   [ txqueuelen PACKETS ]\n");
 		fprintf(stderr, "                   [ address LLADDR ]\n");
 		fprintf(stderr, "                   [ broadcast LLADDR ]\n");
-		fprintf(stderr, "                   [ mtu MTU ]\n");
+		fprintf(stderr, "                   [ mtu MTU ] [index IDX ]\n");
 		fprintf(stderr, "                   [ numtxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   [ numrxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
@@ -291,7 +291,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 }
 
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
-		char **name, char **type, char **link, char **dev, int *group)
+		char **name, char **type, char **link, char **dev, int *group, int *index)
 {
 	int ret, len;
 	char abuf[32];
@@ -315,6 +315,9 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
 			*name = *argv;
+		} else if (strcmp(*argv, "index") == 0) {
+			NEXT_ARG();
+			*index = atoi(*argv);
 		} else if (matches(*argv, "link") == 0) {
 			NEXT_ARG();
 			*link = *argv;
@@ -506,6 +509,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
+	int index = 0;
 	int group;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
@@ -518,7 +522,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	req.n.nlmsg_type = cmd;
 	req.i.ifi_family = preferred_family;
 
-	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev, &group);
+	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev, &group, &index);
 	if (ret < 0)
 		return ret;
 
@@ -578,6 +582,8 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			}
 			addattr_l(&req.n, sizeof(req), IFLA_LINK, &ifindex, 4);
 		}
+
+		req.i.ifi_index = index;
 	}
 
 	if (name) {
diff --git a/ip/link_veth.c b/ip/link_veth.c
index 62cb5a5..3cbeb54 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -30,6 +30,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
+	int index = 0;
 	int err, len;
 	struct rtattr * data;
 	int group;
@@ -45,7 +46,7 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	hdr->nlmsg_len += sizeof(struct ifinfomsg);
 
 	err = iplink_parse(argc - 1, argv + 1, (struct iplink_req *)hdr,
-			   &name, &type, &link, &dev, &group);
+			   &name, &type, &link, &dev, &group, &index);
 	if (err < 0)
 		return err;
 
@@ -56,6 +57,11 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(hdr, 1024, IFLA_IFNAME, name, len);
 	}
 
+	if (index) {
+		struct ifinfomsg *ifi = (struct ifinfomsg *)(data + 1);
+		ifi->ifi_index = index;
+	}
+
 	if (group != -1)
 		addattr32(hdr, 1024, IFLA_GROUP, group);
 
