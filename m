From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] bpf: devmap: Check attr->max_entries more carefully
Date: Mon, 16 Oct 2017 00:00:20 +0200
Message-ID: <20171015220020.8157-1-richard@nod.at>
Cc: linux-kernel@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        sp3485@columbia.edu, Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

max_entries is user controlled and used as input for __alloc_percpu().
This function expects that the allocation size is a power of two and
less than PCPU_MIN_UNIT_SIZE.
Otherwise a WARN() is triggered.

Fixes: 11393cc9b9be ("xdp: Add batching support to redirect map")
Reported-by: Shankara Pailoor <sp3485@columbia.edu>
Reported-by: syzkaller <syzkaller@googlegroups.com>
Signed-off-by: Richard Weinberger <richard@nod.at>
---
 kernel/bpf/devmap.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index e093d9a2c4dd..6ce00083103b 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -49,6 +49,7 @@
  */
 #include <linux/bpf.h>
 #include <linux/filter.h>
+#include <linux/log2.h>
 
 struct bpf_dtab_netdev {
 	struct net_device *dev;
@@ -77,6 +78,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	struct bpf_dtab *dtab;
 	int err = -EINVAL;
 	u64 cost;
+	size_t palloc_size;
 
 	/* check sanity of attributes */
 	if (attr->max_entries == 0 || attr->key_size != 4 ||
@@ -95,9 +97,14 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	dtab->map.map_flags = attr->map_flags;
 	dtab->map.numa_node = bpf_map_attr_numa_node(attr);
 
+	palloc_size = roundup_pow_of_two(dev_map_bitmap_size(attr));
+	if (palloc_size > PCPU_MIN_UNIT_SIZE ||
+	    palloc_size < dev_map_bitmap_size(attr))
+		return ERR_PTR(-EINVAL);
+
 	/* make sure page count doesn't overflow */
 	cost = (u64) dtab->map.max_entries * sizeof(struct bpf_dtab_netdev *);
-	cost += dev_map_bitmap_size(attr) * num_possible_cpus();
+	cost += palloc_size * num_possible_cpus();
 	if (cost >= U32_MAX - PAGE_SIZE)
 		goto free_dtab;
 
@@ -111,7 +118,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	err = -ENOMEM;
 
 	/* A per cpu bitfield with a bit per possible net device */
-	dtab->flush_needed = __alloc_percpu(dev_map_bitmap_size(attr),
+	dtab->flush_needed = __alloc_percpu(palloc_size,
 					    __alignof__(unsigned long));
 	if (!dtab->flush_needed)
 		goto free_dtab;
-- 
2.13.6
