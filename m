From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/2] bpf: Add test for syscall on fd array/htab lookup
Date: Tue, 27 Jun 2017 23:08:35 -0700
Message-ID: <20170628060835.2142549-3-kafai@fb.com>
References: <20170628060835.2142549-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33574 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751580AbdF1GIj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 02:08:39 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5S66UkB007777
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2bc05j8ukh-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:08:38 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 38d5fd285bc811e7b7a00002c991e86a-1eb358f0 for <netdev@vger.kernel.org>;        Tue,
 27 Jun 2017 23:08:36 -0700
In-Reply-To: <20170628060835.2142549-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checks are added to the existing sockex3 and test_map_in_map test.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/sockex3_user.c         | 15 ++++++++++++++-
 samples/bpf/test_map_in_map_user.c | 17 +++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index b5524d417eb5..877ecf8fc5ac 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -8,6 +8,10 @@
 #include <arpa/inet.h>
 #include <sys/resource.h>
 
+#define PARSE_IP 3
+#define PARSE_IP_PROG_FD (prog_fd[0])
+#define PROG_ARRAY_FD (map_fd[0])
+
 struct bpf_flow_keys {
 	__be32 src;
 	__be32 dst;
@@ -28,7 +32,9 @@ int main(int argc, char **argv)
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 	char filename[256];
 	FILE *f;
-	int i, sock;
+	int i, sock, err, id, key = PARSE_IP;
+	struct bpf_prog_info info = {};
+	uint32_t info_len = sizeof(info);
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
 	setrlimit(RLIMIT_MEMLOCK, &r);
@@ -38,6 +44,13 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
+	/* Test fd array lookup which returns the id of the bpf_prog */
+	err = bpf_obj_get_info_by_fd(PARSE_IP_PROG_FD, &info, &info_len);
+	assert(!err);
+	err = bpf_map_lookup_elem(PROG_ARRAY_FD, &key, &id);
+	assert(!err);
+	assert(id == info.id);
+
 	sock = open_raw_sock("lo");
 
 	assert(setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd[4],
diff --git a/samples/bpf/test_map_in_map_user.c b/samples/bpf/test_map_in_map_user.c
index f62fdc2bd428..1aca18539d8d 100644
--- a/samples/bpf/test_map_in_map_user.c
+++ b/samples/bpf/test_map_in_map_user.c
@@ -32,6 +32,20 @@ static const char * const test_names[] = {
 
 #define NR_TESTS (sizeof(test_names) / sizeof(*test_names))
 
+static void check_map_id(int inner_map_fd, int map_in_map_fd, uint32_t key)
+{
+	struct bpf_map_info info = {};
+	uint32_t info_len = sizeof(info);
+	int ret, id;
+
+	ret = bpf_obj_get_info_by_fd(inner_map_fd, &info, &info_len);
+	assert(!ret);
+
+	ret = bpf_map_lookup_elem(map_in_map_fd, &key, &id);
+	assert(!ret);
+	assert(id == info.id);
+}
+
 static void populate_map(uint32_t port_key, int magic_result)
 {
 	int ret;
@@ -45,12 +59,15 @@ static void populate_map(uint32_t port_key, int magic_result)
 
 	ret = bpf_map_update_elem(A_OF_PORT_A, &port_key, &PORT_A, BPF_ANY);
 	assert(!ret);
+	check_map_id(PORT_A, A_OF_PORT_A, port_key);
 
 	ret = bpf_map_update_elem(H_OF_PORT_A, &port_key, &PORT_A, BPF_NOEXIST);
 	assert(!ret);
+	check_map_id(PORT_A, H_OF_PORT_A, port_key);
 
 	ret = bpf_map_update_elem(H_OF_PORT_H, &port_key, &PORT_H, BPF_NOEXIST);
 	assert(!ret);
+	check_map_id(PORT_H, H_OF_PORT_H, port_key);
 }
 
 static void test_map_in_map(void)
-- 
2.9.3
