From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 23:56:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004065629.GA94203@gaz.sfgoth.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil> <20031001054226.126cea7b.davem@redhat.com> <20031003022615.GA42593@gaz.sfgoth.com> <20031003065824.713627c6.davem@redhat.com> <20031003214541.GA73152@gaz.sfgoth.com> <20031003221640.19aa485f.davem@redhat.com> <20031004055526.GG73152@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031004055526.GG73152@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr wrote:
> I'm just trying to make the point that the spinlock (or rwlock, whatever)
> can't be held when we call atm_dev->{open,close}() since they can sleep.
> Which is why we need to do the three-step process I described in the
> earlier email.

Actually I guess there's two ways of doing it... so instead of

Method 1:
  1. Take rwlock for writing
  2. Search for {dev,vpi,vci} tuple.  If found, fail - otherwise add it
     as "inactive"
  3. Drop rwlock
  4. Take semaphore
  5. Call atm_dev->open()
  6. Drop semaphore
  7. Take rwlock for writing
  8. If open succeeded clear "inactive" flag.  If failed remove entry
  9. Drop rwlock

Method 2:
  1. Take semaphore
  2. Take rwlock for reading
  3. Search for tuple, if found fail
  4. Drop rwlock
  5. Call atm_dev->open
  6. Take rwlock for writing
  7. Add tuple to list
  8. Drop rwlock
  9. Drop semaphore

The second method has the advantage that you don't need the "inactive"
flag.  On the other hand, you have to wait for the semaphore before
you can return EADDRINUSE.

-Mitch
