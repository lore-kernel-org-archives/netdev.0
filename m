From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mpls: Add missing RCU-bh read side critical section locking
 in output path
Date: Mon, 20 Jun 2016 21:05:27 +0300
Message-ID: <20160620180527.GU20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:53504 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932373AbcFTSPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 14:15:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Barroso <dbarroso@fastly.com>

When locally originated IP traffic hits a route that says to push
MPLS labels, we'll get a call chain dst_output() -> lwtunnel_output()
-> mpls_output() -> neigh_xmit() -> ___neigh_lookup_noref() where the
last function in this chain accesses a RCU-bh protected struct
neigh_table pointer without us ever having declared an RCU-bh read
side critical section.

As in case of locally originated IP traffic we'll be running in process
context, with softirqs enabled, we can be preempted by a softirq at any
time, and RCU-bh considers the completion of a softirq as signaling
the end of any pending read-side critical sections, so if we do get a
softirq here, we can end up with an unexpected RCU grace period and
all the nastiness that that comes with.

This patch makes neigh_xmit() take rcu_read_{,un}lock_bh() around the
code that expects to be treated as an RCU-bh read side critical section.

Signed-off-by: David Barroso <dbarroso@fastly.com>
Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f18ae91..769cece 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2467,13 +2467,17 @@ int neigh_xmit(int index, struct net_device *dev,
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
