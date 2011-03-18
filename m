From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 36/36] net,rcu: convert call_rcu(xt_osf_finger_free_rcu) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:15:02 +0800
Message-ID: <4D82DC46.5010905__5514.99883081323$1300421610$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59450 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750817Ab1CRENR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback xt_osf_finger_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(xt_osf_finger_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/netfilter/xt_osf.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4327e10..846f895 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -62,13 +62,6 @@ static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
 	[OSF_ATTR_FINGER]	= { .len = sizeof(struct xt_osf_user_finger) },
 };
 
-static void xt_osf_finger_free_rcu(struct rcu_head *rcu_head)
-{
-	struct xt_osf_finger *f = container_of(rcu_head, struct xt_osf_finger, rcu_head);
-
-	kfree(f);
-}
-
 static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
 			       const struct nlmsghdr *nlh,
 			       const struct nlattr * const osf_attrs[])
@@ -133,7 +126,7 @@ static int xt_osf_remove_callback(struct sock *ctnl, struct sk_buff *skb,
 		 * We are protected by nfnl mutex.
 		 */
 		list_del_rcu(&sf->finger_entry);
-		call_rcu(&sf->rcu_head, xt_osf_finger_free_rcu);
+		kfree_rcu(sf, rcu_head);
 
 		err = 0;
 		break;
@@ -414,7 +407,7 @@ static void __exit xt_osf_fini(void)
 
 		list_for_each_entry_rcu(f, &xt_osf_fingers[i], finger_entry) {
 			list_del_rcu(&f->finger_entry);
-			call_rcu(&f->rcu_head, xt_osf_finger_free_rcu);
+			kfree_rcu(f, rcu_head);
 		}
 	}
 	rcu_read_unlock();
-- 
1.7.4
