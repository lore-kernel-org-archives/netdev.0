From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 22:55:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004055526.GG73152@gaz.sfgoth.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil> <20031001054226.126cea7b.davem@redhat.com> <20031003022615.GA42593@gaz.sfgoth.com> <20031003065824.713627c6.davem@redhat.com> <20031003214541.GA73152@gaz.sfgoth.com> <20031003221640.19aa485f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003221640.19aa485f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> > We *can't* use it to protect the state of the vcc list though because we
> > need to do lookups in both interrupt and bh context.  Using a sleeping
> > lock alone is a non-starter.
> > 
> > That's why we need to do the three-step spinlock->semaphore->spinlock
> > dance in the vcc open and close paths.
> 
> The semaphore protects "modifications", it basically serializes them.
> 
> You still need a rwlock to protect the actual lists and this rwlock
> is what the interrupt/bh context code takes to traverse the lists
> and tables.

I think we're saying approximately the same thing at this point.

I'm just trying to make the point that the spinlock (or rwlock, whatever)
can't be held when we call atm_dev->{open,close}() since they can sleep.
Which is why we need to do the three-step process I described in the
earlier email.

Once you do that there's no reason (that I know of) to take rtnl_sem
except to serialize the actual calls into atm_dev's ops.  There's no
problem if multiple opens both get their vpi/vci's allocated in
"inactive" state as long as the actual connects happen in series.

-Mitch
