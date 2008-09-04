From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] pci: VPD access timeout increase
Date: Thu, 4 Sep 2008 09:32:35 -0700
Message-ID: <20080904093235.30ade46b@extreme>
References: <20080827204626.4b65862f@extreme>
	<20080828111323.GI7908@solarflare.com>
	<20080903155713.7fab2e19@extreme>
	<20080904125219.GJ2772@parisc-linux.org>
	<20080904141944.GE7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58271 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404AbYIDQci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 12:32:38 -0400
In-Reply-To: <20080904141944.GE7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Sep 2008 15:19:46 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Matthew Wilcox wrote:
> > On Wed, Sep 03, 2008 at 03:57:13PM -0700, Stephen Hemminger wrote:
> > > Accessing the VPD area can take a long time. There are comments in the
> > > SysKonnect vendor driver that it can take up to 25ms.  The existing vpd
> > > access code fails consistently on my hardware.

It's bad but not that bad more details are:

				MIN		MAX
 -------------------------------------------------------------------
 write				1.8 ms		3.6 ms
 internal write cyles		0.7 ms		7.0 ms
 -------------------------------------------------------------------
 over all program time	 	2.5 ms		10.6 ms
 read				1.3 ms		2.6 ms
 -------------------------------------------------------------------
 over all 			3.8 ms		13.2 ms


Usable VPD is limited to 2K so worst case read is 27 seconds.
Note: there doesn't appear to be an standard for VPD size register in
PCI spec, but there is a device specific register.

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

Why not, it makes sense to allow killing a stuck modprobe.
