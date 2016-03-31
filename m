From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 2/4] net: proper check if we hold the socket lock during dereference
Date: Fri,  1 Apr 2016 01:29:40 +0200
Message-ID: <1459466982-20432-3-git-send-email-hannes@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57884 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbcCaX34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:29:56 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id F0ACC2194A
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:29:55 -0400 (EDT)
In-Reply-To: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lockdep_sock_is_held makes sure that we currently own the
lock. sock_owned_by_user simply checks if a user holds the socket. This
could lead to non deterministic lock checks.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 5 +++++
 net/core/filter.c  | 6 +++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e03727b73..30f9b5ad0a82ef 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1382,6 +1382,11 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 		spin_unlock_bh(&sk->sk_lock.slock);
 }
 
+static bool lockdep_sock_is_held(struct sock *sk)
+{
+	return lockdep_is_held(&sk->sk_lock) ||
+	       lockdep_is_held(&sk->sk_lock.slock);
+}
 
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		      struct proto *prot, int kern);
diff --git a/net/core/filter.c b/net/core/filter.c
index 4b81b71171b4ce..e8486ba601eae7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1166,7 +1166,7 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 	}
 
 	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_sock_is_held(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
 
 	if (old_fp)
@@ -2259,7 +2259,7 @@ int sk_detach_filter(struct sock *sk)
 		return -EPERM;
 
 	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_sock_is_held(sk));
 	if (filter) {
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 		sk_filter_uncharge(sk, filter);
@@ -2279,7 +2279,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 
 	lock_sock(sk);
 	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_sock_is_held(sk));
 	if (!filter)
 		goto out;
 
-- 
2.5.5
