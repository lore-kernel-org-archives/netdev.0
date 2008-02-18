From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Sun, 17 Feb 2008 20:21:11 -0700
Message-ID: <20080218032111.GA7970@colo.lackof.org>
References: <200801262158.12016.linux@rainbow-software.org> <200801302123.07783.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:48606 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754078AbYBRDVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 22:21:30 -0500
Content-Disposition: inline
In-Reply-To: <200801302123.07783.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 09:23:06PM +0100, Ondrej Zary wrote:
> On Saturday 26 January 2008 21:58:10 Ondrej Zary wrote:
> > Hello,
> > I was having problems with these FreedomLine cards with Linux before but
> > tested it thoroughly today. This card uses DEC 21041 chip and has TP and
> > BNC connectors:
> >
> > 00:12.0 Ethernet controller [0200]: Digital Equipment Corporation DECchip
> > 21041 [Tulip Pass 3] [1011:0014] (rev 21)
> >
> >
> > de2104x driver was loaded automatically by udev and card seemed to work.
> > Until I disconnected the TP cable and putting it back after a while. The
> > driver then switched to (non-existing) AUI port and remained there. I tried
> > to set media to TP using ethtool - and the whole kernel crashed because of
> > BUG_ON(de_is_running(de));
> > in de_set_media(). Seems that the driver is unable to stop the DMA in
> > de_stop_rxtx().

The BUG_ON() is probably fine normally. But the media selection sounds broken.
It's possible to select the wrong media type with 21040 chip but shouldn't
be possible with 21041. For 21040 support, see de21040_get_media_info().
But de21041_get_srom_info() is expected to determine which media
types are supported from SEPROM "media blocks".   My guess is that code
is broken since it seems to work with de405 driver. If you care to
work the difference, I'd be happy to make a patch to fix that up.

Also, from code review, DE2104X driver still has a few places with
potential PCI MMIO Write posting issues.  Specifically, I was looking
in de_stop_hw() and de_set_media(). Several other bits of code correctly
flush MMIO writes: e.g. tulip_read_eeprom().


> > I commented out AUI detection in the driver - this time it switched to BNC
> > after unplugging the cable and remained there. I also attempted to reset
> > the chip when de_stop_rxtx failed but failed to do it.

You'd have to basically hardcode only one media type and it's corresponding
parameters.

> > Then I found that there's de4x5 driver which supports the same cards as
> > de2104x (and some other too) - and this one works fine! I can plug and
> > unplug the cable and even change between TP and BNC ports just by
> > unplugging one and plugging the other cable in. Unfortunately, this driver
> > is blacklisted by default - at least in Slackware and Debian.

ISTR there was a time when tulip would compete with de4x5 for devices.
tulip is the preferred driver. That's clearly no longer the case
and perhaps both distro's need to revisit this.

> > The question is: why does de2104x exist? Does it work better with some
> > hardware?

de2104x is a "work in progress".
That's why it's marked "EXPERIMENTAL" in the Kconfig file.

> > BTW. Found that the problem exist at least since 2003:
> > http://oss.sgi.com/archives/netdev/2003-08/msg00951.html
> 
> Does the de2104x driver work correctly for anyone?

No idea. I've only used tulip driver.

thanks for the bug report,
grant
