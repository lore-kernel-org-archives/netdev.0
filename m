From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: use sock_kmalloc() to limit md5 keys
Date: Tue, 31 Jan 2012 21:56:48 +0100
Message-ID: <1328043408.2617.9.camel@edumazet-laptop>
References: <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328023113.2297.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328024317.2297.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120131.121510.2256411938697193634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45507 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab2AaU4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 15:56:55 -0500
Received: by bkcjm19 with SMTP id jm19so365195bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 12:56:54 -0800 (PST)
In-Reply-To: <20120131.121510.2256411938697193634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no limit on number of MD5 keys an application can attach to a
tcp socket.

This patch adds a per tcp socket limit based
on /proc/sys/net/core/optmem_max

With current default optmem_max values, this allows about 150 keys on
64bit arches, and 88 keys on 32bit arches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_ipv4.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1d5fd82..da5d322 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -943,11 +943,11 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		tp->md5sig_info = md5sig;
 	}
 
-	key = kmalloc(sizeof(*key), gfp);
+	key = sock_kmalloc(sk, sizeof(*key), gfp);
 	if (!key)
 		return -ENOMEM;
 	if (hlist_empty(&md5sig->head) && !tcp_alloc_md5sig_pool(sk)) {
-		kfree(key);
+		sock_kfree_s(sk, key, sizeof(*key));
 		return -ENOMEM;
 	}
 
@@ -971,6 +971,7 @@ int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr, int family)
 	if (!key)
 		return -ENOENT;
 	hlist_del_rcu(&key->node);
+	atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
 	kfree_rcu(key, rcu);
 	if (hlist_empty(&tp->md5sig_info->head))
 		tcp_free_md5sig_pool();
@@ -988,6 +989,7 @@ void tcp_clear_md5_list(struct sock *sk)
 		tcp_free_md5sig_pool();
 	hlist_for_each_entry_safe(key, pos, n, &tp->md5sig_info->head, node) {
 		hlist_del_rcu(&key->node);
+		atomic_sub(sizeof(*key), &sk->sk_omem_alloc);
 		kfree_rcu(key, rcu);
 	}
 }
