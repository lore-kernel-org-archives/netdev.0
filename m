From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf, maps: flush own entries on perf map release
Date: Wed, 15 Jun 2016 22:47:14 +0200
Message-ID: <ab35c46ce683f5ac48b4c4482ae4e5d5ab3fad17.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42933 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbcFOUr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:47:28 -0400
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The behavior of perf event arrays are quite different from all
others as they are tightly coupled to perf event fds, f.e. shown
recently by commit e03e7ee34fdd ("perf/bpf: Convert perf_event_array
to use struct file") to make refcounting on perf event more robust.
A remaining issue that the current code still has is that since
additions to the perf event array take a reference on the struct
file via perf_event_get() and are only released via fput() (that
cleans up the perf event eventually via perf_event_release_kernel())
when the element is either manually removed from the map from user
space or automatically when the last reference on the perf event
map is dropped. However, this leads us to dangling struct file's
when the map gets pinned after the application owning the perf
event descriptor exits, and since the struct file reference will
in such case only be manually dropped or via pinned file removal,
it leads to the perf event living longer than necessary, consuming
needlessly resources for that time.

Relations between perf event fds and bpf perf event map fds can be
rather complex. F.e. maps can act as demuxers among different perf
event fds that can possibly be owned by different threads and based
on the index selection from the program, events get dispatched to
one of the per-cpu fd endpoints. One perf event fd (or, rather a
per-cpu set of them) can also live in multiple perf event maps at
the same time, listening for events. Also, another requirement is
that perf event fds can get closed from application side after they
have been attached to the perf event map, so that on exit perf event
map will take care of dropping their references eventually. Likewise,
when such maps are pinned, the intended behavior is that a user
application does bpf_obj_get(), puts its fds in there and on exit
when fd is released, they are dropped from the map again, so the map
acts rather as connector endpoint. This also makes perf event maps
inherently different from program arrays as described in more detail
in commit c9da161c6517 ("bpf: fix clearing on persistent program
array maps").

To tackle this, map entries are marked by the map struct file that
added the element to the map. And when the last reference to that map
struct file is released from user space, then the tracked entries
are purged from the map. This is okay, because new map struct files
instances resp. frontends to the anon inode are provided via
bpf_map_new_fd() that is called when we invoke bpf_obj_get_user()
for retrieving a pinned map, but also when an initial instance is
created via map_create(). The rest is resolved by the vfs layer
automatically for us by keeping reference count on the map's struct
file. Any concurrent updates on the map slot are fine as well, it
just means that perf_event_fd_array_release() needs to delete less
of its own entires.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |   9 +++++
 kernel/bpf/arraymap.c    | 102 ++++++++++++++++++++++++++++++++++-------------
 kernel/trace/bpf_trace.c |  18 ++++-----
 3 files changed, 91 insertions(+), 38 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d7b43e7..9adfef6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -13,6 +13,7 @@
 #include <linux/percpu.h>
 #include <linux/err.h>
 
+struct perf_event;
 struct bpf_map;
 
 /* map is generic key/value storage optionally accesible by eBPF programs */
@@ -166,8 +167,16 @@ struct bpf_array {
 		void __percpu *pptrs[0] __aligned(8);
 	};
 };
+
 #define MAX_TAIL_CALL_CNT 32
 
+struct bpf_event_entry {
+	struct perf_event *event;
+	struct file *perf_file;
+	struct file *map_file;
+	struct rcu_head rcu;
+};
+
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index bfedcbd..5af3073 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -427,59 +427,105 @@ static int __init register_prog_array_map(void)
 }
 late_initcall(register_prog_array_map);
 
