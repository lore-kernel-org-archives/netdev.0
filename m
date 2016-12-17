From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] bpf: fix overflow in prog accounting
Date: Sat, 17 Dec 2016 01:54:49 +0100
Message-ID: <e225c943767e175b2431a8f23699b7dad5e2758b.1481935106.git.daniel@iogearbox.net>
References: <cover.1481935106.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50836 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934201AbcLQAzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 19:55:10 -0500
In-Reply-To: <cover.1481935106.git.daniel@iogearbox.net>
In-Reply-To: <cover.1481935106.git.daniel@iogearbox.net>
References: <cover.1481935106.git.daniel@iogearbox.net>
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
 include/linux/filter.h |  3 +++
 kernel/bpf/core.c      | 61 +++++++++++++++++++++++++++++++++++++++++++++++---
 kernel/bpf/syscall.c   | 25 ---------------------
 3 files changed, 61 insertions(+), 28 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index a0934e6..496a8c0 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -577,6 +577,9 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags);
 void __bpf_prog_free(struct bpf_prog *fp);
 
+int bpf_prog_charge_memlock(struct bpf_prog *prog);
+void bpf_prog_uncharge_memlock(struct bpf_prog *prog);
+
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
 	bpf_prog_unlock_ro(fp);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 75c08b8..1f9a146 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -71,6 +71,51 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 	return NULL;
 }
 
+static int __bpf_prog_charge(struct user_struct *user, u32 pages)
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
+static void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
+{
+	if (user)
+		atomic_long_sub(pages, &user->locked_vm);
+}
+
+int bpf_prog_charge_memlock(struct bpf_prog *prog)
+{
+	struct user_struct *user = get_current_user();
+	int ret;
+
+	ret = __bpf_prog_charge(user, prog->pages);
+	if (ret) {
+		free_uid(user);
+		return ret;
+	}
+
+	prog->aux->user = user;
+	return 0;
+}
+
+void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
+{
+	struct user_struct *user = prog->aux->user;
+
+	__bpf_prog_uncharge(user, prog->pages);
+	free_uid(user);
+}
+
 struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 {
 	gfp_t gfp_flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO |
@@ -105,19 +150,29 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
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
index 35d674c..016382b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -615,31 +615,6 @@ static void free_used_maps(struct bpf_prog_aux *aux)
 	kfree(aux->used_maps);
 }
 
-static int bpf_prog_charge_memlock(struct bpf_prog *prog)
-{
-	struct user_struct *user = get_current_user();
-	unsigned long memlock_limit;
-
-	memlock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-	atomic_long_add(prog->pages, &user->locked_vm);
-	if (atomic_long_read(&user->locked_vm) > memlock_limit) {
-		atomic_long_sub(prog->pages, &user->locked_vm);
-		free_uid(user);
-		return -EPERM;
-	}
-	prog->aux->user = user;
-	return 0;
-}
-
-static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
-{
-	struct user_struct *user = prog->aux->user;
-
-	atomic_long_sub(prog->pages, &user->locked_vm);
-	free_uid(user);
-}
-
 static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 {
 	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
-- 
1.9.3
