From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [sungem] proposal for a new locking strategy
Date: Sun, 5 Nov 2006 09:02:54 -0800
Message-ID: <20061105090254.66710154@localhost.localdomain>
References: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
	<1162731940.28571.245.camel@localhost.localdomain>
	<5cac192f0611050517q297f5b04w7931788f6dfef3fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55742 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161369AbWKERDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 12:03:21 -0500
To: "Eric Lemoine" <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0611050517q297f5b04w7931788f6dfef3fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 5 Nov 2006 14:17:38 +0100
"Eric Lemoine" <eric.lemoine@gmail.com> wrote:

> On 11/5/06, Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > On Sun, 2006-11-05 at 14:00 +0100, Eric Lemoine wrote:
> > > Hi!
> > >
> > > Some (long) time ago benh wrote a blaming comment in sungem.c about
> > > that driver's locking strategy. That comment basically says that we
> > > probably don't need two spinlocks.
> >
> > Yeah :) Note that I mostly blamed myself there ... Just never found the
> > time to sit down a figure out a proper locking.
> 
> I actually did introduce tx_lock! So you could well have blamed me :-)
> 
> 
> >
> > > I agree!
> > >
> > > Proposal:
> > >
> > > Today's sungem effectively uses two spinlock's: "lock" and "tx_lock".
> > >
> > > "tx_lock" is held by the xmit function when sending out a packet. Lots
> > > of functions grab "tx_lock" not to mess up with xmit (gem_stop_phy(),
> > > gem_change_mtu(), etc.).
> > >
> > > All of these funcs also take "lock"!
> > >
> > > What we could do is remove "lx_lock", have the above functions take
> > > only "lock", and rely on dev->_xmit_lock to protect the xmit func from
> > > reentrance. In that case, obviously, the driver wouldn't feature LLTX
> > > anymore.
> >
> > We could probably do even better but yeah, a single lock is a good
> > start. Overall, I'm unhappy with the infrastructure provided by the
> > network stack though. (Might be better nowadays, but last I looked, for
> > example, I couldn't properly do things like stopping  MAPI poll from
> > set_multicast etc... due to locks held by the upper level).
> 
> What you said in your comment is that set_multicast and change_mtu
> cannot schedule() because the upper layer holds a spinlock. This is
> still the case actually.
> 
> >
> > > When (re-)configuring we'd now quiesce the device, with the new
> > > functions gem_netif_stop() and gem_full_lock(), in the same way as tg3
> > > does.
> > >
> > > gem_interrupt(), gem_poll(), and gem_start_xmit() could become lockless. Fast!
> > >
> > > Basically this proposal makes the data path faster, the control path
> > > slower, and simplifies the code by using one single spinlock within
> > > the driver.
> > >
> > > If the idea seems reasonable to you guys I can go ahead and cook up something...
> >
> > I certainly does. Bring on the patch ! :-)
> 
> Will arrange some time to do it.
> 
> Thanks for your quick response.
> 
> 

You could also just use net_tx_lock() now.
