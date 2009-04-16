From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Thu, 16 Apr 2009 14:23:04 -0400
Message-ID: <200904161423.04414.paul.moore@hp.com>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp> <200904141859.57965.paul.moore@hp.com> <200904150512.n3F5CfDA008806@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:19410 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609AbZDPSXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 14:23:10 -0400
In-Reply-To: <200904150512.n3F5CfDA008806@www262.sakura.ne.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 April 2009 01:12:41 am Tetsuo Handa wrote:
> Hello.
>
> Paul Moore wrote:
> > Please submit a patch set that includes both this patch as well as a
> > patch to TOMOYO which makes use of these changes; this way we can
> > properly review your patches in context.

Thank you for sending a patchset with both TOMOYO and LSM/stack changes; this 
should give other developers who may not be familiar with TOMOYO a chance to 
review your code.  My comments/concerns about the LSM changes still stand, if 
it is decided to merge these changes I'll be happy to review the TOMOYO 
changes further.

> > > +	if (!(flags & MSG_PEEK))
> > > +		goto no_peek;
> > > +	/*
> > > +	 * If this packet is MSG_PEEK'ed, dequeue it forcibly
> > > +	 * so that this packet won't prevent the caller from picking up
> > > +	 * next packet.
> > > +	 */
> > > +	spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
> > > +	if (skb == skb_peek(&sk->sk_receive_queue)) {
> > > +		__skb_unlink(skb, &sk->sk_receive_queue);
> > > +		atomic_dec(&skb->users);
> > > +		/* Do I have something to do with skb->peeked ? */
> >
> > I don't know but you should find out before this code is merged :)
>
> Q1: Can I use skb_kill_datagram() here?
>
>     skb_kill_datagram() uses spin_lock_bh() while __skb_recv_datagram()
> uses spin_lock_irqsave(). Since this codepath is called inside
>     __skb_recv_datagram(), I used spin_lock_irqsave() rather than calling
>     skb_kill_datagram().

Since __skb_recv_datagram() is already using spin_lock_irqsave() it seems 
reasonable to do the same in your changes.  As far as skb->peeked is concerned 
I don't think it matters much since you are destroying the skb anyway.

> > > +no_peek:
> > > +	kfree_skb(skb);
>
> Q2: Do I need to use skb_free_datagram() here rather than kfree_skb()?
>
>     In the past ( http://lkml.org/lkml/2007/11/16/406 ), there was no
>     difference between skb_free_datagram() and kfree_skb().
>
>     | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
>     | {
>     | 	kfree_skb(skb);
>     | }
>
>     But now (as of 2.6.30-rc2), there is a difference.
>
>     | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
>     | {
>     | 	consume_skb(skb);
>     | 	sk_mem_reclaim_partial(sk);
>     | }

I don't know for certain, I would have to go look at other users of 
skb_free_datagram(), but it does look like using skb_free_datagram() instead 
of skb_free() might be preferable.

> Q3: Is __skb_recv_datagram() called from contexts that are not permitted to
>     sleep?
>
>     If so, TOMOYO has to check whether it is allowed to sleep, for TOMOYO
> will prompt the user "whether to allow App1 to read this datagram or not".

I believe __skb_recv_datagram() is only called via userspace so sleeping 
should not be an issue.

> Q4: Is there a way to distinguish requests from userland programs and
> requests from kernel code?

I'm not sure if this is the 100% correct way to do it, but in the past I have 
always checked current->mm, for kernel threads this will be NULL.

-- 
paul moore
linux @ hp

