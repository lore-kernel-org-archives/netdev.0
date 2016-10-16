From: William Tu <u9012063@gmail.com>
Subject: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to user.
Date: Sun, 16 Oct 2016 09:41:28 -0700
Message-ID: <1476636088-9268-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36782 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbcJPQlk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 12:41:40 -0400
Received: by mail-pf0-f193.google.com with SMTP id r16so11120039pfg.3
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 09:41:39 -0700 (PDT)
Received: from vm-dev.localdomain ([76.126.157.223])
        by smtp.gmail.com with ESMTPSA id u10sm41822757pau.32.2016.10.16.09.41.37
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 09:41:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running bpf_map_lookup on percpu elements, the bytes copied to
userspace depends on num_possible_cpus() * value_size, which could
potentially be larger than memory allocated from user, which depends
on sysconf(_SC_NPROCESSORS_CONF) to get the current cpu num.  As a
result, the inconsistency might corrupt the user's stack.

The fact that sysconf(_SC_NPROCESSORS_CONF) != num_possible_cpu()
happens when cpu hotadd is enabled.  For example, in Fusion when
setting vcpu.hotadd = "TRUE" or in KVM, setting
  ./qemu-system-x86_64 -smp 2, maxcpus=4 ...
the num_possible_cpu() will be 4 and sysconf() will be 2[1].
Currently the any percpu map lookup suffers this issue, try
samples/bpf/test_maps.c or tracex3.c.

Th RFC patch adds additional 'size' param from userspace so that
kernel knows the maximum memory it should copy to the user.

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg121183.html

Signed-off-by: William Tu <u9012063@gmail.com>
---
 include/uapi/linux/bpf.h       |  5 ++++-
 kernel/bpf/syscall.c           |  5 +++--
 samples/bpf/fds_example.c      |  2 +-
 samples/bpf/libbpf.c           |  3 ++-
 samples/bpf/libbpf.h           |  2 +-
 samples/bpf/test_maps.c        | 30 +++++++++++++++---------------
 tools/include/uapi/linux/bpf.h |  5 ++++-
 7 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f09c70b..fa0c40b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -123,7 +123,10 @@ union bpf_attr {
 			__aligned_u64 value;
 			__aligned_u64 next_key;
 		};
-		__u64		flags;
+		union {
+			__u64		flags;
+			__u32		size; /* number of bytes allocated in userspace */
+		};
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_LOAD command */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..be211ea 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -264,13 +264,14 @@ int __weak bpf_stackmap_copy(struct bpf_map *map, void *key, void *value)
 }
 
 /* last field in 'union bpf_attr' used by this command */
-#define BPF_MAP_LOOKUP_ELEM_LAST_FIELD value
+#define BPF_MAP_LOOKUP_ELEM_LAST_FIELD size
 
 static int map_lookup_elem(union bpf_attr *attr)
 {
 	void __user *ukey = u64_to_ptr(attr->key);
 	void __user *uvalue = u64_to_ptr(attr->value);
 	int ufd = attr->map_fd;
+	u32 usize = attr->size;
 	struct bpf_map *map;
 	void *key, *value, *ptr;
 	u32 value_size;
@@ -324,7 +325,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 		goto free_value;
 
 	err = -EFAULT;
-	if (copy_to_user(uvalue, value, value_size) != 0)
+	if (copy_to_user(uvalue, value, min_t(u32, usize, value_size)) != 0)
 		goto free_value;
 
 	err = 0;
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 625e797..5b833d8 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -88,7 +88,7 @@ static int bpf_do_map(const char *file, uint32_t flags, uint32_t key,
 		       ret, strerror(errno));
 		assert(ret == 0);
 	} else if (flags & BPF_F_KEY) {
-		ret = bpf_lookup_elem(fd, &key, &value);
+		ret = bpf_lookup_elem(fd, &key, &value, sizeof(value));
 		printf("bpf: fd:%d l->(%u):%u ret:(%d,%s)\n", fd, key, value,
 		       ret, strerror(errno));
 		assert(ret == 0);
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 9969e35..9f0a1c3 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -44,12 +44,13 @@ int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
 	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_lookup_elem(int fd, void *key, void *value)
+int bpf_lookup_elem(int fd, void *key, void *value, int size)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
 		.key = ptr_to_u64(key),
 		.value = ptr_to_u64(value),
+		.size = size,
 	};
 
 	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index ac6edb6..b911185 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -7,7 +7,7 @@ struct bpf_insn;
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, int map_flags);
 int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_lookup_elem(int fd, void *key, void *value, int size);
 int bpf_delete_elem(int fd, void *key);
 int bpf_get_next_key(int fd, void *key, void *next_key);
 
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index cce2b59..a6a8fbe 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -47,11 +47,11 @@ static void test_hashmap_sanity(int i, void *data)
 	assert(bpf_update_elem(map_fd, &key, &value, -1) == -1 && errno == EINVAL);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == 0 && value == 1234);
 
 	key = 2;
 	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
 	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
