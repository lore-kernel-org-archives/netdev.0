From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 14:25:13 +0000
Message-ID: <87a9cd82ba.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<8761n19k0w.fsf@sable.mobileactivedefense.com>
	<1395842972.12610.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:55039 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751232AbaCZOZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:25:26 -0400
In-Reply-To: <1395842972.12610.203.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 26 Mar 2014 07:09:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2014-03-26 at 13:17 +0000, Rainer Weikusat wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > Some applications didn't expect recvmsg() on a non blocking socket
>> > could return -EINTR. This possibility was added as a side effect
>> > of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
>> > unix recv routines").
>> >
>> > To hit this bug, you need to be a bit unlucky, as the u->readlock
>> > mutex is usually held for very small periods.
>> 
>> This would mean that 'some applications' are broken, cf
>> 
>> [EAGAIN] or [EWOULDBLOCK]
>>     The socket's file descriptor is marked O_NONBLOCK and no data is
>>     waiting to be received; or MSG_OOB is set and no out-of-band data is
>>     available and either the socket's file descriptor is marked
>>     O_NONBLOCK or the socket does not support blocking to await
>>     out-of-band data.
>> 
>> [EINTR]
>>     This function was interrupted by a signal before any data was
>>     available.
>>     
>> http://pubs.opengroup.org/onlinepubs/9699919799/functions/recvmsg.html
>> 
>> and
>> 
>>  EAGAIN or EWOULDBLOCK
>>               The socket is marked nonblocking and the receive operation
>>               would block, or a receive timeout had been set and the
>>               timeout expired before data was received.
>> 
>>  EINTR  The receive was interrupted by delivery of a signal before any
>>         data were available; see signal(7).
>> 
>> [3.27 Linux recvmsg(2)]
>> 
>> since the function was interrupted before any data was available and it
>> is unknown if the condition supposed to be signalled by EAGAIN had
>> otherwise occurred.
>> 
>> A correct 'fix'/ workaround would seem to be using mutex_trylock and
>> abort execution immediately with -EAGAIN in case the operation had to
>> wait for the lock, although this is inconsistent with the usual
>> semantics of 'blocking' which implies that the operation may take an
>> indefinite amount of time because it waits for an external event which
>> might never occur.
>
> Before your patch, -EAGAIN was delivered, -EINTR was _never_ delivered.
>
> Thats a fact.

Indeed. Before this change, a signal could silently get lost for reasons
I outlined in the original mail. This is now no longer the case.

> If you read the manpage, its in this order :
>
> When using a nonblocking socket, and no data is available, EAGAIN or
> EWOULDBLOCK is delivered.
>
> -EINTR is not expected from a non blocking system call. Period.

That's your interpretation of a text which doesn't say so unambigiously
(actually, it pretty much says the exact opposite) and I think this
interpretation is not correct for the reasons I gave (in particular,
that it is unknown if data is available and that EAGAIN implies that it
is known that data is not available).

This is a somewhat interesting problem from a theoretical standpoint,
because there is really no totally satisfactory solution, however, I'm
presently 'over-the-top' buried below a heap of seriously grotty and
misbehaving Java code. Consequently, I suggest to end this discussion
here.
