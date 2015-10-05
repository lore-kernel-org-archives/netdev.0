From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] bpf: charge user for creation of BPF maps and programs
Date: Mon,  5 Oct 2015 13:48:21 -0700
Message-ID: <1444078101-29060-3-git-send-email-ast@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

since eBPF programs and maps use kernel memory consider it 'locked' memory
from user accounting point of view and charge it against RLIMIT_MEMLOCK limit.
This limit is typically set to 64Kbytes by distros, so almost all
bpf+tracing programs would need to increase it, since they use maps,
but kernel charges maximum map size upfront.
For example the hash map of 1024 elements will be charged as 64Kbyte.
It's inconvenient for current users and changes current behavior for root,
but probably worth doing to be consistent root vs non-root.

Similar accounting logic is done by mmap of perf_event.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
The charging is agressive and even basic test_maps, test_verifier are
hitting memlock limit, so alternatively we can drop charging
for cap_sys_admin.
---
 include/linux/bpf.h   |    3 +++
 include/linux/sched.h |    2 +-
 kernel/bpf/arraymap.c |    2 +-
 kernel/bpf/hashtab.c  |    4 ++++
 kernel/bpf/syscall.c  |   63 +++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index acf97d66b681..740906f8684a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -37,6 +37,8 @@ struct bpf_map {
 	u32 key_size;
 	u32 value_size;
 	u32 max_entries;
+	u32 pages;
+	struct user_struct *user;
 	const struct bpf_map_ops *ops;
 	struct work_struct work;
 };
@@ -130,6 +132,7 @@ struct bpf_prog_aux {
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
+	struct user_struct *user;
 	union {
 		struct work_struct work;
 		struct rcu_head	rcu;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b7b9501b41af..4817df5fffae 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -840,7 +840,7 @@ struct user_struct {
 	struct hlist_node uidhash_node;
 	kuid_t uid;
 
-#ifdef CONFIG_PERF_EVENTS
+#if defined(CONFIG_PERF_EVENTS) || defined(CONFIG_BPF_SYSCALL)
 	atomic_long_t locked_vm;
 #endif
 };
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 29ace107f236..d9061730a26c 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -48,7 +48,7 @@ static struct bpf_map *array_map_alloc(union bpf_attr *attr)
 	array->map.key_size = attr->key_size;
 	array->map.value_size = attr->value_size;
 	array->map.max_entries = attr->max_entries;
-
+	array->map.pages = round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
 	array->elem_size = elem_size;
 
 	return &array->map;
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 83c209d9b17a..28592d79502b 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -88,6 +88,10 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 	htab->elem_size = sizeof(struct htab_elem) +
 			  round_up(htab->map.key_size, 8) +
 			  htab->map.value_size;
+
+	htab->map.pages = round_up(htab->n_buckets * sizeof(struct hlist_head) +
+				   htab->elem_size * htab->map.max_entries,
+				   PAGE_SIZE) >> PAGE_SHIFT;
 	return &htab->map;
 
 free_htab:
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 9a2098da2da9..5d65c40486a1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -46,11 +46,38 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
 	list_add(&tl->list_node, &bpf_map_types);
 }
 
+static int bpf_map_charge_memlock(struct bpf_map *map)
+{
+	struct user_struct *user = get_current_user();
+	unsigned long memlock_limit;
+
+	memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+
+	atomic_long_add(map->pages, &user->locked_vm);
+
+	if (atomic_long_read(&user->locked_vm) > memlock_limit) {
+		atomic_long_sub(map->pages, &user->locked_vm);
+		free_uid(user);
+		return -EPERM;
+	}
+	map->user = user;
+	return 0;
+}
+
+static void bpf_map_uncharge_memlock(struct bpf_map *map)
+{
+	struct user_struct *user = map->user;
+
+	atomic_long_sub(map->pages, &user->locked_vm);
+	free_uid(user);
+}
+
 /* called from workqueue */
 static void bpf_map_free_deferred(struct work_struct *work)
 {
 	struct bpf_map *map = container_of(work, struct bpf_map, work);
 
+	bpf_map_uncharge_memlock(map);
 	/* implementation dependent freeing */
 	map->ops->map_free(map);
 }
@@ -110,6 +137,10 @@ static int map_create(union bpf_attr *attr)
 
 	atomic_set(&map->refcnt, 1);
 
+	err = bpf_map_charge_memlock(map);
+	if (err)
+		goto free_map;
+
 	err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
 
 	if (err < 0)
@@ -440,11 +471,37 @@ static void free_used_maps(struct bpf_prog_aux *aux)
 	kfree(aux->used_maps);
 }
 
+static int bpf_prog_charge_memlock(struct bpf_prog *prog)
+{
+	struct user_struct *user = get_current_user();
+	unsigned long memlock_limit;
+
+	memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+
+	atomic_long_add(prog->pages, &user->locked_vm);
+	if (atomic_long_read(&user->locked_vm) > memlock_limit) {
+		atomic_long_sub(prog->pages, &user->locked_vm);
+		free_uid(user);
+		return -EPERM;
+	}
+	prog->aux->user = user;
+	return 0;
+}
+
+static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
+{
+	struct user_struct *user = prog->aux->user;
+
+	atomic_long_sub(prog->pages, &user->locked_vm);
+	free_uid(user);
+}
+
 static void __prog_put_rcu(struct rcu_head *rcu)
 {
 	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
 
 	free_used_maps(aux);
+	bpf_prog_uncharge_memlock(aux->prog);
 	bpf_prog_free(aux->prog);
 }
 
@@ -552,6 +609,10 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (!prog)
 		return -ENOMEM;
 
+	err = bpf_prog_charge_memlock(prog);
+	if (err)
+		goto free_prog_nouncharge;
+
 	prog->len = attr->insn_cnt;
 
 	err = -EFAULT;
@@ -593,6 +654,8 @@ static int bpf_prog_load(union bpf_attr *attr)
 free_used_maps:
 	free_used_maps(prog->aux);
 free_prog:
+	bpf_prog_uncharge_memlock(prog);
+free_prog_nouncharge:
 	bpf_prog_free(prog);
 	return err;
 }
-- 
1.7.9.5
