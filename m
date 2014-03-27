From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Thu, 27 Mar 2014 13:29:41 +0000
Message-ID: <878urvpy62.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<87ha6k7jt7.fsf@sable.mobileactivedefense.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EA4FF@AcuExch.aculab.com>
	<87zjkb7r1q.fsf@sable.mobileactivedefense.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EA7FB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:52313 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754638AbaC0N34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:29:56 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EA7FB@AcuExch.aculab.com>
	(David Laight's message of "Thu, 27 Mar 2014 12:53:58 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:
> From: Rainer Weikusat 
>> Considering all of this, the trylock-approach seems best to me. OTOH,
>
> No - using trylock() is definitely wrong.
> If there are two messages queued and two processes/threads try to
> read them, you don't want one of them being given EAGAIN.

I'd consider this acceptable because a second message could also come in
at the very moment the 2nd reader gives up. This is the 'next simplest
approach' after 'returning EAGAIN instead of EINTR' and I think it is a
little less non-desirable because it avoids the mixed blocking/
non-blocking problem (presently, I don't see why this shouldn't work,
ie, a process which inherited a socket ought to be able to switch that
to non-blocking mode and then call recv without risking to stop
executing for 'a long time'), and it is still reasonably simple (although
the problem is likely rather contrived).

Anything beyond that would involve priorising non-blocking readers over
blocking ones and let them wait uninterruptedly in case the lock is
presently held by another non-blocking reader. But this would be a whole
lot more complicated and even waiting for a blocking reader might work
just fine if a message arrives soon enough. Which then again means "it
should wait some time uninterruptedly in any case" but how much time?

The whole issue would neatly "not exist" if only one process could ever
be executing kernel code at any given time, but since is not the case
anymore, some kind of 'heuristic solution based on a tradeoff' is
necessary.
