From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Fw: rcu warning
Date: Wed, 22 Sep 2010 16:11:13 -0700
Message-ID: <20100922231113.GR2435@linux.vnet.ibm.com>
References: <20100922214438.GN2435@linux.vnet.ibm.com>
 <20100922144736.baf75544.akpm@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34734 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540Ab0IVXLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Sep 2010 19:11:15 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MMpKBU012244
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 18:51:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MNBEdM349114
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 19:11:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MNBEak030214
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 19:11:14 -0400
Content-Disposition: inline
In-Reply-To: <20100922144736.baf75544.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 22, 2010 at 02:47:36PM -0700, Andrew Morton wrote:
> On Wed, 22 Sep 2010 14:44:38 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > In linux/master, there is an rcu_read_lock_bh() in the call path, but
> > an rcu_dereference() instead of an rcu_dereference_bh().  Thoughts?
> > 
> > (I have asked Andrew what kernel this is against -- I don't see the
> > rcu_read_lock() that I would expect to see in the lockdep output.)
> 
> current linux-next.

Thank you!!!

OK, here we have __in_dev_get_rtnl() called from ip_route_output_slow().
I might be missing something, but I don't see either an rcu_read_lock()
or an RTNL acquisition in ip_route_output_slow().

But the call to __in_dev_get_rtnl() simply compares to NULL, so I don't
understand why this can't instead call __in_dev_get_rcu().  Given that
there are a number of places where the return value from __in_dev_get_rtnl()
is compared to NULL, one approach would be to have something like the
following:

	static inline int __in_dev_check_null(const struct net_device *dev)
	{
		return rcu_dereference_raw(dev->ip_ptr) == NULL;
	}

Thoughts?

							Thanx, Paul
