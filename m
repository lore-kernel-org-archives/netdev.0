From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH net-next] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for xdp1
Date: Fri, 27 Oct 2017 16:12:30 -0700
Message-ID: <1509145950-5840-1-git-send-email-tushar.n.dave@oracle.com>
To: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42937 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdJ0XMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 19:12:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default rlimit RLIMIT_MEMLOCK is 64KB, causes bpf map failure.
e.g.
[root@lab bpf]#./xdp1 -N $(</sys/class/net/eth2/ifindex)
failed to create a map: 1 Operation not permitted

Fix it.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 samples/bpf/xdp1_user.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index 2431c03..fdaefe9 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -14,6 +14,7 @@
 #include <string.h>
 #include <unistd.h>
 #include <libgen.h>
+#include <sys/resource.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
@@ -69,6 +70,7 @@ static void usage(const char *prog)
 
 int main(int argc, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	const char *optstr = "SN";
 	char filename[256];
 	int opt;
@@ -91,6 +93,12 @@ int main(int argc, char **argv)
 		usage(basename(argv[0]));
 		return 1;
 	}
+
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK)");
+		return 1;
+	}
+
 	ifindex = strtoul(argv[optind], NULL, 0);
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
-- 
1.9.1
