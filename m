From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Mon, 22 Apr 2013 10:56:38 +0200
Message-ID: <1366620998.4141.28.camel@weser.hi.pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	 <CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
	 <CAHrpEqQyG68v4VMDNEwcobhHqkuP_ORH9KA3OZD=2xAoJCMNOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58191 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab3DVI5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:57:42 -0400
In-Reply-To: <CAHrpEqQyG68v4VMDNEwcobhHqkuP_ORH9KA3OZD=2xAoJCMNOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Am Samstag, den 20.04.2013, 20:35 +0800 schrieb Frank Li:
> 2013/4/20 Fabio Estevam <festevam@gmail.com>
> >
> > Lucas,
> >
> > On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> > > Those patches introduce instability to the point of kernel OOPSes with
> > > NULL-ptr dereferences.
> > >
> > > The patches drop locks from the code without justifying why this would
> > > be safe at all. In fact it isn't safe as now the controller restart can
> > > happily free the RX and TX ring buffers while the NAPI poll function is
> > > still accessing them. So with a heavily loaded but slightly instable
> 
> I think a possible solution is disable NAPI in restart function.
> So only one thread can reset BD queue.
> 
> BD queue is nolock design.
> 
It doesn't matter at all that the hardware BD queue is designed to be
operated lockless, you still have to synchronize the driver functions to
each other and explicit locks are a far better way to achieve this than
some implicit tunneling through a single thread or other such things.

Let us please try and concentrate on making things safe and easy to
understand and not introduce possibilities for breakage in the future,
when the next change goes into the driver.

> Can you provide test case?
> 
The test case is already described in my original mail: heavily loaded
link, so NAPI has to do some spinning in the receive function while
having the link flapping.

> > > link we regularly end up with OOPSes because link change restarts
> > > the FEC and bombs away buffers still in use.
> > >
> > > Also the NAPI enabled interrupt handler ACKs the INT and only later
> > > masks it, this way introducing a window where new interrupts could sneak
> > > in while we are already in polling mode.
> > >
> > > As it's way too late in the cycle to try and fix this up just revert the
> > > relevant patches for now.
> >
> > What about restoring the spinlocks and masking the int first?
> >
While reintroducing the spinlocks might fix the problem (I'll retest
that today) we are now holding a big lock for extended periods of time,
so while we are spinning in the receive poll function we are not able to
enqueue new TX buffers. This is also a problem with the original
patches, as they are mashing together the TX and RX interrupts.

Dave, even if the reverts are intrusive I'm still not convinced that we
should try and fix this up in the short period of time we have left
until the 3.9 final release.

To fix all this properly we would have to fix at least the following
things:
1. Split up the spinlock into two independent locks for RX and TX.
Interrupt handlers should only take their respective lock, things like
the FEC restart, who want to mess with both queues have to take both
locks.
2. Move locking to the right places, there is zero reason why the
adjust_link PHY callback has to take the locks, but rather FEC restart
should take them.
3. Introduce separate NAPI contexts for RX and TX, to get around one of
them blocking the other.

I doubt this will be less intrusive than reverting the offending patches
for now and taking a new stab at NAPI support in the next cycle.

Also I suspect the patch "net: fec: put tx to napi poll function to fix
dead lock" to introduce a more subtle problem in the ring buffer
accounting (why does this patch even change the way ring buffers are
tracked?) which triggers on rarer occasions, but I have to test if this
is still there with the lock added back.

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
