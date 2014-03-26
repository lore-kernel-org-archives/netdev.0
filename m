From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 19:46:05 +0000
Message-ID: <87y4zw7ngi.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:50286 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580AbaCZTqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:46:20 -0400
In-Reply-To: <1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 26 Mar 2014 08:25:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2014-03-26 at 15:13 +0000, Rainer Weikusat wrote:
>
>> (This is from memory) If there's a thread blocked in recv and another
>> blocked on the lock and the kernel selects the thread blocked on the lock
>> for handling the signal, the signal won't be handled until some data is
>> received on the socket, ie, possibly never.
>
> Look at what we do for AF_INET. We handle this the proper way.
>
> If we are 'interrupted' by a signal while sleeping in lock_sock(),
> recvmsg() on a non blocking socket, we return -EAGAIN properly, not
> -EINTR.
>
> Fact that we potentially sleep to get the socket lock is hidden for the
> user, its an implementation detail of the kernel.
>
> We never return -EINTR, as stated in manpage for non blocking sockets.

There is (to the best of my knowledge) no man page which specifically
states that "socket is non-blocking" means "receive operation can't be
interrupted by a signal before any data was received" and telling
userspace "no data is available right now" when the operation was
actually interrupted by a signal before checking is still inaccurate.
The underlying problem would seem to be that a O_NONBLOCK call might
actually block forever in case a blocking receiver sits on the lock and
no data is ever received. Hence my original suggestion that it should
use a trylock-operation. But there are presumably downsides to this as
well, I didn't really think through it.

As I already wrote, this is a theoretical problem with no really
satisfactory solution minus noting that both 'nonblocking sockets' and
'multithreaded kernels' are somewhat alien concepts when considering the
system where EINTR originated (AFAIK). Also, it doesn't really matter:
If it was commonly assumed that O_NONBLOCK would imply 'no EINTR', the
kernel should behave accordingly for pragmatic reasons, not because
"commonly assumed" is the same as "obviously correct" (although it is
not uncommon for people to assume that common assumption are
must be obviously correct because they're common assumptions :-).
