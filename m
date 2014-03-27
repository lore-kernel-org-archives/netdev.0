From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Thu, 27 Mar 2014 12:40:49 +0000
Message-ID: <87zjkb7r1q.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<87ha6k7jt7.fsf@sable.mobileactivedefense.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:40053 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946AbaC0MlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:41:04 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
	(David Laight's message of "Thu, 27 Mar 2014 09:36:30 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:
> From: Rainer Weikusat 
>> Rainer Weikusat <rw@sable> writes:
>> 
>> [...]
>> 
>> > The underlying problem would seem to be that a O_NONBLOCK call might
>> > actually block forever in case a blocking receiver sits on the lock and
>> > no data is ever received.
>> 
>> ... except that this probably cannot happen because O_NONBLOCK is a file
>> status flag and not a file descriptor flag.
>> 
>> NB: I've neither tested nor checked this.
>
> While dup() gives a second fd referring to the same kernel 'file'
> doing open("/dev/fd/4", ...) traditionally gives you an additional
> 'file' referring to the same vnode.
> For real files the file offset is in the 'file' structure, and
> I think the O_NONBLOCK flag is in the same place.
> Which means that is possible (but maybe not that usual or sensible)
> for a process to try a non-blocking read on a socket while another
> process is blocked in the read code.
>
> The same would be true for writes, and for writes to a datagram
> socket it might even make sense.
>
> In any case I expect EAGAIN to mean 'there is no data to read'
> not 'something happened and I didn't bother to look for data'.

The problem is really that the non-blocking thread shouldn't be
interruptible and hence, should never return an EINTR error because of
this. As shown elsewhere, this is not only a theoretical concern but
actually real bug, as a read-call made while the socket is non-blocking
may actually stop executing forever if a prior, blocking read call is
already blocked. When assuming that the non-blocking call should execute
in favour of a blocking call which is actually blocked, this could be
regarded as a 'priority inversion' problem. OTOH, there is not 'perfect'
solution, IOW, one which doesn't involve the non-blocking read to give
up without trying 'immediately before' it had succeeded had it tried.

The 'return EAGAIN in an EINTR situation' is really a lame attempt at
hiding the real problem. A slightly better idea would be that the
non-blocking call should use trylock and return EAGAIN if this didn't
succeed. This would at least prevent it from becoming blocked for an
indefinite time.

A possible improvement would be to record if the thread currently
holding the lock made a blocking or a non-blocking call and use a
non-interruptible wait for the latter case since the lock ought to
become free soon. Problem with this: Another blocking reader could
appear while the non-blocking one is waiting an grab the lock instead.
This could presumably be preventend, but I doubt it'll be worth the
effort for something which seems to be a corner case.

Lastly, the non-blocking read could wait for a bounded time and give up
afterwards. Which turns this into a 'tuning' problem because there's no
good way to determine the 'right' bounded time.

Considering all of this, the trylock-approach seems best to me. OTOH,
I'm find with any behaviour which does not restore the original 'lost
wakeup' bug and considering that "it is a standard procedure to harras
people who are so careless to contribute bug fixes to Linux until the
cow comes home and they'd better be quiet about that!", as Mr Eric
"/dev/null" Dumasomething explained, I certainly don't plan to turn this
conviction of mine into a proper patch.
