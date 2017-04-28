From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] ipv4: get rid of ip_ra_lock
Date: Fri, 28 Apr 2017 10:04:29 -0700
Message-ID: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34099 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424651AbdD1REi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:04:38 -0400
Received: by mail-pg0-f67.google.com with SMTP id t7so6266096pgt.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 10:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
we always take RTNL lock for ip_ra_control() which is the only place
we update the list ip_ra_chain, so the ip_ra_lock is no longer needed.

As Eric points out, BH does not need to disable either, RCU readers
don't care.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ip_sockglue.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 1d46d05..4c25458 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -330,7 +330,6 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
    sent to multicast group to reach destination designated router.
  */
 struct ip_ra_chain __rcu *ip_ra_chain;
-static DEFINE_SPINLOCK(ip_ra_lock);
 
 
 static void ip_ra_destroy_rcu(struct rcu_head *head)
@@ -352,21 +351,17 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
-	spin_lock_bh(&ip_ra_lock);
 	for (rap = &ip_ra_chain;
-	     (ra = rcu_dereference_protected(*rap,
-			lockdep_is_held(&ip_ra_lock))) != NULL;
+	     (ra = rtnl_dereference(*rap)) != NULL;
 	     rap = &ra->next) {
 		if (ra->sk == sk) {
 			if (on) {
-				spin_unlock_bh(&ip_ra_lock);
 				kfree(new_ra);
 				return -EADDRINUSE;
 			}
 			/* dont let ip_call_ra_chain() use sk again */
 			ra->sk = NULL;
 			RCU_INIT_POINTER(*rap, ra->next);
-			spin_unlock_bh(&ip_ra_lock);
 
 			if (ra->destructor)
 				ra->destructor(sk);
@@ -381,7 +376,6 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 		}
 	}
 	if (!new_ra) {
-		spin_unlock_bh(&ip_ra_lock);
 		return -ENOBUFS;
 	}
 	new_ra->sk = sk;
@@ -390,7 +384,6 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 	RCU_INIT_POINTER(new_ra->next, ra);
 	rcu_assign_pointer(*rap, new_ra);
 	sock_hold(sk);
-	spin_unlock_bh(&ip_ra_lock);
 
 	return 0;
 }
-- 
2.5.5
