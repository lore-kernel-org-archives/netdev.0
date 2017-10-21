From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] selftests/bpf: fix broken build of test_maps
Date: Fri, 20 Oct 2017 23:25:33 -0700
Message-ID: <20171021062533.2090015-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Chenbo Feng <fengc@google.com>,
        Lorenzo Colitti <lorenzo@google.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40282 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750961AbdJUGZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 02:25:36 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9L6PZWj005416
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 23:25:35 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqtak8pqw-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 23:25:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix broken tests

Fixes: e043325b3087 ("bpf: Add tests for eBPF file mode")
Fixes: 6e71b04a8224 ("bpf: Add file mode configuration into bpf maps")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
Chenbo,

this was very broken patch submission.
Please make sure to actually compile your tests before sending patches.
---
 tools/include/uapi/linux/bpf.h          | 35 ++++++++++++++++++++++++++++++---
 tools/testing/selftests/bpf/test_maps.c |  6 +++---
 2 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index fa93033dc521..d83f95ea6a1b 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -218,6 +218,10 @@ enum bpf_attach_type {
 
 #define BPF_OBJ_NAME_LEN 16U
 
+/* Flags for accessing BPF object */
+#define BPF_F_RDONLY		(1U << 3)
+#define BPF_F_WRONLY		(1U << 4)
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -260,6 +264,7 @@ union bpf_attr {
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
 		__aligned_u64	pathname;
 		__u32		bpf_fd;
+		__u32		file_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
@@ -287,6 +292,7 @@ union bpf_attr {
 			__u32		map_id;
 		};
 		__u32		next_id;
+		__u32		open_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_GET_INFO_BY_FD */
@@ -366,7 +372,7 @@ union bpf_attr {
  *     jump into another BPF program
  *     @ctx: context pointer passed to next program
  *     @prog_array_map: pointer to map which type is BPF_MAP_TYPE_PROG_ARRAY
- *     @index: index inside array that selects specific program to run
+ *     @index: 32-bit index inside array that selects specific program to run
  *     Return: 0 on success or negative error
  *
  * int bpf_clone_redirect(skb, ifindex, flags)
@@ -642,6 +648,21 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data_meta
  *     Return: 0 on success or negative on error
+ *
+ * int bpf_perf_event_read_value(map, flags, buf, buf_size)
+ *     read perf event counter value and perf event enabled/running time
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return: 0 on success or negative error code
+ *
+ * int bpf_perf_prog_read_value(ctx, buf, buf_size)
+ *     read perf prog attached perf event counter and enabled/running time
+ *     @ctx: pointer to ctx
+ *     @buf: buf to fill
+ *     @buf_size: size of the buf
+ *     Return : 0 on success or negative error code
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -744,7 +765,9 @@ enum bpf_func_id {
 #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
 #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
 
-/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
+/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
+ * BPF_FUNC_perf_event_read_value flags.
+ */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
 /* BPF_FUNC_perf_event_output for sk_buff input context. */
@@ -872,7 +895,7 @@ struct bpf_prog_info {
 	__u32 created_by_uid;
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
-	char  name[BPF_OBJ_NAME_LEN];
+	char name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
@@ -937,4 +960,10 @@ enum {
 #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
 #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
 
+struct bpf_perf_event_value {
+	__u64 counter;
+	__u64 enabled;
+	__u64 running;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 896f23cfe918..c302847671dc 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -1035,7 +1035,7 @@ static void test_map_parallel(void)
 
 static void test_map_rdonly(void)
 {
-	int i, fd, key = 0, value = 0;
+	int fd, key = 0, value = 0;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags | BPF_F_RDONLY);
@@ -1058,7 +1058,7 @@ static void test_map_rdonly(void)
 
 static void test_map_wronly(void)
 {
-	int i, fd, key = 0, value = 0;
+	int fd, key = 0, value = 0;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags | BPF_F_WRONLY);
@@ -1071,7 +1071,7 @@ static void test_map_wronly(void)
 	key = 1;
 	value = 1234;
 	/* Insert key=1 element. */
-	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0)
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0);
 
 	/* Check that key=2 is not found. */
 	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == EPERM);
-- 
2.9.5
