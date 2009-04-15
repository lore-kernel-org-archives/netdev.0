From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 15 Apr 2009 14:12:41 +0900
Message-ID: <200904150512.n3F5CfDA008806@www262.sakura.ne.jp>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp> <200904141859.57965.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904141859.57965.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Paul Moore wrote:
> Please submit a patch set that includes both this patch as well as a
> patch to TOMOYO which makes use of these changes; this way we can properly
> review your patches in context.

I see.

I have some questions.

> > +	if (!(flags & MSG_PEEK))
> > +		goto no_peek;
> > +	/*
> > +	 * If this packet is MSG_PEEK'ed, dequeue it forcibly
> > +	 * so that this packet won't prevent the caller from picking up
> > +	 * next packet.
> > +	 */
> > +	spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
> > +	if (skb == skb_peek(&sk->sk_receive_queue)) {
> > +		__skb_unlink(skb, &sk->sk_receive_queue);
> > +		atomic_dec(&skb->users);
> > +		/* Do I have something to do with skb->peeked ? */
> 
> I don't know but you should find out before this code is merged :)

Q1: Can I use skb_kill_datagram() here?

    skb_kill_datagram() uses spin_lock_bh() while __skb_recv_datagram() uses
    spin_lock_irqsave(). Since this codepath is called inside
    __skb_recv_datagram(), I used spin_lock_irqsave() rather than calling
    skb_kill_datagram().
> 
> > +	}
> > +	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
> > +no_peek:
> > +	kfree_skb(skb);

Q2: Do I need to use skb_free_datagram() here rather than kfree_skb()?

    In the past ( http://lkml.org/lkml/2007/11/16/406 ), there was no
    difference between skb_free_datagram() and kfree_skb().
    | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
    | {
    | 	kfree_skb(skb);
    | }
    But now (as of 2.6.30-rc2), there is a difference.
    | void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
    | {
    | 	consume_skb(skb);
    | 	sk_mem_reclaim_partial(sk);
    | }

> >  no_packet:
> >  	*err = error;
> >  	return NULL;

Q3: Is __skb_recv_datagram() called from contexts that are not permitted to
    sleep?

    If so, TOMOYO has to check whether it is allowed to sleep, for TOMOYO will
    prompt the user "whether to allow App1 to read this datagram or not".

Q4: Is there a way to distinguish requests from userland programs and requests
    from kernel code?

    Some kernel code (e.g. NFS) sends/receives UDP packets to deal requests
    from userland program's requests. TOMOYO wants to distinguish "direct
    requests" (requests issued by userland programs, such as open()/read()/
    write() against files on NFS) and "indirect requests" (requests issued by
    reasons of kernel's own which are needed to handle "direct requests", such
    as fetching file data from NFS server). But currently, TOMOYO can't
    distinguish these requests. As a result, those who use NFS have to give
    permissions for sending/receiving UDP packets to/from NFS server to all
    userland programs.
    This means that TOMOYO allows userland programs to send/receive crafted
    packets to/from NFS server. I want to solve this problem.

Regards.
