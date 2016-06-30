From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: generally move prog destruction to RCU deferral
Date: Thu, 30 Jun 2016 17:24:43 +0200
Message-ID: <21793b7893ca86eb0ba06bc7cedca60dd27e3e84.1467298256.git.daniel@iogearbox.net>
References: <cover.1467298256.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, jannh@google.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48319 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932447AbcF3PZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:25:06 -0400
In-Reply-To: <cover.1467298256.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467298256.git.daniel@iogearbox.net>
References: <cover.1467298256.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jann Horn reported following analysis that could potentially result
in a very hard to trigger (if not impossible) UAF race, to quote his
event timeline:

 - Set up a process with threads T1, T2 and T3
 - Let T1 set up a socket filter F1 that invokes another filter F2
   through a BPF map [tail call]
 - Let T1 trigger the socket filter via a unix domain socket write,
   don't wait for completion
 - Let T2 call PERF_EVENT_IOC_SET_BPF with F2, don't wait for completion
 - Now T2 should be behind bpf_prog_get(), but before bpf_prog_put()
 - Let T3 close the file descriptor for F2, dropping the reference
   count of F2 to 2
 - At this point, T1 should have looked up F2 from the map, but not
   finished executing it
 - Let T3 remove F2 from the BPF map, dropping the reference count of
   F2 to 1
 - Now T2 should call bpf_prog_put() (wrong BPF program type), dropping
   the reference count of F2 to 0 and scheduling bpf_prog_free_deferred()
   via schedule_work()
 - At this point, the BPF program could be freed
 - BPF execution is still running in a freed BPF program

While at PERF_EVENT_IOC_SET_BPF time it's only guaranteed that the perf
event fd we're doing the syscall on doesn't disappear from underneath us
for whole syscall time, it may not be the case for the bpf fd used as
an argument only after we did the put. It needs to be a valid fd pointing
to a BPF program at the time of the call to make the bpf_prog_get() and
while T2 gets preempted, F2 must have dropped reference to 1 on the other
CPU. The fput() from the close() in T3 should also add additionally delay
to the reference drop via exit_task_work() when bpf_prog_release() gets
called as well as scheduling bpf_prog_free_deferred().

That said, it makes nevertheless sense to move the BPF prog destruction
generally after RCU grace period to guarantee that such scenario above,
but also others as recently fixed in ceb56070359b ("bpf, perf: delay release
of BPF prog after grace period") with regards to tail calls won't happen.
Integrating bpf_prog_free_deferred() directly into the RCU callback is
not allowed since the invocation might happen from either softirq or
process context, so we're not permitted to block. Reviewing all bpf_prog_put()
invocations from eBPF side (note, cBPF -> eBPF progs don't use this for
their destruction) with call_rcu() look good to me.

Since we don't know whether at the time of attaching the program, we're
already part of a tail call map, we need to use RCU variant. However, due
to this, there won't be severely more stress on the RCU callback queue:
situations with above bpf_prog_get() and bpf_prog_put() combo in practice
normally won't lead to releases, but even if they would, enough effort/
cycles have to be put into loading a BPF program into the kernel already.

Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   |  5 -----
 kernel/bpf/arraymap.c |  4 +---
 kernel/bpf/syscall.c  | 13 +++----------
 kernel/events/core.c  |  2 +-
 4 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8411032..7495498 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -220,7 +220,6 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
-void bpf_prog_put_rcu(struct bpf_prog *prog);
 
 struct bpf_map *bpf_map_get_with_uref(u32 ufd);
 struct bpf_map *__bpf_map_get(struct fd f);
@@ -281,10 +280,6 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
-
-static inline void bpf_prog_put_rcu(struct bpf_prog *prog)
-{
-}
 #endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5af3073..4ec57a6 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -390,9 +390,7 @@ static void *prog_fd_array_get_ptr(struct bpf_map *map,
 
 static void prog_fd_array_put_ptr(void *ptr)
 {
-	struct bpf_prog *prog = ptr;
-
-	bpf_prog_put_rcu(prog);
+	bpf_prog_put(ptr);
 }
 
 /* decrement refcnt of all bpf_progs that are stored in this map */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c23a4e93..f6806a1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -623,7 +623,7 @@ static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
 	free_uid(user);
 }
 
-static void __prog_put_common(struct rcu_head *rcu)
+static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 {
 	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
 
@@ -632,17 +632,10 @@ static void __prog_put_common(struct rcu_head *rcu)
 	bpf_prog_free(aux->prog);
 }
 
-/* version of bpf_prog_put() that is called after a grace period */
-void bpf_prog_put_rcu(struct bpf_prog *prog)
-{
-	if (atomic_dec_and_test(&prog->aux->refcnt))
-		call_rcu(&prog->aux->rcu, __prog_put_common);
-}
-
 void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt))
-		__prog_put_common(&prog->aux->rcu);
+		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_put);
 
@@ -650,7 +643,7 @@ static int bpf_prog_release(struct inode *inode, struct file *filp)
 {
 	struct bpf_prog *prog = filp->private_data;
 
-	bpf_prog_put_rcu(prog);
+	bpf_prog_put(prog);
 	return 0;
 }
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 85cd418..9c51ec3 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7529,7 +7529,7 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
 	prog = event->tp_event->prog;
 	if (prog) {
 		event->tp_event->prog = NULL;
-		bpf_prog_put_rcu(prog);
+		bpf_prog_put(prog);
 	}
 }
 
-- 
1.9.3
