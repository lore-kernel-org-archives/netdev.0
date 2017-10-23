From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v2 3/3] bpf: add a test case to test single tp multiple bpf attachment
Date: Mon, 23 Oct 2017 15:13:31 -0700
Message-ID: <20171023221331.4131164-4-yhs@fb.com>
References: <20171023221331.4131164-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55048 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932195AbdJWWNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:13:39 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NMBeCu000878
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:13:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2dr22cx004-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:13:38 -0700
In-Reply-To: <20171023221331.4131164-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf sample program syscall_tp is modified to
show attachment of more than bpf programs
for a particular kernel tracepoint.

Signed-off-by: Yonghong Song <yhs@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/syscall_tp_user.c | 66 ++++++++++++++++++++++++++++++++++---------
 1 file changed, 53 insertions(+), 13 deletions(-)

diff --git a/samples/bpf/syscall_tp_user.c b/samples/bpf/syscall_tp_user.c
index a3cb91e..9169d32 100644
--- a/samples/bpf/syscall_tp_user.c
+++ b/samples/bpf/syscall_tp_user.c
@@ -23,6 +23,13 @@
  * This requires kernel CONFIG_FTRACE_SYSCALLS to be set.
  */
 
+static void usage(const char *cmd)
+{
+	printf("USAGE: %s [-i num_progs] [-h]\n", cmd);
+	printf("       -i num_progs      # number of progs of the test\n");
+	printf("       -h                # help\n");
+}
+
 static void verify_map(int map_id)
 {
 	__u32 key = 0;
@@ -32,22 +39,29 @@ static void verify_map(int map_id)
 		fprintf(stderr, "map_lookup failed: %s\n", strerror(errno));
 		return;
 	}
-	if (val == 0)
+	if (val == 0) {
 		fprintf(stderr, "failed: map #%d returns value 0\n", map_id);
+		return;
+	}
+	val = 0;
+	if (bpf_map_update_elem(map_id, &key, &val, BPF_ANY) != 0) {
+		fprintf(stderr, "map_update failed: %s\n", strerror(errno));
+		return;
+	}
 }
 
-int main(int argc, char **argv)
+static int test(char *filename, int num_progs)
 {
-	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
-	char filename[256];
-	int fd;
+	int i, fd, map0_fds[num_progs], map1_fds[num_progs];
 
-	setrlimit(RLIMIT_MEMLOCK, &r);
-	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
-
-	if (load_bpf_file(filename)) {
-		fprintf(stderr, "%s", bpf_log_buf);
-		return 1;
+	for (i = 0; i < num_progs; i++) {
+		if (load_bpf_file(filename)) {
+			fprintf(stderr, "%s", bpf_log_buf);
+			return 1;
+		}
+		printf("prog #%d: map ids %d %d\n", i, map_fd[0], map_fd[1]);
+		map0_fds[i] = map_fd[0];
+		map1_fds[i] = map_fd[1];
 	}
 
 	/* current load_bpf_file has perf_event_open default pid = -1
@@ -64,8 +78,34 @@ int main(int argc, char **argv)
 	close(fd);
 
 	/* verify the map */
-	verify_map(map_fd[0]);
-	verify_map(map_fd[1]);
+	for (i = 0; i < num_progs; i++) {
+		verify_map(map0_fds[i]);
+		verify_map(map1_fds[i]);
+	}
 
 	return 0;
 }
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	int opt, num_progs = 1;
+	char filename[256];
+
+	while ((opt = getopt(argc, argv, "i:h")) != -1) {
+		switch (opt) {
+		case 'i':
+			num_progs = atoi(optarg);
+			break;
+		case 'h':
+		default:
+			usage(argv[0]);
+			return 0;
+		}
+	}
+
+	setrlimit(RLIMIT_MEMLOCK, &r);
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	return test(filename, num_progs);
+}
-- 
2.9.5
