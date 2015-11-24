From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix clearing on persistent program array maps
Date: Tue, 24 Nov 2015 21:28:15 +0100
Message-ID: <92a1259fbea681022425a2e03c0efda95d183632.1448396272.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45361 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816AbbKXU2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 15:28:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when having map file descriptors pointing to program arrays,
there's still the issue that we unconditionally flush program array
contents via bpf_fd_array_map_clear() in bpf_map_release(). This happens
when such a file descriptor is released and is independent of the map's
refcount.

Having this flush independent of the refcount is for a reason: there
can be arbitrary complex dependency chains among tail calls, also circular
ones (direct or indirect, nesting limit determined during runtime), and
we need to make sure that the map drops all references to eBPF programs
it holds, so that the map's refcount can eventually drop to zero and
initiate its freeing. Btw, a walk of the whole dependency graph would
not be possible for various reasons, one being complexity and another
one inconsistency, i.e. new programs can be added to parts of the graph
at any time, so there's no guaranteed consistent state for the time of
such a walk.

Now, the program array pinning itself works, but the issue is that each
derived file descriptor on close would nevertheless call unconditionally
into bpf_fd_array_map_clear(). Instead, keep track of users and postpone
this flush until the last reference to a user is dropped. As this only
concerns a subset of references (f.e. a prog array could hold a program
that itself has reference on the prog array holding it, etc), we need to
track them separately.

Short analysis on the refcounting: on map creation time usercnt will be
one, so there's no change in behaviour for bpf_map_release(), if unpinned.
If we already fail in map_create(), we are immediately freed, and no
file descriptor has been made public yet. In bpf_obj_pin_user(), we need
to probe for a possible map in bpf_fd_probe_obj() already with a usercnt
reference, so before we drop the reference on the fd with fdput().
Therefore, if actual pinning fails, we need to drop that reference again
in bpf_any_put(), otherwise we keep holding it. When last reference
drops on the inode, the bpf_any_put() in bpf_evict_inode() will take
care of dropping the usercnt again. In the bpf_obj_get_user() case, the
bpf_any_get() will grab a reference on the usercnt, still at a time when
we have the reference on the path. Should we later on fail to grab a new
file descriptor, bpf_any_put() will drop it, otherwise we hold it until
bpf_map_release() time.

Joint work with Alexei.

Fixes: b2197755b263 ("bpf: add support for persistent maps/progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   |  5 ++++-
 kernel/bpf/inode.c    |  6 +++---
 kernel/bpf/syscall.c  | 36 +++++++++++++++++++++++++-----------
 kernel/bpf/verifier.c |  3 +--
 4 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index de464e6..83d1926 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -40,6 +40,7 @@ struct bpf_map {
 	struct user_struct *user;
 	const struct bpf_map_ops *ops;
 	struct work_struct work;
+	atomic_t usercnt;
 };
 
 struct bpf_map_type_list {
@@ -167,8 +168,10 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 void bpf_prog_put(struct bpf_prog *prog);
 void bpf_prog_put_rcu(struct bpf_prog *prog);
 
-struct bpf_map *bpf_map_get(u32 ufd);
+struct bpf_map *bpf_map_get_with_uref(u32 ufd);
 struct bpf_map *__bpf_map_get(struct fd f);
+void bpf_map_inc(struct bpf_map *map, bool uref);
+void bpf_map_put_with_uref(struct bpf_map *map);
 void bpf_map_put(struct bpf_map *map);
 
 extern int sysctl_unprivileged_bpf_disabled;
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index be6d726..5a8a797 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -34,7 +34,7 @@ static void *bpf_any_get(void *raw, enum bpf_type type)
 		atomic_inc(&((struct bpf_prog *)raw)->aux->refcnt);
 		break;
 	case BPF_TYPE_MAP:
-		atomic_inc(&((struct bpf_map *)raw)->refcnt);
+		bpf_map_inc(raw, true);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -51,7 +51,7 @@ static void bpf_any_put(void *raw, enum bpf_type type)
 		bpf_prog_put(raw);
 		break;
 	case BPF_TYPE_MAP:
-		bpf_map_put(raw);
+		bpf_map_put_with_uref(raw);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -64,7 +64,7 @@ static void *bpf_fd_probe_obj(u32 ufd, enum bpf_type *type)
 	void *raw;
 
 	*type = BPF_TYPE_MAP;
-	raw = bpf_map_get(ufd);
+	raw = bpf_map_get_with_uref(ufd);
 	if (IS_ERR(raw)) {
 		*type = BPF_TYPE_PROG;
 		raw = bpf_prog_get(ufd);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 0d3313d..4a8f3c1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -82,6 +82,14 @@ static void bpf_map_free_deferred(struct work_struct *work)
 	map->ops->map_free(map);
 }
 
+static void bpf_map_put_uref(struct bpf_map *map)
+{
+	if (atomic_dec_and_test(&map->usercnt)) {
+		if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY)
+			bpf_fd_array_map_clear(map);
+	}
+}
+
 /* decrement map refcnt and schedule it for freeing via workqueue
  * (unrelying map implementation ops->map_free() might sleep)
  */
@@ -93,17 +101,15 @@ void bpf_map_put(struct bpf_map *map)
 	}
 }
 
-static int bpf_map_release(struct inode *inode, struct file *filp)
+void bpf_map_put_with_uref(struct bpf_map *map)
 {
-	struct bpf_map *map = filp->private_data;
-
-	if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY)
-		/* prog_array stores refcnt-ed bpf_prog pointers
-		 * release them all when user space closes prog_array_fd
-		 */
-		bpf_fd_array_map_clear(map);
-
+	bpf_map_put_uref(map);
 	bpf_map_put(map);
+}
+
+static int bpf_map_release(struct inode *inode, struct file *filp)
+{
+	bpf_map_put_with_uref(filp->private_data);
 	return 0;
 }
 
@@ -142,6 +148,7 @@ static int map_create(union bpf_attr *attr)
 		return PTR_ERR(map);
 
 	atomic_set(&map->refcnt, 1);
+	atomic_set(&map->usercnt, 1);
 
 	err = bpf_map_charge_memlock(map);
 	if (err)
@@ -174,7 +181,14 @@ struct bpf_map *__bpf_map_get(struct fd f)
 	return f.file->private_data;
 }
 
-struct bpf_map *bpf_map_get(u32 ufd)
+void bpf_map_inc(struct bpf_map *map, bool uref)
+{
+	atomic_inc(&map->refcnt);
+	if (uref)
+		atomic_inc(&map->usercnt);
+}
+
+struct bpf_map *bpf_map_get_with_uref(u32 ufd)
 {
 	struct fd f = fdget(ufd);
 	struct bpf_map *map;
@@ -183,7 +197,7 @@ struct bpf_map *bpf_map_get(u32 ufd)
 	if (IS_ERR(map))
 		return map;
 
-	atomic_inc(&map->refcnt);
+	bpf_map_inc(map, true);
 	fdput(f);
 
 	return map;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c607305..a7945d1 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2021,8 +2021,7 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 			 * will be used by the valid program until it's unloaded
 			 * and all maps are released in free_bpf_prog_info()
 			 */
-			atomic_inc(&map->refcnt);
-
+			bpf_map_inc(map, false);
 			fdput(f);
 next_insn:
 			insn++;
-- 
1.9.3
