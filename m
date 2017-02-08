From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v4 08/11] bpf: Use bpf_map_get_next_key() from the library
Date: Wed,  8 Feb 2017 21:49:37 +0100
Message-ID: <20170208204940.26023-9-mic@digikod.net>
References: <20170208204940.26023-1-mic@digikod.net>
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
In-Reply-To: <20170208204940.26023-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_map_next_key() with bpf_map_get_next_key() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                        |  2 +-
 tools/lib/bpf/bpf.h                        |  2 +-
 tools/testing/selftests/bpf/bpf_sys.h      | 11 ----------
 tools/testing/selftests/bpf/test_lru_map.c |  2 +-
 tools/testing/selftests/bpf/test_maps.c    | 34 +++++++++++++++---------------
 5 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index eab8c6bfbf8f..f8a2b7fa7741 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -135,7 +135,7 @@ int bpf_map_delete_elem(int fd, const void *key)
 	return sys_bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_map_get_next_key(int fd, void *key, void *next_key)
+int bpf_map_get_next_key(int fd, const void *key, void *next_key)
 {
 	union bpf_attr attr;
 
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index f559f648db45..88f07c15423a 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -38,7 +38,7 @@ int bpf_map_update_elem(int fd, const void *key, const void *value,
 
 int bpf_map_lookup_elem(int fd, const void *key, void *value);
 int bpf_map_delete_elem(int fd, const void *key);
-int bpf_map_get_next_key(int fd, void *key, void *next_key);
+int bpf_map_get_next_key(int fd, const void *key, void *next_key);
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index 17581a42e1d9..aeff99f0a411 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -24,17 +24,6 @@ static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 #endif
 }
 
-static inline int bpf_map_next_key(int fd, const void *key, void *next_key)
-{
-	union bpf_attr attr = {};
-
-	attr.map_fd = fd;
-	attr.key = bpf_ptr_to_u64(key);
-	attr.next_key = bpf_ptr_to_u64(next_key);
-
-	return bpf(BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
-}
-
 static inline int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
 				 uint32_t size_value, uint32_t max_elem,
 				 uint32_t flags)
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index d375fac1a49c..94ecd4c58d75 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -46,7 +46,7 @@ static int map_subset(int map0, int map1)
 	unsigned long long value0[nr_cpus], value1[nr_cpus];
 	int ret;
 
-	while (!bpf_map_next_key(map1, &next_key, &next_key)) {
+	while (!bpf_map_get_next_key(map1, &next_key, &next_key)) {
 		assert(!bpf_map_lookup_elem(map1, &next_key, value1));
 		ret = bpf_map_lookup_elem(map0, &next_key, value0);
 		if (ret) {
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index ae22fdc93172..c96f9c9661a0 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -88,11 +88,11 @@ static void test_hashmap(int task, void *data)
 	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
-	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
 	       (next_key == 1 || next_key == 2));
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
 	       (next_key == 1 || next_key == 2));
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* Delete both elements. */
@@ -104,7 +104,7 @@ static void test_hashmap(int task, void *data)
 
 	key = 0;
 	/* Check that map is empty. */
-	assert(bpf_map_next_key(fd, &key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	close(fd);
@@ -173,7 +173,7 @@ static void test_hashmap_percpu(int task, void *data)
 	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
-	while (!bpf_map_next_key(fd, &key, &next_key)) {
+	while (!bpf_map_get_next_key(fd, &key, &next_key)) {
 		assert((expected_key_mask & next_key) == next_key);
 		expected_key_mask &= ~next_key;
 
@@ -199,7 +199,7 @@ static void test_hashmap_percpu(int task, void *data)
 
 	key = 0;
 	/* Check that map is empty. */
-	assert(bpf_map_next_key(fd, &key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	close(fd);
@@ -244,11 +244,11 @@ static void test_arraymap(int task, void *data)
 	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
-	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
 	       next_key == 0);
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
 	       next_key == 1);
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* Delete shouldn't succeed. */
@@ -299,11 +299,11 @@ static void test_arraymap_percpu(int task, void *data)
 	assert(bpf_map_lookup_elem(fd, &key, values) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
-	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
 	       next_key == 0);
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
 	       next_key == 1);
-	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
 	/* Delete shouldn't succeed. */
@@ -378,8 +378,8 @@ static void test_map_large(void)
 
 	/* Iterate through all elements. */
 	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_map_next_key(fd, &key, &key) == 0);
-	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+		assert(bpf_map_get_next_key(fd, &key, &key) == 0);
+	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 
 	key.c = 0;
 	assert(bpf_map_lookup_elem(fd, &key, &value) == 0 && value == 0);
@@ -475,8 +475,8 @@ static void test_map_parallel(void)
 	/* Check that all elements were inserted. */
 	key = -1;
 	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_map_next_key(fd, &key, &key) == 0);
-	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+		assert(bpf_map_get_next_key(fd, &key, &key) == 0);
+	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 
 	/* Another check for all elements */
 	for (i = 0; i < MAP_SIZE; i++) {
@@ -492,7 +492,7 @@ static void test_map_parallel(void)
 
 	/* Nothing should be left. */
 	key = -1;
-	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 }
 
 static void run_all_tests(void)
-- 
2.11.0
