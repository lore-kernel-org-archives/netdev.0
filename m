From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: What protects rcu_dereference() in __in6_dev_get()?
Date: Thu, 14 Jan 2010 10:32:15 -0800
Message-ID: <20100114183215.GA16866@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, mingo@elte.hu,
	akpm@linux-foundation.org, peterz@infradead.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42792 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848Ab0ANScW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 13:32:22 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0EIN4YU006957
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:23:04 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0EIWKra1552574
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:32:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0EIWJUg028575
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:32:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Yoshi,

Could you please tell me what protects the rcu_dereference() in
__in6_dev_get()?  I am adding lockdep-based checking to RCU, and
"git blame" said I should ask you about this one.

The current code, rcu_dereference(), assumes that this is protected only
by RCU.  My problem might be any of the following:

o	Some other flavor of RCU protects this, e.g., RCU-bh, which
	would require rcu_dereference_bh().

o	This is called from updates as well as from readers, and
	some lock protects the updates.

o	This is called during initialization, when this pointer is
	inaccessible to readers.
	
Please note that I can add a check to cover multiple possibilities.
For a real example in include/linux/fdtable.h:

	file = rcu_dereference_check(fdt->fd[fd],
				     rcu_read_lock_held() ||
				     lockdep_is_held(&files->file_lock) ||
				     atomic_read(&files->count) == 1);

The first argument is the pointer, and the second argument says that
this may be protected by either RCU (as opposed to RCU-bh, RCU-sched,
or SRCU), the files->file_lock as recorded by lockdep, or by being in
a single-threaded process as noted by the value of files->count.
(Please see http://lwn.net/Articles/368683/ for a recent patch, another
will go out soon.)

So, could you please tell me what protects the rcu_dereference()
in __in6_dev_get() so that I can craft the appropriate form of
rcu_dereference()?

							Thanx, Paul
