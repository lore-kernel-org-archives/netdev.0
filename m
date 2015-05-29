From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: add missing rcu protection when releasing programs from prog_array
Date: Thu, 28 May 2015 19:26:02 -0700
Message-ID: <1432866362-8154-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33179 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbbE2C0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 22:26:15 -0400
Received: by pdbqa5 with SMTP id qa5so55126674pdb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 19:26:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally the program attachment place (like sockets, qdiscs) takes
care of rcu protection and calls bpf_prog_put() after a grace period.
The programs stored inside prog_array may not be attached anywhere,
so prog_array needs to take care of preserving rcu protection.
Otherwise bpf_tail_call() will race with bpf_prog_put().
To solve that introduce bpf_prog_put_rcu() helper function and use
it in 3 places where unattached program can decrement refcnt:
closing program fd, deleting/replacing program in prog_array.

Fixes: 04fd61ab36ec ("bpf: allow bpf programs to tail-call other bpf programs")
Reported-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h   |    6 +++++-
 kernel/bpf/arraymap.c |    4 ++--
 kernel/bpf/syscall.c  |   19 ++++++++++++++++++-
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8821b9a8689e..5f520f5f087e 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -123,7 +123,10 @@ struct bpf_prog_aux {
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
-	struct work_struct work;
+	union {
+		struct work_struct work;
+		struct rcu_head	rcu;
+	};
 };
 
 struct bpf_array {
@@ -153,6 +156,7 @@ void bpf_register_map_type(struct bpf_map_type_list *tl);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
 void bpf_prog_put(struct bpf_prog *prog);
+void bpf_prog_put_rcu(struct bpf_prog *prog);
 
 struct bpf_map *bpf_map_get(struct fd f);
 void bpf_map_put(struct bpf_map *map);
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 614bcd4c1d74..cb31229a6fa4 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -202,7 +202,7 @@ static int prog_array_map_update_elem(struct bpf_map *map, void *key,
 
 	old_prog = xchg(array->prog + index, prog);
 	if (old_prog)
-		bpf_prog_put(old_prog);
+		bpf_prog_put_rcu(old_prog);
 
 	return 0;
 }
@@ -218,7 +218,7 @@ static int prog_array_map_delete_elem(struct bpf_map *map, void *key)
 
 	old_prog = xchg(array->prog + index, NULL);
 	if (old_prog) {
-		bpf_prog_put(old_prog);
+		bpf_prog_put_rcu(old_prog);
 		return 0;
 	} else {
 		return -ENOENT;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 98a69bd83069..a1b14d197a4f 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -432,6 +432,23 @@ static void free_used_maps(struct bpf_prog_aux *aux)
 	kfree(aux->used_maps);
 }
 
+static void __prog_put_rcu(struct rcu_head *rcu)
+{
+	struct bpf_prog_aux *aux = container_of(rcu, struct bpf_prog_aux, rcu);
+
+	free_used_maps(aux);
+	bpf_prog_free(aux->prog);
+}
+
+/* version of bpf_prog_put() that is called after a grace period */
+void bpf_prog_put_rcu(struct bpf_prog *prog)
+{
+	if (atomic_dec_and_test(&prog->aux->refcnt)) {
+		prog->aux->prog = prog;
+		call_rcu(&prog->aux->rcu, __prog_put_rcu);
+	}
+}
+
 void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
@@ -445,7 +462,7 @@ static int bpf_prog_release(struct inode *inode, struct file *filp)
 {
 	struct bpf_prog *prog = filp->private_data;
 
-	bpf_prog_put(prog);
+	bpf_prog_put_rcu(prog);
 	return 0;
 }
 
-- 
1.7.9.5
