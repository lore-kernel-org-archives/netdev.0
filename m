From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Mon, 01 Oct 2007 22:57:06 +0900
Message-ID: <4700FCB2.9090906@hitachi.com>
References: <46FD0117.9030407@hitachi.com> <E1IbSt7-000091-00@gondolin.me.apana.org.au> <20070928.214737.120464821.davem@davemloft.net> <20070929055515.GB1192@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:40982 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbXJAN5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:57:11 -0400
Received: from mlsv10.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 1FECF37C88
	for <netdev@vger.kernel.org>; Mon,  1 Oct 2007 22:57:10 +0900 (JST)
In-Reply-To: <20070929055515.GB1192@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, Sep 28, 2007 at 09:47:37PM -0700, David Miller wrote:
>> There are two things we (might) need to guard against, one local and
>> one remote.
>
> Right I was focusing on the local threat.
>
>> If you do a per-user limit, apache would basically just stop at that
>> redzone point.  In some sense making the attack more effective because
>> then it's trivial to shut down an entire web server this way.
>
> Having a per-user limit doesn't necessarily mean that we have
> to apply the limit differently to how we apply the system-wide
> limits.  We could keep exactly the same code as we have now but
> check against a per-user limit instead of a system-wide one.
>
> In other words your apache scenario will continue to work as is
> even with a per-user limit.

I'm afraid that per-user limit won't work for system administrator,
because he can't know who is the rogue user in advance (before
such attack is made). And once the attack is made, system will
not responce because of the lack of memory for slab.

So if he only has per-user limit, he need to split the memory
budget for UDP to each user. The limit per user will be very
small if number of users in the system is large.


> Now where it does become useful is when we have a rogue local
> user.  As it is that user can chew up all of the budgeted TCP
> memory by simply not calling recvmsg.  As I've stated in the
> other email, the existing rlimits don't help because they're
> per-process rather than per-user.
>
> BTW, this is not fatal for TCP because TCP provides a minimum
> amount of memory for each socket even when we are over the
> limit.  However, if we this was implemented for UDP without
> a minimum guarantee then it'd be quite useless.

Hmm, I didn't realize that. Thank you for your good
suggestion. I will think of it.


>> I see no valid argument against doing something similar for sockets.
>> Such a register_shrinker() handler for TCP could, for example, look
>> for TCP flows which haven't made forward progress in more than a
>> certain amount of time and attempt to trim SKB memory from them.
>
> Yes I agree this would be quite useful for sending.  However, it'll
> be tough to shrink skbs that we've already acked for but the app
> for some reason has decided to leave in the socket by not calling
> recvmsg.
>
>> UDP and other datagram sockets are troublesome because the memory
>> gets wholly tied up immediately during the send call and it's not
>> easy to liberate anything.  The nice part about datagram sockets,
>> however, is that they make forward progress quickly and their
>> memory is liberated as soon as the device transmits the packet.
>> They don't have to wait for ACKs, windows openning up, or anything
>> like that to happen.
>
> Agreed.  Also the recvmsg case I've described above is much
> simpler for UDP as we can just go through all the sockets and
> free skbs at random :)
>
>> To be honest I don't even think UDP is much of a real problem for this
>> reason.
>
> It's not a hard problem but we do need to have some code for it.

I believe so. Currently, a nasty user can easily stop the system
without root privilege. This may not be a serious problem, but
this is the problem to be fixed.

