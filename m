From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC] netns: keep vlan slaves on master netns move
Date: Mon, 27 Sep 2010 09:23:32 -0700
Message-ID: <m1fwwvqhob.fsf@fess.ebiederm.org>
References: <20100824115056.GA235835@jupiter.n2.diac24.net>
	<20100913114315.GA859019@jupiter.n2.diac24.net>
	<m1bp7z4v0m.fsf@fess.ebiederm.org> <4C9363CB.7050302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	David Lamparter <equinox@diac24.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54183 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933190Ab0I0QXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 12:23:45 -0400
In-Reply-To: <4C9363CB.7050302@trash.net> (Patrick McHardy's message of "Fri,
	17 Sep 2010 14:49:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Am 15.09.2010 04:10, schrieb Eric W. Biederman:
>> 
>> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> 
>> My inclination is that the best way to handle this is to would be to
>> push the device deletion for vlan and macvlan devices into the device
>> core, where we could get the advantage of batched deletions.
>
> We've added batched deletion to both about a year ago, what exactly
> is the problem?

My problem is that while the both have dellink implemented we
don't really batch their deletes as best we can.

For macvlan when the underlying device is unregistered we delete
each macvlan device one by one.

For vlans we do batch the deletes, but not in the same batch as
the underlying device.

>>  Right
>> now vlan and macvlan devices are the only devices I know of that cause
>> other devices to be removed during unregister, so removing that
>> specialness seems reasonable.
>
> Actually all devices can cause this when used as a lower device by
> vlan or macvlan. Both vlan and macvlan are useless without a lower
> device, so I don't see why we shouldn't remove them when the lower
> device is unregistered.

I definitely think we should remove the devices when the lower device
is destroyed/removed.  However unregistered is a slightly different
concept, and arguably macvlan and vlan devices are much more intimately
connected to their underlying device than that.

What I meant is we should implement the deletion differently.  By doing
something like having a list of all derived devices for a device, that
we could walk and call dellink on from rollback_registered_many.  In
theory that could destroy a whole pile of macvlan and vlan devices with
various different stackings one on the other all in the same batch.

Eric
