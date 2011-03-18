From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 09/36] net,rcu: convert call_rcu(ip_mc_socklist_reclaim) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 11:45:08 +0800
Message-ID: <4D82D544.6090509__26347.7594628514$1300419819$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59728 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755759Ab1CRDn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:43:28 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback ip_mc_socklist_reclaim() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ip_mc_socklist_reclaim).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv4/igmp.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index cf98a36..998dff0 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1850,14 +1850,6 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 	return err;
 }
 
-
-static void ip_mc_socklist_reclaim(struct rcu_head *rp)
-{
-	kfree(container_of(rp, struct ip_mc_socklist, rcu));
-	/* sk_omem_alloc should have been decreased by the caller*/
-}
-
-
 /*
  *	Ask a socket to leave a group.
  */
@@ -1897,7 +1889,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 		rtnl_unlock();
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
-		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
+		kfree_rcu(iml, rcu);
 		return 0;
 	}
 	if (!in_dev)
@@ -2312,7 +2304,7 @@ void ip_mc_drop_socket(struct sock *sk)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
-		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
+		kfree_rcu(iml, rcu);
 	}
 	rtnl_unlock();
 }
-- 
1.7.4
