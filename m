From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net] openvswitch: Fix refcount leak on force commit.
Date: Tue, 28 Mar 2017 11:25:26 -0700
Message-ID: <1490725526-21075-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: jarno@ovn.org, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:54800 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755487AbdC1SdX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:33:23 -0400
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net [217.70.183.200])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 1B86A487215
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 20:25:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reference count held for skb needs to be released when the skb's
nfct pointer is cleared regardless of if nf_ct_delete() is called or
not.

Failing to release the skb's reference cound led to deferred conntrack
cleanup spinning forever within nf_conntrack_cleanup_net_list() when
cleaning up a network namespace:

   kworker/u16:0-19025 [004] 45981067.173642: sched_switch: kworker/u16:0:19025 [120] R ==> rcu_preempt:7 [120]
   kworker/u16:0-19025 [004] 45981067.173651: kernel_stack: <stack trace>
=> ___preempt_schedule (ffffffffa001ed36)
=> _raw_spin_unlock_bh (ffffffffa0713290)
=> nf_ct_iterate_cleanup (ffffffffc00a4454)
=> nf_conntrack_cleanup_net_list (ffffffffc00a5e1e)
=> nf_conntrack_pernet_exit (ffffffffc00a63dd)
=> ops_exit_list.isra.1 (ffffffffa06075f3)
=> cleanup_net (ffffffffa0607df0)
=> process_one_work (ffffffffa0084c31)
=> worker_thread (ffffffffa008592b)
=> kthread (ffffffffa008bee2)
=> ret_from_fork (ffffffffa071b67c)

Fixes: dd41d33f0b03 ("openvswitch: Add force commit.")
Reported-by: Yang Song <yangsong@vmware.com>
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index e0a8777..7b2c2fc 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -643,8 +643,8 @@ static bool skb_nfct_cached(struct net *net,
 		 */
 		if (nf_ct_is_confirmed(ct))
 			nf_ct_delete(ct, 0, 0);
-		else
-			nf_conntrack_put(&ct->ct_general);
+
+		nf_conntrack_put(&ct->ct_general);
 		nf_ct_set(skb, NULL, 0);
 		return false;
 	}
-- 
2.1.4
