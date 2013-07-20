From: Eric Wong <normalperson@yhbt.net>
Subject: Re: strange crashes in tcp_poll() via epoll_wait
Date: Sat, 20 Jul 2013 02:03:18 +0000
Message-ID: <20130720020318.GA12731@dcvr.yhbt.net>
References: <1374251057.26476.17.camel@edumazet-glaptop>
 <20130719235008.GA4518@dcvr.yhbt.net>
 <1374279005.26476.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1374279005.26476.31.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-07-19 at 23:50 +0000, Eric Wong wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Hi Al
> > > 
> > > I tried to debug strange crashes in tcp_poll() called from
> > > sys_epoll_wait() -> sock_poll()
> > > 
> > > The symptom is that sock->sk is NULL and we therefore dereference a NULL
> > > pointer.
> > > 
> > > It's really rare crashes but still, it would be nice to understand where
> > > is the bug. Presumably latest kernels would crash in sock_poll() because
> > > of the sk_can_busy_loop(sock->sk) call.
> > > 
> > > We do test sock->sk being NULL in sock_fasync(), but epoll should be
> > > safe because of existing synchronization (epmutex) ?
> > 
> > It should be safe because of ep->mtx, actually, as epmutex is not taken
> > in sys_epoll_wait.
> 
> Hmm, it might be more complex than that for multi threaded programs : 
> 
> eventpoll_release_file()
> 
> The problem might be because a thread closes a socket while an event
> was queued for it.

But ep->mtx is also held when traversing the ready list with
ep_send_events_proc.

Can sock->sk somehow be NULL before hitting eventpoll_release_file?

> > I took a look at this but have not found anything.  I've yet to see this
> > this on my machines.
> > 
> > When did you start noticing this?
> 
> Hard to say, but we have these crashes on a 3.3+ based kernel.

So I don't think any of my epoll changes caused it.  Phew!

> Probability of said crashes is very very low.

This still worries me since I rely heavily on multi-threaded epoll.  I
don't have a lot of cores/CPUs, though, so maybe it's harder to trigger
any potential race as a result...
