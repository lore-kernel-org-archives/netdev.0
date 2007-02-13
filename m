From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 14:26:28 -0800
Message-ID: <200702132226.l1DMQS22009230@death.nxdomain.ibm.com>
References: <200702091623.l19GNiUP006513@fire-2.osdl.org> <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	lpiccilli@gelre.com.br,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:35978 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbXBMW0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 17:26:34 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1DMQXOn029368
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 17:26:33 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1DMQX9t232664
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 17:26:33 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1DMQWsu008594
	for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 17:26:33 -0500
In-reply-to: <20070213202905.GA26818@gospo.rdu.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

[...]
>I've been working off and on for a little while to resolve these issues
>and even posted a patch not long ago to address some these by removing
>the timers and using workqueues instead.  This enabled resolution of
>quite a few of the issues with bonding since the code was no longer
>running in an atomic context and could now more easily take locks.
[...]
>On the side I've also been working to keep the timers and take the rtnl
>lock in the correct place so avoid messages like these:

	I've also been giving this some thought.

	I'm all in favor of moving the timers to work queues, and
eventually dispatching all of the various things from a single common
handler.  The advantage of concentrating everything like that it
effectively mutexes all of the timer things against one another, and
disabling (pausing) the work queue then provides mutexing against any of
the things that are dispated by timed events.  That single thread can
acquire rtnl when it needs to, which mutexes against the user initiated
events (add or remove slave, change active, etc) since those also hold
rtnl.  Some of that is further down the road, but I've prototyped it
out.

	In reference to Andy's recent patch (which first did conditional
locking for rtnl, then later acquired rtnl for every entry into the
timer function), I know the conditional locking isn't popular, but it
seems to me that it's a less bad alternative than holding rtnl every
time the bond_mii_monitor() runs (typically 10 - 50 times per second).
Or is the rtnl lock really so cheap that this isn't an issue?  The
overwhelming majority of cases the mii_monitor won't need to do anything
that requires rtnl, so only holding it when needed is better.

	Moving the slave lists to read copy doesn't help with this
particular problem, as it's necessary to read copy unlock before going
into something that might sleep (which is the big problem, when the alb
code calls dev_set_mac_address()).  Unless I'm misremembering how RCU
hangs together.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
