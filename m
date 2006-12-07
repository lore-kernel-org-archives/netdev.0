From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Wed, 06 Dec 2006 22:46:37 -0800
Message-ID: <200612070646.kB76kbgv004791@death.nxdomain.ibm.com>
References: <20061130162322.GA8772@gospo.rdu.redhat.com> <200611301938.kAUJchgv020451@death.nxdomain.ibm.com> <bdfc5d6e0611301215o3e3e0c73wb22156b57ba7ed0f@mail.gmail.com> <200612050049.kB50nwgv023439@death.nxdomain.ibm.com> <bdfc5d6e0612061801wc276619l3c4b6d498ca4e8fd@mail.gmail.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36990 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031727AbWLGGqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:46:40 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB76kdBZ024794
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 01:46:39 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB76kdKm228146
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 01:46:39 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB76kdUs006022
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 01:46:39 -0500
To: "Andy Gospodarek" <andy@greyhouse.net>
In-reply-to: <bdfc5d6e0612061801wc276619l3c4b6d498ca4e8fd@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> wrote:

>On 12/4/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
[...]
>>         Appended is my working development patch for rearranging a bunch
>> of stuff in bonding.  This is a work in progress, and is not likely to
>> be very stable.  This largely reimplements the entire link monitor
>> scheme, along with associated locking changes.  It's not split into
>> functional pieces, and is just a big kitchen sink blob at the moment.
>> It's still very experimental.
[...]
>Thanks for sending it.  I've finally got some time to digest it.  I
>didn't get a chance to test it, but I did have a chance to take a look
>at it in detail.

	I think the patch might have been over the size limit for
netdev, as I never saw it appear on the list.  For interested readers,
the description Andy mentions in his next paragraph is:

	By way of description, in the patch, all monitors (link state
and mode specific bits for ALB and 802.3ad) are all dispatched from a
single workqueue (rather than each on a separate timer), and the updelay
/ downdelay parameters are done as special monitors.  The monitors can
be paused for purposes of conflict avoidance, although some mutexing
with TX activity is still necessary.  It also allows for the ARP and MII
link monitors to run simultaneously (which isn't allowed in the current
mainline driver).

	This also splits up the slave lists into an "all" and an
"active" list, rearranges the release processing for bonding
(consolidates duplicated code from bond_release and bond_release_all
into a common function).  I'm still dithering as to whether or not this
is a good idea; it adds a little complexity to link state changes and
add/remove of slaves, but simplifies most of the transmit processing.

	The locking still needs some adjustment; there's some tracking
of whether or not RTNL is held, and right now most locking is of the _bh
variety, which may be too strict.

>I certainly agree with the design points you laid out in your
>description.  I like the fact that you've restructured a lot of the
>code and moved the monitoring to a common place.  It is also nice to
>have it in one spot so you can report link status and bond membership.
> I don't think the bh-locking is necessary since the workqueues
>eliminate the possibility that you will be preempted by the bonding
>driver -- I dropped them all from my patch.

	The only concern I had in that regard is whether it's possible
to get into a bonding transmit function from someplace that requires _bh
level locking to mutex against.  I'm thinking in particular of packet
receive processing somewhere turning around to do a transmit right away.

>Overall this seems like a good way to go, but it [obviously] seems
>like it would be good to work towards this functionality rather than
>simply dumping this huge blob all at once.

	I absolutely agree that moving in steps to a final resolution is
much better than dropping a big blob; the patch ended up this way since
it's just a big diff from my experimental tree.

[...]  I would like to use a
>smaller patch to switch to workqueues (my patch or a partial of yours
>-- it makes no difference to me) as a start with the intent to let
>that soak-in for a while and follow it with chunks that will
>eventually get the entire driver closer to the functionality that your
>big patch has.

	I don't see a problem in starting with your patch; the end state
will be sufficiently different (e.g., the four workqueues would
ultimately be consolidated into one) that it's still a good testbed to
start with.

	The only other minor issue is that after this week, I will be
off for the holidays (and far, far away from email) for the next month.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
