From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: rcu cleanup in ip_ra_control()
Date: Tue, 09 Sep 2014 08:11:41 -0700
Message-ID: <1410275501.7106.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46180 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbaIIPLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:11:42 -0400
Received: by mail-pd0-f170.google.com with SMTP id fp1so1433912pdb.15
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 08:11:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove one sparse warning :
net/ipv4/ip_sockglue.c:328:22: warning: incorrect type in assignment (different address spaces)
net/ipv4/ip_sockglue.c:328:22:    expected struct ip_ra_chain [noderef] <asn:4>*next
net/ipv4/ip_sockglue.c:328:22:    got struct ip_ra_chain *[assigned] ra

And replace one rcu_assign_ptr() by RCU_INIT_POINTER() where applicable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_sockglue.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 455e75bcb167..c373a9ad4555 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -303,7 +303,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 			}
 			/* dont let ip_call_ra_chain() use sk again */
 			ra->sk = NULL;
-			rcu_assign_pointer(*rap, ra->next);
+			RCU_INIT_POINTER(*rap, ra->next);
 			spin_unlock_bh(&ip_ra_lock);
 
 			if (ra->destructor)
@@ -325,7 +325,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 	new_ra->sk = sk;
 	new_ra->destructor = destructor;
 
-	new_ra->next = ra;
+	RCU_INIT_POINTER(new_ra->next, ra);
 	rcu_assign_pointer(*rap, new_ra);
 	sock_hold(sk);
 	spin_unlock_bh(&ip_ra_lock);
