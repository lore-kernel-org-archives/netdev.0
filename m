From: Andres Salomon <dilinger@queued.net>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Wed, 6 Apr 2011 11:25:57 -0700
Message-ID: <20110406112557.5c4c9bfe@debxo>
References: <20110401112030.GA3447@sortiz-mobl>
	<20110401104756.2f5c6f7a@debxo>
	<BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
	<20110401235239.GE29397@sortiz-mobl>
	<BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
	<20110404100314.GC2751@sortiz-mobl>
	<20110405030428.GB29522@ponder.secretlab.ca>
	<20110406152322.GA2757@sortiz-mobl>
	<20110406155805.GA20095@suse.de>
	<20110406170537.GB2757@sortiz-mobl>
	<20110406175647.GA8048@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <sameo@linux.intel.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from LUNGE.MIT.EDU ([18.54.1.69]:35430 "EHLO lunge.queued.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368Ab1DFS0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 14:26:09 -0400
In-Reply-To: <20110406175647.GA8048@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Apr 2011 10:56:47 -0700
Greg KH <gregkh@suse.de> wrote:

> On Wed, Apr 06, 2011 at 07:05:38PM +0200, Samuel Ortiz wrote:
> > Hi Greg,
> > 
> > On Wed, Apr 06, 2011 at 08:58:05AM -0700, Greg KH wrote:
> > > On Wed, Apr 06, 2011 at 05:23:23PM +0200, Samuel Ortiz wrote:
> > > > --- a/include/linux/device.h
> > > > +++ b/include/linux/device.h
> > > > @@ -33,6 +33,7 @@ struct class;
> > > >  struct subsys_private;
> > > >  struct bus_type;
> > > >  struct device_node;
> > > > +struct mfd_cell;
> > > >  
> > > >  struct bus_attribute {
> > > >  	struct attribute	attr;
> > > > @@ -444,6 +445,8 @@ struct device {
> > > >  	struct device_node	*of_node; /* associated
> > > > device tree node */ const struct of_device_id *of_match; /*
> > > > matching of_device_id from driver */ 
> > > > +	struct mfd_cell	*mfd_cell; /* MFD cell pointer
> > > > */ +
> > > 
> > > What is a "MFD cell pointer" and why is it needed in struct
> > > device?
> > An MFD cell is an MFD instantiated device.
> > MFD (Multi Function Device) drivers instantiate platform devices.
> > Those devices drivers sometimes need a platform data pointer,
> > sometimes an MFD specific pointer, and sometimes both. Also, some
> > of those drivers have been implemented as MFD sub drivers, while
> > others know nothing about MFD and just expect a plain platform_data
> > pointer.
> 
> That sounds like a bug in those drivers, why not fix them to properly
> pass in the correct pointer?

I'm still trying to understand if this is a theoretical problem, or if
Grant has actually experienced a regression.  His mention of bisecting
made it sound like the latter was the case, but I've yet to hear of
specifically what drivers this was breaking.  Samuel described some
potential driver breakage, but nothing concrete.

I do agree that this needs a better solution, given the theoretical
breakage.

> 
> > We've been faced with the problem of being able to pass both MFD
> > related data and a platform_data pointer to some of those drivers.
> > Squeezing the MFD bits in the sub driver platform_data pointer
> > doesn't work for drivers that know nothing about MFDs. It also adds
> > an additional dependency on the MFD API to all MFD sub drivers.
> > That prevents any of those drivers to eventually be used as plain
> > platform device drivers.
> 
> Then they shouldn't be "plain" platform drivers, that should only be
> reserved for drivers that are the "lowest" type.  Just make them MFD
> devices and go from there.


The problem is of mixing "plain" platform devices and MFD devices.
It's reasonable to assume that different hardware may be using
one method or the other to create devices; in order to maintain
compatibility with the driver, one either needs to use a plain platform
device.  Alternatively, if an MFD-specific device class is created,
then MFD devices would start showing up in weird places.

> 
> > So, adding an MFD cell pointer to the device structure allows us to
> > cleanly pass both pieces of information, while keeping all the MFD
> > sub drivers independant from the MFD core if they want/can.
> 
> They shouldn't be "independant", make them "dependant" and go from
> there.
> 
> thanks,
> 
> greg k-h

