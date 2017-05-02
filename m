From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/4] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for
 traceex2, tracex3 and tracex4
Date: Tue, 02 May 2017 14:31:50 +0200
Message-ID: <149372831091.22268.12527267276516941574.stgit@firesoul>
References: <149372826543.22268.3617359219409721129.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbdEBMcC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:32:02 -0400
In-Reply-To: <149372826543.22268.3617359219409721129.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Needed to adjust max locked memory RLIMIT_MEMLOCK for testing these bpf samples
as these are using more and larger maps than can fit in distro default 64Kbytes limit.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/tracex2_user.c |    7 +++++++
 samples/bpf/tracex3_user.c |    7 +++++++
 samples/bpf/tracex4_user.c |    8 ++++++++
 3 files changed, 22 insertions(+)

diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index ded9804c5034..7fee0f1ba9a3 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -4,6 +4,7 @@
 #include <signal.h>
 #include <linux/bpf.h>
 #include <string.h>
+#include <sys/resource.h>
 
 #include "libbpf.h"
 #include "bpf_load.h"
@@ -112,6 +113,7 @@ static void int_exit(int sig)
 
 int main(int ac, char **argv)
 {
+	struct rlimit r = {1024*1024, RLIM_INFINITY};
 	char filename[256];
 	long key, next_key, value;
 	FILE *f;
@@ -119,6 +121,11 @@ int main(int ac, char **argv)
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK)");
+		return 1;
+	}
+
 	signal(SIGINT, int_exit);
 
 	/* start 'ping' in the background to have some kfree_skb events */
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
index 8f7d199d5945..fe372239d505 100644
--- a/samples/bpf/tracex3_user.c
+++ b/samples/bpf/tracex3_user.c
@@ -11,6 +11,7 @@
 #include <stdbool.h>
 #include <string.h>
 #include <linux/bpf.h>
+#include <sys/resource.h>
 
 #include "libbpf.h"
 #include "bpf_load.h"
@@ -112,11 +113,17 @@ static void print_hist(int fd)
 
 int main(int ac, char **argv)
 {
+	struct rlimit r = {1024*1024, RLIM_INFINITY};
 	char filename[256];
 	int i;
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK)");
+		return 1;
+	}
+
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
 		return 1;
diff --git a/samples/bpf/tracex4_user.c b/samples/bpf/tracex4_user.c
index 03449f773cb1..22c644f1f4c3 100644
--- a/samples/bpf/tracex4_user.c
+++ b/samples/bpf/tracex4_user.c
@@ -12,6 +12,8 @@
 #include <string.h>
 #include <time.h>
 #include <linux/bpf.h>
+#include <sys/resource.h>
+
 #include "libbpf.h"
 #include "bpf_load.h"
 
@@ -50,11 +52,17 @@ static void print_old_objects(int fd)
 
 int main(int ac, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	char filename[256];
 	int i;
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK, RLIM_INFINITY)");
+		return 1;
+	}
+
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
 		return 1;
