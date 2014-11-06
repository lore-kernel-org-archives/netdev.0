From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Subject: RE: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net on arndale platform
Date: Thu, 6 Nov 2014 13:39:07 +0100
Message-ID: <C89EFD3CD56F64468D3D206D683A8D22039FFE16@ldam-msx2.fugro-nl.local>
References: <20141104072236.GA559@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local> <20141104094336.GA3145@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local> <20141104200914.GN23178@opensource.wolfsonmicro.com> <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local> <20141105150258.GR23178@opensource.wolfsonmicro.com> <20141106090651.GA19109@afflict.kos.to> <20141106100104.GS23178@opensource.wolfsonmicro.com> <20141106120416.GA20162@afflict.kos.to>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <freddy@asix.com.tw>, <davem@davemloft.net>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-samsung-soc@vger.kernel.org>
To: "Riku Voipio" <riku.voipio@iki.fi>,
	"Charles Keepax" <ckeepax@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20141106120416.GA20162@afflict.kos.to>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Riku and Charles,

I tried this with my original patch and the suggested patch applied,
this seems to work for me too.

One thing that bothers me, is the suspend / resume situation; usbnet.c
seems to call the bind( ) on probe( ). Suspend / resume do not seem to
call bind( ) directly.

As Riku pointed out, the original patch I reverted was because of
suspend/resume issues. I wonder if this will still work? 

Kind regards,

Michel Stam

-----Original Message-----
From: Riku Voipio [mailto:riku.voipio@iki.fi] 
Sent: Thursday, November 06, 2014 13:04 PM
To: Charles Keepax
Cc: Riku Voipio; Stam, Michel [FINT]; freddy@asix.com.tw;
davem@davemloft.net; linux-usb@vger.kernel.org; netdev@vger.kernel.org;
linux-kernel@vger.kernel.org; linux-samsung-soc@vger.kernel.org
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net
on arndale platform

On Thu, Nov 06, 2014 at 10:01:04AM +0000, Charles Keepax wrote:
> On Thu, Nov 06, 2014 at 11:06:51AM +0200, Riku Voipio wrote:
> > The asix on arndale comes semi-configured from u-boot, which I guess

> > is not the state kernel expects it to come in. At least in my case 
> > where I use tftp from u-boot to load my kernel.
> > 
> > So probably the full reset is needed here to make the asix chip come

> > to a truly pristine state.
> > 
> > The commit that Michel partially reverted (by returning to use 
> > ax88772_link_reset instead of ax88772_reset), indicates that a 
> > strong reset is needed for suspend/resume as well:
 
> Ok I think I have cracked this one. I am pretty sure you are right 
> that the USB comes to us in a strange state and needs a full reset, 
> but that only needs to happen once when the driver is bound in. So 
> there is some code in ax88772_bind that appears to try to reset the 
> device but does a lot less than ax88772_reset and I think that must be

> the problem. Applying the following on top of the patch we have been 
> debating I think will make everything work for all of us:

The patch below on top of 3.18-rc3 fixes arndale network for me.

Tested-by: Riku Voipio <riku.voipio@linaro.org>

> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -465,19 +465,7 @@ static int ax88772_bind(struct usbnet *dev, 
> struct usb_interface *in
>                 return ret;
>         }
> 
> -       ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
> -       if (ret < 0)
> -               return ret;
> -
> -       msleep(150);
> -
> -       ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
> -       if (ret < 0)
> -               return ret;
> -
> -       msleep(150);
> -
> -       ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL :
AX_SWRESET_PRTE);
> +       ax88772_reset(dev);
> 
> If you guys could test that and let me know how you get on I will send

> in a proper patch if it looks good.
> 
> Thanks,
> Charles
