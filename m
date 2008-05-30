From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup mode
Date: Fri, 30 May 2008 00:15:45 -0700
Message-ID: <28012.1212131745@death>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com> <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com> <12513.1212013148@death> <483E847A.9090508@voltaire.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34671 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738AbYE3HQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 03:16:05 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4U7FmSF022709
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 03:15:48 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4U7FmuT159468
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 03:15:48 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4U7Fm8V029492
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 03:15:48 -0400
In-reply-to: <483E847A.9090508@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> wrote:

>Jay Vosburgh wrote:
[...]
>> 	Your case is similar: you want to issue a notifier call during
>> an active-backup failover, so that notifier call will have to be made
>> holding RTNL and no other locks.
>>
>> 	I think the most maintainable way to do that is to convert the
>> remaining callers of bond_change_active_slave to hold the correct set of
>> locks, and then have bond_change_active_slave drop down to just RTNL at
>> the appropriate place to make the notifier call.  That may not be as
>> simple as it sounds, as it may open race windows.
>>
>Lets say that everyone calls bond_change_active_slave with the correct
>locks taken and the code that delivers the event, unlocks these two locks,
>call to the notifier chain through dev_set_xxx() and then locks them
>again. These locks were there in the first place to protect on something,
>so generally speaking I don't see why its allowed to unlock them for some
>window of time... is it some "best effort" compromise?

	Not exactly.  The unlock/lock dance doesn't release RTNL, so we
know that slaves cannot be added or removed (because that requires
RTNL).  Generally speaking, slaves can't have their up/down status
changed, either, since that would also acquire RTNL.

	However, the curr_slave_lock is still needed, particularly for
the alb mode.  All of the paths that can change the curr_active_slave
now hold RTNL (which is reasonable, as it's generally a pretty rare
event).  However, not all of the paths that inspect curr_active_slave
hold RTNL, so some places (alb mode in particular) need a mutex to keep
the curr_active_slave from changing during various activities, but
holding RTNL for those things is unreasonable (e.g., bond_alb_xmit would
need it for every packet).

	It's probably possible to do away with the curr_slave_lock
entirely (and just use the bond->lock).  That will still have some
windows like this, since there will be places that hold bond->lock for
read and have to temporarily upgrade it to a write lock (which I think
would be all of the places that now hold curr_slave_lock for write).

>Second, if it makes sense to have this window at time where the other two
>locks are not taken and only the RTNL one is taken. Is there any reason I
>can't take the approach of bond_alb_handle_active_change() which as you
>pointed out, releases the locks, delivers the event and take them again?
>is there something different between the possible calls under the
>active-backup mode vs the ALB mode that requires to do this deeper fix?

	I'm suggesting you do exactly that: release the locks, do your
stuff, then reacquire the locks.

	The concern for you is that there are still a few calls to
bond_change_active_slave that will never enter the ALB path, and those
calls to bond_change_active slave don't necessarily have the correct set
of locks at present.  

	The location of your new notifier call is such that there's no
way for it to know whether bond_change_active_slave was called with the
full set of locks (e.g., from one of the link monitors), or some other
set (as from bond_release_all), so some of the remaining calls to
bond_change_active_slave will likely need to be updated with regard to
locking.

	I took a look, and I think this is how it stands: I recently
refactored the active-backup ARP monitor, and I believe that all of its
calls are now correct; this would have been the difficult one to fix, so
you timed this just right.  The load-balance ARP monitor is still wrong,
but you don't care about that one since it isn't used for active-backup
mode.

	I think the only cases that will require fixing for you are the
bond_release and bond_release_all.

	For bond_release, there are two calls to change_active: one sets
it to NULL, and the second sets to to a slave.  The first of those calls
has nominally incorrect locking; the second has proper locking.
Changing the first call to mimic the methodology of the second call
should be pretty straightforward.  Alternately, if your notifier doesn't
want to log "change to nothing" events (i.e., put it inside the "if
(new_active)" block), then you could probably get away with not fixing
the first call.

	For bond_release_all, there's just one call, and it sets the
current slave to NULL (and then goes off and frees all of the slaves).
The same caveats from the bond_release case apply here.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
