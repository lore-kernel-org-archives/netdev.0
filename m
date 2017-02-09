From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v5 06/11] bpf: Use bpf_map_lookup_elem() from the library
Date: Fri, 10 Feb 2017 00:21:40 +0100
Message-ID: <20170209232145.19085-7-mic@digikod.net>
References: <20170209232145.19085-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209232145.19085-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_map_lookup() with bpf_map_lookup_elem() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                        |  2 +-
 tools/lib/bpf/bpf.h                        |  2 +-
 tools/testing/selftests/bpf/bpf_sys.h      | 11 -----------
 tools/testing/selftests/bpf/test_lpm_map.c | 16 ++++++++--------
 tools/testing/selftests/bpf/test_lru_map.c | 28 ++++++++++++++--------------
 tools/testing/selftests/bpf/test_maps.c    | 30 +++++++++++++++---------------
 6 files changed, 39 insertions(+), 50 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 1de762677a2f..b1a1f58b99e0 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -112,7 +112,7 @@ int bpf_map_update_elem(int fd, const void *key, const void *value,
 	return sys_bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_map_lookup_elem(int fd, void *key, void *value)
+int bpf_map_lookup_elem(int fd, const void *key, void *value)
 {
 	union bpf_attr attr;
 
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 2458534c8b33..171cf594f782 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -36,7 +36,7 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
 
-int bpf_map_lookup_elem(int fd, void *key, void *value);
+int bpf_map_lookup_elem(int fd, const void *key, void *value);
 int bpf_map_delete_elem(int fd, void *key);
 int bpf_map_get_next_key(int fd, void *key, void *next_key);
 int bpf_obj_pin(int fd, const char *pathname);
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index e08dec0db9e0..0a5a6060db70 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -24,17 +24,6 @@ static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 #endif
 }
 
-static inline int bpf_map_lookup(int fd, const void *key, void *value)
-{
-	union bpf_attr attr = {};
-
-	attr.map_fd = fd;
-	attr.key = bpf_ptr_to_u64(key);
-	attr.value = bpf_ptr_to_u64(value);
-
-	return bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
-}
-
 static inline int bpf_map_delete(int fd, const void *key)
 {
 	union bpf_attr attr = {};
diff --git a/tools/testing/selftests/bpf/test_lpm_map.c b/tools/testing/selftests/bpf/test_lpm_map.c
index e29ffbcd2932..bd08394c26cb 100644
--- a/tools/testing/selftests/bpf/test_lpm_map.c
+++ b/tools/testing/selftests/bpf/test_lpm_map.c
@@ -211,7 +211,7 @@ static void test_lpm_map(int keysize)
 
 		key->prefixlen = 8 * keysize;
 		memcpy(key->data, data, keysize);
-		r = bpf_map_lookup(map, key, value);
+		r = bpf_map_lookup_elem(map, key, value);
 		assert(!r || errno == ENOENT);
 		assert(!t == !!r);
 
@@ -300,32 +300,32 @@ static void test_lpm_ipaddr(void)
 
 	/* Test some lookups that should come back with a value */
 	inet_pton(AF_INET, "192.168.128.23", key_ipv4->data);
-	assert(bpf_map_lookup(map_fd_ipv4, key_ipv4, &value) == 0);
+	assert(bpf_map_lookup_elem(map_fd_ipv4, key_ipv4, &value) == 0);
 	assert(value == 3);
 
 	inet_pton(AF_INET, "192.168.0.1", key_ipv4->data);
-	assert(bpf_map_lookup(map_fd_ipv4, key_ipv4, &value) == 0);
+	assert(bpf_map_lookup_elem(map_fd_ipv4, key_ipv4, &value) == 0);
 	assert(value == 2);
 
 	inet_pton(AF_INET6, "2a00:1450:4001:814::", key_ipv6->data);
-	assert(bpf_map_lookup(map_fd_ipv6, key_ipv6, &value) == 0);
+	assert(bpf_map_lookup_elem(map_fd_ipv6, key_ipv6, &value) == 0);
 	assert(value == 0xdeadbeef);
 
 	inet_pton(AF_INET6, "2a00:1450:4001:814::1", key_ipv6->data);
-	assert(bpf_map_lookup(map_fd_ipv6, key_ipv6, &value) == 0);
+	assert(bpf_map_lookup_elem(map_fd_ipv6, key_ipv6, &value) == 0);
 	assert(value == 0xdeadbeef);
 
 	/* Test some lookups that should not match any entry */
 	inet_pton(AF_INET, "10.0.0.1", key_ipv4->data);
-	assert(bpf_map_lookup(map_fd_ipv4, key_ipv4, &value) == -1 &&
+	assert(bpf_map_lookup_elem(map_fd_ipv4, key_ipv4, &value) == -1 &&
 	       errno == ENOENT);
 
 	inet_pton(AF_INET, "11.11.11.11", key_ipv4->data);
-	assert(bpf_map_lookup(map_fd_ipv4, key_ipv4, &value) == -1 &&
+	assert(bpf_map_lookup_elem(map_fd_ipv4, key_ipv4, &value) == -1 &&
 	       errno == ENOENT);
 
 	inet_pton(AF_INET6, "2a00:ffff::", key_ipv6->data);
-	assert(bpf_map_lookup(map_fd_ipv6, key_ipv6, &value) == -1 &&
+	assert(bpf_map_lookup_elem(map_fd_ipv6, key_ipv6, &value) == -1 &&
 	       errno == ENOENT);
 
 	close(map_fd_ipv4);
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 2f61b5817af4..eccf6d96e551 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -47,8 +47,8 @@ static int map_subset(int map0, int map1)
 	int ret;
 
 	while (!bpf_map_next_key(map1, &next_key, &next_key)) {
-		assert(!bpf_map_lookup(map1, &next_key, value1));
-		ret = bpf_map_lookup(map0, &next_key, value0);
+		assert(!bpf_map_lookup_elem(map1, &next_key, value1));
+		ret = bpf_map_lookup_elem(map0, &next_key, value0);
 		if (ret) {
 			printf("key:%llu not found from map. %s(%d)\n",
 			       next_key, strerror(errno), errno);
@@ -136,7 +136,7 @@ static void test_lru_sanity0(int map_type, int map_flags)
 
 	/* check that key=2 is not found */
 	key = 2;
-	assert(bpf_map_lookup(lru_map_fd, &key, value) == -1 &&
+	assert(bpf_map_lookup_elem(lru_map_fd, &key, value) == -1 &&
 	       errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
@@ -150,14 +150,14 @@ static void test_lru_sanity0(int map_type, int map_flags)
 
 	/* check that key=3 is not found */
 	key = 3;
-	assert(bpf_map_lookup(lru_map_fd, &key, value) == -1 &&
+	assert(bpf_map_lookup_elem(lru_map_fd, &key, value) == -1 &&
 	       errno == ENOENT);
 
 	/* check that key=1 can be found and mark the ref bit to
 	 * stop LRU from removing key=1
 	 */
 	key = 1;
-	assert(!bpf_map_lookup(lru_map_fd, &key, value));
+	assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 	assert(value[0] == 1234);
 
 	key = 3;
@@ -167,7 +167,7 @@ static void test_lru_sanity0(int map_type, int map_flags)
 
 	/* key=2 has been removed from the LRU */
 	key = 2;
-	assert(bpf_map_lookup(lru_map_fd, &key, value) == -1);
+	assert(bpf_map_lookup_elem(lru_map_fd, &key, value) == -1);
 
 	assert(map_equal(lru_map_fd, expected_map_fd));
 
@@ -226,7 +226,7 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	/* Lookup 1 to tgt_free/2 */
 	end_key = 1 + batch_size;
 	for (key = 1; key < end_key; key++) {
-		assert(!bpf_map_lookup(lru_map_fd, &key, value));
+		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				            BPF_NOEXIST));
 	}
@@ -336,10 +336,10 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	end_key = 1 + batch_size;
 	value[0] = 4321;
 	for (key = 1; key < end_key; key++) {
-		assert(bpf_map_lookup(lru_map_fd, &key, value));
+		assert(bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
 					    BPF_NOEXIST));
-		assert(!bpf_map_lookup(lru_map_fd, &key, value));
+		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(value[0] == 4321);
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				            BPF_NOEXIST));
@@ -418,7 +418,7 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	/* Lookup key 1 to tgt_free*3/2 */
 	end_key = tgt_free + batch_size;
 	for (key = 1; key < end_key; key++) {
-		assert(!bpf_map_lookup(lru_map_fd, &key, value));
+		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				            BPF_NOEXIST));
 	}
@@ -477,7 +477,7 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 	assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	for (key = 1; key <= tgt_free; key++) {
-		assert(!bpf_map_lookup(lru_map_fd, &key, value));
+		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 					    BPF_NOEXIST));
 	}
@@ -508,16 +508,16 @@ static void do_test_lru_sanity5(unsigned long long last_key, int map_fd)
 	unsigned long long key, value[nr_cpus];
 
 	/* Ensure the last key inserted by previous CPU can be found */
-	assert(!bpf_map_lookup(map_fd, &last_key, value));
+	assert(!bpf_map_lookup_elem(map_fd, &last_key, value));
 
 	value[0] = 1234;
 
 	key = last_key + 1;
 	assert(!bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST));
-	assert(!bpf_map_lookup(map_fd, &key, value));
+	assert(!bpf_map_lookup_elem(map_fd, &key, value));
 
 	/* Cannot find the last key because it was removed by LRU */
-	assert(bpf_map_lookup(map_fd, &last_key, value));
+	assert(bpf_map_lookup_elem(map_fd, &last_key, value));
 }
 
 /* Test map with only one element */
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index d4b9ba6d6a0e..5db1a939af69 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -55,11 +55,11 @@ static void test_hashmap(int task, void *data)
 	       errno == EINVAL);
 
 	/* Check that key=1 can be found. */
