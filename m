From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 09/15] tg3: Allow WOL for phylib controlled Broadcom
 phys
Date: Mon, 3 Nov 2008 18:46:36 -0800
Message-ID: <20081104024636.GA6315@xw6200.broadcom.net>
References: <1225751626.6190@xw6200>
 <2acbd3e40811031509q3d3005e5g9fedd842a1d08a52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Andy Fleming" <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2938 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbYKDCqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 21:46:47 -0500
In-Reply-To: <2acbd3e40811031509q3d3005e5g9fedd842a1d08a52@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 03:09:34PM -0800, Andy Fleming wrote:
> On Mon, Nov 3, 2008 at 4:13 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > This patch allows WOL to be enabled for Broadcom phys under phylib
> > control.  The only exception is the AC131, which has a completely
> > different register set.
> >
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Code to enable WOL sounds like the sort of thing we'd want in the PHY
> driver itself, rather than a manual setup done from the NIC driver.
> Clearly, we need support for WOL on both in order for it to work,
> though, so I can see two solutions off the top of my head:

Disregarding my diatribe below for a moment, I'd think you'd need both.
(1) informs the phylib how and to what state to bring the phy down,
(2) informs phylib how to bring the phy back to full power.

> 1) phy_connect() allows for passing in flags.  Maybe we should create
> one for WOL, and have the config_init() functions for the Broadcom
> PHYs check that, and set it up.

> 2) The appropriate code can register a phy_fixup, which will be
> invoked whenever the PHY is initialized.  The fixup can be restricted
> based on PHY ID and address.
> 
> It seems to me that WOL support is probably a common desire, so we
> should either always enable it, or provide generic infrastructure for
> enabling it, so that your driver doesn't need to know what PHY it is
> connecting to.

I suppose I should have thought out the wording of the patch description
more carefully.  The patch isn't enabling WOL.  Rather, it is allowing the
driver to bring the phy to a lower powered state.  This patch is mostly
about maximizing power savings.

WOL is mostly a function of the MAC.  Disregarding power budgets for the
moment, there is nothing the phy is required (or should be required) to
do to support WOL.  You should be able to configure the phy however you
wish and, as long as you have link, you should be able to wake the
machine.

To remove these phy writes from the tg3 driver then, phylib would have
to take on the burden of power management.  To bring the phy to a lower
powered state means that you also need a way to bring it back to full
power.  That implies taking complete control of the lifetime of the
phy, starting from phy powerup and ending at either configuring the phy
for a low power state or turning it off entirely.

I had toyed around with that idea for some time, but I just don't think
it is the proper thing to do.  There are two problems that I can see
with that approach.  The first problem is that we would need a way to
express exactly what state to leave the phy in when phy_disconnect() is
called.  There can be other agents, like management firmware, that
require the phy to be enabled for use even after the driver has
released the phy.  The process by which the driver would inform the
phylib this information would look very similar to the code sequence in
tg3_set_power_state().  In other words, we really aren't gaining
anything if the abstraction is just as verbose as the present API usage.
(Is it worth it to remove one or two phy specific writes from the
driver?)

The other problem is that there can be deeper interactions between the
phy and the MAC that are not all that apparent.  In some earlier tg3
devices, if you shutdown the phy, certain MAC registers would be
inaccessible or yeild bad values.  To solve this problem, the driver
needs finer grained control over the power state of the phy.  Of course
this is just one example off the top of my head and I can't speak
towards the similar types of problems that might exist in other
hardware.

Unfortunately, the devil is in the details.


