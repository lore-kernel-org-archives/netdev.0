From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [RFC net-next 1/5] bonding: 3ad: use curr_slave_lock instead of bond->lock
Date: Fri, 05 Sep 2014 18:08:08 -0700
Message-ID: <27301.1409965688@localhost.localdomain>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com> <1409941011-5494-2-git-send-email-nikolay@redhat.com> <23382.1409949468@localhost.localdomain> <540A247A.60202@redhat.com>
Cc: netdev@vger.kernel.org, vfalico@gmail.com, andy@greyhouse.net,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46345 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaIFBIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 21:08:15 -0400
In-reply-to: <540A247A.60202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>On 09/05/2014 10:37 PM, Jay Vosburgh wrote:
>> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> 
>>> In 3ad mode the only syncing needed by bond->lock is for the wq
>>> and the recv handler, so change them to use curr_slave_lock.
>>> There're no locking dependencies here as 3ad doesn't use
>>> curr_slave_lock at all.
>> 
>> 	One subtle aspect of the 3ad locking is that it's not really
>> using the "read" property of the read lock with regard to the state
>> machine; it's largely using it as a spin lock, because there is at most
>> one reader and at most one writer in the full state machine code
>> (although there are multiple reader possibilities elsewhere).  The code
>> would break if there actually were multiple read-lock holders in the
>> full state machine or aggregator selection logic simultaneously.
>> 
>> 	Because the state machine and incoming LACPDU cases both acquire
>> the read lock for read, there is a separate per-port "state machine"
>> spin lock to protect only the per-port fields that LACPDU and periodic
>> state machine both touch.  The incoming LACPDU case doesn't call into
>> the full state machine, only the RX processing which can't go into agg
>> selection, so this works.
>> 
>> 	The agg selection can be entered via the unbind path or the
>> periodic state machine (and only these two paths), and relies on the
>> "one reader max" usage of the read lock to mutex the code paths that may
>> enter agg selection.
>> 
>> 	I suspect that what 3ad may need is a spin lock, not a read
>> lock, because the multiple reader property isn't really being utilized;
>> the incoming LACPDU and periodic state machine both acquire the read
>> lock for read, but then acquire a second per-port spin lock.  If the
>> "big" (bond->lock currently) lock is a spin lock, then the per-port
>> state machine lock is unnecessary, as the only purpose of the per-port
>> lock is to mutex the one case that does have multiple readers.
>> 
>> 	In actual practice I doubt there are multiple simultaneous
>> readers very often; the periodic machine runs every 100 ms, but LACPDUs
>> arrive for each port either every second or every 30 seconds (depending
>> on admin configuration).
>> 
>> 	Since contention on these locks is generally low, we're probably
>> better off in the long run with something simpler to understand.
>> 
>> 	So, what I'm kind of saying here is that this patch isn't a bad
>> first step, but at least for the 3ad case, removal of the bond->lock
>> itself doesn't really simplify the locking as much as could be done.
>> 
>> 	Thoughts?
>> 
>> 	-J
>> 
>> 
>
>Hi Jay,
>That is a very good point, my main idea was to protect __bond_release_one
>and the machine handler otherwise I'd have removed it altogether. I know
>that this doesn't improve on the 3ad situation, I did it mostly to get rid
>of bond->lock first. Going with a spinlock certainly makes sense there as
>we don't spend much time inside and the contention is not high as you said
>and would simplify the 3ad code so I like it :-)
>I will include it in my bond-locking todo list and will post a follow-up
>once I've cleared the details up as I'm speaking from the top of my head
>right now, but first I'd like to clean the current lock use especially with
>regard to curr_slave_lock and bring it to the necessary minimum. In the
>long run I think that we either might be able to remove curr_slave_lock
>completely or at least reduce it to ~ 3 places and with the spinlock that
>you suggested here, we'll be definitely able to remove it from the 3ad code.

	I looked into curr_slave_lock some time ago, and as I recall
there's not much it really protects that's not also covered by RTNL,
since changes to the active slave are all happening under RTNL these
days.  And that was before the RCU conversion; with the current code,
I'm not sure the curr_slave_lock is providing much mutexing beyond what
we get from RTNL.

	There are a couple of special cases, like the TLB rebalance in
bond_alb_monitor, but that happens once every 10 seconds, and could just
grab RTNL for this bit:

			if (slave == rcu_access_pointer(bond->curr_active_slave)) {
				SLAVE_TLB_INFO(slave).load =
					bond_info->unbalanced_load /
						BOND_TLB_REBALANCE_INTERVAL;
				bond_info->unbalanced_load = 0;

	the "unbalanced_load," now that I'm looking at it, might already
have some race problems since it's now updated outside of bonding locks
in bond_do_alb_xmit.  It'll probably race with multiple bond_do_alb_xmit
functions running simultaneously as well as the tx rebalance in
bond_alb_monitor.  I think the worst that will happen is that the tx
traffic load is distributed suboptimally for 10 seconds.

	The rlb_clear_slave case that acquires curr_slave_lock already
also has RTNL, so I'm not sure that removing the curr_slave_lock will
have any impact there, either.  Many of the other curr_slave_lock
holders bounce the curr_slave_lock to call into net/core functions (set
promisc, change MAC, etc), so there's already reliance on RTNL.

	Separately, it also might be possible to combine the various
per-mode special locks internally into a generic "mode lock" so the alb
and rlb hashtbl lock and the 802.3ad state machine lock could be a
single "bond->mode_lock" that mutexes whatever special sauce the active
mode needs protected.  Not sure if that's worth the trouble or not, but
it seems plausible at first glance.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
