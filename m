From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/3] tun: use socket locks for sk_{attach,detatch}_filter
Date: Tue,  5 Apr 2016 17:10:16 +0200
Message-ID: <1459869016-13896-4-git-send-email-hannes@stressinduktion.org>
References: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Cc: daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49961 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758708AbcDEPKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:10:25 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 6B5C220A5F
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 11:10:24 -0400 (EDT)
In-Reply-To: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 5a5abb1fa3b05dd ("tun, bpf: fix suspicious RCU usage
in tun_{attach, detach}_filter") and replaces it to use lock_sock around
sk_{attach,detach}_filter. The checks inside filter.c are updated with
lockdep_sock_is_held to check for proper socket locks.

It keeps the code cleaner by ensuring that only one lock governs the
socket filter instead of two independent locks.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/tun.c      | 14 +++++++++-----
 include/linux/filter.h |  4 ----
 net/core/filter.c      | 35 +++++++++++++----------------------
 3 files changed, 22 insertions(+), 31 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9abc36bf77eae3..64bc143eddd983 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -622,8 +622,9 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	/* Re-attach the filter to persist device */
 	if (!skip_filter && (tun->filter_attached == true)) {
-		err = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
-					 lockdep_rtnl_is_held());
+		lock_sock(tfile->socket.sk);
+		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		release_sock(tfile->socket.sk);
 		if (!err)
 			goto out;
 	}
@@ -1824,7 +1825,9 @@ static void tun_detach_filter(struct tun_struct *tun, int n)
 
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
-		__sk_detach_filter(tfile->socket.sk, lockdep_rtnl_is_held());
+		lock_sock(tfile->socket.sk);
+		sk_detach_filter(tfile->socket.sk);
+		release_sock(tfile->socket.sk);
 	}
 
 	tun->filter_attached = false;
@@ -1837,8 +1840,9 @@ static int tun_attach_filter(struct tun_struct *tun)
 
 	for (i = 0; i < tun->numqueues; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
-		ret = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
-					 lockdep_rtnl_is_held());
+		lock_sock(tfile->socket.sk);
+		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		release_sock(tfile->socket.sk);
 		if (ret) {
 			tun_detach_filter(tun, i);
 			return ret;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a51a5361695fbf..43aa1f8855c7ff 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -465,14 +465,10 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
-int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
-		       bool locked);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
 int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_reuseport_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
-int __sk_detach_filter(struct sock *sk, bool locked);
-
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index ca7f832b29802d..e8486ba601eae7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1149,8 +1149,7 @@ void bpf_prog_destroy(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_destroy);
 
-static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk,
-			    bool locked)
+static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
 
@@ -1166,8 +1165,10 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk,
 		return -ENOMEM;
 	}
 
-	old_fp = rcu_dereference_protected(sk->sk_filter, locked);
+	old_fp = rcu_dereference_protected(sk->sk_filter,
+					   lockdep_sock_is_held(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
+
 	if (old_fp)
 		sk_filter_uncharge(sk, old_fp);
 
@@ -1246,8 +1247,7 @@ struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
  * occurs or there is insufficient memory for the filter a negative
  * errno code is returned. On success the return is zero.
  */
-int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
-		       bool locked)
+int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct bpf_prog *prog = __get_filter(fprog, sk);
 	int err;
@@ -1255,7 +1255,7 @@ int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	err = __sk_attach_prog(prog, sk, locked);
+	err = __sk_attach_prog(prog, sk);
 	if (err < 0) {
 		__bpf_prog_release(prog);
 		return err;
@@ -1263,12 +1263,7 @@ int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(__sk_attach_filter);
-
-int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
-{
-	return __sk_attach_filter(fprog, sk, sock_owned_by_user(sk));
-}
+EXPORT_SYMBOL_GPL(sk_attach_filter);
 
 int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
@@ -1314,7 +1309,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	err = __sk_attach_prog(prog, sk, sock_owned_by_user(sk));
+	err = __sk_attach_prog(prog, sk);
 	if (err < 0) {
 		bpf_prog_put(prog);
 		return err;
@@ -2255,7 +2250,7 @@ static int __init register_sk_filter_ops(void)
 }
 late_initcall(register_sk_filter_ops);
 
-int __sk_detach_filter(struct sock *sk, bool locked)
+int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
 	struct sk_filter *filter;
@@ -2263,7 +2258,8 @@ int __sk_detach_filter(struct sock *sk, bool locked)
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
 		return -EPERM;
 
-	filter = rcu_dereference_protected(sk->sk_filter, locked);
+	filter = rcu_dereference_protected(sk->sk_filter,
+					   lockdep_sock_is_held(sk));
 	if (filter) {
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 		sk_filter_uncharge(sk, filter);
@@ -2272,12 +2268,7 @@ int __sk_detach_filter(struct sock *sk, bool locked)
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(__sk_detach_filter);
-
-int sk_detach_filter(struct sock *sk)
-{
-	return __sk_detach_filter(sk, sock_owned_by_user(sk));
-}
+EXPORT_SYMBOL_GPL(sk_detach_filter);
 
 int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		  unsigned int len)
@@ -2288,7 +2279,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 
 	lock_sock(sk);
 	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_sock_is_held(sk));
 	if (!filter)
 		goto out;
 
-- 
2.5.5
