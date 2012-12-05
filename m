From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: avoid taking locks at socket dismantle
Date: Wed, 05 Dec 2012 11:18:10 -0800
Message-ID: <1354735090.31222.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55454 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab2LETSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:18:15 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3816615pad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 11:18:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ipv6_sock_mc_close() is called for ipv6 sockets at close time, and most
of them don't use multicast.

Add a test to avoid contention on a shared spinlock.

Same heuristic applies for ipv6_sock_ac_close(), to avoid contention
on a shared rwlock.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/anycast.c |    3 +++
 net/ipv6/mcast.c   |    3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 2f4f584..757a810 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -189,6 +189,9 @@ void ipv6_sock_ac_close(struct sock *sk)
 	struct net *net = sock_net(sk);
 	int	prev_index;
 
+	if (!np->ipv6_ac_list)
+		return;
+
 	write_lock_bh(&ipv6_sk_ac_lock);
 	pac = np->ipv6_ac_list;
 	np->ipv6_ac_list = NULL;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b19ed51..28dfa5f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -284,6 +284,9 @@ void ipv6_sock_mc_close(struct sock *sk)
 	struct ipv6_mc_socklist *mc_lst;
 	struct net *net = sock_net(sk);
 
+	if (!rcu_access_pointer(np->ipv6_mc_list))
+		return;
+
 	spin_lock(&ipv6_sk_mc_lock);
 	while ((mc_lst = rcu_dereference_protected(np->ipv6_mc_list,
 				lockdep_is_held(&ipv6_sk_mc_lock))) != NULL) {