-	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == 0 && value == 1234);
 
 	key = 2;
 	/* Check that key=2 is not found. */
-	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means update existing element. */
 	assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == -1 &&
@@ -148,11 +148,11 @@ static void test_hashmap_percpu(int task, void *data)
 	 * was run from a different CPU.
 	 */
 	value[0] = 1;
-	assert(bpf_map_lookup(fd, &key, value) == 0 && value[0] == 100);
+	assert(bpf_map_lookup_elem(fd, &key, value) == 0 && value[0] == 100);
 
 	key = 2;
 	/* Check that key=2 is not found. */
-	assert(bpf_map_lookup(fd, &key, value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(fd, &key, value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means update existing element. */
 	assert(bpf_map_update_elem(fd, &key, value, BPF_EXIST) == -1 &&
@@ -179,7 +179,7 @@ static void test_hashmap_percpu(int task, void *data)
 		assert((expected_key_mask & next_key) == next_key);
 		expected_key_mask &= ~next_key;
 
-		assert(bpf_map_lookup(fd, &next_key, value) == 0);
+		assert(bpf_map_lookup_elem(fd, &next_key, value) == 0);
 
 		for (i = 0; i < nr_cpus; i++)
 			assert(value[i] == i + 100);
@@ -229,11 +229,11 @@ static void test_arraymap(int task, void *data)
 	       errno == EEXIST);
 
 	/* Check that key=1 can be found. */
-	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == 0 && value == 1234);
 
 	key = 0;
 	/* Check that key=0 is also found and zero initialized. */
-	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 0);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == 0 && value == 0);
 
 	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
 	 * due to max_entries limit.
