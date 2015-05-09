From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 6/6] net: kill sk_change_net and sk_release_kernel
Date: Fri, 08 May 2015 21:12:13 -0500
Message-ID: <87y4kyzegy.fsf_-_@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
	<87383633pu.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35258 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbbEICQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:16:46 -0400
In-Reply-To: <87383633pu.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 08 May 2015 21:05:33 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These functions are no longer needed and no longer used kill them.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sock.h | 17 -----------------
 net/core/sock.c    | 19 -------------------
 2 files changed, 36 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 9e6b2c0b4741..d882f4c8e438 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1518,7 +1518,6 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		      struct proto *prot, int kern);
 void sk_free(struct sock *sk);
-void sk_release_kernel(struct sock *sk);
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
 
 struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
@@ -2194,22 +2193,6 @@ void sock_net_set(struct sock *sk, struct net *net)
 	write_pnet(&sk->sk_net, net);
 }
 
-/*
- * Kernel sockets, f.e. rtnl or icmp_socket, are a part of a namespace.
- * They should not hold a reference to a namespace in order to allow
- * to stop it.
- * Sockets after sk_change_net should be released using sk_release_kernel
- */
-static inline void sk_change_net(struct sock *sk, struct net *net)
-{
-	struct net *current_net = sock_net(sk);
-
-	if (!net_eq(current_net, net)) {
-		put_net(current_net);
-		sock_net_set(sk, net);
-	}
-}
-
 static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 {
 	if (skb->sk) {
diff --git a/net/core/sock.c b/net/core/sock.c
index 9e8968e9ebeb..c18738a795b0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1466,25 +1466,6 @@ void sk_free(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_free);
 
-/*
- * Last sock_put should drop reference to sk->sk_net. It has already
- * been dropped in sk_change_net. Taking reference to stopping namespace
- * is not an option.
- * Take reference to a socket to remove it from hash _alive_ and after that
- * destroy it in the context of init_net.
- */
-void sk_release_kernel(struct sock *sk)
-{
-	if (sk == NULL || sk->sk_socket == NULL)
-		return;
-
-	sock_hold(sk);
-	sock_net_set(sk, get_net(&init_net));
-	sock_release(sk->sk_socket);
-	sock_put(sk);
-}
-EXPORT_SYMBOL(sk_release_kernel);
-
 static void sk_update_clone(const struct sock *sk, struct sock *newsk)
 {
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-- 
2.2.1
