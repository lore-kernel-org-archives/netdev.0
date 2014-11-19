From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: fix arraymap NULL deref and missing overflow and zero size checks
Date: Tue, 18 Nov 2014 17:32:16 -0800
Message-ID: <1416360736-9531-1-git-send-email-ast@plumgrid.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- fix NULL pointer dereference:
kernel/bpf/arraymap.c:41 array_map_alloc() error: potential null dereference 'array'.  (kzalloc returns null)
kernel/bpf/arraymap.c:41 array_map_alloc() error: we previously assumed 'array' could be null (see line 40)

- integer overflow check was missing in arraymap
(hashmap checks for overflow via kmalloc_array())

- arraymap can round_up(value_size, 8) to zero. check was missing.

- hashmap was missing zero size check as well, since roundup_pow_of_two() can
truncate into zero

- found a typo in the arraymap comment and unnecessary empty line

Fix all of these issues and make both overflow checks explicit U32 in size.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
This silly NULL deref bug and missing overflow check was an oversight when
I refactored the code from two allocations (kmalloc for struct bpf_array and
kcalloc for array of elements) in the first implementation of arraymap
into one allocation which is this code.

 kernel/bpf/arraymap.c |   17 +++++++++++------
 kernel/bpf/hashtab.c  |    5 +++++
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 58b80c137afd..9eb4d8a7cd87 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -25,7 +25,7 @@ struct bpf_array {
 static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 {
 	struct bpf_array *array;
-	u32 elem_size;
+	u32 elem_size, array_size;
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
@@ -34,11 +34,17 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 
 	elem_size = round_up(attr->value_size, 8);
 
+	/* check round_up into zero and u32 overflow */
+	if (elem_size == 0 ||
+	    attr->max_entries > (U32_MAX - sizeof(*array)) / elem_size)
+		return ERR_PTR(-ENOMEM);
+
+	array_size = sizeof(*array) + attr->max_entries * elem_size;
+
 	/* allocate all map elements and zero-initialize them */
-	array = kzalloc(sizeof(*array) + attr->max_entries * elem_size,
-			GFP_USER | __GFP_NOWARN);
+	array = kzalloc(array_size, GFP_USER | __GFP_NOWARN);
 	if (!array) {
-		array = vzalloc(array->map.max_entries * array->elem_size);
+		array = vzalloc(array_size);
 		if (!array)
 			return ERR_PTR(-ENOMEM);
 	}
@@ -51,7 +57,6 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	array->elem_size = elem_size;
 
 	return &array->map;
-
 }
 
 /* Called from syscall or from eBPF program */
@@ -101,7 +106,7 @@ static int array_map_update_elem(struct bpf_map *map, void *key, void *value,
 		return -E2BIG;
 
 	if (map_flags == BPF_NOEXIST)
-		/* all elemenets already exist */
+		/* all elements already exist */
 		return -EEXIST;
 
 	memcpy(array->value + array->elem_size * index, value, array->elem_size);
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index d234a012f046..b3ba43674310 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -65,6 +65,11 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		goto free_htab;
 
 	err = -ENOMEM;
+	/* prevent zero size kmalloc and check for u32 overflow */
+	if (htab->n_buckets == 0 ||
+	    htab->n_buckets > U32_MAX / sizeof(struct hlist_head))
+		goto free_htab;
+
 	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct hlist_head),
 				      GFP_USER | __GFP_NOWARN);
 
-- 
1.7.9.5
