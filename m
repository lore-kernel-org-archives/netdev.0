From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 7/7] net: Batch inet_twsk_purge
Date: Thu,  3 Dec 2009 04:29:09 -0800
Message-ID: <1259843349-3810-7-git-send-email-ebiederm@xmission.com>
References: <m11vjcnsyr.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54620 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbZLCM32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:29:28 -0500
In-Reply-To: <m11vjcnsyr.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

This function walks the whole hashtable so there is no point in
passing it a network namespace.  Instead I purge all timewait
sockets from dead network namespaces that I find.  If the namespace
is one of the once I am trying to purge I am guaranteed no new timewait
sockets can be formed so this will get them all.  If the namespace
is one I am not acting for it might form a few more but I will
call inet_twsk_purge again and  shortly to get rid of them.  In
any even if the network namespace is dead timewait sockets are
useless.

Move the calls of inet_twsk_purge into batch_exit routines so
that if I am killing a bunch of namespaces at once I will just
call inet_twsk_purge once and save a lot of redundant unnecessary
work.

My simple 4k network namespace exit test the cleanup time dropped from
roughly 8.2s to 1.6s.  While the time spent running inet_twsk_purge fell
to about 2ms.  1ms for ipv4 and 1ms for ipv6.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/inet_timewait_sock.h |    6 +++---
 net/ipv4/inet_timewait_sock.c    |   10 +++++-----
 net/ipv4/tcp_ipv4.c              |   11 ++++++++---
 net/ipv6/tcp_ipv6.c              |   11 ++++++++---
 4 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 773b10f..4fd007f 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -212,14 +212,14 @@ extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
 extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
 				 struct inet_timewait_death_row *twdr);
 
-extern void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
+extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 			    struct inet_timewait_death_row *twdr, int family);
 
 static inline
 struct net *twsk_net(const struct inet_timewait_sock *twsk)
 {
 #ifdef CONFIG_NET_NS
-	return twsk->tw_net;
+	return rcu_dereference(twsk->tw_net);
 #else
 	return &init_net;
 #endif
@@ -229,7 +229,7 @@ static inline
 void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	twsk->tw_net = net;
+	rcu_assign_pointer(twsk->tw_net, net);
 #endif
 }
 #endif	/* _INET_TIMEWAIT_SOCK_ */
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 683ecec..a3699ac 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -421,7 +421,7 @@ out:
 
 EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
 
-void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
+void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 		     struct inet_timewait_death_row *twdr, int family)
 {
 	struct inet_timewait_sock *tw;
@@ -436,15 +436,15 @@ restart_rcu:
 restart:
 		sk_nulls_for_each_rcu(sk, node, &head->twchain) {
 			tw = inet_twsk(sk);
-			if (!net_eq(twsk_net(tw), net) ||
-			    tw->tw_family != family)
+			if ((tw->tw_family != family) ||
+				atomic_read(&twsk_net(tw)->count))
 				continue;
 
 			if (unlikely(!atomic_inc_not_zero(&tw->tw_refcnt)))
 				continue;
 
-			if (unlikely(!net_eq(twsk_net(tw), net) ||
-				     tw->tw_family != family)) {
+			if (unlikely((tw->tw_family != family) ||
+				     atomic_read(&twsk_net(tw)->count))) {
 				inet_twsk_put(tw);
 				goto restart;
 			}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index df18ce0..e30f026 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2468,12 +2468,17 @@ static int __net_init tcp_sk_init(struct net *net)
 static void __net_exit tcp_sk_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
-	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET);
+}
+
+static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_list)
+{
+	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET);
 }
 
 static struct pernet_operations __net_initdata tcp_sk_ops = {
-       .init = tcp_sk_init,
-       .exit = tcp_sk_exit,
+       .init	   = tcp_sk_init,
+       .exit	   = tcp_sk_exit,
+       .exit_batch = tcp_sk_exit_batch,
 };
 
 void __init tcp_v4_init(void)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index de70909..5f46d36 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2126,12 +2126,17 @@ static int tcpv6_net_init(struct net *net)
 static void tcpv6_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.tcp_sk);
-	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET6);
+}
+
+static void tcpv6_net_exit_batch(struct list_head *net_exit_list)
+{
+	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET6);
 }
 
 static struct pernet_operations tcpv6_net_ops = {
-	.init = tcpv6_net_init,
-	.exit = tcpv6_net_exit,
+	.init	    = tcpv6_net_init,
+	.exit	    = tcpv6_net_exit,
+	.exit_batch = tcpv6_net_exit_batch,
 };
 
 int __init tcpv6_init(void)
-- 
1.6.5.2.143.g8cc62

