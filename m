From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC iproute v1 3/4] afnetns: introduce lib/afnetns.c and a name cache
Date: Mon, 13 Mar 2017 00:01:37 +0100
Message-ID: <20170312230138.5096-4-hannes@stressinduktion.org>
References: <20170312230138.5096-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47078 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935422AbdCLXBr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:47 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id BAB2D20682
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:45 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 084A7240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:44 -0400 (EDT)
In-Reply-To: <20170312230138.5096-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a name cache for afnetns, so we don't need to scan the
inodes all the same again. This speeds up address list in case of many
configured afnetns and ip addresses.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/afnetns.h   |   6 ++
 include/namespace.h |   3 -
 ip/ipaddress.c      |  12 ++-
 ip/ipafnetns.c      |   1 +
 lib/Makefile        |   2 +-
 lib/afnetns.c       | 226 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/namespace.c     |  21 -----
 7 files changed, 243 insertions(+), 28 deletions(-)
 create mode 100644 include/afnetns.h
 create mode 100644 lib/afnetns.c

diff --git a/include/afnetns.h b/include/afnetns.h
new file mode 100644
index 00000000000000..287bcb6153611b
--- /dev/null
+++ b/include/afnetns.h
@@ -0,0 +1,6 @@
+#pragma once
+
+#define AFNETNS_RUN_DIR "/var/run/afnetns"
+
+int afnetns_open(const char *name);
+char *afnetns_lookup_name(ino_t inode);
diff --git a/include/namespace.h b/include/namespace.h
index e0745ab0b50972..8193e474a75f98 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -7,7 +7,6 @@
 #include <sys/syscall.h>
 #include <errno.h>
 
-#define AFNETNS_RUN_DIR "/var/run/afnetns"
 #define NETNS_RUN_DIR "/var/run/netns"
 #define NETNS_ETC_DIR "/etc/netns"
 
@@ -52,8 +51,6 @@ int netns_switch(char *netns);
 int netns_get_fd(const char *netns);
 int netns_foreach(int (*func)(char *nsname, void *arg), void *arg);
 
