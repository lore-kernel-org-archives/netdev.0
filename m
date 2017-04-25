From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: map_get_next_key to return first key on NULL
Date: Mon, 24 Apr 2017 19:00:37 -0700
Message-ID: <20170425020037.1114047-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Teng Qin <qinteng@fb.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40132 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S979859AbdDYCAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 22:00:42 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3P1xaLT031422
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 19:00:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a1tdwrm24-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 19:00:41 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 fa97fb14295a11e7b2c824be05904660-bc7f39a0 for <netdev@vger.kernel.org>;        Mon,
 24 Apr 2017 19:00:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Teng Qin <qinteng@fb.com>

When iterating through a map, we need to find a key that does not exist
in the map so map_get_next_key will give us the first key of the map.
This often requires a lot of guessing in production systems.

This patch makes map_get_next_key return the first key when the key
pointer in the parameter is NULL.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/trace/events/bpf.h              | 10 +++++++---
 kernel/bpf/arraymap.c                   |  2 +-
 kernel/bpf/hashtab.c                    |  9 +++++----
 kernel/bpf/syscall.c                    | 20 ++++++++++++--------
 tools/testing/selftests/bpf/test_maps.c | 29 +++++++++++++++++++++++++----
 5 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/include/trace/events/bpf.h b/include/trace/events/bpf.h
index c3a53fd47ff1..52c8425d144b 100644
--- a/include/trace/events/bpf.h
+++ b/include/trace/events/bpf.h
@@ -321,11 +321,14 @@ TRACE_EVENT(bpf_map_next_key,
 		__dynamic_array(u8, key, map->key_size)
 		__dynamic_array(u8, nxt, map->key_size)
 		__field(bool, key_trunc)
+		__field(bool, key_null)
 		__field(int, ufd)
 	),
 
 	TP_fast_assign(
-		memcpy(__get_dynamic_array(key), key, map->key_size);
+		if (key)
+			memcpy(__get_dynamic_array(key), key, map->key_size);
+		__entry->key_null = !key;
 		memcpy(__get_dynamic_array(nxt), key_next, map->key_size);
 		__entry->type      = map->map_type;
 		__entry->key_len   = min(map->key_size, 16U);
@@ -336,8 +339,9 @@ TRACE_EVENT(bpf_map_next_key,
 	TP_printk("map type=%s ufd=%d key=[%s%s] next=[%s%s]",
 		  __print_symbolic(__entry->type, __MAP_TYPE_SYM_TAB),
 		  __entry->ufd,
-		  __print_hex(__get_dynamic_array(key), __entry->key_len),
-		  __entry->key_trunc ? " ..." : "",
+		  __entry->key_null ? "NULL" : __print_hex(__get_dynamic_array(key),
+							   __entry->key_len),
+		  __entry->key_trunc && !__entry->key_null ? " ..." : "",
 		  __print_hex(__get_dynamic_array(nxt), __entry->key_len),
 		  __entry->key_trunc ? " ..." : "")
 );
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index ec621df5a97a..5e00b2333c26 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -182,7 +182,7 @@ int bpf_percpu_array_copy(struct bpf_map *map, void *key, void *value)
 static int array_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
-	u32 index = *(u32 *)key;
+	u32 index = key ? *(u32 *)key : U32_MAX;
 	u32 *next = (u32 *)next_key;
 
 	if (index >= array->map.max_entries) {
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index bc80c038e430..004334ea13ba 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -540,12 +540,15 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	struct hlist_nulls_head *head;
 	struct htab_elem *l, *next_l;
 	u32 hash, key_size;
-	int i;
+	int i = 0;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
 	key_size = map->key_size;
 
+	if (!key)
+		goto find_first_elem;
+
 	hash = htab_map_hash(key, key_size);
 
 	head = select_bucket(htab, hash);
@@ -553,10 +556,8 @@ static int htab_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	/* lookup the key */
 	l = lookup_nulls_elem_raw(head, hash, key, key_size, htab->n_buckets);
 
-	if (!l) {
-		i = 0;
+	if (!l)
 		goto find_first_elem;
-	}
 
 	/* key was found, get next key in the same bucket */
 	next_l = hlist_nulls_entry_safe(rcu_dereference_raw(hlist_nulls_next_rcu(&l->hash_node)),
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index b89288e2b589..13642c73dca0 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -536,14 +536,18 @@ static int map_get_next_key(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
-	err = -ENOMEM;
-	key = kmalloc(map->key_size, GFP_USER);
-	if (!key)
-		goto err_put;
-
-	err = -EFAULT;
-	if (copy_from_user(key, ukey, map->key_size) != 0)
-		goto free_key;
+	if (ukey) {
+		err = -ENOMEM;
+		key = kmalloc(map->key_size, GFP_USER);
+		if (!key)
+			goto err_put;
+
+		err = -EFAULT;
+		if (copy_from_user(key, ukey, map->key_size) != 0)
+			goto free_key;
+	} else {
+		key = NULL;
+	}
 
 	err = -ENOMEM;
 	next_key = kmalloc(map->key_size, GFP_USER);
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 20f1871874df..a977c4f7b0ce 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -28,7 +28,7 @@ static int map_flags;
 
 static void test_hashmap(int task, void *data)
 {
-	long long key, next_key, value;
+	long long key, next_key, first_key, value;
 	int fd;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
@@ -89,10 +89,13 @@ static void test_hashmap(int task, void *data)
 	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
+	assert(bpf_map_get_next_key(fd, NULL, &first_key) == 0 &&
+	       (first_key == 1 || first_key == 2));
 	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
-	       (next_key == 1 || next_key == 2));
+	       (next_key == first_key));
 	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
-	       (next_key == 1 || next_key == 2));
+	       (next_key == 1 || next_key == 2) &&
+	       (next_key != first_key));
 	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == -1 &&
 	       errno == ENOENT);
 
