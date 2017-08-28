From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 9/9] bpf: test_maps add sockmap stress test
Date: Mon, 28 Aug 2017 07:12:41 -0700
Message-ID: <20170828141241.14143.90704.stgit@john-Precision-Tower-5810>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36501 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdH1OM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 10:12:56 -0400
Received: by mail-pg0-f67.google.com with SMTP id 83so458599pgb.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 07:12:56 -0700 (PDT)
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sockmap is a bit different than normal stress tests that can run
in parallel as is. We need to reuse the same socket pool and map
pool to get good stress test cases.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_maps.c |   29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 0c4b56d..7059bb3 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -461,7 +461,7 @@ static void test_devmap(int task, void *data)
 #include <linux/err.h>
 #define SOCKMAP_PARSE_PROG "./sockmap_parse_prog.o"
 #define SOCKMAP_VERDICT_PROG "./sockmap_verdict_prog.o"
-static void test_sockmap(int task, void *data)
+static void test_sockmap(int tasks, void *data)
 {
 	int one = 1, map_fd_rx, map_fd_tx, map_fd_break, s, sc, rc;
 	struct bpf_map *bpf_map_rx, *bpf_map_tx, *bpf_map_break;
@@ -473,6 +473,7 @@ static void test_sockmap(int task, void *data)
 	struct bpf_object *obj;
 	struct timeval to;
 	__u32 key, value;
+	pid_t pid[tasks];
 	fd_set w;
 
 	/* Create some sockets to use with sockmap */
@@ -782,6 +783,32 @@ static void test_sockmap(int task, void *data)
 		}
 	}
 
+	/* Test tasks number of forked operations */
+	for (i = 0; i < tasks; i++) {
+		pid[i] = fork();
+		if (pid[i] == 0) {
+			for (i = 0; i < 6; i++) {
+				bpf_map_delete_elem(map_fd_tx, &i);
+				bpf_map_delete_elem(map_fd_rx, &i);
+				bpf_map_update_elem(map_fd_tx, &i,
+						    &sfd[i], BPF_ANY);
+				bpf_map_update_elem(map_fd_rx, &i,
+						    &sfd[i], BPF_ANY);
+			}
+			exit(0);
+		} else if (pid[i] == -1) {
+			printf("Couldn't spawn #%d process!\n", i);
+			exit(1);
+		}
+	}
+
+	for (i = 0; i < tasks; i++) {
+		int status;
+
+		assert(waitpid(pid[i], &status, 0) == pid[i]);
+		assert(status == 0);
+	}
+
 	/* Test map close sockets */
 	for (i = 0; i < 6; i++)
 		close(sfd[i]);
