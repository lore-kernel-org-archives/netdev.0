From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 15/36] net,rcu: convert call_rcu(ipv6_mc_socklist_reclaim)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:00:50 +0800
Message-ID: <4D82D8F2.5020208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)"
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64588 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932176Ab1CRD7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback ipv6_mc_socklist_reclaim() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ipv6_mc_socklist_reclaim).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv6/mcast.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 49f986d..7f8df31 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -201,10 +201,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	return 0;
 }
 
-static void ipv6_mc_socklist_reclaim(struct rcu_head *head)
-{
-	kfree(container_of(head, struct ipv6_mc_socklist, rcu));
-}
 /*
  *	socket leave on multicast group
  */
@@ -239,7 +235,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
 			rcu_read_unlock();
 			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
-			call_rcu(&mc_lst->rcu, ipv6_mc_socklist_reclaim);
+			kfree_rcu(mc_lst, rcu);
 			return 0;
 		}
 	}
@@ -307,7 +303,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 		rcu_read_unlock();
 
 		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
-		call_rcu(&mc_lst->rcu, ipv6_mc_socklist_reclaim);
+		kfree_rcu(mc_lst, rcu);
 
 		spin_lock(&ipv6_sk_mc_lock);
 	}
-- 
1.7.4
