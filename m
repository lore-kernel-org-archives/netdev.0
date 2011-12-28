From: David Miller <davem@davemloft.net>
Subject: Re: Crash in ip_expire/icmp_send - 2.6.38.2 (Ubuntu 11.04 natty)
Date: Tue, 27 Dec 2011 22:48:53 -0500 (EST)
Message-ID: <20111227.224853.1945641698257880843.davem@davemloft.net>
References: <1325043141.4354.20.camel@boudreau>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tim@edgecast.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab1L1Ds4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 22:48:56 -0500
In-Reply-To: <1325043141.4354.20.camel@boudreau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Well known and fixed a long time ago, see the patch below.

Please reproduce bugs against current upstream kernels before
reporting the problem here, if it only occurs in the vendor's
kernel then the appropriate thing to do is to report it to
the vendor.

--------------------
commit 64f3b9e203bd06855072e295557dca1485a2ecba
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed May 4 10:02:26 2011 +0000

    net: ip_expire() must revalidate route
    
    Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
    added a bug in IP defragmentation handling, in case timeout is fired.
    
    When a frame is defragmented, we use last skb dst field when building
    final skb. Its dst is valid, since we are in rcu read section.
    
    But if a timeout occurs, we take first queued fragment to build one ICMP
    TIME EXCEEDED message. Problem is all queued skb have weak dst pointers,
    since we escaped RCU critical section after their queueing. icmp_send()
    might dereference a now freed (and possibly reused) part of memory.
    
    Calling skb_dst_drop() and ip_route_input_noref() to revalidate route is
    the only possible choice.
    
    Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a1151b8..b1d282f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -223,31 +223,30 @@ static void ip_expire(unsigned long arg)
 
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
+		const struct iphdr *iph;
+		int err;
 
 		rcu_read_lock();
 		head->dev = dev_get_by_index_rcu(net, qp->iif);
 		if (!head->dev)
 			goto out_rcu_unlock;
 
+		/* skb dst is stale, drop it, and perform route lookup again */
+		skb_dst_drop(head);
+		iph = ip_hdr(head);
+		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
+					   iph->tos, head->dev);
+		if (err)
+			goto out_rcu_unlock;
+
 		/*
-		 * Only search router table for the head fragment,
-		 * when defraging timeout at PRE_ROUTING HOOK.
+		 * Only an end host needs to send an ICMP
+		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (qp->user == IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
-			const struct iphdr *iph = ip_hdr(head);
-			int err = ip_route_input(head, iph->daddr, iph->saddr,
-						 iph->tos, head->dev);
-			if (unlikely(err))
-				goto out_rcu_unlock;
-
-			/*
-			 * Only an end host needs to send an ICMP
-			 * "Fragment Reassembly Timeout" message, per RFC792.
-			 */
-			if (skb_rtable(head)->rt_type != RTN_LOCAL)
-				goto out_rcu_unlock;
+		if (qp->user == IP_DEFRAG_CONNTRACK_IN &&
+		    skb_rtable(head)->rt_type != RTN_LOCAL)
+			goto out_rcu_unlock;
 
-		}
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
