From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 01:35:19 +0200
Message-ID: <20080827233519.GG26610@one.firstfloor.org>
References: <20080827223410.GC26610@one.firstfloor.org> <20080827.153907.157997966.davem@davemloft.net> <48B5DE9F.4010000@cosmosbay.com> <20080827.161504.183610665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34010 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbYH0Xcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:32:46 -0400
Content-Disposition: inline
In-Reply-To: <20080827.161504.183610665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 04:15:04PM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Aug 2008 01:09:19 +0200
> 
> > Not really, I suspect commit (a7ab4b501f9b8a9dc4d5cee542db67b6ccd1088b [TCPv4]: Improve BH latency in /proc/net/tcp) is responsible for longer delays.
> > Note that its rather old :
>  ...
> > We used to disable bh once, while reading the table. This sucked.
> > 
> > In case machine is handling trafic, we now are preemptable by softirqs
> > while reading /proc/net/tcp. Thats a good thing.
> 
> Yes, that would account for it, good spotting.
> 
> > By the way, I find Andi patch usefull. Same thing could be done for /proc/net/rt_cache.
> 
> Fair enough.  If you can cook up a quick rt_cache patch I'll toss it and
> Andi's patch into net-next so it can cook for a while.

Thanks. Here's a little followup patch that implements the same
optimization for inet_diag/ss.
 
-Andi

---

Add empty bucket optimization to inet_diag too

Skip quickly over empty buckets in inet_diag.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

Index: linux-2.6.27-rc4-misc/net/ipv4/inet_diag.c
===================================================================
--- linux-2.6.27-rc4-misc.orig/net/ipv4/inet_diag.c
+++ linux-2.6.27-rc4-misc/net/ipv4/inet_diag.c
@@ -782,11 +782,15 @@ skip_listen_ht:
 		struct sock *sk;
 		struct hlist_node *node;
 
+		num = 0;
+
+		if (hlist_empty(&head->chain) && hlist_empty(&head->twchain))
+			continue;
+
 		if (i > s_i)
 			s_num = 0;
 
 		read_lock_bh(lock);
-		num = 0;
 		sk_for_each(sk, node, &head->chain) {
 			struct inet_sock *inet = inet_sk(sk);
 
