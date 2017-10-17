From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/3] bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations
Date: Tue, 17 Oct 2017 16:55:54 +0200
Message-ID: <a11e92b8ba4f5270437caa629307c300bca37976.1508251210.git.daniel@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net>
Cc: tj@kernel.org, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
References: <cover.1508251210.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PCPU_MIN_UNIT_SIZE is an implementation detail of the percpu
allocator. Given we support __GFP_NOWARN now, lets just let
the allocation request fail naturally instead. The two call
sites from BPF mistakenly assumed __GFP_NOWARN would work, so
no changes needed to their actual __alloc_percpu_gfp() calls
which use the flag already.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/arraymap.c | 2 +-
 kernel/bpf/hashtab.c  | 4 ----
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 98c0f00..e263673 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -98,7 +98,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	array_size += (u64) attr->max_entries * elem_size * num_possible_cpus();
 
 	if (array_size >= U32_MAX - PAGE_SIZE ||
-	    elem_size > PCPU_MIN_UNIT_SIZE || bpf_array_alloc_percpu(array)) {
+	    bpf_array_alloc_percpu(array)) {
 		bpf_map_area_free(array);
 		return ERR_PTR(-ENOMEM);
 	}
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 431126f..6533f08 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -317,10 +317,6 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	if (percpu && round_up(htab->map.value_size, 8) > PCPU_MIN_UNIT_SIZE)
-		/* make sure the size for pcpu_alloc() is reasonable */
-		goto free_htab;
-
 	htab->elem_size = sizeof(struct htab_elem) +
 			  round_up(htab->map.key_size, 8);
 	if (percpu)
-- 
1.9.3