-static void perf_event_array_map_free(struct bpf_map *map)
+static struct bpf_event_entry *bpf_event_entry_gen(struct file *perf_file,
+						   struct file *map_file)
 {
-	bpf_fd_array_map_clear(map);
-	fd_array_map_free(map);
+	struct bpf_event_entry *ee;
+
+	ee = kzalloc(sizeof(*ee), GFP_KERNEL);
+	if (ee) {
+		ee->event = perf_file->private_data;
+		ee->perf_file = perf_file;
+		ee->map_file = map_file;
+	}
+
+	return ee;
+}
+
+static void __bpf_event_entry_free(struct rcu_head *rcu)
+{
+	struct bpf_event_entry *ee;
+
+	ee = container_of(rcu, struct bpf_event_entry, rcu);
+	fput(ee->perf_file);
+	kfree(ee);
+}
+
+static void bpf_event_entry_free_rcu(struct bpf_event_entry *ee)
+{
+	call_rcu(&ee->rcu, __bpf_event_entry_free);
 }
 
 static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 					 struct file *map_file, int fd)
 {
-	struct perf_event *event;
 	const struct perf_event_attr *attr;
-	struct file *file;
+	struct bpf_event_entry *ee;
+	struct perf_event *event;
+	struct file *perf_file;
 
-	file = perf_event_get(fd);
-	if (IS_ERR(file))
-		return file;
+	perf_file = perf_event_get(fd);
+	if (IS_ERR(perf_file))
+		return perf_file;
 
-	event = file->private_data;
+	event = perf_file->private_data;
+	ee = ERR_PTR(-EINVAL);
 
 	attr = perf_event_attrs(event);
-	if (IS_ERR(attr))
-		goto err;
-
-	if (attr->inherit)
-		goto err;
-
-	if (attr->type == PERF_TYPE_RAW)
-		return file;
-
-	if (attr->type == PERF_TYPE_HARDWARE)
-		return file;
+	if (IS_ERR(attr) || attr->inherit)
+		goto err_out;
+
+	switch (attr->type) {
+	case PERF_TYPE_SOFTWARE:
+		if (attr->config != PERF_COUNT_SW_BPF_OUTPUT)
+			goto err_out;
+		/* fall-through */
+	case PERF_TYPE_RAW:
+	case PERF_TYPE_HARDWARE:
+		ee = bpf_event_entry_gen(perf_file, map_file);
+		if (ee)
+			return ee;
+		ee = ERR_PTR(-ENOMEM);
+		/* fall-through */
+	default:
+		break;
+	}
 
-	if (attr->type == PERF_TYPE_SOFTWARE &&
-	    attr->config == PERF_COUNT_SW_BPF_OUTPUT)
-		return file;
-err:
-	fput(file);
-	return ERR_PTR(-EINVAL);
+err_out:
+	fput(perf_file);
+	return ee;
 }
 
 static void perf_event_fd_array_put_ptr(void *ptr)
 {
-	fput((struct file *)ptr);
+	bpf_event_entry_free_rcu(ptr);
+}
+
+static void perf_event_fd_array_release(struct bpf_map *map,
+					struct file *map_file)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_event_entry *ee;
+	int i;
+
+	rcu_read_lock();
+	for (i = 0; i < array->map.max_entries; i++) {
+		ee = READ_ONCE(array->ptrs[i]);
+		if (ee && ee->map_file == map_file)
+			fd_array_map_delete_elem(map, &i);
+	}
+	rcu_read_unlock();
 }
 
 static const struct bpf_map_ops perf_event_array_ops = {
 	.map_alloc = fd_array_map_alloc,
-	.map_free = perf_event_array_map_free,
+	.map_free = fd_array_map_free,
 	.map_get_next_key = array_map_get_next_key,
 	.map_lookup_elem = fd_array_map_lookup_elem,
 	.map_delete_elem = fd_array_map_delete_elem,
 	.map_fd_get_ptr = perf_event_fd_array_get_ptr,
 	.map_fd_put_ptr = perf_event_fd_array_put_ptr,
+	.map_release = perf_event_fd_array_release,
 };
 
 static struct bpf_map_type_list perf_event_array_type __read_mostly = {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 720b7bb..037ea6e 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -192,18 +192,17 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_event_entry *ee;
 	struct perf_event *event;
-	struct file *file;
 
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
-	file = READ_ONCE(array->ptrs[index]);
-	if (unlikely(!file))
+	ee = READ_ONCE(array->ptrs[index]);
+	if (unlikely(!ee))
 		return -ENOENT;
 
-	event = file->private_data;
-
+	event = ee->event;
 	/* make sure event is local and doesn't have pmu::count */
 	if (event->oncpu != smp_processor_id() ||
 	    event->pmu->count)
@@ -233,8 +232,8 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	u64 index = flags & BPF_F_INDEX_MASK;
 	void *data = (void *) (long) r4;
 	struct perf_sample_data sample_data;
+	struct bpf_event_entry *ee;
 	struct perf_event *event;
-	struct file *file;
 	struct perf_raw_record raw = {
 		.size = size,
 		.data = data,
@@ -247,12 +246,11 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
 	if (unlikely(index >= array->map.max_entries))
 		return -E2BIG;
 
-	file = READ_ONCE(array->ptrs[index]);
-	if (unlikely(!file))
+	ee = READ_ONCE(array->ptrs[index]);
+	if (unlikely(!ee))
 		return -ENOENT;
 
-	event = file->private_data;
-
+	event = ee->event;
 	if (unlikely(event->attr.type != PERF_TYPE_SOFTWARE ||
 		     event->attr.config != PERF_COUNT_SW_BPF_OUTPUT))
 		return -EINVAL;
-- 
1.9.3