@@ -105,6 +108,8 @@ static void test_hashmap(int task, void *data)
 
 	key = 0;
 	/* Check that map is empty. */
+	assert(bpf_map_get_next_key(fd, NULL, &next_key) == -1 &&
+	       errno == ENOENT);
 	assert(bpf_map_get_next_key(fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 
@@ -133,7 +138,7 @@ static void test_hashmap_percpu(int task, void *data)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
 	long long value[nr_cpus];
-	long long key, next_key;
+	long long key, next_key, first_key;
 	int expected_key_mask = 0;
 	int fd, i;
 
@@ -193,7 +198,13 @@ static void test_hashmap_percpu(int task, void *data)
 	assert(bpf_map_delete_elem(fd, &key) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
+	assert(bpf_map_get_next_key(fd, NULL, &first_key) == 0 &&
+	       ((expected_key_mask & first_key) == first_key));
 	while (!bpf_map_get_next_key(fd, &key, &next_key)) {
+		if (first_key) {
+			assert(next_key == first_key);
+			first_key = 0;
+		}
 		assert((expected_key_mask & next_key) == next_key);
 		expected_key_mask &= ~next_key;
 
@@ -219,6 +230,8 @@ static void test_hashmap_percpu(int task, void *data)
 
 	key = 0;
 	/* Check that map is empty. */
+	assert(bpf_map_get_next_key(fd, NULL, &next_key) == -1 &&
+	       errno == ENOENT);
 	assert(bpf_map_get_next_key(fd, &key, &next_key) == -1 &&
 	       errno == ENOENT);
 
@@ -264,6 +277,8 @@ static void test_arraymap(int task, void *data)
 	assert(bpf_map_lookup_elem(fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
+	assert(bpf_map_get_next_key(fd, NULL, &next_key) == 0 &&
+	       next_key == 0);
 	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
 	       next_key == 0);
 	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
@@ -319,6 +334,8 @@ static void test_arraymap_percpu(int task, void *data)
 	assert(bpf_map_lookup_elem(fd, &key, values) == -1 && errno == ENOENT);
 
 	/* Iterate over two elements. */
+	assert(bpf_map_get_next_key(fd, NULL, &next_key) == 0 &&
+	       next_key == 0);
 	assert(bpf_map_get_next_key(fd, &key, &next_key) == 0 &&
 	       next_key == 0);
 	assert(bpf_map_get_next_key(fd, &next_key, &next_key) == 0 &&
@@ -400,6 +417,8 @@ static void test_map_large(void)
 	       errno == E2BIG);
 
 	/* Iterate through all elements. */
+	assert(bpf_map_get_next_key(fd, NULL, &key) == 0);
+	key.c = -1;
 	for (i = 0; i < MAP_SIZE; i++)
 		assert(bpf_map_get_next_key(fd, &key, &key) == 0);
 	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
@@ -499,6 +518,7 @@ static void test_map_parallel(void)
 	       errno == EEXIST);
 
 	/* Check that all elements were inserted. */
+	assert(bpf_map_get_next_key(fd, NULL, &key) == 0);
 	key = -1;
 	for (i = 0; i < MAP_SIZE; i++)
 		assert(bpf_map_get_next_key(fd, &key, &key) == 0);
@@ -518,6 +538,7 @@ static void test_map_parallel(void)
 
 	/* Nothing should be left. */
 	key = -1;
+	assert(bpf_map_get_next_key(fd, NULL, &key) == -1 && errno == ENOENT);
 	assert(bpf_map_get_next_key(fd, &key, &key) == -1 && errno == ENOENT);
 }
 
-- 
2.9.3
