From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: What protects rcu_dereference() in __sk_free()?
Date: Thu, 14 Jan 2010 10:41:08 -0800
Message-ID: <20100114184107.GA17245@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dim@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:59025 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab0ANSlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 13:41:13 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0EISksQ016988
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:28:46 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0EIfCIQ1998940
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:41:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0EIfBAs028974
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 13:41:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dmitry,

Could you please tell me what protects the rcu_dereference() in
__sk_free()?  I am adding lockdep-based checking to RCU, and
"git blame" said I should ask you about this one.

The current code, rcu_dereference(), assumes that this is protected only
by RCU-bh.  My problem might be any of the following:

o	Some other flavor of RCU protects this, e.g., RCU-sched, which
	would require rcu_dereference_sched() in place of my current
	rcu_dereference_bh() for RCU-bh.

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

So, could you please tell me what protects the rcu_dereference() in
__sk_free() so that I can craft the appropriate form of rcu_dereference()?

							Thanx, Paul
