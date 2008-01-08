From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 6/8] [PATCH] Split up rndis_host.c
Date: Tue, 8 Jan 2008 03:19:22 -0800
Message-ID: <200801080319.23299.david-b@pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net> <20071223011707.1798C2360C6@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <1199304827.8532.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bjd@jooz.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:26084 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750792AbYAHLT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 06:19:29 -0500
In-Reply-To: <1199304827.8532.31.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 January 2008, Jussi Kivilinna wrote:
> Hello,
> 
> Bjorge was not comfortable with double probing rndis_wext requires,
> wireless RNDIS devices have same device id as the rest of RNDIS.

I should have known Microsoft wouldn't start by assuming systems
software module boundaries should be natural and obvious ones.  :(

I see that the rndis_wext.c Kconfig won't kick in unless the
802.11 stuff is available ... what additional dependencies
does that imply for a fatter rndis_host module?  If it doesn't
cause extra modules to be loaded (even for non-WLAN devices),
then I suppose I could just live with the RNDIS module being
bigger than it needs to be.  It was pretty thin to start with!

What would bother me would be seeing that systems with this
WLAN support option configured could no longer load the basic
RNDIS code without also loading a bunch of extra modules
that weren't needed for all RNDIS devices.


> Our 
> module version checks OID_GEN_PHYSICAL_MEDIUM in generic_rndis_bind,
> with rndis_host bind fails if OID is supported and wireless media type
> is returned, with rndis_wext if OID isn't supported or type isn't
> wireless. Should this be ok?

Sounds like if you can go the different-modules route, then rndis_bind()
should maybe accept a parameter giving it that option.  Then

	rndis_wlan_bind(...) == rndis_bind(..., check_wlan_media)
	rndis_generic_bind(...) == rndis_bind(..., non_wlan_media)

That would be getting pretty complicated, since as you say the same
USB-level binding (hence hotplugging) would need to kick in ... but
having different modules for different RNDIS flavors would need a 
new hotplug mechanism keying on media type.  Ugh.


> Should separate rndis_wext be located in drivers/net/wireless instead of
> drivers/net/usb?

If that doesn't complicate maintaining that software, I can't
see why it shouldn't go there.  It might imply moving the usbnet
interface declarations to someplace linux/include though.  (And
that presumes there's actually a sane way to split that stuff
into its own module, too...)

- Dave


>  - Jussi Kivilinna
> 
> On Sat, 2007-12-22 at 17:17 -0800, David Brownell wrote:
> > > From: Bjorge Dijkstra <bjd@jooz.net>
> > > Subject: [PATCH 6/8] [PATCH] Split up rndis_host.c
> > > Date: Sat, 22 Dec 2007 22:51:32 +0100
> > >
> > > Split up rndis_host.c into rndis_host.h and rndis_base.c and
> > > change Makefile accordingly. This is done so we can add extra
> > > source files to the rndis_host module later on.
> > 
> > I'm fine with splitting out a header file and the EXPORT_SYMBOL_GPL.
> > But why not just have a separate "rndis_wext" module?
> > 
> > 
> > > ---
> > >  drivers/net/usb/Makefile     |    1 +
> > >  drivers/net/usb/rndis_base.c |  548 ++++++++++++++++++++++++++++++
> > >  drivers/net/usb/rndis_host.c |  763 ------------------------------------------
> > >  drivers/net/usb/rndis_host.h |  256 ++++++++++++++
> > >  4 files changed, 805 insertions(+), 763 deletions(-)
> > >  create mode 100644 drivers/net/usb/rndis_base.c
> > >  delete mode 100644 drivers/net/usb/rndis_host.c
> > >  create mode 100644 drivers/net/usb/rndis_host.h
> > 
> 


