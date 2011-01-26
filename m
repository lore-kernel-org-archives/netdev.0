From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 1/3] iproute2: add support for setting device groups
Date: Wed, 26 Jan 2011 18:41:24 +0200
Message-ID: <1296060086-18777-2-git-send-email-ddvlad@rosedu.org>
References: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:43645 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752993Ab1AZQla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 11:41:30 -0500
In-Reply-To: <1296060086-18777-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the group keyword to specify what group the device should belong to.
Since the kernel uses numbers internally, mapping of group names to
numbers is defined in /etc/iproute2/group_map. Example usage:

  ip link set dev eth0 group default

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 etc/iproute2/group_map  |    2 ++
 include/linux/if_link.h |    1 +
 include/utils.h         |    2 ++
 ip/ip_common.h          |    2 ++
 ip/iplink.c             |    9 +++++++++
 lib/utils.c             |   41 +++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8           |    9 +++++++++
 tc/m_ematch.c           |   39 ---------------------------------------
 8 files changed, 66 insertions(+), 39 deletions(-)
 create mode 100644 etc/iproute2/group_map

diff --git a/etc/iproute2/group_map b/etc/iproute2/group_map
new file mode 100644
index 0000000..6f000b2
--- /dev/null
+++ b/etc/iproute2/group_map
@@ -0,0 +1,2 @@
+# device group names
+0	default
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e87456c..54d05f9 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -135,6 +135,7 @@ enum {
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
+	IFLA_GROUP,
 	__IFLA_MAX
 };
 
diff --git a/include/utils.h b/include/utils.h
index 3da6998..327373e 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -152,4 +152,6 @@ extern int makeargs(char *line, char *argv[], int maxargs);
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev);
+
+int lookup_map_id(const char *kind, int *dst, const char *file);
 #endif /* __UTILS_H__ */
diff --git a/ip/ip_common.h b/ip/ip_common.h
index a114186..b751d46 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -68,3 +68,5 @@ struct link_util *get_link_kind(const char *kind);
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
 #endif
+
+#define GROUP_MAP "/etc/iproute2/group_map"
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..6c9df43 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -68,6 +68,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
+	fprintf(stderr, "			  [ group GROUP ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
@@ -252,6 +253,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int mtu = -1;
 	int netns = -1;
 	int vf = -1;
+	int group = -1;
 
 	ret = argc;
 
@@ -297,6 +299,13 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
+		} else if (strcmp(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (group != -1)
+				duparg("group", *argv);
+			if (lookup_map_id(*argv, &group, GROUP_MAP))
+				invarg("Invalid \"group\" value\n", *argv);
+			addattr_l(&req->n, sizeof(*req), IFLA_GROUP, &group, 4);
                 } else if (strcmp(*argv, "netns") == 0) {
                         NEXT_ARG();
                         if (netns != -1)
diff --git a/lib/utils.c b/lib/utils.c
index a60d884..3642cb7 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -25,6 +25,7 @@
 #include <linux/pkt_sched.h>
 #include <time.h>
 #include <sys/time.h>
+#include <errno.h>
 
 
 #include "utils.h"
@@ -760,3 +761,43 @@ int makeargs(char *line, char *argv[], int maxargs)
 
 	return argc;
 }
+
+int lookup_map_id(const char *kind, int *dst, const char *file)
+{
+	int err = -EINVAL;
+	char buf[512];
+	FILE *fd = fopen(file, "r");
+
+	if (fd == NULL) {
+		fprintf(stderr, "open %s: %s\n", file, strerror(errno));
+		return -errno;
+	}
+
+	while (fgets(buf, sizeof(buf), fd)) {
+		char namebuf[512], *p = buf;
+		int id;
+
+		while (*p == ' ' || *p == '\t')
+			p++;
+		if (*p == '#' || *p == '\n' || *p == 0)
+			continue;
+
+		if (sscanf(p, "%d %s", &id, namebuf) != 2) {
+			fprintf(stderr, "map %s corrupted at %s\n",
+			    file, p);
+			goto out;
+		}
+
+		if (!strcasecmp(namebuf, kind)) {
+			if (dst)
+				*dst = id;
+			err = 0;
+			goto out;
+		}
+	}
+
+	err = -ENOENT;
+out:
+	fclose(fd);
+	return err;
+}
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8d55fa9..77e03d8 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -86,6 +86,9 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .B alias
 .IR NAME  " |"
 .br
+.B  group
+.IR GROUP " |"
+.br
 .B vf
 .IR NUM " ["
 .B  mac
@@ -994,6 +997,12 @@ move the device to the network namespace associated with the process
 give the device a symbolic name for easy reference.
 
 .TP
+.BI group " GROUP"
+specify the group the device belongs to.
+The available groups are listed in file
+.BR "/etc/iproute2/group_map" .
+
+.TP
 .BI vf " NUM"
 specify a Virtual Function device to be configured. The associated PF device
 must be specified using the
diff --git a/tc/m_ematch.c b/tc/m_ematch.c
index 4c3acf8..4a6855c 100644
--- a/tc/m_ematch.c
+++ b/tc/m_ematch.c
@@ -87,45 +87,6 @@ out:
 	return err;
 }
 
-static int lookup_map_id(char *kind, int *dst, const char *file)
-{
-	int err = -EINVAL;
-	char buf[512];
-	FILE *fd = fopen(file, "r");
-
-	if (fd == NULL)
-		return -errno;
-
-	while (fgets(buf, sizeof(buf), fd)) {
-		char namebuf[512], *p = buf;
-		int id;
-
-		while (*p == ' ' || *p == '\t')
-			p++;
-		if (*p == '#' || *p == '\n' || *p == 0)
-			continue;
-
-		if (sscanf(p, "%d %s", &id, namebuf) != 2) {
-			fprintf(stderr, "ematch map %s corrupted at %s\n",
-			    file, p);
-			goto out;
-		}
-
-		if (!strcasecmp(namebuf, kind)) {
-			if (dst)
-				*dst = id;
-			err = 0;
-			goto out;
-		}
-	}
-
-	err = -ENOENT;
-	*dst = 0;
-out:
-	fclose(fd);
-	return err;
-}
-
 static struct ematch_util *get_ematch_kind(char *kind)
 {
 	static void *body;
-- 
1.7.1

