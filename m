From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC iproute v1 2/4] afnetns: support for ipv4/v6 address management
Date: Mon, 13 Mar 2017 00:01:36 +0100
Message-ID: <20170312230138.5096-3-hannes@stressinduktion.org>
References: <20170312230138.5096-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:54682 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935545AbdCLXBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:51 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id E334C2067F
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:44 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id EDC64240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:43 -0400 (EDT)
In-Reply-To: <20170312230138.5096-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support ip address add xxx.yyy.zzz.lll/kk dev eth0 afnetns <afnetns-name>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/libnetlink.h    |  7 +++++++
 include/linux/if_addr.h |  2 ++
 include/namespace.h     |  2 ++
 ip/ipaddress.c          | 32 ++++++++++++++++++++++++++++++++
 ip/ipafnetns.c          | 26 +++++++-------------------
 lib/namespace.c         | 21 +++++++++++++++++++++
 6 files changed, 71 insertions(+), 19 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index bd0267dfcc02ad..81ba0d3a032360 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -152,10 +152,17 @@ static inline __u32 rta_getattr_u32(const struct rtattr *rta)
 {
 	return *(__u32 *)RTA_DATA(rta);
 }
+
+static inline __s32 rta_getattr_s32(const struct rtattr *rta)
+{
+	return *(__s32 *)RTA_DATA(rta);
+}
+
 static inline __be32 rta_getattr_be32(const struct rtattr *rta)
 {
 	return ntohl(rta_getattr_u32(rta));
 }
+
 static inline __u64 rta_getattr_u64(const struct rtattr *rta)
 {
 	__u64 tmp;
diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 26f0ecff9f13dd..dea1abe593ab29 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -32,6 +32,8 @@ enum {
 	IFA_CACHEINFO,
 	IFA_MULTICAST,
 	IFA_FLAGS,
+	IFA_AFNETNS_FD,
+	IFA_AFNETNS_INODE,
 	__IFA_MAX,
 };
 
diff --git a/include/namespace.h b/include/namespace.h
index acecc8c1f0d2b8..e0745ab0b50972 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -52,6 +52,8 @@ int netns_switch(char *netns);
 int netns_get_fd(const char *netns);
 int netns_foreach(int (*func)(char *nsname, void *arg), void *arg);
 
+int afnetns_open(const char *name);
+
 struct netns_func {
 	int (*func)(char *nsname, void *arg);
 	void *arg;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8d9c7d917fe8d..2994b6a3e0a154 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -37,6 +37,7 @@
 #include "ip_common.h"
 #include "xdp.h"
 #include "color.h"
+#include "namespace.h"
 
 enum {
 	IPADD_LIST,
@@ -999,6 +1000,18 @@ static int set_lifetime(unsigned int *lifetime, char *argv)
 	return 0;
 }
 
+static int afnetns_get_fd(const char *name)
+{
+	int ns = -1;
+
+	if (name[0] == '/')
+		ns = open(name, O_RDONLY | O_CLOEXEC);
+	else
+		ns = afnetns_open(name);
+
+	return ns;
+}
+
 static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
 				  struct rtattr *ifa_flags_attr)
 {
@@ -1205,6 +1218,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				fprintf(fp, "%usec", ci->ifa_prefered);
 		}
 	}
+	if (rta_tb[IFA_AFNETNS_INODE]) {
+		fprintf(fp, " afnet:[%u]",
+			rta_getattr_u32(rta_tb[IFA_AFNETNS_INODE]));
+	}
 	fprintf(fp, "\n");
 brief_exit:
 	fflush(fp);
@@ -1883,6 +1900,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	int brd_len = 0;
 	int any_len = 0;
 	int scoped = 0;
+	int afnetns_fd = -1;
 	__u32 preferred_lft = INFINITY_LIFE_TIME;
 	__u32 valid_lft = INFINITY_LIFE_TIME;
 	unsigned int ifa_flags = 0;
@@ -1958,6 +1976,14 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			preferred_lftp = *argv;
 			if (set_lifetime(&preferred_lft, *argv))
 				invarg("preferred_lft value", *argv);
+		} else if (strcmp(*argv, "afnetns") == 0) {
+			if (afnetns_fd != -1)
+				duparg("afnetns", *argv);
+
+			NEXT_ARG();
+			afnetns_fd = afnetns_get_fd(*argv);
+			if (afnetns_fd < 0)
+				invarg("afnetns", *argv);
 		} else if (strcmp(*argv, "home") == 0) {
 			ifa_flags |= IFA_F_HOMEADDRESS;
 		} else if (strcmp(*argv, "nodad") == 0) {
@@ -2064,9 +2090,15 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		return -1;
 	}
 
+	if (afnetns_fd != -1)
+		addattr32(&req.n, sizeof(req), IFA_AFNETNS_FD, afnetns_fd);
+
 	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 		return -2;
 
+	if (afnetns_fd > 0)
+		close(afnetns_fd);
+
 	return 0;
 }
 
diff --git a/ip/ipafnetns.c b/ip/ipafnetns.c
index 5b7a7e59bc947a..5a197ad3866d18 100644
--- a/ip/ipafnetns.c
+++ b/ip/ipafnetns.c
@@ -148,37 +148,25 @@ out_delete:
 static int afnetns_switch(const char *name)
 {
 	int err, ns;
-	char *path;
 
-	err = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
-	if (err < 0) {
-		perror("asprintf");
-		return err;
-	};
-
-	ns = open(path, O_RDONLY | O_CLOEXEC);
-	if (ns < 0) {
-		fprintf(stderr, "Cannot open afnet namespace \"%s\": %s\n",
-			name, strerror(errno));
-		err = ns;
-		goto out;
-	}
+	ns = afnetns_open(name);
+	if (ns < 0)
+		return ns;
 
 	err = setns(ns, CLONE_NEWAFNET);
 	if (err) {
 		fprintf(stderr, "setting the afnet namespace \"%s\" failed: %s\n",
 			name, strerror(errno));
-		goto out;
+		return err;
 	}
+
 	err = close(ns);
 	if (err) {
 		perror("close");
-		goto out;
+		return err;
 	}
 
-out:
-	free(path);
-	return err;
+	return 0;
 }
 
 static int afnetns_exec(int argc, char **argv)
diff --git a/lib/namespace.c b/lib/namespace.c
index 30b513889e6e24..f20e5b6ef5a3ef 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -124,3 +124,24 @@ int netns_foreach(int (*func)(char *nsname, void *arg), void *arg)
 	closedir(dir);
 	return 0;
 }
+
+int afnetns_open(const char *name)
+{
+	int ns;
+	char *path;
+
+	ns = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
+	if (ns < 0) {
+		perror("asprintf");
+		return ns;
+	};
+
+	ns = open(path, O_RDONLY | O_CLOEXEC);
+	if (ns < 0) {
+		fprintf(stderr, "Cannot open afnet namespace \"%s\": %s\n",
+			name, strerror(errno));
+	}
+
+	free(path);
+	return ns;
+}
-- 
2.9.3
