From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v5 09/11] bpf: Use bpf_create_map() from the library
Date: Fri, 10 Feb 2017 00:21:43 +0100
Message-ID: <20170209232145.19085-10-mic@digikod.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:54051 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752787AbdBIXXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 18:23:30 -0500
In-Reply-To: <20170209232145.19085-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace bpf_map_create() with bpf_create_map() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/testing/selftests/bpf/bpf_sys.h       | 15 ---------------
 tools/testing/selftests/bpf/test_lpm_map.c  |  6 +++---
 tools/testing/selftests/bpf/test_lru_map.c  |  4 ++--
 tools/testing/selftests/bpf/test_maps.c     | 14 +++++++-------
 tools/testing/selftests/bpf/test_tag.c      |  2 +-
 tools/testing/selftests/bpf/test_verifier.c |  4 ++--
 6 files changed, 15 insertions(+), 30 deletions(-)

diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index aeff99f0a411..aa076a8a07f7 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -24,19 +24,4 @@ static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 #endif
 }
 
-static inline int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
-				 uint32_t size_value, uint32_t max_elem,
-				 uint32_t flags)
-{
-	union bpf_attr attr = {};
-
-	attr.map_type = type;
-	attr.key_size = size_key;
-	attr.value_size = size_value;
-	attr.max_entries = max_elem;
-	attr.map_flags = flags;
-
-	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
-}
-
 #endif /* __BPF_SYS__ */
diff --git a/tools/testing/selftests/bpf/test_lpm_map.c b/tools/testing/selftests/bpf/test_lpm_map.c
index bd08394c26cb..3cc812cac2d7 100644
--- a/tools/testing/selftests/bpf/test_lpm_map.c
+++ b/tools/testing/selftests/bpf/test_lpm_map.c
@@ -183,7 +183,7 @@ static void test_lpm_map(int keysize)
 	key = alloca(sizeof(*key) + keysize);
 	memset(key, 0, sizeof(*key) + keysize);
 
-	map = bpf_map_create(BPF_MAP_TYPE_LPM_TRIE,
+	map = bpf_create_map(BPF_MAP_TYPE_LPM_TRIE,
 			     sizeof(*key) + keysize,
 			     keysize + 1,
 			     4096,
@@ -253,12 +253,12 @@ static void test_lpm_ipaddr(void)
 	key_ipv4 = alloca(key_size_ipv4);
 	key_ipv6 = alloca(key_size_ipv6);
 
-	map_fd_ipv4 = bpf_map_create(BPF_MAP_TYPE_LPM_TRIE,
+	map_fd_ipv4 = bpf_create_map(BPF_MAP_TYPE_LPM_TRIE,
 				     key_size_ipv4, sizeof(value),
 				     100, BPF_F_NO_PREALLOC);
 	assert(map_fd_ipv4 >= 0);
 
-	map_fd_ipv6 = bpf_map_create(BPF_MAP_TYPE_LPM_TRIE,
+	map_fd_ipv6 = bpf_create_map(BPF_MAP_TYPE_LPM_TRIE,
 				     key_size_ipv6, sizeof(value),
 				     100, BPF_F_NO_PREALLOC);
 	assert(map_fd_ipv6 >= 0);
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 360f7e006eb6..48973ded1c96 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -31,11 +31,11 @@ static int create_map(int map_type, int map_flags, unsigned int size)
 {
 	int map_fd;
 
-	map_fd = bpf_map_create(map_type, sizeof(unsigned long long),
+	map_fd = bpf_create_map(map_type, sizeof(unsigned long long),
 				sizeof(unsigned long long), size, map_flags);
 
 	if (map_fd == -1)
-		perror("bpf_map_create");
+		perror("bpf_create_map");
 
 	return map_fd;
 }
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index be52c808d6cf..39168499f43f 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -32,7 +32,7 @@ static void test_hashmap(int task, void *data)
 	long long key, next_key, value;
 	int fd;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    2, map_flags);
 	if (fd < 0) {
 		printf("Failed to create hashmap '%s'!\n", strerror(errno));
@@ -119,7 +119,7 @@ static void test_hashmap_percpu(int task, void *data)
 	int expected_key_mask = 0;
 	int fd, i;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
+	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
 			    sizeof(value[0]), 2, map_flags);
 	if (fd < 0) {
 		printf("Failed to create hashmap '%s'!\n", strerror(errno));
@@ -212,7 +212,7 @@ static void test_arraymap(int task, void *data)
 	int key, next_key, fd;
 	long long value;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
+	fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
 			    2, 0);
 	if (fd < 0) {
 		printf("Failed to create arraymap '%s'!\n", strerror(errno));
@@ -266,7 +266,7 @@ static void test_arraymap_percpu(int task, void *data)
 	int key, next_key, fd, i;
 	long values[nr_cpus];
 
-	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
 			    sizeof(values[0]), 2, 0);
 	if (fd < 0) {
 		printf("Failed to create arraymap '%s'!\n", strerror(errno));
@@ -322,7 +322,7 @@ static void test_arraymap_percpu_many_keys(void)
 	long values[nr_cpus];
 	int key, fd, i;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
 			    sizeof(values[0]), nr_keys, 0);
 	if (fd < 0) {
 		printf("Failed to create per-cpu arraymap '%s'!\n",
@@ -360,7 +360,7 @@ static void test_map_large(void)
 	} key;
 	int fd, i, value;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags);
 	if (fd < 0) {
 		printf("Failed to create large map '%s'!\n", strerror(errno));
@@ -455,7 +455,7 @@ static void test_map_parallel(void)
 	int i, fd, key = 0, value = 0;
 	int data[2];
 
-	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
 			    MAP_SIZE, map_flags);
 	if (fd < 0) {
 		printf("Failed to create map for parallel test '%s'!\n",
diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
index dc209721ffd5..ae4263638cd5 100644
--- a/tools/testing/selftests/bpf/test_tag.c
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -189,7 +189,7 @@ int main(void)
 	int i, fd_map;
 
 	setrlimit(RLIMIT_MEMLOCK, &rinf);
-	fd_map = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(int),
+	fd_map = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(int),
 				sizeof(int), 1, BPF_F_NO_PREALLOC);
 	assert(fd_map > 0);
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 247830ecf68e..63818cbb9fb1 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -4467,7 +4467,7 @@ static int create_map(uint32_t size_value, uint32_t max_elem)
 {
 	int fd;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(long long),
+	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(long long),
 			    size_value, max_elem, BPF_F_NO_PREALLOC);
 	if (fd < 0)
 		printf("Failed to create hash map '%s'!\n", strerror(errno));
@@ -4479,7 +4479,7 @@ static int create_prog_array(void)
 {
 	int fd;
 
-	fd = bpf_map_create(BPF_MAP_TYPE_PROG_ARRAY, sizeof(int),
+	fd = bpf_create_map(BPF_MAP_TYPE_PROG_ARRAY, sizeof(int),
 			    sizeof(int), 4, 0);
 	if (fd < 0)
 		printf("Failed to create prog array '%s'!\n", strerror(errno));
-- 
2.11.0
