From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] bpf: do not use KMALLOC_SHIFT_MAX
Date: Tue, 20 Dec 2016 14:06:59 +0100
Message-ID: <20161220130659.16461-3-mhocko@kernel.org>
References: <20161220130659.16461-1-mhocko@kernel.org>
Cc: Cristopher Lameter <cl@linux.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	netdev@vger.kernel.org,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161220130659.16461-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

01b3f52157ff ("bpf: fix allocation warnings in bpf maps and integer
overflow") has added checks for the maximum allocateable size. It
(ab)used KMALLOC_SHIFT_MAX for that purpose. While this is not incorrect
it is not very clean because we already have KMALLOC_MAX_SIZE for this
very reason so let's change both checks to use KMALLOC_MAX_SIZE instead.

The original motivation for using KMALLOC_SHIFT_MAX was to work around
an incorrect KMALLOC_MAX_SIZE which could lead to allocation warnings
but it is no longer needed since "slab: make sure that KMALLOC_MAX_SIZE
will fit into MAX_ORDER".

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 kernel/bpf/arraymap.c | 2 +-
 kernel/bpf/hashtab.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index a2ac051c342f..229a5d5df977 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -56,7 +56,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	    attr->value_size == 0 || attr->map_flags)
 		return ERR_PTR(-EINVAL);
 
-	if (attr->value_size >= 1 << (KMALLOC_SHIFT_MAX - 1))
+	if (attr->value_size > KMALLOC_MAX_SIZE)
 		/* if value_size is bigger, the user space won't be able to
 		 * access the elements.
 		 */
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index ad1bc67aff1b..c5ec7dc71c84 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -181,7 +181,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		 */
 		goto free_htab;
 
-	if (htab->map.value_size >= (1 << (KMALLOC_SHIFT_MAX - 1)) -
+	if (htab->map.value_size >= KMALLOC_MAX_SIZE -
 	    MAX_BPF_STACK - sizeof(struct htab_elem))
 		/* if value_size is bigger, the user space won't be able to
 		 * access the elements via bpf syscall. This check also makes
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
