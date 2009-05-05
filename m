From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered
	devicesynchronization, v5
Date: Mon, 4 May 2009 17:31:23 -0700
Message-ID: <20090505003123.GD29124@cuplxvomd02.corp.sa.net>
References: <20090502022551.GA15600@cuplxvomd02.corp.sa.net> <20090502133153.GA8116@atlas.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Sergey Vlasov <vsu@altlinux.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62304 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbZEEAbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 20:31:22 -0400
Content-Disposition: inline
In-Reply-To: <20090502133153.GA8116@atlas.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 02, 2009 at 09:31:53AM -0400, Sergey Vlasov wrote:
> On Fri, May 01, 2009 at 07:25:51PM -0700, David VomLehn wrote:
> > supported on USB and SCII buses.
>                        ^^^^ typo

Yes.

> > +initdev_found(int initdev_mask)
> > +	This function must be called each time a possible init device device
> > +	is found.  It is passed a bit mask created by ORing any of the
> > +	following flags that apply to the device found:
> > +		BOOTDEV_CONSOLE_MASK
> > +		BOOTDEV_NETDEV_MASK
> > +		BOOTDEV_BLOCK_MASK
> 
> Should these also be renamed to INITDEV_* ?

Absolutely.

> > +initdev_type_found(int initdev_mask, enum initdev_type type)
> > +	If the type of a init device could not be found, but was determined
> > +	later, this function can be used to indicate the device type. It
> > +	is passed the mask that was originally passed to initdev_found.
> > +	Note that, if a device for which initdev_found is called is
> > +	subsequently determine not to be a possible init device, this function
> > +	should not be called. Instead, initdev_probe_done should be
> > +	called.
> 
> This function is never used in your patches - maybe drop it for now
> and introduce when a need for it arises?

Agreed.

> > diff --git a/drivers/base/initdev.c b/drivers/base/initdev.c
> > new file mode 100644
> > index 0000000..eaf53e3
> > --- /dev/null
> > +++ b/drivers/base/initdev.c
...
> > +__init int initdevs_init(void)
> > +{
> > +	int	i;
> > +
> > +	for (i = 0; i < ARRAY_SIZE(initdev_info); i++) {
> > +		atomic_set(&initdev_info[i].pending, 0);
> > +		init_waitqueue_head(&initdev_info[i].wq);
> > +	}
> > +
> > +	return 0;
> 
> The return value is useless - it is never checked.

Yes, it should be a void function.

> > +#ifdef CONFIG_NETCONSOLE
> > +static int initdev_add_netconsole(int initdev_mask)
> > +{
> > +	return (initdev_mask & BOOTDEV_NETDEV_MASK) ?
> > +		initdev_mask | BOOTDEV_CONSOLE : initdev_mask;
> 
> This should be BOOTDEV_CONSOLE_MASK.

Ouch. Good catch.
> > +			if (atomic_dec_return(&initdev_info[i].pending) == 0)
...
> 
> May be replaced by a more commonly used atomic function:
> 
> 			if (atomic_dec_and_test(&initdev_info[i].pending))

Definitely better.
...
> What if type == BOOTDEV_NETDEV, and CONFIG_NETCONSOLE is defined?
> In this case we must keep both BOOTDEV_NETDEV and BOOTDEV_CONSOLE
> (otherwise the subsequent initdev_probe_done(BOOTDEV_NETDEV_MASK) will
> mess up the pending counter for BOOTDEV_CONSOLE).
> 
> Or, as noted above, just drop this function if is it not actually
> needed anywhere.

The function is gone. If it gets resurrected, we'll just have to deal with it.

> > +			if (atomic_dec_return(&initdev_info[i].pending) == 0)
> 
> 			if (atomic_dec_and_test(&initdev_info[i].pending))

Yes.
> > +void initdev_wait(enum initdev_type type, bool (*done)(void))
> 
> This function should probably be __init - there is no point to invoke
> it outside of the boot-time initialization code.

True.

> Unfortunately, the rest of code and data in this file (which will be
> useless after the boot-time initialization is complete) cannot be
> discarded, which will cause typical complaints that the kernel gets
> more and more bloated with each release.

And I'll be one of the complainers. Still, the one sure way to stop kernel
growth is to stop adding functionality and stop fixing bugs. I console
myself wth the observation Michael Opdenacker made at this year's
System Size BOF at this year's ELC: system size is growing at a slower rate
than Moore's Law. So, even though the kernel grows each year, the memory it
uses gets cheaper and cheaper.

Thanks for your comments!

David VomLehn

