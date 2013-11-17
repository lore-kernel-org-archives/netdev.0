From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: don't return uninitialized addresses on concurrent socket shutdown
Date: Sun, 17 Nov 2013 20:22:40 +0100
Message-ID: <20131117192240.GI16541@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com> <20131116054344.GG26901@order.stressinduktion.org> <20131116054814.GH26901@order.stressinduktion.org> <20131116191916.GC16541@order.stressinduktion.org> <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com> <20131116224330.GF16541@order.stressinduktion.org> <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48589 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab3KQTWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 14:22:42 -0500
Content-Disposition: inline
In-Reply-To: <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 04:36:24PM -0800, Eric Dumazet wrote:
> On Sat, 2013-11-16 at 23:43 +0100, Hannes Frederic Sowa wrote:
> 
> > I do think it is common to call recvfrom, process the packet and sendto
> > back a packet with the updated values from recvfrom. We accept AF_UNSPEC
> > on an IPv4 UDP socket and use the addresses as it would be a AF_INET
> > sockaddr. We only bail out if the port is 0.
> > 
> > It was my intend to at least clear the addressing portions of the regular
> > sockaddr_* structure for the user as it could be reused as explained
> > earlier and be allocated uninitialized on the stack (or reused, so
> > sending packet to a previous destination). I think it is very uncommon to
> > expect a non-error value on a recvfrom/recvmsg and have AF_UNSPEC in the
> > sockaddr.
> > 
> > (I erroneously stated that we could return the full 128 zero bytes, we only
> > clear 128 bytes and return only max(128, msg.msg_namelen). msg_namelen gets
> > updated by the recvmsg handler and that only iff we have this concurrent
> > shutdown and blocking read issue.)
> > 
> > If the socket structure is cleared a following sendto would produce a -EINVAL.
> > 
> > Maybe I am too sensible regarding such problems and will think about that a
> > bit more (and check for AF_INVALID/AF_UNSPEC).
> > 
> 
> I think the _default_ should be to clear it.
> 
> -	msg.msg_namelen = sizeof(address);
> +	msg.msg_namelen = 0;
> 
> And subsystems filling a real address would set it back to the length
> they took care of.
> 
> in recvfrom() paths, the kernel _knows_ it uses an array of 128 bytes.
> (struct sockaddr_storage)

I agree, that's the only sane approach we can take. Both the AF_UNSPEC and
also the AF_INVALID approach does conflict how packet sockets structure their
sockaddr_pkt (dev->type is put in sa_family and both 0 and 0xFFFF are valid
interface types).

I'll check it out.

Thanks,

  Hannes
