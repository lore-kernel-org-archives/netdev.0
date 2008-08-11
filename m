From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Mon, 11 Aug 2008 16:26:57 -0700
Message-ID: <20080811232657.GQ6762@linux.vnet.ibm.com>
References: <20080810190458.GA7279@ami.dom.local> <20080811100126.GA6401@ff.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38795 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbYHKX06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 19:26:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7BNQvgJ022011
	for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 19:26:58 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7BNQvCm145716
	for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 17:26:57 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7BNQumo027311
	for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 17:26:57 -0600
Content-Disposition: inline
In-Reply-To: <20080811100126.GA6401@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 10:01:26AM +0000, Jarek Poplawski wrote:
> On 10-08-2008 21:04, Jarek Poplawski wrote:
> ...
> > Hmm.. Actually, it's completely unreasonable. Let's forget this.
> 
> But accidentally it might even sometimes work here...
> 
> Currently, the most suspicious place to me seems to be
> __netif_schedule(). Is it legal to store RCU protected pointers out of
> rcu_read_lock() sections?

Yes, but:

1.	You need to use one of the update-side primitives to do the
	store: rcu_assign_pointer(), list_add_rcu(), etc.

2.	There has to be some way for multiple updaters to coordinate,
	for example:

	a.	Only a single task is permitted to update.

	b.	Locking is used to coordinate among multiple updaters
		(so that only one such updater may proceed at a given
		time).

	c.	Atomic operations are used to coordinate multiple
		updaters.  Here be dragons, go for (a) or (b)
		instead unless you have an extremely good reason
		-and- you have both a proof of correctness and
		a totally brutal and malign test suite.

The main reason to update RCU-protected pointers within rcu_read_lock()
regions is when sharing code between RCU readers and updaters, or when
an RCU reader can see the need to do an update.

							Thanx, Paul
