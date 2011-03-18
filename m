From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 07/36] net,rcu: convert call_rcu(ip_mc_list_reclaim) to kfree_rcu()
Date: Fri, 18 Mar 2011 11:44:08 +0800
Message-ID: <4D82D508.5080901__46829.5067236342$1300419766$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59681 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:42:22 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback ip_mc_list_reclaim() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ip_mc_list_reclaim).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/ipv4/igmp.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index e0e77e2..cf187b6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -149,17 +149,11 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc);
 static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 			 int sfcount, __be32 *psfsrc, int delta);
 
-
-static void ip_mc_list_reclaim(struct rcu_head *head)
-{
-	kfree(container_of(head, struct ip_mc_list, rcu));
-}
-
 static void ip_ma_put(struct ip_mc_list *im)
 {
 	if (atomic_dec_and_test(&im->refcnt)) {
 		in_dev_put(im->interface);
-		call_rcu(&im->rcu, ip_mc_list_reclaim);
+		kfree_rcu(im, rcu);
 	}
 }
 
-- 
1.7.4
