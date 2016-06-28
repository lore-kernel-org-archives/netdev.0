From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] neigh: Explicitly declare RCU-bh read side critical section
 in neigh_xmit()
Date: Tue, 28 Jun 2016 11:16:43 +0300
Message-ID: <20160628081643.GU10080@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, roopa@cumulusnetworks.com,
	Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:48588 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbcF1IQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 04:16:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Barroso <dbarroso@fastly.com>

neigh_xmit() expects to be called inside an RCU-bh read side critical
section, and while one of its two current callers gets this right, the
other one doesn't.

More specifically, neigh_xmit() has two callers, mpls_forward() and
mpls_output(), and while both callers call neigh_xmit() under
rcu_read_lock(), this provides sufficient protection for neigh_xmit()
only in the case of mpls_forward(), as that is always called from
softirq context and therefore doesn't need explicit BH protection,
while mpls_output() can be called from process context with softirqs
enabled.

When mpls_output() is called from process context, with softirqs
enabled, we can be preempted by a softirq at any time, and RCU-bh
considers the completion of a softirq as signaling the end of any
pending read-side critical sections, so if we do get a softirq
while we are in the part of neigh_xmit() that expects to be run inside
an RCU-bh read side critical section, we can end up with an unexpected
RCU grace period running right in the middle of that critical section,
making things go boom.

This patch fixes this impedance mismatch in the callee, by making
neigh_xmit() always take rcu_read_{,un}lock_bh() around the code that
expects to be treated as an RCU-bh read side critical section, as this
seems a safer option than fixing it in the callers.

Fixes: 4fd3d7d9e868f ("neigh: Add helper function neigh_xmit")
Signed-off-by: David Barroso <dbarroso@fastly.com>
Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>
Acked-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Robert Shearman <rshearma@brocade.com>
---
 net/core/neighbour.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 29dd8cc..510cd62 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2469,13 +2469,17 @@ int neigh_xmit(int index, struct net_device *dev,
 		tbl = neigh_tables[index];
 		if (!tbl)
 			goto out;
+		rcu_read_lock_bh();
 		neigh = __neigh_lookup_noref(tbl, addr, dev);
 		if (!neigh)
 			neigh = __neigh_create(tbl, addr, dev, false);
 		err = PTR_ERR(neigh);
-		if (IS_ERR(neigh))
+		if (IS_ERR(neigh)) {
+			rcu_read_unlock_bh();
 			goto out_kfree_skb;
+		}
 		err = neigh->output(neigh, skb);
+		rcu_read_unlock_bh();
 	}
 	else if (index == NEIGH_LINK_TABLE) {
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
-- 
2.7.4
