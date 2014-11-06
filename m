From: Riku Voipio <riku.voipio@iki.fi>
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net on
 arndale platform
Date: Thu, 6 Nov 2014 11:06:51 +0200
Message-ID: <20141106090651.GA19109@afflict.kos.to>
References: <20141104072236.GA559@afflict.kos.to>
 <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local>
 <20141104094336.GA3145@afflict.kos.to>
 <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local>
 <20141104200914.GN23178@opensource.wolfsonmicro.com>
 <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local>
 <20141105150258.GR23178@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stam, Michel [FINT]" <M.Stam@fugro.nl>, freddy@asix.com.tw,
	davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
To: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141105150258.GR23178@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 03:02:58PM +0000, Charles Keepax wrote:
> On Wed, Nov 05, 2014 at 01:04:37PM +0100, Stam, Michel [FINT] wrote:
> > Hello Charles,
> > 
> > After looking around I found the reset value for the 8772 chip, which
> > seems to be 0x1E1 (ANAR register).
> > 
> > This equates to (according to include/uapi/linux/mii.h)
> > ADVERTISE_ALL | ADVERTISE_CSMA.
> > 
> > The register only seems to become 0 if the software reset fails.
 
> Odd it definitely reads back as zero on Arndale. I am guessing
> that the root of the problem here is that for some reason Arndale
> POR of the ethernet is pants and it needs a full software reset
> before it will work and the patch removes the full reset
> callback.

The asix on arndale comes semi-configured from u-boot, which I guess is
not the state kernel expects it to come in. At least in my case where
I use tftp from u-boot to load my kernel.

So probably the full reset is needed here to make the asix chip come
to a truly pristine state.

The commit that Michel partially reverted (by returning to use
ax88772_link_reset instead of ax88772_reset), indicates that a strong reset
is needed for suspend/resume as well:

commit 4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378
Author: Grant Grundler <grundler@chromium.org>
Date:   Tue Oct 4 09:55:16 2011 +0000

    NET: fix phy init for AX88772 USB ethernet
        
    Fix phy initialization for AX88772 (USB 2.0 100BT). Failure
    was occasionally DHCP wouldn't work after reboot or
    suspend/resume cycle.
 
> > Unfortunately, this is exactly what I get when the patch is applied;
> > asix 1-2:1.0 eth1: Failed to send software reset: ffffffb5
> > asix 1-2:1.0 eth1: link reset failed (-75) usbnet usb-0000:00:1d.0-2, 
> > ASIX AX88772 USB 2.0 Ethernet
> > asix 1-2:1.0 eth1: Failed to send software reset: ffffffb5
> > asix 1-2:1.0 eth1: link reset failed (-75) usbnet usb-0000:00:1d.0-2, 
> > ASIX AX88772 USB 2.0 Ethernet
> 
> Ok so I am guessing you have a value in the register which is
> neither the reset value or 0 and this causing problems later in
> the reset/on the next reset. I do find the naming confusing in
> the error message there as it says link reset failed but the
> link_reset callback can't fail in the driver and I modified the
> reset callback. But I guess that is just oddities of the network
> stack I am not familiar with.
> 
> The other thing that feels odd is (and again apologies as I know
> next to nothing about the networking stack) how come it is
> unexpected that the reset callback destroys the state of the
> device. Naively I would have expected that a reset callback would
> reset the device back to its default state. Here we seem to be
> trying to avoid that happening.

Indeed, it would seems some tracing would be neede to figure out in
which order the .reset and .link_reset callbacks are being called.
