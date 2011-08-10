From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Add pch ieee1588 driver for Intel EG20T PCH
Date: Wed, 10 Aug 2011 09:28:52 +0200
Message-ID: <20110810072852.GA3619@riccoc20.at.omicron.at>
References: <1312352861-10955-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
 <20110803192331.GA11166@riccoc20.at.omicron.at>
 <817E42EB77CC464D9F0BA9D4CB92C152@hacdom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tomoya-linux@dsn.okisemi.com, kok.howg.ewe@intel.com,
	joel.clark@intel.com, yong.y.wang@intel.com, qi.wang@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	richard.cochran@omicron.at
To: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <817E42EB77CC464D9F0BA9D4CB92C152@hacdom.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 10, 2011 at 02:03:32PM +0900, Toshiharu Okada wrote:
> Hi Richard
> 
> I added comment below.
> Please confirm them

Thanks, I have a few questions, below.

I will also comment on the patch itself.

> >Section 14.6.1.10 in the data sheet seems to imply that the input
> >clock is 50 MHz. In that case you could use a nominal frequency of
> >31.25 MHz (period 32 ns, SHIFT 5). However, you need to find out
> >the actual input clock frequency. If this can vary, then the driver
> >should allow changing these values.
> 
> modify as follows.
> 
> #define DEFAULT_ADDEND 0xA0000000
> #define TICKS_NS_SHIFT  5

Have you determined the input clock frequency?
If so, what is it?

> >> + u32 ch_control;
> >
> >You never program this register. But I think the "Mode" field should
> >be set to 2. The other settings really make no sense at all.  Or do
> >you set this in the MAC driver?
> >
> >(I wonder why Intel retained the very limited PTP V1 modes from the
> >IXP time stamping unit.)
> 
> ch_control register was set as 0x80020000    (Version:1, mode:2 )

It might make more sense to set this register in the MAC driver in
connection with enabling and disabling packet time stamps (see below).

> >This ISR code (and much of the rest of the driver) is copied from the
> >IXP driver. It would be nice to know if it actually works on the atom
> >hardware. Do have any hardware to try it on?
> 
> We have a board of atom(E600) and EG20T.
> However there is no environment for confirming auxiliary snapshot.

Well, if you plan to test the auxiliary snapshot on real hardware,
then we can leave the code as it is.

Otherwise, I would prefer to move the auxiliary snapshot code into a
separate patch. Then, we can wait to merge that code until someone
tests it.

I did test the auxiliary snapshot code on the IXP465, and probably it
will work just fine, but I want to be sure that it works on the atom
before merging.

> >I would also like to see how the time stamps are done in the MAC
> >driver. Have you already posted that?
> 
> Mac driver already upstreamed. ( drivers/net/pch_gbe)
> However the code relevant to IEEE1588 is not contained into Ethernet driver.
> I have question about rx/tx snapshot.
> Is it necessary to use a snapshot within an Ethernet driver driver?
> I was indicated that there must not be any dependence of a device when the 
> Ethernet driver was upstreamed.

(I assume that you mean "time stamp" when you say, "snapshot")

You will need to also add time stamping support into that driver. That
means supporting the SIOCSHWTSTAMP ioctl. As an example, you can take
a look at drivers/net/arm/ixp4xx_eth.c.

It would be nice to have a series of two patches, one adding the PHC
driver, and one adding SIOCSHWTSTAMP to the MAC driver.

Thanks,

Richard
