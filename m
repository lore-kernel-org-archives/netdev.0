From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [iproute PATCH 0/2] Netns performance improvements
Date: Fri, 08 Jul 2016 03:12:28 -0500
Message-ID: <87zipsv98z.fsf@x220.int.ebiederm.org>
References: <1467729773-16751-1-git-send-email-phil@nwl.cc>
	<87twg4ywjz.fsf@x220.int.ebiederm.org>
	<20160705205103.GE620@orbyte.nwl.cc>
	<87h9c259ip.fsf@x220.int.ebiederm.org>
	<20160707111718.GL620@orbyte.nwl.cc> <577E5244.8030601@6wind.com>
	<20160707154809.GN620@orbyte.nwl.cc> <577E8054.6040603@hpe.com>
	<87vb0h1k6b.fsf@x220.int.ebiederm.org> <577E914F.3060001@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Phil Sutter <phil@nwl.cc>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35616 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbcGHIZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 04:25:17 -0400
In-Reply-To: <577E914F.3060001@hpe.com> (Rick Jones's message of "Thu, 7 Jul
	2016 10:28:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hpe.com> writes:

> On 07/07/2016 09:34 AM, Eric W. Biederman wrote:
>> Rick Jones <rick.jones2@hpe.com> writes:
>>> 300 routers is far from the upper limit/goal.  Back in HP Public
>>> Cloud, we were running as many as 700 routers per network node (*),
>>> and more than four network nodes. (back then it was just the one
>>> namespace per router and network). Mileage will of course vary based
>>> on the "oomph" of one's network node(s).
>>
>> To clarify processes for these routers and dhcp servers are created
>> with "ip netns exec"?
>
> I believe so, but it would be good to have someone else confirm that, and speak
> to your paragraph below.

>> If that is the case and you are using this feature as effectively a
>> lightweight container and not lots vrfs in a single network stack
>> then I suspect much larger gains can be had by creating a variant
>> of ip netns exec avoids the mount propagation.
>>
>
> ...
>
>>> * Didn't want to go much higher than that because each router had a
>>> port on a common linux bridge and getting to > 1024 would be an
>>> unpleasant day.
>>
>> * I would have thought all you have to do is bump of the size
>>    of the linux neighbour cache.  echo $BIGNUM > /proc/sys/net/ipv4/neigh/default/gc_thresh3
>
> We didn't want to hit the 1024 port limit of a (then?) Linux bridge.

Silly linux bridge.  I haven't run into that one.

> Having a bit of deja vu but I suspect things like commit
> 0818bf27c05b2de56c5b2bd08cfae2a939bd5f52  are not exactly on the same
> wavelength, just my brain seeing "namespaces" and "performance" and lighting-up
> :)

Actually that could still be relevant. 100,000 or so mount entries
is larger than the 16384 of mount entries on the machine I am looking
at.  Given an expected avearage hash chain length of 6.  So it might be
worth playing with the mhash= and mphash= kernel command line entries
and seeing if upping the count helps.  For upstream is probably very
much worth looking at making the mount hash an rhashtable so it grows to
the size it is needed.

I looked a little more and I see where the double mounts are coming
from.  Because "ip netns" creates /var/run/netns as a local bind mount
of itself we get one copy of the mounts below the bind mount and
another copy above.  Ugh.

Unfortunately I think the way the first patch solves this (by breaking
mount propagation with the parent) will fail to do the right thing in
caseses where "ip netns add" is called from a mount namespace with just
a private /tmp like systemd creates to run services in.  If we break the
mount propagation is broken by making the bind mount private I can't see
how the network namespace file descriptor mounts would propagate to the
rest of the ordinary mount namespaces in the system.

Unfortunately the semantics of the mount propgation directives were not
designed for easy use.  It seems extremly easy to do the wrong thing.

So I think the correct way to avoid double mounts and to safely and
reliably do what patch 1 is trying to do is to read /proc/self/mountinfo
and see if /var/run/netns is under a shared mount point (possibly
itself).  If so do go on to creating the mountpoint for the netns file
descriptor.  Otherwise make /var/run/netns a bind mount to itself and
ensure it is marked MS_SHARED.

Effectively that is runtime detection of systemd.  But since it keys off
of what is actually happening on the system it will work in whatever
strange environment "ip netns" happens to be run in.

Eric
