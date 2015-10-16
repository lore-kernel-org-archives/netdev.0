From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] bpf: align and clean bpf_{map,prog}_get helpers
Date: Fri, 16 Oct 2015 03:09:23 +0200
Message-ID: <e257aebd713873eae8e49d6691b8568815c5152a.1444956943.git.daniel@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	tgraf@suug.ch, hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1444956943.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444956943.git.daniel@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a bpf_map_get() function that we're going to use later on and
align/clean the remaining helpers a bit so that we have them a bit
more consistent:

  - __bpf_map_get() and __bpf_prog_get() that both work on the fd
    struct, check whether the descriptor is eBPF and return the
    pointer to the map/prog stored in the private data.

    Also, we can return f.file->private_data directly, the function
    signature is enough of a documentation already.

  - bpf_map_get() and bpf_prog_get() that both work on u32 user fd,
    call their respective __bpf_map_get()/__bpf_prog_get() variants,
    and take a reference.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   |  2 +-
 kernel/bpf/syscall.c  | 41 +++++++++++++++++++++++------------------
 kernel/bpf/verifier.c |  3 +--
 3 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index e3a51b7..0ae6f77 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -167,7 +167,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd);
 void bpf_prog_put(struct bpf_prog *prog);
 void bpf_prog_put_rcu(struct bpf_prog *prog);
 
-struct bpf_map *bpf_map_get(struct fd f);
+struct bpf_map *__bpf_map_get(struct fd f);
 void bpf_map_put(struct bpf_map *map);
 
 extern int sysctl_unprivileged_bpf_disabled;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2b89ef0..3fff82c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -162,19 +162,29 @@ free_map:
 /* if error is returned, fd is released.
  * On success caller should complete fd access with matching fdput()
  */
-struct bpf_map *bpf_map_get(struct fd f)
+struct bpf_map *__bpf_map_get(struct fd f)
 {
-	struct bpf_map *map;
-
 	if (!f.file)
 		return ERR_PTR(-EBADF);
-
 	if (f.file->f_op != &bpf_map_fops) {
 		fdput(f);
 		return ERR_PTR(-EINVAL);
 	}
 
-	map = f.file->private_data;
+	return f.file->private_data;
+}
+
+static struct bpf_map *bpf_map_get(u32 ufd)
+{
+	struct fd f = fdget(ufd);
+	struct bpf_map *map;
+
+	map = __bpf_map_get(f);
+	if (IS_ERR(map))
+		return map;
+
+	atomic_inc(&map->refcnt);
+	fdput(f);
 
 	return map;
 }
@@ -202,7 +212,7 @@ static int map_lookup_elem(union bpf_attr *attr)
 		return -EINVAL;
 
 	f = fdget(ufd);
-	map = bpf_map_get(f);
+	map = __bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
@@ -261,7 +271,7 @@ static int map_update_elem(union bpf_attr *attr)
 		return -EINVAL;
 
 	f = fdget(ufd);
-	map = bpf_map_get(f);
+	map = __bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
@@ -314,7 +324,7 @@ static int map_delete_elem(union bpf_attr *attr)
 		return -EINVAL;
 
 	f = fdget(ufd);
-	map = bpf_map_get(f);
+	map = __bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
@@ -355,7 +365,7 @@ static int map_get_next_key(union bpf_attr *attr)
 		return -EINVAL;
 
 	f = fdget(ufd);
-	map = bpf_map_get(f);
+	map = __bpf_map_get(f);
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
@@ -549,21 +559,16 @@ static int bpf_prog_new_fd(struct bpf_prog *prog)
 				O_RDWR | O_CLOEXEC);
 }
 
-static struct bpf_prog *get_prog(struct fd f)
+static struct bpf_prog *__bpf_prog_get(struct fd f)
 {
-	struct bpf_prog *prog;
-
 	if (!f.file)
 		return ERR_PTR(-EBADF);
-
 	if (f.file->f_op != &bpf_prog_fops) {
 		fdput(f);
 		return ERR_PTR(-EINVAL);
 	}
 
-	prog = f.file->private_data;
-
-	return prog;
+	return f.file->private_data;
 }
 
 /* called by sockets/tracing/seccomp before attaching program to an event
@@ -574,13 +579,13 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 	struct fd f = fdget(ufd);
 	struct bpf_prog *prog;
 
-	prog = get_prog(f);
-
+	prog = __bpf_prog_get(f);
 	if (IS_ERR(prog))
 		return prog;
 
 	atomic_inc(&prog->aux->refcnt);
 	fdput(f);
+
 	return prog;
 }
 EXPORT_SYMBOL_GPL(bpf_prog_get);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1d6b97b..735999a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1988,8 +1988,7 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 			}
 
 			f = fdget(insn->imm);
-
-			map = bpf_map_get(f);
+			map = __bpf_map_get(f);
 			if (IS_ERR(map)) {
 				verbose("fd %d is not pointing to valid bpf_map\n",
 					insn->imm);
-- 
1.9.3
