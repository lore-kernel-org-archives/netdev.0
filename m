From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Mon, 13 Feb 2017 22:56:46 +0100
Message-ID: <2337836.67BmyCWMtR@debian64>
References: <20160728012253.GT2356@ZenIV.linux.org.uk> <6129494.xvkFqTsVzW@debian64> <20170212054209.GQ13195@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Alan Curry <rlwinm@sdf.org>, alexmcwhirter@triadic.us,
        David Miller <davem@davemloft.net>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36377 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbdBMV67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 16:58:59 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so515016wmd.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 13:58:59 -0800 (PST)
In-Reply-To: <20170212054209.GQ13195@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, February 12, 2017 5:42:18 AM CET Al Viro wrote:
> On Sat, Feb 11, 2017 at 08:37:06PM +0100, Christian Lamparter wrote:
> 
> > I think if you follow through with this argument. You have the problem of:
> > How to handle EFAULT from skb_copy_datagram_* (and all it's "wrappers")?
> > 
> > Because on one hand, the iovec could be partially bad. I remember that 
> > the application could do the following shenanigans during recvmsg: 
> >  - mprotect() could've flipped page read-only and back to read-write.
> >  - Or truncate() could've shortened the mmapped file,
> >  - etc.
> > 
> > In this case the error should be propagated back to the userspace.
> > 
> > But OTOH, it could just be a temporary failure (*) and restoring the
> > iovec and trying again is needed.
> 
> No.  You can't _rely_ upon -EFAULT being repeated, but it's not something
> you would expect to retry your way out of.
> 
> The sane semantics is
> 	* fail read/recvmsg (with EFAULT) if it's a datagram socket
> 	* fail if it's a stream socket and nothing has been read by
> that point
> 	* a short read if something has been already read.
> 
> > Is this a correct/complete assessment of the problem at hand? Or did
> > I make a mistake / wrong assumption in there?
> 
> > I'm looking at:
> > <http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L4668>
> > <http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L5232>
> > <http://lxr.free-electrons.com/source/net/ipv4/tcp_input.c#L5465>
> > 
> > >From what I can see, the tcp functions tcp_data_queue(),
> > tcp_copy_to_iovec() and tcp_rcv_established() would need to be
> > extended to handle EFAULT. Because if the iovec is restored
> > and the application did something bad (mprotect(), truncate(),
> >  ...), this code would sort of loop?
> 
> tcp_v4_do_rcv() has every right to copy nothing whatsoever - it's a fastpath
> and when e.g. it's called in context of another thread or when skb isn't the
> next fragment expected it won't bother with tcp_copy_to_iovec() at all.
> Failure to copy anything in there is just fine, as long as you don't end
> up buggering tp->ucopy state (in particular, tp->ucopy.msg->msg_iter).
> 
> > If this is the case: How many retries do we want, before we can
> > say it is a permament failure (and abort)?
> 
> We don't want any.  What happens is that this path won't copy anything and
> when that skb gets to
>                         err = skb_copy_datagram_msg(skb, offset, msg, used);
>                         if (err) {
>                                 /* Exception. Bailout! */
>                                 if (!copied)
>                                         copied = -EFAULT;
>                                 break;
>                         }
> in tcp_recvmsg() we'll get our short read.
> 
> Again, the trouble is not with tcp_v4_do_rcv() failing to copy something -
> it's failing to copy and ending up with iov_iter advanced that might be
> a problem.  E.g. tp->ucopy.len getting out of sync with tp->ucopy.msg->msg_iter,
> etc.
> 
> Short read on fault is fine.  So's full copy if somebody had been flipping
> memprotect() and slow path ends up catching the moment when the buffer is
> writable.  Both outcomes are fine.  Having the same memprotect() flipping
> leave ->msg_iter more than one would expect by tp->ucopy.len and everything
> back with copy_to_user working again, OTOH, might confuse tcp_input.c.
> 
Ok, thank you for sticking around. As for the patch: I've tested it with
the dlbug program from <https://lkml.org/lkml/2016/7/26/25> (modified to
pull from a local server) and the netem corruption policy as described
in <https://lkml.org/lkml/2016/8/3/181>. 
It works as expected. I did not get a single corruption with the patch
applied. Without the patch: every try had corruptions in random places. 

Tested-by: Christian Lamparter <chunkeey@googlemail.com>

Regards,
Christian
