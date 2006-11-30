From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Thu, 30 Nov 2006 11:38:43 -0800
Message-ID: <200611301938.kAUJchgv020451@death.nxdomain.ibm.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:10182 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1031267AbWK3Tis
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:38:48 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUJcjZi031280
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 14:38:45 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUJcipm498110
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 12:38:44 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUJciTx010220
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 12:38:44 -0700
To: Andy Gospodarek <andy@greyhouse.net>
In-reply-to: <20061130162322.GA8772@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andy Gospodarek <andy@greyhouse.net> wrote:
>The main purpose of this patch is to clean-up the bonding code so that
>several important operations are not done in the incorrect (softirq)
>context. Whenever a kernel is compiled with CONFIG_DEBUG_SPINLOCK_SLEEP
>all sorts of backtraces are spewed to the log since might_sleep will
>kindly remind us we are doing something in a atomic context when we
>probably should not.
[...]

	I'll look at the patch in detail in a bit (and I have 802.3ad
switches to test on), but on first glance, does this not still hold a
lock during failover operations in balance-alb mode?  I.e., this doesn't
change the locking model, it just moves the timers to workqueues and
relaxes the _bh locking.

	The really problematic case calls dev_set_mac_address() with a
lock held, and I don't see that this patch changes that behavior.  Do
you still get the lock warnings during link fail / recovery in
balance-alb mode?

	Also, on an CONFIG_PREEMPT kernel, it'll still get the sleep
warnings, since in_atomic() will trip __might_sleep() for any lock (if
I'm reading things correctly).

	Don't get me wrong, this (switching to workqueues, etc) needs to
be done, but I don't think this patch really resolves the underlying
problem that causes the warnings.

	Let me see if I can dust off the extensive patch that does
change the locking model; I'll see if I can bring it up to the current
git and post it.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
