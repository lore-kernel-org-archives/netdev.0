From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 5/5] net: sock_aio_write: set CMSG_MSG_COMPAT flag if
 is_compat_task
Date: Fri, 26 Feb 2010 11:03:05 +0100
Message-ID: <20100226100305.GA16504@Chamillionaire.breakpoint.cc>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
 <1266583307-3049-6-git-send-email-fwestphal@astaro.com>
 <20100226.011646.257642830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:45282 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827Ab0BZKDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:03:09 -0500
Content-Disposition: inline
In-Reply-To: <20100226.011646.257642830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fwestphal@astaro.com>
> Date: Fri, 19 Feb 2010 13:41:47 +0100
> 
> > some programs (e.g. pluto ike daemon), send netlink data to the
> > kernel via write().
> > 
> > So far, the CMSG_MSG_COMPAT flag is not set in this case, which
> > results in the kernel interpreting the netlink data the wrong way.
> > 
> > An alternative solution is to switch userspace to sendmsg() when
> > using netlink sockets.
> > 
> > Cc: Johannes Berg <johannes@sipsolutions.net>
> > Signed-off-by: Florian Westphal <fwestphal@astaro.com>
> 
> I was about to apply this entire patch set, but thinking about this
> one patch we have to do it differently:
> 
> > @@ -837,6 +837,10 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
> >  	msg->msg_iov = (struct iovec *)iov;
> >  	msg->msg_iovlen = nr_segs;
> >  	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
> > +#ifdef CONFIG_COMPAT
> > +	if (is_compat_task())
> > +		msg->msg_flags |= MSG_CMSG_COMPAT;
> > +#endif
> >  	if (sock->type == SOCK_SEQPACKET)
> >  		msg->msg_flags |= MSG_EOR;
> >  
> 
> What if the kernel itself does a socket write, say from a software
> interrupt or to generate events in response to a user event,
> and the current process happens to be a compat task?
> 
> I think this could even occur for NFS perhaps?

I do not know. But it certainly shows that this patch should not be
applied.

> Anyways, that isn't going to work properly.
> 
> We might need to add ->compat_write to file operations to do
> it properly.

Fair enough.

If its necessary to set MSG_CMSG_COMPAT properly for plain
write() as well to have the patch set merged then
I'll see about adding such a ->compat_write and will resubmit
the entire set again once net-next opens again for 2.6.35.

Thanks,
	Florian
