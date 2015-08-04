From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH v6 1/4] bpf: Make the bpf_prog_array_map more generic
Date: Tue, 4 Aug 2015 08:58:13 +0000
Message-ID: <1438678696-88289-2-git-send-email-xiakaixu@huawei.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Nan <wangnan0@huawei.com>

All the map backends are of generic nature. In order to avoid
adding much special code into the eBPF core, rewrite part of
the bpf_prog_array map code and make it more generic. So the
new perf_event_array map type can reuse most of code with
bpf_prog_array map and add fewer lines of special code.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 arch/x86/net/bpf_jit_comp.c |  6 ++--
 include/linux/bpf.h         |  8 +++--
 kernel/bpf/arraymap.c       | 80 +++++++++++++++++++++++++++------------------
 kernel/bpf/core.c           |  2 +-
 kernel/bpf/syscall.c        |  2 +-
 5 files changed, 60 insertions(+), 38 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 579a8fd..e377f07 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -246,7 +246,7 @@ static void emit_prologue(u8 **pprog)
  *     goto out;
  *   if (++tail_call_cnt > MAX_TAIL_CALL_CNT)
  *     goto out;
- *   prog = array->prog[index];
+ *   prog = array->ptrs[index];
  *   if (prog == NULL)
  *     goto out;
  *   goto *(prog->bpf_func + prologue_size);
@@ -284,9 +284,9 @@ static void emit_bpf_tail_call(u8 **pprog)
 	EMIT3(0x83, 0xC0, 0x01);                  /* add eax, 1 */
 	EMIT2_off32(0x89, 0x85, -STACKSIZE + 36); /* mov dword ptr [rbp - 516], eax */
 
-	/* prog = array->prog[index]; */
+	/* prog = array->ptrs[index]; */
 	EMIT4(0x48, 0x8D, 0x44, 0xD6);            /* lea rax, [rsi + rdx * 8 + 0x50] */
-	EMIT1(offsetof(struct bpf_array, prog));
+	EMIT1(offsetof(struct bpf_array, ptrs));
 	EMIT3(0x48, 0x8B, 0x00);                  /* mov rax, qword ptr [rax] */
 
 	/* if (prog == NULL)
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4383476..a8ce262 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -24,6 +24,10 @@ struct bpf_map_ops {
 	void *(*map_lookup_elem)(struct bpf_map *map, void *key);
 	int (*map_update_elem)(struct bpf_map *map, void *key, void *value, u64 flags);
 	int (*map_delete_elem)(struct bpf_map *map, void *key);
+
+	/* funcs called by prog_array and perf_event_array map */
+	void *(*map_fd_get_ptr) (struct bpf_map *map, int fd);
+	void (*map_fd_put_ptr) (void *ptr);
 };
 
 struct bpf_map {
@@ -142,13 +146,13 @@ struct bpf_array {
 	bool owner_jited;
 	union {
 		char value[0] __aligned(8);
-		struct bpf_prog *prog[0] __aligned(8);
+		void *ptrs[0] __aligned(8);
 	};
 };
 #define MAX_TAIL_CALL_CNT 32
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
-void bpf_prog_array_map_clear(struct bpf_map *map);
+void bpf_fd_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index cb31229..45df657 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -150,15 +150,15 @@ static int __init register_array_map(void)
 }
 late_initcall(register_array_map);
 
-static struct bpf_map *prog_array_map_alloc(union bpf_attr *attr)
+static struct bpf_map *fd_array_map_alloc(union bpf_attr *attr)
 {
-	/* only bpf_prog file descriptors can be stored in prog_array map */
+	/* only file descriptors can be stored in this type of map */
 	if (attr->value_size != sizeof(u32))
 		return ERR_PTR(-EINVAL);
 	return array_map_alloc(attr);
 }
 
-static void prog_array_map_free(struct bpf_map *map)
+static void fd_array_map_free(struct bpf_map *map)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	int i;
@@ -167,21 +167,21 @@ static void prog_array_map_free(struct bpf_map *map)
 
 	/* make sure it's empty */
 	for (i = 0; i < array->map.max_entries; i++)
-		BUG_ON(array->prog[i] != NULL);
+		BUG_ON(array->ptrs[i] != NULL);
 	kvfree(array);
 }
 
-static void *prog_array_map_lookup_elem(struct bpf_map *map, void *key)
+static void *fd_array_map_lookup_elem(struct bpf_map *map, void *key)
 {
 	return NULL;
 }
 
 /* only called from syscall */
