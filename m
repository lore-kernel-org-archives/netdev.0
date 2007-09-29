From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Sat, 29 Sep 2007 13:55:15 +0800
Message-ID: <20070929055515.GB1192@gondor.apana.org.au>
References: <46FD0117.9030407@hitachi.com> <E1IbSt7-000091-00@gondolin.me.apana.org.au> <20070928.214737.120464821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: satoshi.oshima.fk@hitachi.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2795 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750882AbXI2Fzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 01:55:36 -0400
Content-Disposition: inline
In-Reply-To: <20070928.214737.120464821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 09:47:37PM -0700, David Miller wrote:
>
> There are two things we (might) need to guard against, one local and
> one remote.

Right I was focusing on the local threat.

> If you do a per-user limit, apache would basically just stop at that
> redzone point.  In some sense making the attack more effective because
> then it's trivial to shut down an entire web server this way.

Having a per-user limit doesn't necessarily mean that we have
to apply the limit differently to how we apply the system-wide
limits.  We could keep exactly the same code as we have now but
check against a per-user limit instead of a system-wide one.

In other words your apache scenario will continue to work as is
even with a per-user limit.

Now where it does become useful is when we have a rogue local
user.  As it is that user can chew up all of the budgeted TCP
memory by simply not calling recvmsg.  As I've stated in the
other email, the existing rlimits don't help because they're
per-process rather than per-user.

BTW, this is not fatal for TCP because TCP provides a minimum
amount of memory for each socket even when we are over the
limit.  However, if we this was implemented for UDP without
a minimum guarantee then it'd be quite useless.
 
> I see no valid argument against doing something similar for sockets.
> Such a register_shrinker() handler for TCP could, for example, look
> for TCP flows which haven't made forward progress in more than a
> certain amount of time and attempt to trim SKB memory from them.

Yes I agree this would be quite useful for sending.  However, it'll
be tough to shrink skbs that we've already acked for but the app
for some reason has decided to leave in the socket by not calling
recvmsg.

> UDP and other datagram sockets are troublesome because the memory
> gets wholly tied up immediately during the send call and it's not
> easy to liberate anything.  The nice part about datagram sockets,
> however, is that they make forward progress quickly and their
> memory is liberated as soon as the device transmits the packet.
> They don't have to wait for ACKs, windows openning up, or anything
> like that to happen.

Agreed.  Also the recvmsg case I've described above is much
simpler for UDP as we can just go through all the sockets and
free skbs at random :)

> To be honest I don't even think UDP is much of a real problem for this
> reason.

It's not a hard problem but we do need to have some code for it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
