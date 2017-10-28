From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH net-next] samples/bpf: adjust rlimit RLIMIT_MEMLOCK for xdp_redirect_map
Date: Fri, 27 Oct 2017 17:28:22 -0700
Message-ID: <1509150502-6632-1-git-send-email-tushar.n.dave@oracle.com>
To: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44359 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdJ1A2p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:28:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default rlimit RLIMIT_MEMLOCK is 64KB, causes bpf map failure.
e.g.
[root@labbpf]# ./xdp_redirect_map $(</sys/class/net/eth2/ifindex) \
> $(</sys/class/net/eth3/ifindex)
failed to create a map: 1 Operation not permitted

The failure is 100% when multiple xdp programs are running. Fix it.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 samples/bpf/xdp_redirect_map_user.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/samples/bpf/xdp_redirect_map_user.c b/samples/bpf/xdp_redirect_map_user.c
index d4d86a2..978a532 100644
--- a/samples/bpf/xdp_redirect_map_user.c
+++ b/samples/bpf/xdp_redirect_map_user.c
@@ -20,6 +20,7 @@
 #include <string.h>
 #include <unistd.h>
 #include <libgen.h>
+#include <sys/resource.h>
 
 #include "bpf_load.h"
 #include "bpf_util.h"
@@ -74,6 +75,7 @@ static void usage(const char *prog)
 
 int main(int argc, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	const char *optstr = "SN";
 	char filename[256];
 	int ret, opt, key = 0;
@@ -97,6 +99,11 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK)");
+		return 1;
+	}
+
 	ifindex_in = strtoul(argv[optind], NULL, 0);
 	ifindex_out = strtoul(argv[optind + 1], NULL, 0);
 	printf("input: %d output: %d\n", ifindex_in, ifindex_out);
-- 
1.9.1
