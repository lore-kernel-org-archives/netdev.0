From: Borislav Petkov <petkov@uni-muenster.de>
Subject: Re: [PATCH] remove check_region from PnPWakeUp routine of Eepro ISA driver
Date: Thu, 22 Sep 2005 08:29:44 +0200
Message-ID: <20050922062943.GA31805@gollum.tnic>
References: <20050922060030.GB19049@gollum.tnic> <20050921230915.364f0ac9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965242AbVIVG30@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050921230915.364f0ac9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2005 at 11:09:15PM -0700, Andrew Morton wrote:
> Borislav Petkov <petkov@uni-muenster.de> wrote:
> >
> >  Hi,
> > 
> >  The following patch removes the check_region call in the PnPWakeUp
> >  path in the Eepro /10 ISA driver. Instead, now it calls request_region
> >  for the PnP wake up routine and, after succeeding, it calls release_region
> >  for the actual reservation of I/O ports takes place in the eepro_probe1() 
> >  function straight afterwards.
> > 
> >  Signed-off-by: Borislav Petkov <petkov@uni-muenster.de>
> > 
> > 
> > --- drivers/net/eepro.c.orig	2005-09-22 06:20:28.000000000 +0200
> > +++ drivers/net/eepro.c	2005-09-22 07:20:16.000000000 +0200
> > @@ -552,7 +552,7 @@ static int __init do_eepro_probe(struct 
> >  	{
> >  		unsigned short int WS[32]=WakeupSeq;
> >  
> > -		if (check_region(WakeupPort, 2)==0) {
> > +		if (request_region(WakeupPort, 2, DRV_NAME)) {
> >  
> >  			if (net_debug>5)
> >  				printk(KERN_DEBUG "Waking UP\n");
> > @@ -563,6 +563,8 @@ static int __init do_eepro_probe(struct 
> >  				outb_p(WS[i],WakeupPort);
> >  				if (net_debug>5) printk(KERN_DEBUG ": %#x ",WS[i]);
> >  			}
> > +			release_region(WakeupPort, 2);
> > +
> >  		} else printk(KERN_WARNING "Checkregion Failed!\n");
> >  	}
> >  #endif
> 
> hm, that's all a bit strange.  It would be better to do the
> request_region() just once and if that works, retain the reservation rather
> than releasing and reacquiring it.
I thought so at first too but was having problems with the call to
eepro_probe1() a bit further down where request_region() is called a second time
and this would have resulted in two consecutive calls to request_region for the
same region without freeing it. I guess in the actual __request_region() in the
while loop, during the second call IORESOURCE_BUSY will be returned meaning that
the region is already reserved?
> 
> That being said, the code you've modified is disabled due to
> !defined(PnPWakeup), and the chances of anyone ever changing that are close
> to zero.
should I remove it then altogether?

Regards,
		Boris.
