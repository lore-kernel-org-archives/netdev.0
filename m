From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 2/3] bpf: fix overflow in prog accounting
Date: Sun, 18 Dec 2016 01:52:58 +0100
Message-ID: <d7c46fc4e8647bc903a4c21e7193c580ab3e3a40.1482019225.git.daniel@iogearbox.net>
References: <cover.1482019225.git.daniel@iogearbox.net>
Cc: ast@fb.com, kafai@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60744 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753896AbcLRAxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 19:53:16 -0500
In-Reply-To: <cover.1482019225.git.daniel@iogearbox.net>
In-Reply-To: <cover.1482019225.git.daniel@iogearbox.net>
References: <cover.1482019225.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit aaac3ba95e4c ("bpf: charge user for creation of BPF maps and
programs") made a wrong assumption of charging against prog->pages.
Unlike map->pages, prog->pages are still subject to change when we
need to expand the program through bpf_prog_realloc().

This can for example happen during verification stage when we need to
expand and rewrite parts of the program. Should the required space
cross a page boundary, then prog->pages is not the same anymore as
its original value that we used to bpf_prog_charge_memlock() on. Thus,
we'll hit a wrap-around during bpf_prog_uncharge_memlock() when prog
is freed eventually. I noticed this that despite having unlimited
memlock, programs suddenly refused to load with EPERM error due to
insufficient memlock.

There are two ways to fix this issue. One would be to add a cached
variable to struct bpf_prog that takes a snapshot of prog->pages at the
time of charging. The other approach is to also account for resizes. I
chose to go with the latter for a couple of reasons: i) We want accounting
rather to be more accurate instead of further fooling limits, ii) adding
yet another page counter on struct bpf_prog would also be a waste just
for this purpose. We also do want to charge as early as possible to
avoid going into the verifier just to find out later on that we crossed
limits. The only place that needs to be fixed is bpf_prog_realloc(),
since only here we expand the program, so we try to account for the
needed delta and should we fail, call-sites check for outcome anyway.
On cBPF to eBPF migrations, we don't grab a reference to the user as
they are charged differently. With that in place, my test case worked
fine.

Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h  | 11 +++++++++++
 kernel/bpf/core.c    | 16 +++++++++++++---
 kernel/bpf/syscall.c | 36 ++++++++++++++++++++++++++++--------
 3 files changed, 52 insertions(+), 11 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 201eb48..f74ae68 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -238,6 +238,8 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 void bpf_prog_sub(struct bpf_prog *prog, int i);
 struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
+int __bpf_prog_charge(struct user_struct *user, u32 pages);
+void __bpf_prog_uncharge(struct user_struct *user, u32 pages);
 
 struct bpf_map *bpf_map_get_with_uref(u32 ufd);
 struct bpf_map *__bpf_map_get(struct fd f);
@@ -318,6 +320,15 @@ static inline struct bpf_prog * __must_check bpf_prog_inc(struct bpf_prog *prog)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
+
+static inline int __bpf_prog_charge(struct user_struct *user, u32 pages)
+{
+	return 0;
+}
+
+static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
+{
+}
 #endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 75c08b8..1eb4f13 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -105,19 +105,29 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
 			  gfp_extra_flags;
 	struct bpf_prog *fp;
+	u32 pages, delta;
+	int ret;
 
 	BUG_ON(fp_old == NULL);
 
 	size = round_up(size, PAGE_SIZE);
-	if (size <= fp_old->pages * PAGE_SIZE)
+	pages = size / PAGE_SIZE;
+	if (pages <= fp_old->pages)
 		return fp_old;
 
+	delta = pages - fp_old->pages;
+	ret = __bpf_prog_charge(fp_old->aux->user, delta);
+	if (ret)
+		return NULL;
+
 	fp = __vmalloc(size, gfp_flags, PAGE_KERNEL);
-	if (fp != NULL) {
+	if (fp == NULL) {
+		__bpf_prog_uncharge(fp_old->aux->user, delta);
+	} else {
 		kmemcheck_annotate_bitfield(fp, meta);
 
 		memcpy(fp, fp_old, fp_old->pages * PAGE_SIZE);
-		fp->pages = size / PAGE_SIZE;
+		fp->pages = pages;
 		fp->aux->prog = fp;
 
 		/* We keep fp->aux from fp_old around in the new
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 35d674c..e89acea 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -615,19 +615,39 @@ static void free_used_maps(struct bpf_prog_aux *aux)
 	kfree(aux->used_maps);
 }
 
+int __bpf_prog_charge(struct user_struct *user, u32 pages)
+{
+	unsigned long memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	unsigned long user_bufs;
+
+	if (user) {
+		user_bufs = atomic_long_add_return(pages, &user->locked_vm);
+		if (user_bufs > memlock_limit) {
+			atomic_long_sub(pages, &user->locked_vm);
+			return -EPERM;
+		}
+	}
+
+	return 0;
+}
+
+void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
+{
+	if (user)
+		atomic_long_sub(pages, &user->locked_vm);
+}
+
 static int bpf_prog_charge_memlock(struct bpf_prog *prog)
 {
 	struct user_struct *user = get_current_user();
-	unsigned long memlock_limit;
-
-	memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	int ret;
 
-	atomic_long_add(prog->pages, &user->locked_vm);
-	if (atomic_long_read(&user->locked_vm) > memlock_limit) {
-		atomic_long_sub(prog->pages, &user->locked_vm);
+	ret = __bpf_prog_charge(user, prog->pages);
+	if (ret) {
 		free_uid(user);
-		return -EPERM;
+		return ret;
 	}
+
 	prog->aux->user = user;
 	return 0;
 }
@@ -636,7 +656,7 @@ static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
 {
 	struct user_struct *user = prog->aux->user;
 
-	atomic_long_sub(prog->pages, &user->locked_vm);
+	__bpf_prog_uncharge(user, prog->pages);
 	free_uid(user);
 }
 
-- 
1.9.3
