From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 14:45:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003214541.GA73152@gaz.sfgoth.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil> <20031001054226.126cea7b.davem@redhat.com> <20031003022615.GA42593@gaz.sfgoth.com> <20031003065824.713627c6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003065824.713627c6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> > My personal recommendations:
> >   * There should be a per-atm-device semaphore held across calls into the
> >     driver's ->open, ->close, ->change_qos and maybe a couple other things
> >     to serialize those operations (for the sake of keeping the drivers
> >     sane - there's no reason there should be multiple operations pending)
> 
> Ok, but what Chas is trying to do is move the ATM device stuff over
> to a model that makes use of the existing network device infrastructure
> for solving these kinds of problems.
> 
> Part of that is using the rtnl semaphore etc.
> 
> I would rather Chas use the rtnl semaphore for synchronization
> than to ultra-optimize this code by using the rwlock as I had suggested
> to him.

I have no problem with using rtnl_sem to syncronize the atmdev->{open,
close,change_qos}() paths instead of a per-device semaphore.

We *can't* use it to protect the state of the vcc list though because we
need to do lookups in both interrupt and bh context.  Using a sleeping
lock alone is a non-starter.

That's why we need to do the three-step spinlock->semaphore->spinlock
dance in the vcc open and close paths.

-Mitch
