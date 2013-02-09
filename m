From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH 1/1] eventfd: implementation of EFD_MASK flag
Date: Sat, 9 Feb 2013 03:54:31 +0000
Message-ID: <20130209035431.GA28448@dcvr.yhbt.net>
References: <1360219292-19754-1-git-send-email-sustrik@250bpm.com>
 <20130207144433.527ef024.akpm@linux-foundation.org>
 <5114F2D8.5020300@250bpm.com>
 <20130208222107.GA4762@dcvr.yhbt.net>
 <5115B720.2080207@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5115B720.2080207@250bpm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Sustrik <sustrik@250bpm.com> wrote:
> On 08/02/13 23:21, Eric Wong wrote:
> >Martin Sustrik<sustrik@250bpm.com>  wrote:
> >>To address the question, I've written down detailed description of
> >>the challenges of the network protocol development in user space and
> >>how the proposed feature addresses the problems.
> >>
> >>It can be found here: http://www.250bpm.com/blog:16
> >
> >Using one eventfd per userspace socket still seems a bit wasteful.
> 
> Wasteful in what sense? Occupying a slot in file descriptor table?
> That's the price for having the socket uniquely identified by the
> fd.

Yes.  I realize eventfd is small, but I don't think eventfd is needed
at all, here.  Just one pipe.

> >Couldn't you use a single pipe for all sockets and write the efd_mask to
> >the pipe for each socket?
> >
> >A read from the pipe would behave like epoll_wait.
> >
> >You might need to use one-shot semantics; but that's probably
> >the easiest thing in multithreaded apps anyways.
> 
> Having multiple sockets represented by a single eventfd. how would
> you distinguish where did individual events came from?
> 
>   struct pollfd pfd;
>   ...
>   poll (pfd, 1, -1);
>   if (pfd.revents & POLLIN) /* Incoming data on which socket? */
>     ...

No eventfd, you write just write struct to the pipe, and consume the
struct to a fixed size buffer:

/* trigger readiness notification for sock,
 * this probably needs a lock around it
 */
void sock_trigger(struct my_sock *sock, int events)
{
	struct efd_mask mask;

	/* check if the triggeered event is something sock wants: */
	events &= sock->watched_events;

	if (!events)
		return;

	mask.events = events;
	mask.ptr = sock;

	/*
	 * preventing sock from being in the pipe multiple times
	 * is probably required (or just a good idea).  Which is
	 * why I mentioned oneshot semantics are probably required.
	 */
	if (oneshot)
		sock->watched_events = 0;

	/*
	 * This is analogous to:
	 *   list_add_tail(&epi->rdllink, &ep->rdllist);
	 * in fs/eventpoll.c
	 *
	 * This may block, but that's why consumer_loop runs in different
	 * threads.  Or run some iteration of consumer_loop here if
	 * it blocks (beware of stack depth from recursion, though)
	 */
	write(pipe_wr, &mask, sizeof(mask));
}

/* in another thread (or several threads) */
void consumer_loop(int pipe_rd)
{
	struct efd_mask mask;
	struct my_sock *sock;

	for (;;) {
		/*
		 * analogous to:
		 *    epoll_wait(.., maxevents=1, ...);
		 *
		 * You can read several masks at once if have one thread,
		 * but I usually use maxevents=1 (+several threads) to
		 * distribute traffic between threads
		 */
		read(pipe_rd, &mask, sizeof(mask));
		sock = mask.ptr;
		if (mask.events & POLLIN)
			sock_read(sock);
		else if (mask.events & POLLOUT)
			sock_write(sock);
		...

		/* analogous to epoll_ctl() */
		if (sock->write_buffered)
			sock->watched_events |= POLLOUT;
		if (sock->wants_more_data)
			sock->watched_events |= POLLIN;

		/* onto the next ready event */
	}
}
