From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: Slab Corruption with ipv6 and tcp6fuzz
Date: Sun, 27 Apr 2008 09:25:42 -0400
Message-ID: <1209302742.29301.137.camel@tng>
References: <20080425125230.GA12343@alice>
	 <20080425130946.GA1019@2ka.mipt.ru> <20080426160519.GA5697@2ka.mipt.ru>
	 <20080426.230549.230699327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, snakebyte@gmx.de, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, dada1@cosmosbay.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:47739 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbYD0OJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 10:09:05 -0400
In-Reply-To: <20080426.230549.230699327.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll take a look asap - thanks for the cc:, I've been away.

-Patrick

On Sat, 2008-04-26 at 23:05 -0700, David Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Sat, 26 Apr 2008 20:05:20 +0400
> 
> Patrick, please look at this, your defer-accept changes are causing
> crashes.  See below.
> 
> Eric, I'm CC:'ing you because you ACK'd some of this stuff :-))
> 
> > On Fri, Apr 25, 2008 at 05:09:46PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > On Fri, Apr 25, 2008 at 02:52:30PM +0200, Eric Sesterhenn (snakebyte@gmx.de) wrote:
> > > > > > [  215.103103]  [<c0671e3b>] tcp_v6_do_rcv+0x33b/0xcd0
> > > > > 
> > > > > So far can you run kernel with debug turned on and provide output of
> > > > > gdb ./vmlinux
> > > > > l *(tcp_v6_do_rcv+0x33b)
> > > > 
> > > > l *(tcp_v6_do_rcv+0x33b)
> > > > Using host libthread_db library "/lib/tls/i686/cmov/libthread_db.so.1".
> > > > (gdb) l *(tcp_v6_do_rcv+0x33b)
> > > > 0xc0671e3b is in tcp_v6_do_rcv (net/ipv6/tcp_ipv6.c:1670).
> > > > 1665    reset:
> > > > 1666            tcp_v6_send_reset(sk, skb);
> > > > 1667    discard:
> > > > 1668            if (opt_skb)
> > > > 1669                    __kfree_skb(opt_skb);
> > > > 1670            kfree_skb(skb);
> > > > 1671            return 0;
> > > > 1672    csum_err:
> > > > 1673            TCP_INC_STATS_BH(TCP_MIB_INERRS);
> > > > 1674            goto discard;
> > > 
> > > Well, first possible error path:
> > > 
> > > tcp_v6_do_rcv()->tcp_rcv_established(), the latter goes to step5, where
> > > eventually skb can be freed via tcp_data_queue() (drop: label), then if
> > > check for tcp_defer_accept_check() returns true and thus
> > > tcp_rcv_established() returns -1, which forces tcp_v6_do_rcv() to jump
> > > to reset: label, which in turn will pass through discard: label and free
> > > the same skb again.
> > >  
> > > > Here is the programm itself...
> > > 
> > > I will work on this this weekend, thank you.
> >
> > Ok, I can not reproduce it, so lets try hard way.
> > Can you test attached patch, its idea is described above and I checked
> > multiple times, that it is forbidden to free skb and return non-zero
> > value from tcp_rcv_established(). This behaviour was introduced with TCP
> > defer accept changes in 2.6.25 with
> > ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 commit.
> > 
> > Please test. This bug affects both ipv6 and ipv4 code actually.
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index ac9b848..0298f80 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4925,8 +4925,7 @@ step5:
> >  	tcp_data_snd_check(sk);
> >  	tcp_ack_snd_check(sk);
> >  
> > -	if (tcp_defer_accept_check(sk))
> > -		return -1;
> > +	tcp_defer_accept_check(sk);
> >  	return 0;
> >  
> >  csum_error:
> > 
> > 
> > -- 
> > 	Evgeniy Polyakov

