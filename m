From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 1/2] bpf: minor cleanups for bpf_trace_pipe
Date: Tue,  5 Sep 2017 02:24:31 +0200
Message-ID: <aee6f9e51843216733ebfb1072748eca21544cf6.1504570627.git.daniel@iogearbox.net>
References: <cover.1504570627.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49479 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754046AbdIEAYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 20:24:46 -0400
In-Reply-To: <cover.1504570627.git.daniel@iogearbox.net>
In-Reply-To: <cover.1504570627.git.daniel@iogearbox.net>
References: <cover.1504570627.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just minor nits, e.g. no need to fflush() and instead of returning
right away, just break and close the fd.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 5fd4928..7463fdc 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -569,9 +569,9 @@ int bpf_trace_pipe(void)
 		"/trace",
 		0,
 	};
+	int fd_in, fd_out = STDERR_FILENO;
 	char tpipe[PATH_MAX];
 	const char *mnt;
-	int fd;
 
 	mnt = bpf_find_mntpt("tracefs", TRACEFS_MAGIC, tracefs_mnt,
 			     sizeof(tracefs_mnt), tracefs_known_mnts);
@@ -582,8 +582,8 @@ int bpf_trace_pipe(void)
 
 	snprintf(tpipe, sizeof(tpipe), "%s/trace_pipe", mnt);
 
-	fd = open(tpipe, O_RDONLY);
-	if (fd < 0)
+	fd_in = open(tpipe, O_RDONLY);
+	if (fd_in < 0)
 		return -1;
 
 	fprintf(stderr, "Running! Hang up with ^C!\n\n");
@@ -591,15 +591,14 @@ int bpf_trace_pipe(void)
 		static char buff[4096];
 		ssize_t ret;
 
-		ret = read(fd, buff, sizeof(buff) - 1);
-		if (ret > 0) {
-			if (write(STDERR_FILENO, buff, ret) != ret)
-				return -1;
-			fflush(stderr);
-		}
+		ret = read(fd_in, buff, sizeof(buff));
+		if (ret > 0 && write(fd_out, buff, ret) == ret)
+			continue;
+		break;
 	}
 
-	return 0;
+	close(fd_in);
+	return -1;
 }
 
 static int bpf_gen_global(const char *bpf_sub_dir)
-- 
1.9.3