-static int prog_array_map_update_elem(struct bpf_map *map, void *key,
-				      void *value, u64 map_flags)
+static int fd_array_map_update_elem(struct bpf_map *map, void *key,
+				    void *value, u64 map_flags)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
-	struct bpf_prog *prog, *old_prog;
+	void *new_ptr, *old_ptr;
 	u32 index = *(u32 *)key, ufd;
 
 	if (map_flags != BPF_ANY)
@@ -191,57 +191,75 @@ static int prog_array_map_update_elem(struct bpf_map *map, void *key,
 		return -E2BIG;
 
 	ufd = *(u32 *)value;
-	prog = bpf_prog_get(ufd);
-	if (IS_ERR(prog))
-		return PTR_ERR(prog);
-
-	if (!bpf_prog_array_compatible(array, prog)) {
-		bpf_prog_put(prog);
-		return -EINVAL;
-	}
+	new_ptr = map->ops->map_fd_get_ptr(map, ufd);
+	if (IS_ERR(new_ptr))
+		return PTR_ERR(new_ptr);
 
-	old_prog = xchg(array->prog + index, prog);
-	if (old_prog)
-		bpf_prog_put_rcu(old_prog);
+	old_ptr = xchg(array->ptrs + index, new_ptr);
+	if (old_ptr)
+		map->ops->map_fd_put_ptr(old_ptr);
 
 	return 0;
 }
 
-static int prog_array_map_delete_elem(struct bpf_map *map, void *key)
+static int fd_array_map_delete_elem(struct bpf_map *map, void *key)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
-	struct bpf_prog *old_prog;
+	void *old_ptr;
 	u32 index = *(u32 *)key;
 
 	if (index >= array->map.max_entries)
 		return -E2BIG;
 
-	old_prog = xchg(array->prog + index, NULL);
-	if (old_prog) {
-		bpf_prog_put_rcu(old_prog);
+	old_ptr = xchg(array->ptrs + index, NULL);
+	if (old_ptr) {
+		map->ops->map_fd_put_ptr(old_ptr);
 		return 0;
 	} else {
 		return -ENOENT;
 	}
 }
 
+static void *prog_fd_array_get_ptr(struct bpf_map *map, int fd)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_prog *prog = bpf_prog_get(fd);
+	if (IS_ERR(prog))
+		return prog;
+
+	if (!bpf_prog_array_compatible(array, prog)) {
+		bpf_prog_put(prog);
+		return ERR_PTR(-EINVAL);
+	}
+	return prog;
+}
+
+static void prog_fd_array_put_ptr(void *ptr)
+{
+	struct bpf_prog *prog = ptr;
+
+	bpf_prog_put_rcu(prog);
+}
+
 /* decrement refcnt of all bpf_progs that are stored in this map */
-void bpf_prog_array_map_clear(struct bpf_map *map)
+void bpf_fd_array_map_clear(struct bpf_map *map)
 {
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	int i;
 
 	for (i = 0; i < array->map.max_entries; i++)
-		prog_array_map_delete_elem(map, &i);
+		fd_array_map_delete_elem(map, &i);
 }
 
 static const struct bpf_map_ops prog_array_ops = {
-	.map_alloc = prog_array_map_alloc,
-	.map_free = prog_array_map_free,
+	.map_alloc = fd_array_map_alloc,
+	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
-	.map_lookup_elem = prog_array_map_lookup_elem,
-	.map_update_elem = prog_array_map_update_elem,
-	.map_delete_elem = prog_array_map_delete_elem,
+	.map_lookup_elem = fd_array_map_lookup_elem,
+	.map_update_elem = fd_array_map_update_elem,
+	.map_delete_elem = fd_array_map_delete_elem,
+	.map_fd_get_ptr = prog_fd_array_get_ptr,
+	.map_fd_put_ptr = prog_fd_array_put_ptr,
 };
 
 static struct bpf_map_type_list prog_array_type __read_mostly = {
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index c5bedc8..be848d0 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -449,7 +449,7 @@ select_insn:
 
 		tail_call_cnt++;
 
-		prog = READ_ONCE(array->prog[index]);
+		prog = READ_ONCE(array->ptrs[index]);
 		if (unlikely(!prog))
 			goto out;
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index a1b14d1..dc9b464 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -72,7 +72,7 @@ static int bpf_map_release(struct inode *inode, struct file *filp)
 		/* prog_array stores refcnt-ed bpf_prog pointers
 		 * release them all when user space closes prog_array_fd
 		 */
-		bpf_prog_array_map_clear(map);
+		bpf_fd_array_map_clear(map);
 
 	bpf_map_put(map);
 	return 0;
-- 
1.8.3.4
