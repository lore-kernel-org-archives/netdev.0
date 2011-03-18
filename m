From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 08/36] net,rcu: convert call_rcu(ip_sf_socklist_reclaim) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 11:44:46 +0800
Message-ID: <4D82D52E.1010501__23649.258647538$1300419800$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59698 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:43:01 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback ip_sf_socklist_reclaim() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ip_sf_socklist_reclaim).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv4/igmp.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index cf187b6..cf98a36 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1830,12 +1830,6 @@ done:
 }
 EXPORT_SYMBOL(ip_mc_join_group);
 
-static void ip_sf_socklist_reclaim(struct rcu_head *rp)
-{
-	kfree(container_of(rp, struct ip_sf_socklist, rcu));
-	/* sk_omem_alloc should have been decreased by the caller*/
-}
-
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 			   struct in_device *in_dev)
 {
@@ -1852,7 +1846,7 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 	rcu_assign_pointer(iml->sflist, NULL);
 	/* decrease mem now to avoid the memleak warning */
 	atomic_sub(IP_SFLSIZE(psf->sl_max), &sk->sk_omem_alloc);
-	call_rcu(&psf->rcu, ip_sf_socklist_reclaim);
+	kfree_rcu(psf, rcu);
 	return err;
 }
 
@@ -2020,7 +2014,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			/* decrease mem now to avoid the memleak warning */
 			atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
-			call_rcu(&psl->rcu, ip_sf_socklist_reclaim);
+			kfree_rcu(psl, rcu);
 		}
 		rcu_assign_pointer(pmc->sflist, newpsl);
 		psl = newpsl;
@@ -2121,7 +2115,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 			psl->sl_count, psl->sl_addr, 0);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
-		call_rcu(&psl->rcu, ip_sf_socklist_reclaim);
+		kfree_rcu(psl, rcu);
 	} else
 		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			0, NULL, 0);
-- 
1.7.4
