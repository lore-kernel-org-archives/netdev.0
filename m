From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] b44: fix resume, request_irq after hw reset
Date: Tue, 12 Oct 2010 00:27:15 -0700
Message-ID: <20101012002715.fd0e3371.akpm@linux-foundation.org>
References: <201010120022.13171.james@albanarts.com>
	<20101011163440.072e0227.akpm@linux-foundation.org>
	<201010120808.05713.james@albanarts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>,
	Jiri Pirko <jpirko@redhat.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: James Hogan <james@albanarts.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201010120808.05713.james@albanarts.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2010 08:08:05 +0100 James Hogan <james@albanarts.com> wrote:

> > > @@ -2309,6 +2303,12 @@ static int b44_resume(struct ssb_device *sdev)
> > > 
> > >  	netif_device_attach(bp->dev);
> > >  	spin_unlock_irq(&bp->lock);
> > > 
> > > +	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, 
> dev);
> > > +	if (rc) {
> > > +		netdev_err(dev, "request_irq failed\n");
> > > +		return rc;
> > > +	}
> > > +
> > > 
> > >  	b44_enable_ints(bp);
> > >  	netif_wake_queue(dev);
> > 
> > OK, running the interrupt handler before b44_init_hw() is presumably
> > the problem here.
> > 
> > The hardware surely won't be generating interrupts until we've run
> > b44_init_hw() and b44_enable_ints(), so this patch really is only to
> > keep CONFIG_DEBUG_SHIRQ happy.
> 
> For me it's mainly to keep CONFIG_DEBUG_SHIRQ happy (Fedora has this switched 
> on), but since it's a shared IRQ, there is still a chance it could be 
> called before enabling it's own interrupts by a different device on the same 
> IRQ.

ooh, yes, you're right, I forgot about that.  It's indeed a bug.

> It makes sense to me why it's disabling the IRQ now, in case another device 
> triggers it when it cannot handle it safely.

What code are you referring to here?  There's no disable_irq() in that area?

> I also tried calling the 
> interrupt directly before the free_irq in the suspend function to check that 
> it wasn't being done too late, and it didn't fail, so possibly it is the core 
> suspension that makes it start failing until it is brought back up properly.
