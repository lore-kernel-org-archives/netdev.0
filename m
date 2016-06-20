From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: rcu locking issue in mpls output code?
Date: Mon, 20 Jun 2016 03:45:46 +0300
Message-ID: <20160620004546.GP20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:52306 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbcFTA4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 20:56:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

While trying to chase down a memory corruption issue that only occurs
when originating large amounts of MPLS tagged IP traffic, I came across
something in the MPLS output code for which I'm not entirely sure that
it's correct.

Specifically, there is the code path dst_output() -> lwtunnel_output()
-> mpls_output() -> neigh_xmit() -> ___neigh_lookup_noref(), where the
latter accesses a RCU-bh protected struct neigh_table pointer, but there
is no RCU-bh protection being arranged anywhere in this call chain.

Since this is locally generated IP traffic, we're running in process
context, and while lwtunnel_output() holds rcu_read_lock() across its
call to lwtunnel_encap_ops::output() (which is mpls_output() here),
nothing in the chain disables BHs, and in RCU-bh, the completion of a
softirq signals the end of any pending read-side critical sections,
and BHs can preempt this call chain at any time because it runs with
hardirqs and softirqs both enabled, so that would mean that neighbour
table entries can be zapped at any time even while we hold
rcu_read_lock().  I think.

The mpls_forward() path doesn't seem susceptible to the same issue,
as it runs from softirq, where rcu_read_lock() suffices, so I figured
that mpls_output() would be a good place to deal with this and that
something like the patch below would do the trick.  I can't say yet if
this makes my memory corruption issues go away, as they don't reproduce
that easily, but I'll keep testing.  Any thoughts so far?


Thanks,
Lennert



diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index fb31aa8..802956b 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -105,12 +105,15 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		bos = false;
 	}
 
+	rcu_read_lock_bh();
 	if (rt)
 		err = neigh_xmit(NEIGH_ARP_TABLE, out_dev, &rt->rt_gateway,
 				 skb);
 	else if (rt6)
 		err = neigh_xmit(NEIGH_ND_TABLE, out_dev, &rt6->rt6i_gateway,
 				 skb);
+	rcu_read_unlock_bh();
+
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
