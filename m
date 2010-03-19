From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus
 Carrier Board
Date: Fri, 19 Mar 2010 08:13:26 -0700
Message-ID: <20100319151326.GA13672@ovro.caltech.edu>
References: <>
 <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
 <4BA34026.8010806@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, sameo@linux.intel.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:57682 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab0CSPN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 11:13:28 -0400
Content-Disposition: inline
In-Reply-To: <4BA34026.8010806@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 10:13:10AM +0100, Wolfgang Grandegger wrote:
> Ira W. Snyder wrote:
> > The Janz CMOD-IO PCI MODULbus carrier board is a PCI to MODULbus bridge,
> > which may host many different types of MODULbus daughterboards, including
> > CAN and GPIO controllers.
> > 
> > Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> > Cc: Samuel Ortiz <sameo@linux.intel.com>
> 
> You can add my "Reviewed-by: Wolfgang Grandegger <wg@grandegger.com>".
> 
> Just one concern:
> 
> > ---
> >  drivers/mfd/Kconfig       |    8 +
> >  drivers/mfd/Makefile      |    1 +
> >  drivers/mfd/janz-cmodio.c |  339 +++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/mfd/janz.h  |   54 +++++++
> >  4 files changed, 402 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/mfd/janz-cmodio.c
> >  create mode 100644 include/linux/mfd/janz.h
> > 
> > diff --git a/drivers/mfd/Kconfig b/drivers/mfd/Kconfig
> > index 8782978..f1858d7 100644
> > --- a/drivers/mfd/Kconfig
> > +++ b/drivers/mfd/Kconfig
> > @@ -27,6 +27,14 @@ config MFD_SM501_GPIO
> >  	 lines on the SM501. The platform data is used to supply the
> >  	 base number for the first GPIO line to register.
> >  
> > +config MFD_JANZ_CMODIO
> > +	tristate "Support for Janz CMOD-IO PCI MODULbus Carrier Board"
> > +	---help---
> > +	  This is the core driver for the Janz CMOD-IO PCI MODULbus
> > +	  carrier board. This device is a PCI to MODULbus bridge which may
> > +	  host many different types of MODULbus daughterboards, including
> > +	  CAN and GPIO controllers.
> > +
> >  config MFD_ASIC3
> >  	bool "Support for Compaq ASIC3"
> >  	depends on GENERIC_HARDIRQS && GPIOLIB && ARM
> > diff --git a/drivers/mfd/Makefile b/drivers/mfd/Makefile
> > index e09eb48..e8fa905 100644
> > --- a/drivers/mfd/Makefile
> > +++ b/drivers/mfd/Makefile
> > @@ -3,6 +3,7 @@
> >  #
> >  
> >  obj-$(CONFIG_MFD_SM501)		+= sm501.o
> > +obj-$(CONFIG_MFD_JANZ_CMODIO)	+= janz-cmodio.o
> >  obj-$(CONFIG_MFD_ASIC3)		+= asic3.o tmio_core.o
> >  obj-$(CONFIG_MFD_SH_MOBILE_SDHI)		+= sh_mobile_sdhi.o
> >  
> > diff --git a/drivers/mfd/janz-cmodio.c b/drivers/mfd/janz-cmodio.c
> > new file mode 100644
> > index 0000000..914280e
> > --- /dev/null
> > +++ b/drivers/mfd/janz-cmodio.c
> > @@ -0,0 +1,339 @@
> > +/*
> > + * Janz CMOD-IO MODULbus Carrier Board PCI Driver
> > + *
> > + * Copyright (c) 2010 Ira W. Snyder <iws@ovro.caltech.edu>
> > + *
> > + * Lots of inspiration and code was copied from drivers/mfd/sm501.c
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of the GNU General Public License as published by the
> > + * Free Software Foundation; either version 2 of the License, or (at your
> > + * option) any later version.
> > + */
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/module.h>
> > +#include <linux/init.h>
> > +#include <linux/pci.h>
> > +#include <linux/interrupt.h>
> > +#include <linux/delay.h>
> > +#include <linux/platform_device.h>
> > +
> > +#include <linux/mfd/janz.h>
> > +
> > +#define DRV_NAME "janz-cmodio"
> > +
> > +/* Size of each MODULbus module in PCI BAR4 */
> > +#define CMODIO_MODULBUS_SIZE	0x200
> > +
> > +/* Maximum number of MODULbus modules on a CMOD-IO carrier board */
> > +#define CMODIO_MAX_MODULES	4
> > +
> > +/* Module Parameters */
> > +static unsigned int num_modules = CMODIO_MAX_MODULES;
> > +static unsigned char *modules[CMODIO_MAX_MODULES] = {
> > +	"janz-ican3",
> > +	"janz-ican3",
> > +	"",
> > +	"janz-ttl",
> > +};
> 
> This is probably not a good default but just your private configuration.
> 

Yep, that's the configuration I have. Do you have any suggestions for a
better default? I could make them all blank strings, which means "no
daughtercard in this slot". That is my only idea for a different
default.

Thanks for the review!
Ira
