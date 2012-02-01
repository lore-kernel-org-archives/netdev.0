From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: protects md5sig_info with RCU
Date: Wed, 01 Feb 2012 05:45:40 +0100
Message-ID: <1328071540.2617.25.camel@edumazet-laptop>
References: <1328057424-11962-1-git-send-email-shawn.lu@ericsson.com>
	 <1328057424-11962-2-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63784 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab2BAEpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 23:45:47 -0500
Received: by werb13 with SMTP id b13so644198wer.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 20:45:45 -0800 (PST)
In-Reply-To: <1328057424-11962-2-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes sure we use appropriate memory barriers before
publishing tp->md5sig_info, allowing tcp_md5_do_lookup() being used from
tcp_v4_send_reset() without holding socket lock (upcoming patch from
Shawn Lu)

Note we also need to respect rcu grace period before its freeing, since
we can free socket without this grace period thanks to
SLAB_DESTROY_BY_RCU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shawn Lu <shawn.lu@ericsson.com>
---
 include/linux/tcp.h |    2 +-
 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   32 ++++++++++++++++++++------------
 net/ipv6/tcp_ipv6.c |    2 --
 4 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c2025f1..115389e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -463,7 +463,7 @@ struct tcp_sock {
 	const struct tcp_sock_af_ops	*af_specific;
 
 /* TCP MD5 Signature Option information */
-	struct tcp_md5sig_info	*md5sig_info;
+	struct tcp_md5sig_info	__rcu *md5sig_info;
 #endif
 
 	/* When the cookie options are generated and exchanged, then this
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 10ae4c7..78880ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1150,6 +1150,7 @@ struct tcp_md5sig_key {
 /* - sock block */
 struct tcp_md5sig_info {
 	struct hlist_head	head;
+	struct rcu_head		rcu;
 };
 
 /* - pseudo header */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index da5d322..567cca9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -879,14 +879,18 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 	struct tcp_md5sig_key *key;
 	struct hlist_node *pos;
 	unsigned int size = sizeof(struct in_addr);
+	struct tcp_md5sig_info *md5sig;
 
-	if (!tp->md5sig_info)
+	/* caller either holds rcu_read_lock() or socket lock */
+	md5sig = rcu_dereference_check(tp->md5sig_info,
+				       sock_owned_by_user(sk));
+	if (!md5sig)
 		return NULL;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (family == AF_INET6)
 		size = sizeof(struct in6_addr);
 #endif
-	hlist_for_each_entry_rcu(key, pos, &tp->md5sig_info->head, node) {
+	hlist_for_each_entry_rcu(key, pos, &md5sig->head, node) {
 		if (key->family != family)
 			continue;
 		if (!memcmp(&key->addr, addr, size))
@@ -932,7 +936,8 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		return 0;
 	}
 
-	md5sig = tp->md5sig_info;
+	md5sig = rcu_dereference_protected(tp->md5sig_info,
+					   sock_owned_by_user(sk));
 	if (!md5sig) {
 		md5sig = kmalloc(sizeof(*md5sig), gfp);
 		if (!md5sig)
@@ -940,7 +945,7 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 
 		sk_nocaps_add(sk, NETIF_F_GSO_MASK);
 		INIT_HLIST_HEAD(&md5sig->head);
-		tp->md5sig_info = md5sig;
+		rcu_assign_pointer(tp->md5sig_info, md5sig);
 	}
 
 	key = sock_kmalloc(sk, sizeof(*key), gfp);
@@ -966,6 +971,7 @@ int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
+	struct tcp_md5sig_info *md5sig;
 
 	key = tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&addr, AF_INET);
 	if (!key)
@@ -973,7 +979,9 @@ int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 	hlist_del_rcu(&key->node);
 	atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
 	kfree_rcu(key, rcu);
-	if (hlist_empty(&tp->md5sig_info->head))
+	md5sig = rcu_dereference_protected(tp->md5sig_info,
+					   sock_owned_by_user(sk));
+	if (hlist_empty(&md5sig->head))
 		tcp_free_md5sig_pool();
 	return 0;
 }
@@ -984,10 +992,13 @@ void tcp_clear_md5_list(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
 	struct hlist_node *pos, *n;
+	struct tcp_md5sig_info *md5sig;
 
-	if (!hlist_empty(&tp->md5sig_info->head))
+	md5sig = rcu_dereference_protected(tp->md5sig_info, 1);
+
+	if (!hlist_empty(&md5sig->head))
 		tcp_free_md5sig_pool();
-	hlist_for_each_entry_safe(key, pos, n, &tp->md5sig_info->head, node) {
+	hlist_for_each_entry_safe(key, pos, n, &md5sig->head, node) {
 		hlist_del_rcu(&key->node);
 		atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
 		kfree_rcu(key, rcu);
@@ -1009,12 +1020,9 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
-	if (!cmd.tcpm_key || !cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
-			return -ENOENT;
+	if (!cmd.tcpm_key || !cmd.tcpm_keylen)
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
 				      AF_INET);
-	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
@@ -1896,7 +1904,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	/* Clean up the MD5 key list, if any */
 	if (tp->md5sig_info) {
 		tcp_clear_md5_list(sk);
-		kfree(tp->md5sig_info);
+		kfree_rcu(tp->md5sig_info, rcu);
 		tp->md5sig_info = NULL;
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bec41f9..c250181 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -571,8 +571,6 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 		return -EINVAL;
 
 	if (!cmd.tcpm_keylen) {
-		if (!tcp_sk(sk)->md5sig_info)
-			return -ENOENT;
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 			return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
 					      AF_INET);
