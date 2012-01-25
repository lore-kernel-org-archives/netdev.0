From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V4 2/4] CS89x0 : add CS89x0 platform device to the
 iMX21ADS board
Date: Wed, 25 Jan 2012 18:06:22 +0100
Message-ID: <20120125170622.GX5446@pengutronix.de>
References: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
 <20120123093420.GL5446@pengutronix.de>
 <CAGzjT4eODr-8yUUSLxeZQ_O1H3Fngep=rDwM_RaiT4xT6aVD-A@mail.gmail.com>
 <20120124105653.GU5446@pengutronix.de>
 <CAGzjT4eLGYjLd3WKLaxVK-S7p+d4jndAuvdJJTvMp7ZvZrqG0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52644 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756207Ab2AYRGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 12:06:52 -0500
Content-Disposition: inline
In-Reply-To: <CAGzjT4eLGYjLd3WKLaxVK-S7p+d4jndAuvdJJTvMp7ZvZrqG0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 09:34:09PM +0100, Jaccon Bastiaansen wrote:
> >> >
> >> > Since you now use ioremap the cs89x0 driver this mapping is not used
> >> > for the cs89x0 anymore, so it's strange to have references to it
> >> > here.
> >> > You still need the mapping though, but only for MX21ADS_IO_REG.
> >> >
> >>
> >> The ST16C255 UART is the first peripheral in the CS1 memory range for
> >> which this fixed mapping is now required. I could create another
> >> constant (for example: MX21ADS_ST16C255_OFFSET) to indicate the offset
> >> in the CS1 memory range where the mapping should start. But since that
> >> would create another constant with the same value as
> >> MX21ADS_CS8900A_MMIO_SIZE, I decided to use MX21ADS_CS8900A_MMIO_SIZE.
> >>
> >> Do you prefer to a constant with another name here?
> >
> > Ok, looking again at it I understand what you are doing here and it
> > seems wrong. Instead of mapping MX21_CS1_BASE_ADDR you now map
> > MX21_CS1_BASE_ADDR + MX21ADS_CS8900A_MMIO_SIZE. This means that the
> > offset to MX21ADS_IO_REG is no longer 0x800000 but
> > 0x800000 - MX21ADS_CS8900A_MMIO_SIZE.
> > Please just keep the mapping like it was before, it won't hurt.
> > BTW the 8250 serial driver also ioremaps the memory if you add
> > UPF_IOREMAP to the platform data.
> >
> > Sascha
> >
> 
> You are right, this mapping is now wrong.
> 
> The reason I didn't keep the mapping as is, is because then the
> physical pages from MX21_CS1_BASE_ADDR up to MX21_CS1_BASE_ADDR +
> MX21ADS_CS8900A_MMIO_SIZE would be mapped twice to different virtual
> addresses (once by this static mapping and once by the ioremap in the
> cs89x0 driver).

This won't hurt, you will even get the same virtual address you have in
the static mapping returned from ioremap since this commit:

commit 576d2f2525612ecb5af029a76f21f22a3b82563d
Author: Nicolas Pitre <nicolas.pitre@linaro.org>
Date:   Fri Sep 16 01:14:23 2011 -0400

    ARM: add generic ioremap optimization by reusing static mappings
    
    Now that we have all the static mappings from iotable_init() located
    in the vmalloc area, it is trivial to optimize ioremap by reusing those
    static mappings when the requested physical area fits in one ofi them,
    and so in a generic way for all platforms.
    
    Signed-off-by: Nicolas Pitre <nicolas.pitre@linaro.org>
    Tested-by: Stephen Warren <swarren@nvidia.com>
    Tested-by: Kevin Hilman <khilman@ti.com>
    Tested-by: Jamie Iles <jamie@jamieiles.com>



-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
