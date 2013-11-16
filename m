From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: don't return uninitialized addresses on concurrent socket shutdown
Date: Sat, 16 Nov 2013 23:43:30 +0100
Message-ID: <20131116224330.GF16541@order.stressinduktion.org>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com> <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com> <20131116054344.GG26901@order.stressinduktion.org> <20131116054814.GH26901@order.stressinduktion.org> <20131116191916.GC16541@order.stressinduktion.org> <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47543 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab3KPWnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 17:43:32 -0500
Content-Disposition: inline
In-Reply-To: <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 12:46:42PM -0800, Eric Dumazet wrote:
> On Sat, 2013-11-16 at 20:19 +0100, Hannes Frederic Sowa wrote:
> > If a blocking read waits on a socket which gets concurrently shut down we
> > return 0 as error and so indicate success to the socket functions which
> > thus copies an uninitialized stack allocated address back to the user.
> > 
> > Fix this by introducing a new AF_INVALID sa_family marker and check if the
> > recvmsg function overwrote it. In case it was not overwritten, clear the
> > address with zeros (AF_UNSPEC) before returning it to the user. IMHO we
> > should only increase msg.msg_namelen (if we have to truncate the address),
> > so don't clear msg.msg_namelen.
> > 
> > This patch fixes the problem for recvfrom, recvmsg and recvmmsg.
> > 
> > Reported-by: mpb <mpb.mail@gmail.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  include/linux/socket.h | 2 ++
> >  net/socket.c           | 6 ++++++
> >  2 files changed, 8 insertions(+)
> > 
> > diff --git a/include/linux/socket.h b/include/linux/socket.h
> > index 445ef75..bdf9205 100644
> > --- a/include/linux/socket.h
> > +++ b/include/linux/socket.h
> > @@ -182,6 +182,8 @@ struct ucred {
> >  #define AF_VSOCK	40	/* vSockets			*/
> >  #define AF_MAX		41	/* For now.. */
> >  
> > +#define AF_INVALID	((__kernel_sa_family_t)(~0U))
> > +
> >  /* Protocol families, same as address families. */
> >  #define PF_UNSPEC	AF_UNSPEC
> >  #define PF_UNIX		AF_UNIX
> > diff --git a/net/socket.c b/net/socket.c
> > index c226ace..8361e15 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -1834,6 +1834,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
> >  	if (!sock)
> >  		goto out;
> >  
> > +	address.ss_family = AF_INVALID;
> 
> 
> 	address.ss_family = AF_UNSPEC;

That might be possible. Because I was afraid that AF_UNSPEC could re misused
in some other protocols I decided to use the (what I think) more robust
AF_INVALID.

> 
> >  	msg.msg_control = NULL;
> >  	msg.msg_controllen = 0;
> >  	msg.msg_iovlen = 1;
> > @@ -1847,6 +1848,8 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
> >  	err = sock_recvmsg(sock, &msg, size, flags);
> >  
> >  	if (err >= 0 && addr != NULL) {
> > +		if (unlikely(address.ss_family == AF_INVALID))
> > +			memset(&address, 0, sizeof(address));
> 
> Why clearing 128 bytes, and return msg.msg_namelen null bytes to the
> user ?
> 
> What useful information will the user get from this ? Is this even
> documented ?
> 
> 
> >  		err2 = move_addr_to_user(&address,
> >  					 msg.msg_namelen, addr, addr_len);
> >  		if (err2 < 0)
> 
> I really don't think userland should expect to read 128 null bytes if it
> asked 128 bytes.
> 
> We can certainly return 2 null bytes (AF_UNSPEC) and comply with the
> documentation.
> 
> if (unlikely(address.ss_family == AF_UNSPEC))
> 	msg.msg_namelen = sizeof(address.ss_family);

I have thought about that:

I do think it is common to call recvfrom, process the packet and sendto
back a packet with the updated values from recvfrom. We accept AF_UNSPEC
on an IPv4 UDP socket and use the addresses as it would be a AF_INET
sockaddr. We only bail out if the port is 0.

It was my intend to at least clear the addressing portions of the regular
sockaddr_* structure for the user as it could be reused as explained
earlier and be allocated uninitialized on the stack (or reused, so
sending packet to a previous destination). I think it is very uncommon to
expect a non-error value on a recvfrom/recvmsg and have AF_UNSPEC in the
sockaddr.

(I erroneously stated that we could return the full 128 zero bytes, we only
clear 128 bytes and return only max(128, msg.msg_namelen). msg_namelen gets
updated by the recvmsg handler and that only iff we have this concurrent
shutdown and blocking read issue.)

If the socket structure is cleared a following sendto would produce a -EINVAL.

Maybe I am too sensible regarding such problems and will think about that a
bit more (and check for AF_INVALID/AF_UNSPEC).

Thanks,

  Hannes
