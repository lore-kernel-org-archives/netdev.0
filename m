From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v3 07/11] bpf: Use bpf_map_delete_elem() from the library
Date: Tue,  7 Feb 2017 22:44:56 +0100
Message-ID: <20170207214500.27496-8-mic@digikod.net>
References: <20170207214500.27496-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207214500.27496-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_map_delete() with bpf_map_delete_elem() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                        |  5 ++---
 tools/lib/bpf/bpf.h                        |  2 +-
 tools/testing/selftests/bpf/bpf_sys.h      | 10 ----------
 tools/testing/selftests/bpf/test_lru_map.c |  6 +++---
 tools/testing/selftests/bpf/test_maps.c    | 22 +++++++++++-----------
 5 files changed, 17 insertions(+), 28 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 81505801fa33..ee3a87de15ba 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -121,11 +121,10 @@ int bpf_map_lookup_elem(int fd, const void *key, void *value)
 	return sys_bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_map_delete_elem(int fd, void *key)
+int bpf_map_delete_elem(int fd, const void *key)
 {
-	union bpf_attr attr;
+	union bpf_attr attr = {};
 
-	bzero(&attr, sizeof(attr));
 	attr.map_fd = fd;
 	attr.key = ptr_to_u64(key);
 
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 171cf594f782..f559f648db45 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -37,7 +37,7 @@ int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
 
 int bpf_map_lookup_elem(int fd, const void *key, void *value);
-int bpf_map_delete_elem(int fd, void *key);
+int bpf_map_delete_elem(int fd, const void *key);
 int bpf_map_get_next_key(int fd, void *key, void *next_key);
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index 0a5a6060db70..17581a42e1d9 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -24,16 +24,6 @@ static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 #endif
 }
 
-static inline int bpf_map_delete(int fd, const void *key)
-{
-	union bpf_attr attr = {};
-
-	attr.map_fd = fd;
-	attr.key = bpf_ptr_to_u64(key);
-
-	return bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
-}
-
 static inline int bpf_map_next_key(int fd, const void *key, void *next_key)
 {
 	union bpf_attr attr = {};
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 53155009bdb6..d375fac1a49c 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -318,7 +318,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	key = 1;
 	if (map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH) {
 		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
-		assert(!bpf_map_delete(lru_map_fd, &key));
+		assert(!bpf_map_delete_elem(lru_map_fd, &key));
 	} else {
 		assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_EXIST));
 	}
@@ -470,8 +470,8 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 	}
 
 	for (; key <= 2 * tgt_free; key++) {
-		assert(!bpf_map_delete(lru_map_fd, &key));
-		assert(bpf_map_delete(lru_map_fd, &key));
+		assert(!bpf_map_delete_elem(lru_map_fd, &key));
+		assert(bpf_map_delete_elem(lru_map_fd, &key));
 	}
 
 	end_key = key + 2 * tgt_free;
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index c73a1fbc5bcc..ae22fdc93172 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -85,7 +85,7 @@ static void test_hashmap(int task, void *data)
 
 	/* Check that key = 0 doesn't exist. */
 	key = 0;
-	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
 	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
@@ -97,10 +97,10 @@ static void test_hashmap(int task, void *data)
 
 	/* Delete both elements. */
 	key = 1;
-	assert(bpf_map_delete(fd, &key) == 0);
+	assert(bpf_map_delete_elem(fd, &key) == 0);
 	key = 2;
-	assert(bpf_map_delete(fd, &key) == 0);
-	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(fd, &key) == 0);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	key = 0;
 	/* Check that map is empty. */
@@ -170,7 +170,7 @@ static void test_hashmap_percpu(int task, void *data)
 	       errno == E2BIG);
 
 	/* Check that key = 0 doesn't exist. */
-	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
 	while (!bpf_map_next_key(fd, &key, &next_key)) {
@@ -192,10 +192,10 @@ static void test_hashmap_percpu(int task, void *data)
 
 	/* Delete both elements. */
 	key = 1;
-	assert(bpf_map_delete(fd, &key) == 0);
+	assert(bpf_map_delete_elem(fd, &key) == 0);
 	key = 2;
-	assert(bpf_map_delete(fd, &key) == 0);
-	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+	assert(bpf_map_delete_elem(fd, &key) == 0);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	key = 0;
 	/* Check that map is empty. */
@@ -253,7 +253,7 @@ static void test_arraymap(int task, void *data)
 
 	/* Delete shouldn't succeed. */
 	key = 1;
-	assert(bpf_map_delete(fd, &key) == -1 && errno == EINVAL);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == EINVAL);
 
 	close(fd);
 }
@@ -308,7 +308,7 @@ static void test_arraymap_percpu(int task, void *data)
 
 	/* Delete shouldn't succeed. */
 	key = 1;
-	assert(bpf_map_delete(fd, &key) == -1 && errno == EINVAL);
+	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == EINVAL);
 
 	close(fd);
 }
@@ -441,7 +441,7 @@ static void do_work(int fn, void *data)
 			assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == 0);
 			assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == 0);
 		} else {
-			assert(bpf_map_delete(fd, &key) == 0);
+			assert(bpf_map_delete_elem(fd, &key) == 0);
 		}
 	}
 }
-- 
2.11.0