@@ -243,7 +243,7 @@ static void test_arraymap(int task, void *data)
 	       errno == E2BIG);
 
 	/* Check that key = 2 doesn't exist. */
-	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
 	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
@@ -285,11 +285,11 @@ static void test_arraymap_percpu(int task, void *data)
 	       errno == EEXIST);
 
 	/* Check that key=1 can be found. */
-	assert(bpf_map_lookup(fd, &key, values) == 0 && values[0] == 100);
+	assert(bpf_map_lookup_elem(fd, &key, values) == 0 && values[0] == 100);
 
 	key = 0;
 	/* Check that key=0 is also found and zero initialized. */
-	assert(bpf_map_lookup(fd, &key, values) == 0 &&
+	assert(bpf_map_lookup_elem(fd, &key, values) == 0 &&
 	       values[0] == 0 && values[nr_cpus - 1] == 0);
 
 	/* Check that key=2 cannot be inserted due to max_entries limit. */
@@ -298,7 +298,7 @@ static void test_arraymap_percpu(int task, void *data)
 	       errno == E2BIG);
 
 	/* Check that key = 2 doesn't exist. */
-	assert(bpf_map_lookup(fd, &key, values) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(fd, &key, values) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
 	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
@@ -340,7 +340,7 @@ static void test_arraymap_percpu_many_keys(void)
 		for (i = 0; i < nr_cpus; i++)
 			values[i] = 0;
 
-		assert(bpf_map_lookup(fd, &key, values) == 0);
+		assert(bpf_map_lookup_elem(fd, &key, values) == 0);
 
 		for (i = 0; i < nr_cpus; i++)
 			assert(values[i] == i + 10);
@@ -384,9 +384,9 @@ static void test_map_large(void)
 	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 
 	key.c = 0;
-	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 0);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == 0 && value == 0);
 	key.a = 1;
-	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
 
 	close(fd);
 }
@@ -486,7 +486,7 @@ static void test_map_parallel(void)
 	for (i = 0; i < MAP_SIZE; i++) {
 		key = MAP_SIZE - i - 1;
 
-		assert(bpf_map_lookup(fd, &key, &value) == 0 &&
+		assert(bpf_map_lookup_elem(fd, &key, &value) == 0 &&
 		       value == key);
 	}
 
-- 
2.11.0
