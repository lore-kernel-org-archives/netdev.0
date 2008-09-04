From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 1/3] pci: VPD access timeout increase
Date: Thu, 4 Sep 2008 10:10:51 -0600
Message-ID: <20080904161051.GL2772@parisc-linux.org>
References: <20080827204626.4b65862f@extreme> <20080828111323.GI7908@solarflare.com> <20080903155713.7fab2e19@extreme> <20080904125219.GJ2772@parisc-linux.org> <20080904141944.GE7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080904141944.GE7908@solarflare.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2008 at 03:19:46PM +0100, Ben Hutchings wrote:
> Matthew Wilcox wrote:
> > On Wed, Sep 03, 2008 at 03:57:13PM -0700, Stephen Hemminger wrote:
> > > Accessing the VPD area can take a long time. There are comments in the
> > > SysKonnect vendor driver that it can take up to 25ms.  The existing vpd
> > > access code fails consistently on my hardware.
> > 
> > Wow, that's slow.  If you were to try to read all 32k, it'd take more
> > than three minutes!  (I presume it doesn't actually have as much as 32k).
> > 
> > > Change the access routines to:
> > >   * use a mutex rather than spinning with IRQ's disabled and lock held
> > >   * have a longer timeout
> > >   * call schedule while spinning to provide some responsivness
> > 
> > I agree with your approach, but have one minor comment:
> > 
> > > -	spin_lock_irq(&vpd->lock);
> > > +	mutex_lock(&vpd->lock);
> > 
> > This should be:
> > 
> > +	if (mutex_lock_interruptible(&vpd->lock))
> > +		return -EINTR;
> [...]
> 
> This is fine for the sysfs case, but not if this is called during device
> probe - we don't want signals to modprobe to break device initialisation,
> do we?

Probably only fatal signals -- in which case the if (signal_pending)
check should be a fatal_signal_pending() and mutex_lock_interruptible()
should be mutex_lock_killable().

OTOH, who's signalling modprobe to do anything other than die?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