@@ -139,11 +139,11 @@ static void test_percpu_hashmap_sanity(int task, void *data)
 	 * was run from a different cpu.
 	 */
 	value[0] = 1;
-	assert(bpf_lookup_elem(map_fd, &key, value) == 0 && value[0] == 100);
+	assert(bpf_lookup_elem(map_fd, &key, value, sizeof(value)) == 0 && value[0] == 100);
 
 	key = 2;
 	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, value) == -1 && errno == ENOENT);
+	assert(bpf_lookup_elem(map_fd, &key, value, sizeof(value)) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
 	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == -1 &&
@@ -170,7 +170,7 @@ static void test_percpu_hashmap_sanity(int task, void *data)
 		assert((expected_key_mask & next_key) == next_key);
 		expected_key_mask &= ~next_key;
 
-		assert(bpf_lookup_elem(map_fd, &next_key, value) == 0);
+		assert(bpf_lookup_elem(map_fd, &next_key, value, sizeof(value)) == 0);
 		for (i = 0; i < nr_cpus; i++)
 			assert(value[i] == i + 100);
 
@@ -218,11 +218,11 @@ static void test_arraymap_sanity(int i, void *data)
 	       errno == EEXIST);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == 0 && value == 1234);
 
 	key = 0;
 	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == 0 && value == 0);
 
 
 	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
@@ -233,7 +233,7 @@ static void test_arraymap_sanity(int i, void *data)
 	       errno == E2BIG);
 
 	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
 	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
@@ -274,7 +274,7 @@ static void test_percpu_arraymap_many_keys(void)
 	for (key = 0; key < nr_keys; key++) {
 		for (i = 0; i < nr_cpus; i++)
 			values[i] = 0;
-		assert(bpf_lookup_elem(map_fd, &key, values) == 0);
+		assert(bpf_lookup_elem(map_fd, &key, values, sizeof(values)) == 0);
 		for (i = 0; i < nr_cpus; i++)
 			assert(values[i] == i + 10);
 	}
@@ -307,11 +307,11 @@ static void test_percpu_arraymap_sanity(int i, void *data)
 	       errno == EEXIST);
 
 	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 && values[0] == 100);
+	assert(bpf_lookup_elem(map_fd, &key, values, sizeof(values)) == 0 && values[0] == 100);
 
 	key = 0;
 	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
+	assert(bpf_lookup_elem(map_fd, &key, values, sizeof(values)) == 0 &&
 	       values[0] == 0 && values[nr_cpus - 1] == 0);
 
 
@@ -321,7 +321,7 @@ static void test_percpu_arraymap_sanity(int i, void *data)
 	       errno == E2BIG);
 
 	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, values) == -1 && errno == ENOENT);
+	assert(bpf_lookup_elem(map_fd, &key, values, sizeof(values)) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
 	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
@@ -371,9 +371,9 @@ static void test_map_large(void)
 	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
 
 	key.c = 0;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == 0 && value == 0);
 	key.a = 1;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+	assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == -1 && errno == ENOENT);
 
 	close(map_fd);
 }
@@ -466,7 +466,7 @@ static void test_map_parallel(void)
 	/* another check for all elements */
 	for (i = 0; i < MAP_SIZE; i++) {
 		key = MAP_SIZE - i - 1;
-		assert(bpf_lookup_elem(map_fd, &key, &value) == 0 &&
+		assert(bpf_lookup_elem(map_fd, &key, &value, sizeof(value)) == 0 &&
 		       value == key);
 	}
 
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 9e5fc16..719fa25 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -122,7 +122,10 @@ union bpf_attr {
 			__aligned_u64 value;
 			__aligned_u64 next_key;
 		};
-		__u64		flags;
+		union {
+			__u64		flags;
+			__u32		size; /* number of bytes allocated in userspace */
+		};
 	};
 
 	struct { /* anonymous struct used by BPF_PROG_LOAD command */
-- 
2.5.0
