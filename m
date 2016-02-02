From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/6] bpf: introduce BPF_MAP_TYPE_PERCPU_ARRAY map
Date: Mon, 1 Feb 2016 22:39:54 -0800
Message-ID: <1454395198-1796236-3-git-send-email-ast@fb.com>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:13927 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752254AbcBBGkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:02 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126YMmq030906
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 20thrrs5s6-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:02 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c8012c8cc97711e59ab524be05956610-68ab56b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:40:00 -0800
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Primary use case is a histogram array of latency
where bpf program computes the latency of block requests or other
events and stores histogram of latency into array of 64 elements.
All cpus are constantly running, so normal increment is not accurate,
bpf_xadd causes cache ping-pong and this per-cpu approach allows
fastest collision-free counters.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |   1 +
 include/uapi/linux/bpf.h |   1 +
 kernel/bpf/arraymap.c    | 102 ++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 93 insertions(+), 11 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 83d1926c61e4..141fb0d45731 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -151,6 +151,7 @@ struct bpf_array {
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
+		void __percpu *pptrs[0] __aligned(8);
 	};
 };
 #define MAX_TAIL_CALL_CNT 32
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 43ae40c8763e..2ee0fde1bf96 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -82,6 +82,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_PROG_ARRAY,
 	BPF_MAP_TYPE_PERF_EVENT_ARRAY,
 	BPF_MAP_TYPE_PERCPU_HASH,
+	BPF_MAP_TYPE_PERCPU_ARRAY,
 };
 
 enum bpf_prog_type {
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 89ebbc4d1164..b9bf1d7949ca 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -17,11 +17,39 @@
 #include <linux/filter.h>
 #include <linux/perf_event.h>
 
+static void bpf_array_free_percpu(struct bpf_array *array)
+{
+	int i;
+
+	for (i = 0; i < array->map.max_entries; i++)
+		free_percpu(array->pptrs[i]);
+}
+
+static int bpf_array_alloc_percpu(struct bpf_array *array)
+{
+	void __percpu *ptr;
+	int i;
+
+	for (i = 0; i < array->map.max_entries; i++) {
+		ptr = __alloc_percpu_gfp(array->elem_size, 8,
+					 GFP_USER | __GFP_NOWARN);
+		if (!ptr) {
+			bpf_array_free_percpu(array);
+			return -ENOMEM;
+		}
+		array->pptrs[i] = ptr;
+	}
+
+	return 0;
+}
+
 /* Called from syscall */
 static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 {
+	bool percpu = attr->map_type == BPF_MAP_TYPE_PERCPU_ARRAY;
 	struct bpf_array *array;
-	u32 elem_size, array_size;
+	u64 array_size;
+	u32 elem_size;
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
@@ -36,12 +64,16 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	elem_size = round_up(attr->value_size, 8);
 
-	/* check round_up into zero and u32 overflow */
-	if (elem_size == 0 ||
-	    attr->max_entries > (U32_MAX - PAGE_SIZE - sizeof(*array)) / elem_size)
+	array_size = sizeof(*array);
+	if (percpu)
+		array_size += (u64) attr->max_entries * sizeof(void *);
+	else
+		array_size += (u64) attr->max_entries * elem_size;
+
+	/* make sure there is no u32 overflow later in round_up() */
+	if (array_size >= U32_MAX - PAGE_SIZE)
 		return ERR_PTR(-ENOMEM);
 
-	array_size = sizeof(*array) + attr->max_entries * elem_size;
 
 	/* allocate all map elements and zero-initialize them */
 	array = kzalloc(array_size, GFP_USER | __GFP_NOWARN);
@@ -52,12 +84,25 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	}
 
 	/* copy mandatory map attributes */
+	array->map.map_type = attr->map_type;
 	array->map.key_size = attr->key_size;
 	array->map.value_size = attr->value_size;
 	array->map.max_entries = attr->max_entries;
-	array->map.pages = round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
 	array->elem_size = elem_size;
 
+	if (!percpu)
+		goto out;
+
+	array_size += (u64) attr->max_entries * elem_size * num_possible_cpus();
+
+	if (array_size >= U32_MAX - PAGE_SIZE ||
+	    elem_size > PCPU_MIN_UNIT_SIZE || bpf_array_alloc_percpu(array)) {
+		kvfree(array);
+		return ERR_PTR(-ENOMEM);
+	}
+out:
+	array->map.pages = round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
+
 	return &array->map;
 }
 
@@ -67,12 +112,24 @@ static void *array_map_lookup_elem(struct bpf_map *map, void *key)
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	u32 index = *(u32 *)key;
 
-	if (index >= array->map.max_entries)
+	if (unlikely(index >= array->map.max_entries))
 		return NULL;
 
 	return array->value + array->elem_size * index;
 }
 
+/* Called from eBPF program */
+static void *percpu_array_map_lookup_elem(struct bpf_map *map, void *key)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	u32 index = *(u32 *)key;
+
+	if (unlikely(index >= array->map.max_entries))
+		return NULL;
+
+	return this_cpu_ptr(array->pptrs[index]);
+}
+
 /* Called from syscall */
 static int array_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 {
@@ -99,19 +156,24 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	u32 index = *(u32 *)key;
 
-	if (map_flags > BPF_EXIST)
+	if (unlikely(map_flags > BPF_EXIST))
 		/* unknown flags */
 		return -EINVAL;
 
-	if (index >= array->map.max_entries)
+	if (unlikely(index >= array->map.max_entries))
 		/* all elements were pre-allocated, cannot insert a new one */
 		return -E2BIG;
 
-	if (map_flags == BPF_NOEXIST)
+	if (unlikely(map_flags == BPF_NOEXIST))
 		/* all elements already exist */
 		return -EEXIST;
 
-	memcpy(array->value + array->elem_size * index, value, map->value_size);
+	if (array->map.map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
+		memcpy(this_cpu_ptr(array->pptrs[index]),
+		       value, map->value_size);
+	else
+		memcpy(array->value + array->elem_size * index,
+		       value, map->value_size);
 	return 0;
 }
 
@@ -133,6 +195,9 @@ static void array_map_free(struct bpf_map *map)
 	 */
 	synchronize_rcu();
 
+	if (array->map.map_type == BPF_MAP_TYPE_PERCPU_ARRAY)
+		bpf_array_free_percpu(array);
+
 	kvfree(array);
 }
 
@@ -150,9 +215,24 @@ static struct bpf_map_type_list array_type __read_mostly = {
 	.type = BPF_MAP_TYPE_ARRAY,
 };
 
+static const struct bpf_map_ops percpu_array_ops = {
+	.map_alloc = array_map_alloc,
+	.map_free = array_map_free,
+	.map_get_next_key = array_map_get_next_key,
+	.map_lookup_elem = percpu_array_map_lookup_elem,
+	.map_update_elem = array_map_update_elem,
+	.map_delete_elem = array_map_delete_elem,
+};
+
+static struct bpf_map_type_list percpu_array_type __read_mostly = {
+	.ops = &percpu_array_ops,
+	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
+};
+
 static int __init register_array_map(void)
 {
 	bpf_register_map_type(&array_type);
+	bpf_register_map_type(&percpu_array_type);
 	return 0;
 }
 late_initcall(register_array_map);
-- 
2.4.6