-int afnetns_open(const char *name);
-
 struct netns_func {
 	int (*func)(char *nsname, void *arg);
 	void *arg;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 2994b6a3e0a154..d954f3ea5bff40 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -38,6 +38,7 @@
 #include "xdp.h"
 #include "color.h"
 #include "namespace.h"
+#include "afnetns.h"
 
 enum {
 	IPADD_LIST,
@@ -1004,7 +1005,7 @@ static int afnetns_get_fd(const char *name)
 {
 	int ns = -1;
 
-	if (name[0] == '/')
+	if (strnlen(name, 1) && name[0] == '/')
 		ns = open(name, O_RDONLY | O_CLOEXEC);
 	else
 		ns = afnetns_open(name);
@@ -1219,8 +1220,13 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		}
 	}
 	if (rta_tb[IFA_AFNETNS_INODE]) {
-		fprintf(fp, " afnet:[%u]",
-			rta_getattr_u32(rta_tb[IFA_AFNETNS_INODE]));
+		ino_t inode;
+		char *name;
+
+		inode = rta_getattr_u32(rta_tb[IFA_AFNETNS_INODE]);
+		name = afnetns_lookup_name(inode);
+		if (name)
+			fprintf(fp, " afnet %s", name);
 	}
 	fprintf(fp, "\n");
 brief_exit:
diff --git a/ip/ipafnetns.c b/ip/ipafnetns.c
index 5a197ad3866d18..2fd749a3f20628 100644
--- a/ip/ipafnetns.c
+++ b/ip/ipafnetns.c
@@ -7,6 +7,7 @@
 #include "utils.h"
 #include "ip_common.h"
 #include "namespace.h"
+#include "afnetns.h"
 
 static void usage(void)
 {
diff --git a/lib/Makefile b/lib/Makefile
index 1d24ca24b9a39f..7825021ea3cfa8 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -8,7 +8,7 @@ CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
 	inet_proto.o namespace.o json_writer.o \
-	names.o color.o bpf.o exec.o fs.o
+	names.o color.o bpf.o exec.o fs.o afnetns.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/afnetns.c b/lib/afnetns.c
new file mode 100644
index 00000000000000..d58a55df46daa7
--- /dev/null
+++ b/lib/afnetns.c
@@ -0,0 +1,226 @@
+#include <stdlib.h>
+#include <stdio.h>
+#include <stdbool.h>
+#include <string.h>
+#include <errno.h>
+#include <limits.h>
+
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include <dirent.h>
+#include <unistd.h>
+#include <fcntl.h>
+
+#include <math.h>
+
+#include "list.h"
+#include "afnetns.h"
+
+#define ULONG_CHARS ((int)ceill(log10l(ULONG_MAX)))
+
+static struct inode_cache {
+	struct inode_cache *next;
+	ino_t inode;
+	char name[];
+} *cache[64];
+
+static int self_inode(ino_t *me)
+{
+	static bool initialized;
+	static ino_t inode;
+	long path_size;
+	char *path;
+	int err;
+
+	if (initialized) {
+		*me = inode;
+		return 0;
+	}
+
+	errno = 0;
+	path_size = pathconf("/proc/self/ns/afnet", _PC_PATH_MAX);
+	if (path_size < 0) {
+		if (errno)
+			perror("pathconf");
+		else
+			fprintf(stderr,
+				"couldn't determine _PC_PATH_MAX for procfs: %zd\n",
+				path_size);
+		return -1;
+	}
+
+	path = malloc(path_size);
+	if (!path) {
+		perror("malloc");
+		return -1;
+	}
+
+	err = readlink("/proc/self/ns/afnet", path, path_size);
+	if (err < 0) {
+		perror("readlink");
+		goto out;
+	} else if (err >= path_size) {
+		fprintf(stderr, "readlink(\"/proc/self/ns/afnet\") exceeded maximum path length: %d >= %ld",
+			err, path_size);
+		err = -1;
+		goto out;
+	}
+	path[err] = '\0';
+
+	if (sscanf(path, "afnet:[%lu]", &inode) != 1) {
+		perror("sscanf");
+		err = -1;
+		goto out;
+	}
+
+	initialized = true;
+	*me = inode;
+	err = 0;
+out:
+	free(path);
+	return err;
+}
+
+static struct inode_cache **lookup_node(ino_t inode)
+{
+	struct inode_cache **node;
+
+	node = cache + (inode & 63);
+	while (*node && node[0]->inode != inode)
+		node = &node[0]->next;
+
+	return node;
+}
+
+static void fill_cache(void)
+{
+	struct dirent *ent;
+	ino_t me;
+	DIR *dir;
+
+	if (self_inode(&me))
+		return;
+
+	dir = opendir(AFNETNS_RUN_DIR);
+	if (!dir)
+		return;
+
+	errno = 0;
+	while ((ent = readdir(dir))) {
+		struct inode_cache **node;
+		struct stat buf;
+		ino_t inode;
+		bool self;
+		char *end;
+		int fd;
+
+		if (!strcmp(ent->d_name, ".") ||
+		    !strcmp(ent->d_name, ".."))
+			continue;
+
+		fd = dirfd(dir);
+		if (fd < 0) {
+			perror("dirfd");
+			continue;
+		}
+
+		if (fstatat(fd, ent->d_name, &buf, 0)) {
+			perror("fstatat");
+			continue;
+		}
+
+		inode = buf.st_ino;
+		self = me == inode;
+
+		node = lookup_node(inode);
+		if (*node)
+			continue;
+
+		*node = malloc(sizeof(**node)
+			       + strlen(ent->d_name)
+			       + (self ? strlen(",self") : 0)
+			       + 1);
+		if (!*node)
+			continue;
+
+		node[0]->next = NULL;
+		node[0]->inode = inode;
+		end  = stpcpy(node[0]->name, ent->d_name);
+		if (self)
+			strcpy(end, ",self");
+
+		errno = 0;
+	}
+
+	if (errno)
+		perror("readdir");
+
+	if (closedir(dir))
+		perror("closedir");
+}
+
+static char *lookup_cache(ino_t inode)
+{
+	struct inode_cache **node;
+	bool self;
+	ino_t me;
+
+	node = lookup_node(inode);
+	if (*node)
+		return node[0]->name;
+
+	if (self_inode(&me))
+		return NULL;
+
+	self = me == inode;
+
+	*node = malloc(sizeof(**node) + ULONG_CHARS + strlen("afnet:[]") + 1 +
+		       (self ? strlen(",self") : 0));
+	if (!*node)
+		return NULL;
+
+	if (sprintf(node[0]->name, "afnet:[%lu]%s", inode, self ? ",self" : "") < 0) {
+		free(*node);
+		*node = NULL;
+		return NULL;
+	}
+
+	node[0]->next = NULL;
+	node[0]->inode = inode;
+	return node[0]->name;
+}
+
+char *afnetns_lookup_name(ino_t inode)
+{
+	static bool initialized = false;
+
+	if (!initialized) {
+		fill_cache();
+		initialized = true;
+	}
+
+	return lookup_cache(inode);
+}
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
+
diff --git a/lib/namespace.c b/lib/namespace.c
index f20e5b6ef5a3ef..30b513889e6e24 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -124,24 +124,3 @@ int netns_foreach(int (*func)(char *nsname, void *arg), void *arg)
 	closedir(dir);
 	return 0;
 }
-
-int afnetns_open(const char *name)
-{
-	int ns;
-	char *path;
-
-	ns = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
-	if (ns < 0) {
-		perror("asprintf");
-		return ns;
-	};
-
-	ns = open(path, O_RDONLY | O_CLOEXEC);
-	if (ns < 0) {
-		fprintf(stderr, "Cannot open afnet namespace \"%s\": %s\n",
-			name, strerror(errno));
-	}
-
-	free(path);
-	return ns;
-}
-- 
2.9.3
