From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iproute] iptuntap: show processes using tuntap interface
Date: Wed, 24 Aug 2016 20:08:25 +0200
Message-ID: <1472062105-17995-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33447 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755047AbcHXSSC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:18:02 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.nyi.internal (Postfix) with ESMTP id E36D1203D9
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 14:08:33 -0400 (EDT)
Received: from z.com (unknown [213.55.184.242])
        by mail.messagingengine.com (Postfix) with ESMTPA id 0F40FF29CE
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 14:08:32 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show which processes are using which tun/tap devices, e.g.:

$ ip -d tuntap
tun0: tun
	Attached to processes: vpnc(9531)
vnet0: tap vnet_hdr
	Attached to processes: qemu-system-x86(10442)
virbr0-nic: tap UNKNOWN_FLAGS:800
	Attached to processes:

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 ip/iptuntap.c | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 43774f96e335ef..b5aa0542c1f8f2 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -25,6 +25,7 @@
 #include <fcntl.h>
 #include <dirent.h>
 #include <errno.h>
+#include <glob.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -273,6 +274,109 @@ static void print_flags(long flags)
 		printf(" UNKNOWN_FLAGS:%lx", flags);
 }
 
+static char *pid_name(pid_t pid)
+{
+	char *comm;
+	FILE *f;
+	int err;
+
+	err = asprintf(&comm, "/proc/%d/comm", pid);
+	if (err < 0)
+		return NULL;
+
+	f = fopen(comm, "r");
+	free(comm);
+	if (!f) {
+		perror("fopen");
+		return NULL;
+	}
+
+	if (fscanf(f, "%ms\n", &comm) != 1) {
+		perror("fscanf");
+		comm = NULL;
+	}
+
+
+	if (fclose(f))
+		perror("fclose");
+
+	return comm;
+}
+
+static void show_processes(const char *name)
+{
+	glob_t globbuf = { };
+	char **fd_path;
+	int err;
+
+	err = glob("/proc/[0-9]*/fd/[0-9]*", GLOB_NOSORT,
+		   NULL, &globbuf);
+	if (err)
+		return;
+
+	fd_path = globbuf.gl_pathv;
+	while (*fd_path) {
+		const char *dev_net_tun = "/dev/net/tun";
+		const size_t linkbuf_len = strlen(dev_net_tun) + 2;
+		char linkbuf[linkbuf_len], *fdinfo;
+		int pid, fd;
+		FILE *f;
+
+		if (sscanf(*fd_path, "/proc/%d/fd/%d", &pid, &fd) != 2)
+			goto next;
+
+		if (pid == getpid())
+			goto next;
+
+		err = readlink(*fd_path, linkbuf, linkbuf_len - 1);
+		if (err < 0) {
+			perror("readlink");
+			goto next;
+		}
+		linkbuf[err] = '\0';
+		if (strcmp(dev_net_tun, linkbuf))
+			goto next;
+
+		if (asprintf(&fdinfo, "/proc/%d/fdinfo/%d", pid, fd) < 0)
+			goto next;
+
+		f = fopen(fdinfo, "r");
+		free(fdinfo);
+		if (!f) {
+			perror("fopen");
+			goto next;
+		}
+
+		while (!feof(f)) {
+			char *key = NULL, *value = NULL;
+
+			err = fscanf(f, "%m[^:]: %ms\n", &key, &value);
+			if (err == EOF) {
+				if (ferror(f))
+					perror("fscanf");
+				break;
+			} else if (err == 2 &&
+				   !strcmp("iff", key) && !strcmp(name, value)) {
+				char *pname = pid_name(pid);
+				printf(" %s(%d)", pname ? pname : "<NULL>", pid);
+				free(pname);
+			}
+
+			free(key);
+			free(value);
+		}
+		if (fclose(f))
+			perror("fclose");
+
+next:
+		++fd_path;
+	}
+
+	globfree(&globbuf);
+	return;
+}
+
+
 static int do_show(int argc, char **argv)
 {
 	DIR *dir;
@@ -302,6 +406,11 @@ static int do_show(int argc, char **argv)
 		if (group != -1)
 			printf(" group %ld", group);
 		printf("\n");
+		if (show_details) {
+			printf("\tAttached to processes:");
+			show_processes(d->d_name);
+			printf("\n");
+		}
 	}
 	closedir(dir);
 	return 0;
-- 
2.7.4
