From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/5] bpf: consolidate bpf_prog_put{,_rcu} dismantle paths
Date: Thu, 29 Oct 2015 14:58:08 +0100
Message-ID: <af56025453ad6ba1b04a022724174e3a87b6c13a.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently have duplicated cleanup code in bpf_prog_put() and
bpf_prog_put_rcu() cleanup paths. Back then we decided that it was
not worth it to make it a common helper called by both, but with
the recent addition of resource charging, we could have avoided
the fix in commit ac00737f4e81 ("bpf: Need to call bpf_prog_uncharge_memlock
from bpf_prog_put") if we would have had only a single, common path.
We can simplify it further by assigning aux->prog only once during
allocation time.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/core.c    |  3 ++-
 kernel/bpf/syscall.c | 15 +++++----------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 8086471..334b1bd 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -92,6 +92,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 
 	fp->pages = size / PAGE_SIZE;
 	fp->aux = aux;
+	fp->aux->prog = fp;
 
 	return fp;
 }
@@ -116,6 +117,7 @@ struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 
 		memcpy(fp, fp_old, fp_old->pages * PAGE_SIZE);
 		fp->pages = size / PAGE_SIZE;
+		fp->aux->prog = fp;
 
 		/* We keep fp->aux from fp_old around in the new
 		 * reallocated structure.
@@ -726,7 +728,6 @@ void bpf_prog_free(struct bpf_prog *fp)
 	struct bpf_prog_aux *aux = fp->aux;
 
 	INIT_WORK(&aux->work, bpf_prog_free_deferred);
-	aux->prog = fp;
 	schedule_work(&aux->work);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_free);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 3fff82c..d7783cb 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -513,7 +513,7 @@ static void bpf_prog_uncharge_memlock(struct bpf_prog *prog)
 	free_uid(user);
 }
 
-static void __prog_put_rcu(struct rcu_head *rcu)
+static void __prog_put_common(struct rcu_head *rcu)
 {
 	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
 
@@ -525,19 +525,14 @@ static void __prog_put_rcu(struct rcu_head *rcu)
 /* version of bpf_prog_put() that is called after a grace period */
 void bpf_prog_put_rcu(struct bpf_prog *prog)
 {
-	if (atomic_dec_and_test(&prog->aux->refcnt)) {
-		prog->aux->prog = prog;
-		call_rcu(&prog->aux->rcu, __prog_put_rcu);
-	}
+	if (atomic_dec_and_test(&prog->aux->refcnt))
+		call_rcu(&prog->aux->rcu, __prog_put_common);
 }
 
 void bpf_prog_put(struct bpf_prog *prog)
 {
-	if (atomic_dec_and_test(&prog->aux->refcnt)) {
-		free_used_maps(prog->aux);
-		bpf_prog_uncharge_memlock(prog);
-		bpf_prog_free(prog);
-	}
+	if (atomic_dec_and_test(&prog->aux->refcnt))
+		__prog_put_common(&prog->aux->rcu);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_put);
 
-- 
1.9.3
