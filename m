From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Wed, 6 Oct 2004 23:49:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006234912.66bfbdcc.davem@davemloft.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
In-Reply-To: <20041007075319.6b31430d@jack.colino.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004 07:53:19 +0200
Colin Leroy <colin@colino.net> wrote:

> On 06 Oct 2004 at 16h10, Matt Mackall wrote:
> 
> > On Wed, Oct 06, 2004 at 11:25:44PM +0200, Colin Leroy wrote:
> > Well this doesn't look unreasonable, but I haven't run into it with
> > the NICs I've tested. Nor have I seen this reported before. Which NICs
> > is this with?
> 
> Sungem. I didn't find anything strange in sungem, but it may be...

I think this is very strange that only sungem behaves this
way.

I don't think netpoll is doing anything different than what
would happen, f.e., when bringing an interface up using dhcp.
That should cause the same kind of hang.

The only thing that should make the thing spin is if gp->hw_running
is zero.  This is set non-zero by gem_open() after resetting the
chip to bring it up.

If gem_open() fails, and on entry gp->hw_running was zero, the chip
will be powered back down and gp->hw_running set back to zero.
gem_suspend()/gem_resume() also modify the gp->hw_running state, as
appropriate.

I could see it that if gp->hw_running is non-zero, we could run into
troubles.  np->dev->poll_controller() will run, and it won't do anything
since the gem_interrupt() call is a nop when gp->hw_running is zero.
Then we blindly call ingo np->dev->poll()

Folks debugging this should verify that gp->hw_running is non-zero when
the problematic case runs.
