From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Tue, 27 Mar 2012 09:47:40 -0700
Message-ID: <20120327164740.GS2450@linux.vnet.ibm.com>
References: <4F70E308.7070908@candelatech.com>
 <20120326.174945.1186427809261872546.davem@davemloft.net>
 <4F70E560.3020102@candelatech.com>
 <4F70F688.6050108@candelatech.com>
 <1332805148.3547.14.camel@edumazet-glaptop>
 <4F70FFE0.7070204@candelatech.com>
 <1332806834.3547.16.camel@edumazet-glaptop>
 <20120327051120.GM2450@linux.vnet.ibm.com>
 <4F71508C.908@candelatech.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:58611 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab2C0QsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 12:48:21 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 27 Mar 2012 10:48:20 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 55ACEC40008
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 10:48:17 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2RGmEas152004
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 10:48:14 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2RGlkAg001846
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 10:47:47 -0600
Content-Disposition: inline
In-Reply-To: <4F71508C.908@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 10:30:52PM -0700, Ben Greear wrote:
> On 03/26/2012 10:11 PM, Paul E. McKenney wrote:
> >On Tue, Mar 27, 2012 at 02:07:14AM +0200, Eric Dumazet wrote:
> >>On Mon, 2012-03-26 at 16:46 -0700, Ben Greear wrote:
> >>
> >>>The 3.0.21 kernel doesn't appear to have a rcu_read_lock_return(),
> >>>so I can't use your patch below.
> >>
> >>This patch was only to show the point (I also CCed Paul, he might have
> >>some time to think about it, after he clears the inline stuff with
> >>Linus)
> >
> >There is an rcu_preempt_depth() that returns rcu_read_lock() nesting
> >level for CONFIG_PREEMPT_RCU=y on the one hand and returns zero
> >for CONFIG_PREEMPT_RCU=n on the other.  So if you can reproduce
> >with CONFIG_PREEMPT_RCU=y, you can substitute rcu_preempt_depth()
> >rcu_read_lock_return() in Eric's earlier patch.
> 
> I'll try looking at that tomorrow.  I tried adding some code to check for
> recursive calls to the fib-dump, and didn't see it ever hit, though
> the bug continued to happen readily.
> 
> I just #if 0 the part between rcu-read-lock and read-unlock, and
> the problem went away..but of course you can't dump ipv6
> routes then...
> 
> The actual logic to dump the fib is quite complex, full of
> opaque types and other stuff ripe for bugs.  But, I don't see
> how it could cause the rcu splats in such a repeatable manner.
> 
> The bug is always reported as being in the same place, so if
> there is any other debugging code you can think of to help
> shed light on this, I'll be happy to add it and give it a try.
> For instance, is there a way to dump (print) all current holders of
> the rcu_read_lock?  I could call that before/during/after in that
> method and maybe get a clue.

I would guess that CONFIG_PROVE_RCU's use of lockdep would permit
listing all tasks holding rcu_read_lock(), as lockdep does maintain
that state in that case.

							Thanx, Paul
