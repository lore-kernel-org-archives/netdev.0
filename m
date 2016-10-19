From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: fix a potential deadlock in do_ipv6_setsockopt()
Date: Wed, 19 Oct 2016 11:20:18 -0700
Message-ID: <1476901218-15635-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: sploving1@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36558 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932426AbcJSSUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 14:20:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id r16so3089131pfg.3
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 11:20:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Baozeng reported this deadlock case:

       CPU0                    CPU1
       ----                    ----
  lock([  165.136033] sk_lock-AF_INET6);
                               lock([  165.136033] rtnl_mutex);
                               lock([  165.136033] sk_lock-AF_INET6);
  lock([  165.136033] rtnl_mutex);

Similar to commit 87e9f0315952
("ipv4: fix a potential deadlock in mcast getsockopt() path")
this is due to we still have a case, ipv6_sock_mc_close(),
where we acquire sk_lock before rtnl_lock. Close this deadlock
with the similar solution, that is always acquire rtnl lock first.

Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
Reported-by: Baozeng Ding <sploving1@gmail.com>
Tested-by: Baozeng Ding <sploving1@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/af_inet6.c      | 2 ++
 net/ipv6/ipv6_sockglue.c | 1 +
 net/ipv6/mcast.c         | 4 ++--
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 46ad699..b8c8d20 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -414,7 +414,9 @@ int inet6_release(struct socket *sock)
 		return -EINVAL;
 
 	/* Free mc lists */
+	rtnl_lock();
 	ipv6_sock_mc_close(sk);
+	rtnl_unlock();
 
 	/* Free ac lists */
 	ipv6_sock_ac_close(sk);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 5330262..1e4bcce 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -120,6 +120,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 static bool setsockopt_needs_rtnl(int optname)
 {
 	switch (optname) {
+	case IPV6_ADDRFORM:
 	case IPV6_ADD_MEMBERSHIP:
 	case IPV6_DROP_MEMBERSHIP:
 	case IPV6_JOIN_ANYCAST:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 75c1fc5..41badfd 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -282,10 +282,11 @@ void ipv6_sock_mc_close(struct sock *sk)
 	struct ipv6_mc_socklist *mc_lst;
 	struct net *net = sock_net(sk);
 
+	ASSERT_RTNL();
+
 	if (!rcu_access_pointer(np->ipv6_mc_list))
 		return;
 
-	rtnl_lock();
 	while ((mc_lst = rtnl_dereference(np->ipv6_mc_list)) != NULL) {
 		struct net_device *dev;
 
@@ -305,7 +306,6 @@ void ipv6_sock_mc_close(struct sock *sk)
 		kfree_rcu(mc_lst, rcu);
 
 	}
-	rtnl_unlock();
 }
 
 int ip6_mc_source(int add, int omode, struct sock *sk,
-- 
2.1.0
