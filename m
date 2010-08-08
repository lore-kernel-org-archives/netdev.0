From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: disable preemption before call smp_processor_id()
Date: Sat, 7 Aug 2010 21:57:51 -0700
Message-ID: <20100808045751.GF19600@linux.vnet.ibm.com>
References: <1281173162-10587-1-git-send-email-xiaosuo@gmail.com>
 <20100807.203700.186284252.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:44409 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab0HHE5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Aug 2010 00:57:54 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o784iYig028859
	for <netdev@vger.kernel.org>; Sun, 8 Aug 2010 00:44:34 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o784vrqs2367524
	for <netdev@vger.kernel.org>; Sun, 8 Aug 2010 00:57:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o784vqnx015147
	for <netdev@vger.kernel.org>; Sun, 8 Aug 2010 00:57:53 -0400
Content-Disposition: inline
In-Reply-To: <20100807.203700.186284252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 07, 2010 at 08:37:00PM -0700, David Miller wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Sat,  7 Aug 2010 17:26:02 +0800
> 
> > Although netif_rx() isn't expected to be called in process context with
> > preemption enabled, it'd better handle this case. And this is why get_cpu()
> > is used in the non-RPS #ifdef branch. If tree RCU is selected,
> > rcu_read_lock() won't disable preemption, so preempt_disable() should be
> > called explictly.
> > 
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Applied, thanks Changli.
> 
> Paul, perhaps the comment above rcu_read_lock()'s definition should
> be updated in rcupdate.h?  It says blocking is not allowed inside
> of a read side critical section, but obviously with tree-rcu that
> is not the case.
> 
> Either we should add a mention of tree-rcu's semantics or just remote
> this part of the comment altogether.

Good point, that last sentence is quite obsolete.  It also survived a
recent cleanup.  :-/

If I cover preemptible RCU's semantics, a first cut comes out like this:

 * In non-preemptible RCU implementations (TREE_RCU and TINY_RCU), it
 * is illegal to block while in an RCU read-side critical section.  In
 * preemptible RCU implementations (TREE_PREEMPT_RCU and TINY_PREEMPT_RCU)
 * in CONFIG_PREEMPT kernel builds, RCU read-side critical sections may
 * be preempted, but explicit blocking is illegal.  Finally, in preemptible
 * RCU implementations in real-time (CONFIG_PREEMPT_RT) kernel builds,
 * RCU read-side critical sections may be preempted and they may also
 * block, but only when acquiring spinlocks that are subject to priority
 * inheritance.

Does that seem reasonable?

							Thanx, Paul
