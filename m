From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Tue, 29 Jun 2010 11:58:30 +0200
Message-ID: <20100629095830.GA6775@amd64.fatal.se>
References: <20100628.233600.242129599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:52791 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826Ab0F2KO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 06:14:28 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id E9A7C141A2
	for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 11:53:05 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20100628.233600.242129599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all!

I'm sorry if I forgot to CC someone in this reply. I'm not subscribed
and all list archives seems to be very scared of showing recipiets
these days.

[...]
>
> I can understand the reasoning behind the limit, because if this is
> run by something automated it's not like someone is at the command
> line and hit Ctrl-C to break out of a looping instance.
>
> But practically speaking I bet this never happens.

I'm sorry to bring bad news, but your bet is wrong!

There are atleast two different places (IIRC route flush, addr flush)
in iproute2 which have these limits because they've been preventing
people from booting their systems in the past! I know atleast
ubuntu users has been having problems booting their computers because
firewalling scripts executed by init use iproute2 commands and
expect them to finish.

>
> So what makes sense to me is:
>
> 1) Loop forever by default.

I think this is a completely insane default. The iproute2 tools
are low-level and will be executed by higher level tools. Authors
of these higher level tools expect iproute2 commands to always finish.
Since iproute2 will *usually* finish, it's hard for these authors
that they need to add some switch to always get this behaviour.

>
> 2) When the number of loops exceeds a threshold (calculated by the
>    number of addresses we see the first dump, divided by the number
>    of deletes we can squeeze into the 4096 byte message), we emit
>    a warning.
>
> 3) A hard limit, off by default, it available via your "-l" new option.
>
> But seriously we can determine forward progress quite easily I think.
>
> Each loop, we see if the dump returns a smaller number of addresses
> than the last iteration.  If so, we just keep going.

This would be a much better solution!

>
> If the number of addresses increases, I think we can bail in this
> case.
>
> This logic would only ever trigger iff another entity is adding a
> large number of addresses simultaneously with our flush.  And frankly
> speaking the person doing the flush probably doesn't expect that to be
> happening.  You're flushing all of the addresses so you can start with
> a clean slate and then add specific addresses back, or whatever.
>

How about implementing it in the kernel so iproute2 can tell the kernel
via netlink "flush <addresses|routes> on interface X" with a single
netlink message?
I guess the kernel side has some kind of lock here that will prevent
addresses being added and removed at the same time?



Please think about this more before re-introducing the same problems again!

I guess with modern distributions now using parallell boot the issue
will not block the entire bootup anymore, but firewalls being blocked
forever by iproute2 and not coming up might be very bad in some circumstances.

-- 
Andreas Henriksson
