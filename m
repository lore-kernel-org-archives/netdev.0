From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 4/4] ipv6 anycast: Convert ipv6_sk_ac_lock to spinlock.
Date: Thu, 31 Jan 2013 04:27:58 +0900
Message-ID: <5109743E.7070308@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56151 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756624Ab3A3T17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 14:27:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since all users are write-lock, it does not make sense to use
rwlock here.  Use simple spinlock.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/anycast.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 757a810..921b8b3 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -47,7 +47,7 @@
 static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr);
 
 /* Big ac list lock for all the sockets */
-static DEFINE_RWLOCK(ipv6_sk_ac_lock);
+static DEFINE_SPINLOCK(ipv6_sk_ac_lock);
 
 
 /*
@@ -128,10 +128,10 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	err = ipv6_dev_ac_inc(dev, addr);
 	if (!err) {
-		write_lock_bh(&ipv6_sk_ac_lock);
+		spin_lock_bh(&ipv6_sk_ac_lock);
 		pac->acl_next = np->ipv6_ac_list;
 		np->ipv6_ac_list = pac;
-		write_unlock_bh(&ipv6_sk_ac_lock);
+		spin_unlock_bh(&ipv6_sk_ac_lock);
 		pac = NULL;
 	}
 
@@ -152,7 +152,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct ipv6_ac_socklist *pac, *prev_pac;
 	struct net *net = sock_net(sk);
 
-	write_lock_bh(&ipv6_sk_ac_lock);
+	spin_lock_bh(&ipv6_sk_ac_lock);
 	prev_pac = NULL;
 	for (pac = np->ipv6_ac_list; pac; pac = pac->acl_next) {
 		if ((ifindex == 0 || pac->acl_ifindex == ifindex) &&
@@ -161,7 +161,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		prev_pac = pac;
 	}
 	if (!pac) {
-		write_unlock_bh(&ipv6_sk_ac_lock);
+		spin_unlock_bh(&ipv6_sk_ac_lock);
 		return -ENOENT;
 	}
 	if (prev_pac)
@@ -169,7 +169,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	else
 		np->ipv6_ac_list = pac->acl_next;
 
-	write_unlock_bh(&ipv6_sk_ac_lock);
+	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
@@ -192,10 +192,10 @@ void ipv6_sock_ac_close(struct sock *sk)
 	if (!np->ipv6_ac_list)
 		return;
 
-	write_lock_bh(&ipv6_sk_ac_lock);
+	spin_lock_bh(&ipv6_sk_ac_lock);
 	pac = np->ipv6_ac_list;
 	np->ipv6_ac_list = NULL;
-	write_unlock_bh(&ipv6_sk_ac_lock);
+	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	prev_index = 0;
 	rcu_read_lock();
-- 
1.7.9.5
