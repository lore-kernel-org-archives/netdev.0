From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] filter: refactor common filter attach code into __sk_attach_prog
Date: Mon,  2 Mar 2015 12:25:51 +0100
Message-ID: <8c751ae5e391a3b2dd7a541ad89b3255d2a1f19d.1425295277.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44090 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbbCBLZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 06:25:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both sk_attach_filter() and sk_attach_bpf() are setting up sk_filter,
charging skmem and attaching it to the socket after we got the eBPF
prog up and ready. Lets refactor that into a common helper.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 71 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 38 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ff000cb..7a4eb70 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1019,6 +1019,32 @@ void bpf_prog_destroy(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_destroy);
 
+static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
+{
+	struct sk_filter *fp, *old_fp;
+
+	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp)
+		return -ENOMEM;
+
+	fp->prog = prog;
+	atomic_set(&fp->refcnt, 0);
+
+	if (!sk_filter_charge(sk, fp)) {
+		kfree(fp);
+		return -ENOMEM;
+	}
+
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   sock_owned_by_user(sk));
+	rcu_assign_pointer(sk->sk_filter, fp);
+
+	if (old_fp)
+		sk_filter_uncharge(sk, old_fp);
+
+	return 0;
+}
+
 /**
  *	sk_attach_filter - attach a socket filter
  *	@fprog: the filter program
@@ -1031,7 +1057,6 @@ EXPORT_SYMBOL_GPL(bpf_prog_destroy);
  */
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
-	struct sk_filter *fp, *old_fp;
 	unsigned int fsize = bpf_classic_proglen(fprog);
 	unsigned int bpf_fsize = bpf_prog_size(fprog->len);
 	struct bpf_prog *prog;
@@ -1068,35 +1093,20 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
-	if (!fp) {
+	err = __sk_attach_prog(prog, sk);
+	if (err < 0) {
 		__bpf_prog_release(prog);
-		return -ENOMEM;
-	}
-	fp->prog = prog;
-
-	atomic_set(&fp->refcnt, 0);
-
-	if (!sk_filter_charge(sk, fp)) {
-		__sk_filter_release(fp);
-		return -ENOMEM;
+		return err;
 	}
 
-	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
-	rcu_assign_pointer(sk->sk_filter, fp);
-
-	if (old_fp)
-		sk_filter_uncharge(sk, old_fp);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
 int sk_attach_bpf(u32 ufd, struct sock *sk)
 {
-	struct sk_filter *fp, *old_fp;
 	struct bpf_prog *prog;
+	int err;
 
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
 		return -EPERM;
@@ -1110,27 +1120,12 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 		return -EINVAL;
 	}
 
-	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
-	if (!fp) {
+	err = __sk_attach_prog(prog, sk);
+	if (err < 0) {
 		bpf_prog_put(prog);
-		return -ENOMEM;
-	}
-
-	fp->prog = prog;
-	atomic_set(&fp->refcnt, 0);
-
-	if (!sk_filter_charge(sk, fp)) {
-		__sk_filter_release(fp);
-		return -ENOMEM;
+		return err;
 	}
 
-	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
-	rcu_assign_pointer(sk->sk_filter, fp);
-
-	if (old_fp)
-		sk_filter_uncharge(sk, old_fp);
-
 	return 0;
 }
 
-- 
1.9.3
