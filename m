From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 7/7] initdev:kernel:Await block device discovery
Date: Mon, 8 Jun 2009 15:30:19 -0700
Message-ID: <20090608223019.GC22222@cuplxvomd02.corp.sa.net>
References: <20090606023416.GA5798@cuplxvomd02.corp.sa.net> <4A2A3F36.4070408@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A2A3F36.4070408@s5r6.in-berlin.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 06, 2009 at 06:04:38AM -0400, Stefan Richter wrote:
> David VomLehn wrote:
> > --- a/init/do_mounts.c
> > +++ b/init/do_mounts.c
> > @@ -358,6 +358,18 @@ void __init mount_root(void)
> >  #endif
> >  }
> >  
> > +/**
> > + * root_present - determine whether the root device is available yet
> > + *
> > + * Returns true if the root device is available, false if not. The check to
> > + * see if the root device is available is done by check to see whether it
> > + * has been assigned a major/minor device number.
> > + */
> > +static bool root_present(void)
> > +{
> > +	return name_to_dev_t(saved_root_name) != 0;
> > +}
> > +
> >  /*
> >   * Prepare the namespace - decide what/where to mount, load ramdisks, etc.
> >   */
> > @@ -398,12 +410,21 @@ void __init prepare_namespace(void)
> >  		goto out;
> >  
> >  	/* wait for any asynchronous scanning to complete */
> > -	if ((ROOT_DEV == 0) && root_wait) {
> > +	if (ROOT_DEV == 0) {
> >  		printk(KERN_INFO "Waiting for root device %s...\n",
> >  			saved_root_name);
> > -		while (driver_probe_done() != 0 ||
> > -			(ROOT_DEV = name_to_dev_t(saved_root_name)) == 0)
> > -			msleep(100);
> > +		if (root_wait) {
> > +			while (driver_probe_done() != 0 ||
> > +				(ROOT_DEV = name_to_dev_t(saved_root_name)) ==
> > +					0)
> > +				msleep(100);
> > +		}
> > +
> > +		else {
> > +			initdev_wait(INITDEV_BLOCK_TYPE, root_present);
> > +			ROOT_DEV = name_to_dev_t(saved_root_name);
> > +		}
> > +
> >  		async_synchronize_full();
> >  	}
> >  
> 
> This together with 1/7, 5/7, 6/7 looks seriously flawed, if not broken.
> 
> 1.)  It depends on the rootdelay so big that it is guaranteed that one 
> or more initdev_found() have been called before prepare_namespace()'s 
> ssleep(root_delay) is over.  This is because initdev_wait() does not 
> wait at all if called when the number of pending initdevs is 0.
> 
> Hence the whole thing, as currently implemented, is quite useless:  The 
> user/admin has to guess what a safe rootdelay value is, and then the 
> kernel will always be delayed for >= rootdelay.

I think you misunderstood.  Buses are enumerated before this code is
reached and thus initdev_found() has already been called for all attached
block devices. If there are devices found, but not probed, the number
of pending BLOCK device initdevs will be greater than zero.

Also, this code doesn't depend on rootdelay at all. In fact, avoiding
unnecessary delays both in finding devices and in finding out that you don't
have a device is the whole reason for this patch. I really can't stand
things like rootdelay so long as the hardware supports proper device
discovery.

> 2.)  The fact that initdev_wait() does not wait at all when there are no 
> pending initdevs causes another failure.  If there are sequences of the 
> following type:
> 
> 	initdev_found(INITDEV_BLOCK_TYPE);
> 	initdev_probe_done(INITDEV_BLOCK_TYPE); /* found other dev */
> 	initdev_found(INITDEV_BLOCK_TYPE);
> 	initdev_probe_done(INITDEV_BLOCK_TYPE); /* found root dev */
> 
> then prepare_namespace() will fall through without ROOT_DEV found and 
> booting will fail, won't it?

If this were to happen, then you would be correct, but since initdev_found()
is called for all block devices before reaching this code, you will only
continue once initdev_probe_done() has been called for all of those devices.

> I suspect that there are similar problems with the console and 
> networking parts of the patch series.

I'm less confident in the block code than the console and networking parts, but
don't think there is a problem with any of these.  It's also worth mentioning
that this is not a theoretical exercise--without this patch, I have no USB
console, network device, or root filesystem. With the patch, I have all three.
That is no guarantee of correctness, but it implies that it's on the right
path.

I would appreciate it if you could take a closer look at the locations where
initdev_found() and initdev_probe_done() are called and see if you still
think there is a problem.

> Stefan Richter

David VomLehn
