From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv4: get rid of ip_ra_lock
Date: Wed, 26 Apr 2017 13:55:15 -0700
Message-ID: <1493240115-779-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36244 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967526AbdDZUzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 16:55:24 -0400
Received: by mail-pf0-f194.google.com with SMTP id v14so2592387pfd.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 13:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
we always take RTNL lock for ip_ra_control() which is the only place
we update the list ip_ra_chain, so the ip_ra_lock is no longer needed,
we just need to disable BH there.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ip_sockglue.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 1d46d05..2923ea1 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -330,7 +330,6 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
    sent to multicast group to reach destination designated router.
  */
 struct ip_ra_chain __rcu *ip_ra_chain;
-static DEFINE_SPINLOCK(ip_ra_lock);
 
 
 static void ip_ra_destroy_rcu(struct rcu_head *head)
@@ -352,21 +351,21 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
-	spin_lock_bh(&ip_ra_lock);
+	ASSERT_RTNL();
+	local_bh_disable();
 	for (rap = &ip_ra_chain;
-	     (ra = rcu_dereference_protected(*rap,
-			lockdep_is_held(&ip_ra_lock))) != NULL;
+	     (ra = rtnl_dereference(*rap)) != NULL;
 	     rap = &ra->next) {
 		if (ra->sk == sk) {
 			if (on) {
-				spin_unlock_bh(&ip_ra_lock);
+				local_bh_enable();
 				kfree(new_ra);
 				return -EADDRINUSE;
 			}
 			/* dont let ip_call_ra_chain() use sk again */
 			ra->sk = NULL;
 			RCU_INIT_POINTER(*rap, ra->next);
-			spin_unlock_bh(&ip_ra_lock);
+			local_bh_enable();
 
 			if (ra->destructor)
 				ra->destructor(sk);
@@ -381,7 +380,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 		}
 	}
 	if (!new_ra) {
-		spin_unlock_bh(&ip_ra_lock);
+		local_bh_enable();
 		return -ENOBUFS;
 	}
 	new_ra->sk = sk;
@@ -390,7 +389,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 	RCU_INIT_POINTER(new_ra->next, ra);
 	rcu_assign_pointer(*rap, new_ra);
 	sock_hold(sk);
-	spin_unlock_bh(&ip_ra_lock);
+	local_bh_enable();
 
 	return 0;
 }
-- 
2.5.5
