From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/3] samples/bpf: xdp_monitor increase memory rlimit
Date: Fri, 06 Oct 2017 10:41:51 +0200
Message-ID: <150727931167.4460.6190697015268732941.stgit@firesoul>
References: <150727927390.4460.3200093291677318710.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36978 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdJFIlx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 04:41:53 -0400
In-Reply-To: <150727927390.4460.3200093291677318710.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other concurrent running programs, like perf or the XDP program what
needed to be monitored, might take up part of the max locked memory
limit.  Thus, the xdp_monitor tool have to set the RLIMIT_MEMLOCK to
RLIM_INFINITY, as it cannot determine a more sane limit.

Using the man exit(3) specified EXIT_FAILURE return exit code, and
correct other users too.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/xdp_monitor_user.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/xdp_monitor_user.c b/samples/bpf/xdp_monitor_user.c
index 97c3456c11b2..eaba165b3549 100644
--- a/samples/bpf/xdp_monitor_user.c
+++ b/samples/bpf/xdp_monitor_user.c
@@ -20,6 +20,7 @@ static const char *__doc_err_only__=
 #include <unistd.h>
 #include <locale.h>
 
+#include <sys/resource.h>
 #include <getopt.h>
 #include <net/if.h>
 #include <time.h>
@@ -295,6 +296,7 @@ static void print_bpf_prog_info(void)
 
 int main(int argc, char **argv)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	int longindex = 0, opt;
 	int ret = EXIT_SUCCESS;
 	char bpf_obj_file[256];
@@ -325,13 +327,18 @@ int main(int argc, char **argv)
 		}
 	}
 
+	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
+		perror("setrlimit(RLIMIT_MEMLOCK)");
+		return EXIT_FAILURE;
+	}
+
 	if (load_bpf_file(bpf_obj_file)) {
 		printf("ERROR - bpf_log_buf: %s", bpf_log_buf);
-		return 1;
+		return EXIT_FAILURE;
 	}
 	if (!prog_fd[0]) {
 		printf("ERROR - load_bpf_file: %s\n", strerror(errno));
-		return 1;
+		return EXIT_FAILURE;
 	}
 
 	if (debug) {
