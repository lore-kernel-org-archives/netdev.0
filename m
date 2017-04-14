From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/6] bpf: lru: Add test_lru_sanity6 for BPF_F_NO_COMMON_LRU
Date: Fri, 14 Apr 2017 10:30:25 -0700
Message-ID: <20170414173030.2853860-2-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41835 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751612AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHPLLZ026252
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29u1phrfm1-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 0e817644213811e79e5b0002c9931860-3dffa9a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_lru_sanity3 is not applicable to BPF_F_NO_COMMON_LRU.
It just happens to work when PERCPU_FREE_TARGET == 16.

This patch:
1) Disable test_lru_sanity3 for BPF_F_NO_COMMON_LRU
2) Add test_lru_sanity6 to test list rotation for
   the BPF_F_NO_COMMON_LRU map.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_lru_map.c | 70 +++++++++++++++++++++++++++---
 1 file changed, 65 insertions(+), 5 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 00b0aff56e2e..04b2242937cc 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -387,6 +387,10 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	unsigned int map_size;
 	int next_cpu = 0;
 
+	if (map_flags & BPF_F_NO_COMMON_LRU)
+		/* This test is only applicable to common LRU list */
+		return;
+
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
@@ -396,11 +400,7 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	assert(batch_size * 2 == tgt_free);
 
 	map_size = tgt_free * 2;
-	if (map_flags & BPF_F_NO_COMMON_LRU)
-		lru_map_fd = create_map(map_type, map_flags,
-					map_size * nr_cpus);
-	else
-		lru_map_fd = create_map(map_type, map_flags, map_size);
+	lru_map_fd = create_map(map_type, map_flags, map_size);
 	assert(lru_map_fd != -1);
 
 	expected_map_fd = create_map(BPF_MAP_TYPE_HASH, 0, map_size);
@@ -566,6 +566,65 @@ static void test_lru_sanity5(int map_type, int map_flags)
 	printf("Pass\n");
 }
 
+/* Test list rotation for BPF_F_NO_COMMON_LRU map */
+static void test_lru_sanity6(int map_type, int map_flags, int tgt_free)
+{
+	int lru_map_fd, expected_map_fd;
+	unsigned long long key, value[nr_cpus];
+	unsigned int map_size = tgt_free * 2;
+	int next_cpu = 0;
+
+	if (!(map_flags & BPF_F_NO_COMMON_LRU))
+		return;
+
+	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
+	       map_flags);
+
+	assert(sched_next_online(0, &next_cpu) != -1);
+
+	expected_map_fd = create_map(BPF_MAP_TYPE_HASH, 0, map_size);
+	assert(expected_map_fd != -1);
+
+	lru_map_fd = create_map(map_type, map_flags, map_size * nr_cpus);
+	assert(lru_map_fd != -1);
+
+	value[0] = 1234;
+
+	for (key = 1; key <= tgt_free; key++) {
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
+					    BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
+					    BPF_NOEXIST));
+	}
+
+	for (; key <= tgt_free * 2; key++) {
+		unsigned long long stable_key;
+
+		/* Make ref bit sticky for key: [1, tgt_free] */
+		for (stable_key = 1; stable_key <= tgt_free; stable_key++) {
+			/* Mark the ref bit */
+			assert(!bpf_map_lookup_elem(lru_map_fd, &stable_key,
+						    value));
+		}
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
+					    BPF_NOEXIST));
+	}
+
+	for (; key <= tgt_free * 3; key++) {
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
+					    BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
+					    BPF_NOEXIST));
+	}
+
+	assert(map_equal(lru_map_fd, expected_map_fd));
+
+	close(expected_map_fd);
+	close(lru_map_fd);
+
+	printf("Pass\n");
+}
+
 int main(int argc, char **argv)
 {
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
@@ -593,6 +652,7 @@ int main(int argc, char **argv)
 			test_lru_sanity3(map_types[t], map_flags[f], tgt_free);
 			test_lru_sanity4(map_types[t], map_flags[f], tgt_free);
 			test_lru_sanity5(map_types[t], map_flags[f]);
+			test_lru_sanity6(map_types[t], map_flags[f], tgt_free);
 
 			printf("\n");
 		}
-- 
2.9.3
